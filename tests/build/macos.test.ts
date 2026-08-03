import { stageReleaseTree } from "../../scripts/package-release.ts";
import {
  buildDistributionConsumer,
  run,
  stageDistributionConsumer,
  withTempDirectory,
} from "./support.ts";

const companions = ["image", "ttf", "mixer", "net"];
const sourceAllFixture = `${import.meta.dirname}/fixtures/source_all`;

Deno.test({
  name: "macOS builds and runs the CMake source distribution for SDL and every companion",
  ignore: Deno.build.os !== "darwin",
  async fn(test) {
    await withTempDirectory("sdl-macos-cmake-source-", async (temporary) => {
      for (const linkage of ["static", "shared"]) {
        await test.step(linkage, async () => {
          const cache = `${temporary}/${linkage}/local`;
          await run("zig", [
            "build",
            `-Dtarget=${Deno.build.arch}-macos`,
            `-Dlinkage=${linkage}`,
            "-p",
            `${temporary}/${linkage}/output`,
            "--cache-dir",
            cache,
            "--global-cache-dir",
            `${temporary}/${linkage}/global`,
          ], { cwd: sourceAllFixture });
          const suffix = linkage === "static" ? ".a" : ".dylib";
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
          await run(
            `${cache}/sdl3-source-build/ControllerImage/make-controllerimage-data`,
            ["${Deno.cwd()}/vendor/ControllerImage/art"],
            { cwd: `${temporary}/${linkage}` },
          );
          await run(`${temporary}/${linkage}/output/bin/cmake-source-all`, [], {
            cwd: `${temporary}/${linkage}`,
            env: { DYLD_LIBRARY_PATH: `${cache}/sdl3-source/lib` },
          });
        });
      }
    });
  },
});

Deno.test({
  name: "macOS prebuilt distributions link and install for every supported architecture",
  ignore: Deno.build.os !== "darwin",
  async fn(test) {
    await withTempDirectory("sdl-macos-distribution-", async (temporary) => {
      const packageRoot = await stageReleaseTree(`${temporary}/package`);
      const consumer = await stageDistributionConsumer(temporary, packageRoot);

      for (const target of ["x86_64-macos", "aarch64-macos"]) {
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
