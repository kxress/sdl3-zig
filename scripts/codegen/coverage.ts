import { dirname } from "@std/path";
import type { ApiModel, XmlAstNode } from "./analysis.ts";
import type {
  CoverageEvidence,
  CoverageExclusion,
  CoverageHandling,
  CoveragePolicy,
  LibraryProfile,
  PublicSymbol,
} from "./profile.ts";

export type CoverageApplicationDisposition = "consumed" | "rejected";

/**
 * Generator-owned reconciliation for one configured intentional policy.
 *
 * `applications` counts normalized declaration contracts, not Clang node IDs. A
 * zero count is still an explicit rejection: the pinned headers did not expose
 * an application that can be consumed by this generator.
 */
export interface CoveragePolicyAudit {
  cName: string;
  applications: number;
  disposition: CoverageApplicationDisposition;
  detail: string;
}

export type CoverageStatus = "covered" | "intentional" | "limitation";

export interface CoverageEntry {
  cName: string;
  kind: string;
  status: CoverageStatus;
  reason?: string;
  handling: CoverageHandling;
  evidence: CoverageEvidence[];
  targets: string[];
}

export interface LibraryCoverage {
  moduleName: string;
  displayName: string;
  sourceLabel: string;
  targets: string[];
  entries: CoverageEntry[];
  policyAudit?: CoveragePolicyAudit[];
  /** Typed format applications observed while analyzing this library. */
  formatApplications?: Readonly<Record<string, number>>;
}

export function collectLibraryCoverage(
  model: ApiModel,
  profile: LibraryProfile,
  symbols: PublicSymbol[],
  sourceLabel: string,
  coverageNames: ReadonlySet<string> = new Set(symbols.map((symbol) => symbol.cName)),
): LibraryCoverage {
  validateCoveragePolicies(model, profile);
  const emitted = coverageNames;
  const entries = new Map<string, CoverageEntry>();
  const formatEvidence = formatApplicationEvidence(model);
  const policyAudit = auditCoveragePolicies(model, profile.coveragePolicies);
  const policyEvidence = new Map(
    policyAudit.map((item) => [item.cName, item.detail]),
  );

  for (const node of model.nodes) {
    if (!model.publicNodeIds.includes(node.id) || !node.attributes.name) continue;
    addEntry(
      entries,
      node.attributes.name,
      declarationKind(node),
      model.publicNodeTargets[node.id] ?? model.analysisTargets,
      emitted,
      profile.coverageExclusions,
      profile.coveragePolicies,
      formatEvidence,
      policyEvidence,
    );
  }
  for (const constant of model.constants) {
    addEntry(
      entries,
      constant.name,
      constant.source === "enum" ? "enum_constant" : "constant",
      model.constantTargets[constantIdentity(constant)] ?? model.analysisTargets,
      emitted,
      profile.coverageExclusions,
      profile.coveragePolicies,
      formatEvidence,
      policyEvidence,
    );
  }
  for (const macro of model.functionMacros ?? []) {
    addEntry(
      entries,
      macro.name,
      "function_macro",
      model.functionMacroTargets?.[macro.name] ?? model.analysisTargets,
      emitted,
      profile.coverageExclusions,
      profile.coveragePolicies,
      formatEvidence,
      policyEvidence,
    );
  }
  for (const macro of model.objectMacros ?? []) {
    addEntry(
      entries,
      macro.name,
      "object_macro",
      model.analysisTargets,
      emitted,
      profile.coverageExclusions,
      profile.coveragePolicies,
      formatEvidence,
      policyEvidence,
    );
  }
  for (const alias of profile.macroTypeAliases ?? []) {
    addEntry(
      entries,
      alias.name,
      "type_macro",
      model.analysisTargets,
      emitted,
      profile.coverageExclusions,
      profile.coveragePolicies,
      formatEvidence,
      policyEvidence,
    );
  }

  return {
    moduleName: profile.moduleName,
    displayName: profile.displayName,
    sourceLabel,
    targets: [...model.analysisTargets].sort(),
    entries: [...entries.values()].sort(compareEntries),
    policyAudit,
    formatApplications: Object.fromEntries(formatApplicationCounts(model)),
  };
}

function addEntry(
  entries: Map<string, CoverageEntry>,
  cName: string,
  kind: string,
  targets: string[],
  emitted: ReadonlySet<string>,
  exclusions: CoverageExclusion[] | undefined,
  policies: CoveragePolicy[] | undefined,
  formatEvidence: ReadonlyMap<string, string>,
  policyEvidence: ReadonlyMap<string, string>,
): void {
  const key = `${kind}:${cName}`;
  if (entries.has(key)) return;
  const policy = policies?.find((candidate) => candidate.cName === cName);
  const exclusion = policy ?? exclusions?.find((candidate) => candidate.names.includes(cName));
  const status: CoverageStatus = emitted.has(cName)
    ? "covered"
    : exclusion
    ? "intentional"
    : "limitation";
  const uniqueTargets = [...new Set(targets)].sort();
  const handling = status === "covered"
    ? "direct"
    : policy
    ? policy.handling
    : exclusion
    ? exclusionHandling(cName)
    : "unrepresentable";
  const evidence = status === "covered"
    ? [{
      kind: "generated" as const,
      source: cName,
      targets: uniqueTargets,
      detail: "A public Zig declaration is emitted for this analyzed entry.",
    }]
    : policy
    ? policy.evidence.map((item) => ({
      ...item,
      targets: uniqueTargets,
      detail: policyEvidence.get(cName) ?? formatEvidence.get(cName) ?? item.detail,
    }))
    : [
      exclusionEvidence(
        cName,
        handling,
        uniqueTargets,
        exclusion && "names" in exclusion ? exclusion : undefined,
      ),
    ];
  entries.set(key, {
    cName,
    kind,
    status,
    reason: status === "covered" ? undefined : exclusion?.reason ?? limitationReason(kind),
    handling,
    evidence,
    targets: uniqueTargets,
  });
}

function formatApplicationEvidence(model: ApiModel): ReadonlyMap<string, string> {
  const counts = formatApplicationCounts(model);
  return new Map(
    [...counts].map(([macro, count]) => [
      macro,
      `Application inventory: ${count} typed declaration application(s); consumption: ` +
      "FormatContract-driven Zig wrapper planning and validation.",
    ]),
  );
}

function formatApplicationCounts(model: ApiModel): ReadonlyMap<string, number> {
  const counts = new Map<string, number>();
  for (const semantics of Object.values(model.declarationSemantics ?? {})) {
    const format = semantics.format;
    if (!format) continue;
    const suffix = format.firstVariadicParameter === "va_list" ? "V" : "";
    const macro = `SDL_${format.dialect.toUpperCase()}_VARARG_FUNC${suffix}`;
    counts.set(macro, (counts.get(macro) ?? 0) + 1);
  }
  return counts;
}

/**
 * Reconcile normalized declaration contracts with the configured macro policies.
 *
 * Clang's supplemental JSON intentionally gives us declaration semantics rather
 * than process-local attribute nodes. This mapping is therefore kept in one
 * typed place and counts each declaration once for each distinct SDL contract it
 * carries. Policies without a matching application are explicitly rejected by
 * the pinned input inventory; they are not silently treated as orphaned.
 */
export function auditCoveragePolicies(
  model: ApiModel,
  policies: CoveragePolicy[] | undefined,
): CoveragePolicyAudit[] {
  if (!policies || policies.length === 0) return [];
  const configured = new Set(policies.map((policy) => policy.cName));
  const counts = new Map<string, number>();
  const increment = (cName: string): void => {
    if (configured.has(cName)) counts.set(cName, (counts.get(cName) ?? 0) + 1);
  };

  for (const semantics of Object.values(model.declarationSemantics ?? {})) {
    if (semantics.format) {
      const suffix = semantics.format.firstVariadicParameter === "va_list" ? "V" : "";
      increment(`SDL_${semantics.format.dialect.toUpperCase()}_VARARG_FUNC${suffix}`);
    }
    if (semantics.allocationSize) {
      increment(
        semantics.allocationSize.parameters.length > 1 ? "SDL_ALLOC_SIZE2" : "SDL_ALLOC_SIZE",
      );
    }
    if (semantics.alignment !== undefined) increment("SDL_ALIGNED");
    if (semantics.mallocLike) increment("SDL_MALLOC");
    if (semantics.deprecated) increment("SDL_DEPRECATED");
    if (semantics.fallthrough) increment("SDL_FALLTHROUGH");
    if (semantics.inline === "always") increment("SDL_FORCE_INLINE");
    if (semantics.inline === "hint") increment("SDL_INLINE");
    if (semantics.resultUse === "should_use") increment("SDL_NODISCARD");
    if (semantics.returnFlow === "no_return") increment("SDL_NORETURN");
    if (semantics.returnFlow === "analyzer_no_return") increment("SDL_ANALYZER_NORETURN");
    if (semantics.restrict) increment("SDL_RESTRICT");
    if (semantics.unused) increment("SDL_UNUSED");
    if (semantics.linkage !== "default") increment("SDL_DECLSPEC");
  }

  return policies.map((policy) => {
    const applications = counts.get(policy.cName) ?? 0;
    if (policy.handling === "indirect") {
      return {
        cName: policy.cName,
        applications,
        disposition: "consumed" as const,
        detail: `Application inventory: ${applications} declaration application(s); ` +
          "consumption: generated thread-creation wrapper forwarding; no standalone hook name " +
          "is emitted.",
      };
    }
    if (applications > 0) {
      const applicationKind = isFormatPolicy(policy.cName) ? "typed" : "normalized";
      return {
        cName: policy.cName,
        applications,
        disposition: "consumed" as const,
        detail:
          `Application inventory: ${applications} ${applicationKind} declaration application(s); ` +
          `consumption: ${policyConsumption(policy.cName)}.`,
      };
    }
    return {
      cName: policy.cName,
      applications: 0,
      disposition: "rejected" as const,
      detail: `Application inventory: 0 normalized declaration applications; ` +
        `consumption: explicitly rejected — ${policy.reason}`,
    };
  });
}

function isFormatPolicy(cName: string): boolean {
  return cName.startsWith("SDL_PRINTF_VARARG_FUNC") ||
    cName.startsWith("SDL_SCANF_VARARG_FUNC");
}

function policyConsumption(cName: string): string {
  if (
    cName.startsWith("SDL_PRINTF_VARARG_FUNC") ||
    cName.startsWith("SDL_SCANF_VARARG_FUNC")
  ) {
    return "FormatContract-driven wrapper planning and validation";
  }
  if (cName === "SDL_ALLOC_SIZE" || cName === "SDL_ALLOC_SIZE2") {
    return "normalized allocation-size validation and allocator return planning";
  }
  if (cName === "SDL_MALLOC" || cName === "SDL_ALIGNED" || cName === "SDL_RESTRICT") {
    return "normalized allocator/alias metadata validation";
  }
  if (cName === "SDL_NORETURN" || cName === "SDL_ANALYZER_NORETURN") {
    return "normalized return-flow documentation and planning";
  }
  if (cName === "SDL_DECLSPEC") return "normalized linkage selection";
  return "normalized declaration metadata and validation";
}

function validateCoveragePolicies(model: ApiModel, profile: LibraryProfile): void {
  const policies = profile.coveragePolicies;
  if (!policies) return;
  const known = new Set<string>([
    ...model.nodes.map((node) => node.attributes.name).filter((name): name is string => !!name),
    ...model.constants.map((constant) => constant.name),
    ...(model.functionMacros ?? []).map((macro) => macro.name),
    ...(model.objectMacros ?? []).map((macro) => macro.name),
    ...(profile.macroTypeAliases ?? []).map((alias) => alias.name),
  ]);
  const seen = new Set<string>();
  for (const policy of policies) {
    if (seen.has(policy.cName)) throw new Error(`duplicate coverage policy: ${policy.cName}`);
    seen.add(policy.cName);
    if (!known.has(policy.cName)) throw new Error(`unknown coverage policy: ${policy.cName}`);
    if (policy.status === "limitation" && policy.reason.trim().length === 0) {
      throw new Error(`coverage limitation is missing a reason: ${policy.cName}`);
    }
    if (policy.evidence.length === 0) {
      throw new Error(`coverage policy has no evidence: ${policy.cName}`);
    }
    for (const evidence of policy.evidence) {
      if (evidence.source !== policy.cName) {
        throw new Error(`stale coverage evidence endpoint: ${policy.cName} -> ${evidence.source}`);
      }
      if (evidence.targets.length === 0) {
        throw new Error(`coverage evidence has no targets: ${policy.cName}`);
      }
    }
  }
}

function exclusionHandling(cName: string): CoverageHandling {
  if (cName === "SDL_BeginThreadFunction" || cName === "SDL_EndThreadFunction") {
    return "indirect";
  }
  if (
    cName === "SDL_PRINTF_VARARG_FUNC" || cName === "SDL_PRINTF_VARARG_FUNCV" ||
    cName === "SDL_SCANF_VARARG_FUNC" || cName === "SDL_SCANF_VARARG_FUNCV"
  ) return "semantic";
  if (
    cName.startsWith("SDL_assert") || cName === "SDL_enabled_assert" ||
    cName === "SDL_disabled_assert"
  ) {
    return "additive";
  }
  if (
    cName === "SDL_ANALYZER_NORETURN" || cName === "SDL_DECLSPEC" ||
    cName === "SDL_DEPRECATED" || cName === "SDL_FALLTHROUGH" ||
    cName === "SDL_FORCE_INLINE" || cName === "SDL_INLINE" ||
    cName === "SDL_NODISCARD" || cName === "SDL_NORETURN" ||
    cName === "SDL_RESTRICT" || cName === "SDL_UNUSED"
  ) return "semantic";
  return "unrepresentable";
}

function exclusionEvidence(
  cName: string,
  handling: CoverageHandling,
  targets: string[],
  exclusion: CoverageExclusion | undefined,
): CoverageEvidence {
  const kind = handling === "indirect"
    ? "wrapper"
    : handling === "semantic"
    ? "normalized_effect"
    : handling === "additive"
    ? "additive_facility"
    : "policy";
  const detail = handling === "indirect"
    ? "Application inventory: not observed; consumption: generated thread-creation wrappers; " +
      "no standalone hook name is emitted."
    : handling === "semantic"
    ? "Application inventory: not observed; consumption: generator policy/metadata rather than " +
      "a consumer-facing declaration."
    : handling === "additive"
    ? "Application inventory: not observed; consumption: reserved for the SDL-aware assertion " +
      "adapter disposition; the macro remains intentionally excluded."
    : "Application inventory: not observed; consumption: not applicable; " +
      (exclusion?.reason ??
        "No honest consumer-facing or generator operation exists for this entry.");
  return { kind, source: cName, targets, detail };
}

function declarationKind(node: XmlAstNode): string {
  switch (node.kind) {
    case "Enumeration":
      return "enum_type";
    case "Function":
      return "function";
    case "Struct":
      return "struct";
    case "Typedef":
      return "typedef";
    case "Union":
      return "union";
    case "Variable":
      return "variable";
    default:
      return node.kind.toLowerCase();
  }
}

function limitationReason(kind: string): string {
  if (kind.endsWith("macro") || kind === "constant" || kind === "enum_constant") {
    return "The macro/constant renderer has no rule for this analyzed replacement or value.";
  }
  if (kind === "function") {
    return "The function planner or renderer has no supported public binding for this signature.";
  }
  if (kind === "variable") {
    return "The public variable renderer has no supported binding for this declaration.";
  }
  return "The public type renderer has no supported binding for this declaration shape.";
}

function constantIdentity(constant: { name: string; source: string }): string {
  return `${constant.source}:${constant.name}`;
}

function compareEntries(left: CoverageEntry, right: CoverageEntry): number {
  return left.cName.localeCompare(right.cName) || left.kind.localeCompare(right.kind);
}

export async function writeCoverageReport(
  output: string,
  libraries: LibraryCoverage[],
): Promise<void> {
  const outputDirectory = dirname(output);
  if (outputDirectory !== ".") await Deno.mkdir(outputDirectory, { recursive: true });
  await Deno.writeTextFile(output, renderCoverageReport(libraries));
}

export function renderCoverageReport(libraries: LibraryCoverage[]): string {
  const sortedLibraries = [...libraries].sort((left, right) =>
    left.moduleName.localeCompare(right.moduleName)
  );
  const allEntries = sortedLibraries.flatMap((library) =>
    library.entries.map((entry) => ({ library, entry }))
  );
  const formatApplications = new Map<string, number>();
  for (const library of sortedLibraries) {
    for (const [macro, count] of Object.entries(library.formatApplications ?? {})) {
      formatApplications.set(macro, (formatApplications.get(macro) ?? 0) + count);
    }
  }
  const lines = [
    "<!-- Generated by sdl-zig-codegen. Do not edit. -->",
    "",
    "# SDL binding coverage",
    "",
    "This report is generated from the configured SDL headers, target matrix, analyzed public " +
    "declarations, and symbols emitted by the binding generator.",
    "",
    "The inventory covers the generator's semantic Zig surface: public declarations and " +
    "configured public macros recognized by the analysis pass. The raw C import remains " +
    "available through each module's `c` declaration and is not counted as a generated Zig " +
    "binding.",
    "",
    "An intentional exclusion does not mean that no approximation is possible. It means that " +
    "the generator does not claim a faithful standalone Zig binding for the C entry: an " +
    "approximation may lose compile-time elimination, caller source information, target-specific " +
    "behavior, static-analysis meaning, ownership, or linker effects. Such entries may still be " +
    "available through the module's raw `c` import when the C translation exposes them, or may be " +
    "covered by a higher-level Zig API without counting the macro itself as covered.",
    "",
    "Coverage is reported two ways: **surface coverage** includes every analyzed API entry, while " +
    "**supported-scope coverage** removes entries explicitly excluded by generator policy from " +
    "the denominator. Every entry not emitted is listed below as either intentional or a " +
    "generator limitation.",
    "",
    "## Summary",
    "",
    "| Library | API entries | Covered | Intentional | Limitations | Surface coverage | Supported-scope coverage |",
    "| --- | ---: | ---: | ---: | ---: | ---: | ---: |",
    ...sortedLibraries.map((library) => summaryRow(library)),
    summaryRow({
      moduleName: "overall",
      displayName: "Overall",
      sourceLabel: "",
      targets: [],
      entries: allEntries.map(({ entry }) => entry),
    }),
    "",
    "## Scope",
    "",
    ...sortedLibraries.flatMap((library) => [
      `- **${library.displayName}** (` +
      `\`${library.moduleName}\`): ${library.sourceLabel}; targets: ` +
      `${library.targets.map((target) => `\`${target}\``).join(", ")}.`,
    ]),
    "",
    "## Intentional exclusions",
    "",
    "These entries are omitted by explicit profile policy because they are compiler annotations, " +
    "preprocessor/build-time machinery, debugger behavior, or another non-portable C concern " +
    "rather than consumer-facing runtime bindings.",
    "",
    ...renderEntries(
      allEntries.filter(({ entry }) => entry.status === "intentional"),
      formatApplications,
    ),
    "",
    "## Policy reconciliation",
    "",
    "Every configured intentional policy has one generator-owned relation. A relation with one " +
    "or more normalized declaration applications is marked **consumed**; a zero-application " +
    "compiler/preprocessor contract is marked **rejected** with its explicit reason.",
    "",
    ...renderPolicyAudit(sortedLibraries),
    "",
    "## Generator limitations",
    "",
    "This is the exhaustive difference between the analyzed API inventory and emitted symbols " +
    "after intentional exclusions. Each row is an analyzed public entry that the current " +
    "generator does not handle.",
    "",
    ...renderEntries(
      allEntries.filter(({ entry }) => entry.status === "limitation"),
      formatApplications,
    ),
    "",
  ];
  return lines.join("\n");
}

function renderPolicyAudit(libraries: LibraryCoverage[]): string[] {
  const rows = libraries.flatMap((library) =>
    (library.policyAudit ?? []).map((audit) => ({ library, audit }))
  );
  if (rows.length === 0) return ["No configured policy relations."];
  return [
    "| Library | Policy | Applications | Disposition | Detail |",
    "| --- | --- | ---: | --- | --- |",
    ...rows
      .sort((left, right) =>
        left.library.moduleName.localeCompare(right.library.moduleName) ||
        left.audit.cName.localeCompare(right.audit.cName)
      )
      .map(({ library, audit }) =>
        `| ${library.displayName} | \`${audit.cName}\` | ${audit.applications} | ` +
        `${audit.disposition} | ${escapeTableCell(audit.detail)} |`
      ),
  ];
}

function renderEntries(
  entries: Array<{ library: LibraryCoverage; entry: CoverageEntry }>,
  formatApplications: ReadonlyMap<string, number> = new Map(),
): string[] {
  if (entries.length === 0) return ["No entries."];
  return [
    "| Library | C API entry | Kind | Status | Handling | Targets | Evidence | Reason |",
    "| --- | --- | --- | --- | --- | --- | --- | --- |",
    ...entries
      .sort((left, right) =>
        left.library.moduleName.localeCompare(right.library.moduleName) ||
        compareEntries(left.entry, right.entry)
      )
      .map(({ library, entry }) =>
        `| ${library.displayName} | \`${entry.cName}\` | ${entry.kind} | ${entry.status} | ` +
        `${entry.handling} | ${entry.targets.map((target) => `\`${target}\``).join(", ")} | ` +
        `${escapeTableCell(renderEvidence(entry.evidence, formatApplications))} | ` +
        `${escapeTableCell(entry.reason ?? "")} |`
      ),
  ];
}

function renderEvidence(
  evidence: CoverageEvidence[],
  formatApplications: ReadonlyMap<string, number>,
): string {
  return evidence.map((item) => {
    const count = formatApplications.get(item.source);
    const detail = count === undefined ? item.detail : item.detail.replace(
      /Application inventory: \d+ typed declaration application\(s\)/,
      `Application inventory: ${count} typed declaration application(s)`,
    );
    return `${item.kind}: ${item.source} — ${detail}`;
  }).join("; ");
}

function summaryRow(library: LibraryCoverage): string {
  const counts = summarize(library.entries);
  return `| ${library.displayName} | ${counts.total} | ${counts.covered} | ` +
    `${counts.intentional} | ${counts.limitations} | ` +
    `${percentage(counts.covered, counts.total)} | ` +
    `${percentage(counts.covered, counts.total - counts.intentional)} |`;
}

function summarize(entries: CoverageEntry[]): {
  total: number;
  covered: number;
  intentional: number;
  limitations: number;
} {
  return {
    total: entries.length,
    covered: entries.filter((entry) => entry.status === "covered").length,
    intentional: entries.filter((entry) => entry.status === "intentional").length,
    limitations: entries.filter((entry) => entry.status === "limitation").length,
  };
}

function percentage(numerator: number, denominator: number): string {
  return denominator === 0 ? "n/a" : `${((numerator / denominator) * 100).toFixed(2)}%`;
}

function escapeTableCell(value: string): string {
  return value.replaceAll("|", "\\|").replaceAll("\n", " ");
}
