import { assertThrows } from "@std/assert";
import { validateNoticeInventory } from "../scripts/third-party-notices.ts";

Deno.test("third-party notice inventory rejects missing and unexpected entries", () => {
  validateNoticeInventory(
    ["LICENSE", "vendor/SDL3/LICENSE.txt"],
    ["LICENSE", "vendor/SDL3/LICENSE.txt"],
    ["LICENSE"],
  );

  assertThrows(
    () => validateNoticeInventory(["LICENSE"], ["LICENSE", "vendor/SDL3/LICENSE.txt"], ["LICENSE"]),
    Error,
    "missing expected notice: vendor/SDL3/LICENSE.txt",
  );
  assertThrows(
    () => validateNoticeInventory(["LICENSE", "vendor/extra/NOTICE.txt"], ["LICENSE"], ["LICENSE"]),
    Error,
    "unexpected notice: vendor/extra/NOTICE.txt",
  );
});
