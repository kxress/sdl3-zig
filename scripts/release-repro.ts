import { copy } from "@std/fs/copy";
import { packageRelease } from "./package-release.ts";
import { runCommand } from "./utils/command.ts";
import { repositoryRoot } from "./utils/paths.ts";

const fixtures = {
  none: "tests/build/fixtures/distribution_sdl",
  system: "tests/build/fixtures/system_sdl",
  prebuilt: "tests/build/fixtures/distribution_sdl",
  source: "tests/build/fixtures/source_all",
} as const;

if (import.meta.main) await verifyReleaseReproducibility();

export async function verifyReleaseReproducibility(): Promise<void> {
  const workspace = await Deno.makeTempDir({
    dir: `${repositoryRoot}/.zig-cache`,
    prefix: "release-repro-",
  });
  try {
    const release = await packageRelease(`${workspace}/release`);
    await verifyCleanFetch(release.archive, release.zigHash, workspace);
    await verifyDistributionConsumers(release.archive, release.zigHash, workspace);
    console.log("Release archive-consumer checks passed.");
  } finally {
    await Deno.remove(workspace, { recursive: true });
  }
}

async function verifyCleanFetch(archive: string, hash: string, workspace: string): Promise<void> {
  const consumer = `${workspace}/clean-consumer`;
  await Deno.mkdir(consumer, { recursive: true });
  await Deno.writeTextFile(
    `${consumer}/build.zig.zon`,
    consumerManifest("archive_consumer", ["build.zig", "build.zig.zon"], [[archive, hash]]),
  );
  await Deno.writeTextFile(
    `${consumer}/build.zig`,
    'const std = @import("std");\n\npub fn build(b: *std.Build) void { _ = b.dependency("sdl3", .{}); }\n',
  );
  await runCommand("zig", [
    "fetch",
    "--global-cache-dir",
    `${workspace}/clean-global`,
    archive,
  ], { cwd: consumer });
  await runCommand("zig", [
    "build",
    "--cache-dir",
    `${workspace}/clean-local`,
    "--global-cache-dir",
    `${workspace}/clean-global`,
  ], { cwd: consumer });
}

async function verifyDistributionConsumers(
  archive: string,
  hash: string,
  workspace: string,
): Promise<void> {
  await buildFixture("none", archive, hash, workspace, [
    "-Dtarget=x86_64-linux-gnu",
    "-Ddistribution=none",
    "-Dimage=true",
  ]);
  await buildFixture("system", archive, hash, workspace, [
    "-Dtarget=x86_64-linux-gnu",
    "-Dlink_image=true",
    "-Dallow_unknown_system_versions=true",
  ]);
  await buildPrebuiltProbe(archive, hash, workspace);
  await buildFixture("source", archive, hash, workspace, [
    "-Dtarget=x86_64-linux-gnu",
    "-Dlinkage=shared",
  ]);
}

async function buildFixture(
  name: keyof typeof fixtures,
  archive: string,
  hash: string,
  workspace: string,
  options: string[],
): Promise<void> {
  const consumer = `${workspace}/${name}-consumer`;
  await copy(`${repositoryRoot}/${fixtures[name]}`, consumer);
  const paths = name === "source"
    ? ["build.zig", "build.zig.zon", "main.zig", "zig-toolchain.cmake"]
    : name === "system"
    ? ["build.zig", "build.zig.zon", "image.zig", "all.zig", "library.zig"]
    : ["build.zig", "build.zig.zon", "image.zig", "all.zig"];
  await buildConsumer(name, consumer, paths, archive, hash, workspace, options);
}

async function buildPrebuiltProbe(
  archive: string,
  hash: string,
  workspace: string,
): Promise<void> {
  const consumer = `${workspace}/prebuilt-consumer`;
  await Deno.mkdir(consumer, { recursive: true });
  await Deno.writeTextFile(
    `${consumer}/build.zig`,
    [
      'const sdl3 = @import("sdl3");',
      "",
      "pub fn build(b: *std.Build) void {",
      "    const target = b.standardTargetOptions(.{});",
      "    const optimize = b.standardOptimizeOption(.{});",
      '    const library = b.addLibrary(.{ .name = "prebuilt-probe", .linkage = .static, .root_module = b.createModule(.{',
      '        .root_source_file = b.path("probe.zig"), .target = target, .optimize = optimize,',
      "    }) });",
      "    _ = sdl3.addTo(b, library, .{ .distribution = .prebuilt, .image = true });",
      "    b.installArtifact(library);",
      "}",
    ].join("\n").replace(
      'const sdl3 = @import("sdl3");',
      'const std = @import("std");\nconst sdl3 = @import("sdl3");',
    ),
  );
  await Deno.writeTextFile(
    `${consumer}/probe.zig`,
    'const sdl = @import("sdl");\ncomptime { _ = sdl; }\n',
  );
  await buildConsumer(
    "prebuilt",
    consumer,
    ["build.zig", "build.zig.zon", "probe.zig"],
    archive,
    hash,
    workspace,
    ["-Dtarget=x86_64-windows-gnu"],
  );
}

async function buildConsumer(
  name: string,
  consumer: string,
  paths: readonly string[],
  archive: string,
  hash: string,
  workspace: string,
  options: readonly string[],
): Promise<void> {
  let fingerprint = "0x0";
  for (let attempt = 0; attempt < 2; attempt++) {
    await Deno.writeTextFile(
      `${consumer}/build.zig.zon`,
      consumerManifest(`${name}_archive_consumer`, paths, [[archive, hash]], fingerprint),
    );
    try {
      await runCommand("zig", [
        "build",
        ...options,
        "--cache-dir",
        `${workspace}/${name}-local`,
        "--global-cache-dir",
        `${workspace}/${name}-global`,
      ], { cwd: consumer });
      return;
    } catch (error) {
      const suggestion = String(error).match(/use this value: (0x[0-9a-f]+)/)?.[1];
      if (!suggestion || suggestion === fingerprint) throw error;
      fingerprint = suggestion;
    }
  }
  throw new Error(`Unable to derive the ${name} consumer manifest fingerprint`);
}

function consumerManifest(
  name: string,
  paths: readonly string[],
  dependencies: readonly (readonly [string, string])[],
  fingerprint = "0x5d34f84b944a25ae",
): string {
  const dependencyText = dependencies.length === 0
    ? ".{}"
    : `.{\n        .sdl3 = .{ .url = ${JSON.stringify(fileUrl(dependencies[0][0]))}, .hash = ${
      JSON.stringify(dependencies[0][1])
    } },\n    }`;
  return [
    ".{",
    `    .name = .${name},`,
    '    .version = "0.0.0",',
    `    .fingerprint = ${fingerprint},`,
    '    .minimum_zig_version = "0.16.0",',
    `    .dependencies = ${dependencyText},`,
    `    .paths = .{ ${paths.map((path) => JSON.stringify(path)).join(", ")} },`,
    "}",
    "",
  ].join("\n");
}

function fileUrl(path: string): string {
  return path.startsWith("/") ? `file://${path}` : path;
}
