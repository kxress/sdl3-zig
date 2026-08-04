import { assertEquals, assertThrows } from "@std/assert";
import {
  extractHeaderIdentities,
  validateCoverageEvolution,
  validateCoverageInventory,
} from "../scripts/api-coverage.ts";

Deno.test("coverage inventory distinguishes documented declarations from macro artifacts", () => {
  const identities = extractHeaderIdentities(
    `
      #define PATTERN_VALUE 1
      #define PATTERN_KEY_A 65
      #define PATTERN_CALL(value) (value)
      #define PATTERN_Inc(value) PATTERN_Add((value), 1)
      #define PATTERN_PRIVATE 2
      typedef struct PATTERN_Record { int value; } PATTERN_Record;
      extern void PATTERN_DoThing(void);
      extern int PATTERN_Add(int value, int delta);
    `,
    "Pattern",
    "pattern.h",
    ["PATTERN_"],
    new Set([
      "PATTERN_VALUE",
      "PATTERN_KEY_A",
      "PATTERN_Record",
      "PATTERN_DoThing",
      "PATTERN_Inc",
    ]),
    new Set(["PATTERN_VALUE"]),
    ["PATTERN_KEY_"],
  );
  const byName = new Map(
    identities.map((identity) => [`${identity.kind}:${identity.name}`, identity]),
  );
  assertEquals(byName.get("function:PATTERN_DoThing")?.translation, "generated");
  assertEquals(byName.get("record:PATTERN_Record")?.translation, "generated");
  assertEquals(byName.get("macro:PATTERN_VALUE")?.translation, "excluded");
  assertEquals(byName.get("macro:PATTERN_VALUE")?.preprocessed, true);
  assertEquals(byName.get("macro:PATTERN_KEY_A")?.translation, "generated");
  assertEquals(byName.get("macro:PATTERN_CALL")?.translation, "excluded");
  assertEquals(byName.get("macro:PATTERN_Inc")?.translation, "generated");
  assertEquals(
    byName.get("macro:PATTERN_PRIVATE")?.reason,
    "Undocumented preprocessor artifact is not part of the supported public API.",
  );
});

Deno.test("coverage ledger applies disposition and target rules", () => {
  const inventory = {
    format: 1 as const,
    input_sha256: "fixture",
    mise_sdl_sha256: "fixture",
    identities: extractHeaderIdentities(
      "#define PATTERN_VALUE 1\nextern void PATTERN_DoThing(void);",
      "Pattern",
      "pattern.h",
      ["PATTERN_"],
      new Set(["PATTERN_DoThing"]),
    ),
  };
  validateCoverageInventory(inventory);
  assertThrows(() =>
    validateCoverageInventory({
      ...inventory,
      identities: [{
        ...inventory.identities[0],
        translation: "generated",
        documented: false,
      }],
    })
  );
});

Deno.test("coverage evolution allows additions but rejects unexplained losses", () => {
  const previous = {
    format: 1 as const,
    input_sha256: "previous",
    mise_sdl_sha256: "previous",
    identities: extractHeaderIdentities(
      "extern void PATTERN_DoThing(void);",
      "Pattern",
      "pattern.h",
      ["PATTERN_"],
      new Set(["PATTERN_DoThing"]),
    ),
  };
  const added = {
    ...previous,
    identities: [
      ...previous.identities,
      ...extractHeaderIdentities(
        "extern void PATTERN_DoThing(void);\nextern void PATTERN_NewThing(void);",
        "Pattern",
        "pattern.h",
        ["PATTERN_"],
        new Set(["PATTERN_DoThing", "PATTERN_NewThing"]),
      ).filter((identity) => identity.name === "PATTERN_NewThing"),
    ],
  };
  validateCoverageEvolution(previous, added);
  const removed = { ...previous, identities: [] };
  assertThrows(() => validateCoverageEvolution(previous, removed), Error, "removed");
});
