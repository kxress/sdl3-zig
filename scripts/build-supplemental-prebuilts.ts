import { copy } from "@std/fs/copy";
import { dirname, resolve } from "@std/path";
import { repositoryRoot } from "./utils/paths.ts";

type Target =
  | "x86-windows-gnu"
  | "x86_64-windows-gnu"
  | "x86-windows-msvc"
  | "x86_64-windows-msvc"
  | "aarch64-windows-msvc"
  | "macos";

const args = Deno.args[0] === "--" ? Deno.args.slice(1) : Deno.args;
const options = parseArgs(args);
const target = options.target as Target | undefined;
if (!target || !isTarget(target) || !options.output) {
  throw new Error(
    "usage: build-supplemental-prebuilts.ts --target <windows target|macos> --output <directory> [--dxc-root <directory>]",
  );
}
if (target !== "macos" && !options.dxcRoot) {
  throw new Error("Windows supplemental shadercross builds require --dxc-root");
}

const output = resolve(repositoryRoot, options.output);
const work = await Deno.makeTempDir({
  dir: `${repositoryRoot}/.zig-cache`,
  prefix: "release-prebuilt-",
});
try {
  const prefix = `${work}/prefix`;
  const configuration = target === "macos" ? [] : ["--config", "Release"];
  const platformArgs = cmakePlatformArgs(target);
  await cmake("vendor/SDL3", `${work}/sdl`, [
    `-DCMAKE_INSTALL_PREFIX=${prefix}`,
    "-DSDL_SHARED=ON",
    "-DSDL_STATIC=OFF",
    "-DSDL_TEST_LIBRARY=ON",
    "-DSDL_TESTS=OFF",
    "-DSDL_EXAMPLES=OFF",
    ...platformArgs,
  ]);
  await cmakeBuild(`${work}/sdl`, ["--target", "install", ...configuration]);

  await cmake("vendor/ControllerImage", `${work}/controller-image`, [
    `-DCMAKE_PREFIX_PATH=${prefix}`,
    ...platformArgs,
  ]);
  await cmakeBuild(`${work}/controller-image`, [
    "--target",
    "controllerimage",
    "make-controllerimage-data",
    ...configuration,
  ]);

  const shaderArgs = target === "macos"
    ? ["-DSDLSHADERCROSS_DXC=OFF", "-DSDLSHADERCROSS_VENDORED=ON"]
    : [
      "-DSDLSHADERCROSS_DXC=ON",
      "-DSDLSHADERCROSS_VENDORED=OFF",
      `-DDirectXShaderCompiler_ROOT=${resolve(repositoryRoot, options.dxcRoot!)}`,
    ];
  if (target !== "macos") await buildSpirvCross(work, prefix, platformArgs, configuration);
  await cmake("vendor/SDL3_shadercross", `${work}/shadercross`, [
    `-DCMAKE_INSTALL_PREFIX=${prefix}`,
    `-DCMAKE_PREFIX_PATH=${prefix}`,
    "-DSDLSHADERCROSS_SHARED=ON",
    "-DSDLSHADERCROSS_STATIC=OFF",
    "-DSDLSHADERCROSS_SPIRVCROSS_SHARED=OFF",
    "-DSDLSHADERCROSS_CLI=OFF",
    "-DSDLSHADERCROSS_INSTALL=ON",
    "-DSDLSHADERCROSS_INSTALL_RUNTIME=ON",
    ...shaderArgs,
    ...platformArgs,
  ]);
  await cmakeBuild(`${work}/shadercross`, ["--target", "install", ...configuration]);

  await stage(target, output, work, prefix);
  await Deno.writeTextFile(`${output}/MANIFEST.txt`, `${target}\n`);
} finally {
  await Deno.remove(work, { recursive: true });
}

async function buildSpirvCross(
  work: string,
  prefix: string,
  platformArgs: string[],
  configuration: string[],
): Promise<void> {
  await cmake("vendor/SDL3_shadercross/external/SPIRV-Cross", `${work}/spirv-cross`, [
    `-DCMAKE_INSTALL_PREFIX=${prefix}`,
    "-DSPIRV_CROSS_SHARED=OFF",
    "-DSPIRV_CROSS_STATIC=ON",
    "-DSPIRV_CROSS_CLI=OFF",
    "-DSPIRV_CROSS_ENABLE_TESTS=OFF",
    ...platformArgs,
  ]);
  await cmakeBuild(`${work}/spirv-cross`, ["--target", "install", ...configuration]);
}

async function stage(target: Target, output: string, work: string, prefix: string): Promise<void> {
  const isMac = target === "macos";
  const family = isMac ? "macos" : target.endsWith("-gnu") ? "windows-gnu" : "windows-msvc";
  const arch = target.split("-")[0];
  const root = (component: string) =>
    isMac ? `${output}/${component}/macos` : `${output}/${component}/${family}/${arch}`;
  const staticName = (name: string) =>
    isMac || family === "windows-gnu" ? `lib${name}.a` : `${name}.lib`;

  await copyFile(
    `${prefix}/lib/${staticName("SDL3_test")}`,
    `${root("test")}/lib/${staticName("SDL3_test")}`,
  );
  const controller = await findFile(`${work}/controller-image`, staticName("controllerimage"));
  await copyFile(controller, `${root("controller_image")}/lib/${staticName("controllerimage")}`);

  if (isMac) {
    const shadercross = `${root("shadercross")}/lib/libSDL3_shadercross.dylib`;
    await copyFile(`${prefix}/lib/libSDL3_shadercross.dylib`, shadercross);
    await command(
      "install_name_tool",
      ["-id", "@rpath/libSDL3_shadercross.dylib", shadercross],
      repositoryRoot,
    );
  } else {
    const shared = "SDL3_shadercross.dll";
    const importName = family === "windows-gnu"
      ? "libSDL3_shadercross.dll.a"
      : "SDL3_shadercross.lib";
    await copyFile(`${prefix}/bin/${shared}`, `${root("shadercross")}/bin/${shared}`);
    await copyFile(`${prefix}/lib/${importName}`, `${root("shadercross")}/lib/${importName}`);
    for (const file of ["dxcompiler.dll", "dxil.dll"]) {
      const source = await findFile(prefix, file);
      await copyFile(source, `${root("shadercross")}/dxc/${file}`);
    }
    const dxcRoot = Deno.env.get("DXC_ROOT");
    if (dxcRoot) {
      for (const notice of ["LICENSE.TXT", "ThirdPartyNotices.txt"]) {
        const source = await findFile(dxcRoot, notice);
        await copyFile(source, `${root("shadercross")}/dxc/${notice}`);
      }
    }
  }

  const generator = await findFile(
    `${work}/controller-image`,
    isMac ? "make-controllerimage-data" : "make-controllerimage-data.exe",
  );
  const data = `${work}/controller-data`;
  await Deno.mkdir(data, { recursive: true });
  await command(generator, [`${repositoryRoot}/vendor/ControllerImage/art`], data);
  await copy(data, `${root("controller_image")}/share/ControllerImage`);
}

function cmakePlatformArgs(target: Target): string[] {
  if (target === "macos") return ["-DCMAKE_OSX_ARCHITECTURES=x86_64;arm64"];
  const [, , abi] = target.split("-");
  if (abi === "gnu") return ["-G", "MinGW Makefiles", "-DCMAKE_BUILD_TYPE=Release"];
  const arch = target.startsWith("x86_64")
    ? "x64"
    : target.startsWith("aarch64")
    ? "ARM64"
    : "Win32";
  return ["-G", "Visual Studio 17 2022", "-A", arch];
}

async function cmake(source: string, build: string, arguments_: string[]): Promise<void> {
  await command(
    "cmake",
    ["-S", `${repositoryRoot}/${source}`, "-B", build, ...arguments_],
    repositoryRoot,
  );
}
async function cmakeBuild(build: string, arguments_: string[]): Promise<void> {
  await command("cmake", ["--build", build, ...arguments_], repositoryRoot);
}
async function command(command_: string, args_: string[], cwd: string): Promise<void> {
  const result = await new Deno.Command(command_, {
    args: args_,
    cwd,
    stdout: "inherit",
    stderr: "inherit",
  }).output();
  if (!result.success) throw new Error(`${command_} exited with ${result.code}`);
}
async function copyFile(source: string, destination: string): Promise<void> {
  await Deno.mkdir(dirname(destination), { recursive: true });
  await copy(source, destination);
}
async function findFile(root: string, name: string): Promise<string> {
  for await (const entry of walk(root)) if (entry.endsWith(`/${name}`)) return entry;
  throw new Error(`Could not find ${name} below ${root}`);
}
async function* walk(root: string): AsyncGenerator<string> {
  for await (const entry of Deno.readDir(root)) {
    const path = `${root}/${entry.name}`;
    if (entry.isDirectory) yield* walk(path);
    else if (entry.isFile) yield path;
  }
}
function parseArgs(args_: string[]): Record<string, string> {
  const parsed: Record<string, string> = {};
  for (let index = 0; index < args_.length; index += 2) {
    const key = args_[index];
    const value = args_[index + 1];
    if (!key?.startsWith("--") || !value || value.startsWith("--")) {
      throw new Error("invalid arguments");
    }
    parsed[key.slice(2).replace(/-([a-z])/g, (_, letter: string) => letter.toUpperCase())] = value;
  }
  return parsed;
}
function isTarget(value: string): value is Target {
  return [
    "x86-windows-gnu",
    "x86_64-windows-gnu",
    "x86-windows-msvc",
    "x86_64-windows-msvc",
    "aarch64-windows-msvc",
    "macos",
  ].includes(value);
}
