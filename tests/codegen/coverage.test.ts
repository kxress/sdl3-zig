import { assert, assertEquals } from "@std/assert";
import type { ApiModel } from "../../scripts/codegen/analysis.ts";
import { collectLibraryCoverage, renderCoverageReport } from "../../scripts/codegen/coverage.ts";
import type { LibraryProfile } from "../../scripts/codegen/profile.ts";

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
  releaseFunctions: [],
  headerPrefixes: ["PATTERN_"],
  rootHeaders: ["pattern.h"],
  namespaceStrategy: { kind: "header_stem" },
  macroTypeAliases: [{ name: "PATTERN_TYPE", type: "u32" }],
  coverageExclusions: [{
    names: ["PATTERN_ASSERT"],
    reason: "Intentional test policy.",
  }],
};

Deno.test("coverage classifies emitted, intentional, and unsupported entries", () => {
  const model: ApiModel = {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu"],
    apiPrefixes: ["PATTERN_"],
    nodes: [{
      id: "function",
      kind: "Function",
      attributes: { name: "PATTERN_Function" },
      members: [],
      order: 0,
    }],
    publicNodeIds: ["function"],
    locations: {},
    files: {},
    documentation: [],
    headerDocumentation: [],
    constants: [{ name: "PATTERN_CONSTANT", value: "1", source: "macro" }],
    publicNodeTargets: { function: ["x86_64-linux-gnu"] },
    constantTargets: { "macro:PATTERN_CONSTANT": ["x86_64-linux-gnu"] },
    functionMacros: [{
      name: "PATTERN_ASSERT",
      parameters: ["value"],
      replacement: "value",
    }],
    functionMacroTargets: { PATTERN_ASSERT: ["x86_64-linux-gnu"] },
    objectMacros: [{ name: "PATTERN_OBJECT", replacement: "unknown" }],
  };
  const coverage = collectLibraryCoverage(
    model,
    profile,
    [
      { cName: "PATTERN_Function", path: "function", kind: "function" },
      { cName: "PATTERN_TYPE", path: "type", kind: "macro" },
    ],
    "pattern.h",
  );

  assertEquals(coverage.entries.length, 5);
  assertEquals(coverage.entries.filter((entry) => entry.status === "covered").length, 2);
  assertEquals(coverage.entries.filter((entry) => entry.status === "intentional").length, 1);
  assertEquals(coverage.entries.filter((entry) => entry.status === "limitation").length, 2);
  assert(
    coverage.entries.some((entry) =>
      entry.cName === "PATTERN_OBJECT" && entry.reason?.includes("macro/constant renderer")
    ),
  );

  const report = renderCoverageReport([coverage]);
  assert(report.includes("| Pattern | 5 | 2 | 1 | 2 | 40.00% | 50.00% |"));
  assert(report.includes("`PATTERN_OBJECT`"));
  assert(report.includes("`PATTERN_ASSERT`"));
});
