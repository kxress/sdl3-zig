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
  timeout: 30 * 60 * 1000,
  async fn(test) {
    const temporary = await Deno.makeTempDir({ prefix: "sdl-windows-cmake-source-" });
    for (const linkage of ["static", "shared"]) {
      await test.step(linkage, async () => {
        console.error(`[windows source] building ${linkage} linkage`);
        const cache = `${temporary}/${linkage}/local`;
        await run("zig", [
          "build",
          `-Dtarget=${Deno.build.arch}-windows-msvc`,
          `-Dlinkage=${linkage}`,
          "-Dinstall_controller_image_data=true",
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
            await Deno.stat(`${temporary}/${linkage}/output/bin/${library}.dll`);
          }
        }
        console.error(`[windows source] running ${linkage} executable`);
        await runWindowsExecutable(
          `${temporary}/${linkage}/output/bin/cmake-source-all.exe`,
          `${temporary}/${linkage}/output/share/ControllerImage`,
        );
        console.error(`[windows source] passed ${linkage} linkage`);
      });
    }
  },
});

Deno.test({
  name: "Windows MinGW prebuilt distributions link and install",
  ignore: Deno.build.os !== "windows",
  timeout: 10 * 60 * 1000,
  async fn(test) {
    await buildWindowsDistribution(test, "mingw");
  },
});

Deno.test({
  name: "Windows MSVC prebuilt distributions link and install",
  ignore: Deno.build.os !== "windows",
  timeout: 10 * 60 * 1000,
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
        console.error(`[windows prebuilt] building ${abi} ${targetString}`);
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
          console.error(`[windows prebuilt] running ${abi} ${targetString}`);
          await runWindowsExecutable(`${output}/bin/sdl-distribution-consumer.exe`, output);
        }
        console.error(`[windows prebuilt] passed ${abi} ${targetString}`);
      });
    }
  });
}
