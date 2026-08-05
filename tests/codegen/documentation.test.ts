import { assertEquals } from "@std/assert";
import {
  appendDeclarationSemanticsDocumentation,
  renderDocComment,
} from "../../scripts/codegen/documentation.ts";

Deno.test("declaration metadata adds prominent deprecation guidance", () => {
  const source = appendDeclarationSemanticsDocumentation(
    "Use the newer operation.",
    { deprecated: { message: "Kept for source compatibility.", replacement: "SDL_New" } },
  );
  assertEquals(
    renderDocComment(source),
    [
      "/// Use the newer operation.",
      "///",
      "/// > **Deprecated:** Kept for source compatibility. Use `SDL_New` instead.",
    ],
  );
});

Deno.test("declaration metadata preserves an existing deprecation and adds replacement", () => {
  const source = appendDeclarationSemanticsDocumentation(
    "**Deprecated:** Prefer the replacement.",
    { deprecated: { replacement: "SDL_New" } },
  );
  assertEquals(
    renderDocComment(source),
    [
      "/// > **Deprecated:** Prefer the replacement.",
      "///",
      "/// - **Replacement:** Use `SDL_New` instead.",
    ],
  );
});

Deno.test("result-use metadata is documentation-only and idempotent", () => {
  const once = appendDeclarationSemanticsDocumentation(
    "Returns a status.",
    { resultUse: "should_use" },
  );
  const twice = appendDeclarationSemanticsDocumentation(once, { resultUse: "should_use" });
  assertEquals(once, twice);
  assertEquals(
    renderDocComment(once).at(-1),
    "/// - **Result use:** The return value should be checked or otherwise consumed.",
  );
});

Deno.test("return-flow metadata distinguishes runtime and analyzer-only contracts", () => {
  const noReturn = appendDeclarationSemanticsDocumentation(
    "Terminates the process.",
    { returnFlow: "no_return" },
  );
  assertEquals(
    renderDocComment(noReturn).at(-1),
    "/// > **Control flow:** This function does not return.",
  );

  const analyzerOnly = appendDeclarationSemanticsDocumentation(
    "Reports an assertion failure.",
    { returnFlow: "analyzer_no_return" },
  );
  assertEquals(
    renderDocComment(analyzerOnly).at(-1),
    "/// > **Analyzer control flow:** Static analyzers may treat this function as non-returning, " +
      "but it can return at runtime.",
  );
});

Deno.test("return-flow documentation is idempotent and does not alter ordinary declarations", () => {
  const source = appendDeclarationSemanticsDocumentation(
    "Reports an assertion failure.\n\n> **Analyzer control flow:** Static analyzers may treat this function as non-returning, but it can return at runtime.",
    { returnFlow: "analyzer_no_return" },
  );
  assertEquals(
    source,
    "Reports an assertion failure.\n\n> **Analyzer control flow:** Static analyzers may treat this function as non-returning, but it can return at runtime.",
  );
  assertEquals(
    appendDeclarationSemanticsDocumentation("Returns normally.", { returnFlow: "normal" }),
    "Returns normally.",
  );
});
