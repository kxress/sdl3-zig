import { command, withTempDirectory } from "./support.ts";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";

const fixture = `${import.meta.dirname}/fixtures/allocator_bridge`;

async function expectDiagnostic(step: string, fragment: string): Promise<void> {
  await withTempDirectory(`sdl-allocator-${step}-`, async (cache) => {
    const result = await command("zig", ["build", step, ...cacheArgs(cache)], { cwd: fixture });
    if (result.success) throw new Error(`expected ${step} to fail`);
    const diagnostic = new TextDecoder().decode(result.stderr);
    if (!diagnostic.includes(fragment)) {
      throw new Error(`${step} diagnostic changed unexpectedly:\n${diagnostic}`);
    }
  });
}

function cacheArgs(cache: string): string[] {
  return ["--cache-dir", `${cache}/local`, "--global-cache-dir", `${cache}/global`];
}

async function runFixture(...args: string[]): Promise<void> {
  const cache = await Deno.makeTempDir({ prefix: "sdl-allocator-build-" });
  let completed = false;
  try {
    const command = new Deno.Command("zig", {
      args: ["build", ...args, ...cacheArgs(cache)],
      cwd: fixture,
      signal: AbortSignal.timeout(90_000),
    });
    const result = await command.output();
    if (result.success) {
      completed = true;
      return;
    }
    const decoder = new TextDecoder();
    throw new Error(
      `zig build ${args.join(" ")} exited with code ${result.code}:\n${
        decoder.decode(result.stderr)
      }\n${decoder.decode(result.stdout)}`,
    );
  } finally {
    // Preserve an aborted target cache for CI diagnostics; successful probes clean up normally.
    if (completed) await Deno.remove(cache, { recursive: true });
  }
}

Deno.test({
  name: "generated allocator bridge passes its fake-ABI lifetime and pairing fixture",
  timeout: 10 * 60 * 1000,
  fn: async () => {
    await runFixture("--summary", "all");
  },
});

Deno.test({
  name: "allocator bridge preserves size_t ABI width on Windows targets",
  ignore: Deno.build.os !== "windows",
  timeout: 10 * 60 * 1000,
  fn: async () => {
    await runFixture("compile-check", "-Dtarget=x86_64-windows-gnu");
  },
});

for (const analysisTarget of codegenConfiguration.targets) {
  Deno.test({
    name: `allocator bridge compiles for ${analysisTarget}`,
    timeout: 2 * 60 * 1000,
    fn: async () => {
      // Zig spells the API-level suffix in the analysis target separately from its target triple.
      const zigTarget = analysisTarget === "aarch64-linux-android21"
        ? "aarch64-linux-android"
        : analysisTarget;
      await runFixture("matrix-check", `-Dtarget=${zigTarget}`);
    },
  });
}

Deno.test("SDL_COMPILE_TIME_ASSERT preserves its supplied failure name", async () => {
  const result = await command("zig", ["build", "negative-compile-time"], { cwd: fixture });
  if (result.success) throw new Error("expected the negative compile-time fixture to fail");
  const diagnostic = new TextDecoder().decode(result.stderr);
  if (!diagnostic.includes("SDL_COMPILE_TIME_ASSERT failure")) {
    throw new Error(`compile-time assertion diagnostic lost its name:\n${diagnostic}`);
  }
});

Deno.test("SDL_static_cast rejects an incompatible target", async () => {
  const result = await command("zig", ["build", "negative-cast"], { cwd: fixture });
  if (result.success) throw new Error("expected the negative cast fixture to fail");
  const diagnostic = new TextDecoder().decode(result.stderr);
  if (!diagnostic.includes("type 'u8' cannot represent integer value")) {
    throw new Error(`invalid cast diagnostic changed unexpectedly:\n${diagnostic}`);
  }
});

Deno.test("typed scanf wrappers reject an incompatible destination width", async () => {
  const result = await command("zig", ["build", "negative-format"], { cwd: fixture });
  if (result.success) throw new Error("expected the negative format fixture to fail");
  const diagnostic = new TextDecoder().decode(result.stderr);
  if (!diagnostic.includes("C scanf %d requires *c_int")) {
    throw new Error(`scanf destination diagnostic changed unexpectedly:\n${diagnostic}`);
  }
});

Deno.test("C format grammar rejects positional arguments", async () => {
  const result = await command("zig", ["build", "negative-grammar"], { cwd: fixture });
  if (result.success) throw new Error("expected positional format fixture to fail");
  const diagnostic = new TextDecoder().decode(result.stderr);
  if (!diagnostic.includes("positional C format arguments are unsupported")) {
    throw new Error(`positional format diagnostic changed unexpectedly:\n${diagnostic}`);
  }
});

Deno.test("C scanf grammar rejects empty scansets", async () => {
  await expectDiagnostic("negative-scanset", "malformed C scanf scanset");
});

Deno.test("C format grammar reports stable diagnostics for invalid consumers", async (test) => {
  const cases = [
    ["negative-argument-count", "C format has too few arguments"],
    ["negative-promotion", "C printf integer arguments must be default-promoted to c_int"],
    ["negative-signed-length", "C printf %lld requires c_longlong"],
    ["negative-string", "C printf %s arguments must be sentinel-terminated C strings"],
    ["negative-immutable-scan", "C scanf string arguments must be writable pointers"],
    ["negative-pointer", "C printf pointer arguments must be pointers"],
    ["negative-malformed", "unterminated C format specifier"],
    ["negative-unsupported", "unsupported C format conversion"],
  ] as const;
  for (const [step, fragment] of cases) {
    await test.step(step, () => expectDiagnostic(step, fragment));
  }
});
