import { copy } from "@std/fs/copy";
import { dirname, resolve } from "@std/path";
import { runCommand } from "./utils/command.ts";
import { repositoryRoot } from "./utils/paths.ts";
import {
  artifactName,
  binaryArtifactNames,
  installArtifacts,
  loadSdlRelease,
  packagePaths,
  releaseVersion,
  type SdlComponent,
  type SdlRelease,
  windowsOptionalArchitectures,
} from "./sdl-release.ts";

const localBuildRoots = new Set([
  ".zig-cache",
  "zig-out",
  "sdl3-source",
  "sdl3-source-build",
]);

export async function stageReleaseTree(
  destination: string,
): Promise<string> {
  const release = await loadSdlRelease();
  await ensureVendoredSources();
  const packageRoot = `${destination}/sdl3-${releaseVersion(release)}`;
  await Deno.mkdir(packageRoot, { recursive: true });
  await copyPackageSources(release, packageRoot);
  await stagePrebuilts(release, packageRoot, destination);
  await validateReleaseTree(packageRoot);
  return packageRoot;
}

async function ensureVendoredSources(): Promise<void> {
  await runCommand("deno", [
    "run",
    "--allow-read",
    "--allow-write",
    "--allow-run=mise",
    "scripts/sync-sources.ts",
    "update",
  ], { cwd: repositoryRoot });
}

export async function packageRelease(
  outputRoot = `${repositoryRoot}/zig-out/release`,
) {
  if (Deno.build.os === "windows") {
    throw new Error("package:release requires GNU tar under Linux, macOS, or WSL");
  }
  outputRoot = resolve(repositoryRoot, outputRoot);
  await Deno.mkdir(`${repositoryRoot}/.zig-cache`, { recursive: true });
  await Deno.mkdir(outputRoot, { recursive: true });
  const temporary = await Deno.makeTempDir({
    dir: `${repositoryRoot}/.zig-cache`,
    prefix: "release-package-",
  });
  try {
    const packageRoot = await stageReleaseTree(temporary);
    const packageName = packageRoot.slice(packageRoot.lastIndexOf("/") + 1);

    const archive = `${outputRoot}/${packageName}.tar.gz`;
    await runCommand(
      "tar",
      [
        "--sort=name",
        "--mtime=@0",
        "--owner=0",
        "--group=0",
        "--numeric-owner",
        "--format=pax",
        "--pax-option=delete=atime,delete=ctime",
        "-czf",
        archive,
        "-C",
        temporary,
        packageName,
      ],
      { cwd: repositoryRoot },
    );
    const sha256 = (await runCommand("sha256sum", [archive], { cwd: repositoryRoot })).stdout
      .split(/\s+/, 1)[0];
    if (!/^[0-9a-f]{64}$/.test(sha256)) {
      throw new Error(`sha256sum returned an invalid digest: ${sha256}`);
    }
    await Deno.writeTextFile(
      `${archive}.sha256`,
      `${sha256}  ${archive.slice(archive.lastIndexOf("/") + 1)}\n`,
    );
    const zigHash = (
      await runCommand("zig", [
        "fetch",
        "--global-cache-dir",
        `${temporary}/zig-global-cache`,
        archive,
      ], { cwd: repositoryRoot })
    ).stdout.trim();
    if (!/^[A-Za-z0-9_.+-]+$/.test(zigHash)) {
      throw new Error(`zig fetch returned an invalid package hash: ${zigHash}`);
    }
    await Deno.writeTextFile(`${archive}.zig-hash`, `${zigHash}\n`);
    console.log(`Packaged ${archive}`);
    console.log(`SHA-256 ${sha256}`);
    console.log(`Zig hash ${zigHash}`);
    return { archive, sha256, zigHash };
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
}

async function copyPackageSources(release: SdlRelease, destination: string): Promise<void> {
  for (const path of packagePaths(release)) {
    if (path === "prebuilt") continue;
    await copyTo(`${repositoryRoot}/${path}`, `${destination}/${path}`);
  }
}

async function stagePrebuilts(
  release: SdlRelease,
  packageRoot: string,
  temporary: string,
): Promise<void> {
  const prebuiltComponents = release.components.filter((component) => component.prebuilt);
  const names = prebuiltComponents.flatMap(binaryArtifactNames);
  const installations = await installArtifacts(names);
  for (const component of prebuiltComponents) {
    const upstreamDirectory = `${component.id}-${component.version}`;
    const mingw = `${
      requireInstallation(installations, artifactName(component, "mingw"))
    }/${upstreamDirectory}`;
    const msvc = `${
      requireInstallation(installations, artifactName(component, "msvc"))
    }/${upstreamDirectory}`;
    const macos = `${temporary}/upstream/${component.key}/macos`;
    await Deno.mkdir(macos, { recursive: true });
    await runCommand("7zz", [
      "x",
      "-y",
      `-o${macos}`,
      `${
        requireInstallation(installations, artifactName(component, "macos"))
      }/${upstreamDirectory}.dmg`,
    ], { cwd: repositoryRoot });
    await stageMinGW(component, mingw, packageRoot, installations);
    await stageMSVC(component, msvc, packageRoot);
    await stageMacOS(component, macos, packageRoot);
    console.log(`Staged ${component.id} ${component.version} prebuilts.`);
  }
}

async function stageMinGW(
  component: SdlComponent,
  extracted: string,
  packageRoot: string,
  installations: Map<string, string>,
): Promise<void> {
  for (
    const [arch, prefix] of [
      ["x86", "i686-w64-mingw32"],
      ["x86_64", "x86_64-w64-mingw32"],
    ] as const
  ) {
    const destination = `${packageRoot}/prebuilt/${component.key}/windows-gnu/${arch}`;
    await copyTo(
      `${extracted}/${prefix}/lib/lib${component.id}.dll.a`,
      `${destination}/lib/lib${component.id}.dll.a`,
    );
    await copyTo(
      `${extracted}/${prefix}/bin/${component.id}.dll`,
      `${destination}/bin/${component.id}.dll`,
    );

    const optional = component.windowsOptionalRuntime;
    if (!optional || !windowsOptionalArchitectures.mingw.includes(arch)) continue;
    const optionalRoot = requireInstallation(
      installations,
      artifactName(component, `mingw-${arch}-runtime`),
    );
    await stageOptionalWindows(
      `${optionalRoot}/optional`,
      optional,
      `${destination}/optional`,
    );
  }
}

async function stageMSVC(
  component: SdlComponent,
  extracted: string,
  packageRoot: string,
): Promise<void> {
  for (
    const [arch, upstreamArch] of [
      ["x86", "x86"],
      ["x86_64", "x64"],
      ["aarch64", "arm64"],
    ] as const
  ) {
    const destination = `${packageRoot}/prebuilt/${component.key}/windows-msvc/${arch}`;
    await copyTo(
      `${extracted}/lib/${upstreamArch}/${component.id}.lib`,
      `${destination}/lib/${component.id}.lib`,
    );
    await copyTo(
      `${extracted}/lib/${upstreamArch}/${component.id}.dll`,
      `${destination}/bin/${component.id}.dll`,
    );
    const optional = component.windowsOptionalRuntime;
    if (optional && windowsOptionalArchitectures.msvc.includes(arch)) {
      await stageOptionalWindows(
        `${extracted}/lib/${upstreamArch}/optional`,
        optional,
        `${destination}/optional`,
      );
    }
  }
}

async function stageOptionalWindows(
  source: string,
  optional: NonNullable<SdlComponent["windowsOptionalRuntime"]>,
  destination: string,
): Promise<void> {
  for (const name of [...optional.dlls, ...optional.licenses]) {
    await copyTo(`${source}/${name}`, `${destination}/${name}`);
  }
}

async function stageMacOS(
  component: SdlComponent,
  extracted: string,
  packageRoot: string,
): Promise<void> {
  const destination = `${packageRoot}/prebuilt/${component.key}/macos`;
  const source = `${extracted}/${component.id}`;
  const framework =
    `${source}/${component.id}.xcframework/macos-arm64_x86_64/${component.id}.framework`;
  await copyTo(
    framework,
    `${destination}/frameworks/${component.id}.framework`,
  );
  for (const name of component.macosOptionalFrameworks ?? []) {
    const optional = `${source}/optional/${name}.xcframework/macos-arm64_x86_64/${name}.framework`;
    await copyTo(optional, `${destination}/optional/${name}.framework`);
  }
}

function requireInstallation(installations: Map<string, string>, artifact: string): string {
  const installation = installations.get(artifact);
  if (!installation) throw new Error(`Missing installed SDL artifact: ${artifact}`);
  return installation;
}

async function copyTo(source: string, destination: string): Promise<void> {
  await Deno.mkdir(dirname(destination), { recursive: true });
  try {
    await copy(source, destination);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      throw new Error(`Required release input does not exist: ${source}`, { cause: error });
    }
    throw error;
  }
}

export async function validateReleaseTree(root: string, relative = ""): Promise<void> {
  const directory = relative ? `${root}/${relative}` : root;
  for await (const entry of Deno.readDir(directory)) {
    const child = relative ? `${relative}/${entry.name}` : entry.name;
    if (!relative && localBuildRoots.has(entry.name)) {
      throw new Error(`Release tree contains a local build root: ${entry.name}`);
    }
    if (entry.isDirectory) {
      await validateReleaseTree(root, child);
    } else if (entry.isSymlink) {
      const target = await Deno.readLink(`${root}/${child}`);
      if (target.startsWith("/") || target.split("/").includes("..")) {
        throw new Error(`Unsafe release symlink ${child} -> ${target}`);
      }
    }
  }
}

if (import.meta.main) {
  const args = Deno.args[0] === "--" ? Deno.args.slice(1) : Deno.args;
  if (
    args.length !== 0 &&
    (args.length !== 2 || args[0] !== "--output" || args[1].startsWith("-"))
  ) {
    throw new Error("usage: package-release.ts [--output <directory>]");
  }
  await packageRelease(args[1]);
}
