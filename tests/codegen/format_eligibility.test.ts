import { assertFalse, assertStringIncludes } from "@std/assert";
import type { ApiModel, XmlAstNode } from "../../scripts/codegen/analysis.ts";
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
  order = 0,
): XmlAstNode {
  return { id, kind, attributes, members, order };
}

function wideVariadicFixture(): ApiModel {
  const format = node("format", "Argument", { name: "format", type: "wide_ptr" }, [], 0);
  const ellipsis = node("ellipsis", "Ellipsis");
  const narrowFormat = node(
    "narrow_format",
    "Argument",
    { name: "format", type: "narrow_ptr" },
    [],
    0,
  );
  const narrowEllipsis = node("narrow_ellipsis", "Ellipsis");
  const wide = node(
    "wide",
    "Function",
    { name: "PATTERN_Wide", returns: "void", location: "wide" },
    [format.id, ellipsis.id],
  );
  wide.attributes.ellipsis = "1";
  const narrow = node(
    "narrow",
    "Function",
    { name: "PATTERN_Narrow", returns: "void", location: "narrow" },
    [narrowFormat.id, narrowEllipsis.id],
  );
  narrow.attributes.ellipsis = "1";
  const nodes = [
    node("void", "FundamentalType", { name: "void" }),
    node("char", "FundamentalType", { name: "char" }),
    node("char_const", "CvQualifiedType", { type: "char", const: "1" }),
    node("narrow_ptr", "PointerType", { type: "char_const" }),
    node("wchar", "Typedef", { name: "wchar_t", type: "wchar_fundamental" }),
    node("wchar_fundamental", "FundamentalType", { name: "int" }),
    node("wchar_const", "CvQualifiedType", { type: "wchar", const: "1" }),
    node("wide_ptr", "PointerType", { type: "wchar_const" }),
    format,
    ellipsis,
    wide,
    narrowFormat,
    narrowEllipsis,
    narrow,
  ];
  return {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu", "aarch64-windows"],
    apiPrefixes: ["PATTERN_"],
    nodes,
    publicNodeIds: [wide.id, narrow.id],
    locations: {
      wide: { file: "include/pattern.h", line: 42 },
      narrow: { file: "include/pattern.h", line: 43 },
    },
    files: {},
    documentation: [{
      name: "PATTERN_Wide",
      kind: "function",
      header: "pattern.h",
      signature: "void PATTERN_Wide(const wchar_t *format, ...)",
      comment: "Formats a wide string.",
      parameters: ["..."],
    }, {
      name: "PATTERN_Narrow",
      kind: "function",
      header: "pattern.h",
      signature: "void PATTERN_Narrow(const char *format, ...)",
      comment: "Formats a narrow string.",
      parameters: ["..."],
    }],
    headerDocumentation: [],
    constants: [],
    publicNodeTargets: {
      [wide.id]: ["x86_64-linux-gnu", "aarch64-windows"],
      [narrow.id]: ["x86_64-linux-gnu", "aarch64-windows"],
    },
    constantTargets: {},
    declarationSemantics: {
      PATTERN_Wide: {
        linkage: "default",
        inline: "none",
        returnFlow: "normal",
        resultUse: "ordinary",
        format: { dialect: "printf", formatParameter: 0, firstVariadicParameter: 1 },
      },
      PATTERN_Narrow: {
        linkage: "default",
        inline: "none",
        returnFlow: "normal",
        resultUse: "ordinary",
        format: { dialect: "printf", formatParameter: 0, firstVariadicParameter: 1 },
      },
    },
  };
}

Deno.test("wide variadic contracts retain raw C access instead of a tuple adapter", () => {
  const rendered = renderSemanticBindings(wideVariadicFixture(), profile, new Map());
  assertStringIncludes(rendered.source, 'pub const c = @import("pattern_c");');
  assertStringIncludes(
    rendered.source,
    ".{ .specifier = 'f', .length = .l, .printf = .float, .scanf = .scan_double },",
  );
  assertFalse(rendered.source.includes("pub inline fn wide("));
  assertStringIncludes(rendered.source, "pub inline fn narrow(comptime format: [:0]const u8");
  assertFalse(rendered.coverageNames.includes("PATTERN_Wide"));
  if (!rendered.coverageNames.includes("PATTERN_Narrow")) {
    throw new Error("narrow format contract was not emitted");
  }
});
