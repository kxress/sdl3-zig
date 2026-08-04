import { assertStringIncludes } from "@std/assert";
import type { ApiModel, XmlAstNode } from "../../scripts/codegen/analysis.ts";
import type { LibraryProfile } from "../../scripts/codegen/profile.ts";
import { renderSemanticBindings } from "../../scripts/codegen/render.ts";

function node(
  id: string,
  kind: string,
  attributes: Record<string, string> = {},
  members: string[] = [],
): XmlAstNode {
  return { id, kind, attributes, members, order: 0 };
}

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

Deno.test("record fields preserve nullable callbacks and opaque pointers", () => {
  const nodes = [
    node("u32", "FundamentalType", { name: "unsigned int" }),
    node("int", "FundamentalType", { name: "int" }),
    node("char", "FundamentalType", { name: "char" }),
    node("const_char", "CvQualifiedType", { type: "char", const: "1" }),
    node("string_pointer", "PointerType", { type: "const_char" }),
    node("void", "FundamentalType", { name: "void" }),
    node("callback_arg", "Argument", { name: "userdata", type: "void_pointer" }),
    node("callback", "FunctionType", { returns: "void" }, ["callback_arg"]),
    node("callback_pointer", "PointerType", { type: "callback" }),
    node("void_pointer", "PointerType", { type: "void" }),
    node("version", "Field", { name: "version", type: "u32" }),
    node("userdata", "Field", { name: "userdata", type: "void_pointer" }),
    node("run", "Field", { name: "run", type: "callback_pointer" }),
    node("consume_value", "Argument", { name: "value", type: "void_pointer" }),
    node(
      "consume",
      "Function",
      { name: "PATTERN_Consume", returns: "void", location: "consume" },
      ["consume_value"],
    ),
    node("check", "Function", { name: "PATTERN_Check", returns: "int", location: "check" }),
    node("name", "Function", { name: "PATTERN_Name", returns: "string_pointer", location: "name" }),
    node(
      "interface",
      "Struct",
      { name: "PATTERN_Interface", location: "interface" },
      ["version", "userdata", "run"],
    ),
  ];
  const model: ApiModel = {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu"],
    apiPrefixes: ["PATTERN_"],
    nodes,
    publicNodeIds: ["interface", "consume", "check", "name"],
    locations: {
      interface: { file: "include/pattern.h" },
      consume: { file: "include/pattern.h" },
      check: { file: "include/pattern.h" },
      name: { file: "include/pattern.h" },
    },
    files: {},
    documentation: [{
      name: "PATTERN_INIT_INTERFACE",
      kind: "define",
      header: "pattern.h",
      signature: "",
      comment: "Initializes a PATTERN interface.",
      parameters: [],
    }, {
      name: "PATTERN_Interface",
      kind: "struct",
      header: "pattern.h",
      signature: "",
      comment: "This structure should be initialized using PATTERN_INIT_INTERFACE().",
      parameters: [],
    }, {
      name: "PATTERN_Consume",
      kind: "function",
      header: "pattern.h",
      signature: "",
      comment: "Consumes a value.\n\n- `value`: Must not be null.",
      parameters: ["value"],
    }, {
      name: "PATTERN_Check",
      kind: "function",
      header: "pattern.h",
      signature: "",
      comment: "Checks a value.\n\n- **Returns:** a negative error code on failure.",
      parameters: [],
    }, {
      name: "PATTERN_Name",
      kind: "function",
      header: "pattern.h",
      signature: "",
      comment: "Returns a sentinel-terminated name.",
      parameters: [],
    }],
    headerDocumentation: [],
    constants: [],
    publicNodeTargets: { interface: ["x86_64-linux-gnu"] },
    constantTargets: {},
  };

  const { source } = renderSemanticBindings(model, profile, new Map());

  assertStringIncludes(source, "userdata: ?*anyopaque,");
  assertStringIncludes(source, "run: ?*const fn (userdata: ?*anyopaque) callconv(.c) void,");
  assertStringIncludes(source, "pub inline fn init() @This() {");
  assertStringIncludes(source, "var value: @This() = std.mem.zeroes(@This());");
  assertStringIncludes(source, "value.version = @sizeOf(@This());");
  assertStringIncludes(source, "pub const default: @This() = @This().init();");
  assertStringIncludes(source, "pub inline fn consume(value: *anyopaque) void {");
  assertStringIncludes(source, "pub inline fn check() Error!c_int {");
  assertStringIncludes(source, "pub inline fn name() ?[:0]const u8 {");
});
