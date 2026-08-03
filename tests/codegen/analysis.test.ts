import { assertEquals } from "@std/assert";
import { type ApiModel, mergeApiModels, type XmlAstNode } from "../../scripts/codegen/analysis.ts";

function node(id: string, name: string, location: string, order: number): XmlAstNode {
  return {
    id,
    kind: "Function",
    attributes: { name, location },
    members: [],
    order,
  };
}

function model(
  target: string,
  nodes: XmlAstNode[],
  constants: ApiModel["constants"],
): ApiModel {
  return {
    target,
    analysisTargets: [target],
    apiPrefixes: ["PATTERN_"],
    nodes,
    publicNodeIds: nodes.map(({ id }) => id),
    locations: Object.fromEntries(nodes.map(({ attributes }, index) => [
      attributes.location,
      { file: "include/pattern.h", line: index + 1 },
    ])),
    files: {},
    documentation: [],
    headerDocumentation: [],
    constants,
    publicNodeTargets: Object.fromEntries(nodes.map(({ id }) => [id, [target]])),
    constantTargets: Object.fromEntries(constants.map((constant) => [
      `${constant.source}:${constant.name}`,
      [target],
    ])),
  };
}

Deno.test("target merging preserves declarations and constants with their availability", () => {
  const linux = model(
    "x86_64-linux-gnu",
    [node("shared-linux", "PATTERN_Shared", "shared", 0)],
    [{ name: "PATTERN_SHARED", value: "1", source: "macro" }],
  );
  const macos = model(
    "aarch64-macos",
    [
      node("shared-macos", "PATTERN_Shared", "shared", 0),
      node("macos-only", "PATTERN_MacosOnly", "macos-only", 1),
    ],
    [
      { name: "PATTERN_SHARED", value: "1", source: "macro" },
      { name: "PATTERN_MACOS_ONLY", value: "2", source: "macro" },
    ],
  );

  const merged = mergeApiModels([linux, macos]);
  const shared = merged.nodes.find((candidate) => candidate.attributes.name === "PATTERN_Shared");
  const macosOnly = merged.nodes.find((candidate) =>
    candidate.attributes.name === "PATTERN_MacosOnly"
  );

  assertEquals(merged.analysisTargets, ["x86_64-linux-gnu", "aarch64-macos"]);
  assertEquals(shared === undefined, false);
  assertEquals(macosOnly === undefined, false);
  assertEquals(merged.publicNodeTargets[shared!.id], ["x86_64-linux-gnu", "aarch64-macos"]);
  assertEquals(merged.publicNodeTargets[macosOnly!.id], ["aarch64-macos"]);
  assertEquals(merged.constantTargets["macro:PATTERN_SHARED"], [
    "x86_64-linux-gnu",
    "aarch64-macos",
  ]);
  assertEquals(merged.constantTargets["macro:PATTERN_MACOS_ONLY"], ["aarch64-macos"]);
});
