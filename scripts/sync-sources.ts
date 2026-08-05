import { copy } from "@std/fs/copy";
import { join } from "@std/path";
import { runCommand } from "./utils/command.ts";
import { repositoryRoot } from "./utils/paths.ts";

const root = repositoryRoot;
const vendorManifest = join(root, "vendor", ".sdl-source-manifest");
const action = Deno.args[0];
const sources = [
  ["SDL3", "http:sdl-source"],
  ["SDL3_image", "http:sdl-image-source"],
  ["SDL3_ttf", "http:sdl-ttf-source"],
  ["SDL3_mixer", "http:sdl-mixer-source"],
  ["SDL3_net", "http:sdl-net-source"],
] as const;
const freetypeArtifact = "http:freetype-source";
const controllerImageComponent = "ControllerImage";
const controllerImageArtifact = "http:controller-image-source";
const shadercrossComponent = "SDL3_shadercross";
const shadercrossArtifact = "http:sdl-shadercross-source";
const shadercrossDependencies = [
  ["SPIRV-Cross", "http:spirv-cross-source"],
  ["SPIRV-Headers", "http:spirv-headers-source"],
  ["SPIRV-Tools", "http:spirv-tools-source"],
  ["DirectXShaderCompiler", "http:dxc-source"],
] as const;
const dxcDependencies = [
  ["DirectX-Headers", "http:dxc-directx-headers-source"],
  ["SPIRV-Headers", "http:dxc-spirv-headers-source"],
  ["SPIRV-Tools", "http:dxc-spirv-tools-source"],
] as const;
if (Deno.args.length !== 1 || (action !== "update" && action !== "check")) {
  throw new Error("usage: sync-sources.ts update|check");
}

if (action === "update") {
  await Deno.mkdir(join(root, "vendor"), { recursive: true });
}

if (await vendoredSourcesMatchManifest()) {
  console.log(`Using existing verified source cache at ${join(root, "vendor")}.`);
  Deno.exit(0);
}

await mise("install", ...sources.map(([, artifact]) => artifact));
await mise("install", freetypeArtifact);

for (const [component, artifact] of sources) {
  const source = await Deno.realPath((await mise("where", artifact)).trim());
  const header = join(source, "include", component, `${component.replace("SDL3", "SDL")}.h`);
  if (!(await isFile(header))) {
    throw new Error(`${artifact} is missing its expected header`);
  }

  const destination = join(root, "vendor", component);
  if (action === "check") {
    await runCommand("diff", [
      "--no-dereference",
      "--recursive",
      "--brief",
      "--exclude=freetype",
      "--exclude=metadata.json",
      source,
      destination,
    ], { cwd: root });
    if (component === "SDL3_ttf") {
      const freetype = await Deno.realPath((await mise("where", freetypeArtifact)).trim());
      await runCommand("diff", [
        "--no-dereference",
        "--recursive",
        "--brief",
        "--exclude=metadata.json",
        freetype,
        join(destination, "external/freetype"),
      ], { cwd: root });
    }
    console.log(`Verified ${component} against ${artifact}.`);
    continue;
  }

  const stage = await Deno.makeTempDir({
    dir: join(root, "vendor"),
    prefix: `.${component}.refresh.`,
  });
  const backup = `${stage}.previous`;
  await Deno.remove(stage, { recursive: true });
  await copyUpstreamTree(source, stage);
  if (component === "SDL3_ttf") {
    const freetype = await Deno.realPath((await mise("where", freetypeArtifact)).trim());
    await copyUpstreamTree(freetype, join(stage, "external/freetype"));
  }
  if (await exists(destination)) await Deno.rename(destination, backup);
  try {
    await Deno.rename(stage, destination);
  } catch (error) {
    if (await exists(backup)) await Deno.rename(backup, destination);
    throw error;
  }
  if (await exists(backup)) await Deno.remove(backup, { recursive: true });
  console.log(`Refreshed ${component} from ${artifact}.`);
}

await mise("install", controllerImageArtifact);
const controllerImageSource = await Deno.realPath(
  (await mise("where", controllerImageArtifact)).trim(),
);
const controllerImageHeader = join(controllerImageSource, "src", "controllerimage.h");
if (
  !(await isFile(controllerImageHeader)) || !(await isDirectory(join(controllerImageSource, "art")))
) {
  throw new Error(`${controllerImageArtifact} is missing its header or artwork`);
}
const controllerImageDestination = join(root, "vendor", controllerImageComponent);
if (action === "check") {
  await runCommand("diff", [
    "--no-dereference",
    "--recursive",
    "--brief",
    "--exclude=metadata.json",
    controllerImageSource,
    controllerImageDestination,
  ], { cwd: root });
  console.log(`Verified ${controllerImageComponent} against ${controllerImageArtifact}.`);
} else {
  const stage = await Deno.makeTempDir({
    dir: join(root, "vendor"),
    prefix: `.${controllerImageComponent}.refresh.`,
  });
  const backup = `${stage}.previous`;
  await Deno.remove(stage, { recursive: true });
  await copyUpstreamTree(controllerImageSource, stage);
  if (await exists(controllerImageDestination)) {
    await Deno.rename(controllerImageDestination, backup);
  }
  try {
    await Deno.rename(stage, controllerImageDestination);
  } catch (error) {
    if (await exists(backup)) await Deno.rename(backup, controllerImageDestination);
    throw error;
  }
  if (await exists(backup)) await Deno.remove(backup, { recursive: true });
  console.log(`Refreshed ${controllerImageComponent} from ${controllerImageArtifact}.`);
}

await mise(
  "install",
  shadercrossArtifact,
  ...shadercrossDependencies.map(([, artifact]) => artifact),
  ...dxcDependencies.map(([, artifact]) => artifact),
);
const shadercrossSource = await Deno.realPath((await mise("where", shadercrossArtifact)).trim());
const shadercrossHeader = join(
  shadercrossSource,
  "include",
  "SDL3_shadercross",
  "SDL_shadercross.h",
);
if (!(await isFile(shadercrossHeader))) {
  throw new Error(`${shadercrossArtifact} is missing its public header`);
}
const shadercrossDestination = join(root, "vendor", shadercrossComponent);
if (action === "check") {
  await runCommand("diff", [
    "--no-dereference",
    "--recursive",
    "--brief",
    "--exclude=external",
    "--exclude=metadata.json",
    shadercrossSource,
    shadercrossDestination,
  ], { cwd: root });
  for (const [directory, artifact] of shadercrossDependencies) {
    const dependencySource = await Deno.realPath((await mise("where", artifact)).trim());
    const arguments_ = [
      "--no-dereference",
      "--recursive",
      "--brief",
    ];
    arguments_.push("--exclude=metadata.json");
    if (directory === "DirectXShaderCompiler") arguments_.push("--exclude=external");
    arguments_.push(
      dependencySource,
      join(shadercrossDestination, "external", directory),
    );
    await runCommand("diff", arguments_, { cwd: root });
  }
  for (const [directory, artifact] of dxcDependencies) {
    const dependencySource = await Deno.realPath((await mise("where", artifact)).trim());
    await runCommand("diff", [
      "--no-dereference",
      "--recursive",
      "--brief",
      "--exclude=metadata.json",
      dependencySource,
      join(
        shadercrossDestination,
        "external",
        "DirectXShaderCompiler",
        "external",
        directory,
      ),
    ], { cwd: root });
  }
  console.log(`Verified ${shadercrossComponent} and its source dependencies.`);
} else {
  const stage = await Deno.makeTempDir({
    dir: join(root, "vendor"),
    prefix: `.${shadercrossComponent}.refresh.`,
  });
  const backup = `${stage}.previous`;
  await Deno.remove(stage, { recursive: true });
  await copyUpstreamTree(shadercrossSource, stage);
  for (const [directory, artifact] of shadercrossDependencies) {
    const dependencySource = await Deno.realPath((await mise("where", artifact)).trim());
    const dependencyDestination = join(stage, "external", directory);
    if (await exists(dependencyDestination)) {
      await Deno.remove(dependencyDestination, { recursive: true });
    }
    await copyUpstreamTree(dependencySource, dependencyDestination);
  }
  for (const [directory, artifact] of dxcDependencies) {
    const dependencySource = await Deno.realPath((await mise("where", artifact)).trim());
    const dependencyDestination = join(
      stage,
      "external",
      "DirectXShaderCompiler",
      "external",
      directory,
    );
    if (await exists(dependencyDestination)) {
      await Deno.remove(dependencyDestination, { recursive: true });
    }
    await copyUpstreamTree(dependencySource, dependencyDestination);
  }
  if (await exists(shadercrossDestination)) await Deno.rename(shadercrossDestination, backup);
  try {
    await Deno.rename(stage, shadercrossDestination);
  } catch (error) {
    if (await exists(backup)) await Deno.rename(backup, shadercrossDestination);
    throw error;
  }
  if (await exists(backup)) await Deno.remove(backup, { recursive: true });
  console.log(`Refreshed ${shadercrossComponent} and its source dependencies.`);
}

if (action === "update") {
  await Deno.writeTextFile(vendorManifest, `${await sourceManifestFingerprint()}\n`);
}

async function mise(...args: string[]): Promise<string> {
  return (await runCommand("mise", ["--quiet", "-E", "sdl", ...args], { cwd: root })).stdout;
}

async function exists(path: string): Promise<boolean> {
  try {
    await Deno.lstat(path);
    return true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

async function vendoredSourcesMatchManifest(): Promise<boolean> {
  const requiredPaths = [
    join(root, "vendor", "SDL3", "include", "SDL3", "SDL.h"),
    join(root, "vendor", "SDL3_image", "include", "SDL3_image", "SDL_image.h"),
    join(root, "vendor", "SDL3_ttf", "include", "SDL3_ttf", "SDL_ttf.h"),
    join(root, "vendor", "SDL3_mixer", "include", "SDL3_mixer", "SDL_mixer.h"),
    join(root, "vendor", "SDL3_net", "include", "SDL3_net", "SDL_net.h"),
    join(root, "vendor", "ControllerImage", "src", "controllerimage.h"),
    join(root, "vendor", "SDL3_shadercross", "include", "SDL3_shadercross", "SDL_shadercross.h"),
  ];
  if (!(await Promise.all(requiredPaths.map(isFile))).every(Boolean)) return false;
  try {
    const actual = (await Deno.readTextFile(vendorManifest)).trim();
    return actual === await sourceManifestFingerprint();
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

async function sourceManifestFingerprint(): Promise<string> {
  const manifest = await Deno.readTextFile(join(root, "mise.sdl.toml"));
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(manifest));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

async function isFile(path: string): Promise<boolean> {
  try {
    return (await Deno.lstat(path)).isFile;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

async function isDirectory(path: string): Promise<boolean> {
  try {
    return (await Deno.lstat(path)).isDirectory;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}

async function copyUpstreamTree(source: string, destination: string): Promise<void> {
  await copy(source, destination);
  await Deno.remove(join(destination, "metadata.json")).catch((error: unknown) => {
    if (!(error instanceof Deno.errors.NotFound)) throw error;
  });
}
