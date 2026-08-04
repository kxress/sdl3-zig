import { assert, assertEquals, assertRejects, assertThrows } from "@std/assert";
import { buildShaders, parseShaderManifest } from "../scripts/build-shaders.ts";
import { runCommand } from "../scripts/utils/command.ts";

Deno.test("shader manifest validates safe, explicit source contracts", () => {
  const manifest = parseShaderManifest({
    version: 1,
    shaders: [{
      name: "sample",
      input: "sample.hlsl",
      language: "hlsl",
      stage: "vertex",
    }],
  });
  assertEquals(manifest.shaders[0].entrypoint, undefined);
  assertThrows(
    () =>
      parseShaderManifest({
        version: 1,
        shaders: [{ name: "../unsafe", input: "sample.hlsl", language: "hlsl", stage: "vertex" }],
      }),
    Error,
    "safe identifier",
  );
  assertThrows(
    () =>
      parseShaderManifest({
        version: 1,
        shaders: [{ name: "zig", input: "shader.zig", language: "zig", stage: "vertex" }],
      }),
    Error,
    "source_language",
  );
});

Deno.test("shader helper reports a missing required compiler", async () => {
  const temporary = await makeShaderTemp("sdl3-shader-diagnostic-");
  try {
    await Deno.writeTextFile(`${temporary}/shader.hlsl`, "void main() {}");
    await Deno.writeTextFile(
      `${temporary}/manifest.json`,
      JSON.stringify({
        version: 1,
        shaders: [{ name: "shader", input: "shader.hlsl", language: "hlsl", stage: "vertex" }],
      }),
    );
    await assertRejects(
      () =>
        buildShaders({
          manifest: `${temporary}/manifest.json`,
          output: `${temporary}/output`,
          shadercross: `${temporary}/missing-shadercross`,
        }),
      Error,
      "Required shader tool 'missing-shadercross'",
    );
    await Deno.writeTextFile(`${temporary}/shader.glsl`, "#version 450\nvoid main() {}");
    await Deno.writeTextFile(
      `${temporary}/glsl-manifest.json`,
      JSON.stringify({
        version: 1,
        shaders: [{ name: "shader", input: "shader.glsl", language: "glsl", stage: "vertex" }],
      }),
    );
    await assertRejects(
      () =>
        buildShaders({
          manifest: `${temporary}/glsl-manifest.json`,
          output: `${temporary}/glsl-output`,
          glslang: `${temporary}/missing-glslangValidator`,
        }),
      Error,
      "Required shader tool 'missing-glslangValidator'",
    );
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
});

Deno.test({
  name: "shader helper produces stable metadata when the pinned tools are supplied",
  ignore: !Deno.env.has("SDL_SHADERCROSS") || !Deno.env.has("GLSLANG_VALIDATOR"),
  async fn() {
    const temporary = await makeShaderTemp("sdl3-shader-determinism-");
    try {
      const first = `${temporary}/first`;
      const second = `${temporary}/second`;
      await buildShaders({
        manifest: "examples/shaders/manifest.json",
        output: first,
      });
      await buildShaders({
        manifest: "examples/shaders/manifest.json",
        output: second,
      });
      const expected = await Deno.readTextFile(`${first}/shader-manifest.json`);
      const actual = await Deno.readTextFile(`${second}/shader-manifest.json`);
      assertEquals(actual, expected);
      for (
        const name of [
          "glsl_vertex",
          "hlsl_vertex",
          "zig_vertex",
          "glsl_compute",
          "hlsl_compute",
          "zig_compute",
        ]
      ) {
        for (const extension of ["spv", "dxil", "metal", "json"]) {
          assert(
            await sameBytes(`${first}/${name}.${extension}`, `${second}/${name}.${extension}`),
            `${name}.${extension} was not deterministic`,
          );
        }
      }
    } finally {
      await Deno.remove(temporary, { recursive: true });
    }
  },
});

Deno.test({
  name: "shader outputs load through SDL_GPU when a host loader is configured",
  ignore: !Deno.env.has("SDL_SHADER_DEVICE_LOADER") || !Deno.env.has("SDL_SHADER_OUTPUT_DIR"),
  async fn() {
    const loader = Deno.env.get("SDL_SHADER_DEVICE_LOADER")!;
    const output = Deno.env.get("SDL_SHADER_OUTPUT_DIR")!;
    for (const [format, extension] of [["spirv", "spv"], ["dxil", "dxil"], ["msl", "metal"]]) {
      await runCommand(loader, [format, `${output}/hlsl_vertex.${extension}`], {
        stdout: "inherit",
        stderr: "inherit",
      });
    }
  },
});

async function sameBytes(left: string, right: string): Promise<boolean> {
  const leftBytes = await Deno.readFile(left);
  const rightBytes = await Deno.readFile(right);
  return leftBytes.length === rightBytes.length &&
    leftBytes.every((byte, index) => byte === rightBytes[index]);
}

async function makeShaderTemp(prefix: string): Promise<string> {
  const cache = `${Deno.cwd()}/.zig-cache`;
  await Deno.mkdir(cache, { recursive: true });
  return await Deno.makeTempDir({ dir: cache, prefix });
}
