import { assert, assertEquals } from "@std/assert";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";

const assertionMacros = [
  "SDL_assert",
  "SDL_assert_release",
  "SDL_assert_paranoid",
  "SDL_assert_always",
  "SDL_enabled_assert",
  "SDL_disabled_assert",
] as const;

Deno.test("SDL assertion macros retain an explicit rejected disposition", async () => {
  const core = codegenConfiguration.libraries.find((library) => library.id === "SDL3")!;
  const policies = new Map(core.profile.coveragePolicies!.map((policy) => [policy.cName, policy]));
  for (const cName of assertionMacros) {
    const policy = policies.get(cName);
    assert(policy, `missing coverage policy for ${cName}`);
    assertEquals(policy.handling, "unrepresentable");
    assertEquals(policy.status, "intentional");
    assert(policy.reason.includes("per-call-site static SDL_AssertData"));
    assert(policy.reason.includes("SDL_ASSERT_LEVEL"));
    assert(policy.evidence.some((evidence) => evidence.kind === "policy"));
  }

  const generated = await Deno.readTextFile("src/sdl.zig");
  assert(!generated.includes("assert.check("));
  assert(!generated.includes("assert.checkAlways("));
  assert(!generated.includes("assert.isEnabled("));
  assert(generated.includes("const assert_level = c.SDL_ASSERT_LEVEL"));
});
