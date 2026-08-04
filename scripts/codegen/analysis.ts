import { XMLParser } from "fast-xml-parser";
import { runCommand } from "../utils/command.ts";
import {
  collectDoxygenDocumentation,
  type Documentation,
  type HeaderDocumentation,
} from "./doxygen.ts";
import { attribute, numberAttribute, object, objects, type XmlObject } from "./xml.ts";

export interface AnalyzeOptions {
  translationUnit: string;
  includeDirectories: string[];
  publicIncludeDirectories: string[];
  apiPrefixes: string[];
  macroPrefixes?: string[];
  defines: string[];
  targets: string[];
  documentationInput: string;
  documentationProjectName: string;
  documentationPredefined: string[];
}

interface TargetAnalyzeOptions extends Omit<AnalyzeOptions, "targets" | "translationUnit"> {
  target: string;
}

interface ExternalCommand {
  command: string;
  args: string[];
}

export interface XmlAstNode {
  id: string;
  kind: string;
  attributes: Record<string, string>;
  members: string[];
  order: number;
}

export interface SourceLocation {
  file?: string;
  line?: number;
  column?: number;
}

export interface Constant {
  name: string;
  value: string;
  source: "macro" | "enum";
  header?: string;
}

export interface FunctionMacro {
  name: string;
  parameters: string[];
  replacement: string;
  header?: string;
}

export interface ApiModel {
  target: string;
  analysisTargets: string[];
  apiPrefixes: string[];
  nodes: XmlAstNode[];
  publicNodeIds: string[];
  locations: Record<string, SourceLocation>;
  files: Record<string, string>;
  documentation: Documentation[];
  headerDocumentation: HeaderDocumentation[];
  constants: Constant[];
  publicNodeTargets: Record<string, string[]>;
  constantTargets: Record<string, string[]>;
  functionMacros?: FunctionMacro[];
  functionMacroTargets?: Record<string, string[]>;
}

const declarationKinds = new Set([
  "Enumeration",
  "Function",
  "Struct",
  "Typedef",
  "Union",
  "Variable",
]);

const parser = new XMLParser({
  attributeNamePrefix: "@_",
  ignoreAttributes: false,
  parseAttributeValue: false,
  parseTagValue: false,
  trimValues: false,
  processEntities: false,
});

function buildCastXmlCommand(
  options: TargetAnalyzeOptions,
  input: string,
  output: string,
): ExternalCommand {
  const args = [
    "--castxml-output=1",
    "--castxml-cc-gnu-c",
    "clang",
    "-target",
    compilerTarget(options.target),
    ...targetIdentityArguments(options.target),
    ...includeAndDefineArguments(options),
  ];
  args.push("-o", output, input);
  return { command: "castxml", args };
}

function targetIdentityArguments(target: string): string[] {
  const normalized = target.toLowerCase();
  const args = [
    "-U__linux__",
    "-U__linux",
    "-Ulinux",
    "-U__gnu_linux__",
    "-U__unix__",
    "-U__unix",
    "-Uunix",
    "-U__ELF__",
    "-U_WIN32",
    "-U_WIN64",
    "-U__WIN32__",
    "-U__WIN64__",
    "-U__APPLE__",
    "-U__MACH__",
    "-UTARGET_OS_MACCATALYST",
    "-UTARGET_OS_IOS",
    "-UTARGET_OS_IPHONE",
    "-UTARGET_OS_TV",
    "-UTARGET_OS_SIMULATOR",
    "-UTARGET_OS_VISION",
    "-USDL_PLATFORM_LINUX",
    "-USDL_PLATFORM_WINDOWS",
    "-USDL_PLATFORM_WIN32",
    "-USDL_PLATFORM_APPLE",
    "-USDL_PLATFORM_MACOS",
    "-USDL_PLATFORM_IOS",
    "-USDL_PLATFORM_TVOS",
    "-USDL_PLATFORM_UNIX",
  ];
  if (normalized.includes("windows")) {
    args.push(
      "-D_WIN32=1",
      "-DSDL_PLATFORM_WINDOWS=1",
      "-DSDL_PLATFORM_WIN32=1",
    );
    if (normalized.startsWith("x86_64") || normalized.startsWith("aarch64")) {
      args.push("-D_WIN64=1");
    }
  } else if (
    normalized.includes("macos") || normalized.includes("ios") || normalized.includes("tvos")
  ) {
    // CastXML only supplies structure to the generator. Defining SDL's platform
    // identity and supplying minimal platform-definition headers avoids requiring
    // an Apple SDK on the generation host.
    args.push(
      "-D__APPLE__=1",
      "-D__MACH__=1",
      "-DSDL_PLATFORM_APPLE=1",
    );
    if (normalized.includes("ios")) {
      args.push(
        "-DTARGET_OS_IPHONE=1",
        "-DTARGET_OS_IOS=1",
        "-DSDL_PLATFORM_IOS=1",
      );
    } else if (normalized.includes("tvos")) {
      args.push(
        "-DTARGET_OS_TV=1",
        "-DSDL_PLATFORM_TVOS=1",
      );
    } else {
      args.push("-DSDL_PLATFORM_MACOS=1");
    }
    if (normalized.includes("simulator")) args.push("-DTARGET_OS_SIMULATOR=1");
  } else if (normalized.includes("emscripten")) {
    args.push(
      "-D__EMSCRIPTEN__=1",
      "-D__wasm32__=1",
    );
  } else if (normalized.includes("android")) {
    args.push(
      "-D__ANDROID__=1",
      "-DANDROID=1",
      "-D__ANDROID_API__=21",
    );
  } else if (normalized.includes("linux")) {
    args.push(
      "-D__linux__=1",
      "-D__gnu_linux__=1",
      "-D__unix__=1",
      "-D__ELF__=1",
      "-DSDL_PLATFORM_LINUX=1",
      "-DSDL_PLATFORM_UNIX=1",
    );
  }
  return args;
}

function compilerTarget(target: string): string {
  const normalized = target.toLowerCase();
  if (normalized.includes("android")) {
    // Android's public SDL headers intentionally avoid including the NDK headers. Use the
    // host's LP64 GNU ABI for structural traversal so generation remains SDK-independent; the
    // consumer build still compiles and ABI-checks the selected declarations for Android.
    return "x86_64-linux-gnu";
  }
  return target;
}

function buildMacroCommand(
  options: TargetAnalyzeOptions,
  input: string,
  expanded = false,
): ExternalCommand {
  const args = [
    "-E",
    ...(expanded ? ["-P"] : ["-dD"]),
    "-x",
    "c",
    ...targetIdentityArguments(options.target),
    ...includeAndDefineArguments(options),
  ];
  args.push(input);
  return { command: "clang", args };
}

function includeAndDefineArguments(options: TargetAnalyzeOptions): string[] {
  return [
    ...options.includeDirectories.map((directory) => `-I${directory}`),
    ...options.defines.map((define) => `-D${define}`),
  ];
}

function parseCastXml(
  xml: string,
  options: Pick<
    TargetAnalyzeOptions,
    "target" | "includeDirectories" | "publicIncludeDirectories" | "apiPrefixes"
  >,
): ApiModel {
  let document: XmlObject;
  try {
    document = parser.parse(xml) as XmlObject;
  } catch (error) {
    throw new Error(
      `Unable to parse CastXML output: ${error instanceof Error ? error.message : error}`,
    );
  }

  const root = requireObject(document.CastXML, "CastXML root");
  const format = attribute(root, "format");
  if (!format || !/^1\./.test(format)) {
    throw new Error(`Unsupported CastXML format ${format || "<missing>"}; expected format 1.x`);
  }

  const files: Record<string, string> = {};
  const locations: Record<string, SourceLocation> = {};
  const nodes: XmlAstNode[] = [];

  let order = 0;
  const visit = (kind: string, item: XmlObject, parentId?: string): string | undefined => {
    if (kind.startsWith("@_") || kind === "#text") return undefined;
    const explicitId = attribute(item, "id");
    const id = explicitId || `${parentId ?? "root"}:${kind}:${order}`;
    const nodeOrder = order++;
    const childIds: string[] = [];

    for (const [childKind, childValue] of Object.entries(item)) {
      if (childKind.startsWith("@_") || childKind === "#text") continue;
      for (const child of objects(childValue)) {
        const childId = visit(childKind, child, id);
        if (childId) childIds.push(childId);
      }
    }

    if (kind === "File") {
      files[id] = attribute(item, "name");
      return id;
    }

    if (kind === "Location") {
      locations[id] = {
        file: files[attribute(item, "file")] ?? (attribute(item, "file") || undefined),
        line: numberAttribute(item, "line"),
        column: numberAttribute(item, "column"),
      };
      return id;
    }

    nodes.push({
      id,
      kind,
      attributes: stringAttributes(item),
      members: [...splitIds(attribute(item, "members")), ...childIds],
      order: nodeOrder,
    });
    return id;
  };

  for (const [kind, value] of Object.entries(root)) {
    if (kind.startsWith("@_") || kind === "#text") continue;
    for (const item of objects(value)) visit(kind, item);
  }

  // CastXML normally emits File nodes before Locations. Resolve a second time so
  // XML ordering does not affect the model when a fixture or future CastXML version
  // orders those nodes differently.
  for (const [kind, value] of Object.entries(root)) {
    if (kind !== "Location" || kind.startsWith("@_")) continue;
    for (const item of objects(value)) {
      const id = attribute(item, "id");
      if (!id) continue;
      locations[id] = {
        file: files[attribute(item, "file")] ?? (attribute(item, "file") || undefined),
        line: numberAttribute(item, "line"),
        column: numberAttribute(item, "column"),
      };
    }
  }

  const publicNodeIds = nodes
    .filter((node) =>
      declarationKinds.has(node.kind) && isPublicNode(node, locations, files, options)
    )
    .map((node) => node.id)
    .sort();

  const constants = enumConstants(nodes, new Set(publicNodeIds));
  return {
    target: options.target,
    analysisTargets: [options.target],
    apiPrefixes: options.apiPrefixes,
    nodes: nodes.sort(compareNodes),
    publicNodeIds,
    locations,
    files,
    documentation: [],
    headerDocumentation: [],
    constants,
    publicNodeTargets: Object.fromEntries(
      publicNodeIds.map((id) => [id, [options.target]]),
    ),
    constantTargets: Object.fromEntries(
      constants.map((constant) => [constantIdentity(constant), [options.target]]),
    ),
    functionMacros: [],
    functionMacroTargets: {},
  };
}

const doxygenCache = new Map<
  string,
  Promise<{
    documentation: Documentation[];
    headerDocumentation: HeaderDocumentation[];
  }>
>();

export async function analyzeTargets(
  options: AnalyzeOptions,
): Promise<ApiModel[]> {
  const uniqueTargets = [...new Set(options.targets)];
  if (uniqueTargets.length === 0 || uniqueTargets.some((target) => target.length === 0)) {
    throw new Error("Semantic analysis requires at least one target");
  }
  const resolvedOptions: AnalyzeOptions = {
    ...options,
    includeDirectories: options.includeDirectories.map(resolvePath),
    publicIncludeDirectories: options.publicIncludeDirectories.map(resolvePath),
    documentationInput: resolvePath(options.documentationInput),
  };
  const temporaryDirectory = await Deno.makeTempDir({ prefix: "sdl-codegen-analysis-" });
  try {
    const shim = `${temporaryDirectory}/input.h`;
    await Deno.writeTextFile(shim, renderAnalysisShim(resolvedOptions.translationUnit));

    const documentationKey = JSON.stringify({
      inputDirectory: resolvedOptions.documentationInput,
      apiPrefixes: resolvedOptions.apiPrefixes,
      projectName: resolvedOptions.documentationProjectName,
      predefined: resolvedOptions.documentationPredefined,
    });
    const cachedDocumentation = doxygenCache.get(documentationKey);
    const documentationPromise = cachedDocumentation ?? collectDoxygenDocumentation({
      inputDirectory: resolvedOptions.documentationInput,
      outputDirectory: `${temporaryDirectory}/doxygen`,
      apiPrefixes: resolvedOptions.apiPrefixes,
      projectName: resolvedOptions.documentationProjectName,
      predefined: resolvedOptions.documentationPredefined,
    });
    if (!cachedDocumentation) doxygenCache.set(documentationKey, documentationPromise);
    const modelPromises = uniqueTargets.map(async (target, index) => {
      const supportDirectories = await createTargetAnalysisSupport(
        temporaryDirectory,
        target,
        index,
      );
      const targetOptions = {
        ...resolvedOptions,
        target,
        includeDirectories: [...supportDirectories, ...resolvedOptions.includeDirectories],
      };
      const xml = `${temporaryDirectory}/ast-${index}.xml`;
      const castXml = buildCastXmlCommand(targetOptions, shim, xml);
      await runCommand(castXml.command, castXml.args);
      const model = parseCastXml(await Deno.readTextFile(xml), targetOptions);

      const macroCommand = buildMacroCommand(targetOptions, shim);
      const macroResult = await runCommand(macroCommand.command, macroCommand.args);
      model.functionMacros = parseFunctionMacros(
        macroResult.stdout,
        [...resolvedOptions.apiPrefixes, ...(resolvedOptions.macroPrefixes ?? [])],
      ).filter((macro) =>
        macro.header !== undefined && isPublicSourcePath(macro.header, resolvedOptions)
      );
      model.functionMacroTargets = Object.fromEntries(
        (model.functionMacros ?? []).map((macro) => [macro.name, [target]]),
      );
      const macroLocations = parseMacroLocations(macroResult.stdout);
      const macroNames = parseMacroNames(
        macroResult.stdout,
        resolvedOptions.apiPrefixes,
        resolvedOptions.macroPrefixes,
      ).filter(
        (name) => {
          const location = macroLocations[name];
          return location !== undefined && isPublicSourcePath(location, resolvedOptions);
        },
      );
      const macroProbe = `${temporaryDirectory}/macros-${index}.c`;
      await Deno.writeTextFile(macroProbe, renderMacroProbe(shim, macroNames));
      const expandedMacroCommand = buildMacroCommand(targetOptions, macroProbe, true);
      const expandedMacroResult = await runCommand(
        expandedMacroCommand.command,
        expandedMacroCommand.args,
      );
      model.constants = mergeConstants(
        model.constants,
        parseExpandedMacroOutput(
          expandedMacroResult.stdout,
        ).map((constant) => ({ ...constant, header: macroLocations[constant.name] })),
      );
      model.constantTargets = Object.fromEntries(
        model.constants.map((constant) => [constantIdentity(constant), [target]]),
      );
      model.analysisTargets = uniqueTargets;
      return model;
    });
    const [models, doxygen] = await Promise.all([
      Promise.all(modelPromises),
      documentationPromise,
    ]);
    for (const model of models) {
      model.documentation = doxygen.documentation;
      model.headerDocumentation = doxygen.headerDocumentation;
    }
    return models;
  } finally {
    await Deno.remove(temporaryDirectory, { recursive: true });
  }
}

export function mergeApiModels(models: ApiModel[]): ApiModel {
  if (models.length === 0) throw new Error("Cannot merge an empty analysis matrix");
  const targets = models.map((model) => model.target);
  if (new Set(targets).size !== targets.length) {
    throw new Error("Cannot merge duplicate analysis targets");
  }

  const first = models[0];
  const merged: ApiModel = {
    ...first,
    analysisTargets: targets,
    nodes: first.nodes.map((node) => ({
      ...node,
      attributes: { ...node.attributes },
      members: [...node.members],
    })),
    publicNodeIds: [...first.publicNodeIds],
    locations: structuredClone(first.locations),
    files: { ...first.files },
    documentation: [...first.documentation],
    headerDocumentation: [...first.headerDocumentation],
    constants: first.constants.map((constant) => ({ ...constant })),
    publicNodeTargets: Object.fromEntries(
      first.publicNodeIds.map((id) => [id, [first.target]]),
    ),
    constantTargets: Object.fromEntries(
      first.constants.map((constant) => [constantIdentity(constant), [first.target]]),
    ),
    functionMacros: (first.functionMacros ?? []).map((macro) => ({ ...macro })),
    functionMacroTargets: Object.fromEntries(
      Object.entries(first.functionMacroTargets ?? {}).map((
        [name, targets],
      ) => [name, [...targets]]),
    ),
  };
  const publicIds = new Set(merged.publicNodeIds);
  const mergedNodeIds = new Set(merged.nodes.map((node) => node.id));
  const declarationIdentities = new Map<string, string>();
  for (const node of merged.nodes) {
    const identity = mergeableNodeIdentity(node, first);
    if (identity) declarationIdentities.set(identity, node.id);
  }

  for (const [modelIndex, model] of models.entries()) {
    if (modelIndex === 0) continue;
    const prefix = `target${modelIndex}:`;
    const orderOffset = merged.nodes.reduce(
      (maximum, node) => Math.max(maximum, node.order),
      -1,
    ) + 1;
    const idMap = new Map<string, string>();
    for (const id of Object.keys(model.files)) idMap.set(id, `${prefix}${id}`);
    for (const id of Object.keys(model.locations)) idMap.set(id, `${prefix}${id}`);

    const appendedIdentities = new Map<string, string>();
    for (const node of model.nodes) {
      const identity = mergeableNodeIdentity(node, model);
      const canonicalId = identity ? declarationIdentities.get(identity) : undefined;
      const id = canonicalId ?? `${prefix}${node.id}`;
      idMap.set(node.id, id);
      if (identity && !canonicalId) appendedIdentities.set(identity, id);
    }
    for (const [identity, id] of appendedIdentities) {
      declarationIdentities.set(identity, id);
    }

    for (const [id, file] of Object.entries(model.files)) {
      merged.files[idMap.get(id) ?? `${prefix}${id}`] = file;
    }
    for (const [id, location] of Object.entries(model.locations)) {
      merged.locations[idMap.get(id) ?? `${prefix}${id}`] = { ...location };
    }

    for (const node of model.nodes) {
      const remappedId = idMap.get(node.id) ?? `${prefix}${node.id}`;
      if (mergedNodeIds.has(remappedId)) continue;
      merged.nodes.push({
        ...node,
        id: remappedId,
        attributes: remapAttributes(node.attributes, idMap),
        members: node.members.map((id) => idMap.get(id) ?? `${prefix}${id}`),
        order: orderOffset + node.order,
      });
      mergedNodeIds.add(remappedId);
    }

    for (const sourceId of model.publicNodeIds) {
      const id = idMap.get(sourceId) ?? `${prefix}${sourceId}`;
      if (!publicIds.has(id)) {
        publicIds.add(id);
        merged.publicNodeIds.push(id);
      }
      addAvailability(merged.publicNodeTargets, id, model.target, targets);
    }

    const constantByIdentity = new Map(
      merged.constants.map((constant) => [constantIdentity(constant), constant]),
    );
    for (const constant of model.constants) {
      const identity = constantIdentity(constant);
      if (!constantByIdentity.has(identity)) {
        const copy = { ...constant };
        merged.constants.push(copy);
        constantByIdentity.set(identity, copy);
      }
      addAvailability(merged.constantTargets, identity, model.target, targets);
    }

    const mergedFunctionMacros = new Map(
      (merged.functionMacros ?? []).map((macro) => [macro.name, macro]),
    );
    for (const macro of model.functionMacros ?? []) {
      if (!mergedFunctionMacros.has(macro.name)) {
        mergedFunctionMacros.set(macro.name, { ...macro });
        merged.functionMacros?.push({ ...macro });
      }
      addAvailability(
        merged.functionMacroTargets ?? (merged.functionMacroTargets = {}),
        macro.name,
        model.target,
        targets,
      );
    }
  }

  return merged;
}

function mergeableNodeIdentity(node: XmlAstNode, model: ApiModel): string | undefined {
  const name = node.attributes.name;
  if (!name || !declarationKinds.has(node.kind)) return undefined;
  const location = model.locations[node.attributes.location];
  const fileReference = node.attributes.file || location?.file;
  const file = (fileReference ? model.files[fileReference] : undefined) ??
    location?.file ??
    fileReference;
  const line = location?.line ?? Number(node.attributes.line);
  if (!file || !Number.isFinite(line)) return undefined;
  const stableFile = file.replaceAll("\\", "/");
  return [
    node.kind,
    name,
    stableFile,
    String(line),
    String(location?.column ?? ""),
  ].join("|");
}

function remapAttributes(
  attributes: Record<string, string>,
  idMap: Map<string, string>,
): Record<string, string> {
  return Object.fromEntries(
    Object.entries(attributes).map(([key, value]) => {
      const direct = idMap.get(value);
      if (direct) return [key, direct];
      const ids = value.trim().split(/\s+/);
      if (ids.length > 1 && ids.some((id) => idMap.has(id))) {
        return [key, ids.map((id) => idMap.get(id) ?? id).join(" ")];
      }
      return [key, value];
    }),
  );
}

function addAvailability(
  availability: Record<string, string[]>,
  identity: string,
  target: string,
  targetOrder: string[],
): void {
  const values = availability[identity] ?? [];
  if (!values.includes(target)) values.push(target);
  availability[identity] = values.sort((left, right) =>
    targetOrder.indexOf(left) - targetOrder.indexOf(right)
  );
}

function constantIdentity(constant: Constant): string {
  return `${constant.source}:${constant.name}`;
}

async function createTargetAnalysisSupport(
  temporaryDirectory: string,
  target: string,
  index: number,
): Promise<string[]> {
  const normalized = target.toLowerCase();
  if (
    normalized.includes("macos") || normalized.includes("ios") || normalized.includes("tvos")
  ) {
    const directory = `${temporaryDirectory}/target-support-${index}`;
    await Deno.mkdir(directory);
    await Deno.writeTextFile(
      `${directory}/AvailabilityMacros.h`,
      "#define MAC_OS_X_VERSION_MIN_REQUIRED 130000\n",
    );
    await Deno.writeTextFile(
      `${directory}/TargetConditionals.h`,
      [
        `#define TARGET_OS_MACCATALYST 0`,
        `#define TARGET_OS_IOS ${normalized.includes("ios") ? 1 : 0}`,
        `#define TARGET_OS_IPHONE ${normalized.includes("ios") ? 1 : 0}`,
        `#define TARGET_OS_TV ${normalized.includes("tvos") ? 1 : 0}`,
        `#define TARGET_OS_SIMULATOR ${normalized.includes("simulator") ? 1 : 0}`,
        "#define TARGET_OS_VISION 0",
        "",
      ].join("\n"),
    );
    return [directory];
  }
  if (!normalized.includes("windows")) return [];
  const directory = `${temporaryDirectory}/target-support-${index}`;
  await Deno.mkdir(directory);
  // SDL_thread.h includes this MSVCRT header for declarations that do not
  // affect SDL's public structure. CastXML does not need a Windows SDK to
  // traverse the SDL declarations themselves.
  await Deno.writeTextFile(
    `${directory}/process.h`,
    "/* Structural CastXML analysis stub: no public SDL declarations. */\n",
  );
  return [directory];
}

function resolvePath(path: string): string {
  const normalized = normalizePath(path);
  return isAbsolutePath(normalized) ? normalized : normalizePath(`${Deno.cwd()}/${normalized}`);
}

function renderAnalysisShim(translationUnit: string): string {
  return [
    "#ifndef DOXYGEN_SHOULD_IGNORE_THIS",
    "#define DOXYGEN_SHOULD_IGNORE_THIS 1",
    "#endif",
    translationUnit.trimEnd(),
    "",
  ].join("\n");
}

function parseMacroNames(
  output: string,
  apiPrefixes: string[] = ["SDL_"],
  macroPrefixes: string[] = [],
): string[] {
  const definitions = [...parseMacroDefinitions(output).values()];

  const contextualIdentifiers = new Set([
    "__BASE_FILE__",
    "__COUNTER__",
    "__DATE__",
    "__FILE__",
    "__FILE_NAME__",
    "__FUNCTION__",
    "__INCLUDE_LEVEL__",
    "__LINE__",
    "__PRETTY_FUNCTION__",
    "__TIMESTAMP__",
    "__TIME__",
    "__func__",
  ]);
  const contextualMacros = new Set<string>();
  let changed = true;
  while (changed) {
    changed = false;
    for (const definition of definitions) {
      if (contextualMacros.has(definition.name)) continue;
      const identifiers = definition.replacement.match(/[A-Za-z_][A-Za-z0-9_]*/g) ?? [];
      if (
        identifiers.some((identifier) =>
          contextualIdentifiers.has(identifier) || contextualMacros.has(identifier)
        )
      ) {
        contextualMacros.add(definition.name);
        changed = true;
      }
    }
  }

  return [
    ...new Set(
      definitions
        .filter((definition) =>
          [...apiPrefixes, ...macroPrefixes].some((prefix) => definition.name.startsWith(prefix)) &&
          !definition.name.endsWith("_h_") &&
          !definition.functionLike &&
          definition.replacement.trim().length !== 0
        )
        .map((definition) => definition.name),
    ),
  ]
    .filter((name) => !contextualMacros.has(name))
    .sort((left, right) => left.localeCompare(right));
}

function parseMacroLocations(output: string): Record<string, string> {
  return Object.fromEntries(
    [...parseMacroDefinitions(output).values()]
      .filter((definition) => definition.header !== undefined)
      .map((definition) => [definition.name, definition.header!]),
  );
}

interface ParsedMacroDefinition {
  name: string;
  functionLike: boolean;
  parameters: string[];
  replacement: string;
  header?: string;
}

function parseFunctionMacros(output: string, prefixes: string[]): FunctionMacro[] {
  return [...parseMacroDefinitions(output).values()]
    .filter((definition) =>
      definition.functionLike &&
      prefixes.some((prefix) => definition.name.startsWith(prefix)) &&
      definition.replacement.trim().length > 0
    )
    .map((definition) => ({
      name: definition.name,
      parameters: definition.parameters,
      replacement: definition.replacement,
      header: definition.header,
    }))
    .sort((left, right) => left.name.localeCompare(right.name));
}

function parseMacroDefinitions(output: string): Map<string, ParsedMacroDefinition> {
  const definitions = new Map<string, ParsedMacroDefinition>();
  let header: string | undefined;
  for (const line of output.split("\n")) {
    const marker = line.match(/^#\s+\d+\s+"((?:[^"\\]|\\.)*)"/);
    if (marker) {
      header = decodeLineMarkerPath(marker[1]);
      continue;
    }
    const undefinition = line.match(/^#undef\s+([A-Za-z_][A-Za-z0-9_]*)/);
    if (undefinition) {
      definitions.delete(undefinition[1]);
      continue;
    }
    const definition = line.match(
      /^#define\s+([A-Za-z_][A-Za-z0-9_]*)(\([^)]*\))?\s*(.*)$/,
    );
    if (!definition) continue;
    definitions.set(definition[1], {
      name: definition[1],
      functionLike: definition[2] !== undefined,
      parameters: definition[2]
        ? definition[2].slice(1, -1).split(",").map((parameter) => parameter.trim()).filter(Boolean)
        : [],
      replacement: definition[3],
      header,
    });
  }
  return definitions;
}

function decodeLineMarkerPath(value: string): string {
  return value.replace(/\\(["\\])/g, "$1");
}

function renderMacroProbe(header: string, names: string[]): string {
  const escapedHeader = header.replaceAll("\\", "/").replaceAll('"', '\\"');
  const lines = [
    `#include "${escapedHeader}"`,
    "#define SDL_CODEGEN_STRINGIFY_INNER(value) #value",
    "#define SDL_CODEGEN_STRINGIFY(value) SDL_CODEGEN_STRINGIFY_INNER(value)",
  ];
  for (const name of names) {
    lines.push(`const char *sdl_codegen_${name} = SDL_CODEGEN_STRINGIFY(${name});`);
  }
  return `${lines.join("\n")}\n`;
}

function parseExpandedMacroOutput(output: string): Constant[] {
  const constants: Constant[] = [];
  const pattern =
    /^const char \*sdl_codegen_([A-Za-z_][A-Za-z0-9_]*)\s*=\s*("(?:[^"\\]|\\.)*")\s*;/;
  for (const line of output.split("\n")) {
    const match = line.trim().match(pattern);
    if (!match) continue;
    const expanded = decodeCString(match[2]);
    const value = normalizeLiteral(expanded);
    if (value !== null) constants.push({ name: match[1], value, source: "macro" });
  }
  return constants.sort((left, right) => left.name.localeCompare(right.name));
}

function normalizeLiteral(value: string): string | null {
  if (/^(?:[-+]?0[xX][0-9a-fA-F]+|[-+]?(?:0|[1-9][0-9]*))(?:[uUlL]*)$/.test(value)) {
    return value.replace(/[uUlL]+$/g, "");
  }
  if (/^(?:true|false)$/.test(value)) return value;
  if (/^"(?:[^"\\]|\\.)*"$/.test(value)) return value;
  if (/^'(?:[^'\\]|\\.)'$/.test(value)) return value;
  const expression = stripBalancedParentheses(value.trim())
    .replace(/\b(0[xX][0-9a-fA-F]+|[0-9]+)(?:[uUlL]+)\b/g, "$1");
  if (
    expression.length > 0 &&
    /^[0-9A-Fa-fxX\s()+\-*/%<>&|^~.]+$/.test(expression) &&
    /[0-9]/.test(expression)
  ) return expression;
  return null;
}

function stripBalancedParentheses(value: string): string {
  let result = value;
  while (result.startsWith("(") && result.endsWith(")")) {
    let depth = 0;
    let enclosesAll = true;
    for (const [index, character] of [...result].entries()) {
      if (character === "(") depth++;
      else if (character === ")") depth--;
      if (depth === 0 && index < result.length - 1) {
        enclosesAll = false;
        break;
      }
    }
    if (!enclosesAll || depth !== 0) break;
    result = result.slice(1, -1).trim();
  }
  return result;
}

function decodeCString(value: string): string {
  const body = value.slice(1, -1);
  return body.replace(/\\(x[0-9a-fA-F]{2}|[0-7]{1,3}|.)/g, (_match, escaped: string) => {
    if (escaped.startsWith("x")) return String.fromCodePoint(Number.parseInt(escaped.slice(1), 16));
    if (/^[0-7]/.test(escaped)) return String.fromCodePoint(Number.parseInt(escaped, 8));
    return ({ n: "\n", r: "\r", t: "\t", "\\": "\\", '"': '"' } as Record<string, string>)[
      escaped
    ] ?? escaped;
  });
}

function enumConstants(nodes: XmlAstNode[], publicIds: Set<string>): Constant[] {
  const result: Constant[] = [];
  const byId = new Map(nodes.map((node) => [node.id, node]));
  for (
    const enumeration of nodes.filter((node) =>
      node.kind === "Enumeration" && publicIds.has(node.id)
    )
  ) {
    for (const memberId of enumeration.members) {
      const member = byId.get(memberId);
      if (!member || member.kind !== "EnumValue") continue;
      const name = member.attributes.name;
      const value = member.attributes.init;
      if (name && value) result.push({ name, value, source: "enum" });
    }
  }
  return result.sort((left, right) => left.name.localeCompare(right.name));
}

function mergeConstants(left: Constant[], right: Constant[]): Constant[] {
  const constants = new Map<string, Constant>();
  for (const constant of [...left, ...right]) {
    if (!constants.has(constant.name) || constant.source === "enum") {
      constants.set(constant.name, constant);
    }
  }
  return [...constants.values()].sort((a, b) => a.name.localeCompare(b.name));
}

function isPublicNode(
  node: XmlAstNode,
  locations: Record<string, SourceLocation>,
  files: Record<string, string>,
  options: Pick<
    AnalyzeOptions,
    "publicIncludeDirectories" | "apiPrefixes"
  >,
): boolean {
  if (isImplementationArtifact(node.attributes.name)) return false;
  const locationId = node.attributes.location;
  const location = locations[locationId];
  const fileReference = node.attributes.file || location?.file;
  const fileName = (fileReference ? files[fileReference] : undefined) ?? fileReference;
  if (!fileName) {
    // Declarations without source provenance are generally compiler built-ins. Keep
    // named SDL declarations, but never import an anonymous system declaration.
    return options.apiPrefixes.some((prefix) => (node.attributes.name ?? "").startsWith(prefix));
  }
  return isPublicSourcePath(fileName, options);
}

function isImplementationArtifact(name: string | undefined): boolean {
  return name !== undefined &&
    (name.startsWith("__builtin_") || /^SDL_size_.*_builtin$/.test(name));
}

function isPublicSourcePath(
  fileName: string,
  options: Pick<AnalyzeOptions, "publicIncludeDirectories">,
): boolean {
  const file = normalizePath(fileName);
  const roots = options.publicIncludeDirectories.flatMap((path) => {
    const normalized = normalizePath(path);
    return isAbsolutePath(normalized)
      ? [normalized]
      : [normalized, normalizePath(`${Deno.cwd()}/${normalized}`)];
  });
  return roots.some((root) => file === root || file.startsWith(`${root.replace(/\/$/, "")}/`));
}

function compareNodes(left: XmlAstNode, right: XmlAstNode): number {
  return left.kind.localeCompare(right.kind) ||
    (left.attributes.name ?? "").localeCompare(right.attributes.name ?? "") ||
    left.order - right.order ||
    left.id.localeCompare(right.id);
}

function normalizePath(path: string): string {
  return path.replaceAll("\\", "/").replace(/\/+/g, "/").replace(/\/$/, "");
}

function isAbsolutePath(path: string): boolean {
  return path.startsWith("/") || /^[A-Za-z]:\//.test(path);
}

function stringAttributes(object: XmlObject): Record<string, string> {
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(object)) {
    if (!key.startsWith("@_")) continue;
    result[key.slice(2)] = typeof value === "string" ? value : String(value);
  }
  return result;
}

function splitIds(value: string): string[] {
  return value.trim().length === 0 ? [] : value.trim().split(/\s+/);
}

function requireObject(value: unknown, description: string): XmlObject {
  const result = object(value);
  if (!result) throw new Error(`Expected ${description}`);
  return result;
}
