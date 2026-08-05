import { assertEquals, assertMatch } from "@std/assert";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";

const clangTargets: Record<string, string> = {
  "x86_64-linux-gnu": "x86_64-unknown-linux-gnu",
  "x86_64-windows-gnu": "x86_64-w64-windows-gnu",
  "aarch64-macos": "aarch64-apple-macos",
  "aarch64-ios": "aarch64-apple-ios",
  "aarch64-ios-simulator": "aarch64-apple-ios-simulator",
  "x86_64-ios-simulator": "x86_64-apple-ios-simulator",
  "aarch64-tvos": "aarch64-apple-tvos",
  "aarch64-tvos-simulator": "aarch64-apple-tvos-simulator",
  "x86_64-tvos-simulator": "x86_64-apple-tvos-simulator",
  "wasm32-emscripten": "wasm32-unknown-emscripten",
  "aarch64-linux-android21": "aarch64-linux-android21",
};

const zigTargets: Record<string, string> = {
  ...Object.fromEntries(codegenConfiguration.targets.map((target) => [target, target])),
  "aarch64-linux-android21": "aarch64-linux-android",
};

const probeSource = "struct LongDoubleProbe { long double value; }; " +
  "struct LongDoubleProbe probe;\n";

async function clangLayout(target: string): Promise<{ size: number; alignment: number }> {
  const command = new Deno.Command("clang", {
    args: [
      "-target",
      target,
      "-Xclang",
      "-fdump-record-layouts-complete",
      "-fsyntax-only",
      "-x",
      "c",
      "-",
    ],
    stdin: "piped",
    stdout: "piped",
    stderr: "piped",
  });
  const child = command.spawn();
  const writer = child.stdin.getWriter();
  await writer.write(new TextEncoder().encode(probeSource));
  await writer.close();
  const output = await child.output();
  const decoder = new TextDecoder();
  const diagnostics = decoder.decode(output.stdout) + decoder.decode(output.stderr);
  assertEquals(output.success, true, diagnostics);
  const text = diagnostics;
  const matches = [...text.matchAll(/\[sizeof=(\d+), align=(\d+)\]/g)];
  const match = matches.at(-1);
  assertMatch(text, /struct LongDoubleProbe/);
  if (!match) throw new Error(`Clang omitted long-double layout for ${target}`);
  return { size: Number(match[1]), alignment: Number(match[2]) };
}

Deno.test("Zig c_longdouble matches Clang size/alignment on every configured target", async (test) => {
  const directory = await Deno.makeTempDir({ prefix: "sdl-long-double-abi-" });
  try {
    for (const analysisTarget of codegenConfiguration.targets) {
      await test.step(analysisTarget, async () => {
        const clangTarget = clangTargets[analysisTarget];
        if (!clangTarget) throw new Error(`missing Clang target mapping for ${analysisTarget}`);
        const zigTarget = zigTargets[analysisTarget];
        if (!zigTarget) throw new Error(`missing Zig target mapping for ${analysisTarget}`);
        const layout = await clangLayout(clangTarget);
        const source = `${directory}/${analysisTarget}.zig`;
        const object = `${directory}/${analysisTarget}.o`;
        await Deno.writeTextFile(
          source,
          `comptime {\n` +
            `    if (@sizeOf(c_longdouble) != ${layout.size}) @compileError("size mismatch");\n` +
            `    if (@alignOf(c_longdouble) != ${layout.alignment}) @compileError("alignment mismatch");\n` +
            `}\n` +
            "test {}\n",
        );
        const result = await new Deno.Command("zig", {
          args: [
            "build-obj",
            source,
            "-target",
            zigTarget,
            "--name",
            "long-double-probe",
            "-femit-bin=" + object,
            "--cache-dir",
            `${directory}/zig-cache`,
            "--global-cache-dir",
            `${directory}/zig-global-cache`,
          ],
          stdout: "piped",
          stderr: "piped",
        }).output();
        assertEquals(result.success, true, new TextDecoder().decode(result.stderr));
      });
    }
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});
