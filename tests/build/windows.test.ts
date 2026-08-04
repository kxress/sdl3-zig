import { stageReleaseTree } from "../../scripts/package-release.ts";
import {
  prebuiltTargetsFor,
  targetName,
  windowsOptionalArchitectures,
  type WindowsPrebuiltFamily,
} from "../../scripts/distribution-policy.ts";
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
              await Deno.stat(`${temporary}/${linkage}/output/bin/${library}.dll`);
            }
          }
          await run(
            `${cache}/sdl3-source-build/ControllerImage/make-controllerimage-data.exe`,
            ["${Deno.cwd()}\\vendor\\ControllerImage\\art"],
            { cwd: `${temporary}/${linkage}` },
          );
          await runWindowsExecutable(
            `${temporary}/${linkage}/output/bin/cmake-source-all.exe`,
            `${temporary}/${linkage}`,
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
    await buildWindowsDistribution(test, "mingw");
  },
});

Deno.test({
  name: "Windows MSVC prebuilt distributions link and install",
  ignore: Deno.build.os !== "windows",
  async fn(test) {
    await buildWindowsDistribution(test, "msvc");
  },
});

async function buildWindowsDistribution(
  test: Deno.TestContext,
  abi: WindowsPrebuiltFamily,
  targets = prebuiltTargetsFor(abi),
): Promise<void> {
  await withTempDirectory(`sdl-windows-${abi}-distribution-`, async (temporary) => {
    const packageRoot = await stageReleaseTree(`${temporary}/package`);
    const consumer = await stageDistributionConsumer(temporary, packageRoot);

    for (const target of targets) {
      const targetString = targetName(target);
      await test.step(`${targetString} prebuilts link and install`, async () => {
        const optionalCodecs = windowsOptionalArchitectures[abi].includes(target.arch);
        const output = `${temporary}/${targetString}`;
        await buildDistributionConsumer(consumer, temporary, targetString, output, [
          "-Ddistribution=prebuilt",
          ...companions.map((library) => `-D${library}=true`),
          `-Doptional_codecs=${optionalCodecs}`,
        ]);
        for (const library of ["SDL3", "SDL3_image", "SDL3_ttf", "SDL3_mixer", "SDL3_net"]) {
          await Deno.stat(`${output}/bin/${library}.dll`);
        }
        if (targetString === `${Deno.build.arch}-windows-${target.abi}`) {
          await runWindowsExecutable(`${output}/bin/sdl-distribution-consumer.exe`, output);
        }
      });
    }
  });
}
