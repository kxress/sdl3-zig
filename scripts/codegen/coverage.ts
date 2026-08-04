import { dirname } from "@std/path";
import type { ApiModel, XmlAstNode } from "./analysis.ts";
import type { CoverageExclusion, LibraryProfile, PublicSymbol } from "./profile.ts";

export type CoverageStatus = "covered" | "intentional" | "limitation";

export interface CoverageEntry {
  cName: string;
  kind: string;
  status: CoverageStatus;
  reason?: string;
  targets: string[];
}

export interface LibraryCoverage {
  moduleName: string;
  displayName: string;
  sourceLabel: string;
  targets: string[];
  entries: CoverageEntry[];
}

export function collectLibraryCoverage(
  model: ApiModel,
  profile: LibraryProfile,
  symbols: PublicSymbol[],
  sourceLabel: string,
  coverageNames: ReadonlySet<string> = new Set(symbols.map((symbol) => symbol.cName)),
): LibraryCoverage {
  const emitted = coverageNames;
  const entries = new Map<string, CoverageEntry>();

  for (const node of model.nodes) {
    if (!model.publicNodeIds.includes(node.id) || !node.attributes.name) continue;
    addEntry(
      entries,
      node.attributes.name,
      declarationKind(node),
      model.publicNodeTargets[node.id] ?? model.analysisTargets,
      emitted,
      profile.coverageExclusions,
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
    );
  }

  return {
    moduleName: profile.moduleName,
    displayName: profile.displayName,
    sourceLabel,
    targets: [...model.analysisTargets].sort(),
    entries: [...entries.values()].sort(compareEntries),
  };
}

function addEntry(
  entries: Map<string, CoverageEntry>,
  cName: string,
  kind: string,
  targets: string[],
  emitted: ReadonlySet<string>,
  exclusions: CoverageExclusion[] | undefined,
): void {
  const key = `${kind}:${cName}`;
  if (entries.has(key)) return;
  const exclusion = exclusions?.find((candidate) => candidate.names.includes(cName));
  const status: CoverageStatus = emitted.has(cName)
    ? "covered"
    : exclusion
    ? "intentional"
    : "limitation";
  entries.set(key, {
    cName,
    kind,
    status,
    reason: status === "covered" ? undefined : exclusion?.reason ?? limitationReason(kind),
    targets: [...new Set(targets)].sort(),
  });
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
    ...renderEntries(allEntries.filter(({ entry }) => entry.status === "intentional")),
    "",
    "## Generator limitations",
    "",
    "This is the exhaustive difference between the analyzed API inventory and emitted symbols " +
    "after intentional exclusions. Each row is an analyzed public entry that the current " +
    "generator does not handle.",
    "",
    ...renderEntries(allEntries.filter(({ entry }) => entry.status === "limitation")),
    "",
  ];
  return lines.join("\n");
}

function renderEntries(
  entries: Array<{ library: LibraryCoverage; entry: CoverageEntry }>,
): string[] {
  if (entries.length === 0) return ["No entries."];
  return [
    "| Library | C API entry | Kind | Targets | Reason |",
    "| --- | --- | --- | --- | --- |",
    ...entries
      .sort((left, right) =>
        left.library.moduleName.localeCompare(right.library.moduleName) ||
        compareEntries(left.entry, right.entry)
      )
      .map(({ library, entry }) =>
        `| ${library.displayName} | \`${entry.cName}\` | ${entry.kind} | ` +
        `${entry.targets.map((target) => `\`${target}\``).join(", ")} | ` +
        `${escapeTableCell(entry.reason ?? "")} |`
      ),
  ];
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
