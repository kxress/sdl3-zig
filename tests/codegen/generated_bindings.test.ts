import { assertRejects } from "@std/assert";
import { resolve } from "@std/path";
import { assertGeneratedBindingsMatch } from "../../scripts/check-generated-bindings.ts";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";
import { generateRepositoryBindings } from "../../scripts/generate-bindings.ts";

Deno.test("committed generated bindings match a clean regeneration", async () => {
  const temporary = await Deno.makeTempDir({ prefix: "sdl-generated-bindings-" });
  try {
    await generateRepositoryBindings({ outputRoot: temporary });
    await assertGeneratedBindingsMatch(temporary);

    const perturbed = resolve(temporary, codegenConfiguration.libraries[0].output);
    await Deno.writeTextFile(perturbed, `${await Deno.readTextFile(perturbed)}\n// drift\n`);
    await assertRejects(
      () => assertGeneratedBindingsMatch(temporary),
      Error,
      "differs from the committed source",
    );
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
});
