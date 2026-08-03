import { stageReleaseTree } from "../../scripts/package-release.ts";
import {
  buildDistributionConsumer,
  run,
  runWindowsExecutable,
  stageDistributionConsumer,
  withTempDirectory,
} from "./support.ts";

const companions = ["image", "ttf", "mixer", "net"];
const sourceAllFixture = `${import.meta.dirname}/fixtures/source_all`;

Deno.test({
  name: "Windows MSVC builds and runs the CMake source distribution for SDL and every companion",
  ignore: Deno.build.os !== "windows",
  async fn(test) {
    await withTempDirectory("sdl-windows-cmake-source-", async (temporary) => {
      for (const linkage of ["static", "shared"]) {
        await test.step(linkage, async () => {
          const cache = `${temporary}/${linkage}/local`;
          await run("zig", [
            "build",
            `-Dtarget=${Deno.build.arch}-windows-msvc`,
            `-Dlinkage=${linkage}`,
            "-p",
            `${temporary}/${linkage}/output`,
            "--cache-dir",
            cache,
            "--global-cache-dir",
            `${temporary}/${linkage}/global`,
          ], { cwd: sourceAllFixture });
          const suffix = linkage === "static" ? "-static.lib" : ".dll";
          const directory = linkage === "static" ? "lib" : "bin";
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
            await Deno.stat(`${cache}/sdl3-source/${directory}/${library}${suffix}`);
          }
          await Deno.stat(`${cache}/sdl3-source/lib/SDL3_test.lib`);
          await Deno.stat(`${cache}/sdl3-source/bin/shadercross.exe`);
          await Deno.stat(`${cache}/sdl3-source-build/ControllerImage/controllerimage.lib`);
          await run(
            `${cache}/sdl3-source-build/ControllerImage/make-controllerimage-data.exe`,
            ["${Deno.cwd()}\\vendor\\ControllerImage\\art"],
            { cwd: `${temporary}/${linkage}` },
          );
          await runWindowsExecutable(
            `${temporary}/${linkage}/output/bin/cmake-source-all.exe`,
            `${temporary}/${linkage}`,
            {
              PATH: `${cache}/sdl3-source/bin`,
            },
          );
        });
      }
    });
  },
});

Deno.test({
  name: "Windows MinGW prebuilt distributions link and install",
  ignore: Deno.build.os !== "windows",
  async fn(test) {
    await buildWindowsDistribution(test, "gnu", ["x86-windows-gnu", "x86_64-windows-gnu"]);
  },
});

Deno.test({
  name: "Windows MSVC prebuilt distributions link and install",
  ignore: Deno.build.os !== "windows",
  async fn(test) {
    await buildWindowsDistribution(test, "msvc", [
      "x86-windows-msvc",
      "x86_64-windows-msvc",
      "aarch64-windows-msvc",
    ]);
  },
});

async function buildWindowsDistribution(
  test: Deno.TestContext,
  abi: "gnu" | "msvc",
  targets: string[],
): Promise<void> {
  await withTempDirectory(`sdl-windows-${abi}-distribution-`, async (temporary) => {
    const packageRoot = await stageReleaseTree(`${temporary}/package`);
    const consumer = await stageDistributionConsumer(temporary, packageRoot);

    for (const target of targets) {
      await test.step(`${target} prebuilts link and install`, async () => {
        const optionalCodecs = !target.startsWith("aarch64-");
        const output = `${temporary}/${target}`;
        await buildDistributionConsumer(consumer, temporary, target, output, [
          ...companions.map((library) => `-D${library}=true`),
          `-Doptional_codecs=${optionalCodecs}`,
        ]);
        if (target === `${Deno.build.arch}-windows-${abi}`) {
          await runWindowsExecutable(`${output}/bin/sdl-distribution-consumer.exe`, output);
        }
      });
    }
  });
}
