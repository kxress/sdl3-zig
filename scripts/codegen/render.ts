import type { ApiModel, XmlAstNode } from "./analysis.ts";
import { appendDocumentationParagraph, renderDocComment } from "./documentation.ts";
import {
  type BorrowedSliceInfo,
  createFunctionPlan,
  type FailureMode,
  type FunctionPlan,
  type OutputResultMode,
  type OutputValue,
  type OwnedArrayInfo,
  type OwnedStringRecordInfo,
  type SliceRelationship,
} from "./function-plan.ts";
import { uniqueIdentifier, ZigNaming } from "./naming.ts";
import type { LibraryProfile, PublicApi, PublicReference, PublicSymbol } from "./profile.ts";

interface RenderContext {
  model: ApiModel;
  profile: LibraryProfile;
  dependencyApis: ReadonlyMap<string, PublicApi>;
  dependencySymbols: Map<string, { dependency: string; symbol: PublicSymbol }>;
  dependencyReferences: Map<string, PublicReference>;
  byId: Map<string, XmlAstNode>;
  publicIds: Set<string>;
  publicTypes: XmlAstNode[];
  publicFunctions: XmlAstNode[];
  publicVariables: XmlAstNode[];
  nodesByName: Map<string, XmlAstNode[]>;
  documentationByName: Map<string, ApiModel["documentation"]>;
  headerDocumentationByHeader: Map<string, ApiModel["headerDocumentation"][number]>;
  constantsByName: Map<string, ApiModel["constants"][number]>;
  rawTypeNames: Map<string, string>;
  publicTypeNames: Map<string, string>;
  naming: ZigNaming;
  renderedTypeIds: Set<string>;
  emittedNames: Map<string, string>;
  namespaceExports: Array<{ cName: string; publicName: string }>;
  literalDocumentationReferences: Set<string>;
  namespaceNames: Set<string>;
  reservedPublicNames?: Set<string>;
  documentationMembers: Map<string, DocumentationMember>;
  resources: Map<string, ResourceInfo>;
  destructorCNames: Set<string>;
  flags: Map<string, FlagInfo>;
  ownedStringRecords: Map<string, OwnedStringRecordInfo>;
  functionPlans: Map<string, FunctionPlan>;
  needsOwnedStringSupport: boolean;
}

interface ResourceInfo {
  lifecycle: LifecycleOperation[];
  parentRecordId?: string;
}

interface DocumentationMember {
  ownerCName: string;
  ownerPublicName: string;
  memberName: string;
}

type LifecycleResult = "void" | "bool_error" | "negative_error" | "status_output" | "value";

interface LifecycleOperation {
  nodeId: string;
  cName: string;
  methodName: "deinit" | "close" | "wait" | "detach";
  handleArgumentIndex: number;
  parentArgumentIndex?: number;
  statusArgumentIndex?: number;
  result: LifecycleResult;
  invalidate: "always" | "success";
}

interface RenderedParameters {
  declarations: string[];
  callArguments: string[];
}

interface VisibleFunctionParameters {
  arguments: Array<{ name: string; type: string }>;
  indexes: number[];
  names: string[];
  rendered: RenderedParameters;
}

interface SliceElementInfo {
  elementType: string;
  isConst: boolean;
  byteLike: boolean;
}

interface FlagInfo {
  bits: number;
  backingType: string;
  constants: Array<{ name: string; value: bigint }>;
  prefix: string;
}

export function renderSemanticBindings(
  model: ApiModel,
  profile: LibraryProfile,
  dependencyApis: ReadonlyMap<string, PublicApi>,
): { source: string; symbols: PublicSymbol[] } {
  const context = createContext(model, profile, dependencyApis);
  const source = renderPublicBindings(context);
  return {
    source,
    symbols: collectPublicSymbols(context),
  };
}

function createContext(
  model: ApiModel,
  profile: LibraryProfile,
  dependencyApis: ReadonlyMap<string, PublicApi>,
): RenderContext {
  const naming = new ZigNaming([
    ...model.nodes.map((node) => node.attributes.name ?? ""),
    ...model.constants.map((constant) => constant.name),
  ], model.apiPrefixes);
  const byId = new Map(model.nodes.map((node) => [node.id, node]));
  const publicIds = new Set(model.publicNodeIds);
  const publicNodes = model.nodes.filter((node) => publicIds.has(node.id));
  const documentationByName = indexByName(
    model.documentation,
    (documentation) => documentation.name,
  );
  const headerDocumentationByHeader = new Map(
    model.headerDocumentation.map((documentation) => [documentation.header, documentation]),
  );
  const rawTypeNames = collectRawTypeNames(model, byId, publicIds);
  const publicTypeNames = collectPublicTypeNames(model.nodes, byId, rawTypeNames, naming);
  const dependencySymbols = indexDependencySymbols(profile, dependencyApis);
  resolveDependencyTypeNames(publicTypeNames, model.nodes, byId, publicIds, dependencySymbols);
  const resources = collectResources(model.nodes, byId, publicIds, naming, documentationByName);
  const destructorCNames = new Set(
    [...resources.values()].flatMap((resource) =>
      resource.lifecycle.map((operation) => operation.cName)
    ),
  );
  const context: RenderContext = {
    model,
    profile,
    dependencyApis,
    dependencySymbols,
    dependencyReferences: indexDependencyReferences(profile, dependencyApis),
    byId,
    publicIds,
    publicTypes: publicNodes.filter((node) =>
      (
        node.kind === "Struct" || node.kind === "Union" || node.kind === "Enumeration" ||
        node.kind === "Typedef"
      ) && rawTypeNames.has(node.id)
    ),
    publicFunctions: publicNodes.filter((node) => node.kind === "Function"),
    publicVariables: publicNodes.filter((node) => node.kind === "Variable"),
    nodesByName: indexByName(model.nodes, (node) => node.attributes.name),
    documentationByName,
    headerDocumentationByHeader,
    constantsByName: new Map(model.constants.map((constant) => [constant.name, constant])),
    rawTypeNames,
    publicTypeNames,
    naming,
    renderedTypeIds: new Set(),
    emittedNames: new Map(),
    namespaceExports: [],
    literalDocumentationReferences: new Set(),
    namespaceNames: new Set(),
    documentationMembers: new Map(),
    resources,
    destructorCNames,
    flags: collectFlagTypes(model, byId, publicIds, naming),
    ownedStringRecords: new Map(),
    functionPlans: new Map(),
    needsOwnedStringSupport: false,
  };
  validatePublicSignatures(context);
  context.ownedStringRecords = collectOwnedStringRecords(context);
  context.functionPlans = new Map(
    context.publicFunctions.map((node) => [node.id, planFunction(node, context)]),
  );
  context.needsOwnedStringSupport = [...context.functionPlans.values()].some((plan) =>
    plan.ownedArray?.kind === "strings" || plan.ownedArray?.kind === "string_records"
  );
  return context;
}

function resolveDependencyTypeNames(
  publicTypeNames: Map<string, string>,
  nodes: XmlAstNode[],
  byId: Map<string, XmlAstNode>,
  publicIds: Set<string>,
  dependencySymbols: ReadonlyMap<string, { dependency: string; symbol: PublicSymbol }>,
): void {
  for (const node of nodes) {
    const cName = node.attributes.name;
    if (publicIds.has(node.id) || !cName) continue;
    const dependency = dependencySymbols.get(cName);
    if (!dependency || !isTypeSymbolKind(dependency.symbol.kind)) continue;
    const publicPath = `${dependency.dependency}.${dependency.symbol.path}`;
    publicTypeNames.set(node.id, publicPath);
    let target = node.attributes.type ? byId.get(node.attributes.type) : undefined;
    while (
      target?.kind === "Typedef" || target?.kind === "CvQualifiedType" ||
      target?.kind === "ElaboratedType"
    ) {
      publicTypeNames.set(target.id, publicPath);
      target = target.attributes.type ? byId.get(target.attributes.type) : undefined;
    }
    if (target && (target.kind === "Struct" || target.kind === "Union")) {
      publicTypeNames.set(target.id, publicPath);
    }
  }
}

function indexDependencySymbols(
  profile: LibraryProfile,
  dependencyApis: ReadonlyMap<string, PublicApi>,
): Map<string, { dependency: string; symbol: PublicSymbol }> {
  const symbols = new Map<string, { dependency: string; symbol: PublicSymbol }>();
  for (const dependency of profile.dependencies) {
    const api = dependencyApis.get(dependency);
    if (!api) throw new Error(`Missing public API for dependency ${dependency}`);
    for (const symbol of api.symbols) {
      if (!symbols.has(symbol.cName)) {
        symbols.set(symbol.cName, { dependency, symbol });
      }
    }
  }
  return symbols;
}

function indexDependencyReferences(
  profile: LibraryProfile,
  dependencyApis: ReadonlyMap<string, PublicApi>,
): Map<string, PublicReference> {
  const references = new Map<string, PublicReference>();
  for (const dependency of profile.dependencies) {
    for (const reference of dependencyApis.get(dependency)?.references ?? []) {
      if (!references.has(reference.cName)) references.set(reference.cName, reference);
    }
  }
  return references;
}

function isTypeSymbolKind(kind: string): boolean {
  return kind === "enumeration" || kind === "struct" || kind === "typedef" || kind === "union";
}

function validatePublicSignatures(context: RenderContext): void {
  for (const node of context.publicTypes) {
    const name = node.attributes.name ?? context.rawTypeNames.get(node.id) ?? node.id;
    validateSignatureType(node.id, `type ${name}`, true, context, new Set());
  }
  for (const node of context.publicVariables) {
    const name = node.attributes.name;
    const type = node.attributes.type;
    if (!name || !type) {
      throw unsupportedPublicSignature(
        `variable ${name || node.id}`,
        "missing a name or type",
      );
    }
    validateSignatureType(type, `variable ${name}`, false, context, new Set());
  }
  for (const node of context.publicFunctions) {
    const name = node.attributes.name;
    if (!name) {
      throw unsupportedPublicSignature(`function ${node.id}`, "missing a C name");
    }
    const returnId = functionReturnId(node, context);
    if (!returnId) {
      throw unsupportedPublicSignature(`function ${name} return`, "missing a return type");
    }
    validateSignatureType(returnId, `function ${name} return`, false, context, new Set());
    for (const argument of functionArguments(node, context)) {
      validateSignatureType(
        argument.type,
        `function ${name} parameter ${argument.name || "<unnamed>"}`,
        false,
        context,
        new Set(),
      );
    }
  }
}

function validateSignatureType(
  id: string,
  path: string,
  allowOpaqueRecord: boolean,
  context: RenderContext,
  seen: Set<string>,
): void {
  const key = `${id}:${allowOpaqueRecord ? "opaque" : "complete"}`;
  if (seen.has(key)) return;
  seen.add(key);
  const node = context.byId.get(id);
  if (!node) {
    throw unsupportedPublicSignature(path, `references missing CastXML type ${id}`);
  }

  switch (node.kind) {
    case "FundamentalType":
      if (!isSupportedFundamentalType(node.attributes.name)) {
        throw unsupportedPublicSignature(
          path,
          `uses unsupported fundamental type ${node.attributes.name || "<unnamed>"}`,
        );
      }
      return;
    case "Typedef":
    case "CvQualifiedType":
    case "ElaboratedType":
      if (!node.attributes.type) {
        throw unsupportedPublicSignature(path, `${node.kind} ${node.id} has no target type`);
      }
      validateSignatureType(
        node.attributes.type,
        path,
        allowOpaqueRecord,
        context,
        seen,
      );
      return;
    case "ReferenceType":
      throw unsupportedPublicSignature(path, "uses a C++ reference type");
    case "PointerType":
      if (!node.attributes.type) {
        throw unsupportedPublicSignature(path, `pointer ${node.id} has no pointee type`);
      }
      validateSignatureType(node.attributes.type, path, true, context, seen);
      return;
    case "ArrayType":
      if (!node.attributes.type) {
        throw unsupportedPublicSignature(path, `array ${node.id} has no element type`);
      }
      if (!hasSupportedArrayBounds(node)) {
        throw unsupportedPublicSignature(path, `array ${node.id} has unsupported bounds`);
      }
      validateSignatureType(node.attributes.type, path, false, context, seen);
      return;
    case "FunctionType": {
      const returnId = node.attributes.returns;
      if (!returnId) {
        throw unsupportedPublicSignature(path, `callback ${node.id} has no return type`);
      }
      validateSignatureType(returnId, `${path} callback return`, false, context, seen);
      for (const argument of callbackArguments(node, context)) {
        validateSignatureType(
          argument.type,
          `${path} callback parameter ${argument.name || "<unnamed>"}`,
          false,
          context,
          seen,
        );
      }
      return;
    }
    case "Struct":
    case "Union":
      if (isOpaqueRecord(node)) {
        if (!allowOpaqueRecord) {
          throw unsupportedPublicSignature(
            path,
            `uses incomplete ${node.kind.toLowerCase()} ${
              node.attributes.name || node.id
            } by value`,
          );
        }
        if (!context.publicTypeNames.has(node.id)) {
          throw unsupportedPublicSignature(
            path,
            `references incomplete ${node.kind.toLowerCase()} ${
              node.attributes.name || node.id
            } without a public type`,
          );
        }
        return;
      }
      for (const field of recordFields(node, context)) {
        const fieldName = field.attributes.name || `<field ${field.order}>`;
        if (isBitfield(field)) {
          throw unsupportedPublicSignature(
            `${path} field ${fieldName}`,
            "uses a C bitfield",
          );
        }
        if (!field.attributes.type) {
          throw unsupportedPublicSignature(
            `${path} field ${fieldName}`,
            "has no type",
          );
        }
        validateSignatureType(
          field.attributes.type,
          `${path} field ${fieldName}`,
          false,
          context,
          seen,
        );
      }
      return;
    case "Enumeration":
      return;
    default:
      throw unsupportedPublicSignature(path, `uses unsupported CastXML kind ${node.kind}`);
  }
}

function unsupportedPublicSignature(path: string, reason: string): Error {
  return new Error(`Unsupported public signature at ${path}: ${reason}`);
}

function hasSupportedArrayBounds(node: XmlAstNode): boolean {
  if (node.attributes.min === undefined || node.attributes.max === undefined) return false;
  const min = Number(node.attributes.min);
  const max = Number(node.attributes.max);
  return Number.isSafeInteger(min) && Number.isSafeInteger(max) && max >= min;
}

function isSupportedFundamentalType(rawName: string | undefined): boolean {
  const name = rawName?.toLowerCase().trim() ?? "";
  if (["void", "_bool", "bool", "float", "double", "long double"].includes(name)) {
    return true;
  }
  const words = name.split(/\s+/).filter(Boolean);
  if (words.length === 0) return false;
  const allowed = new Set(["signed", "unsigned", "char", "short", "int", "long"]);
  if (words.some((word) => !allowed.has(word))) return false;
  if (words.filter((word) => word === "signed").length > 1) return false;
  if (words.filter((word) => word === "unsigned").length > 1) return false;
  if (words.includes("signed") && words.includes("unsigned")) return false;
  if (words.filter((word) => word === "long").length > 2) return false;
  if (
    ["char", "short", "int"].some((word) =>
      words.filter((candidate) => candidate === word).length > 1
    )
  ) return false;
  if (words.includes("char") && words.some((word) => ["short", "int", "long"].includes(word))) {
    return false;
  }
  if (words.includes("short") && words.includes("long")) return false;
  return words.some((word) =>
    ["char", "short", "int", "long", "signed", "unsigned"].includes(word)
  );
}

function collectOwnedStringRecords(
  context: RenderContext,
): Map<string, OwnedStringRecordInfo> {
  const records = new Map<string, OwnedStringRecordInfo>();
  for (const node of context.publicFunctions) {
    const documentation = matchedDocumentation(node, context);
    if (!mentionsReleaseFunction(documentation?.comment ?? "", context)) continue;
    const outer = unwrapTransparentType(functionReturnId(node, context), context);
    if (outer?.kind !== "PointerType" || !outer.attributes.type) continue;
    const inner = unwrapTransparentType(outer.attributes.type, context);
    if (inner?.kind !== "PointerType" || !inner.attributes.type) continue;
    const record = unwrapTransparentType(inner.attributes.type, context);
    if (!record || (record.kind !== "Struct" && record.kind !== "Union")) continue;
    const info = ownedStringRecordInfo(record, context);
    if (info) records.set(record.id, info);
  }
  return records;
}

function ownedStringRecordInfo(
  record: XmlAstNode,
  context: RenderContext,
): OwnedStringRecordInfo | undefined {
  const sourceFields = recordFields(record, context);
  if (sourceFields.length === 0) return undefined;
  const usedFields = new Set<string>();
  let hasString = false;
  const fields: OwnedStringRecordInfo["fields"] = [];
  for (const [index, field] of sourceFields.entries()) {
    if (!field.attributes.type) return undefined;
    const sourceName = field.attributes.name || `field_${index}`;
    const publicName = uniqueIdentifier(context.naming.fieldName(sourceName), usedFields);
    if (isCharPointerType(field.attributes.type, context)) {
      hasString = true;
      fields.push({ kind: "string", sourceName, publicName });
      continue;
    }
    const unwrapped = unwrapTransparentType(field.attributes.type, context);
    if (unwrapped?.kind === "PointerType" && unwrapped.attributes.type) {
      const target = unwrapTransparentType(unwrapped.attributes.type, context);
      if (!target || !isOpaqueRecord(target)) return undefined;
    }
    fields.push({
      kind: "value",
      sourceName,
      publicName,
      typeId: field.attributes.type,
    });
  }
  if (!hasString) return undefined;
  const publicRecordName = context.publicTypeNames.get(record.id);
  if (!publicRecordName) return undefined;
  return {
    recordId: record.id,
    sourceCName: context.rawTypeNames.get(record.id) ?? record.attributes.name ?? record.id,
    valueName: `Owned${publicRecordName}`,
    collectionName: `Owned${publicRecordName}List`,
    fields,
  };
}

function collectFlagTypes(
  model: ApiModel,
  byId: Map<string, XmlAstNode>,
  publicIds: Set<string>,
  naming: ZigNaming,
): Map<string, FlagInfo> {
  const flags = new Map<string, FlagInfo>();
  for (const node of model.nodes) {
    const rawName = node.attributes.name;
    if (
      !publicIds.has(node.id) || node.kind !== "Typedef" || !rawName?.endsWith("Flags") ||
      !node.attributes.type
    ) continue;
    const fixed = fixedIntegerType(node.attributes.type, byId);
    if (!fixed) continue;
    const apiPrefix = model.apiPrefixes.find((prefix) => rawName.startsWith(prefix)) ??
      model.apiPrefixes[0];
    const withoutPrefix = rawName.startsWith(apiPrefix) ? rawName.slice(apiPrefix.length) : rawName;
    const baseWords = naming.words(withoutPrefix.replace(/Flags$/, ""));
    const prefix = `${apiPrefix}${baseWords.map((word) => word.toUpperCase()).join("_")}`;
    const constants = model.constants
      .filter((constant) => constant.source === "macro" && constant.name.startsWith(`${prefix}_`))
      .map((constant) => {
        try {
          return { name: constant.name, value: BigInt(normalizeInteger(constant.value)) };
        } catch {
          return undefined;
        }
      })
      .filter((constant): constant is { name: string; value: bigint } =>
        constant !== undefined && constant.value >= 0n
      );
    if (constants.some((constant) => isOneBit(constant.value))) {
      flags.set(node.id, {
        bits: fixed.bits,
        backingType: fixed.type,
        constants,
        prefix,
      });
    }
  }
  return flags;
}

function fixedIntegerType(
  id: string,
  byId: Map<string, XmlAstNode>,
): { bits: number; type: string } | undefined {
  let node = byId.get(id);
  while (node) {
    const match = node.attributes.name?.match(/^(U|S)int(8|16|32|64)$/);
    if (match) {
      const bits = Number(match[2]);
      return { bits, type: `${match[1] === "U" ? "u" : "i"}${bits}` };
    }
    if (
      node.kind !== "Typedef" && node.kind !== "CvQualifiedType" &&
      node.kind !== "ElaboratedType"
    ) return undefined;
    if (!node.attributes.type) return undefined;
    node = byId.get(node.attributes.type);
  }
  return undefined;
}

function isOneBit(value: bigint): boolean {
  return value > 0n && (value & (value - 1n)) === 0n;
}

function collectResources(
  nodes: XmlAstNode[],
  byId: Map<string, XmlAstNode>,
  publicIds: Set<string>,
  naming: ZigNaming,
  documentationByName: ReadonlyMap<string, ApiModel["documentation"]>,
): Map<string, ResourceInfo> {
  const resources = new Map<string, ResourceInfo>();
  for (const node of nodes) {
    if (!publicIds.has(node.id) || node.kind !== "Function") continue;
    const cName = node.attributes.name;
    if (!cName) continue;
    const words = naming.words(cName).filter((word) => word !== "sdl");
    const actionIndex = words.findIndex((word) =>
      ["destroy", "free", "close", "release", "unload", "wait", "detach"].includes(word)
    );
    if (actionIndex < 0) continue;
    const action = words[actionIndex];
    const identifyingWords = words.filter((_, index) => index !== actionIndex);
    if (identifyingWords.length === 0) continue;
    const argumentsList = functionArgumentNodes(node, byId);
    const candidates = argumentsList
      .map((argument, index) => ({
        index,
        record: opaqueRecordForArgument(argument, byId),
      }))
      .filter((candidate): candidate is { index: number; record: XmlAstNode } =>
        candidate.record !== undefined
      )
      .filter((candidate) => {
        const recordWords = naming.words(candidate.record.attributes.name ?? "")
          .filter((word) => word !== "sdl");
        return identifyingWords.every((word) => recordWords.includes(word));
      })
      .map((candidate) => ({
        ...candidate,
        extraWords: naming.words(candidate.record.attributes.name ?? "")
          .filter((word) => word !== "sdl" && !identifyingWords.includes(word)).length,
      }))
      .sort((left, right) => left.extraWords - right.extraWords);
    if (candidates.length === 0 || candidates[1]?.extraWords === candidates[0].extraWords) continue;
    const { index: handleArgumentIndex, record: child } = candidates[0];
    const recordWords = naming.words(child.attributes.name ?? "").filter((word) => word !== "sdl");
    const exactNameMatch = recordWords.length === identifyingWords.length &&
      recordWords.every((word, index) => word === identifyingWords[index]);
    const documentation = documentationByName.get(cName)?.find((item) =>
      item.kind === "function" && item.name === cName
    );
    const comment = documentation?.comment.toLowerCase().replace(/\s+/g, " ") ?? "";
    if (
      (!exactNameMatch || action === "wait" || action === "detach") &&
      !hasDestructiveLifecycleContract(comment)
    ) continue;

    const parentArgumentIndex = handleArgumentIndex === argumentsList.length - 1 &&
        argumentsList.length === 2 &&
        opaqueRecordForArgument(argumentsList[0], byId)
      ? 0
      : undefined;
    const parent = parentArgumentIndex === undefined
      ? undefined
      : opaqueRecordForArgument(argumentsList[parentArgumentIndex], byId);
    const statusArgumentIndex = action === "wait"
      ? lifecycleStatusArgumentIndex(argumentsList, handleArgumentIndex, byId)
      : undefined;
    const result = lifecycleResult(
      node,
      action,
      statusArgumentIndex,
      comment,
      byId,
    );
    const methodName = action === "close"
      ? "close"
      : action === "wait"
      ? "wait"
      : action === "detach"
      ? "detach"
      : "deinit";
    const operation: LifecycleOperation = {
      nodeId: node.id,
      cName,
      methodName,
      handleArgumentIndex,
      parentArgumentIndex,
      statusArgumentIndex,
      result,
      invalidate: lifecycleInvalidation(result, comment),
    };
    const existing = resources.get(child.id);
    if (existing?.lifecycle.some((item) => item.methodName === methodName)) {
      throw new Error(
        `Multiple '${methodName}' lifecycle operations found for ${
          child.attributes.name ?? child.id
        }`,
      );
    }
    if (
      existing?.parentRecordId && parent &&
      existing.parentRecordId !== parent.id
    ) {
      throw new Error(
        `Conflicting lifecycle parents found for ${child.attributes.name ?? child.id}`,
      );
    }
    resources.set(child.id, {
      lifecycle: [...(existing?.lifecycle ?? []), operation],
      parentRecordId: existing?.parentRecordId ?? parent?.id,
    });
  }
  collectParentCarrierResources(nodes, byId, publicIds, resources);
  return resources;
}

function hasDestructiveLifecycleContract(comment: string): boolean {
  return /\b(?:close(?:s|d)?|destroy(?:s|ed)?|free(?:s|d)?|unload(?:s|ed)?)\b/.test(comment) ||
    /\b(?:becomes? invalid|no longer valid|freed by this function|resource leak|clean(?:s|ed)? up|not safe to reference)\b/
      .test(comment);
}

function lifecycleStatusArgumentIndex(
  argumentsList: XmlAstNode[],
  handleArgumentIndex: number,
  byId: Map<string, XmlAstNode>,
): number | undefined {
  const candidates = argumentsList
    .map((argument, index) => ({ argument, index }))
    .filter(({ argument, index }) =>
      index !== handleArgumentIndex &&
      /^(?:status|result|exit_?code)$/i.test(argument.attributes.name ?? "") &&
      isPointerToSignedIntegerFromMap(argument.attributes.type, byId)
    );
  return candidates.length === 1 ? candidates[0].index : undefined;
}

function isPointerToSignedIntegerFromMap(
  id: string | undefined,
  byId: Map<string, XmlAstNode>,
): boolean {
  const target = pointedTypeFromMap(id, byId);
  const name = target?.attributes.name?.toLowerCase() ?? "";
  return target?.kind === "FundamentalType" &&
    /(?:char|short|int|long|ptrdiff_t)/.test(name) &&
    !name.includes("unsigned");
}

function lifecycleResult(
  node: XmlAstNode,
  action: string,
  statusArgumentIndex: number | undefined,
  comment: string,
  byId: Map<string, XmlAstNode>,
): LifecycleResult {
  if (action === "wait" && statusArgumentIndex !== undefined) return "status_output";
  const functionType = node.attributes.type ? byId.get(node.attributes.type) : undefined;
  const returnId = node.attributes.returns || functionType?.attributes.returns;
  const result = returnId ? unwrapTransparentTypeFromMap(returnId, byId) : undefined;
  const name = result?.attributes.name?.toLowerCase() ?? "";
  if (!returnId || (result?.kind === "FundamentalType" && name === "void")) return "void";
  if (result?.kind === "FundamentalType" && (name === "_bool" || name === "bool")) {
    return "bool_error";
  }
  if (
    result?.kind === "FundamentalType" &&
    /(?:char|short|int|long|ptrdiff_t)/.test(name) &&
    !name.includes("unsigned") &&
    /\bnegative\b.*\bfailure\b|\bnegative error code\b/.test(comment)
  ) {
    return "negative_error";
  }
  return "value";
}

function lifecycleInvalidation(
  result: LifecycleResult,
  comment: string,
): "always" | "success" {
  if (result === "void" || result === "status_output" || result === "value") return "always";
  if (
    /\bif\b[^.]*\breturns? false\b[^.]*\bsafe to\b[^.]*\b(?:again|retry)\b/.test(comment)
  ) return "success";
  if (
    /\bstill invalid\b|\bregardless of\b|\beven if\b[^.]*\b(?:error|fail)|\bfreed with no errors\b/
      .test(comment)
  ) return "always";
  return "success";
}

function opaqueRecordForArgument(
  argument: XmlAstNode | undefined,
  byId: Map<string, XmlAstNode>,
): XmlAstNode | undefined {
  if (!argument?.attributes.type) return undefined;
  const record = pointedTypeFromMap(argument.attributes.type, byId);
  return record && (record.kind === "Struct" || record.kind === "Union") &&
      isOpaqueRecord(record)
    ? record
    : undefined;
}

function returnedOpaqueRecord(
  node: XmlAstNode,
  byId: Map<string, XmlAstNode>,
): XmlAstNode | undefined {
  const functionType = node.attributes.type ? byId.get(node.attributes.type) : undefined;
  const returnId = node.attributes.returns || functionType?.attributes.returns;
  const record = pointedTypeFromMap(returnId, byId);
  return record && (record.kind === "Struct" || record.kind === "Union") &&
      isOpaqueRecord(record)
    ? record
    : undefined;
}

function collectParentCarrierResources(
  nodes: XmlAstNode[],
  byId: Map<string, XmlAstNode>,
  publicIds: Set<string>,
  resources: Map<string, ResourceInfo>,
): void {
  const functions = nodes.filter((node) => publicIds.has(node.id) && node.kind === "Function");
  let changed = true;
  while (changed) {
    changed = false;
    for (const functionNode of functions) {
      const returned = returnedOpaqueRecord(functionNode, byId);
      const returnedInfo = returned ? resources.get(returned.id) : undefined;
      const parentId = returnedInfo?.parentRecordId;
      if (!parentId) continue;
      for (const argument of functionArgumentNodes(functionNode, byId)) {
        const carrier = opaqueRecordForArgument(argument, byId);
        if (!carrier || carrier.id === parentId || resources.has(carrier.id)) continue;
        if (!recordIsProducedFromParent(carrier.id, parentId, functions, byId, resources)) {
          continue;
        }
        resources.set(carrier.id, { lifecycle: [], parentRecordId: parentId });
        changed = true;
      }
    }
  }
}

function recordIsProducedFromParent(
  recordId: string,
  parentId: string,
  functions: XmlAstNode[],
  byId: Map<string, XmlAstNode>,
  resources: Map<string, ResourceInfo>,
): boolean {
  return functions.some((functionNode) => {
    if (returnedOpaqueRecord(functionNode, byId)?.id !== recordId) return false;
    return functionArgumentNodes(functionNode, byId).some((argument) => {
      const argumentRecord = opaqueRecordForArgument(argument, byId);
      if (!argumentRecord) return false;
      return argumentRecord.id === parentId ||
        resources.get(argumentRecord.id)?.parentRecordId === parentId;
    });
  });
}

function functionArgumentNodes(
  node: XmlAstNode,
  byId: Map<string, XmlAstNode>,
): XmlAstNode[] {
  const functionType = node.attributes.type ? byId.get(node.attributes.type) : undefined;
  const argumentIds = splitIds(
    node.attributes.arguments || node.attributes.parameters || functionType?.attributes.arguments ||
      "",
  );
  const resolvedIds = argumentIds.length > 0
    ? argumentIds
    : node.members.length > 0
    ? node.members
    : functionType?.members ?? [];
  return resolvedIds
    .map((id) => byId.get(id))
    .filter((argument): argument is XmlAstNode =>
      argument?.kind === "Argument" || argument?.kind === "Parameter"
    )
    .sort((left, right) => left.order - right.order);
}

function unwrapTransparentTypeFromMap(
  id: string,
  byId: Map<string, XmlAstNode>,
): XmlAstNode | undefined {
  let node = byId.get(id);
  while (
    node?.kind === "Typedef" || node?.kind === "CvQualifiedType" ||
    node?.kind === "ElaboratedType" || node?.kind === "ReferenceType"
  ) {
    if (!node.attributes.type) return undefined;
    node = byId.get(node.attributes.type);
  }
  return node;
}

function pointedTypeFromMap(
  id: string | undefined,
  byId: Map<string, XmlAstNode>,
): XmlAstNode | undefined {
  if (!id) return undefined;
  const pointer = unwrapTransparentTypeFromMap(id, byId);
  return pointer?.kind === "PointerType" && pointer.attributes.type
    ? unwrapTransparentTypeFromMap(pointer.attributes.type, byId)
    : undefined;
}

function renderPublicBindings(context: RenderContext): string {
  const lines = [
    'const std = @import("std");',
    'const builtin = @import("builtin");',
    `const c = @import("${context.profile.abiImportName}");`,
    ...(context.needsOwnedStringSupport ? ['const support = @import("sdl3_support");'] : []),
    ...context.profile.dependencies.map((dependency) =>
      `const ${dependency} = @import("${dependency}");`
    ),
    "const root = @This();",
    "",
  ];
  renderError(context, lines);
  renderAllocator(context, lines);
  if (context.needsOwnedStringSupport) renderOwnedCollectionTypes(context, lines);

  for (const node of context.publicTypes) renderPublicTypeDeclaration(node, context, lines);

  const moduleNames = new Set(
    [...context.publicTypeNames.entries()]
      .filter(([id]) => !isPrimitiveTypedef(context.byId.get(id)))
      .map(([, name]) => name),
  );
  renderPublicConstants(context, lines, moduleNames);
  renderPublicVariables(context, lines, moduleNames);
  renderPublicFunctions(context, lines, moduleNames);
  privatizeNamespacedDeclarations(context, lines);
  renderNamespaces(context, lines);

  return resolveDocumentationReferences(finish(lines), context);
}

function renderError(context: RenderContext, lines: string[]): void {
  const errorProfile = context.profile.error;
  if (errorProfile.provider === "dependency") {
    return;
  }
  lines.push(
    `/// Failures reported by ${context.profile.displayName}'s documented failure sentinels.`,
    "pub const Error = error{",
    `    /// ${context.profile.displayName} reported that an operation failed.`,
    "    SdlFailure,",
    "    /// The requested allocation could not be created.",
    "    OutOfMemory,",
    "};",
    "",
  );
}

function errorType(context: RenderContext): string {
  const errorProfile = context.profile.error;
  return errorProfile.provider === "dependency"
    ? `${errorProfile.importName}.${errorProfile.publicPath}`
    : "Error";
}

function errorUnion(resultType: string, context: RenderContext): string {
  return `${errorType(context)}!${resultType}`;
}

function renderAllocator(context: RenderContext, lines: string[]): void {
  const allocator = context.profile.allocator;
  if (allocator.provider === "dependency") {
    return;
  }
  lines.push(
    `/// ${context.profile.displayName}-backed allocator. Over-aligned allocations use its aligned allocation API.`,
    "pub const allocator: std.mem.Allocator = .{",
    "    .ptr = @ptrCast(&allocator_state),",
    "    .vtable = &allocator_vtable,",
    "};",
    "",
    "var allocator_state: u8 = 0;",
    "const allocator_vtable: std.mem.Allocator.VTable = .{",
    "    .alloc = allocatorAlloc,",
    "    .resize = std.mem.Allocator.noResize,",
    "    .remap = allocatorRemap,",
    "    .free = allocatorFree,",
    "};",
    "",
    "fn allocatorAlloc(_: *anyopaque, len: usize, alignment: std.mem.Alignment, _: usize) ?[*]u8 {",
    "    const bytes = alignment.toByteUnits();",
    "    const pointer = if (bytes <= @alignOf(std.c.max_align_t))",
    `        c.${allocator.malloc}(len)`,
    "    else",
    `        c.${allocator.alignedAlloc}(bytes, len);`,
    "    return if (pointer) |value| @ptrCast(value) else null;",
    "}",
    "",
    "fn allocatorRemap(_: *anyopaque, allocation: []u8, alignment: std.mem.Alignment, new_len: usize, _: usize) ?[*]u8 {",
    "    if (alignment.toByteUnits() > @alignOf(std.c.max_align_t)) return null;",
    `    const pointer = c.${allocator.realloc}(allocation.ptr, new_len) orelse return null;`,
    "    return @ptrCast(pointer);",
    "}",
    "",
    "fn allocatorFree(_: *anyopaque, allocation: []u8, alignment: std.mem.Alignment, _: usize) void {",
    "    if (alignment.toByteUnits() <= @alignOf(std.c.max_align_t))",
    `        c.${allocator.free}(allocation.ptr)`,
    "    else",
    `        c.${allocator.alignedFree}(allocation.ptr);`,
    "}",
    "",
  );
}

function renderOwnedCollectionTypes(context: RenderContext, lines: string[]): void {
  lines.push(
    `/// Allocator-backed copies of ${context.profile.displayName} strings.`,
    "pub const OwnedStrings = struct {",
    "    /// Allocator that owns `items` and every string in it.",
    "    allocator: std.mem.Allocator,",
    "    /// Independently allocated, sentinel-terminated strings.",
    "    items: [][:0]u8,",
    "",
    "    /// Release every string and the outer slice, then invalidate this collection.",
    "    pub inline fn deinit(self: *@This()) void {",
    "        support.deinitOwnedStrings(self.allocator, self.items);",
    "        self.* = undefined;",
    "    }",
    "};",
    "",
  );
  for (
    const record of [...context.ownedStringRecords.values()].sort((left, right) =>
      left.valueName.localeCompare(right.valueName)
    )
  ) {
    renderOwnedStringRecordTypes(record, context, lines);
  }
}

function renderOwnedStringRecordTypes(
  record: OwnedStringRecordInfo,
  context: RenderContext,
  lines: string[],
): void {
  registerNamespaceExport(record.sourceCName, record.valueName, context);
  registerNamespaceExport(record.sourceCName, record.collectionName, context);
  lines.push(`/// Allocator-backed copy of a ${record.valueName.slice(5)} value.`);
  lines.push(`pub const ${record.valueName} = struct {`);
  for (const field of record.fields) {
    lines.push(
      `    /// Copy of ${context.profile.displayName} field \`${field.sourceName}\`.`,
    );
    lines.push(
      `    ${field.publicName}: ${
        field.kind === "string" ? "?[:0]u8" : renderPublicStorageType(field.typeId, context)
      },`,
    );
  }
  lines.push("};");
  lines.push("");
  lines.push(`/// Allocator-backed list of ${record.valueName.slice(5)} values.`);
  lines.push(`pub const ${record.collectionName} = struct {`);
  lines.push("    /// Allocator that owns `items` and their copied strings.");
  lines.push("    allocator: std.mem.Allocator,");
  lines.push(`    /// Values copied from the ${context.profile.displayName}-owned allocation.`);
  lines.push(`    items: []${record.valueName},`);
  lines.push("");
  lines.push("    /// Release every copied string and the outer slice, then invalidate this list.");
  lines.push("    pub inline fn deinit(self: *@This()) void {");
  lines.push("        for (self.items) |item| {");
  for (const field of record.fields) {
    if (field.kind === "string") {
      lines.push(
        `            if (item.${field.publicName}) |value| self.allocator.free(value);`,
      );
    }
  }
  lines.push("        }");
  lines.push("        self.allocator.free(self.items);");
  lines.push("        self.* = undefined;");
  lines.push("    }");
  lines.push("};");
  lines.push("");
}

function indexByName<T>(
  values: T[],
  nameFor: (value: T) => string | undefined,
): Map<string, T[]> {
  const indexed = new Map<string, T[]>();
  for (const value of values) {
    const name = nameFor(value);
    if (!name) continue;
    const matches = indexed.get(name) ?? [];
    matches.push(value);
    indexed.set(name, matches);
  }
  return indexed;
}

function planFunction(node: XmlAstNode, context: RenderContext): FunctionPlan {
  const argumentsList = functionArguments(node, context);
  const returnId = functionReturnId(node, context);
  const sliceRelationships = documentedSliceRelationships(node, argumentsList, context);
  const failure = failureMode(node, returnId, context);
  const variadic = isVariadicFunction(node, context);
  const ownedOutputIndexes = ownedOutputByteSliceIndexes(
    node,
    returnId,
    argumentsList,
    context,
  );
  const outputMode = outputResultMode(returnId, failure, context);
  const comment = matchedDocumentation(node, context)?.comment.toLowerCase() ?? "";
  const outputResultCandidate = outputMode !== undefined &&
    !/\b(?:newly[- ]allocated|allocated by|owned by (?:the )?caller)\b/.test(comment) &&
    !mentionsReleaseFunction(comment, context);
  const borrowedContract = hasBorrowedResourceContract(node, context);
  const resourceReceiver = argumentsList[0] &&
    resourceRecordForPointer(argumentsList[0].type, context) !== undefined;
  const needsOutputs = ownedOutputIndexes !== undefined || outputResultCandidate ||
    resourceReceiver ||
    (
      borrowedContract &&
      failure === "bool" &&
      !typeContainsResourceBehindPointers(returnId, context)
    );
  const outputs = needsOutputs
    ? collectOutputValues(node, argumentsList, context, sliceRelationships)
    : [];
  const ownedStringElement = isOwnedStringFunction(node, returnId, context)
    ? ownedStringElementType(returnId, context)
    : undefined;
  const ownedArray = ownedArrayInfo(node, argumentsList, context);
  const borrowedResourceResult = borrowedContract &&
    ownedArray?.kind !== "resources" &&
    (
      typeContainsResourceBehindPointers(returnId, context) ||
      (failure === "bool" && outputs.some((output) => output.kind === "resource"))
    );

  return createFunctionPlan({
    arguments: argumentsList,
    returnId,
    sliceRelationships,
    failure,
    outputResultMode: outputMode,
    outputValues: outputs,
    ownedOutputByteSlice: ownedOutputIndexes ? { ...ownedOutputIndexes, outputs } : undefined,
    outputResult: outputResultCandidate && outputMode && outputs.length > 0
      ? { mode: outputMode, outputs }
      : undefined,
    ownedVariadicString: isOwnedVariadicStringOutputFunction(
      node,
      argumentsList,
      returnId,
      variadic,
      context,
    ),
    ownedStringElement,
    ownedByteSliceCountIndex: ownedByteSliceCountIndex(node, returnId, argumentsList, context),
    ownedArray,
    borrowedSlice: borrowedSliceInfo(node, returnId, argumentsList, context),
    borrowedResourceResult,
    variadic,
  });
}

function functionPlan(node: XmlAstNode, context: RenderContext): FunctionPlan {
  const plan = context.functionPlans.get(node.id);
  if (!plan) throw new Error(`Missing function plan for ${node.attributes.name ?? node.id}`);
  return plan;
}

function plannedReturn(
  node: XmlAstNode,
  plan: FunctionPlan,
  context: RenderContext,
): Pick<FunctionCallBody, "returnId" | "returnType" | "failure" | "requiredReturn"> {
  const returnId = plan.returnId;
  const baseType = returnId ? renderPublicReturnType(node, returnId, context) : "void";
  const failure = plan.failure;
  return {
    returnId,
    failure,
    requiredReturn: isRequiredPointerReturn(node, returnId, context),
    returnType: failure === "bool"
      ? errorUnion("void", context)
      : failure === "null"
      ? errorUnion(withoutOptional(baseType), context)
      : failure
      ? errorUnion(baseType, context)
      : baseType,
  };
}

function collectRawTypeNames(
  model: ApiModel,
  byId: ReadonlyMap<string, XmlAstNode>,
  publicIds: ReadonlySet<string>,
): Map<string, string> {
  const names = new Map<string, string>();

  for (const node of model.nodes) {
    if (!publicIds.has(node.id)) continue;
    if (node.kind === "Struct" || node.kind === "Union" || node.kind === "Enumeration") {
      const name = node.attributes.name;
      if (name) names.set(node.id, name);
    }
    if (node.kind === "Typedef") {
      const name = node.attributes.name;
      const target = node.attributes.type;
      if (name) names.set(node.id, name);
      if (name && target) {
        const targetNode = byId.get(target);
        if (targetNode && isAnonymousRecord(targetNode) && !names.has(target)) {
          names.set(target, name);
        }
      }
    }
  }
  return names;
}

function collectPublicTypeNames(
  nodes: XmlAstNode[],
  byId: ReadonlyMap<string, XmlAstNode>,
  rawTypeNames: Map<string, string>,
  naming: ZigNaming,
): Map<string, string> {
  const names = new Map<string, string>();
  const used = new Set<string>();
  for (const node of nodes.filter((node) => node.kind !== "Typedef")) {
    const rawName = rawTypeNames.get(node.id);
    if (!rawName) continue;
    names.set(node.id, uniqueIdentifier(naming.typeName(rawName), used));
  }
  for (const node of nodes.filter((node) => node.kind === "Typedef")) {
    const rawName = rawTypeNames.get(node.id);
    if (!rawName) continue;
    let target = node.attributes.type ? byId.get(node.attributes.type) : undefined;
    while (
      target?.kind === "Typedef" || target?.kind === "CvQualifiedType" ||
      target?.kind === "ElaboratedType"
    ) {
      const existing = names.get(target.id);
      if (existing && naming.typeName(rawName) === existing) {
        names.set(node.id, existing);
        target = undefined;
        break;
      }
      target = target.attributes.type ? byId.get(target.attributes.type) : undefined;
    }
    if (names.has(node.id)) continue;
    const targetName = target ? names.get(target.id) : undefined;
    const candidate = naming.typeName(rawName);
    names.set(
      node.id,
      targetName === candidate ? targetName : uniqueIdentifier(candidate, used),
    );
  }
  return names;
}

function renderPublicTypeDeclaration(
  node: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  if (context.renderedTypeIds.has(node.id) || isPrimitiveTypedef(node)) return;
  const name = context.publicTypeNames.get(node.id);
  if (!name) return;
  const rawName = context.rawTypeNames.get(node.id) ?? node.attributes.name ?? name;

  if (node.kind === "Typedef") {
    const target = node.attributes.type;
    if (!target) return;
    const targetNode = context.byId.get(target);
    const targetName = resolvedNamedTypeName(target, context.publicTypeNames, context);
    if (targetName === name) {
      context.renderedTypeIds.add(node.id);
      return;
    }
    lines.push(...documentationLines(
      rawName,
      context,
      fallbackTypeDocumentation(name, targetNode ?? node, context),
    ));
    const flag = context.flags.get(node.id);
    if (flag) {
      context.renderedTypeIds.add(node.id);
      renderFlags(name, rawName, flag, context, lines);
    } else if (targetNode && isAnonymousRecord(targetNode)) {
      context.renderedTypeIds.add(node.id);
      context.renderedTypeIds.add(targetNode.id);
      renderPublicRecord(name, targetNode, context, lines);
      renderAbiAssertion(name, rawName, targetNode, context, lines);
    } else {
      context.renderedTypeIds.add(node.id);
      lines.push(`pub const ${name} = ${renderPublicType(target, context)};`);
    }
    registerPrimaryEmission(rawName, name, context);
    lines.push("");
    return;
  }

  if (node.kind === "Enumeration") {
    lines.push(...documentationLines(
      rawName,
      context,
      fallbackTypeDocumentation(name, node, context),
    ));
    context.renderedTypeIds.add(node.id);
    renderPublicEnumeration(name, rawName, node, context, lines);
    renderAbiAssertion(name, rawName, node, context, lines);
    registerPrimaryEmission(rawName, name, context);
    lines.push("");
    return;
  }

  if (node.kind === "Struct" || node.kind === "Union") {
    lines.push(...documentationLines(
      rawName,
      context,
      fallbackTypeDocumentation(name, node, context),
    ));
    context.renderedTypeIds.add(node.id);
    if (isOpaqueRecord(node) && context.resources.has(node.id)) {
      renderResource(name, node, context, lines);
    } else if (isOpaqueRecord(node)) lines.push(`pub const ${name} = opaque {};`);
    else {
      renderPublicRecord(name, node, context, lines);
      renderAbiAssertion(name, rawName, node, context, lines);
    }
    registerPrimaryEmission(rawName, name, context);
    lines.push("");
  }
}

function fallbackTypeDocumentation(
  name: string,
  node: XmlAstNode,
  context: RenderContext,
): string {
  const rawName = context.rawTypeNames.get(node.id) ?? node.attributes.name ?? name;
  if (node.kind === "Enumeration") return `SDL enumeration \`${rawName}\`.`;
  if (node.kind === "Struct" || node.kind === "Union") {
    if (isOpaqueRecord(node)) return `SDL handle \`${rawName}\`.`;
    return `SDL record \`${rawName}\`.`;
  }
  return `SDL type \`${rawName}\`.`;
}

function renderFlags(
  name: string,
  rawName: string,
  flag: FlagInfo,
  context: RenderContext,
  lines: string[],
): void {
  const oneBits = flag.constants
    .filter((constant) => isOneBit(constant.value) && constant.value < (1n << BigInt(flag.bits)))
    .sort((left, right) => left.value < right.value ? -1 : left.value > right.value ? 1 : 0);
  const composites = flag.constants.filter((constant) => !isOneBit(constant.value));
  lines.push(`pub const ${name} = packed struct(${flag.backingType}) {`);
  let position = 0;
  let reserved = 0;
  const used = new Set<string>();
  for (const constant of oneBits) {
    const bit = bitIndex(constant.value);
    if (bit > position) {
      lines.push("    /// Unknown or currently unused bits preserved during integer round trips.");
      lines.push(`    reserved_${reserved++}: u${bit - position} = 0,`);
    }
    const suffix = constant.name.slice(flag.prefix.length + 1);
    const fieldName = uniqueIdentifier(context.naming.fieldName(suffix), used);
    registerDocumentationMember(constant.name, rawName, name, fieldName, context);
    lines.push(
      ...documentationLines(
        constant.name,
        context,
        `Flag bit \`${constant.name}\`.`,
      ).map((line) => `    ${line}`),
    );
    lines.push(`    ${fieldName}: bool = false,`);
    position = bit + 1;
  }
  if (position < flag.bits) {
    lines.push("    /// Unknown or currently unused bits preserved during integer round trips.");
    lines.push(`    reserved_${reserved}: u${flag.bits - position} = 0,`);
  }
  lines.push("");
  lines.push("    /// Preserve every known and unknown flag bit.");
  lines.push(`    pub inline fn fromInt(value: ${flag.backingType}) @This() {`);
  lines.push("        return @bitCast(value);");
  lines.push("    }");
  lines.push("");
  lines.push("    /// Convert this flag set to its integer representation.");
  lines.push(`    pub inline fn toInt(self: @This()) ${flag.backingType} {`);
  lines.push("        return @bitCast(self);");
  lines.push("    }");
  for (const constant of composites) {
    const suffix = constant.name.slice(flag.prefix.length + 1);
    const valueName = uniqueIdentifier(context.naming.fieldName(suffix), used);
    registerDocumentationMember(constant.name, rawName, name, valueName, context);
    lines.push("");
    lines.push(
      `    /// Composite flag value \`${constant.name}\`.`,
    );
    lines.push(
      `    pub const ${valueName}: @This() = fromInt(@intCast(c.${constant.name}));`,
    );
  }
  lines.push("};");
}

function bitIndex(value: bigint): number {
  let bit = 0;
  while ((value >> BigInt(bit)) !== 1n) bit++;
  return bit;
}

function renderResource(
  name: string,
  node: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  const resource = context.resources.get(node.id)!;
  lines.push(`pub const ${name} = struct {`);
  lines.push("    /// Opaque handle storage; use generated operations instead of modifying it.");
  lines.push("    value: *anyopaque,");
  if (resource.parentRecordId) {
    const parentName = context.publicTypeNames.get(resource.parentRecordId);
    if (!parentName) {
      throw new Error(`Missing public parent type for resource ${name}`);
    }
    lines.push(
      "    /// Parent handle required by dependent operations and release; it must outlive this handle.",
    );
    lines.push(`    parent: ${parentName},`);
  }
  for (const operation of resource.lifecycle) {
    renderLifecycleMethod(operation, name, node, context, lines);
  }
  renderResourceMethods(name, node, context, lines);
  lines.push("};");
}

function renderLifecycleMethod(
  operation: LifecycleOperation,
  resourceName: string,
  resourceNode: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  const node = context.byId.get(operation.nodeId);
  if (!node) throw new Error(`Missing lifecycle declaration ${operation.cName}`);
  const argumentsList = functionPlan(node, context).arguments;
  const regularArguments = argumentsList
    .map((argument, index) => ({ argument, index }))
    .filter(({ index }) =>
      index !== operation.handleArgumentIndex &&
      index !== operation.parentArgumentIndex &&
      index !== operation.statusArgumentIndex
    );
  const regularNames = publicParameterNames(
    regularArguments.map(({ argument }) => argument),
    context,
  ).map((name) => name === operation.methodName ? `${name}_2` : name);
  const rendered = renderFunctionParameters(
    node,
    regularArguments.map(({ argument }) => argument),
    regularNames,
    context,
  );
  const regularCallArguments = [...rendered.callArguments];
  let statusType: string | undefined;
  const callArguments = argumentsList.map((argument, index) => {
    if (index === operation.handleArgumentIndex) return "@ptrCast(self.value)";
    if (index === operation.parentArgumentIndex) return "@ptrCast(self.parent.value)";
    if (index === operation.statusArgumentIndex) {
      const pointer = unwrapTransparentType(argument.type, context);
      if (pointer?.kind !== "PointerType" || !pointer.attributes.type) {
        throw new Error(`Invalid lifecycle status output for ${operation.cName}`);
      }
      statusType = renderPublicApiType(pointer.attributes.type, context);
      return "&status";
    }
    const value = regularCallArguments.shift();
    if (!value) throw new Error(`Missing lifecycle argument for ${operation.cName}`);
    return value;
  });
  if (regularCallArguments.length > 0) {
    throw new Error(`Unused lifecycle arguments for ${operation.cName}`);
  }

  const returnId = functionReturnId(node, context);
  const returnType = operation.result === "bool_error" ||
      operation.result === "negative_error"
    ? errorUnion("void", context)
    : operation.result === "status_output"
    ? statusType ?? "c_int"
    : operation.result === "value"
    ? renderPublicApiType(returnId, context)
    : "void";
  registerDocumentationMember(
    operation.cName,
    context.rawTypeNames.get(resourceNode.id) ?? resourceNode.attributes.name ?? resourceName,
    resourceName,
    operation.methodName,
    context,
  );
  lines.push("");
  lines.push(
    ...documentationLines(
      operation.cName,
      context,
      `Ends this handle's ${context.profile.displayName} lifecycle.`,
      [
        operation.handleArgumentIndex,
        operation.parentArgumentIndex,
        operation.statusArgumentIndex,
      ].filter((index): index is number => index !== undefined),
    ).map((line) => `    ${line}`),
  );
  lines.push(
    `    /// This method invalidates the handle after ${context.profile.displayName} consumes it.`,
  );
  if (operation.result === "bool_error" || operation.result === "negative_error") {
    lines.push(
      `    /// Returns \`error.SdlFailure\` when ${context.profile.displayName} reports failure.`,
    );
  }
  const parameters = ["self: *@This()", ...rendered.declarations];
  lines.push(`    pub inline fn ${operation.methodName}(${parameters.join(", ")}) ${returnType} {`);
  if (operation.result === "status_output") {
    lines.push(`        var status: ${statusType ?? "c_int"} = undefined;`);
  }
  const call = `c.${operation.cName}(${callArguments.join(", ")})`;
  if (operation.result === "bool_error") {
    lines.push(`        const success = ${call};`);
    if (operation.invalidate === "always") lines.push("        self.* = undefined;");
    lines.push("        if (!success) return error.SdlFailure;");
    if (operation.invalidate === "success") lines.push("        self.* = undefined;");
  } else if (operation.result === "negative_error") {
    lines.push(`        const result = ${call};`);
    if (operation.invalidate === "always") lines.push("        self.* = undefined;");
    lines.push("        if (result < 0) return error.SdlFailure;");
    if (operation.invalidate === "success") lines.push("        self.* = undefined;");
  } else if (operation.result === "value") {
    lines.push(`        const result = ${call};`);
    lines.push("        self.* = undefined;");
    if (conversionKind(returnId, context) === "direct") {
      lines.push("        return result;");
    } else {
      lines.push(`        return ${fromAbiExpression(returnId, "result", context)};`);
    }
  } else {
    lines.push(`        ${call};`);
    lines.push("        self.* = undefined;");
    if (operation.result === "status_output") lines.push("        return status;");
  }
  lines.push("    }");
}

function renderResourceMethods(
  resourceName: string,
  resourceNode: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  const resource = context.resources.get(resourceNode.id)!;
  const used = new Set<string>([
    "value",
    "parent",
    ...resource.lifecycle.map((operation) => operation.methodName),
  ]);
  const reservedMemberNames = new Set<string>(
    resource.lifecycle.map((operation) => operation.methodName),
  );
  for (const functionNode of context.publicFunctions) {
    const cName = functionNode.attributes.name;
    if (!cName) continue;
    const argumentsList = functionPlan(functionNode, context).arguments;
    if (
      argumentsList.length > 0 &&
      resourceRecordForPointer(argumentsList[0].type, context)?.id === resourceNode.id
    ) {
      reservedMemberNames.add(resourceMethodName(cName, resourceName, context));
    }
  }
  for (const functionNode of context.publicFunctions) {
    const cName = functionNode.attributes.name;
    if (!cName || isResourceDestructor(cName, context)) continue;
    const plan = functionPlan(functionNode, context);
    if (plan.variadic) continue;
    const argumentsList = plan.arguments;
    if (
      argumentsList.length === 0 ||
      resourceRecordForPointer(argumentsList[0].type, context)?.id !== resourceNode.id
    ) continue;
    const documentation = matchedDocumentation(functionNode, context);
    if (documentation?.comment.toLowerCase().includes("freed with")) continue;
    if (isResourceConstructor(functionNode, context)) continue;
    const resourceOutputIndexes = new Set(
      plan.outputValues
        .filter((output) => output.kind === "resource")
        .map((output) => output.index),
    );
    if (
      argumentsList.some((argument, index) =>
        index > 0 &&
        outputResourceType(argument.type, context) !== undefined &&
        !resourceOutputIndexes.has(index)
      )
    ) continue;

    const methodName = uniqueIdentifier(
      resourceMethodName(cName, resourceName, context),
      used,
    );
    registerDocumentationMember(
      cName,
      context.rawTypeNames.get(resourceNode.id) ?? resourceNode.attributes.name ?? resourceName,
      resourceName,
      methodName,
      context,
    );
    const methodArguments = argumentsList.slice(1);
    const { returnId, requiredReturn, failure, returnType } = plannedReturn(
      functionNode,
      plan,
      context,
    );
    lines.push("");
    lines.push(
      ...documentationLines(
        cName,
        context,
        `SDL operation \`${cName}\`.`,
        [0],
      ).map(
        (line) => `    ${line}`,
      ),
    );
    if (isBorrowedResourceResult(functionNode, context)) {
      lines.push(
        "    /// Returned handles are borrowed; do not call their destructive lifecycle methods.",
      );
    }
    if (failure) {
      lines.push(
        `    /// Returns \`error.SdlFailure\` when ${context.profile.displayName} reports failure.`,
      );
    }
    const outputMode = plan.outputResultMode;
    const outputs = outputMode ? plan.outputValues.filter((output) => output.index > 0) : [];
    if (outputs.length > 0) {
      renderResourceOutputMethod(
        functionNode,
        methodName,
        methodArguments,
        outputs,
        resourceNode,
        context,
        lines,
        outputMode!,
        reservedMemberNames,
      );
      continue;
    }

    const argumentNames = publicParameterNames(methodArguments, context).map((argumentName) =>
      reservedMemberNames.has(argumentName) ? `${argumentName}_2` : argumentName
    );
    const renderedParameters = renderFunctionParameters(
      functionNode,
      methodArguments,
      argumentNames,
      context,
    );
    const parentExpression = dependentResourceParentExpression(
      returnId,
      methodArguments,
      argumentNames,
      context,
      resourceNode.id,
    );
    const parameters = ["self: @This()", ...renderedParameters.declarations];
    lines.push(`    pub inline fn ${methodName}(${parameters.join(", ")}) ${returnType} {`);
    const callArguments = [
      "@ptrCast(self.value)",
      ...renderedParameters.callArguments,
    ];
    const call = `c.${cName}(${callArguments.join(", ")})`;
    renderFunctionCallBody(
      {
        call,
        returnId,
        returnType,
        failure,
        requiredReturn,
        parentExpression,
        indentation: "        ",
      },
      context,
      lines,
    );
    lines.push("    }");
  }
}

function isResourceConstructor(node: XmlAstNode, context: RenderContext): boolean {
  const actionWords = new Set(["acquire", "create", "load", "open"]);
  const cName = node.attributes.name ?? "";
  const words = sourceWords(cName, context);
  if (words.length === 0 || !actionWords.has(words[0])) return false;
  const plan = functionPlan(node, context);
  const returnsResource = resourceRecordForPointer(plan.returnId, context) !==
    undefined;
  const hasResourceOutput = plan.arguments.some((argument) =>
    outputResourceType(argument.type, context) !== undefined
  );
  if (returnsResource) return true;
  return hasResourceOutput && !isBorrowedResourceResult(node, context);
}

function resourceMethodName(
  cName: string,
  resourceName: string,
  context: RenderContext,
): string {
  const receiverWords = sourceWords(resourceName, context);
  const functionWords = sourceWords(cName, context);
  const receiverStart = contiguousWordsIndex(functionWords, receiverWords);
  const remaining = receiverStart >= 0
    ? [
      ...functionWords.slice(0, receiverStart),
      ...functionWords.slice(receiverStart + receiverWords.length),
    ]
    : removeReceiverWords(functionWords, receiverWords);
  const methodWords = remaining.length > 0 ? remaining : functionWords;
  return context.naming.functionName(
    `${context.profile.symbolPrefixes[0]}${methodWords.join("_")}`,
  );
}

function sourceWords(value: string, context: RenderContext): string[] {
  const words = context.naming.words(value);
  for (const prefix of context.profile.symbolPrefixes) {
    const prefixWords = context.naming.words(prefix);
    if (
      prefixWords.length <= words.length &&
      prefixWords.every((word, index) => words[index] === word)
    ) {
      return words.slice(prefixWords.length);
    }
  }
  return words;
}

function contiguousWordsIndex(words: string[], candidate: string[]): number {
  if (candidate.length === 0 || candidate.length > words.length) return -1;
  for (let index = 0; index <= words.length - candidate.length; index++) {
    if (candidate.every((word, offset) => words[index + offset] === word)) return index;
  }
  return -1;
}

function removeReceiverWords(functionWords: string[], receiverWords: string[]): string[] {
  const remainingReceiverWords = new Map<string, number>();
  for (const word of receiverWords) {
    remainingReceiverWords.set(word, (remainingReceiverWords.get(word) ?? 0) + 1);
  }
  return functionWords.filter((word, index) => {
    const remaining = remainingReceiverWords.get(word) ?? 0;
    if (remaining === 0) return true;
    if (index === 0 && isLeadingMethodAction(word)) return true;
    remainingReceiverWords.set(word, remaining - 1);
    return false;
  });
}

const leadingMethodActions = new Set([
  "acquire",
  "add",
  "begin",
  "close",
  "create",
  "destroy",
  "end",
  "flush",
  "free",
  "get",
  "load",
  "lock",
  "map",
  "open",
  "pop",
  "push",
  "query",
  "read",
  "release",
  "save",
  "seek",
  "set",
  "submit",
  "tell",
  "try",
  "unmap",
  "wait",
  "write",
]);

function isLeadingMethodAction(word: string): boolean {
  return leadingMethodActions.has(word);
}

function renderResourceOutputMethod(
  node: XmlAstNode,
  methodName: string,
  methodArguments: Array<{ name: string; type: string }>,
  outputs: OutputValue[],
  resourceNode: XmlAstNode,
  context: RenderContext,
  lines: string[],
  mode: OutputResultMode,
  reservedMemberNames: Set<string>,
): void {
  const returnId = functionReturnId(node, context);
  const resultName = `${context.naming.typeName(node.attributes.name ?? methodName)}Result`;
  const outputIndexes = new Set(outputs.map((output) => output.index - 1));
  const regularArguments = methodArguments
    .map((argument, index) => ({ argument, index }))
    .filter((item) => !outputIndexes.has(item.index));
  const regularNames = publicParameterNames(
    regularArguments.map((item) => item.argument),
    context,
  ).map((argumentName) =>
    reservedMemberNames.has(argumentName) ? `${argumentName}_2` : argumentName
  );
  const rendered = renderFunctionParameters(
    node,
    regularArguments.map((item) => item.argument),
    regularNames,
    context,
  );
  lines.push(
    `    pub inline fn ${methodName}(self: @This()${
      rendered.declarations.length > 0 ? `, ${rendered.declarations.join(", ")}` : ""
    }) ${outputResultReturnType(mode, `root.${resultName}`, context)} {`,
  );
  const fieldNames = new Map<number, string>();
  const usedFields = new Set<string>(outputResultHasPrimaryValue(mode) ? ["value"] : []);
  for (const output of outputs) {
    const fieldName = uniqueIdentifier(
      context.naming.fieldName(output.argument.name || `result_${output.index}`),
      usedFields,
    );
    fieldNames.set(output.index, fieldName);
  }
  renderOutputLocals(node.attributes.name!, outputs, fieldNames, lines, "        ");
  let regularCallIndex = 0;
  const callArguments = argumentsListForMethod(node, context).map((_argument, index) => {
    if (index === 0) return "@ptrCast(self.value)";
    const output = outputs.find((item) => item.index === index);
    if (output) return `&${fieldNames.get(index)!}_raw`;
    return rendered.callArguments[regularCallIndex++];
  });
  const call = `c.${node.attributes.name}(${callArguments.join(", ")})`;
  if (mode === "bool_error") {
    lines.push(`        if (!${call}) return error.SdlFailure;`);
  } else if (mode === "bool_optional") {
    lines.push(`        if (!${call}) return null;`);
  } else if (mode === "void") {
    lines.push(`        ${call};`);
  } else {
    lines.push(`        const value_raw = ${call};`);
    if (mode === "value_error") {
      const failure = functionPlan(node, context).failure;
      if (!failure) throw new Error(`Missing failure mode for ${node.attributes.name}`);
      lines.push(
        `        if (${failureCondition(failure, "value_raw")}) return error.SdlFailure;`,
      );
    }
  }
  lines.push(`        return root.${resultName}{`);
  if (outputResultHasPrimaryValue(mode)) {
    lines.push(
      `            .value = ${fromAbiExpression(returnId, "value_raw", context)},`,
    );
  }
  renderOutputInitializers(
    outputs,
    fieldNames,
    regularArguments.map((item) => item.argument),
    regularNames,
    context,
    lines,
    "            ",
    resourceNode.id,
  );
  lines.push("        };");
  lines.push("    }");
}

function argumentsListForMethod(
  node: XmlAstNode,
  context: RenderContext,
): Array<{ name: string; type: string }> {
  return functionPlan(node, context).arguments;
}

function resourceRecordForPointer(
  id: string,
  context: RenderContext,
): XmlAstNode | undefined {
  const pointer = unwrapTransparentType(id, context);
  if (pointer?.kind !== "PointerType" || !pointer.attributes.type) return undefined;
  const record = unwrapTransparentType(pointer.attributes.type, context);
  return record && context.resources.has(record.id) ? record : undefined;
}

function dependentResourceParentExpression(
  returnId: string,
  argumentsList: Array<{ name: string; type: string }>,
  argumentNames: string[],
  context: RenderContext,
  selfRecordId?: string,
): string | undefined {
  const returned = resourceRecordForPointer(returnId, context);
  return returned
    ? dependentResourceParentForRecord(
      returned,
      argumentsList,
      argumentNames,
      context,
      selfRecordId,
    )
    : undefined;
}

function dependentResourceParentForRecord(
  returned: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  argumentNames: string[],
  context: RenderContext,
  selfRecordId?: string,
): string | undefined {
  const parentId = context.resources.get(returned.id)?.parentRecordId;
  if (!parentId) return undefined;
  if (selfRecordId === parentId) return "self";
  if (selfRecordId && context.resources.get(selfRecordId)?.parentRecordId === parentId) {
    return "self.parent";
  }
  for (const [index, argument] of argumentsList.entries()) {
    const record = resourceRecordForPointer(argument.type, context);
    if (!record) continue;
    const name = argumentNames[index];
    if (record.id === parentId) return `(${name} orelse return error.SdlFailure)`;
    if (context.resources.get(record.id)?.parentRecordId === parentId) {
      return `(${name} orelse return error.SdlFailure).parent`;
    }
  }
  throw new Error(
    `Cannot determine parent handle for dependent resource ${
      returned.attributes.name ?? returned.id
    }`,
  );
}

function renderPublicRecord(
  name: string,
  node: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  const keyword = node.kind === "Union" ? "extern union" : "extern struct";
  lines.push(`pub const ${name} = ${keyword} {`);
  const fields = recordFields(node, context);
  if (fields.some(isBitfield)) {
    throw new Error(`Unsupported public C bitfield in ${name}`);
  } else if (fields.length === 0) {
    throw new Error(`Non-opaque public record ${name} has no fields`);
  } else {
    const usedNames = new Set<string>();
    for (const [index, field] of fields.entries()) {
      const sourceName = field.attributes.name || `field_${index}`;
      const fieldName = uniqueIdentifier(context.naming.fieldName(sourceName), usedNames);
      if (!field.attributes.type) {
        throw unsupportedPublicSignature(`type ${name} field ${sourceName}`, "has no type");
      }
      const fieldType = renderPublicStorageType(field.attributes.type, context);
      lines.push(`    /// Field \`${sourceName}\`.`);
      lines.push(`    ${fieldName}: ${fieldType},`);
    }
  }
  lines.push("};");
}

function renderPublicEnumeration(
  name: string,
  rawName: string,
  node: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  const values = enumValues(node, context);
  const valueNames = values.map((value) => value.attributes.name || "");
  const tags = context.naming.enumTagNames(node.attributes.name || name, valueNames);
  const seenValues = new Set<string>();
  const aliases: Array<{ sourceName: string; valueName: string }> = [];
  lines.push(`pub const ${name} = enum(c.${rawName}) {`);
  for (const [index, value] of values.entries()) {
    const sourceName = value.attributes.name || valueNames[index];
    const valueName = tags.get(sourceName) ?? `value_${index}`;
    const identity = normalizeInteger(value.attributes.init ?? sourceName);
    if (seenValues.has(identity)) {
      aliases.push({ sourceName, valueName });
      continue;
    }
    seenValues.add(identity);
    registerDocumentationMember(sourceName, rawName, name, valueName, context);
    lines.push(
      ...documentationLines(
        sourceName,
        context,
        `Enumeration value \`${sourceName}\`.`,
      ).map((line) => `    ${line}`),
    );
    lines.push(`    ${valueName} = @intCast(c.${sourceName}),`);
  }
  lines.push("    _,");
  for (const alias of aliases) {
    registerDocumentationMember(alias.sourceName, rawName, name, alias.valueName, context);
    lines.push(
      ...documentationLines(
        alias.sourceName,
        context,
        `Alias for enumeration value \`${alias.sourceName}\`.`,
      ).map((line) => `    ${line}`),
    );
    lines.push(
      `    pub const ${alias.valueName}: @This() = @enumFromInt(c.${alias.sourceName});`,
    );
  }
  lines.push("};");
}

function renderPublicConstants(
  context: RenderContext,
  lines: string[],
  moduleNames: Set<string>,
): void {
  let emitted = false;
  for (const constant of context.model.constants) {
    if (constant.source === "enum") continue;
    const baseName = context.naming.valueName(constant.name);
    const disambiguated = moduleNames.has(baseName)
      ? `${baseName}_${/[a-z]/.test(constant.name) ? "lowercase" : "uppercase"}`
      : baseName;
    const name = uniqueIdentifier(disambiguated, moduleNames);
    lines.push(...documentationLines(
      constant.name,
      context,
      `SDL constant \`${constant.name}\`.`,
    ));
    lines.push(`pub const ${name} = c.${constant.name};`);
    registerPrimaryEmission(constant.name, name, context);
    emitted = true;
  }
  if (emitted) lines.push("");
}

function renderPublicVariables(
  context: RenderContext,
  lines: string[],
  moduleNames: Set<string>,
): void {
  for (const node of context.publicVariables) {
    const cName = node.attributes.name;
    const type = node.attributes.type;
    if (!cName || !type) continue;
    const name = uniqueIdentifier(`${context.naming.functionName(cName)}Ptr`, moduleNames);
    lines.push(...documentationLines(
      cName,
      context,
      `Access SDL variable \`${cName}\`.`,
    ));
    lines.push(`pub inline fn ${name}() *${renderPublicType(type, context)} {`);
    lines.push(`    return @ptrCast(&c.${cName});`);
    lines.push("}");
    lines.push("");
    registerPrimaryEmission(cName, name, context);
  }
}

function renderPublicFunctions(
  context: RenderContext,
  lines: string[],
  moduleNames: Set<string>,
): void {
  // Generated adapters are intended to be a zero-overhead translation layer. Force-inline the
  // wrapper so the public Zig call does not add a boundary around the translated C operation.
  for (const node of context.publicFunctions) {
    const cName = node.attributes.name;
    if (!cName || isResourceDestructor(cName, context)) continue;
    const baseName = context.naming.functionName(cName);
    const disambiguated = moduleNames.has(baseName) ? `${baseName}Default` : baseName;
    const name = uniqueIdentifier(disambiguated, moduleNames);
    registerPrimaryEmission(cName, name, context);
    const plan = functionPlan(node, context);
    const documentation = documentationLines(cName, context, `SDL operation \`${cName}\`.`);
    if (plan.borrowedResourceResult) {
      appendDocumentationParagraph(
        documentation,
        "/// Returned handles are borrowed; do not call their destructive lifecycle methods.",
      );
    }

    if (plan.transformation.kind === "owned_output_byte_slice") {
      renderOwnedOutputByteSliceFunction(
        node,
        name,
        documentation,
        plan,
        context,
        lines,
        moduleNames,
      );
      continue;
    }
    if (plan.transformation.kind === "output_result") {
      renderOutputResultFunction(node, name, documentation, plan, context, lines, moduleNames);
      continue;
    }

    lines.push(...documentation);

    switch (plan.transformation.kind) {
      case "owned_variadic_string":
        renderOwnedVariadicStringFunction(node, name, context, lines);
        continue;
      case "owned_string":
        renderOwnedStringFunction(
          node,
          name,
          plan,
          plan.transformation.elementType,
          context,
          lines,
        );
        continue;
      case "owned_byte_slice":
        renderOwnedByteSliceFunction(
          node,
          name,
          plan,
          plan.transformation.countIndex,
          context,
          lines,
        );
        continue;
      case "owned_slice":
        renderOwnedSliceFunction(node, name, plan, plan.transformation.info, context, lines);
        continue;
      case "borrowed_slice":
        renderBorrowedSliceFunction(node, name, plan, plan.transformation.info, context, lines);
        continue;
      case "variadic":
        renderVariadicFunction(node, name, plan, context, lines);
        continue;
      case "direct":
        break;
    }

    const argumentsList = plan.arguments;
    const argumentNames = publicParameterNames(argumentsList, context);
    const renderedParameters = renderFunctionParameters(
      node,
      argumentsList,
      argumentNames,
      context,
    );
    const { returnId, requiredReturn, failure, returnType } = plannedReturn(node, plan, context);
    const parentExpression = dependentResourceParentExpression(
      returnId,
      argumentsList,
      argumentNames,
      context,
    );
    if (failure) {
      appendDocumentationParagraph(
        lines,
        `/// Returns \`error.SdlFailure\` when ${context.profile.displayName} reports failure.`,
      );
    }
    lines.push(
      `pub inline fn ${name}(${renderedParameters.declarations.join(", ")}) ${returnType} {`,
    );
    const call = `c.${cName}(${renderedParameters.callArguments.join(", ")})`;
    renderFunctionCallBody(
      {
        call,
        returnId,
        returnType,
        failure,
        requiredReturn,
        parentExpression,
        indentation: "    ",
      },
      context,
      lines,
    );
    lines.push("}");
    lines.push("");
  }
}

interface FunctionCallBody {
  call: string;
  returnId: string;
  returnType: string;
  failure: FailureMode | undefined;
  requiredReturn: boolean;
  parentExpression: string | undefined;
  indentation: string;
}

function renderFunctionCallBody(
  body: FunctionCallBody,
  context: RenderContext,
  lines: string[],
): void {
  const { call, returnId, returnType, failure, requiredReturn, parentExpression, indentation } =
    body;
  if (failure === "bool") {
    lines.push(`${indentation}if (!${call}) return error.SdlFailure;`);
  } else if (failure === "null") {
    lines.push(`${indentation}const result = ${call};`);
    lines.push(`${indentation}if (result == null) return error.SdlFailure;`);
    lines.push(
      `${indentation}return ${
        fromAbiNonNullExpression(returnId, "result", context, parentExpression)
      };`,
    );
  } else if (failure) {
    lines.push(`${indentation}const result = ${call};`);
    lines.push(
      `${indentation}if (${failureCondition(failure, "result")}) return error.SdlFailure;`,
    );
    lines.push(
      `${indentation}return ${fromAbiExpression(returnId, "result", context, parentExpression)};`,
    );
  } else if (!returnId || returnType === "void") {
    lines.push(`${indentation}${call};`);
  } else if (conversionKind(returnId, context) === "direct") {
    lines.push(`${indentation}return ${call};`);
  } else {
    lines.push(`${indentation}const result = ${call};`);
    lines.push(
      `${indentation}return ${
        requiredReturn
          ? fromAbiNonNullExpression(returnId, "result", context, parentExpression)
          : fromAbiExpression(returnId, "result", context, parentExpression)
      };`,
    );
  }
}

function isResourceDestructor(cName: string, context: RenderContext): boolean {
  return context.destructorCNames.has(cName);
}

function isBorrowedResourceResult(node: XmlAstNode, context: RenderContext): boolean {
  return functionPlan(node, context).borrowedResourceResult;
}

function hasBorrowedResourceContract(node: XmlAstNode, context: RenderContext): boolean {
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase().replace(/\s+/g, " ") ?? "";
  if (/\bdo not have to\b[^.!?]{0,100}\bdestroy\b[^.!?]{0,100}\bsafe to do so\b/.test(comment)) {
    return false;
  }
  const prohibited =
    /\b(?:do|should|must)\s+not\b[^.!?]{0,180}\b(?:free(?:d)?|destroy(?:ed)?|close(?:d)?|release(?:d)?)\b/
      .test(comment) ||
    /\bdoes not need to be destroyed\b[^.!?]{0,180}\bwill be destroyed\b/.test(comment) ||
    (
      /\bowned by\b/.test(comment) &&
      /\b(?:not necessary to|should not|must not)\s+(?:be\s+)?(?:free|destroy)/.test(comment)
    );
  return prohibited;
}

function typeContainsResourceBehindPointers(id: string, context: RenderContext): boolean {
  let node = unwrapTransparentType(id, context);
  while (node?.kind === "PointerType" && node.attributes.type) {
    node = unwrapTransparentType(node.attributes.type, context);
  }
  return node !== undefined && context.resources.has(node.id);
}

function renderFunctionParameters(
  node: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  argumentNames: string[],
  context: RenderContext,
): RenderedParameters {
  const declarations: string[] = [];
  const callArguments = new Array<string>(argumentsList.length);
  const plan = context.functionPlans.get(node.id);
  const relationships = plan && argumentsList === plan.arguments
    ? plan.sliceRelationships
    : documentedSliceRelationships(node, argumentsList, context);
  const pointerRelationships = new Map<number, SliceRelationship>();
  const countRelationships = new Map<number, SliceRelationship>();
  for (const relationship of relationships) {
    countRelationships.set(relationship.countIndex, relationship);
    for (const pointerIndex of relationship.pointerIndexes) {
      pointerRelationships.set(pointerIndex, relationship);
    }
  }

  for (let index = 0; index < argumentsList.length; index++) {
    const argument = argumentsList[index];
    const name = argumentNames[index];
    if (countRelationships.has(index)) continue;

    const relationship = pointerRelationships.get(index);
    const slice = relationship ? sliceElement(argument.type, context) : undefined;
    if (slice) {
      declarations.push(`${name}: []${slice.isConst ? "const " : ""}${slice.elementType}`);
      callArguments[index] = `@ptrCast(${name}.ptr)`;
      continue;
    }
    declarations.push(`${name}: ${renderPublicParameterType(node, argument, context)}`);
    callArguments[index] = toAbiParameterExpression(node, argument, name, context);
  }

  for (const relationship of relationships) {
    const names = relationship.pointerIndexes.map((index) => argumentNames[index]);
    const first = names[0];
    callArguments[relationship.countIndex] = names.length === 1
      ? `@intCast(${first}.len)`
      : `@intCast(if (${
        names.slice(1).map((name) => `${name}.len == ${first}.len`).join(" and ")
      }) ${first}.len else @panic("related slices must have equal lengths"))`;
  }

  const missingCallArgument = callArguments.findIndex((argument) => argument === undefined);
  if (missingCallArgument !== -1) {
    throw new Error(
      `Missing ABI argument ${missingCallArgument} while rendering ${node.attributes.name}`,
    );
  }

  return { declarations, callArguments };
}

function renderVisibleFunctionParameters(
  node: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  hiddenIndexes: ReadonlySet<number>,
  context: RenderContext,
): VisibleFunctionParameters {
  const indexed = argumentsList
    .map((argument, index) => ({ argument, index }))
    .filter(({ index }) => !hiddenIndexes.has(index));
  const arguments_ = indexed.map(({ argument }) => argument);
  const names = publicParameterNames(arguments_, context);
  return {
    arguments: arguments_,
    indexes: indexed.map(({ index }) => index),
    names,
    rendered: renderFunctionParameters(node, arguments_, names, context),
  };
}

function reconstructCallArguments(
  argumentCount: number,
  visible: VisibleFunctionParameters,
  overrides: ReadonlyMap<number, string>,
): string[] {
  const calls = new Map(visible.indexes.map((index, position) => [
    index,
    visible.rendered.callArguments[position],
  ]));
  return Array.from({ length: argumentCount }, (_, index) => {
    const argument = overrides.get(index) ?? calls.get(index);
    if (argument === undefined) throw new Error(`Missing ABI argument ${index}`);
    return argument;
  });
}

function sliceElement(
  id: string,
  context: RenderContext,
): SliceElementInfo | undefined {
  const pointer = unwrapTransparentType(id, context);
  if (pointer?.kind !== "PointerType" || !pointer.attributes.type) return undefined;
  const immediateTarget = context.byId.get(pointer.attributes.type);
  const isConst = immediateTarget?.kind === "CvQualifiedType" &&
    immediateTarget.attributes.const === "1";
  const target = unwrapTransparentType(pointer.attributes.type, context);
  if (
    !target || target.kind === "PointerType" || target.kind === "FunctionType" ||
    resourceTypeName(target.id, context) ||
    ((target.kind === "Struct" || target.kind === "Union") && isOpaqueRecord(target))
  ) {
    return undefined;
  }
  const byteLike = target.kind === "FundamentalType" &&
    (target.attributes.name === "void" || /char/.test(target.attributes.name ?? ""));
  const elementType = target.kind === "FundamentalType" && target.attributes.name === "void"
    ? "u8"
    : renderPublicApiType(pointer.attributes.type, context);
  return { elementType, isConst, byteLike };
}

function isIntegerValueType(id: string, context: RenderContext): boolean {
  const target = unwrapTransparentType(id, context);
  return target?.kind === "FundamentalType" &&
    /(?:char|short|int|long|size_t|ptrdiff_t)/.test(target.attributes.name?.toLowerCase() ?? "");
}

function isDocumentedCountName(name: string): boolean {
  return /^(?:len|length|size|count|num(?:ber)?(?:_.*)?|.*(?:len|length|size|count|bytes))$/i
    .test(name);
}

function documentedSliceRelationships(
  node: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
): SliceRelationship[] {
  const documentation = matchedDocumentation(node, context);
  if (!documentation) return [];

  const descriptions = argumentsList.map((argument) =>
    documentationParameterDescription(documentation.comment, argument.name)
      .toLowerCase()
      .replace(/\s+/g, " ")
      .trim()
  );
  const edges: Array<{ countIndex: number; pointerIndex: number; score: number }> = [];

  for (const [countIndex, count] of argumentsList.entries()) {
    if (
      !isDocumentedCountName(count.name) ||
      !isIntegerValueType(count.type, context)
    ) continue;

    const countDescription = descriptions[countIndex];
    const exact: Array<{ pointerIndex: number; score: number }> = [];
    const semanticByTerm = new Map<string, Set<number>>();
    for (const [pointerIndex, pointer] of argumentsList.entries()) {
      const slice = sliceElement(pointer.type, context);
      if (
        !slice ||
        hasDocumentedStride(pointer.name, argumentsList)
      ) continue;
      const pointerDescription = descriptions[pointerIndex];
      const countNamesPointer = parameterWordMention(countDescription, pointer.name);
      const pointerNamesCount = parameterWordMention(pointerDescription, count.name);
      const namesPair = countDescription !== "" && pointerDescription !== "" &&
        countNameTargetsPointer(count.name, pointer.name);
      if (countNamesPointer || pointerNamesCount || namesPair) {
        exact.push({
          pointerIndex,
          score: countNamesPointer && pointerNamesCount ? 5 : 4,
        });
        continue;
      }
      const sharedTerms = slice.byteLike
        ? sharedCollectionTerms(countDescription, pointerDescription)
        : [];
      if (sharedTerms.length > 0) {
        for (const term of sharedTerms) {
          const indexes = semanticByTerm.get(term) ?? new Set<number>();
          indexes.add(pointerIndex);
          semanticByTerm.set(term, indexes);
        }
      }
    }

    if (exact.length > 0) {
      for (const edge of exact) edges.push({ countIndex, ...edge });
      continue;
    }
    // Generic prose such as "the buffers" is only enough evidence when it
    // links multiple byte pointers to the same count. A single generic match
    // cannot distinguish an array length from an operation size.
    const semanticPointers = new Set(
      [...semanticByTerm.values()]
        .filter((indexes) => indexes.size > 1)
        .flatMap((indexes) => [...indexes]),
    );
    if (semanticPointers.size > 1) {
      for (const pointerIndex of semanticPointers) {
        edges.push({ countIndex, pointerIndex, score: 2 });
      }
      continue;
    }

    const pointerIndex = countIndex - 1;
    if (pointerIndex < 0) continue;
    const pointer = argumentsList[pointerIndex];
    const slice = sliceElement(pointer.type, context);
    if (
      !slice ||
      !documentation.parameters.some((parameter) =>
        parameterNameFromSignature(parameter) === pointer.name
      )
    ) continue;
    const previousIsPointer = pointerIndex > 0 &&
      sliceElement(argumentsList[pointerIndex - 1].type, context) !== undefined;
    const followedByAnotherCount = argumentsList[countIndex + 1] &&
      isDocumentedCountName(argumentsList[countIndex + 1].name);
    const byteLength = /(?:len|length|size|bytes)$/i.test(count.name);
    const pluralElements =
      /(?:s|data|values|items|array|points|rects|vertices|indices|frames|bindings)$/i.test(
        pointer.name,
      );
    if (
      previousIsPointer || followedByAnotherCount ||
      (byteLength ? !slice.byteLike : !pluralElements)
    ) continue;
    edges.push({ countIndex, pointerIndex, score: 1 });
  }

  const unambiguousEdges = edges.filter((edge) => {
    const competing = edges.filter((candidate) =>
      candidate.pointerIndex === edge.pointerIndex &&
      candidate.score >= edge.score
    );
    const bestScore = Math.max(...competing.map((candidate) => candidate.score));
    return edge.score === bestScore &&
      competing.filter((candidate) => candidate.score === bestScore).length === 1;
  });
  const byCount = new Map<number, number[]>();
  for (const edge of unambiguousEdges) {
    const pointers = byCount.get(edge.countIndex) ?? [];
    pointers.push(edge.pointerIndex);
    byCount.set(edge.countIndex, pointers);
  }
  return [...byCount.entries()]
    .map(([countIndex, pointerIndexes]) => ({
      countIndex,
      pointerIndexes: pointerIndexes.sort((left, right) => left - right),
    }))
    .sort((left, right) => left.countIndex - right.countIndex);
}

function hasDocumentedStride(
  pointerName: string,
  argumentsList: Array<{ name: string; type: string }>,
): boolean {
  const normalized = pointerName.toLowerCase();
  return argumentsList.some((argument) => argument.name.toLowerCase() === `${normalized}_stride`);
}

function parameterWordMention(description: string, parameterName: string): boolean {
  if (!description) return false;
  const escaped = parameterName.toLowerCase().replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`(?:\`${escaped}\`|\\b${escaped}\\b)`, "i").test(description);
}

function countNameTargetsPointer(countName: string, pointerName: string): boolean {
  const countTarget = countName.toLowerCase().replace(/^(?:num(?:ber)?_|n(?=[a-z]))/, "");
  return countTarget === pointerName.toLowerCase();
}

function sharedCollectionTerms(left: string, right: string): string[] {
  if (!left || !right) return [];
  const terms =
    /\b(?:arrays?|buffers?|bytes?|elements?|entries|frames?|indices|items?|points?|records?|streams?|values?|vertices)\b/g;
  const leftTerms = new Set(
    [...left.matchAll(terms)].map((match) => singularCollectionTerm(match[0])),
  );
  return [
    ...new Set(
      [...right.matchAll(terms)]
        .map((match) => singularCollectionTerm(match[0]))
        .filter((term) => leftTerms.has(term)),
    ),
  ];
}

function singularCollectionTerm(term: string): string {
  if (term === "indices") return "index";
  if (term === "entries") return "entry";
  if (term.endsWith("s")) return term.slice(0, -1);
  return term;
}

function parameterNameFromSignature(parameter: string): string {
  return parameter.match(/([A-Za-z_][A-Za-z0-9_]*)\s*(?:\[[^\]]*\])?$/)?.[1] ?? "";
}

function renderVariadicFunction(
  node: XmlAstNode,
  name: string,
  plan: FunctionPlan,
  context: RenderContext,
  lines: string[],
): void {
  const argumentsList = plan.arguments;
  if (argumentsList.length === 0) {
    throw new Error(`Variadic function ${node.attributes.name} has no fixed format parameter`);
  }
  const formatArgument = argumentsList.at(-1)!;
  const charFormat = isConstCharPointerType(formatArgument.type, context);
  const fixedArguments = argumentsList.slice(0, -1);
  const fixedNames = publicParameterNames(fixedArguments, context);
  const parameters = [
    ...fixedArguments.map((argument, index) =>
      `${fixedNames[index]}: ${renderPublicParameterType(node, argument, context)}`
    ),
    charFormat
      ? "comptime format: [:0]const u8"
      : `format: ${renderPublicParameterType(node, formatArgument, context)}`,
    "args: anytype",
  ];
  const returnId = plan.returnId;
  const returnType = returnId ? renderPublicType(returnId, context) : "void";
  lines.push(`pub inline fn ${name}(${parameters.join(", ")}) ${returnType} {`);
  const abiParameterType = (index: number) =>
    `@typeInfo(@TypeOf(c.${node.attributes.name})).@"fn".params[${index}].type.?`;
  const fixedValues = fixedArguments.map((argument, index) =>
    `@as(${abiParameterType(index)}, ${
      toAbiParameterExpression(node, argument, fixedNames[index], context)
    })`
  );
  const untypedFormatValue = charFormat
    ? "format.ptr"
    : toAbiParameterExpression(node, formatArgument, "format", context);
  const formatValue = `@as(${abiParameterType(fixedArguments.length)}, ${untypedFormatValue})`;
  const tuple = fixedValues.length > 0
    ? `.{ ${fixedValues.join(", ")}, ${formatValue} }`
    : `.{${formatValue}}`;
  const call = `@call(.auto, c.${node.attributes.name}, ${tuple} ++ args)`;
  if (!returnId || returnType === "void") {
    lines.push(`    ${call};`);
  } else if (conversionKind(returnId, context) === "direct") {
    lines.push(`    return ${call};`);
  } else {
    lines.push(`    const result = ${call};`);
    lines.push(`    return ${fromAbiExpression(returnId, "result", context)};`);
  }
  lines.push("}");
  lines.push("");
}

function renderOwnedOutputByteSliceFunction(
  node: XmlAstNode,
  name: string,
  documentation: string[],
  plan: FunctionPlan,
  context: RenderContext,
  lines: string[],
  moduleNames: Set<string>,
): void {
  if (plan.transformation.kind !== "owned_output_byte_slice") {
    throw new Error(`Invalid owned-output plan for ${node.attributes.name}`);
  }
  const indexes = plan.transformation.info;

  const argumentsList = plan.arguments;
  const otherOutputs = indexes.outputs.filter((output) =>
    output.index !== indexes.dataIndex && output.index !== indexes.lengthIndex
  );
  const hiddenIndexes = new Set([
    indexes.dataIndex,
    indexes.lengthIndex,
    ...otherOutputs.map((output) => output.index),
  ]);
  const visible = renderVisibleFunctionParameters(node, argumentsList, hiddenIndexes, context);

  const resultName = otherOutputs.length > 0
    ? `${context.naming.typeName(node.attributes.name ?? name)}Result`
    : undefined;
  let outputFields = new Map<number, string>();
  if (resultName) {
    if (moduleNames.has(resultName)) {
      throw new Error(`Public result type collision: ${resultName}`);
    }
    moduleNames.add(resultName);
    registerNamespaceExport(node.attributes.name!, resultName, context);
    lines.push("/// Audio data and named output values.");
    lines.push(`pub const ${resultName} = struct {`);
    outputFields = renderOutputFields(otherOutputs, new Set(["data"]), context, lines);
    lines.push("    /// Audio bytes allocated with the caller-provided allocator.");
    lines.push("    data: []u8,");
    lines.push("};");
    lines.push("");
  }

  const parameters = [
    "allocator_: std.mem.Allocator",
    ...visible.rendered.declarations,
  ];
  lines.push(...documentation);
  lines.push(
    `/// Call \`${name}\`, copy its ${context.profile.displayName}-owned audio buffer, and return allocator-backed data.`,
  );
  lines.push(
    `pub inline fn ${name}(${parameters.join(", ")}) ${
      errorUnion(resultName ?? "[]u8", context)
    } {`,
  );
  const cName = node.attributes.name!;
  lines.push(
    `    const DataPointer = @typeInfo(@typeInfo(@TypeOf(c.${cName})).@"fn".params[${indexes.dataIndex}].type.?).pointer.child;`,
  );
  lines.push(
    `    const Length = @typeInfo(@typeInfo(@TypeOf(c.${cName})).@"fn".params[${indexes.lengthIndex}].type.?).pointer.child;`,
  );
  lines.push("    var data_raw: DataPointer = null;");
  lines.push("    var length_raw: Length = 0;");
  renderOutputLocals(cName, otherOutputs, outputFields, lines);
  const overrides = new Map<number, string>([
    [indexes.dataIndex, "&data_raw"],
    [indexes.lengthIndex, "&length_raw"],
  ]);
  for (const output of otherOutputs) {
    overrides.set(output.index, `@ptrCast(&${outputFields.get(output.index)!}_raw)`);
  }
  const callArguments = reconstructCallArguments(argumentsList.length, visible, overrides);
  lines.push(
    `    if (!c.${cName}(${callArguments.join(", ")})) return error.SdlFailure;`,
  );
  lines.push("    const output_source = data_raw;");
  lines.push("    if (output_source == null) return error.SdlFailure;");
  lines.push(
    `    defer c.${releaseFunctionFor(node, context)}(@ptrCast(output_source));`,
  );
  lines.push(
    "    const length = std.math.cast(usize, length_raw) orelse return error.SdlFailure;",
  );
  lines.push(
    "    const data = allocator_.alloc(u8, length) catch return error.OutOfMemory;",
  );
  lines.push("    @memcpy(data, @as([*]const u8, @ptrCast(output_source))[0..length]);");
  if (!resultName) {
    lines.push("    return data;");
  } else {
    lines.push(`    return ${resultName}{`);
    renderOutputInitializers(
      otherOutputs,
      outputFields,
      visible.arguments,
      visible.names,
      context,
      lines,
      "        ",
    );
    lines.push("        .data = data,");
    lines.push("    };");
  }
  lines.push("}");
  lines.push("");
}

function ownedOutputByteSliceIndexes(
  node: XmlAstNode,
  returnId: string,
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
): { dataIndex: number; lengthIndex: number } | undefined {
  if (!isBoolType(returnId, context)) return undefined;
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase() ?? "";
  if (!mentionsReleaseFunction(comment, context)) return undefined;
  const dataIndex = argumentsList.findIndex((argument) =>
    isPointerToBytePointer(argument.type, context)
  );
  if (dataIndex < 0) return undefined;
  const lengthIndex = argumentsList.findIndex((argument, index) =>
    index !== dataIndex &&
    /(?:len|length|size|bytes)/i.test(argument.name) &&
    isIntegerOutputPointer(argument.type, context)
  );
  return lengthIndex >= 0 ? { dataIndex, lengthIndex } : undefined;
}

function isPointerToBytePointer(id: string, context: RenderContext): boolean {
  const inner = pointedType(id, context);
  const target = inner?.kind === "PointerType" ? pointedType(inner.id, context) : undefined;
  return target?.kind === "FundamentalType" &&
    /char/.test(target.attributes.name?.toLowerCase() ?? "");
}

function renderOutputResultFunction(
  node: XmlAstNode,
  name: string,
  functionDocumentation: string[],
  plan: FunctionPlan,
  context: RenderContext,
  lines: string[],
  moduleNames: Set<string>,
): void {
  if (plan.transformation.kind !== "output_result") {
    throw new Error(`Invalid output-result plan for ${node.attributes.name}`);
  }
  const returnId = plan.returnId;
  const { mode, outputs } = plan.transformation.info;
  const argumentsList = plan.arguments;

  const cName = node.attributes.name!;
  const resultName = `${context.naming.typeName(cName)}Result`;
  if (moduleNames.has(resultName)) {
    throw new Error(`Public result type collision: ${resultName}`);
  }
  moduleNames.add(resultName);
  registerNamespaceExport(cName, resultName, context);
  const usedFields = new Set<string>(outputResultHasPrimaryValue(mode) ? ["value"] : []);
  lines.push("/// Named output values.");
  lines.push(`pub const ${resultName} = struct {`);
  if (outputResultHasPrimaryValue(mode)) {
    lines.push(`    /// Primary return value from \`${name}\`.`);
    lines.push(`    value: ${renderPublicApiType(returnId, context)},`);
  }
  const outputFields = renderOutputFields(outputs, usedFields, context, lines);
  lines.push("};");
  lines.push("");

  const visible = renderVisibleFunctionParameters(
    node,
    argumentsList,
    new Set(outputs.map((output) => output.index)),
    context,
  );
  lines.push(...functionDocumentation);
  lines.push("/// Returns named output values.");
  lines.push(
    `pub inline fn ${name}(${visible.rendered.declarations.join(", ")}) ${
      outputResultReturnType(mode, resultName, context)
    } {`,
  );
  renderOutputLocals(cName, outputs, outputFields, lines);
  const callArguments = reconstructCallArguments(
    argumentsList.length,
    visible,
    new Map(outputs.map((output) => [output.index, `&${outputFields.get(output.index)!}_raw`])),
  );
  const call = `c.${cName}(${callArguments.join(", ")})`;
  if (mode === "bool_error") {
    lines.push(`    if (!${call}) return error.SdlFailure;`);
  } else if (mode === "bool_optional") {
    lines.push(`    if (!${call}) return null;`);
  } else if (mode === "void") {
    lines.push(`    ${call};`);
  } else {
    lines.push(`    const value_raw = ${call};`);
    if (mode === "value_error") {
      const failure = plan.failure;
      if (!failure) throw new Error(`Missing failure mode for ${cName}`);
      lines.push(
        `    if (${failureCondition(failure, "value_raw")}) return error.SdlFailure;`,
      );
    }
  }
  lines.push(`    return ${resultName}{`);
  if (outputResultHasPrimaryValue(mode)) {
    lines.push(`        .value = ${fromAbiExpression(returnId, "value_raw", context)},`);
  }
  renderOutputInitializers(
    outputs,
    outputFields,
    visible.arguments,
    visible.names,
    context,
    lines,
    "        ",
  );
  lines.push("    };");
  lines.push("}");
  lines.push("");
}

function outputResultMode(
  returnId: string,
  failure: FailureMode | undefined,
  context: RenderContext,
): OutputResultMode | undefined {
  if (!returnId) return undefined;
  if (isBoolType(returnId, context)) {
    return failure === "bool" ? "bool_error" : "bool_optional";
  }
  const returnType = unwrapTransparentType(returnId, context);
  if (returnType?.kind === "FundamentalType" && returnType.attributes.name === "void") {
    return "void";
  }
  // Pointer returns need ownership and failure analysis before output parameters can be hidden.
  if (conversionKind(returnId, context) === "pointer") return undefined;
  return failure ? "value_error" : "value";
}

function outputResultReturnType(
  mode: OutputResultMode,
  resultType: string,
  context: RenderContext,
): string {
  if (mode === "bool_error" || mode === "value_error") return errorUnion(resultType, context);
  if (mode === "bool_optional") return `?${resultType}`;
  return resultType;
}

function outputResultHasPrimaryValue(mode: OutputResultMode): boolean {
  return mode === "value" || mode === "value_error";
}

function rawOutputType(cName: string, parameterIndex: number): string {
  return `@typeInfo(@typeInfo(@TypeOf(c.${cName})).@"fn".params[${parameterIndex}].type.?).pointer.child`;
}

function renderOutputFields(
  outputs: OutputValue[],
  used: Set<string>,
  context: RenderContext,
  lines: string[],
): Map<number, string> {
  const fields = new Map<number, string>();
  for (const output of outputs) {
    const name = uniqueIdentifier(
      context.naming.fieldName(output.argument.name || `result_${output.index}`),
      used,
    );
    fields.set(output.index, name);
    lines.push(`    /// Output \`${output.argument.name}\`.`);
    lines.push(
      `    ${name}: ${
        output.kind === "resource" && output.nullable ? "?" : ""
      }${output.publicType},`,
    );
  }
  return fields;
}

function renderOutputLocals(
  cName: string,
  outputs: OutputValue[],
  fields: ReadonlyMap<number, string>,
  lines: string[],
  indentation = "    ",
): void {
  for (const output of outputs) {
    const name = fields.get(output.index)!;
    lines.push(
      output.kind === "resource"
        ? `${indentation}var ${name}_raw: ?*c.${output.rawName} = null;`
        : `${indentation}var ${name}_raw: ${rawOutputType(cName, output.index)} = undefined;`,
    );
  }
}

function renderOutputInitializers(
  outputs: OutputValue[],
  fields: ReadonlyMap<number, string>,
  argumentsList: Array<{ name: string; type: string }>,
  argumentNames: string[],
  context: RenderContext,
  lines: string[],
  indentation: string,
  ignoredParentRecordId?: string,
): void {
  for (const output of outputs) {
    const name = fields.get(output.index)!;
    let expression: string;
    if (output.kind === "resource") {
      const record = context.byId.get(output.recordId);
      if (!record) throw new Error(`Missing resource record ${output.recordId}`);
      expression = outputResourceExpression(
        output,
        record,
        `${name}_raw`,
        context,
        dependentResourceParentForRecord(
          record,
          argumentsList,
          argumentNames,
          context,
          ignoredParentRecordId,
        ),
      );
    } else {
      expression = fromAbiExpression(output.targetId, `${name}_raw`, context);
    }
    lines.push(`${indentation}.${name} = ${expression},`);
  }
}

function outputResourceExpression(
  output: Extract<OutputValue, { kind: "resource" }>,
  record: XmlAstNode,
  rawExpression: string,
  context: RenderContext,
  parentExpression?: string,
): string {
  if (output.nullable) {
    return `if (${rawExpression}) |value| ${
      resourceInitializer(record, output.publicType, "value", context, parentExpression)
    } else null`;
  }
  return resourceInitializer(
    record,
    output.publicType,
    `${rawExpression} orelse return error.SdlFailure`,
    context,
    parentExpression,
  );
}

function collectOutputValues(
  node: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
  sliceRelationships = documentedSliceRelationships(node, argumentsList, context),
): OutputValue[] {
  const documentation = matchedDocumentation(node, context);
  const outputs: OutputValue[] = [];
  const slicePointerIndexes = new Set(
    sliceRelationships.flatMap((relationship) => relationship.pointerIndexes),
  );
  for (const [index, argument] of argumentsList.entries()) {
    if (slicePointerIndexes.has(index)) continue;
    const description = documentationParameterDescription(
      documentation?.comment ?? "",
      argument.name,
    )
      .toLowerCase();
    if (!isDocumentedOutputParameter(description)) continue;
    const resource = outputResourceType(argument.type, context);
    if (resource) {
      const comment = documentation?.comment.toLowerCase().replace(/\s+/g, " ") ?? "";
      outputs.push({
        kind: "resource",
        index,
        argument,
        publicType: resource.publicName,
        rawName: resource.rawName,
        recordId: resource.recordId,
        nullable: /\b(?:may|can)\b[^.]{0,180}\bnull\b/.test(description) ||
          /\b(?:can|may|will)\s+fill\b.{0,220}\bnull\b.{0,220}\bnot an error\b/.test(
            comment,
          ),
      });
      continue;
    }
    const pointer = unwrapTransparentType(argument.type, context);
    if (pointer?.kind !== "PointerType" || !pointer.attributes.type) continue;
    const immediateTarget = context.byId.get(pointer.attributes.type);
    if (immediateTarget?.kind === "CvQualifiedType" && immediateTarget.attributes.const === "1") {
      continue;
    }
    const target = unwrapTransparentType(pointer.attributes.type, context);
    if (
      !target || target.kind === "FunctionType" ||
      (target.kind === "FundamentalType" && target.attributes.name === "void") ||
      resourceTypeName(target.id, context)
    ) continue;
    outputs.push({
      kind: "value",
      index,
      argument,
      publicType: renderPublicApiType(pointer.attributes.type, context),
      targetId: pointer.attributes.type,
    });
  }
  return outputs;
}

function isDocumentedOutputParameter(description: string): boolean {
  const normalized = description.toLowerCase().replace(/\s+/g, " ").trim();
  if (!normalized) return false;
  // Buffers and arrays need an explicit pointer/count transformation, not a one-value result.
  if (/\b(?:array|buffer)\b/.test(normalized)) return false;
  // Describe the parameter itself, not values indirectly referenced by a callback or va_list.
  if (/\bof pointers?\s+to values?\b/.test(normalized)) return false;
  if (/\b(?:copied|copy)\s+from\b/.test(normalized)) return false;
  return /\b(?:filled(?:\s+in)?|initialized)\s+(?:with|by)\b/.test(normalized) ||
    /\b(?:will|is|are)\s+(?:be\s+)?(?:filled|initialized|stored|written|set)\b/.test(
      normalized,
    ) ||
    /\b(?:pointer|place|variable)\s+to\s+(?:hold|receive|store)\b/.test(normalized) ||
    /\b(?:receives?|holds?)\s+(?:the|a|an)\b/.test(normalized) ||
    /\b(?:filled|stored|written|supplied)\s+(?:here|with|to this)\b/.test(normalized) ||
    /\b(?:on (?:successful )?output|output pointer|resulting)\b/.test(normalized);
}

function documentationParameterDescription(comment: string, name: string): string {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return comment.match(new RegExp("^- `" + escaped + "`:\\s*(.*)$", "m"))?.[1] ?? "";
}

function outputResourceType(
  id: string,
  context: RenderContext,
): { publicName: string; rawName: string; recordId: string } | undefined {
  const outer = unwrapTransparentType(id, context);
  if (outer?.kind !== "PointerType" || !outer.attributes.type) return undefined;
  const inner = unwrapTransparentType(outer.attributes.type, context);
  if (inner?.kind !== "PointerType" || !inner.attributes.type) return undefined;
  const record = unwrapTransparentType(inner.attributes.type, context);
  if (!record || !context.resources.has(record.id)) return undefined;
  const publicName = context.publicTypeNames.get(record.id);
  const rawName = context.rawTypeNames.get(record.id) ?? record.attributes.name;
  return publicName && rawName ? { publicName, rawName, recordId: record.id } : undefined;
}

function renderOwnedStringFunction(
  node: XmlAstNode,
  name: string,
  plan: FunctionPlan,
  elementType: string,
  context: RenderContext,
  lines: string[],
): void {
  const argumentsList = plan.arguments;
  const argumentNames = publicParameterNames(argumentsList, context);
  const renderedParameters = renderFunctionParameters(
    node,
    argumentsList,
    argumentNames,
    context,
  );
  const parameters = [
    "allocator_: std.mem.Allocator",
    ...renderedParameters.declarations,
  ];
  lines.push(
    `pub inline fn ${name}(${parameters.join(", ")}) ${
      errorUnion(`[:0]${elementType}`, context)
    } {`,
  );
  lines.push(
    `    const result = c.${node.attributes.name}(${
      renderedParameters.callArguments.join(", ")
    }) orelse return error.SdlFailure;`,
  );
  lines.push(`    defer c.${releaseFunctionFor(node, context)}(result);`);
  lines.push(
    `    const source = std.mem.span(@as([*:0]const ${elementType}, @ptrCast(result)));`,
  );
  lines.push(
    `    const copy = allocator_.allocSentinel(${elementType}, source.len, 0) catch return error.OutOfMemory;`,
  );
  lines.push("    @memcpy(copy, source);");
  lines.push("    return copy;");
  lines.push("}");
  lines.push("");
}

function renderOwnedSliceFunction(
  node: XmlAstNode,
  name: string,
  plan: FunctionPlan,
  info: OwnedArrayInfo,
  context: RenderContext,
  lines: string[],
): void {
  const argumentsList = plan.arguments;
  const visible = renderVisibleFunctionParameters(
    node,
    argumentsList,
    info.countIndex === undefined ? new Set() : new Set([info.countIndex]),
    context,
  );
  const parameters = [
    "allocator_: std.mem.Allocator",
    ...visible.rendered.declarations,
  ];
  const returnType = ownedArrayReturnType(info, context);
  const lengthName = uniqueIdentifier("length", new Set(visible.names));
  lines.push(
    `pub inline fn ${name}(${parameters.join(", ")}) ${errorUnion(returnType, context)} {`,
  );
  if (info.countIndex !== undefined) {
    lines.push(
      `    const Count = @typeInfo(@typeInfo(@TypeOf(c.${node.attributes.name})).@"fn".params[${info.countIndex}].type.?).pointer.child;`,
    );
    lines.push("    var count: Count = 0;");
  }
  const callArguments = reconstructCallArguments(
    argumentsList.length,
    visible,
    info.countIndex === undefined ? new Map() : new Map([[info.countIndex, "&count"]]),
  );
  lines.push(`    const result = c.${node.attributes.name}(${callArguments.join(", ")});`);
  lines.push("    if (result == null) return error.SdlFailure;");
  lines.push(`    defer c.${releaseFunctionFor(node, context)}(@ptrCast(result));`);
  if (info.countIndex === undefined) {
    lines.push(`    var ${lengthName}: usize = 0;`);
    lines.push(
      `    while (result[${lengthName}] != null) : (${lengthName} += 1) {}`,
    );
  } else {
    lines.push(
      `    const ${lengthName} = std.math.cast(usize, count) orelse return error.SdlFailure;`,
    );
  }
  renderOwnedArrayCopy(info, context, lines, lengthName);
  lines.push("}");
  lines.push("");
}

function renderBorrowedSliceFunction(
  node: XmlAstNode,
  name: string,
  plan: FunctionPlan,
  info: BorrowedSliceInfo,
  context: RenderContext,
  lines: string[],
): void {
  const argumentsList = plan.arguments;
  const visible = renderVisibleFunctionParameters(
    node,
    argumentsList,
    new Set([info.countIndex]),
    context,
  );
  const cName = node.attributes.name!;
  const failure = plan.failure === "null";
  lines.push(
    `pub inline fn ${name}(${visible.rendered.declarations.join(", ")}) ${
      failure ? `${errorType(context)}!` : ""
    }[]const ${info.elementType} {`,
  );
  lines.push(`    var count: ${rawOutputType(cName, info.countIndex)} = 0;`);
  const callArguments = reconstructCallArguments(
    argumentsList.length,
    visible,
    new Map([[info.countIndex, "&count"]]),
  );
  lines.push(`    const result = c.${cName}(${callArguments.join(", ")});`);
  lines.push(
    `    if (result == null) return ${failure ? "error.SdlFailure" : "&.{}"};`,
  );
  lines.push(
    "    const length = std.math.cast(usize, count) orelse " +
      (failure ? "return error.SdlFailure;" : "return &.{};"),
  );
  lines.push(
    `    return @as([*]const ${info.elementType}, @ptrCast(result))[0..length];`,
  );
  lines.push("}");
  lines.push("");
}

function borrowedSliceInfo(
  node: XmlAstNode,
  returnId: string,
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
): BorrowedSliceInfo | undefined {
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase().replace(/\s+/g, " ") ?? "";
  if (
    !/\b(?:internal\b.{0,100}\barray|(?:should|must)\s+not\s+be\s+freed|owned by (?:sdl|the library))\b/
      .test(comment) ||
    mentionsReleaseFunction(comment, context)
  ) return undefined;
  const pointer = unwrapTransparentType(returnId, context);
  if (pointer?.kind !== "PointerType" || !pointer.attributes.type) return undefined;
  const immediate = context.byId.get(pointer.attributes.type);
  if (immediate?.kind !== "CvQualifiedType" || immediate.attributes.const !== "1") {
    return undefined;
  }
  const element = unwrapTransparentType(pointer.attributes.type, context);
  if (
    !element || element.kind === "FunctionType" ||
    (element.kind === "FundamentalType" &&
      (element.attributes.name === "void" || element.attributes.name === "char")) ||
    resourceTypeName(element.id, context)
  ) return undefined;
  const countIndex = argumentsList.findIndex((argument) =>
    /(?:count|length|num)/i.test(argument.name) &&
    isIntegerOutputPointer(argument.type, context)
  );
  if (countIndex < 0) return undefined;
  return {
    countIndex,
    elementType: renderPublicApiType(pointer.attributes.type, context),
  };
}

function ownedArrayInfo(
  node: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
): OwnedArrayInfo | undefined {
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase() ?? "";
  if (!mentionsReleaseFunction(comment, context)) return undefined;

  const returnId = functionReturnId(node, context);
  const pointer = unwrapTransparentType(returnId, context);
  if (pointer?.kind !== "PointerType" || !pointer.attributes.type) return undefined;
  const elementId = pointer.attributes.type;
  const element = unwrapTransparentType(elementId, context);
  if (!element || (element.kind === "FundamentalType" && element.attributes.name === "void")) {
    return undefined;
  }

  const countIndex = argumentsList.findIndex((argument) =>
    /(?:count|length|num_)/i.test(argument.name) &&
    isIntegerOutputPointer(argument.type, context)
  );

  if (element.kind !== "PointerType" || !element.attributes.type) {
    return countIndex >= 0 ? { kind: "values", countIndex, elementId } : undefined;
  }

  const pointedId = element.attributes.type;
  const pointed = unwrapTransparentType(pointedId, context);
  if (!pointed) return undefined;
  if (pointed.kind === "FundamentalType" && pointed.attributes.name === "char") {
    if (countIndex >= 0) return { kind: "strings", countIndex, elementId: pointedId };
    return /\bnull[ -]terminated\b/.test(comment)
      ? { kind: "strings", elementId: pointedId }
      : undefined;
  }

  const resourceName = resourceTypeName(pointedId, context);
  if (resourceName && countIndex >= 0) {
    return {
      kind: "resources",
      countIndex,
      elementId: pointedId,
      resourceName,
    };
  }

  if ((pointed.kind === "Struct" || pointed.kind === "Union") && countIndex >= 0) {
    if (isOpaqueRecord(pointed)) {
      return { kind: "values", countIndex, elementId };
    }
    const stringRecord = context.ownedStringRecords.get(pointed.id);
    return stringRecord
      ? {
        kind: "string_records",
        countIndex,
        elementId: pointedId,
        record: stringRecord,
      }
      : { kind: "pointed_records", countIndex, elementId: pointedId };
  }
  return undefined;
}

function ownedArrayReturnType(info: OwnedArrayInfo, context: RenderContext): string {
  switch (info.kind) {
    case "strings":
      return "OwnedStrings";
    case "string_records":
      return info.record.collectionName;
    case "resources":
      return `[]${info.resourceName}`;
    case "values":
    case "pointed_records":
      return `[]${renderPublicType(info.elementId, context)}`;
  }
}

function renderOwnedArrayCopy(
  info: OwnedArrayInfo,
  context: RenderContext,
  lines: string[],
  lengthName: string,
): void {
  switch (info.kind) {
    case "strings":
      renderOwnedStringsCopy(lines, lengthName);
      return;
    case "string_records":
      renderOwnedStringRecordCopy(info, context, lines, lengthName);
      return;
    case "resources":
    case "pointed_records":
    case "values":
      renderOwnedPlainArrayCopy(info, context, lines, lengthName);
  }
}

function renderOwnedPlainArrayCopy(
  info: Extract<OwnedArrayInfo, { kind: "values" | "pointed_records" | "resources" }>,
  context: RenderContext,
  lines: string[],
  lengthName: string,
): void {
  const elementType = info.kind === "resources"
    ? info.resourceName
    : renderPublicType(info.elementId, context);
  lines.push(
    `    const copy = allocator_.alloc(${elementType}, ${lengthName}) catch return error.OutOfMemory;`,
  );
  lines.push("    errdefer allocator_.free(copy);");
  switch (info.kind) {
    case "values":
      if (conversionKind(info.elementId, context) === "direct") {
        lines.push(`    @memcpy(copy, result[0..${lengthName}]);`);
      } else {
        lines.push("    for (copy, 0..) |*item, index| {");
        lines.push(
          `        item.* = ${fromAbiExpression(info.elementId, "result[index]", context)};`,
        );
        lines.push("    }");
      }
      break;
    case "pointed_records":
    case "resources":
      lines.push("    for (copy, 0..) |*item, index| {");
      lines.push("        const source = result[index];");
      lines.push("        if (source == null) return error.SdlFailure;");
      lines.push(
        info.kind === "resources"
          ? "        item.* = .{ .value = @ptrCast(source) };"
          : `        item.* = ${fromAbiExpression(info.elementId, "source.*", context)};`,
      );
      lines.push("    }");
  }
  lines.push("    return copy;");
}

function renderOwnedStringsCopy(lines: string[], lengthName: string): void {
  lines.push(
    `    const items = allocator_.alloc([:0]u8, ${lengthName}) catch return error.OutOfMemory;`,
  );
  lines.push("    var initialized: usize = 0;");
  lines.push("    errdefer {");
  lines.push("        for (items[0..initialized]) |item| allocator_.free(item);");
  lines.push("        allocator_.free(items);");
  lines.push("    }");
  lines.push("    for (items, 0..) |*item, index| {");
  lines.push("        const source = result[index];");
  lines.push("        if (source == null) return error.SdlFailure;");
  lines.push(
    "        item.* = support.copyOwnedZString(allocator_, @ptrCast(source)) catch return error.OutOfMemory;",
  );
  lines.push("        initialized += 1;");
  lines.push("    }");
  lines.push("    return .{ .allocator = allocator_, .items = items };");
}

function renderOwnedStringRecordCopy(
  info: Extract<OwnedArrayInfo, { kind: "string_records" }>,
  context: RenderContext,
  lines: string[],
  lengthName: string,
): void {
  lines.push(
    `    const items = allocator_.alloc(${info.record.valueName}, ${lengthName}) catch return error.OutOfMemory;`,
  );
  lines.push("    var initialized: usize = 0;");
  lines.push("    errdefer {");
  lines.push("        for (items[0..initialized]) |item| {");
  for (const field of info.record.fields) {
    if (field.kind === "string") {
      lines.push(
        `            if (item.${field.publicName}) |value| allocator_.free(value);`,
      );
    }
  }
  lines.push("        }");
  lines.push("        allocator_.free(items);");
  lines.push("    }");
  lines.push("    for (items, 0..) |*item, index| {");
  lines.push("        const source = result[index];");
  lines.push("        if (source == null) return error.SdlFailure;");
  lines.push("        item.* = .{");
  for (const field of info.record.fields) {
    if (field.kind === "string") {
      lines.push(`            .${field.publicName} = null,`);
    } else {
      lines.push(
        `            .${field.publicName} = ${
          fromAbiExpression(
            field.typeId,
            `source.*.${field.sourceName}`,
            context,
          )
        },`,
      );
    }
  }
  lines.push("        };");
  lines.push("        initialized += 1;");
  for (const field of info.record.fields) {
    if (field.kind !== "string") continue;
    lines.push(`        if (source.*.${field.sourceName} != null) {`);
    lines.push(
      `            item.${field.publicName} = support.copyOwnedZString(allocator_, @ptrCast(source.*.${field.sourceName})) catch return error.OutOfMemory;`,
    );
    lines.push("        }");
  }
  lines.push("    }");
  lines.push("    return .{ .allocator = allocator_, .items = items };");
}

function renderOwnedByteSliceFunction(
  node: XmlAstNode,
  name: string,
  plan: FunctionPlan,
  countIndex: number,
  context: RenderContext,
  lines: string[],
): void {
  const argumentsList = plan.arguments;
  const visible = renderVisibleFunctionParameters(
    node,
    argumentsList,
    new Set([countIndex]),
    context,
  );
  const parameters = [
    "allocator_: std.mem.Allocator",
    ...visible.rendered.declarations,
  ];
  lines.push(`pub inline fn ${name}(${parameters.join(", ")}) ${errorUnion("[:0]u8", context)} {`);
  lines.push("    var byte_count: usize = 0;");
  const callArguments = reconstructCallArguments(
    argumentsList.length,
    visible,
    new Map([[countIndex, "&byte_count"]]),
  );
  lines.push(
    `    const result = c.${node.attributes.name}(${
      callArguments.join(", ")
    }) orelse return error.SdlFailure;`,
  );
  lines.push(`    defer c.${releaseFunctionFor(node, context)}(result);`);
  lines.push("    const source: [*]const u8 = @ptrCast(result);");
  lines.push(
    "    const copy = allocator_.allocSentinel(u8, byte_count, 0) catch return error.OutOfMemory;",
  );
  lines.push("    @memcpy(copy, source[0..byte_count]);");
  lines.push("    return copy;");
  lines.push("}");
  lines.push("");
}

function ownedByteSliceCountIndex(
  node: XmlAstNode,
  returnId: string,
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
): number | undefined {
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase() ?? "";
  if (!comment.includes("freed with") || !mentionsReleaseFunction(comment, context)) {
    return undefined;
  }
  const target = pointedType(returnId, context);
  if (target?.kind !== "FundamentalType" || target.attributes.name !== "void") return undefined;
  const countIndex = argumentsList.findIndex((argument) =>
    /(?:size|length|bytes)/i.test(argument.name) &&
    isIntegerOutputPointer(argument.type, context)
  );
  return countIndex >= 0 ? countIndex : undefined;
}

function isCharPointerType(id: string, context: RenderContext): boolean {
  const target = pointedType(id, context);
  return target?.kind === "FundamentalType" && target.attributes.name === "char";
}

function isOwnedStringFunction(
  node: XmlAstNode,
  returnId: string,
  context: RenderContext,
): boolean {
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase() ?? "";
  const callerOwned = comment.includes("owned by the caller") &&
    mentionsReleaseFunction(comment, context);
  const explicitlyFreed = comment.includes("freed with") &&
    mentionsReleaseFunction(comment, context);
  return (callerOwned || explicitlyFreed) &&
    ownedStringElementType(returnId, context) !== undefined;
}

function ownedStringElementType(id: string, context: RenderContext): string | undefined {
  const pointer = unwrapTransparentType(id, context);
  if (pointer?.kind !== "PointerType" || !pointer.attributes.type) return undefined;
  const target = pointedType(id, context);
  if (target?.kind === "FundamentalType" && target.attributes.name === "char") return "u8";
  const type = renderPublicType(pointer.attributes.type, context);
  return type === "std.c.wchar_t" ? type : undefined;
}

function renderOwnedVariadicStringFunction(
  node: XmlAstNode,
  name: string,
  context: RenderContext,
  lines: string[],
): void {
  const abiParameterType = (index: number) =>
    `@typeInfo(@TypeOf(c.${node.attributes.name})).@"fn".params[${index}].type.?`;
  lines.push(
    `pub inline fn ${name}(allocator_: std.mem.Allocator, comptime format: [:0]const u8, args: anytype) ${
      errorUnion("[:0]u8", context)
    } {`,
  );
  lines.push("    var result: ?[*:0]u8 = null;");
  lines.push(
    `    const length = @call(.auto, c.${node.attributes.name}, .{ @as(${
      abiParameterType(0)
    }, @ptrCast(&result)), @as(${abiParameterType(1)}, format.ptr) } ++ args);`,
  );
  lines.push("    if (length < 0) return error.SdlFailure;");
  lines.push("    const source = result orelse return error.SdlFailure;");
  lines.push(`    defer c.${releaseFunctionFor(node, context)}(source);`);
  lines.push("    const copy_length: usize = @intCast(length);");
  lines.push(
    "    const copy = allocator_.allocSentinel(u8, copy_length, 0) catch return error.OutOfMemory;",
  );
  lines.push("    @memcpy(copy, source[0..copy_length]);");
  lines.push("    return copy;");
  lines.push("}");
  lines.push("");
}

function isOwnedVariadicStringOutputFunction(
  node: XmlAstNode,
  argumentsList: Array<{ name: string; type: string }>,
  returnId: string,
  variadic: boolean,
  context: RenderContext,
): boolean {
  if (!variadic) return false;
  const documentation = matchedDocumentation(node, context);
  const comment = documentation?.comment.toLowerCase() ?? "";
  if (
    !comment.includes("owned by the caller") ||
    !mentionsReleaseFunction(comment, context)
  ) return false;
  if (
    argumentsList.length !== 2 ||
    !isPointerToCharPointer(argumentsList[0].type, context) ||
    !isConstCharPointerType(argumentsList[1].type, context)
  ) return false;
  return isIntegerValueType(returnId, context);
}

function isPointerToCharPointer(id: string, context: RenderContext): boolean {
  const target = pointedType(id, context);
  return target?.kind === "PointerType" && isCharPointerType(target.id, context);
}

function isIntegerOutputPointer(id: string, context: RenderContext): boolean {
  const target = pointedType(id, context);
  return target?.kind === "FundamentalType" &&
    /int|long|short/.test(target.attributes.name?.toLowerCase() ?? "");
}

function renderNamespaces(context: RenderContext, lines: string[]): void {
  const namespaces = collectNamespaceMembers(context);
  for (const namespace of [...namespaces.keys()].sort()) {
    const categoryDocumentation = categoryDocumentationForNamespace(namespace, context);
    lines.push(...renderDocComment(
      categoryDocumentation?.comment ??
        `${context.profile.displayName} APIs for the ${namespace} subsystem.`,
    ));
    renderTargetSelectedNamespace(namespace, namespaces.get(namespace)!, context, lines);
    lines.push("");
  }
}

function renderTargetSelectedNamespace(
  namespace: string,
  members: Map<string, string>,
  context: RenderContext,
  lines: string[],
): void {
  const hasTargetSpecificMembers = [...members.values()].some((publicName) =>
    namespaceMemberPlatforms(publicName, context) !== undefined
  );
  if (!hasTargetSpecificMembers) {
    lines.push(`pub const ${namespace} = struct {`);
    renderNamespaceMembers(members, "    ", lines);
    lines.push("};");
    return;
  }

  const platforms = [...new Set(context.model.analysisTargets.map(targetPlatform))].sort();
  for (const [index, platform] of platforms.entries()) {
    const prefix = index === 0 ? `pub const ${namespace} = if` : "} else if";
    lines.push(`${prefix} (${platformConditionForName(platform)}) struct {`);
    renderNamespaceMembers(
      namespaceMembersForPlatform(members, platform, context),
      "    ",
      lines,
    );
  }
  lines.push("} else struct {");
  renderNamespaceMembers(
    namespaceMembersForPlatform(members, undefined, context),
    "    ",
    lines,
  );
  lines.push("};");
}

function namespaceMembersForPlatform(
  members: Map<string, string>,
  platform: string | undefined,
  context: RenderContext,
): Map<string, string> {
  return new Map(
    [...members.entries()].filter(([, publicName]) => {
      const platforms = namespaceMemberPlatforms(publicName, context);
      return platforms === undefined || (platform !== undefined && platforms.includes(platform));
    }),
  );
}

function namespaceMemberPlatforms(
  publicName: string,
  context: RenderContext,
): string[] | undefined {
  const item = context.namespaceExports.find((candidate) => candidate.publicName === publicName);
  if (!item) throw new Error(`Missing namespace export metadata for ${publicName}`);
  const targets = declarationTargets(item.cName, context);
  if (!targets || targets.length === context.model.analysisTargets.length) return undefined;
  return [...new Set(targets.map(targetPlatform))].sort();
}

function renderNamespaceMembers(
  members: Map<string, string>,
  indentation: string,
  lines: string[],
): void {
  for (
    const [memberName, publicName] of [...members.entries()].sort(([left], [right]) =>
      left.localeCompare(right)
    )
  ) {
    lines.push(`${indentation}pub const ${memberName} = root.${publicName};`);
  }
}

function collectPublicSymbols(context: RenderContext): PublicSymbol[] {
  const namespaces = collectNamespaceMembers(context);
  const cNames = new Set([
    ...context.emittedNames.keys(),
    ...context.documentationMembers.keys(),
  ]);
  const symbols: PublicSymbol[] = [];
  for (const cName of cNames) {
    const member = context.documentationMembers.get(cName);
    let path: string | undefined;
    if (member) {
      path = `${
        canonicalPublicPath(
          member.ownerCName,
          member.ownerPublicName,
          context,
          namespaces,
        )
      }.${member.memberName}`;
    } else {
      const publicName = context.emittedNames.get(cName);
      if (publicName) path = canonicalPublicPath(cName, publicName, context, namespaces);
    }
    if (!path) continue;
    const node = context.nodesByName.get(cName)?.[0];
    const constant = context.constantsByName.get(cName);
    symbols.push({
      cName,
      path,
      kind: node?.kind.toLowerCase() ?? constant?.source ?? "declaration",
    });
  }
  return symbols.sort((left, right) =>
    left.cName.localeCompare(right.cName) ||
    left.path.localeCompare(right.path) ||
    left.kind.localeCompare(right.kind)
  );
}

function collectNamespaceMembers(context: RenderContext): Map<string, Map<string, string>> {
  const namespaces = new Map<string, Map<string, string>>();
  const rootNames = new Set(context.namespaceExports.map((item) => item.publicName));
  for (const { cName, publicName } of context.namespaceExports) {
    const header = declarationHeader(cName, context);
    const namespace = effectiveNamespaceFor(header, cName, context);
    if (!namespace || rootNames.has(namespace)) continue;
    const memberName = namespaceMemberName(namespace, cName, publicName, context);
    const members = namespaces.get(namespace) ?? new Map<string, string>();
    const existing = members.get(memberName);
    if (existing && existing !== publicName) {
      members.delete(memberName);
      if (
        (members.has(existing) && members.get(existing) !== existing) ||
        (members.has(publicName) && members.get(publicName) !== publicName) ||
        existing === publicName
      ) {
        throw new Error(
          `Unresolvable public namespace collision: ${namespace}.${memberName}`,
        );
      }
      members.set(existing, existing);
      members.set(publicName, publicName);
    } else {
      members.set(memberName, publicName);
    }
    namespaces.set(namespace, members);
  }
  return namespaces;
}

function registerPrimaryEmission(
  cName: string,
  publicName: string,
  context: RenderContext,
): void {
  context.emittedNames.set(cName, publicName);
  registerNamespaceExport(cName, publicName, context);
}

function registerNamespaceExport(
  cName: string,
  publicName: string,
  context: RenderContext,
): void {
  if (
    !context.namespaceExports.some((item) => item.cName === cName && item.publicName === publicName)
  ) {
    context.namespaceExports.push({ cName, publicName });
  }
}

function registerDocumentationMember(
  cName: string,
  ownerCName: string,
  ownerPublicName: string,
  memberName: string,
  context: RenderContext,
): void {
  const existing = context.documentationMembers.get(cName);
  if (
    existing &&
    (
      existing.ownerCName !== ownerCName ||
      existing.ownerPublicName !== ownerPublicName ||
      existing.memberName !== memberName
    )
  ) {
    throw new Error(`Ambiguous documentation path for ${cName}`);
  }
  context.documentationMembers.set(cName, {
    ownerCName,
    ownerPublicName,
    memberName,
  });
}

function privatizeNamespacedDeclarations(
  context: RenderContext,
  lines: string[],
): void {
  const privateNames = new Set(
    context.namespaceExports
      .filter(({ cName }) =>
        effectiveNamespaceFor(declarationHeader(cName, context), cName, context) !== ""
      )
      .map(({ publicName }) => publicName),
  );
  for (let index = lines.length - 1; index >= 0; index--) {
    const line = lines[index];
    const declaration = line.match(
      /^pub (?:inline )?(?:const|fn|var)\s+((?:@"[^"]+")|[A-Za-z_][A-Za-z0-9_]*)/,
    );
    if (declaration && privateNames.has(declaration[1])) {
      lines[index] = line.slice("pub ".length);
    }
  }
}

function declarationHeader(cName: string, context: RenderContext): string {
  const node = context.nodesByName.get(cName)?.find((candidate) =>
    context.publicIds.has(candidate.id)
  );
  const header = node ? sourceHeaderForNode(node, context) : "";
  if (header) return header;
  const constant = context.constantsByName.get(cName);
  if (constant?.header) return constant.header.replaceAll("\\", "/").split("/").at(-1) ?? "";
  const documentation = context.documentationByName.get(cName)?.[0];
  return documentation?.header.replaceAll("\\", "/").split("/").at(-1) ?? "";
}

function sourceHeaderForNode(node: XmlAstNode, context: RenderContext): string {
  const location = context.model.locations[node.attributes.location];
  const fileReference = node.attributes.file || location?.file;
  const file = (fileReference ? context.model.files[fileReference] : undefined) ?? fileReference;
  return file?.replaceAll("\\", "/").split("/").at(-1) ?? "";
}

function namespaceFor(header: string, _cName: string, context: RenderContext): string {
  if (context.profile.namespaceStrategy.kind === "documented_category") {
    const category = context.headerDocumentationByHeader.get(header)?.category;
    return category ? categoryNamespaceName(category, context.naming) : "";
  }
  if (context.profile.rootHeaders.includes(header)) return "";
  if (!header.endsWith(".h")) return "";
  const headerStem = header.slice(0, -".h".length);
  const prefix = context.profile.headerPrefixes.find((candidate) =>
    headerStem.startsWith(candidate)
  );
  if (!prefix) return "";
  const subsystem = headerStem.slice(prefix.length);
  if (!subsystem) return "";
  if (
    subsystem === "begin_code" || subsystem === "close_code" || subsystem === "oldnames" ||
    subsystem === "main_impl" || subsystem.startsWith("test")
  ) return "";
  return context.naming.fieldName(subsystem);
}

function effectiveNamespaceFor(header: string, cName: string, context: RenderContext): string {
  const namespace = namespaceFor(header, cName, context);
  return resolveNamespaceCollision(
    namespace,
    context.namespaceExports.map((item) => item.publicName),
  );
}

export function categoryNamespaceName(category: string, naming: ZigNaming): string {
  if (!category) return "";
  return naming.functionName(category.replace(/^Category/, ""));
}

export function resolveNamespaceCollision(
  namespace: string,
  publicNames: Iterable<string>,
): string {
  return new Set(publicNames).has(namespace) ? "" : namespace;
}

function categoryDocumentationForNamespace(
  namespace: string,
  context: RenderContext,
): ApiModel["headerDocumentation"][number] | undefined {
  return context.model.headerDocumentation.find((documentation) =>
    categoryNamespaceName(documentation.category, context.naming) === namespace
  );
}

function platformNamespace(cName: string, context: RenderContext): string | undefined {
  const targets = declarationTargets(cName, context);
  if (!targets || targets.length === context.model.analysisTargets.length) return undefined;
  const platforms = [...new Set(targets.map(targetPlatform))].sort();
  if (platforms.length === 1) return platforms[0];
  if (
    platforms.length === 2 &&
    platforms.includes("linux") &&
    platforms.includes("macos")
  ) return "unix";
  return platforms.join("_or_");
}

function declarationTargets(cName: string, context: RenderContext): string[] | undefined {
  const node = context.nodesByName.get(cName)?.find((candidate) =>
    context.publicIds.has(candidate.id)
  );
  if (node) return context.model.publicNodeTargets[node.id];
  const constant = context.constantsByName.get(cName);
  return constant
    ? context.model.constantTargets[`${constant.source}:${constant.name}`]
    : undefined;
}

function targetPlatform(target: string): string {
  const normalized = target.toLowerCase();
  if (normalized.includes("windows")) return "windows";
  if (normalized.includes("macos")) return "macos";
  if (normalized.includes("linux")) return "linux";
  throw new Error(`Unsupported platform analysis target: ${target}`);
}

function platformConditionForName(platformName: string): string {
  const platforms = platformName === "unix" ? ["linux", "macos"] : platformName.split("_or_");
  return platforms.map((platform) => `builtin.os.tag == .${platform}`).join(" or ");
}

function namespaceMemberName(
  namespace: string,
  cName: string,
  publicName: string,
  context: RenderContext,
): string {
  const semanticNamespace = namespace;
  const apiPrefix = context.profile.symbolPrefixes[0];
  const namespaceType = context.naming.typeName(`${apiPrefix}${semanticNamespace}`);
  let candidate = publicName;
  if (/^[A-Z]/.test(publicName)) {
    const namespaceWords = context.naming.words(namespaceType);
    const publicWords = context.naming.words(publicName);
    const hasNamespacePrefix = namespaceWords.length < publicWords.length &&
      namespaceWords.every((word, index) => publicWords[index] === word);
    if (hasNamespacePrefix) {
      candidate = context.naming.typeName(
        `${apiPrefix}${publicWords.slice(namespaceWords.length).join("_")}`,
      );
    }
  } else {
    const namespaceValue = context.naming.fieldName(semanticNamespace);
    if (publicName.startsWith(`${namespaceValue}_`)) {
      candidate = publicName.slice(namespaceValue.length + 1);
    } else if (
      publicName.startsWith(namespaceValue) &&
      /[A-Z]/.test(publicName[namespaceValue.length] ?? "")
    ) {
      candidate = publicName.slice(namespaceValue.length);
    }
  }
  const tokenIndex = candidate.indexOf(namespaceType);
  const tokenEnd = tokenIndex + namespaceType.length;
  const tokenIsWord = tokenIndex > 0 &&
    (tokenEnd === candidate.length || /[A-Z0-9_]/.test(candidate[tokenEnd]));
  if (tokenIsWord) {
    const stripped = `${candidate.slice(0, tokenIndex)}${
      candidate.slice(
        tokenEnd,
      )
    }`;
    if (stripped) candidate = stripped;
  }
  return /^[A-Z]/.test(publicName)
    ? context.naming.typeName(`${apiPrefix}${candidate}`)
    : context.constantsByName.has(cName)
    ? context.naming.fieldName(candidate)
    : context.naming.functionName(candidate);
}

function functionArguments(
  node: XmlAstNode,
  context: RenderContext,
): Array<{ name: string; type: string }> {
  const functionType = node.attributes.type ? context.byId.get(node.attributes.type) : undefined;
  const argumentIds = splitIds(
    node.attributes.arguments || node.attributes.parameters || functionType?.attributes.arguments ||
      "",
  );
  const resolvedArgumentIds = argumentIds.length > 0
    ? argumentIds
    : node.members.length > 0
    ? node.members
    : functionType?.members ?? [];
  return resolveSignatureArguments(
    resolvedArgumentIds,
    `function ${node.attributes.name || node.id}`,
    context,
  );
}

function resolveSignatureArguments(
  ids: string[],
  path: string,
  context: RenderContext,
): Array<{ name: string; type: string }> {
  return ids
    .map((id) => {
      const argument = context.byId.get(id);
      if (!argument) {
        throw unsupportedPublicSignature(path, `references missing argument ${id}`);
      }
      return argument;
    })
    .filter((argument) => argument.kind !== "Ellipsis")
    .map((argument) => {
      if (argument.kind !== "Argument" && argument.kind !== "Parameter") {
        throw unsupportedPublicSignature(
          path,
          `contains unexpected signature node ${argument.kind}`,
        );
      }
      if (!argument.attributes.type) {
        throw unsupportedPublicSignature(
          `${path} parameter ${argument.attributes.name || "<unnamed>"}`,
          "has no type",
        );
      }
      return argument;
    })
    .sort((left, right) => left.order - right.order)
    .map((argument) => ({
      name: argument.attributes.name || "",
      type: argument.attributes.type,
    }));
}

function functionReturnId(node: XmlAstNode, context: RenderContext): string {
  const functionType = node.attributes.type ? context.byId.get(node.attributes.type) : undefined;
  return node.attributes.returns || functionType?.attributes.returns || "";
}

function isVariadicFunction(node: XmlAstNode, context: RenderContext): boolean {
  const functionType = node.attributes.type ? context.byId.get(node.attributes.type) : undefined;
  const documentation = matchedDocumentation(node, context);
  return node.attributes.ellipsis === "1" ||
    documentation?.parameters.includes("...") === true ||
    [...node.members, ...(functionType?.members ?? [])].some((id) =>
      context.byId.get(id)?.kind === "Ellipsis"
    );
}

function renderPublicType(id: string, context: RenderContext): string {
  const node = context.byId.get(id);
  if (!node) {
    throw unsupportedPublicSignature("generated type", `references missing CastXML type ${id}`);
  }

  switch (node.kind) {
    case "FundamentalType":
      return publicFundamentalType(node);
    case "Typedef": {
      if (node.attributes.name === "wchar_t") return "std.c.wchar_t";
      const name = context.publicTypeNames.get(node.id);
      if (name && !isPrimitiveTypedef(node)) return name;
      const primitive = primitiveTypedefType(node);
      if (primitive) return primitive;
      if (!node.attributes.type) {
        throw unsupportedPublicSignature(
          `typedef ${node.attributes.name || node.id}`,
          "has no target type",
        );
      }
      return renderPublicType(node.attributes.type, context);
    }
    case "Struct":
    case "Union":
      return context.publicTypeNames.get(node.id) ??
        renderPublicAnonymousAggregate(node, context);
    case "Enumeration":
      return context.publicTypeNames.get(node.id) ?? "c_int";
    case "PointerType":
      return renderPublicPointer(node, context);
    case "CvQualifiedType":
      if (!node.attributes.type) {
        throw unsupportedPublicSignature("qualified type", `${node.id} has no target type`);
      }
      return renderPublicType(node.attributes.type, context);
    case "ArrayType":
      if (!node.attributes.type) {
        throw unsupportedPublicSignature("array type", `${node.id} has no element type`);
      }
      return `[${arrayLength(node)}]${renderPublicType(node.attributes.type, context)}`;
    case "FunctionType":
      return renderPublicFunctionType(node, context);
    case "ElaboratedType":
      if (!node.attributes.type) {
        throw unsupportedPublicSignature("elaborated type", `${node.id} has no target type`);
      }
      return renderPublicType(node.attributes.type, context);
    case "ReferenceType":
      throw unsupportedPublicSignature("generated type", "uses a C++ reference type");
    default:
      throw unsupportedPublicSignature(
        "generated type",
        `uses unsupported CastXML kind ${node.kind}`,
      );
  }
}

function renderPublicApiType(id: string, context: RenderContext): string {
  return isConstCharPointerType(id, context) ? "?[:0]const u8" : renderPublicType(id, context);
}

function renderPublicReturnType(
  node: XmlAstNode,
  returnId: string,
  context: RenderContext,
): string {
  return renderRequiredPointerType(
    returnId,
    isRequiredPointerReturn(node, returnId, context),
    context,
  );
}

function renderPublicParameterType(
  node: XmlAstNode,
  argument: { name: string; type: string },
  context: RenderContext,
): string {
  return renderRequiredPointerType(
    argument.type,
    isRequiredPointerParameter(node, argument, context),
    context,
  );
}

function renderRequiredPointerType(
  id: string,
  required: boolean,
  context: RenderContext,
): string {
  const publicType = renderPublicApiType(id, context);
  if (!required) return publicType;
  if (publicType.startsWith("?")) return publicType.slice(1);
  const pointer = unwrapTransparentType(id, context);
  return pointer?.kind === "PointerType"
    ? withoutOptional(renderPublicPointer(pointer, context))
    : publicType;
}

function toAbiParameterExpression(
  node: XmlAstNode,
  argument: { name: string; type: string },
  name: string,
  context: RenderContext,
): string {
  if (!isRequiredPointerParameter(node, argument, context)) {
    return toAbiExpression(argument.type, name, context);
  }
  if (resourceTypeNameForPointer(argument.type, context)) {
    return `@ptrCast(${name}.value)`;
  }
  if (isConstCharPointerType(argument.type, context)) {
    return `@ptrCast(${name}.ptr)`;
  }
  return `@ptrCast(${name})`;
}

function isRequiredPointerParameter(
  node: XmlAstNode,
  argument: { name: string; type: string },
  context: RenderContext,
): boolean {
  if (unwrapTransparentType(argument.type, context)?.kind !== "PointerType") return false;
  const documentation = matchedDocumentation(node, context);
  const description = documentationParameterDescription(
    documentation?.comment ?? "",
    argument.name,
  ).toLowerCase().replace(/\s+/g, " ");
  if (!description) return false;
  if (
    /\bunless\b/.test(description) ||
    /\b(?:may|can|could)\s+be\s+null\b/.test(description) ||
    /\b(?:or|if|when)\s+null\b/.test(description) ||
    /\bnull\s+(?:to|for|if|when)\b/.test(description)
  ) {
    return false;
  }
  return /\b(?:must|may)\s+not\s+be\s+null\b/.test(description) ||
    /\bcan(?:not|\s+not)\s+be\s+null\b/.test(description) ||
    /\bmust\s+be\s+non-null\b/.test(description) ||
    /\bnull\s+is\s+not\s+(?:permitted|allowed)\b/.test(description);
}

function isRequiredPointerReturn(
  node: XmlAstNode,
  returnId: string,
  context: RenderContext,
): boolean {
  if (unwrapTransparentType(returnId, context)?.kind !== "PointerType") return false;
  const documentation = matchedDocumentation(node, context);
  const description = documentationReturnDescription(documentation?.comment ?? "")
    .toLowerCase().replace(/\s+/g, " ");
  if (!description || /\b(?:or|may|can)\s+(?:be\s+)?null\b/.test(description)) return false;
  if (
    /\b(?:never|cannot|can not|will not)\s+(?:be\s+)?null\b/.test(description) ||
    /\bnon-null\b/.test(description)
  ) return true;
  const argumentsList = context.functionPlans.get(node.id)?.arguments ??
    functionArguments(node, context);
  return argumentsList.some((argument) =>
    isRequiredPointerParameter(node, argument, context) &&
    (
      description.includes(`\`${argument.name.toLowerCase()}\``) ||
      new RegExp(`\\b${argument.name.toLowerCase()}\\s+pointer\\b`).test(description)
    )
  );
}

function renderPublicPointer(node: XmlAstNode, context: RenderContext): string {
  const targetId = node.attributes.type;
  if (!targetId) {
    throw unsupportedPublicSignature("pointer type", `${node.id} has no pointee type`);
  }
  const transparent = unwrapTransparentType(targetId, context);
  if (transparent?.kind === "FunctionType") {
    return `?${renderPublicFunctionType(transparent, context)}`;
  }

  const cv = context.byId.get(targetId);
  const isConst = cv?.kind === "CvQualifiedType" && cv.attributes.const === "1";
  const pointeeId = isConst && cv.attributes.type ? cv.attributes.type : targetId;
  const pointee = unwrapTransparentType(pointeeId, context);
  const resourceName = resourceTypeName(pointeeId, context);
  if (resourceName) return `?${resourceName}`;
  if (pointee?.kind === "PointerType" && typeContainsResource(pointeeId, context)) {
    return renderPublicStorageType(node.id, context);
  }
  if (pointee?.kind === "FundamentalType" && pointee.attributes.name === "char") {
    return isConst ? "?[*:0]const u8" : "?[*]u8";
  }
  if (pointee?.kind === "FundamentalType" && pointee.attributes.name === "void") {
    return isConst ? "?*const anyopaque" : "?*anyopaque";
  }
  const type = renderPublicType(pointeeId, context);
  return isConst ? `?*const ${type}` : `?*${type}`;
}

function renderPublicFunctionType(node: XmlAstNode, context: RenderContext): string {
  const argumentsList = callbackArguments(node, context);
  const names = publicParameterNames(argumentsList, context);
  const parameters = argumentsList.map((argument, index) =>
    `${names[index]}: ${renderPublicType(argument.type, context)}`
  );
  if (isVariadicFunction(node, context)) parameters.push("...");
  const returnType = node.attributes.returns
    ? renderPublicType(node.attributes.returns, context)
    : "void";
  return `*const fn (${parameters.join(", ")}) callconv(.c) ${returnType}`;
}

function renderPublicAnonymousAggregate(node: XmlAstNode, context: RenderContext): string {
  const keyword = node.kind === "Union" ? "extern union" : "extern struct";
  const fields = recordFields(node, context);
  if (fields.length === 0 || fields.some(isBitfield)) {
    throw new Error("Unsupported anonymous empty record or C bitfield");
  }
  const used = new Set<string>();
  const declarations = fields.map((field, index) => {
    const sourceName = field.attributes.name || `field_${index}`;
    const name = uniqueIdentifier(context.naming.fieldName(sourceName), used);
    if (!field.attributes.type) {
      throw unsupportedPublicSignature(
        `anonymous ${node.kind.toLowerCase()} field ${sourceName}`,
        "has no type",
      );
    }
    const type = renderPublicStorageType(field.attributes.type, context);
    return `${name}: ${type}`;
  });
  return `${keyword} { ${declarations.join(", ")} }`;
}

function renderPublicStorageType(id: string, context: RenderContext): string {
  const node = context.byId.get(id);
  if (!node) {
    throw unsupportedPublicSignature("public storage type", `references missing type ${id}`);
  }
  if (node.kind === "PointerType" && node.attributes.type) {
    const cv = context.byId.get(node.attributes.type);
    const isConst = cv?.kind === "CvQualifiedType" && cv.attributes.const === "1";
    const pointeeId = isConst && cv.attributes.type ? cv.attributes.type : node.attributes.type;
    if (resourceTypeName(pointeeId, context)) {
      return isConst ? "?*const anyopaque" : "?*anyopaque";
    }
    const pointee = renderPublicStorageType(pointeeId, context);
    return isConst ? `?*const ${pointee}` : `?*${pointee}`;
  }
  if (node.kind === "ArrayType" && node.attributes.type) {
    return `[${arrayLength(node)}]${renderPublicStorageType(node.attributes.type, context)}`;
  }
  return renderPublicType(id, context);
}

function typeContainsResource(id: string, context: RenderContext): boolean {
  const node = unwrapTransparentType(id, context);
  if (!node) return false;
  if (context.resources.has(node.id)) return true;
  if ((node.kind === "PointerType" || node.kind === "ArrayType") && node.attributes.type) {
    return typeContainsResource(node.attributes.type, context);
  }
  return false;
}

function callbackArguments(
  node: XmlAstNode,
  context: RenderContext,
): Array<{ name: string; type: string }> {
  const argumentIds = splitIds(node.attributes.arguments);
  return resolveSignatureArguments(
    argumentIds.length > 0 ? argumentIds : node.members,
    `callback ${node.id}`,
    context,
  );
}

function toAbiExpression(id: string, name: string, context: RenderContext): string {
  if (isConstCharPointerType(id, context)) {
    return `if (${name} != null) @ptrCast(${name}.?.ptr) else null`;
  }
  if (resourceTypeNameForPointer(id, context)) {
    return `if (${name}) |resource| @ptrCast(resource.value) else null`;
  }
  switch (conversionKind(id, context)) {
    case "pointer":
      return `@ptrCast(${name})`;
    case "enum":
      return `@intCast(@intFromEnum(${name}))`;
    case "aggregate":
      return `@bitCast(${name})`;
    case "direct":
      return name;
  }
}

function fromAbiExpression(
  id: string,
  name: string,
  context: RenderContext,
  parentExpression?: string,
): string {
  if (isConstCharPointerType(id, context)) {
    return `if (${name} == null) null else ${
      fromAbiNonNullExpression(id, name, context, parentExpression)
    }`;
  }
  const resource = resourceRecordForPointer(id, context);
  const resourceName = resource ? context.publicTypeNames.get(resource.id) : undefined;
  if (resource && resourceName) {
    return `if (${name}) |value| ${
      resourceInitializer(resource, resourceName, "value", context, parentExpression)
    } else null`;
  }
  if (conversionKind(id, context) === "pointer") {
    return `if (${name} == null) null else ${fromAbiValueExpression(id, name, context)}`;
  }
  return fromAbiValueExpression(id, name, context);
}

function fromAbiNonNullExpression(
  id: string,
  name: string,
  context: RenderContext,
  parentExpression?: string,
): string {
  if (isConstCharPointerType(id, context)) {
    return `std.mem.span(@as([*:0]const u8, @ptrCast(${name}.?)))`;
  }
  const resource = resourceRecordForPointer(id, context);
  const resourceName = resource ? context.publicTypeNames.get(resource.id) : undefined;
  if (resource && resourceName) {
    return resourceInitializer(resource, resourceName, `${name}.?`, context, parentExpression);
  }
  return fromAbiValueExpression(id, `${name}.?`, context);
}

function fromAbiValueExpression(id: string, name: string, context: RenderContext): string {
  switch (conversionKind(id, context)) {
    case "pointer":
      return `@ptrCast(${name})`;
    case "enum":
      return `@enumFromInt(${name})`;
    case "aggregate":
      return `@bitCast(${name})`;
    case "direct":
      return name;
  }
}

function resourceInitializer(
  resource: XmlAstNode,
  resourceName: string,
  rawExpression: string,
  context: RenderContext,
  parentExpression?: string,
): string {
  const parentId = context.resources.get(resource.id)?.parentRecordId;
  if (parentId && !parentExpression) {
    throw new Error(
      `Cannot initialize dependent resource ${
        resource.attributes.name ?? resource.id
      } without its parent`,
    );
  }
  const parent = parentId ? `, .parent = ${parentExpression}` : "";
  return `${resourceName}{ .value = @ptrCast(${rawExpression})${parent} }`;
}

function conversionKind(
  id: string,
  context: RenderContext,
): "pointer" | "enum" | "aggregate" | "direct" {
  if (flagType(id, context)) return "aggregate";
  const node = unwrapTransparentType(id, context);
  if (node?.kind === "PointerType" || node?.kind === "FunctionType") return "pointer";
  if (node?.kind === "Enumeration") return "enum";
  if (node?.kind === "Struct" || node?.kind === "Union") return "aggregate";
  return "direct";
}

function flagType(id: string, context: RenderContext): FlagInfo | undefined {
  let node = context.byId.get(id);
  while (
    node?.kind === "Typedef" || node?.kind === "CvQualifiedType" ||
    node?.kind === "ElaboratedType" || node?.kind === "ReferenceType"
  ) {
    const flag = context.flags.get(node.id);
    if (flag) return flag;
    if (!node.attributes.type) return undefined;
    node = context.byId.get(node.attributes.type);
  }
  return undefined;
}

function failureMode(
  node: XmlAstNode,
  returnId: string,
  context: RenderContext,
): FailureMode | undefined {
  if (!returnId) return undefined;
  const documentation = matchedDocumentation(node, context);
  const fullComment = documentation?.comment.replace(/\s+/g, " ") ?? "";
  const returnComment = documentationReturnDescription(documentation?.comment ?? "") ||
    fullComment;
  const comment = returnComment.toLowerCase();
  if (
    isBoolType(returnId, context) &&
    /\btrue on success\b/.test(comment) &&
    /\bfalse\b/.test(comment) &&
    /\b(?:error|failure|call (?:sdl_)?geterror)\b/.test(comment)
  ) {
    return "bool";
  }
  if (
    conversionKind(returnId, context) === "pointer" &&
    /\bnull on failure\b/.test(comment)
  ) {
    return "null";
  }
  const returned = unwrapTransparentType(returnId, context);
  if (returned?.kind === "Enumeration") {
    const memberNames = new Set(
      enumValues(returned, context).map((value) => value.attributes.name).filter(Boolean),
    );
    for (const match of returnComment.matchAll(/\b([A-Z][A-Z0-9_]+)\b/g)) {
      const symbol = match[1];
      const start = (match.index ?? 0) + symbol.length;
      const following = returnComment.slice(start, start + 180);
      if (
        memberNames.has(symbol) &&
        /\b(?:on failure|on error)\b/i.test(following)
      ) {
        return { kind: "symbol", name: symbol };
      }
    }
  }
  if (!isIntegerType(returnId, context)) return undefined;
  const negativeFailure = /\bnegative error code\b/.test(comment) ||
    /\bnegative (?:value|number)\b[^.]{0,100}\b(?:on failure|on error)\b/.test(comment);
  if (!isSignedIntegerType(returnId, context) && negativeFailure) {
    const symbols: string[] = [];
    for (const match of fullComment.matchAll(/\b([A-Z][A-Z0-9_]+)\b/g)) {
      const symbol = match[1];
      const start = (match.index ?? 0) + symbol.length;
      const following = fullComment.slice(start, start + 100);
      if (
        /\bis returned\b/i.test(following) &&
        !symbols.includes(symbol)
      ) {
        symbols.push(symbol);
      }
    }
    if (symbols.length > 0) return { kind: "symbols", names: symbols };
  }
  if (
    isSignedIntegerType(returnId, context) &&
    (
      /(?:^|\W)-1\b[^.]{0,100}\b(?:on failure|on error)\b/.test(comment) ||
      negativeFailure ||
      /\bless than 0\b[^.]{0,100}\b(?:on failure|on error)\b/.test(comment)
    )
  ) {
    return "negative";
  }
  if (
    /\b0\b[^.]{0,80}\bon failure\b/.test(comment) &&
    (
      typeHasIdentifierSemantics(returnId, context) ||
      /\b(?:valid|positive|nonzero)\b[^.]{0,120}\bon success\b/.test(comment)
    )
  ) {
    return "zero";
  }
  return undefined;
}

function failureCondition(mode: FailureMode, rawName: string): string {
  if (mode === "negative") return `${rawName} < 0`;
  if (mode === "zero") return `${rawName} == 0`;
  if (typeof mode === "object") {
    const symbols = mode.kind === "symbol" ? [mode.name] : mode.names;
    return symbols.map((symbol) => `${rawName} == @as(@TypeOf(${rawName}), @intCast(c.${symbol}))`)
      .join(" or ");
  }
  throw new Error(`Failure mode ${mode} does not use a returned-value condition`);
}

function documentationReturnDescription(comment: string): string {
  return comment.match(/^\*\*Returns:\*\*\s*(.*)$/mi)?.[1]?.trim() ?? "";
}

function isIntegerType(id: string, context: RenderContext): boolean {
  const type = unwrapTransparentType(id, context);
  if (type?.kind !== "FundamentalType") return false;
  const name = type.attributes.name.toLowerCase();
  return name !== "_bool" && name !== "bool" &&
    /(?:char|short|int|long|size_t|ptrdiff_t)/.test(name);
}

function isSignedIntegerType(id: string, context: RenderContext): boolean {
  const type = unwrapTransparentType(id, context);
  if (type?.kind !== "FundamentalType") return false;
  const name = type.attributes.name.toLowerCase();
  return isIntegerType(id, context) &&
    !name.includes("unsigned") &&
    !/\bsize_t\b/.test(name);
}

function typeHasIdentifierSemantics(id: string, context: RenderContext): boolean {
  let type = context.byId.get(id);
  while (
    type?.kind === "Typedef" || type?.kind === "CvQualifiedType" ||
    type?.kind === "ElaboratedType" || type?.kind === "ReferenceType"
  ) {
    if (type.kind === "Typedef" && /(?:ID|Id)$/.test(type.attributes.name ?? "")) return true;
    if (!type.attributes.type) return false;
    type = context.byId.get(type.attributes.type);
  }
  return false;
}

function isBoolType(id: string, context: RenderContext): boolean {
  const node = unwrapTransparentType(id, context);
  return node?.kind === "FundamentalType" &&
    (node.attributes.name === "_Bool" || node.attributes.name === "bool");
}

function isConstCharPointerType(id: string, context: RenderContext): boolean {
  const pointer = unwrapTransparentType(id, context);
  if (pointer?.kind !== "PointerType" || !pointer.attributes.type) return false;
  const cv = context.byId.get(pointer.attributes.type);
  if (cv?.kind !== "CvQualifiedType" || cv.attributes.const !== "1" || !cv.attributes.type) {
    return false;
  }
  const target = unwrapTransparentType(cv.attributes.type, context);
  return target?.kind === "FundamentalType" && target.attributes.name === "char";
}

function resourceTypeNameForPointer(id: string, context: RenderContext): string | undefined {
  const record = pointedType(id, context);
  return record && context.resources.has(record.id)
    ? context.publicTypeNames.get(record.id)
    : undefined;
}

function resourceTypeName(id: string, context: RenderContext): string | undefined {
  const record = unwrapTransparentType(id, context);
  if (!record || !context.resources.has(record.id)) return undefined;
  return context.publicTypeNames.get(record.id);
}

function withoutOptional(type: string): string {
  return type.startsWith("?") ? type.slice(1) : type;
}

function publicFundamentalType(node: XmlAstNode): string {
  const name = node.attributes.name.toLowerCase();
  const words = new Set(name.split(/\s+/));
  if (name === "void") return "void";
  if (name === "_bool" || name === "bool") return "bool";
  if (name === "float") return "f32";
  if (name === "double") return "f64";
  if (words.has("long") && words.has("double")) return "c_longdouble";
  if (name === "char") return "u8";
  if (words.has("char")) return words.has("unsigned") ? "u8" : "i8";
  if (words.has("short")) return words.has("unsigned") ? "c_ushort" : "c_short";
  if (name.includes("long long")) return words.has("unsigned") ? "c_ulonglong" : "c_longlong";
  if (words.has("long")) return words.has("unsigned") ? "c_ulong" : "c_long";
  if (words.has("int") || words.has("signed") || words.has("unsigned")) {
    return words.has("unsigned") ? "c_uint" : "c_int";
  }
  throw unsupportedPublicSignature(
    "fundamental type",
    `uses unsupported type ${node.attributes.name || node.id}`,
  );
}

function unwrapTransparentType(id: string, context: RenderContext): XmlAstNode | undefined {
  return unwrapTransparentTypeFromMap(id, context.byId);
}

function pointedType(id: string, context: RenderContext): XmlAstNode | undefined {
  return pointedTypeFromMap(id, context.byId);
}

function resolvedNamedTypeName(
  id: string,
  names: Map<string, string>,
  context: RenderContext,
): string | undefined {
  let node = context.byId.get(id);
  while (node?.kind === "ElaboratedType" || node?.kind === "CvQualifiedType") {
    if (!node.attributes.type) return undefined;
    node = context.byId.get(node.attributes.type);
  }
  return node ? names.get(node.id) : undefined;
}

function recordFields(node: XmlAstNode, context: RenderContext): XmlAstNode[] {
  return node.members
    .map((memberId) => context.byId.get(memberId))
    .filter((member): member is XmlAstNode => member?.kind === "Field");
}

function enumValues(node: XmlAstNode, context: RenderContext): XmlAstNode[] {
  return node.members
    .map((memberId) => context.byId.get(memberId))
    .filter((member): member is XmlAstNode => member?.kind === "EnumValue");
}

function isBitfield(node: XmlAstNode): boolean {
  return Boolean(node.attributes.bits || node.attributes.bitfield);
}

function isOpaqueRecord(node: XmlAstNode): boolean {
  return (node.kind === "Struct" || node.kind === "Union") &&
    node.members.filter((member) => member.length > 0).length === 0 &&
    !node.attributes.size;
}

function isAnonymousRecord(node: XmlAstNode): boolean {
  return (node.kind === "Struct" || node.kind === "Union") && !node.attributes.name;
}

function isPrimitiveTypedef(node: XmlAstNode | undefined): boolean {
  return node?.kind === "Typedef" && /^(?:U|S)int(?:8|16|32|64)$/.test(
    node.attributes.name ?? "",
  );
}

function primitiveTypedefType(node: XmlAstNode): string | undefined {
  const match = node.attributes.name?.match(/^(U|S)int(8|16|32|64)$/);
  if (!match) return undefined;
  return `${match[1] === "U" ? "u" : "i"}${match[2]}`;
}

function arrayLength(node: XmlAstNode): number {
  if (!hasSupportedArrayBounds(node)) {
    throw unsupportedPublicSignature("array type", `${node.id} has unsupported bounds`);
  }
  const min = Number(node.attributes.min ?? "0");
  const max = Number(node.attributes.max ?? "-1");
  return max >= min ? max - min + 1 : 0;
}

function publicParameterNames(
  argumentsList: Array<{ name: string; type: string }>,
  context: RenderContext,
): string[] {
  const used = new Set(reservedPublicIdentifiers(context));
  return argumentsList.map((argument, index) =>
    uniqueIdentifier(
      context.naming.parameterName(argument.name || `arg_${index}`),
      used,
    )
  );
}

function reservedPublicIdentifiers(context: RenderContext): Set<string> {
  if (context.reservedPublicNames) return context.reservedPublicNames;
  context.reservedPublicNames = new Set([
    "c",
    ...allNamespaceNames(context),
    ...context.publicTypeNames.values(),
    ...context.model.constants.map((constant) => context.naming.valueName(constant.name)),
    ...context.publicFunctions.map((node) =>
      context.naming.functionName(node.attributes.name ?? "")
    ),
  ]);
  return context.reservedPublicNames;
}

function allNamespaceNames(context: RenderContext): string[] {
  if (context.namespaceNames.size > 0) return [...context.namespaceNames];
  for (const node of context.model.nodes) {
    if (!context.publicIds.has(node.id) || !node.attributes.name) continue;
    const namespace = namespaceFor(
      declarationHeader(node.attributes.name, context),
      node.attributes.name,
      context,
    );
    if (namespace) context.namespaceNames.add(namespace);
  }
  return [...context.namespaceNames];
}

function matchedDocumentation(
  node: XmlAstNode,
  context: RenderContext,
): ApiModel["documentation"][number] | undefined {
  const name = node.attributes.name;
  if (!name) return undefined;
  const header = sourceHeaderForNode(node, context);
  const expectedKind = node.kind === "Enumeration"
    ? "enum"
    : node.kind === "Function"
    ? "function"
    : node.kind.toLowerCase();
  let candidates = (context.documentationByName.get(name) ?? []).filter((item) =>
    item.kind === expectedKind || node.kind === "Typedef"
  );
  if (header) {
    candidates = candidates.filter((item) =>
      item.header.replaceAll("\\", "/").split("/").at(-1) === header
    );
  }
  if (node.kind === "Function") {
    const argumentNames = (
      context.functionPlans.get(node.id)?.arguments ?? functionArguments(node, context)
    ).map((argument) => argument.name);
    const signatureMatches = candidates.filter((item) => {
      const documentationNames = item.parameters
        .filter((parameter) => parameter !== "...")
        .map(parameterNameFromSignature);
      return documentationNames.length === argumentNames.length &&
        documentationNames.every((parameter, index) =>
          !parameter || !argumentNames[index] || parameter === argumentNames[index]
        );
    });
    if (signatureMatches.length > 0) candidates = signatureMatches;
  }
  return candidates[0];
}

function matchedDocumentationByName(
  cName: string,
  context: RenderContext,
): ApiModel["documentation"][number] | undefined {
  const header = declarationHeader(cName, context);
  let candidates = context.documentationByName.get(cName) ?? [];
  if (header) {
    candidates = candidates.filter((item) =>
      item.header.replaceAll("\\", "/").split("/").at(-1) === header
    );
  }
  return candidates[0];
}

function documentationLines(
  cName: string,
  context: RenderContext,
  fallback: string,
  additionallyHiddenParameterIndexes: number[] = [],
): string[] {
  const declaration = context.nodesByName.get(cName)?.find((node) =>
    context.publicIds.has(node.id)
  );
  const entry = declaration
    ? matchedDocumentation(declaration, context)
    : matchedDocumentationByName(cName, context);
  const plan = declaration?.kind === "Function" ? functionPlan(declaration, context) : undefined;
  let source = entry?.comment.trim() ? entry.comment : fallback;
  const categoryDocumentation = context.headerDocumentationByHeader.get(
    declarationHeader(cName, context),
  );
  if (categoryDocumentation && source.startsWith(categoryDocumentation.category)) {
    // Doxygen attaches a file's leading Category comment to its first declaration.
    // The category struct owns that prose, so do not duplicate it there.
    source = fallback;
  }
  if (plan && (plan.ownedStringElement || plan.ownedVariadicString)) {
    source = source
      .replace(
        new RegExp(
          `This should be freed with (?:${
            releaseFunctionSource(context)
          })\\(\\) when it is no longer needed\\.`,
          "g",
        ),
        "The returned slice is allocated with the caller-provided allocator.",
      )
      .replace(
        new RegExp(
          `The returned string is owned by the caller, and should be passed to (?:${
            releaseFunctionSource(context)
          }) when no longer needed\\.`,
          "g",
        ),
        "The returned slice is allocated with the caller-provided allocator.",
      );
  }
  if (declaration) {
    const argumentsList = plan?.arguments ?? [];
    const hiddenParameterIndexes = new Set([
      ...(plan?.hiddenParameterIndexes ?? []),
      ...additionallyHiddenParameterIndexes,
    ]);
    for (const index of hiddenParameterIndexes) {
      const argument = argumentsList[index];
      if (argument?.name) {
        source = source.replace(documentedParameterPattern(argument.name), "");
      }
    }
    const countIndex = plan?.ownedByteSliceCountIndex;
    if (countIndex !== undefined) {
      const countName = argumentsList[countIndex].name;
      source = source
        .replace(
          new RegExp(
            `(?:The data|This) should be freed with (?:${
              releaseFunctionSource(context)
            })\\(\\)(?: when it is no longer needed)?\\.`,
            "g",
          ),
          "The returned sentinel slice is allocated with the caller-provided allocator.",
        )
        .replace(documentedParameterPattern(countName), "");
    }
    const outputBytes = plan?.ownedOutputByteSlice;
    if (outputBytes) {
      const hidden = new Set([
        outputBytes.dataIndex,
        outputBytes.lengthIndex,
        ...outputBytes.outputs.map((output) => output.index),
      ]);
      for (const index of hidden) {
        source = source.replace(documentedParameterPattern(argumentsList[index].name), "");
      }
      source = source
        .replace(
          new RegExp(
            `which should be freed with (?:${releaseFunctionSource(context)})\\(\\)`,
            "g",
          ),
          "which is copied into the caller-provided allocator",
        )
        .replace(
          new RegExp(
            `When the application is done with the data returned in \`[^\`]+\`, it should call (?:${
              releaseFunctionSource(context)
            })\\(\\) to dispose of it\\.`,
            "g",
          ),
          "The returned audio data is allocated with the caller-provided allocator.",
        )
        .replace(
          new RegExp(
            `It's necessary to use (?:${
              releaseFunctionSource(context)
            })\\(\\) to free the audio data returned in \`[^\`]+\` when it is no longer used\\.`,
            "g",
          ),
          "The returned audio data is allocated with the caller-provided allocator.",
        );
    }
    const array = plan?.ownedArray;
    if (array) {
      if (array.countIndex !== undefined) {
        const countName = argumentsList[array.countIndex].name;
        source = source.replace(documentedParameterPattern(countName), "");
      }
      source = rewriteOwnedArrayDocumentation(source, array, context);
    }
    const borrowed = plan?.borrowedSlice;
    if (borrowed) {
      const countName = argumentsList[borrowed.countIndex].name;
      source = source.replace(documentedParameterPattern(countName), "");
      const library = context.profile.displayName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      source = source
        .replace(
          new RegExp(
            `The pointer returned is a pointer to an internal ${library} array\\.[^.]*should not be freed by the caller\\.`,
            "gi",
          ),
          "",
        )
        .replace(
          new RegExp(
            `You should not free the returned array; it is owned by ${library}\\.`,
            "gi",
          ),
          "",
        )
        .trim();
      source +=
        `\n\nThe returned slice is borrowed from ${context.profile.displayName}. Do not free it, and observe the upstream lifetime rules above.`;
    }
  }
  source = source
    .replace(/\*\*Parameters:\*\*\n(?=\*\*[A-Z][^*]*:\*\*)/g, "")
    .replace(/\*\*Parameters:\*\*\s*$/g, "")
    .trim();
  let rewritten = rewriteDocumentation(source, context);
  if (!declaration) collectLiteralDocumentationReferences(rewritten, context);
  const functionNode = context.nodesByName.get(cName)?.find((node) =>
    context.publicIds.has(node.id) && node.kind === "Function"
  );
  if (functionNode) {
    const argumentsList = functionPlan(functionNode, context).arguments;
    const publicNames = publicParameterNames(argumentsList, context);
    for (const [index, argument] of argumentsList.entries()) {
      if (!argument.name || argument.name === publicNames[index]) continue;
      rewritten = rewritten.replaceAll(`\`${argument.name}\``, `\`${publicNames[index]}\``);
    }
  }
  return renderDocComment(rewritten);
}

function collectLiteralDocumentationReferences(source: string, context: RenderContext): void {
  for (const match of source.matchAll(/__CODEGEN_DOC_REF_([A-Za-z_][A-Za-z0-9_]*)__/g)) {
    const cName = match[1];
    if (hasDocumentedPublicReference(cName, context)) continue;
    if (documentationApiPrefixes(context).some((prefix) => cName.startsWith(prefix))) {
      context.literalDocumentationReferences.add(cName);
    }
  }
}

function hasDocumentedPublicReference(cName: string, context: RenderContext): boolean {
  return context.emittedNames.has(cName) ||
    context.documentationMembers.has(cName) ||
    context.nodesByName.has(cName) ||
    context.documentationByName.has(cName);
}

function mentionsReleaseFunction(comment: string, context: RenderContext): boolean {
  const normalized = comment.toLowerCase();
  return context.profile.releaseFunctions.some((name) => normalized.includes(name.toLowerCase()));
}

function releaseFunctionFor(node: XmlAstNode, context: RenderContext): string {
  const comment = matchedDocumentation(node, context)?.comment.toLowerCase() ?? "";
  return context.profile.releaseFunctions.find((name) => comment.includes(name.toLowerCase())) ??
    context.profile.allocator.free;
}

function releaseFunctionSource(context: RenderContext): string {
  return context.profile.releaseFunctions
    .map((name) => name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
    .join("|");
}

function documentedParameterPattern(name: string): RegExp {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp("^- `" + escaped + "`:[^\\n]*(?:\\n|$)", "m");
}

function rewriteOwnedArrayDocumentation(
  source: string,
  info: OwnedArrayInfo,
  context: RenderContext,
): string {
  const ownership = info.kind === "strings"
    ? "The returned collection owns allocator-backed copies of every string; call `deinit` when finished."
    : info.kind === "string_records"
    ? "The returned collection owns allocator-backed copies of every record and its strings; call `deinit` when finished."
    : info.kind === "resources"
    ? "The returned slice is allocated with the caller-provided allocator. Its handles are borrowed and must not be destroyed through the returned values."
    : "The returned slice is allocated with the caller-provided allocator.";
  return source
    .replace(
      new RegExp(
        `The caller should pass the returned pointer to (?:${
          releaseFunctionSource(context)
        }) when done with it\\.\\s*`,
        "g",
      ),
      "",
    )
    .replace(
      new RegExp(
        `This is a single allocation that should be freed with (?:${
          releaseFunctionSource(context)
        })\\(\\) when it is no longer needed\\.`,
        "g",
      ),
      ownership,
    )
    .replace(
      new RegExp(
        `This should be freed with (?:${
          releaseFunctionSource(context)
        })\\(\\) when it is no longer needed\\.`,
        "g",
      ),
      ownership,
    );
}

function rewriteDocumentation(comment: string, context: RenderContext): string {
  return comment
    .split(/(```[\s\S]*?```)/g)
    .map((part) => part.startsWith("```") ? part : rewriteDocumentationText(part, context))
    .join("");
}

function rewriteDocumentationText(comment: string, context: RenderContext): string {
  const identifier = apiIdentifierSource(context);
  const environmentVariables = new Set(
    [...comment.matchAll(new RegExp(`\\benvironment variable\\s+\`(${identifier})\``, "gi"))]
      .map((match) => match[1]),
  );
  const historicalApiNames = new Set(
    [
      ...comment.matchAll(
        new RegExp(`\\b[A-Za-z][A-Za-z0-9_]*\\s+[0-9.]+\\s+API\\s+\`?(${identifier})`, "gi"),
      ),
    ]
      .map((match) => match[1]),
  );
  const externalSettingNames = new Set(
    [
      ...comment.matchAll(
        new RegExp(
          `\\b(?:key|property)\\s+(?:with\\s+)?(?:the\\s+)?name\\s+\`?(${identifier})`,
          "gi",
        ),
      ),
    ].map((match) => match[1]),
  );
  return comment.replace(
    new RegExp(`(?<!["'])\\b${identifier}\\b(?!["'])`, "g"),
    (cName) =>
      environmentVariables.has(cName) ||
        historicalApiNames.has(cName) ||
        externalSettingNames.has(cName)
        ? cName
        : `__CODEGEN_DOC_REF_${cName}__`,
  );
}

function apiIdentifierSource(context: RenderContext): string {
  const prefixes = documentationApiPrefixes(context)
    .map((prefix) => prefix.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
    .sort((left, right) => right.length - left.length);
  return `(?:${prefixes.join("|")})[A-Za-z0-9_]+`;
}

function documentationApiPrefixes(context: RenderContext): string[] {
  return [
    ...new Set([
      ...context.profile.symbolPrefixes,
      ...context.profile.dependencies.flatMap((dependency) =>
        context.dependencyApis.get(dependency)?.symbolPrefixes ?? []
      ),
    ]),
  ];
}

const documentationReferenceAliases = new Map([
  // SDL_image 3.4.4 still refers to the SDL2 surface destructor name.
  ["SDL_FreeSurface", "SDL_DestroySurface"],
  // SDL_ttf 3.2.2 retains this stale name after the DPI getter was renamed.
  ["TTF_GetFontSizeDPI", "TTF_GetFontDPI"],
  // SDL_mixer 3.2.4 uses this pre-release SDL3 name in explanatory prose.
  ["SDL_CreateIOFromConstMem", "SDL_IOFromConstMem"],
  // SDL_net 3.2.0 accidentally uses the core prefix for its socket destructor.
  ["SDL_DestroyDatagramSocket", "NET_DestroyDatagramSocket"],
  // SDL 3.4.12 retains this stale \sa name after the API changed Set to Send.
  ["SDL_SetJoystickVirtualSensorData", "SDL_SendJoystickVirtualSensorData"],
  // SDL 3.4.12 documents these string properties as NUMBER instead of POINTER.
  [
    "SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_UV_NUMBER",
    "SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_UV_POINTER",
  ],
  [
    "SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_U_NUMBER",
    "SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_U_POINTER",
  ],
  [
    "SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_V_NUMBER",
    "SDL_PROP_TEXTURE_CREATE_GPU_TEXTURE_V_POINTER",
  ],
]);

const documentationLiteralReferences = new Set([
  // Public headers use this annotation in declarations, but it is not part of
  // the generated callable API.
  "SDL_DECLSPEC",
  // SDL_image 3.4.4 retains this SDL2 flag in example prose.
  "SDL_RLEACCEL",
  // Applications implement these optional main callbacks; they are not linkable SDL exports.
  "SDL_AppEvent",
]);

function resolveDocumentationReferences(source: string, context: RenderContext): string {
  const namespaces = collectNamespaceMembers(context);
  const pathCache = new Map<string, string>();
  const publicPath = (cName: string, publicName: string): string => {
    const key = `${cName}\u0000${publicName}`;
    const existing = pathCache.get(key);
    if (existing) return existing;
    const path = canonicalPublicPath(cName, publicName, context, namespaces);
    pathCache.set(key, path);
    return path;
  };
  const resolveReference = (cName: string, repairMalformed: boolean): string => {
    if (
      documentationLiteralReferences.has(cName) ||
      context.literalDocumentationReferences.has(cName)
    ) {
      return `${cName} (C macro outside this module)`;
    }
    const alias = documentationReferenceAliases.get(cName);
    if (alias) return resolveReference(alias, false);
    const member = context.documentationMembers.get(cName);
    if (member) {
      return `${publicPath(member.ownerCName, member.ownerPublicName)}.${member.memberName}`;
    }
    const publicName = context.emittedNames.get(cName);
    if (publicName) return publicPath(cName, publicName);
    const dependencySymbol = context.dependencySymbols.get(cName);
    if (dependencySymbol) {
      return `${dependencySymbol.dependency}.${dependencySymbol.symbol.path}`;
    }
    const dependencyReference = context.dependencyReferences.get(cName);
    if (dependencyReference?.kind === "define") return `${cName} (C macro)`;
    if (dependencyReference) return `${cName} (C API outside this module)`;
    const callbackType = context.nodesByName.get(`${cName}_func`)?.find((node) =>
      context.publicIds.has(node.id) && node.attributes.name === `${cName}_func`
    );
    const callbackName = callbackType ? context.publicTypeNames.get(callbackType.id) : undefined;
    if (callbackName) {
      return publicPath(`${cName}_func`, callbackName);
    }
    const documentedDeclaration = context.documentationByName.get(cName)?.[0];
    if (documentedDeclaration?.kind === "define") return `${cName} (C macro)`;
    if (documentedDeclaration) return `${cName} (C API outside this module)`;
    if (
      documentationApiPrefixes(context).some((prefix) =>
        cName.startsWith(prefix) && /^[a-z]/.test(cName.slice(prefix.length))
      )
    ) return cName;
    if (
      cName.endsWith("_") &&
      context.model.documentation.some((item) =>
        item.kind === "define" && item.name.startsWith(cName)
      )
    ) return cName;
    const prefix = documentationApiPrefixes(context).find((candidate) =>
      cName.startsWith(candidate)
    );
    const subsystem = context.naming.fieldName(cName.slice(prefix?.length ?? 0));
    if (allNamespaceNames(context).includes(subsystem)) return subsystem;
    const familyPaths = [
      ...new Set([
        ...context.emittedNames.keys(),
        ...context.documentationMembers.keys(),
      ]),
    ]
      .filter((candidate) => candidate.startsWith(cName) && candidate.length > cName.length)
      .map((candidate) => {
        const candidateMember = context.documentationMembers.get(candidate);
        if (candidateMember) {
          return `${
            publicPath(candidateMember.ownerCName, candidateMember.ownerPublicName)
          }.${candidateMember.memberName}`;
        }
        const candidatePublicName = context.emittedNames.get(candidate);
        return candidatePublicName ? publicPath(candidate, candidatePublicName) : "";
      })
      .filter(Boolean);
    for (const dependency of context.profile.dependencies) {
      const dependencyFamilyPaths = context.dependencyApis.get(dependency)?.symbols
        .filter((candidate) =>
          candidate.cName.startsWith(cName) && candidate.cName.length > cName.length
        )
        .map((candidate) => `${dependency}.${candidate.path}`) ?? [];
      familyPaths.push(...dependencyFamilyPaths);
    }
    if (cName.endsWith("_") && familyPaths.length === 1) {
      const memberSeparator = familyPaths[0].lastIndexOf(".");
      if (memberSeparator >= 0) return familyPaths[0].slice(0, memberSeparator + 1);
    }
    if (familyPaths.length > 1) {
      const familyPath = commonStringPrefix(familyPaths);
      if (familyPath.includes(".")) return familyPath.replace(/\.$/, "");
    }
    if (repairMalformed) {
      const repaired = repairDuplicatedDocumentationReference(cName, context);
      if (repaired) return resolveReference(repaired, false);
    }
    if (cName.endsWith("s")) {
      const singular = cName.slice(0, -1);
      if (
        context.emittedNames.has(singular) ||
        context.documentationMembers.has(singular) ||
        context.documentationByName.has(singular)
      ) {
        return resolveReference(singular, false);
      }
    }
    throw new Error(`Unresolved documentation reference: ${cName}`);
  };
  return source.replace(/__CODEGEN_DOC_REF_([A-Za-z_][A-Za-z0-9_]*)__/g, (
    _placeholder,
    cName,
  ) => {
    return resolveReference(cName, true);
  });
}

function commonStringPrefix(values: string[]): string {
  if (values.length === 0) return "";
  let prefix = values[0];
  for (const value of values.slice(1)) {
    while (prefix && !value.startsWith(prefix)) prefix = prefix.slice(0, -1);
  }
  return prefix;
}

function repairDuplicatedDocumentationReference(
  cName: string,
  context: RenderContext,
): string | undefined {
  const knownNames = new Set([
    ...context.emittedNames.keys(),
    ...context.documentationMembers.keys(),
    ...context.model.nodes.map((node) => node.attributes.name ?? ""),
    ...context.model.documentation.map((item) => item.name),
  ]);
  return [...knownNames]
    .filter((candidate) => {
      if (
        !documentationApiPrefixes(context).some((prefix) => candidate.startsWith(prefix)) ||
        !cName.startsWith(candidate)
      ) return false;
      const suffix = cName.slice(candidate.length).toLowerCase();
      return suffix !== "" && context.naming.words(candidate).at(-1) === suffix;
    })
    .sort((left, right) => right.length - left.length)[0];
}

function canonicalPublicPath(
  cName: string,
  publicName: string,
  context: RenderContext,
  namespaces: Map<string, Map<string, string>>,
): string {
  const namespace = effectiveNamespaceFor(declarationHeader(cName, context), cName, context);
  if (!namespace) return publicName;
  const members = namespaces.get(namespace);
  const memberName = members
    ? [...members.entries()].find(([, target]) => target === publicName)?.[0]
    : undefined;
  if (!memberName) {
    throw new Error(`Missing canonical namespace path for ${cName} (${publicName})`);
  }
  return `${namespace}.${memberName}`;
}

function renderAbiAssertion(
  publicName: string,
  rawName: string,
  node: XmlAstNode,
  context: RenderContext,
  lines: string[],
): void {
  const platformName = platformNamespace(rawName, context);
  const indentation = platformName ? "        " : "    ";
  lines.push("comptime {");
  if (platformName) {
    lines.push(`    if (${platformConditionForName(platformName)}) {`);
  }
  lines.push(
    `${indentation}if (@sizeOf(${publicName}) != @sizeOf(c.${rawName})) @compileError("ABI size mismatch for ${publicName}");`,
  );
  lines.push(
    `${indentation}if (@alignOf(${publicName}) != @alignOf(c.${rawName})) @compileError("ABI alignment mismatch for ${publicName}");`,
  );
  if (node.kind === "Struct") {
    const usedNames = new Set<string>();
    for (const [index, field] of recordFields(node, context).entries()) {
      if (!field.attributes.name || isBitfield(field)) continue;
      const publicField = uniqueIdentifier(
        context.naming.fieldName(field.attributes.name || `field_${index}`),
        usedNames,
      );
      lines.push(
        `${indentation}if (@offsetOf(${publicName}, "${publicField}") != @offsetOf(c.${rawName}, "${field.attributes.name}")) @compileError("ABI field mismatch for ${publicName}.${publicField}");`,
      );
    }
  }
  if (platformName) lines.push("    }");
  lines.push("}");
}

function normalizeInteger(value: string): string {
  return value.replace(/[uUlL]+$/g, "");
}

function splitIds(value: string | undefined): string[] {
  if (!value || value.trim().length === 0) return [];
  return value.trim().split(/\s+/);
}

function finish(lines: string[]): string {
  return `${lines.join("\n").replaceAll(/[ \t]+$/gm, "").trimEnd()}\n`;
}
