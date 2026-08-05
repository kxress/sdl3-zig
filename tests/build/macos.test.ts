import { stageReleaseTree } from "../../scripts/package-release.ts";
import { prebuiltTargetsFor, targetName } from "../../scripts/distribution-policy.ts";
import {
  buildDistributionConsumer,
  command,
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
              await Deno.stat(`${temporary}/${linkage}/output/lib/lib${library}.dylib`);
            }
            await assertRpath(
              `${temporary}/${linkage}/output/bin/cmake-source-all`,
              "@executable_path/../lib",
            );
          }
          await run(`${temporary}/${linkage}/output/bin/cmake-source-all`, [], {
            cwd: `${temporary}/${linkage}`,
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

      for (const target of prebuiltTargetsFor("macos").map(targetName)) {
        await test.step(`${target} prebuilts link and install`, async () => {
          const output = `${temporary}/${target}`;
          await buildDistributionConsumer(consumer, temporary, target, output, [
            "-Ddistribution=prebuilt",
            ...companions.map((library) => `-D${library}=true`),
            "-Doptional_codecs=true",
          ]);
          for (const framework of ["SDL3", "SDL3_image", "SDL3_ttf", "SDL3_mixer", "SDL3_net"]) {
            await Deno.stat(`${output}/lib/${framework}.framework/Versions/A/${framework}`);
          }
          await assertRpath(`${output}/bin/sdl-distribution-consumer`, "@executable_path/../lib");
          await run(`${output}/bin/sdl-distribution-consumer`, [], { cwd: output });
        });
      }
    });
  },
});

async function assertRpath(executable: string, expected: string): Promise<void> {
  const result = await command("otool", ["-l", executable]);
  if (!result.success) {
    throw new Error(
      `otool could not inspect ${executable}:\n${new TextDecoder().decode(result.stderr)}`,
    );
  }
  const output = new TextDecoder().decode(result.stdout);
  if (!output.includes(expected)) {
    throw new Error(`${executable} is missing rpath ${expected}`);
  }
}
