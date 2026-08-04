import { basename, dirname, isAbsolute, join, relative, resolve } from "@std/path";
import { runCommand } from "./utils/command.ts";

const outputFormats = ["spv", "dxil", "metal", "json"] as const;
const stages = ["vertex", "fragment", "compute"] as const;
const languages = ["glsl", "hlsl", "zig"] as const;

export type ShaderOutputFormat = (typeof outputFormats)[number];
export type ShaderStage = (typeof stages)[number];
export type ShaderLanguage = (typeof languages)[number];

export interface ShaderManifestEntry {
  name: string;
  input: string;
  language: ShaderLanguage;
  source_language?: "glsl" | "hlsl";
  stage: ShaderStage;
  entrypoint?: string;
}

export interface ShaderManifest {
  version: 1;
  shaders: ShaderManifestEntry[];
}

export interface BuildShadersOptions {
  manifest: string;
  output: string;
  shadercross?: string;
  glslang?: string;
}

interface BuiltShader {
  entry: ShaderManifestEntry;
  sourceLanguage: "glsl" | "hlsl";
  sourceSha256: string;
  outputs: Record<ShaderOutputFormat, { path: string; sha256: string }>;
}

export async function buildShaders(options: BuildShadersOptions): Promise<string> {
  const manifestPath = resolve(options.manifest);
  const outputRoot = resolve(options.output);
  const manifest = parseShaderManifest(JSON.parse(await Deno.readTextFile(manifestPath)));
  const manifestDirectory = dirname(manifestPath);
  await Deno.mkdir(outputRoot, { recursive: true });

  const shadercross = options.shadercross ?? Deno.env.get("SDL_SHADERCROSS") ?? "shadercross";
  const glslang = options.glslang ?? Deno.env.get("GLSLANG_VALIDATOR") ?? "glslangValidator";
  const built: BuiltShader[] = [];
  const temporary = await Deno.makeTempDir({ prefix: "sdl3-shader-build-" });
  try {
    for (const entry of manifest.shaders) {
      const input = safeResolve(manifestDirectory, entry.input, "shader input");
      const sourceLanguage = entry.language === "zig" ? entry.source_language : entry.language;
      if (!sourceLanguage) {
        throw new Error(
          `Shader ${entry.name} uses language zig and must declare source_language as glsl or hlsl`,
        );
      }
      const source = entry.language === "zig"
        ? await extractZigSource(input, temporary, entry.name)
        : await Deno.readFile(input);
      const sourceSha256 = await sha256(source);
      const outputPaths = Object.fromEntries(
        outputFormats.map((format) => [format, join(outputRoot, `${entry.name}.${format}`)]),
      ) as Record<ShaderOutputFormat, string>;
      const spirvInput = join(temporary, `${entry.name}.spv`);

      if (sourceLanguage === "glsl") {
        await invokeTool(
          glslang,
          [
            "--quiet",
            "-V",
            "--target-env",
            "vulkan1.2",
            "-S",
            glslangStage(entry.stage),
            "-e",
            entry.entrypoint ?? "main",
            "-o",
            spirvInput,
            input,
          ],
          `compile GLSL shader ${entry.name}`,
        );
      } else {
        await invokeTool(
          shadercross,
          [
            "-s",
            "HLSL",
            "-d",
            "SPIRV",
            "-t",
            entry.stage,
            "-e",
            entry.entrypoint ?? "main",
            "-o",
            spirvInput,
            "--",
            input,
          ],
          `compile HLSL shader ${entry.name}`,
        );
      }

      await Deno.copyFile(spirvInput, outputPaths.spv);
      for (
        const [format, destination] of [
          ["dxil", outputPaths.dxil],
          ["metal", outputPaths.metal],
          ["json", outputPaths.json],
        ] as const
      ) {
        await invokeTool(
          shadercross,
          [
            "-s",
            "SPIRV",
            "-d",
            format === "dxil" ? "DXIL" : format === "metal" ? "MSL" : "JSON",
            "-t",
            entry.stage,
            "-e",
            entry.entrypoint ?? "main",
            "-o",
            destination,
            "--",
            spirvInput,
          ],
          `compile ${format.toUpperCase()} shader ${entry.name}`,
        );
      }
      const outputs = {} as BuiltShader["outputs"];
      for (const format of outputFormats) {
        outputs[format] = {
          path: relative(outputRoot, outputPaths[format]).replaceAll("\\", "/"),
          sha256: await sha256(await Deno.readFile(outputPaths[format])),
        };
      }
      built.push({ entry, sourceLanguage, sourceSha256, outputs });
    }
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }

  built.sort((left, right) => left.entry.name.localeCompare(right.entry.name));
  const metadata = {
    version: 1,
    formats: outputFormats,
    shaders: built.map(({ entry, sourceLanguage, sourceSha256, outputs }) => ({
      name: entry.name,
      input: entry.input.replaceAll("\\", "/"),
      language: sourceLanguage,
      source_kind: entry.language,
      stage: entry.stage,
      entrypoint: entry.entrypoint ?? "main",
      source_sha256: sourceSha256,
      outputs,
    })),
  };
  const metadataPath = join(outputRoot, "shader-manifest.json");
  await Deno.writeTextFile(metadataPath, `${JSON.stringify(metadata, null, 2)}\n`);
  return metadataPath;
}

export function parseShaderManifest(value: unknown): ShaderManifest {
  if (!value || typeof value !== "object") throw new Error("Shader manifest must be an object");
  const manifest = value as Partial<ShaderManifest>;
  if (manifest.version !== 1) throw new Error("Shader manifest version must be 1");
  if (!Array.isArray(manifest.shaders) || manifest.shaders.length === 0) {
    throw new Error("Shader manifest must contain at least one shader");
  }
  const names = new Set<string>();
  for (const entry of manifest.shaders) {
    if (!entry || typeof entry !== "object") throw new Error("Shader manifest entry is invalid");
    const candidate = entry as Partial<ShaderManifestEntry>;
    if (typeof candidate.name !== "string" || !/^[A-Za-z0-9_-]+$/.test(candidate.name)) {
      throw new Error(`Shader name is not a safe identifier: ${String(candidate.name)}`);
    }
    if (!names.add(candidate.name)) throw new Error(`Duplicate shader name: ${candidate.name}`);
    if (typeof candidate.input !== "string" || isAbsolute(candidate.input)) {
      throw new Error(`Shader ${candidate.name} must use a relative input path`);
    }
    if (!languages.includes(candidate.language as ShaderLanguage)) {
      throw new Error(`Shader ${candidate.name} has an unsupported language`);
    }
    if (!stages.includes(candidate.stage as ShaderStage)) {
      throw new Error(`Shader ${candidate.name} has an unsupported stage`);
    }
    if (
      candidate.language === "zig" && !["glsl", "hlsl"].includes(candidate.source_language ?? "")
    ) {
      throw new Error(`Shader ${candidate.name} requires source_language for a Zig input`);
    }
    if (
      candidate.entrypoint !== undefined &&
      (typeof candidate.entrypoint !== "string" ||
        !/^[A-Za-z_][A-Za-z0-9_]*$/.test(candidate.entrypoint))
    ) {
      throw new Error(`Shader ${candidate.name} has an invalid entrypoint`);
    }
  }
  return manifest as ShaderManifest;
}

function safeResolve(base: string, path: string, description: string): string {
  const resolved = resolve(base, path);
  const escaped = relative(base, resolved).split(/[\\/]/).includes("..");
  if (escaped || isAbsolute(relative(base, resolved))) {
    throw new Error(`${description} escapes its manifest directory: ${path}`);
  }
  return resolved;
}

function glslangStage(stage: ShaderStage): "vert" | "frag" | "comp" {
  return stage === "vertex" ? "vert" : stage === "fragment" ? "frag" : "comp";
}

async function extractZigSource(
  input: string,
  temporary: string,
  name: string,
): Promise<Uint8Array> {
  const directory = join(temporary, name);
  await Deno.mkdir(directory, { recursive: true });
  await Deno.copyFile(input, join(directory, "input.zig"));
  await Deno.writeTextFile(
    join(directory, "extract.zig"),
    'const std = @import("std");\n' +
      'const input = @import("input.zig");\n' +
      "pub fn main() !void {\n" +
      "    try std.fs.File.stdout().writeAll(input.source);\n" +
      "}\n",
  );
  const result = await invokeToolResult("zig", ["run", "extract.zig"], `read Zig shader ${name}`, {
    cwd: directory,
  });
  return new TextEncoder().encode(result.stdout);
}

async function invokeTool(
  tool: string,
  args: string[],
  description: string,
  options: { cwd?: string } = {},
): Promise<void> {
  await invokeToolResult(tool, args, description, options);
}

async function invokeToolResult(
  tool: string,
  args: string[],
  description: string,
  options: { cwd?: string } = {},
): Promise<{ stdout: string; stderr: string }> {
  try {
    return await runCommand(tool, args, options);
  } catch (error) {
    throw new Error(
      `Required shader tool '${basename(tool)}' failed while trying to ${description}. ` +
        `Configure the tool path explicitly if it is not on PATH.\n${errorMessage(error)}`,
    );
  }
}

async function sha256(bytes: Uint8Array): Promise<string> {
  const digest = new Uint8Array(
    await crypto.subtle.digest("SHA-256", bytes as unknown as BufferSource),
  );
  return [...digest].map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

if (import.meta.main) {
  const manifest = argumentValue("--manifest") ?? "examples/shaders/manifest.json";
  const output = argumentValue("--output") ?? "zig-out/shaders";
  const metadata = await buildShaders({
    manifest,
    output,
    shadercross: argumentValue("--shadercross"),
    glslang: argumentValue("--glslang"),
  });
  console.log(`Wrote ${metadata}`);
}

function argumentValue(name: string): string | undefined {
  const index = Deno.args.indexOf(name);
  if (index === -1) return undefined;
  const value = Deno.args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`${name} requires a value`);
  return value;
}
