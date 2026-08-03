import { stageReleaseTree } from "../../scripts/package-release.ts";
import {
  buildDistributionConsumer,
  command,
  run,
  stageDistributionConsumer,
  withTempDirectory,
} from "./support.ts";

const systemSdlFixture = `${import.meta.dirname}/fixtures/system_sdl`;
const distributionSdlFixture = `${import.meta.dirname}/fixtures/distribution_sdl`;
const companions = ["image", "ttf", "mixer", "net"];
const sourceAllFixture = `${import.meta.dirname}/fixtures/source_all`;

Deno.test({
  name: "Linux builds the CMake source distribution for SDL and every companion",
  ignore: Deno.build.os !== "linux",
  async fn(test) {
    await withTempDirectory("sdl-linux-cmake-source-", async (temporary) => {
      for (const linkage of ["static", "shared"]) {
        await test.step(linkage, async () => {
          const cache = `${temporary}/${linkage}/local`;
          await run("zig", [
            "build",
            `-Dtarget=${Deno.build.arch}-linux-gnu`,
            `-Dlinkage=${linkage}`,
            "-Ddisable_image_bmp=true",
            "-p",
            `${temporary}/${linkage}/output`,
            "--cache-dir",
            cache,
            "--global-cache-dir",
            `${temporary}/${linkage}/global`,
          ], { cwd: sourceAllFixture });
          const suffix = linkage === "static" ? ".a" : ".so";
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
            await Deno.stat(`${cache}/sdl3-source/lib/lib${library}${suffix}`);
          }
          await Deno.stat(`${cache}/sdl3-source/lib/libSDL3_test.a`);
          await Deno.stat(`${cache}/sdl3-source/bin/shadercross`);
          await Deno.stat(`${cache}/sdl3-source-build/ControllerImage/libcontrollerimage.a`);
          const controllerImageData = `${temporary}/${linkage}/controllerimage-standard.bin`;
          await run(
            `${cache}/sdl3-source-build/ControllerImage/make-controllerimage-data`,
            ["${Deno.cwd()}/vendor/ControllerImage/art"],
            { cwd: `${temporary}/${linkage}` },
          );
          await Deno.stat(controllerImageData);
          const runtimePath = `${cache}/sdl3-source/lib`;
          await run(`${temporary}/${linkage}/output/bin/cmake-source-all`, [], {
            cwd: `${temporary}/${linkage}`,
            env: {
              LD_LIBRARY_PATH: runtimePath,
            },
          });
          const imageCache = await Deno.readTextFile(
            `${cache}/sdl3-source-build/SDL3_image/CMakeCache.txt`,
          );
          if (!imageCache.includes("SDLIMAGE_BMP:BOOL=OFF")) {
            throw new Error(
              "SDL_image CMake options were not forwarded through the source distribution",
            );
          }
          if (!imageCache.includes("SDLIMAGE_GIF:BOOL=ON")) {
            throw new Error("SDL_image did not retain its self-contained GIF decoder");
          }
          const mixerCache = await Deno.readTextFile(
            `${cache}/sdl3-source-build/SDL3_mixer/CMakeCache.txt`,
          );
          for (
            const setting of [
              "SDLMIXER_WAVE:BOOL=ON",
              "SDLMIXER_AIFF:BOOL=ON",
              "SDLMIXER_MP3:BOOL=OFF",
              "SDLMIXER_FLAC:BOOL=OFF",
            ]
          ) {
            if (!mixerCache.includes(setting)) {
              throw new Error(`SDL_mixer CMake profile did not configure ${setting}`);
            }
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
  name: "Linux reports unsupported prebuilt linkage and targets before linking",
  ignore: Deno.build.os !== "linux",
  async fn(test) {
    await withTempDirectory("sdl-linux-distribution-errors-", async (temporary) => {
      const packageRoot = await stageReleaseTree(`${temporary}/package`);
      const consumer = await stageDistributionConsumer(temporary, packageRoot);
      for (
        const [target, option, expected] of [
          [
            "x86_64-windows-gnu",
            "-Dlinkage=static",
            "package-local SDL prebuilts provide shared libraries only",
          ],
          [
            "aarch64-windows-gnu",
            "-Dlinkage=shared",
            "official SDL prebuilts do not support aarch64-windows-gnu",
          ],
          [
            "aarch64-windows-msvc",
            "-Doptional_codecs=true",
            "optional codecs for SDL3_image do not support aarch64-windows-msvc",
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
          const output = new TextDecoder().decode(result.stderr);
          if (!output.includes(expected)) {
            throw new Error(`expected diagnostic ${JSON.stringify(expected)}, got:\n${output}`);
          }
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

      for (const target of ["x86-windows-gnu", "x86_64-windows-gnu"]) {
        await test.step(`${target} prebuilts link and install`, async () => {
          await buildDistributionConsumer(consumer, temporary, target, `${temporary}/${target}`, [
            ...companions.map((library) => `-D${library}=true`),
            "-Doptional_codecs=true",
          ]);
        });
      }
    });
  },
});
