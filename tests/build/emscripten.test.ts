import { run, withTempDirectory } from "./support.ts";

const fixture = `${import.meta.dirname}/fixtures/emscripten`;
const emsdk = Deno.env.get("EMSDK");

Deno.test({
  name: "Emscripten builds, stages, and runs the SDL source consumer",
  ignore: emsdk === undefined,
  async fn() {
    const sdk = emsdk!;
    const emscripten = `${sdk}/upstream/emscripten`;
    const sysroot = `${emscripten}/cache/sysroot`;
    const toolchain = `${emscripten}/cmake/Modules/Platform/Emscripten.cmake`;
    const inheritedPath = (Deno.env.get("PATH") ?? "").split(":").filter((entry) =>
      entry !== sdk && entry !== emscripten && entry !== `${emscripten}/cmake`
    );
    const path = [
      ...inheritedPath,
      `${emscripten}`,
      sdk,
    ].join(":");
    const env = { ...Deno.env.toObject(), PATH: path };

    await withTempDirectory("sdl-emscripten-build-", async (temporary) => {
      const output = `${temporary}/output`;
      await run("zig", [
        "build",
        "-Dtarget=wasm32-emscripten",
        "-Doptimize=ReleaseSmall",
        `-Demscripten_sysroot=${sysroot}`,
        `-Dsource_cmake_toolchain=${toolchain}`,
        "-p",
        output,
        "--cache-dir",
        `${temporary}/cache/local`,
        "--global-cache-dir",
        `${temporary}/cache/global`,
      ], { cwd: fixture, env, stdout: "inherit", stderr: "inherit" });

      for (
        const file of [
          "sdl-emscripten-consumer.html",
          "sdl-emscripten-consumer.js",
          "sdl-emscripten-consumer.wasm",
          "sdl-emscripten-consumer.data",
        ]
      ) {
        await Deno.stat(`${output}/${file}`);
      }
      await run("node", ["sdl-emscripten-consumer.js"], {
        cwd: output,
        env,
        stdout: "inherit",
        stderr: "inherit",
      });
    });
  },
});
