import { assertGeneratedBindingsMatch } from "../../scripts/check-generated-bindings.ts";
import { generateRepositoryBindings } from "../../scripts/generate-bindings.ts";

Deno.test("committed generated bindings match a clean regeneration", async () => {
  const temporary = await Deno.makeTempDir({ prefix: "sdl-generated-bindings-" });
  try {
    await generateRepositoryBindings({ outputRoot: temporary });
    await assertGeneratedBindingsMatch(temporary);
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
});
