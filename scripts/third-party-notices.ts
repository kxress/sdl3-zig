import { join } from "@std/path";

const noticeName = /(?:license|licence|copying|notice|credits?)/i;
const noticeExtension = /(?:^|\.)[a-z0-9]+$/i;

/** Notices required by the locked source inputs, independent of incidental copies. */
export const requiredThirdPartyNoticePaths = [
  "LICENSE",
  "vendor/SDL3/LICENSE.txt",
  "vendor/SDL3_image/LICENSE.txt",
  "vendor/SDL3_ttf/LICENSE.txt",
  "vendor/SDL3_ttf/external/freetype/LICENSE.TXT",
  "vendor/SDL3_mixer/LICENSE.txt",
  "vendor/SDL3_net/LICENSE.txt",
  "vendor/ControllerImage/LICENSE.txt",
  "vendor/ControllerImage/art/kenney/credits.txt",
  "vendor/ControllerImage/art/standard/credits.txt",
  "vendor/SDL3_shadercross/LICENSE.txt",
  "vendor/SDL3_shadercross/external/SPIRV-Cross/LICENSE",
  "vendor/SDL3_shadercross/external/SPIRV-Headers/LICENSE",
  "vendor/SDL3_shadercross/external/SPIRV-Tools/LICENSE",
  "vendor/SDL3_shadercross/external/DirectXShaderCompiler/LICENSE.TXT",
  "vendor/SDL3_shadercross/external/DirectXShaderCompiler/external/DirectX-Headers/LICENSE",
  "vendor/SDL3_shadercross/external/DirectXShaderCompiler/external/SPIRV-Headers/LICENSE",
  "vendor/SDL3_shadercross/external/DirectXShaderCompiler/external/SPIRV-Tools/LICENSE",
] as const;

export async function collectNoticePaths(root: string): Promise<string[]> {
  const paths: string[] = [];
  if (await isFile(join(root, "LICENSE"))) paths.push("LICENSE");
  for (const directory of ["vendor", "prebuilt"]) {
    const path = join(root, directory);
    if (await isDirectory(path)) await collectNoticePathsUnder(path, directory, paths);
  }
  return paths.sort();
}

export async function collectNoticePathsUnder(
  root: string,
  prefix = "",
  output: string[] = [],
): Promise<string[]> {
  for await (const entry of Deno.readDir(root)) {
    const path = join(root, entry.name);
    const relative = prefix ? `${prefix}/${entry.name}` : entry.name;
    const stat = await Deno.stat(path);
    if (stat.isDirectory) {
      await collectNoticePathsUnder(path, relative, output);
    } else if (stat.isFile && isNoticeFile(entry.name)) {
      output.push(relative.replaceAll("\\", "/"));
    }
  }
  return output;
}

export function validateNoticeInventory(
  actual: readonly string[],
  expected: readonly string[],
  required: readonly string[] = requiredThirdPartyNoticePaths,
): void {
  const actualSet = new Set(actual);
  const expectedSet = new Set(expected);
  const missing = [...expectedSet].filter((path) => !actualSet.has(path)).sort();
  const unexpected = [...actualSet].filter((path) => !expectedSet.has(path)).sort();
  const missingRequired = required.filter((path) => !actualSet.has(path));
  if (missing.length || unexpected.length || missingRequired.length) {
    const details = [
      ...missing.map((path) => `missing expected notice: ${path}`),
      ...unexpected.map((path) => `unexpected notice: ${path}`),
      ...missingRequired.map((path) => `missing required notice: ${path}`),
    ];
    throw new Error(`Third-party notice inventory mismatch:\n${details.join("\n")}`);
  }
}

export async function writeThirdPartyNotices(
  packageRoot: string,
  expected: readonly string[],
): Promise<void> {
  const actual = await collectNoticePaths(packageRoot);
  validateNoticeInventory(actual, expected);
  const lines = [
    "# Third-party notices",
    "",
    "This release includes the following notices from its locked source and binary inputs:",
    "",
  ];
  for (const path of actual) {
    lines.push(`- ${path} (sha256: ${await sha256(join(packageRoot, path))})`);
  }
  await Deno.writeTextFile(join(packageRoot, "THIRD_PARTY_NOTICES"), `${lines.join("\n")}\n`);
}

function isNoticeFile(name: string): boolean {
  return noticeName.test(name) && noticeExtension.test(name) && !name.endsWith(".h");
}

async function sha256(path: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", await Deno.readFile(path));
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

async function isFile(path: string): Promise<boolean> {
  try {
    return (await Deno.stat(path)).isFile;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

async function isDirectory(path: string): Promise<boolean> {
  try {
    return (await Deno.stat(path)).isDirectory;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}
