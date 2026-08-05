import { assert, assertEquals, assertThrows } from "@std/assert";
import type { ApiModel } from "../../scripts/codegen/analysis.ts";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";
import {
  auditCoveragePolicies,
  collectLibraryCoverage,
  renderCoverageReport,
} from "../../scripts/codegen/coverage.ts";
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
  assert(report.includes("| intentional | unrepresentable |"));
  assert(report.includes("policy: PATTERN_ASSERT"));
});

Deno.test("coverage policies retain separate semantic and additive handling", () => {
  const model: ApiModel = {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu"],
    apiPrefixes: ["PATTERN_"],
    nodes: [],
    publicNodeIds: [],
    locations: {},
    files: {},
    documentation: [],
    headerDocumentation: [],
    constants: [],
    publicNodeTargets: {},
    constantTargets: {},
    functionMacros: [{
      name: "PATTERN_FORMAT",
      parameters: ["format"],
      replacement: "format",
    }],
    objectMacros: [{ name: "PATTERN_ASSERT", replacement: "assert" }],
  };
  const policies = [
    {
      cName: "PATTERN_FORMAT",
      status: "intentional" as const,
      handling: "semantic" as const,
      reason: "Format metadata is consumed by a generated wrapper.",
      evidence: [{
        kind: "normalized_effect" as const,
        source: "PATTERN_FORMAT",
        targets: ["x86_64-linux-gnu"],
        detail: "Format contract drives validation.",
      }],
    },
    {
      cName: "PATTERN_ASSERT",
      status: "intentional" as const,
      handling: "additive" as const,
      reason: "An adapter carries SDL assertion behavior.",
      evidence: [{
        kind: "additive_facility" as const,
        source: "PATTERN_ASSERT",
        targets: ["x86_64-linux-gnu"],
        detail: "Adapter evidence is separate from direct coverage.",
      }],
    },
  ];
  const coverage = collectLibraryCoverage(
    model,
    { ...profile, coveragePolicies: policies },
    [],
    "pattern.h",
  );
  assertEquals(
    coverage.entries.find((entry) => entry.cName === "PATTERN_FORMAT")?.handling,
    "semantic",
  );
  assertEquals(
    coverage.entries.find((entry) => entry.cName === "PATTERN_ASSERT")?.handling,
    "additive",
  );
  assertEquals(coverage.entries.filter((entry) => entry.status === "covered").length, 0);
});

Deno.test("coverage policy validation rejects orphan, duplicate, missing, and stale relations", () => {
  const model: ApiModel = {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu"],
    apiPrefixes: ["PATTERN_"],
    nodes: [],
    publicNodeIds: [],
    locations: {},
    files: {},
    documentation: [],
    headerDocumentation: [],
    constants: [],
    publicNodeTargets: {},
    constantTargets: {},
    functionMacros: [{ name: "PATTERN_FORMAT", parameters: [], replacement: "0" }],
  };
  const evidence = {
    kind: "test" as const,
    source: "PATTERN_FORMAT",
    targets: ["x86_64-linux-gnu"],
    detail: "fixture",
  };
  const policy = {
    cName: "PATTERN_FORMAT",
    status: "intentional" as const,
    handling: "semantic" as const,
    reason: "fixture",
    evidence: [evidence],
  };
  assertThrows(
    () =>
      collectLibraryCoverage(
        model,
        { ...profile, coveragePolicies: [{ ...policy, cName: "MISSING" }] },
        [],
        "pattern.h",
      ),
    Error,
    "unknown coverage policy",
  );
  assertThrows(
    () =>
      collectLibraryCoverage(
        model,
        { ...profile, coveragePolicies: [policy, policy] },
        [],
        "pattern.h",
      ),
    Error,
    "duplicate coverage policy",
  );
  assertThrows(
    () =>
      collectLibraryCoverage(
        model,
        { ...profile, coveragePolicies: [{ ...policy, status: "limitation", reason: "" }] },
        [],
        "pattern.h",
      ),
    Error,
    "missing a reason",
  );
  assertThrows(
    () =>
      collectLibraryCoverage(
        model,
        {
          ...profile,
          coveragePolicies: [{ ...policy, evidence: [{ ...evidence, source: "STALE" }] }],
        },
        [],
        "pattern.h",
      ),
    Error,
    "stale coverage evidence endpoint",
  );
});

Deno.test("configured SDL exclusions materialize as one typed policy per entry", () => {
  const sdl = codegenConfiguration.libraries.find((library) => library.id === "SDL3");
  const policies = sdl?.profile.coveragePolicies ?? [];
  assertEquals(policies.length, 65);
  assertEquals(new Set(policies.map((policy) => policy.cName)).size, 65);
  assert(policies.every((policy) => policy.evidence.length > 0));
  assert(policies.some((policy) => policy.handling === "indirect"));
  assert(policies.some((policy) => policy.handling === "semantic"));
  assert(policies.some((policy) => policy.handling === "unrepresentable"));
});

Deno.test("generated coverage retains every configured exclusion relation", async () => {
  const sdl = codegenConfiguration.libraries.find((library) => library.id === "SDL3");
  const configured = new Set((sdl?.profile.coveragePolicies ?? []).map((policy) => policy.cName));
  const report = await Deno.readTextFile("COVERAGE.md");
  const rendered = new Set<string>();
  for (const line of report.split(/\r?\n/)) {
    const match = line.match(/^\| SDL \| `([^`]+)` \| [^|]+ \| intentional \|/);
    if (match) rendered.add(match[1]);
  }
  assertEquals(rendered, configured);
  for (const name of configured) {
    assert(
      report.includes(`policy: ${name}`) ||
        report.includes(`normalized_effect: ${name}`) ||
        report.includes(`wrapper: ${name}`),
    );
  }
});

Deno.test("no-code policy families retain explicit unrepresentable evidence", () => {
  const sdl = codegenConfiguration.libraries.find((library) => library.id === "SDL3");
  const policies = new Map(
    (sdl?.profile.coveragePolicies ?? []).map((policy) => [policy.cName, policy]),
  );
  const stringify = policies.get("SDL_STRINGIFY_ARG");
  assertEquals(stringify?.handling, "unrepresentable");
  assert(stringify?.reason.includes("caller") && stringify.reason.includes("token"));
  for (
    const name of [
      "SDL_DLNOTE_JOIN",
      "SDL_DLNOTE_JOIN2",
      "SDL_DLNOTE_JSON_ARRAY",
      "SDL_DLNOTE_JSON_ARRAY_GET",
      "SDL_DLNOTE_JSON_ARRAY1",
      "SDL_DLNOTE_JSON_ARRAY2",
      "SDL_DLNOTE_JSON_ARRAY3",
      "SDL_DLNOTE_JSON_ARRAY4",
      "SDL_DLNOTE_JSON_ARRAY5",
      "SDL_DLNOTE_JSON_ARRAY6",
      "SDL_DLNOTE_JSON_ARRAY7",
      "SDL_DLNOTE_JSON_ARRAY8",
      "SDL_ELF_NOTE_DLOPEN",
      "SDL_ELF_NOTE_INTERNAL",
      "SDL_ELF_NOTE_INTERNAL2",
    ]
  ) {
    const policy = policies.get(name);
    assertEquals(policy?.handling, "unrepresentable");
    assert(policy?.reason.includes("ELF note"));
  }
  for (
    const name of [
      "SDL_ACQUIRE",
      "SDL_CAPABILITY",
      "SDL_HAS_BUILTIN",
      "SDL_stack_alloc",
      "SDL_stack_free",
    ]
  ) {
    assertEquals(policies.get(name)?.handling, "unrepresentable");
  }
});

Deno.test("coverage aggregates typed format applications across companion libraries", () => {
  const entry = (count: number) => ({
    cName: "SDL_PRINTF_VARARG_FUNC",
    kind: "function_macro",
    status: "intentional" as const,
    reason: "Format metadata is consumed by generated wrappers.",
    handling: "semantic" as const,
    evidence: [{
      kind: "normalized_effect" as const,
      source: "SDL_PRINTF_VARARG_FUNC",
      targets: ["x86_64-linux-gnu"],
      detail: `Application inventory: ${count} typed declaration application(s); consumption: ` +
        "FormatContract-driven Zig wrapper planning and validation.",
    }],
    targets: ["x86_64-linux-gnu"],
  });
  const library = (displayName: string, count: number) => ({
    moduleName: displayName.toLowerCase(),
    displayName,
    sourceLabel: `${displayName}.h`,
    targets: ["x86_64-linux-gnu"],
    entries: [entry(count)],
    formatApplications: { SDL_PRINTF_VARARG_FUNC: count },
  });
  const report = renderCoverageReport([library("SDL", 14), library("SDL_test", 6)]);
  assert(report.includes("Application inventory: 20 typed declaration application(s)"));
});

Deno.test("policy reconciliation consumes normalized applications and rejects no-code relations", () => {
  const model: ApiModel = {
    target: "x86_64-linux-gnu",
    analysisTargets: ["x86_64-linux-gnu"],
    apiPrefixes: ["SDL_"],
    nodes: [],
    publicNodeIds: [],
    locations: {},
    files: {},
    documentation: [],
    headerDocumentation: [],
    constants: [],
    publicNodeTargets: {},
    constantTargets: {},
    declarationSemantics: {
      SDL_Print: {
        linkage: "exported",
        inline: "always",
        returnFlow: "normal",
        resultUse: "should_use",
        format: { dialect: "printf", formatParameter: 0, firstVariadicParameter: 1 },
        deprecated: { message: "old" },
        allocationSize: { parameters: [0, 1] },
        alignment: 16,
        mallocLike: true,
        restrict: true,
        unused: true,
      },
      SDL_Fail: {
        linkage: "default",
        inline: "hint",
        returnFlow: "no_return",
        resultUse: "ordinary",
        fallthrough: true,
      },
      SDL_Analyze: {
        linkage: "default",
        inline: "none",
        returnFlow: "analyzer_no_return",
        resultUse: "ordinary",
        format: { dialect: "scanf", formatParameter: 0, firstVariadicParameter: "va_list" },
      },
    },
    functionMacros: [],
    objectMacros: [],
  };
  const names = [
    "SDL_PRINTF_VARARG_FUNC",
    "SDL_SCANF_VARARG_FUNCV",
    "SDL_ALLOC_SIZE2",
    "SDL_ALIGNED",
    "SDL_MALLOC",
    "SDL_DEPRECATED",
    "SDL_FALLTHROUGH",
    "SDL_FORCE_INLINE",
    "SDL_INLINE",
    "SDL_NODISCARD",
    "SDL_NORETURN",
    "SDL_ANALYZER_NORETURN",
    "SDL_RESTRICT",
    "SDL_UNUSED",
    "SDL_DECLSPEC",
    "SDL_ELF_NOTE_INTERNAL",
  ];
  const policies = names.map((cName) => ({
    cName,
    status: "intentional" as const,
    handling: "semantic" as const,
    reason: "fixture policy",
    evidence: [{
      kind: "policy" as const,
      source: cName,
      targets: ["x86_64-linux-gnu"],
      detail: "fixture",
    }],
  }));
  const audit = auditCoveragePolicies(model, policies);
  const consumed = new Map(audit.map((item) => [item.cName, item]));
  for (const name of names.slice(0, -1)) {
    assertEquals(consumed.get(name)?.disposition, "consumed");
    assert((consumed.get(name)?.applications ?? 0) > 0);
  }
  assertEquals(consumed.get("SDL_ELF_NOTE_INTERNAL")?.applications, 0);
  assertEquals(consumed.get("SDL_ELF_NOTE_INTERNAL")?.disposition, "rejected");
  assert(consumed.get("SDL_ELF_NOTE_INTERNAL")?.detail.includes("explicitly rejected"));
  const threadAudit = auditCoveragePolicies(model, [{
    cName: "SDL_BeginThreadFunction",
    status: "intentional",
    handling: "indirect",
    reason: "thread hook is consumed by create-thread wrappers",
    evidence: [{
      kind: "wrapper",
      source: "SDL_BeginThreadFunction",
      targets: ["x86_64-linux-gnu"],
      detail: "fixture",
    }],
  }]);
  assertEquals(threadAudit[0].disposition, "consumed");
  assert(threadAudit[0].detail.includes("thread-creation wrapper"));

  const coverage = collectLibraryCoverage(
    { ...model, functionMacros: names.map((name) => ({ name, parameters: [], replacement: "0" })) },
    { ...profile, coveragePolicies: policies },
    [],
    "SDL3/SDL.h",
  );
  const formatEntry = coverage.entries.find((entry) => entry.cName === "SDL_PRINTF_VARARG_FUNC");
  assert(formatEntry?.evidence[0].detail.includes("typed declaration application"));
  assertEquals(
    coverage.entries.filter((entry) => entry.status === "intentional").length,
    names.length,
  );
  const report = renderCoverageReport([coverage]);
  assert(report.includes("## Policy reconciliation"));
  assert(report.includes("| Pattern | `SDL_ELF_NOTE_INTERNAL` | 0 | rejected |"));
});
