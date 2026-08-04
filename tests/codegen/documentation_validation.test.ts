import { assert, assertThrows } from "@std/assert";
import { collectDoxygenDocumentation, parseDoxygenComment } from "../../scripts/codegen/doxygen.ts";
import { validateGeneratedDocumentation } from "../../scripts/check-generated-documentation.ts";

Deno.test("generated documentation validation rejects malformed reference shapes", () => {
  validateGeneratedDocumentation([[
    "valid.zig",
    "/// See also: time\n/// SDL_APP_EVENT (C macro outside this module)",
  ]]);

  assertThrows(
    () =>
      validateGeneratedDocumentation([[
        "fragment.zig",
        "/// - **See also:** loadGpuTexture */ extern SDL_DECLSPEC IMG_LoadGPUTexture_IO(...);",
      ]]),
    Error,
    "embedded C declaration fragment",
  );
  assertThrows(
    () =>
      validateGeneratedDocumentation([[
        "category.zig",
        "/// See [CategoryTime](CategoryTime)",
      ]]),
    Error,
    "unresolved local category link",
  );
  assertThrows(
    () =>
      validateGeneratedDocumentation([[
        "macro.zig",
        "/// See also: SDL_AUDIO_BITSIZE (C macro)",
      ]]),
    Error,
    "unresolved C macro reference",
  );
});

Deno.test("generated bindings retain recovered SDL_image documentation", async () => {
  const image = await Deno.readTextFile("src/image.zig");
  assert(image.includes("There is also loadGpuTextureTypedIo(), which is equivalent"));
  assert(image.includes("pub inline fn loadGpuTextureIo"));
  assert(image.includes("pub inline fn loadGpuTextureTypedIo"));
  assert(!image.includes("*/ extern"));

  const sdl = await Deno.readTextFile("src/sdl.zig");
  assert(!sdl.includes("CategoryTime"));
  assert(sdl.includes("provided by [time](time)."));
});

Deno.test("source Doxygen comments retain parameters and see-also fields", () => {
  const parsed = parseDoxygenComment(`
 * Loads a resource.
 *
 * \\param source input bytes.
 * \\returns the loaded resource.
 * \\sa SDL_DestroyResource
 `);
  assert(parsed.parameters.includes("source"));
  assert(parsed.comment.includes("**Parameters:**"));
  assert(parsed.comment.includes("**Returns:** the loaded resource."));
  assert(parsed.comment.includes("**See also:** SDL_DestroyResource"));
});

Deno.test("synthetic Doxygen reference corruption is recovered from header comments", async () => {
  const directory = await Deno.makeTempDir({ prefix: "sdl-doxygen-fixture-" });
  try {
    await Deno.writeTextFile(
      `${directory}/pattern.h`,
      `/**\n * Load one resource.\n * \\sa PATTERN_LoadTyped_IO\n */\n` +
        `extern int PATTERN_Load_IO(void);\n\n` +
        `/**\n * Load a typed resource.\n * \\returns a typed resource.\n */\n` +
        `extern int PATTERN_LoadTyped_IO(void);\n`,
    );
    const result = await collectDoxygenDocumentation({
      inputDirectory: directory,
      outputDirectory: `${directory}/doxygen`,
      apiPrefixes: ["PATTERN_"],
      projectName: "Pattern",
      predefined: [],
    });
    const typed = result.documentation.find((item) => item.name === "PATTERN_LoadTyped_IO");
    assert(typed);
    assert(typed.comment.includes("Load a typed resource."));
    assert(!typed.comment.includes("*/ extern"));
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});
