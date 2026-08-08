import { assert, assertEquals, assertStringIncludes } from "@std/assert";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";

Deno.test("release baseline retains the pinned SDL, target matrix, and clean coverage", async () => {
  const sdlPin = await Deno.readTextFile("mise.sdl.toml");
  const toolPin = await Deno.readTextFile("mise.toml");
  const coverage = await Deno.readTextFile("COVERAGE.md");
  const generated = await Deno.readTextFile("src/sdl.zig");

  assertStringIncludes(sdlPin, 'version = "3.4.12"');
  for (
    const pin of [
      '"conda:castxml" = "0.7.0"',
      '"conda:clang" = "19.1.7"',
      '"conda:doxygen" = "1.17.0"',
      'zig = "0.16.0"',
    ]
  ) {
    assertStringIncludes(toolPin, pin);
  }
  assertEquals(codegenConfiguration.targets, [
    "x86_64-linux-gnu",
    "x86_64-windows-gnu",
    "aarch64-macos",
    "aarch64-ios",
    "aarch64-ios-simulator",
    "x86_64-ios-simulator",
    "aarch64-tvos",
    "aarch64-tvos-simulator",
    "x86_64-tvos-simulator",
    "wasm32-emscripten",
    "aarch64-linux-android21",
  ]);
  const coreProfile = codegenConfiguration.libraries.find((library) => library.id === "SDL3")!
    .profile;
  assertEquals(
    coreProfile.manualFunctionMacros?.map(({ cName, kind }) => ({ cName, kind })),
    [
      { cName: "SDL_iconv_utf8_locale", kind: "iconv_utf8_locale" },
      { cName: "SDL_iconv_utf8_ucs2", kind: "iconv_utf8_ucs2" },
      { cName: "SDL_iconv_utf8_ucs4", kind: "iconv_utf8_ucs4" },
      { cName: "SDL_iconv_wchar_utf8", kind: "iconv_wchar_utf8" },
    ],
  );
  assertStringIncludes(coverage, "| Overall | 6283 | 6216 | 65 | 2 |");

  for (
    const declaration of [
      "inline fn compileTimeAssert",
      "inline fn constCast",
      "inline fn reinterpretCast",
      "inline fn staticCast",
      "inline fn sint64c",
      "inline fn uint64c",
      "inline fn triggerBreakpoint",
      "inline fn assertBreakpoint",
      "inline fn compilerBarrier",
      "inline fn createThread",
      "inline fn createThreadWithProperties",
    ]
  ) {
    assert(generated.includes(declaration), `missing generated declaration: ${declaration}`);
  }
  assertStringIncludes(generated, "std.builtin.VaList");
  assertStringIncludes(generated, "inline fn asprintf(allocator_: std.mem.Allocator");
  assertStringIncludes(generated, "inline fn calloc(nmemb: usize, size: usize)");
  assertStringIncludes(generated, "inline fn realloc(mem: ?*anyopaque, size: usize)");
  for (
    const helper of [
      "inline fn iconvUtf8Locale",
      "inline fn iconvUtf8Ucs2",
      "inline fn iconvUtf8Ucs4",
      "inline fn iconvWcharUtf8",
    ]
  ) {
    assertStringIncludes(generated, helper);
  }
  assert(!generated.includes("SDL_ThreadID"), "analyzer-only SDL_ThreadID leaked into ABI output");
  for (
    const companion of ["image", "ttf", "mixer", "net", "test", "shadercross", "controller_image"]
  ) {
    const companionSource = await Deno.readTextFile(`src/${companion}.zig`);
    assert(
      !/^pub const allocator\b/m.test(companionSource),
      `${companion} constructed an allocator`,
    );
    assert(
      !companionSource.includes("AllocatorBridge"),
      `${companion} constructed an allocator bridge`,
    );
  }
  assertStringIncludes(
    generated,
    'createThreadRuntime(fn_, name, data, if (comptime @import("builtin").os.tag == .windows) @ptrCast(&c.SDL_BeginThreadFunction) else @ptrCast(@alignCast(c.SDL_BeginThreadFunction)), if (comptime @import("builtin").os.tag == .windows) @ptrCast(&c.SDL_EndThreadFunction) else @ptrCast(@alignCast(c.SDL_EndThreadFunction)))',
  );
  assertStringIncludes(
    generated,
    'createThreadWithPropertiesRuntime(props, if (comptime @import("builtin").os.tag == .windows) @ptrCast(&c.SDL_BeginThreadFunction) else @ptrCast(@alignCast(c.SDL_BeginThreadFunction)), if (comptime @import("builtin").os.tag == .windows) @ptrCast(&c.SDL_EndThreadFunction) else @ptrCast(@alignCast(c.SDL_EndThreadFunction)))',
  );
  assertStringIncludes(generated, "validateCVarargs(format, args, false)");
  assertStringIncludes(generated, "validateCVarargs(format, args, true)");
  assertStringIncludes(generated, "inline fn swap32(x: u32) u32");
  assertStringIncludes(
    generated,
    "inline fn compilerBarrier() void {\n    memoryBarrierAcquireFunction();\n}",
  );
});
