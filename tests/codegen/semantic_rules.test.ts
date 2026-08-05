import { assertStringIncludes, assertThrows } from "@std/assert";
import {
  analyzeTargets,
  type ApiModel,
  mergeApiModels,
  type XmlAstNode,
} from "../../scripts/codegen/analysis.ts";
import type { LibraryProfile } from "../../scripts/codegen/profile.ts";
import { renderSemanticBindings } from "../../scripts/codegen/render.ts";

const profile: LibraryProfile = {
  moduleName: "pattern",
  displayName: "Pattern",
  abiImportName: "pattern_c",
  symbolPrefixes: ["PATTERN_"],
  dependencies: [],
  error: { provider: "local" },
  allocator: {
    provider: "local",
    malloc: "PATTERN_malloc",
    realloc: "PATTERN_realloc",
    free: "PATTERN_free",
    alignedAlloc: "PATTERN_aligned_alloc",
    alignedFree: "PATTERN_aligned_free",
  },
  releaseFunctions: ["PATTERN_free"],
  headerPrefixes: ["pattern_"],
  rootHeaders: ["pattern.h"],
  namespaceStrategy: { kind: "header_stem" },
};

function node(
  id: string,
  kind: string,
  attributes: Record<string, string> = {},
  members: string[] = [],
): XmlAstNode {
  return { id, kind, attributes, members, order: 0 };
}

function argument(id: string, name: string, type: string, order: number): XmlAstNode {
  return { id, kind: "Argument", attributes: { name, type }, members: [], order };
}

function fn(
  id: string,
  name: string,
  returns: string,
  args: XmlAstNode[],
  location = name,
): XmlAstNode {
  return node(id, "Function", { name, returns, location }, args.map(({ id }) => id));
}

function documentation(name: string, comment: string) {
  return {
    name,
    kind: "function",
    header: "pattern.h",
    signature: "",
    comment,
    parameters: [],
  };
}

function semanticFixture(): ApiModel {
  const values = argument("values_arg", "values", "const_int_pointer", 0);
  const count = argument("count_arg", "count", "uint", 1);
  const required = argument("required_arg", "value", "const_int_pointer", 0);
  const callback = argument("callback_arg", "callback", "callback_typedef", 0);
  const handleArgument = argument("handle_arg", "handle", "handle_pointer", 0);
  const objectFlags = node("object_flags", "Field", { name: "flags", type: "uint" });
  const object = node("object", "Struct", { name: "PATTERN_Object", location: "object" }, [
    objectFlags.id,
  ]);
  const styleFlags = node("style_flags", "Typedef", { name: "PATTERN_StyleFlags", type: "uint32" });
  const addValue = argument("add_value", "value", "int", 0);
  const addDelta = argument("add_delta", "delta", "int", 1);
  const createValue = argument("create_value", "value", "int", 0);
  const createBegin = argument("create_begin", "pfn_begin", "callback_pointer", 1);
  const createEnd = argument("create_end", "pfn_end", "callback_pointer", 2);
  const formatVaList = argument("format_va_list", "ap", "va_list", 0);
  const formatVariadic = argument("format_variadic", "format", "const_char_pointer", 0);
  const ellipsis = node("ellipsis", "Ellipsis");
  const nodes = [
    node("void", "FundamentalType", { name: "void" }),
    node("int", "FundamentalType", { name: "int" }),
    node("uint", "FundamentalType", { name: "unsigned int" }),
    node("uint32", "Typedef", { name: "Uint32", type: "uint" }),
    node("char", "FundamentalType", { name: "char" }),
    node("const_int", "CvQualifiedType", { type: "int", const: "1" }),
    node("const_char", "CvQualifiedType", { type: "char", const: "1" }),
    node("const_int_pointer", "PointerType", { type: "const_int" }),
    node("const_char_pointer", "PointerType", { type: "const_char" }),
    node("callback_function", "FunctionType", { returns: "void" }, ["callback_userdata"]),
    argument("callback_userdata", "userdata", "void_pointer", 0),
    node("callback_pointer", "PointerType", { type: "callback_function" }),
    node("va_list_pointer", "PointerType", { type: "void" }),
    node("va_list", "Typedef", { name: "va_list", type: "va_list_pointer" }),
    node("callback_typedef", "Typedef", { name: "PATTERN_Callback", type: "callback_pointer" }),
    node("void_pointer", "PointerType", { type: "void" }),
    node("handle", "Struct", { name: "PATTERN_Handle" }),
    node("handle_pointer", "PointerType", { type: "handle" }),
    objectFlags,
    object,
    styleFlags,
    addValue,
    addDelta,
    createValue,
    createBegin,
    createEnd,
    formatVaList,
    formatVariadic,
    ellipsis,
    ...[values, count, required, callback, handleArgument],
    fn("add", "PATTERN_Add", "int", [addValue, addDelta]),
    fn("create_runtime", "PATTERN_CreateRuntime", "int", [createValue, createBegin, createEnd]),
    fn("format_v", "PATTERN_FormatV", "int", [formatVaList]),
    fn("print", "PATTERN_Print", "int", [formatVariadic, ellipsis]),
    fn("use", "PATTERN_UsePointer", "void", [required]),
    fn("sum", "PATTERN_Sum", "int", [values, count]),
    fn("name", "PATTERN_GetName", "const_char_pointer", []),
    fn("check", "PATTERN_Check", "int", []),
    fn("notify", "PATTERN_Notify", "void", [callback]),
    fn("create_handle", "PATTERN_CreateHandle", "handle_pointer", []),
    fn("destroy_handle", "PATTERN_DestroyHandle", "void", [handleArgument]),
    fn("use_handle", "PATTERN_UseHandle", "void", [handleArgument]),
    fn("alloc_name", "PATTERN_AllocName", "const_char_pointer", []),
    fn("platform_only", "PATTERN_PlatformOnly", "void", [], "platform"),
  ];
  const publicNodeIds = nodes
    .filter((candidate) =>
      candidate.attributes.name?.startsWith("PATTERN_") || candidate.id === object.id
    )
    .map(({ id }) => id);
  const locations = Object.fromEntries(
    nodes
      .filter(({ id }) => publicNodeIds.includes(id))
      .map((candidate) => [candidate.attributes.location ?? candidate.id, {
        file: candidate.attributes.location === "platform"
          ? "include/pattern_extra.h"
          : "include/pattern.h",
      }]),
  );
  return {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu", "aarch64-macos"],
    apiPrefixes: ["PATTERN_"],
    nodes,
    publicNodeIds,
    locations,
    files: {},
    documentation: [
      documentation(
        "PATTERN_UsePointer",
        "Uses a value.\n\n- `value`: Must not be null.",
      ),
      documentation(
        "PATTERN_Sum",
        "Sums values.\n\n- `values`: The values.\n- `count`: Number of values.",
      ),
      documentation("PATTERN_GetName", "Returns a sentinel-terminated name."),
      documentation(
        "PATTERN_Check",
        "Checks the input.\n\n**Returns:** a negative error code on failure.",
      ),
      documentation("PATTERN_Notify", "Invokes the callback during this call."),
      documentation(
        "PATTERN_CreateHandle",
        "Creates a handle.\n\n**Returns:** a handle or NULL on failure.",
      ),
      documentation(
        "PATTERN_DestroyHandle",
        "Destroys the handle and makes it invalid.",
      ),
      documentation("PATTERN_UseHandle", "Uses the handle."),
      documentation(
        "PATTERN_AllocName",
        "Returns a string owned by the caller and should be freed with PATTERN_free.",
      ),
      documentation("PATTERN_PlatformOnly", "Available only on the macOS target."),
      {
        name: "PATTERN_Mask",
        kind: "define",
        header: "pattern.h",
        signature: "PATTERN_Mask(value)",
        comment: "Masks a value without evaluating it more than once.",
        parameters: ["value"],
      },
      {
        name: "PATTERN_IsMasked",
        kind: "define",
        header: "pattern.h",
        signature: "PATTERN_IsMasked(object)",
        comment: "Checks whether an object has the mask set.",
        parameters: ["object"],
      },
      documentation("PATTERN_Add", "Adds two values."),
      documentation("PATTERN_Inc", "Adds one to a value."),
      documentation("PATTERN_CreateRuntime", "Creates a value with runtime hooks."),
      documentation("PATTERN_Create", "Creates a value."),
      documentation("PATTERN_FormatV", "Consumes a va_list.\n\n- `ap`: a va_list."),
      documentation("PATTERN_FormatV", "Consumes a va_list.\n\n- `ap`: a va_list."),
      documentation("PATTERN_Print", "Prints a formatted message."),
    ],
    headerDocumentation: [{
      header: "pattern_extra.h",
      category: "CategoryPlatform",
      comment: "Target-specific Pattern APIs.",
    }],
    constants: [
      { name: "PATTERN_MASK", value: "255", source: "macro", header: "pattern.h" },
      { name: "PSTYLE_BOLD", value: "1", source: "macro", header: "pattern.h" },
      { name: "PSTYLE_MASK", value: "3", source: "macro", header: "pattern.h" },
    ],
    publicNodeTargets: Object.fromEntries(
      publicNodeIds.map((
        id,
      ) => [
        id,
        id === "platform_only" ? ["aarch64-macos"] : ["x86_64-linux-gnu", "aarch64-macos"],
      ]),
    ),
    constantTargets: {},
    declarationSemantics: {
      PATTERN_Print: {
        linkage: "default",
        inline: "none",
        returnFlow: "normal",
        resultUse: "ordinary",
        format: { dialect: "printf", formatParameter: 0, firstVariadicParameter: 1 },
      },
    },
    functionMacros: [
      {
        name: "PATTERN_Mask",
        parameters: ["value"],
        replacement: "((value) & PATTERN_MASK)",
        header: "pattern.h",
      },
      {
        name: "PATTERN_IsMasked",
        parameters: ["object"],
        replacement: "(((object)->flags & PATTERN_MASK) == PATTERN_MASK)",
        header: "pattern.h",
      },
      {
        name: "PATTERN_Inc",
        parameters: ["value"],
        replacement: "PATTERN_Add((value), 1)",
        header: "pattern.h",
      },
      {
        name: "PATTERN_Create",
        parameters: ["value"],
        replacement:
          "PATTERN_CreateRuntime((value), (PATTERN_FunctionPointer) (PATTERN_BeginFunction), (PATTERN_FunctionPointer) (PATTERN_EndFunction))",
        header: "pattern.h",
      },
    ],
    functionMacroTargets: {
      PATTERN_Mask: ["x86_64-linux-gnu", "aarch64-macos"],
      PATTERN_IsMasked: ["x86_64-linux-gnu", "aarch64-macos"],
      PATTERN_Inc: ["x86_64-linux-gnu", "aarch64-macos"],
      PATTERN_Create: ["x86_64-linux-gnu", "aarch64-macos"],
    },
  };
}

Deno.test("semantic fixtures preserve independent pointer, slice, callback, and error rules", () => {
  const { source } = renderSemanticBindings(semanticFixture(), profile, new Map());

  assertStringIncludes(source, "pub const Callback = ?*const fn (userdata: ?*anyopaque)");
  assertStringIncludes(source, 'pub const c = @import("pattern_c");');
  assertStringIncludes(source, "pub inline fn usePointer(value: *const c_int) void {");
  assertStringIncludes(source, "pub inline fn sum(values: []const c_int) c_int {");
  assertStringIncludes(source, "c.PATTERN_Sum(@ptrCast(values.ptr), @intCast(values.len))");
  assertStringIncludes(source, "pub inline fn getName() ?[:0]const u8 {");
  assertStringIncludes(source, "pub inline fn check() Error!c_int {");
  assertStringIncludes(source, "if (result < 0) return error.SdlFailure;");
  assertStringIncludes(source, "pub inline fn notify(callback: Callback) void {");
  assertStringIncludes(source, "Invokes the callback during this call.");
  assertStringIncludes(source, "pub const Handle = struct {");
  assertStringIncludes(source, "pub inline fn deinit(self: *@This()) void {");
  assertStringIncludes(source, "pub inline fn use(self: @This()) void {");
  assertStringIncludes(source, "pub inline fn allocName(allocator_: std.mem.Allocator)");
  assertStringIncludes(source, "defer c.PATTERN_free(result);");
  assertStringIncludes(source, "pub const extra = if (builtin.os.tag == .linux) struct {");
  assertStringIncludes(source, "builtin.os.tag == .macos");
  assertStringIncludes(source, "root.platformOnly");
  assertStringIncludes(source, "pub inline fn maskMacro(value: c_uint) c_uint {");
  assertStringIncludes(source, "return value & c.PATTERN_MASK;");
  assertStringIncludes(source, "pub inline fn isMasked(object: *const Object) bool {");
  assertStringIncludes(source, "return (object.flags & c.PATTERN_MASK) == c.PATTERN_MASK;");
  assertStringIncludes(source, "pub inline fn inc(value: c_int) c_int {");
  assertStringIncludes(source, "return add(value, 1);");
  assertStringIncludes(source, "pub inline fn create(value: c_int) c_int {");
  assertStringIncludes(
    source,
    "return createRuntime(value, @ptrCast(c.PATTERN_BeginFunction), @ptrCast(c.PATTERN_EndFunction));",
  );
  assertStringIncludes(source, "pub inline fn formatV(ap: std.builtin.VaList) c_int {");
  assertStringIncludes(
    source,
    "return c.PATTERN_FormatV(if (@typeInfo(std.builtin.VaList) == .pointer) @ptrCast(ap) else @ptrCast(&ap));",
  );
  assertStringIncludes(
    source,
    "pub inline fn print(comptime format: [:0]const u8, args: anytype) c_int {",
  );
  assertStringIncludes(source, "validateCVarargs(format, args, false)");
  assertStringIncludes(source, "if (builtin.os.tag == .linux)");
  assertStringIncludes(source, "pub const StyleFlags = packed struct(u32)");
  assertStringIncludes(source, "bold: bool = false,");
  assertStringIncludes(source, "pub const mask: @This() = fromInt(@intCast(c.PSTYLE_MASK));");
});

Deno.test("real no-return semantics render a noreturn Zig wrapper", () => {
  const fixture = semanticFixture();
  const stop = fn("stop", "PATTERN_Stop", "void", []);
  fixture.nodes.push(stop);
  fixture.publicNodeIds.push(stop.id);
  fixture.publicNodeTargets[stop.id] = ["x86_64-linux-gnu", "aarch64-macos"];
  fixture.locations[stop.attributes.location!] = { file: "include/pattern.h", line: 90 };
  fixture.documentation.push(documentation("PATTERN_Stop", "Terminates the process."));
  fixture.declarationSemantics!.PATTERN_Stop = {
    linkage: "exported",
    inline: "none",
    returnFlow: "no_return",
    resultUse: "ordinary",
  };

  const { source } = renderSemanticBindings(fixture, profile, new Map());
  assertStringIncludes(source, "pub inline fn stop() noreturn {");
  assertStringIncludes(source, "c.PATTERN_Stop();\n    unreachable;");
});

Deno.test("header and Doxygen fixtures drive semantic translation", async () => {
  const directory = await Deno.makeTempDir({ prefix: "sdl-zig-semantic-fixture-" });
  try {
    await Deno.writeTextFile(
      `${directory}/pattern.h`,
      `#ifndef PATTERN_H
#define PATTERN_H

/** A callback invoked during the operation. */
typedef void (*PATTERN_Callback)(void *userdata);

/** An opaque resource owned by the caller. */
typedef struct PATTERN_Handle PATTERN_Handle;

/** Sums a borrowed array.
 * @param values values to sum
 * @param count number of values
 */
int PATTERN_Sum(const int *values, unsigned int count);

/** Returns a borrowed sentinel-terminated name. */
const char *PATTERN_GetName(void);

/** Reports a negative error code on failure. */
int PATTERN_Check(void);

/** Invokes the callback during this call.
 * @param callback callback to invoke
 */
void PATTERN_Notify(PATTERN_Callback callback);

/** Creates a handle, or NULL on failure. */
PATTERN_Handle *PATTERN_CreateHandle(void);

/** Destroys a handle and makes it invalid.
 * @param handle handle to destroy
 */
void PATTERN_DestroyHandle(PATTERN_Handle *handle);

/** Uses a handle.
 * @param handle handle to use
 */
void PATTERN_UseHandle(PATTERN_Handle *handle);

#endif
`,
    );
    const [model] = await analyzeTargets({
      translationUnit: '#include "pattern.h"',
      includeDirectories: [directory],
      publicIncludeDirectories: [directory],
      apiPrefixes: profile.symbolPrefixes,
      defines: [],
      targets: ["x86_64-linux-gnu"],
      documentationInput: directory,
      documentationProjectName: profile.displayName,
      documentationPredefined: [],
    });
    const { source } = renderSemanticBindings(
      mergeApiModels([model]),
      profile,
      new Map(),
    );

    assertStringIncludes(source, "pub const Callback = ?*const fn (arg0: ?*anyopaque)");
    assertStringIncludes(source, "pub inline fn sum(values: []const c_int) c_int {");
    assertStringIncludes(source, "pub inline fn getName() ?[:0]const u8 {");
    assertStringIncludes(source, "pub inline fn check() Error!c_int {");
    assertStringIncludes(source, "pub inline fn notify(callback: Callback) void {");
    assertStringIncludes(source, "pub const Handle = struct {");
    assertStringIncludes(source, "pub inline fn deinit(self: *@This()) void {");
    assertStringIncludes(source, "pub inline fn use(self: @This()) void {");
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});

Deno.test("open integer typedefs own configured constant families", () => {
  const keycode = node("keycode", "Typedef", { name: "PATTERN_Keycode", type: "uint" });
  const key = argument("key_arg", "key", "keycode", 0);
  const use = fn("use_key", "PATTERN_UseKey", "void", [key]);
  const nodes = [
    node("void", "FundamentalType", { name: "void" }),
    node("uint", "FundamentalType", { name: "unsigned int" }),
    keycode,
    key,
    use,
  ];
  const model: ApiModel = {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu"],
    apiPrefixes: ["PATTERN_"],
    nodes,
    publicNodeIds: [keycode.id, use.id],
    locations: {
      keycode: { file: "pattern.h" },
      use_key: { file: "pattern.h" },
    },
    files: {},
    documentation: [],
    headerDocumentation: [],
    constants: [
      { name: "PKEY_PRINTABLE", value: "65", source: "macro", header: "pattern.h" },
      { name: "PKEY_EXPRESSION", value: "256", source: "macro", header: "pattern.h" },
      { name: "PKEY_COLLISION", value: "0", source: "macro", header: "pattern.h" },
    ],
    publicNodeTargets: { keycode: ["x86_64-linux-gnu"], use_key: ["x86_64-linux-gnu"] },
    constantTargets: {
      "macro:PKEY_PRINTABLE": ["x86_64-linux-gnu"],
      "macro:PKEY_EXPRESSION": ["x86_64-linux-gnu"],
      "macro:PKEY_COLLISION": ["x86_64-linux-gnu"],
    },
  };
  const { source } = renderSemanticBindings(
    model,
    {
      ...profile,
      rootHeaders: ["pattern.h"],
      constantFamilies: [{ prefix: "PKEY_", typedef: "PATTERN_Keycode" }],
    },
    new Map(),
  );
  assertStringIncludes(source, "pub const keycode_collision = c.PKEY_COLLISION;");
  assertStringIncludes(source, "pub const keycode_expression = c.PKEY_EXPRESSION;");
  assertStringIncludes(source, "pub const keycode_printable = c.PKEY_PRINTABLE;");
  assertStringIncludes(source, "pub inline fn useKey(key: Keycode) void {");
});

Deno.test("release result retains the direct SDL macro port surface", async () => {
  const source = await Deno.readTextFile("src/sdl.zig");
  for (
    const declaration of [
      "inline fn compileTimeAssert",
      "inline fn constCast",
      "inline fn reinterpretCast",
      "inline fn staticCast",
      "inline fn sint64c",
      "inline fn uint64c",
      "inline fn prilLd",
      "inline fn prilLu",
      "inline fn prilLx",
      "inline fn prillx",
      "inline fn triggerBreakpoint",
      "inline fn assertBreakpoint",
      "inline fn compilerBarrier",
    ]
  ) {
    assertStringIncludes(source, declaration);
  }
  assertStringIncludes(source, "std.builtin.VaList");
  assertStringIncludes(source, "c.SDL_BeginThreadFunction");
  assertStringIncludes(source, "c.SDL_EndThreadFunction");
});

Deno.test("manual function macro policy must match the analyzed macro inventory", () => {
  assertThrows(
    () =>
      renderSemanticBindings(
        semanticFixture(),
        {
          ...profile,
          manualFunctionMacros: [{
            cName: "PATTERN_missing",
            kind: "iconv_utf8_locale",
          }],
        },
        new Map(),
      ),
    Error,
    "Manual function macro PATTERN_missing is not present",
  );
  assertThrows(
    () =>
      renderSemanticBindings(
        semanticFixture(),
        {
          ...profile,
          manualFunctionMacros: [{
            cName: "PATTERN_Mask",
            kind: "unknown" as never,
          }],
        },
        new Map(),
      ),
    Error,
    "Manual function macro PATTERN_Mask has no renderer for kind unknown",
  );
});

Deno.test("release format wrappers preserve non-final format positions", async () => {
  const source = await Deno.readTextFile("src/sdl.zig");
  assertStringIncludes(
    source,
    "inline fn renderDebugTextFormat(renderer: ?Renderer, x: f32, y: f32, comptime format: [:0]const u8, args: anytype)",
  );
  assertStringIncludes(source, "validateCVarargs(format, args, false)");
});

Deno.test("generated C-format grammar retains the promoted %lf rule", async () => {
  const source = await Deno.readTextFile("src/sdl.zig");
  assertStringIncludes(
    source,
    ".{ .specifier = 'f', .length = .l, .printf = .float, .scanf = .scan_double },",
  );
  assertStringIncludes(source, "@setEvalBranchQuota(10_000);");
  assertStringIncludes(source, ".long_double => c_longdouble,");
});

Deno.test("builtin-backed SDL helpers retain operation-specific Zig implementations", async () => {
  const source = await Deno.readTextFile("src/sdl.zig");
  for (
    const declaration of [
      "inline fn triggerBreakpoint",
      "inline fn assertBreakpoint",
      "inline fn compilerBarrier",
      "inline fn sizeAddCheckOverflow",
      "inline fn sizeMulCheckOverflow",
      "inline fn swap16",
      "inline fn swap32",
      "inline fn swap64",
    ]
  ) {
    assertStringIncludes(source, declaration);
  }
});

Deno.test("memory barrier helpers preserve SDL acquire/release ordering contract", async () => {
  const source = await Deno.readTextFile("src/sdl.zig");
  assertStringIncludes(
    source,
    "inline fn memoryBarrierAcquire() void {\n    memoryBarrierAcquireFunction();",
  );
  assertStringIncludes(
    source,
    "inline fn memoryBarrierRelease() void {\n    memoryBarrierReleaseFunction();",
  );
  assertStringIncludes(
    source,
    "Memory barriers are designed to prevent reads and writes from being reordered by the compiler",
  );
  assertStringIncludes(
    source,
    "insert a release barrier between writing the data and the flag",
  );
  assertStringIncludes(
    source,
    "insert an acquire barrier between reading the flag and reading the data",
  );
});

Deno.test("prefetch remains an internal SDL implementation detail", async () => {
  const source = await Deno.readTextFile("src/sdl.zig");
  assertStringIncludes(source, "inline fn compilerBarrier");
  if (source.includes("@prefetch")) {
    throw new Error("generated public bindings must not expose an internal prefetch operation");
  }
  for (
    const header of [
      "vendor/SDL3/include/SDL3/SDL_endian.h",
      "vendor/SDL3/include/SDL3/SDL_intrin.h",
    ]
  ) {
    const lines = (await Deno.readTextFile(header)).split(/\r?\n/);
    const applications = lines.filter((line) =>
      /prefetch/i.test(line) && !line.includes("_m_prefetch") &&
      !/^\s*(?:#|\/\*|\*|\/\/|static\b|__builtin_prefetch)/.test(line)
    );
    if (applications.length > 0) {
      throw new Error(`unexpected public prefetch application in ${header}`);
    }
  }
});

Deno.test("allocation contract mismatches stop generation with C source context", () => {
  const fixture = semanticFixture();
  fixture.locations.PATTERN_AllocName = { file: "include/pattern.h", line: 99 };
  fixture.declarationSemantics = {
    ...fixture.declarationSemantics,
    PATTERN_AllocName: {
      linkage: "default",
      inline: "none",
      returnFlow: "normal",
      resultUse: "ordinary",
      mallocLike: false,
    },
  };
  const invalidProfile: LibraryProfile = {
    ...profile,
    allocationContracts: [{ cName: "PATTERN_AllocName", mallocLike: true }],
  };
  assertThrows(
    () => renderSemanticBindings(fixture, invalidProfile, new Map()),
    Error,
    "Contradictory allocator metadata for PATTERN_AllocName at include/pattern.h:99",
  );
});

Deno.test("format contract failures identify the C declaration and source location", () => {
  const invalidIndex = semanticFixture();
  invalidIndex.declarationSemantics = {
    ...invalidIndex.declarationSemantics,
    PATTERN_Print: {
      ...invalidIndex.declarationSemantics!.PATTERN_Print,
      format: { dialect: "printf", formatParameter: 4, firstVariadicParameter: 1 },
    },
  };
  invalidIndex.locations = {
    ...invalidIndex.locations,
    PATTERN_Print: { file: "include/pattern.h", line: 1 },
  };
  assertThrows(
    () => renderSemanticBindings(invalidIndex, profile, new Map()),
    Error,
    "PATTERN_Print at include/pattern.h:1",
  );

  const invalidOrder = semanticFixture();
  invalidOrder.declarationSemantics = {
    ...invalidOrder.declarationSemantics,
    PATTERN_Print: {
      ...invalidOrder.declarationSemantics!.PATTERN_Print,
      format: { dialect: "scanf", formatParameter: 0, firstVariadicParameter: 0 },
    },
  };
  assertThrows(
    () => renderSemanticBindings(invalidOrder, profile, new Map()),
    Error,
    "must precede variadic index 0",
  );
});
