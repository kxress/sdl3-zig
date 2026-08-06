import { run, runScopedExecutable } from "./support.ts";

const nativeTarget = (() => {
  switch (Deno.build.os) {
    case "linux":
      return `${Deno.build.arch}-linux-gnu`;
    case "windows":
      // The cross-target matrix separately covers MinGW.  The native Windows gate must inspect
      // the MSVC ABI used by the CMake distribution consumer and the Windows CI host.
      return `${Deno.build.arch}-windows-msvc`;
    case "darwin":
      return `${Deno.build.arch}-macos`;
    default:
      return undefined;
  }
})();

Deno.test({
  name: "native C and Zig agree on long-double layout and round-trip ABI",
  ignore: nativeTarget === undefined,
  async fn() {
    // Preserve the temporary Zig cache; recursive cleanup can hang on hosted macOS runners.
    const directory = await Deno.makeTempDir({ prefix: "sdl-long-double-runtime-" });
    const cSource = `${directory}/probe.c`;
    const zigSource = `${directory}/probe.zig`;
    const executable = `${directory}/long-double-runtime${
      Deno.build.os === "windows" ? ".exe" : ""
    }`;
    await Deno.writeTextFile(
      cSource,
      `#include <stddef.h>

size_t probe_size(void) { return sizeof(long double); }
size_t probe_alignment(void) { return _Alignof(long double); }
long double probe_roundtrip(long double value) { return value; }
`,
    );
    await Deno.writeTextFile(
      zigSource,
      `extern fn probe_size() callconv(.c) usize;
extern fn probe_alignment() callconv(.c) usize;
extern fn probe_roundtrip(value: c_longdouble) callconv(.c) c_longdouble;

pub fn main() !void {
    if (probe_size() != @sizeOf(c_longdouble)) return error.SizeMismatch;
    if (probe_alignment() != @alignOf(c_longdouble)) return error.AlignmentMismatch;
    const value: c_longdouble = 1.25;
    if (probe_roundtrip(value) != value) return error.RoundTripMismatch;
}
`,
    );
    await run("zig", [
      "build-exe",
      zigSource,
      cSource,
      "-lc",
      "-target",
      nativeTarget!,
      "--name",
      "long-double-runtime",
      `-femit-bin=${executable}`,
      "--cache-dir",
      `${directory}/zig-cache`,
      "--global-cache-dir",
      `${directory}/zig-global-cache`,
    ]);
    await runScopedExecutable(executable, []);
  },
});
