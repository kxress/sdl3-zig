import { run } from "./support.ts";

const fixture = `${import.meta.dirname}/fixtures/allocator_bridge`;

Deno.test("generated allocator bridge passes its fake-ABI lifetime and pairing fixture", async () => {
  await run("zig", ["build", "--summary", "all"], { cwd: fixture });
});
