import { assert } from "@std/assert";
import { collectDoxygenDocumentation, parseDoxygenComment } from "../../scripts/codegen/doxygen.ts";

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
