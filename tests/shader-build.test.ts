import { assertEquals, assertRejects, assertThrows } from "@std/assert";
import { buildShaders, parseShaderManifest } from "../scripts/build-shaders.ts";
import { runCommand } from "../scripts/utils/command.ts";

Deno.test("shader manifest validates safe, explicit source contracts", () => {
  const manifest = parseShaderManifest({
    version: 1,
    shaders: [{
      name: "sample",
      input: "sample.hlsl",
      language: "hlsl",
      stage: "vertex",
    }],
  });
  assertEquals(manifest.shaders[0].entrypoint, undefined);
  assertThrows(
    () =>
      parseShaderManifest({
        version: 1,
        shaders: [{ name: "../unsafe", input: "sample.hlsl", language: "hlsl", stage: "vertex" }],
      }),
    Error,
    "safe identifier",
  );
  assertThrows(
    () =>
      parseShaderManifest({
        version: 1,
        shaders: [{ name: "zig", input: "shader.zig", language: "zig", stage: "vertex" }],
      }),
    Error,
    "source_language",
  );
});

Deno.test("shader helper reports a missing required compiler", async () => {
  const temporary = await makeShaderTemp("sdl3-shader-diagnostic-");
  try {
    await Deno.writeTextFile(`${temporary}/shader.hlsl`, "void main() {}");
    await Deno.writeTextFile(
      `${temporary}/manifest.json`,
      JSON.stringify({
        version: 1,
        shaders: [{ name: "shader", input: "shader.hlsl", language: "hlsl", stage: "vertex" }],
      }),
    );
    await assertRejects(
      () =>
        buildShaders({
          manifest: `${temporary}/manifest.json`,
          output: `${temporary}/output`,
          shadercross: `${temporary}/missing-shadercross`,
        }),
      Error,
      "Required shader tool 'missing-shadercross'",
    );
    await Deno.writeTextFile(`${temporary}/shader.glsl`, "#version 450\nvoid main() {}");
    await Deno.writeTextFile(
      `${temporary}/glsl-manifest.json`,
      JSON.stringify({
        version: 1,
        shaders: [{ name: "shader", input: "shader.glsl", language: "glsl", stage: "vertex" }],
      }),
    );
    await assertRejects(
      () =>
        buildShaders({
          manifest: `${temporary}/glsl-manifest.json`,
          output: `${temporary}/glsl-output`,
          glslang: `${temporary}/missing-glslangValidator`,
        }),
      Error,
      "Required shader tool 'missing-glslangValidator'",
    );
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
});

Deno.test({
  name: "shader outputs load through SDL_GPU when a host loader is configured",
  ignore: !Deno.env.has("SDL_SHADER_DEVICE_LOADER") || !Deno.env.has("SDL_SHADER_OUTPUT_DIR"),
  async fn() {
    const loader = Deno.env.get("SDL_SHADER_DEVICE_LOADER")!;
    const output = Deno.env.get("SDL_SHADER_OUTPUT_DIR")!;
    for (const [format, extension] of [["spirv", "spv"], ["dxil", "dxil"], ["msl", "metal"]]) {
      await runCommand(loader, [format, `${output}/hlsl_vertex.${extension}`], {
        stdout: "inherit",
        stderr: "inherit",
      });
    }
  },
});

async function makeShaderTemp(prefix: string): Promise<string> {
  const cache = `${Deno.cwd()}/.zig-cache`;
  await Deno.mkdir(cache, { recursive: true });
  return await Deno.makeTempDir({ dir: cache, prefix });
}
