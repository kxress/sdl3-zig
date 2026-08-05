import { loadSdlRelease } from "../../scripts/sdl-release.ts";
import { stageReleaseTree } from "../../scripts/package-release.ts";
import { prebuiltTargetsFor, targetName } from "../../scripts/distribution-policy.ts";
import {
  buildDistributionConsumer,
  command,
  run,
  runScopedExecutable,
  stageDistributionConsumer,
  withTempDirectory,
} from "./support.ts";

const systemSdlFixture = `${import.meta.dirname}/fixtures/system_sdl`;
const distributionSdlFixture = `${import.meta.dirname}/fixtures/distribution_sdl`;
const companions = ["image", "ttf", "mixer", "net"];
const sourceAllFixture = `${import.meta.dirname}/fixtures/source_all`;
const sourceCrossFixture = `${import.meta.dirname}/fixtures/source_cross`;

Deno.test({
  name: "Linux builds the CMake source distribution for SDL and every companion",
  ignore: Deno.build.os !== "linux",
  async fn(test) {
    await withTempDirectory("sdl-linux-cmake-source-", async (temporary) => {
      for (const linkage of ["static", "shared"]) {
        await test.step(linkage, async () => {
          const cache = `${temporary}/${linkage}/local`;
          const sourceFeatureArgs = linkage === "static"
            ? [
              "-Dsource_feature_profile=headless",
              "-Dsource_audio=true",
              "-Dinstall_controller_image_data=true",
              "-Dcontroller_image_data_smoke=true",
            ]
            : [
              "-Dsource_feature_profile=desktop",
              "-Dsource_feature_smoke=true",
              "-Dinstall_controller_image_data=true",
              "-Dcontroller_image_data_smoke=true",
            ];
          await run("zig", [
            "build",
            `-Dtarget=${Deno.build.arch}-linux-gnu`,
            `-Dlinkage=${linkage}`,
            ...sourceFeatureArgs,
            "-Ddisable_image_bmp=true",
            "-Denable_mixer_mp3=true",
            "-p",
            `${temporary}/${linkage}/output`,
            "--cache-dir",
            cache,
            "--global-cache-dir",
            `${temporary}/${linkage}/global`,
          ], { cwd: sourceAllFixture });
          if (linkage === "shared") {
            for (
              const library of [
                "SDL3",
                "SDL3_shadercross",
                "SDL3_image",
                "SDL3_ttf",
                "SDL3_mixer",
                "SDL3_net",
              ]
            ) {
              await Deno.stat(`${temporary}/${linkage}/output/lib/lib${library}.so.0`);
            }
          }
          await Deno.stat(
            `${temporary}/${linkage}/output/share/ControllerImage/controllerimage-standard.bin`,
          );
          await Deno.stat(
            `${temporary}/${linkage}/output/share/ControllerImage/controllerimage-kenney.bin`,
          );
          await runScopedExecutable(`${temporary}/${linkage}/output/bin/cmake-source-all`, [], {
            cwd: `${temporary}/${linkage}/output/share/ControllerImage`,
            env: linkage === "shared"
              ? { SDL_VIDEODRIVER: "offscreen", SDL_RENDER_DRIVER: "software" }
              : undefined,
          });
          const imageCache = await Deno.readTextFile(
            `${cache}/sdl3-source-build/SDL3_image/CMakeCache.txt`,
          );
          const sdlCache = await Deno.readTextFile(
            `${cache}/sdl3-source-build/SDL3/CMakeCache.txt`,
          );
          const expectedCoreFeatures = linkage === "static"
            ? {
              SDL_AUDIO: "ON",
              SDL_VIDEO: "OFF",
              SDL_GPU: "OFF",
              SDL_RENDER: "OFF",
              SDL_CAMERA: "OFF",
            }
            : {
              SDL_AUDIO: "ON",
              SDL_VIDEO: "ON",
              SDL_GPU: "ON",
              SDL_RENDER: "ON",
              SDL_CAMERA: "ON",
            };
          for (const [feature, expected] of Object.entries(expectedCoreFeatures)) {
            if (!new RegExp(`^${feature}:[^=]+=${expected}$`, "m").test(sdlCache)) {
              throw new Error(
                `SDL source feature profile did not configure ${feature}=${expected}`,
              );
            }
          }
          if (!imageCache.includes("SDLIMAGE_BMP:BOOL=OFF")) {
            throw new Error(
              "SDL_image CMake options were not forwarded through the source distribution",
            );
          }
        });
      }
    });
  },
});

Deno.test({
  name: "Linux links system SDL with selected and all companions",
  ignore: Deno.build.os !== "linux",
  async fn(test) {
    await withTempDirectory("sdl-linux-build-", async (temporary) => {
      for (const linkage of ["static", "shared"]) {
        for (
          const [name, options] of [
            ["image only", ["-Dlink_image=true"]],
            ["all companions", companions.map((library) => `-Dlink_${library}=true`)],
          ] as const
        ) {
          await test.step(`${linkage} ${name}`, async () => {
            const cacheName = `${linkage}-${name.replaceAll(" ", "-")}`;
            await run("zig", [
              "build",
              `-Dtarget=${Deno.build.arch}-linux-gnu`,
              `-Dlinkage=${linkage}`,
              "-Dallow_unknown_system_versions=true",
              ...options,
              "--cache-dir",
              `${temporary}/cache/${cacheName}/local`,
              "--global-cache-dir",
              `${temporary}/cache/${cacheName}/global`,
            ], { cwd: systemSdlFixture });
          });
        }
      }
    });
  },
});

Deno.test({
  name: "Linux cross-compiles static source SDL and companions with toolchain paths",
  ignore: Deno.build.os !== "linux",
  async fn() {
    await withTempDirectory("sdl-linux-source-cross-", async (temporary) => {
      const includeDir = `${temporary}/include`;
      await Deno.mkdir(includeDir);
      await run("zig", [
        "build",
        "-Dtarget=aarch64-linux-gnu",
        "-Dsource_sysroot=/",
        `-Dsource_include_dir=${includeDir}`,
        "-p",
        `${temporary}/output`,
        "--cache-dir",
        `${temporary}/local`,
        "--global-cache-dir",
        `${temporary}/global`,
      ], { cwd: sourceCrossFixture });

      const executable = `${temporary}/output/bin/cmake-source-cross`;
      const elfHeader = await command("readelf", ["-h", executable]);
      const elfText = new TextDecoder().decode(elfHeader.stdout);
      if (!elfHeader.success || !/^\s*Machine:\s+AArch64$/m.test(elfText)) {
        throw new Error(`cross source consumer was not an AArch64 binary:\n${elfText}`);
      }
      for (const component of ["SDL3", "SDL3_image", "SDL3_ttf", "SDL3_mixer", "SDL3_net"]) {
        const cache = await Deno.readTextFile(
          `${temporary}/local/sdl3-source-build/${component}/CMakeCache.txt`,
        );
        for (
          const expected of [
            "CMAKE_C_COMPILER_TARGET:UNINITIALIZED=aarch64-linux",
            "CMAKE_CXX_COMPILER_TARGET:UNINITIALIZED=aarch64-linux",
            "CMAKE_SYSROOT:UNINITIALIZED=/",
            `-isystem${includeDir}`,
          ]
        ) {
          if (!cache.includes(expected)) {
            throw new Error(`${component} did not retain CMake input ${expected}`);
          }
        }
      }
    });
  },
});

Deno.test({
  name: "Linux rejects unsupported bundled or external DXC targets before CMake",
  ignore: Deno.build.os !== "linux",
  async fn() {
    await withTempDirectory("sdl-linux-dxc-target-", async (temporary) => {
      const result = await command("zig", [
        "build",
        "-Dtarget=aarch64-linux-gnu",
        "-Dlinkage=shared",
        "-Dshadercross_dxc=external",
        "-Dshadercross_dxc_root=/tmp",
        "-p",
        temporary + "/output",
        "--cache-dir",
        temporary + "/local",
        "--global-cache-dir",
        temporary + "/global",
      ], { cwd: sourceAllFixture });
      if (result.success || result.stderr.length === 0) {
        throw new Error("expected DXC target rejection with a diagnostic");
      }
    });
  },
});

Deno.test({
  name: "Linux supports a bindings-only consumer with one selected companion",
  ignore: Deno.build.os !== "linux",
  async fn() {
    await withTempDirectory("sdl-linux-bindings-only-", async (temporary) => {
      await run("zig", [
        "build",
        `-Dtarget=${Deno.build.arch}-linux-gnu`,
        "-Ddistribution=none",
        "-Dimage=true",
        "--cache-dir",
        `${temporary}/cache/local`,
        "--global-cache-dir",
        `${temporary}/cache/global`,
      ], { cwd: distributionSdlFixture });
    });
  },
});

Deno.test({
  name: "Linux system distribution enforces pkg-config API baselines",
  ignore: Deno.build.os !== "linux",
  async fn() {
    const release = await loadSdlRelease();
    const components = ["sdl", "image"].map((key) => {
      const component = release.components.find((candidate) => candidate.key === key);
      if (!component) throw new Error(`missing ${key} component metadata`);
      return component;
    });

    await withTempDirectory("sdl-linux-pkg-config-", async (temporary) => {
      const pkgConfig = `${temporary}/pkgconfig`;
      await Deno.mkdir(pkgConfig);
      const writeVersions = async (versions: Map<string, string>) => {
        for (const component of components) {
          await Deno.writeTextFile(
            `${pkgConfig}/${component.pkgConfigName}.pc`,
            [
              "prefix=/tmp",
              "exec_prefix=${prefix}",
              "libdir=${prefix}/lib",
              "includedir=${prefix}/include",
              `Name: ${component.id}`,
              `Description: ${component.id} test package`,
              `Version: ${versions.get(component.key) ?? component.version}`,
              "Libs:",
              "Cflags:",
              "",
            ].join("\n"),
          );
        }
      };
      const build = async (name: string, args: string[] = []) => {
        const result = await command("zig", [
          "build",
          "-Dtarget=x86_64-linux-gnu",
          "-Dlink_image=true",
          ...args,
          "--cache-dir",
          `${temporary}/${name}-local`,
          "--global-cache-dir",
          `${temporary}/${name}-global`,
        ], { cwd: systemSdlFixture, env: { PKG_CONFIG_PATH: pkgConfig } });
        return {
          success: result.success,
          output: `${new TextDecoder().decode(result.stdout)}\n${
            new TextDecoder().decode(result.stderr)
          }`,
        };
      };
      const current = new Map(components.map((component) => [component.key, component.version]));
      await writeVersions(current);
      const matching = await build("matching");
      if (!matching.success) throw new Error(matching.output);

      const newer = new Map(current);
      newer.set("sdl", "99.0.0");
      await writeVersions(newer);
      const newerResult = await build("newer");
      if (!newerResult.success) throw new Error(newerResult.output);

      const older = new Map(current);
      older.set("sdl", olderVersion(current.get("sdl")!));
      await writeVersions(older);
      const olderResult = await build("older");
      if (olderResult.success) {
        throw new Error(`expected too-old system SDL rejection, got:\n${olderResult.output}`);
      }

      await writeVersions(current);
      await Deno.remove(`${pkgConfig}/${components[1].pkgConfigName}.pc`);
      const missing = await build("missing");
      if (missing.success) {
        throw new Error(`expected missing system SDL metadata rejection, got:\n${missing.output}`);
      }
      const override = await build("override", ["-Dsystem_version_overrides=image=3.4.12"]);
      if (!override.success) throw new Error(override.output);
    });
  },
});

function olderVersion(version: string): string {
  const [major, minor, patch] = version.split(".").map(Number);
  if (patch > 0) return `${major}.${minor}.${patch - 1}`;
  if (minor > 0) return `${major}.${minor - 1}.99`;
  return `${major - 1}.99.99`;
}

Deno.test({
  name: "Linux reports unsupported prebuilt linkage and targets before linking",
  ignore: Deno.build.os !== "linux",
  async fn(test) {
    await withTempDirectory("sdl-linux-distribution-errors-", async (temporary) => {
      const packageRoot = await stageReleaseTree(`${temporary}/package`);
      const consumer = await stageDistributionConsumer(temporary, packageRoot);
      for (
        const [target, option] of [
          [
            "x86_64-windows-gnu",
            "-Dlinkage=static",
          ],
          [
            "aarch64-windows-gnu",
            "-Dlinkage=shared",
          ],
          [
            "aarch64-windows-msvc",
            "-Doptional_codecs=true",
          ],
        ] as const
      ) {
        await test.step(`${target} ${option}`, async () => {
          const result = await command("zig", [
            "build",
            `-Dtarget=${target}`,
            "-Ddistribution=prebuilt",
            "-Dimage=true",
            option,
            "--cache-dir",
            `${temporary}/${target}/local`,
            "--global-cache-dir",
            `${temporary}/${target}/global`,
          ], { cwd: consumer });
          if (result.success) throw new Error(`expected ${target} prebuilt selection to fail`);
          if (result.stderr.length === 0) throw new Error(`missing ${target} diagnostic`);
        });
      }
    });
  },
});

Deno.test({
  name: "Linux cross-compiles Windows MinGW prebuilt distributions",
  ignore: Deno.build.os !== "linux",
  async fn(test) {
    await withTempDirectory("sdl-linux-windows-cross-", async (temporary) => {
      const packageRoot = await stageReleaseTree(`${temporary}/package`);
      const consumer = await stageDistributionConsumer(temporary, packageRoot);

      for (const target of prebuiltTargetsFor("mingw").map(targetName)) {
        await test.step(`${target} prebuilts link and install`, async () => {
          await buildDistributionConsumer(consumer, temporary, target, `${temporary}/${target}`, [
            "-Ddistribution=prebuilt",
            ...companions.map((library) => `-D${library}=true`),
            "-Doptional_codecs=true",
          ]);
        });
      }
    });
  },
});
