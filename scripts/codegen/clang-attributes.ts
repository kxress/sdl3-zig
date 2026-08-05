export interface FormatContract {
  dialect: "printf" | "scanf";
  formatParameter: number;
  firstVariadicParameter: number | "va_list";
}

export interface DeclarationSemantics {
  linkage: "default" | "imported" | "exported" | "hidden";
  deprecated?: { message?: string; replacement?: string };
  inline: "none" | "hint" | "always";
  returnFlow: "normal" | "no_return" | "analyzer_no_return";
  resultUse: "ordinary" | "should_use";
  format?: FormatContract;
  allocationSize?: { parameters: number[] };
  alignment?: number;
  mallocLike?: boolean;
  restrict?: boolean;
  /** Zero-based pointer parameter indexes carrying C's restrict qualifier. */
  restrictParameters?: number[];
  unused?: boolean;
  fallthrough?: boolean;
}

export interface AttributeSource {
  file: string;
  line: number;
  column?: number;
}

export interface DeclarationAttributeRecord {
  cName: string;
  source: AttributeSource;
  semantics: DeclarationSemantics;
}

interface JsonRecord {
  kind?: string;
  name?: string;
  [key: string]: unknown;
}

export function parseClangAttributeJson(
  json: string,
  options: {
    publicFilePrefixes?: string[];
    sourceTextByFile?: Record<string, string>;
    defaultSourceFile?: string;
  } = {},
): DeclarationAttributeRecord[] {
  let root: unknown;
  try {
    root = JSON.parse(json);
  } catch (error) {
    throw new Error(`Unable to parse Clang attribute JSON: ${error}`);
  }
  const records: DeclarationAttributeRecord[] = [];
  walk(root, undefined, records, options);
  return records.sort((left, right) =>
    left.source.file.localeCompare(right.source.file) ||
    left.source.line - right.source.line ||
    left.cName.localeCompare(right.cName)
  );
}

function walk(
  value: unknown,
  parent: JsonRecord | undefined,
  records: DeclarationAttributeRecord[],
  options: {
    publicFilePrefixes?: string[];
    sourceTextByFile?: Record<string, string>;
    defaultSourceFile?: string;
  },
): void {
  if (Array.isArray(value)) {
    for (const item of value) walk(item, parent, records, options);
    return;
  }
  if (!value || typeof value !== "object") return;
  const node = value as JsonRecord;
  if (isDeclaration(node) && typeof node.name === "string") {
    const source = sourceOf(node, options);
    if (source && isPublicSource(source.file, options.publicFilePrefixes ?? [])) {
      const semantics = semanticsOf(node, node.name, source, options);
      if (semantics) records.push({ cName: node.name, source, semantics });
    }
  }
  // Clang AST declarations and their attributes are structurally contained in `inner`. Avoid
  // walking metadata objects (`loc`, `range`, `type`, and source expansions) as if they were AST
  // subtrees: on the full SDL translation unit that multiplies traversal and memory substantially.
  const children = Array.isArray(node.inner) ? node.inner : [];
  for (const child of children) walk(child, node, records, options);
}

function isDeclaration(node: JsonRecord): boolean {
  return node.kind === "FunctionDecl" || node.kind === "VarDecl" ||
    node.kind === "TypedefDecl" || node.kind === "RecordDecl";
}

function semanticsOf(
  node: JsonRecord,
  cName: string,
  source: AttributeSource,
  options: {
    sourceTextByFile?: Record<string, string>;
    defaultSourceFile?: string;
  },
): DeclarationSemantics | undefined {
  const inner = Array.isArray(node.inner) ? node.inner.filter(isRecord) : [];
  const attributes = inner.filter((child) => typeof child.kind === "string");
  const returnType = node.kind === "FunctionDecl"
    ? stringValue(record(node.type)?.qualType)
    : undefined;
  // Clang 19 serializes __attribute__((noreturn)) on a function type rather than
  // emitting a NoReturnAttr child. Keep this probe restricted to FunctionDecl
  // qualTypes so an unrelated spelling in a typedef or parameter name cannot
  // become a control-flow contract.
  const noReturnType = node.kind === "FunctionDecl" && returnType !== undefined &&
    /\b(?:__)?noreturn\b/.test(returnType);
  const semantics: DeclarationSemantics = {
    linkage: "default",
    inline: "none",
    returnFlow: noReturnType ? "no_return" : "normal",
    resultUse: "ordinary",
  };
  const parameterCount = node.kind === "FunctionDecl"
    ? inner.filter((child) => child.kind === "ParmVarDecl").length
    : undefined;
  const parameterNodes = node.kind === "FunctionDecl"
    ? inner.filter((child) => child.kind === "ParmVarDecl")
    : [];
  let recognized = false;
  let explicitNoReturn = noReturnType;
  let analyzerNoReturn = false;
  if (noReturnType) recognized = true;
  if (node.kind === "FunctionDecl" && node.inline === true) {
    recognized = true;
    semantics.inline = "hint";
  }
  if (
    node.kind === "FunctionDecl" &&
    parameterNodes.some((parameter) =>
      Array.isArray(parameter.inner) &&
      parameter.inner.some((child) => isRecord(child) && child.kind === "UnusedAttr")
    )
  ) {
    recognized = true;
    semantics.unused = true;
  }
  for (const attribute of attributes) {
    switch (attribute.kind) {
      case "VisibilityAttr":
        recognized = true;
        semantics.linkage = visibility(attribute.visibility);
        break;
      case "DLLImportAttr":
      case "CXXDLLImportAttr":
        recognized = true;
        semantics.linkage = "imported";
        break;
      case "DLLExportAttr":
      case "CXXDLLExportAttr":
        recognized = true;
        semantics.linkage = "exported";
        break;
      case "DeprecatedAttr":
        recognized = true;
        semantics.deprecated = {
          message: stringValue(attribute.message),
          replacement: stringValue(attribute.replacement),
        };
        break;
      case "AlwaysInlineAttr":
        recognized = true;
        semantics.inline = "always";
        break;
      case "InlineHintAttr":
        recognized = true;
        semantics.inline = semantics.inline === "always" ? "always" : "hint";
        break;
      case "NoReturnAttr":
        recognized = true;
        explicitNoReturn = true;
        break;
      case "AnalyzerNoReturnAttr":
        recognized = true;
        analyzerNoReturn = true;
        break;
      case "WarnUnusedResultAttr":
      case "NoDiscardAttr":
        recognized = true;
        semantics.resultUse = "should_use";
        break;
      case "FormatAttr":
        recognized = true;
        semantics.format = parseFormat(attribute, cName, source, {
          ...options,
          defaultSourceFile: source.file,
        });
        break;
      case "AllocSizeAttr": {
        const directParameters = [attribute.param1, attribute.param2]
          .map(numberValue)
          .filter((value): value is number => value !== undefined);
        const parameters = (directParameters.length > 0
          ? directParameters
          : macroArguments(attribute, options).map(Number))
          .map((value) =>
            Number(value) - 1
          )
          .filter((value) => Number.isInteger(value) && value >= 0);
        if (parameters.length > 0) {
          if (
            parameterCount !== undefined &&
            parameters.some((parameter) => parameter >= parameterCount)
          ) {
            throw new Error(
              `Invalid allocation-size parameter for ${cName} at ${source.file}:${source.line}: ` +
                `indices ${parameters.join(", ")} exceed ${parameterCount} parameters`,
            );
          }
          validateAllocationParameters(cName, source, parameterNodes, parameters);
          validatePointerReturn(cName, source, returnType, "allocation-size");
          if (new Set(parameters).size !== parameters.length) {
            throw new Error(
              `Contradictory allocation-size parameters for ${cName} at ${source.file}:${source.line}: ` +
                `${parameters.join(", ")} contains a duplicate`,
            );
          }
          recognized = true;
          semantics.allocationSize = { parameters };
        }
        break;
      }
      case "RestrictAttr":
        recognized = true;
        semantics.restrict = true;
        // Clang 19 lowers GNU malloc attributes to RestrictAttr in its JSON AST.
        // Recover only the SDL_MALLOC spelling from the stable expansion line;
        // SDL_RESTRICT remains alias metadata and never becomes an ownership promise.
        if (attributeInvocationContains(attribute, options, "SDL_MALLOC")) {
          validatePointerReturn(cName, source, returnType, "malloc-like");
          semantics.mallocLike = true;
        }
        break;
      case "UnusedAttr":
        recognized = true;
        semantics.unused = true;
        break;
      case "FallThroughAttr":
        recognized = true;
        semantics.fallthrough = true;
        break;
      case "AlignedAttr":
      case "AlignmentAttr": {
        const [alignment] = macroArguments(attribute, options).map(Number);
        const directAlignment = numberValue(attribute.alignment ?? attribute.value);
        const resolvedAlignment = directAlignment ?? alignment;
        if (Number.isInteger(resolvedAlignment) && resolvedAlignment > 0) {
          recognized = true;
          semantics.alignment = resolvedAlignment;
        }
        break;
      }
      case "MallocAttr":
      case "MallocLikeAttr":
        validatePointerReturn(cName, source, returnType, "malloc-like");
        recognized = true;
        semantics.mallocLike = true;
        break;
    }
  }
  // A real NoReturnAttr is a runtime control-flow contract. It takes precedence over an analyzer
  // spelling if a compiler emits both attributes, while AnalyzerNoReturnAttr deliberately keeps
  // the C return type unchanged.
  if (explicitNoReturn) semantics.returnFlow = "no_return";
  else if (analyzerNoReturn) semantics.returnFlow = "analyzer_no_return";
  if (node.kind === "FunctionDecl") {
    const restrictParameters = parameterNodes.flatMap((parameter, index) => {
      const spelling = stringValue(record(parameter.type)?.qualType) ?? "";
      if (!/\brestrict\b/.test(spelling)) return [];
      if (!spelling.includes("*")) {
        throw new Error(
          `Invalid restrict metadata for ${cName} at ${source.file}:${source.line}: ` +
            `parameter ${index} has non-pointer type ${spelling}`,
        );
      }
      return [index];
    });
    if (restrictParameters.length > 0) {
      recognized = true;
      semantics.restrict = true;
      semantics.restrictParameters = restrictParameters;
    }
  }
  return recognized ? semantics : undefined;
}

function validateAllocationParameters(
  cName: string,
  source: AttributeSource,
  parameterNodes: JsonRecord[],
  parameters: number[],
): void {
  for (const parameter of parameters) {
    const spelling = stringValue(record(parameterNodes[parameter]?.type)?.qualType);
    if (spelling && !isIntegerSpelling(spelling)) {
      throw new Error(
        `Invalid allocation-size parameter for ${cName} at ${source.file}:${source.line}: ` +
          `parameter ${parameter} has non-integer type ${spelling}`,
      );
    }
  }
}

function isIntegerSpelling(spelling: string): boolean {
  const normalized = spelling.replace(/\bconst\b|\bvolatile\b/g, "").trim();
  return /^(?:unsigned|signed)?\s*(?:char|short|int|long|size_t|ssize_t|ptrdiff_t|u?int\d*_t|SDL_[A-Za-z0-9_]*Size[A-Za-z0-9_]*)$/
    .test(
      normalized,
    );
}

function validatePointerReturn(
  cName: string,
  source: AttributeSource,
  returnType: string | undefined,
  contract: string,
): void {
  if (returnType) {
    const signatureEnd = returnType.indexOf("(");
    const resultType = signatureEnd >= 0 ? returnType.slice(0, signatureEnd) : returnType;
    if (resultType.includes("*")) return;
    throw new Error(
      `Invalid ${contract} metadata for ${cName} at ${source.file}:${source.line}: ` +
        `function return type ${returnType} is not a pointer`,
    );
  }
}

function parseFormat(
  attribute: JsonRecord,
  cName: string,
  source: AttributeSource,
  options: {
    sourceTextByFile?: Record<string, string>;
    defaultSourceFile?: string;
  },
): FormatContract {
  const dialectValue = stringValue(attribute.dialect) ?? stringValue(attribute.formatKind);
  const declaredDialect = dialectValue === "scanf"
    ? "scanf"
    : dialectValue === "printf"
    ? "printf"
    : undefined;
  let formatIndex = numberValue(
    attribute.formatParameter ?? attribute.formatIdx ?? attribute.formatIndex,
  );
  let firstIndex = numberValue(
    attribute.firstVariadicParameter ?? attribute.firstArg ?? attribute.firstVariadicArg,
  );
  let vaList = attribute.firstVariadicParameter === "va_list" || attribute.firstArg === "va_list";
  let inferredDialect: FormatContract["dialect"] | undefined = declaredDialect;
  if (formatIndex === undefined || (firstIndex === undefined && !vaList) || !inferredDialect) {
    const invocation = formatInvocation(attribute, options);
    if (invocation) {
      inferredDialect = invocation.dialect;
      formatIndex ??= invocation.formatParameter;
      firstIndex ??= invocation.firstVariadicParameter === "va_list"
        ? undefined
        : invocation.firstVariadicParameter;
      vaList ||= invocation.firstVariadicParameter === "va_list";
    }
  }
  const dialect = inferredDialect;
  if (!dialect || formatIndex === undefined || (firstIndex === undefined && !vaList)) {
    throw new Error(
      `Malformed FormatAttr for ${cName} at ${source.file}:${source.line}: ` +
        "expected dialect, format parameter, and first variadic parameter",
    );
  }
  if (formatIndex < 1 || (!vaList && firstIndex! < 1)) {
    throw new Error(
      `Malformed FormatAttr for ${cName} at ${source.file}:${source.line}: indexes are one-based positive integers`,
    );
  }
  return {
    dialect,
    formatParameter: formatIndex - 1,
    firstVariadicParameter: vaList ? "va_list" : firstIndex! - 1,
  };
}

function formatInvocation(
  attribute: JsonRecord,
  options: { sourceTextByFile?: Record<string, string>; defaultSourceFile?: string },
): FormatContract | undefined {
  const range = record(attribute.range);
  const begin = record(range?.begin);
  const expansion = record(begin?.expansionLoc) ?? begin;
  const line = numberValue(expansion?.line);
  const column = numberValue(expansion?.col);
  if (line === undefined) return undefined;
  const file = stringValue(expansion?.file) ?? options.defaultSourceFile;
  if (!file) return undefined;
  const source = lookupSource(options.sourceTextByFile, file);
  if (!source) return undefined;
  const sourceLine = source.split(/\r?\n/)[line - 1];
  if (!sourceLine) return undefined;
  const start = Math.max(0, (column ?? 1) - 1);
  const invocation = sourceLine.slice(start).match(
    /([A-Za-z_]\w*)\s*\(\s*([0-9]+)\s*(?:,\s*([0-9]+)\s*)?\)/,
  );
  if (!invocation) {
    const direct = sourceLine.slice(start).match(
      /format\s*\(\s*(__?printf__?|__?scanf__?)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*\)/,
    );
    if (!direct) return undefined;
    return {
      dialect: direct[1].includes("scanf") ? "scanf" : "printf",
      formatParameter: Number(direct[2]),
      firstVariadicParameter: Number(direct[3]),
    };
  }
  const macro = invocation[1].toUpperCase();
  if (!macro.includes("PRINTF") && !macro.includes("SCANF")) return undefined;
  const formatParameter = Number(invocation[2]);
  if (!Number.isInteger(formatParameter)) return undefined;
  const isVaList = macro.endsWith("FUNCV") || macro.endsWith("FUNCV_ATTR");
  const firstVariadicParameter = isVaList
    ? "va_list" as const
    : Number(invocation[3] ?? formatParameter + 1);
  if (!isVaList && !firstVariadicParameter) return undefined;
  return {
    dialect: macro.includes("SCANF") ? "scanf" : "printf",
    formatParameter,
    firstVariadicParameter,
  };
}

function macroArguments(
  attribute: JsonRecord,
  options: { sourceTextByFile?: Record<string, string>; defaultSourceFile?: string },
): string[] {
  const range = record(attribute.range);
  const begin = record(range?.begin);
  const expansion = record(begin?.expansionLoc) ?? begin;
  const line = numberValue(expansion?.line);
  const column = numberValue(expansion?.col);
  const file = stringValue(expansion?.file) ?? options.defaultSourceFile;
  if (line === undefined || !file) return [];
  const source = lookupSource(options.sourceTextByFile, file);
  const sourceLine = source?.split(/\r?\n/)[line - 1];
  if (!sourceLine) return [];
  const start = Math.max(0, (column ?? 1) - 1);
  const match = sourceLine.slice(start).match(/[A-Za-z_]\w*\s*\(([^)]*)\)/);
  return match
    ? match[1].split(",").map((value) => value.trim()).filter((value) => /^\d+$/.test(value))
    : [];
}

function attributeInvocationContains(
  attribute: JsonRecord,
  options: { sourceTextByFile?: Record<string, string>; defaultSourceFile?: string },
  token: string,
): boolean {
  const line = sourceLineForAttribute(attribute, options);
  return line?.includes(token) ?? false;
}

function sourceLineForAttribute(
  attribute: JsonRecord,
  options: { sourceTextByFile?: Record<string, string>; defaultSourceFile?: string },
): string | undefined {
  const range = record(attribute.range);
  const begin = record(range?.begin);
  const expansion = record(begin?.expansionLoc) ?? record(begin?.spellingLoc) ?? begin;
  const line = numberValue(expansion?.line);
  const file = stringValue(expansion?.file) ?? options.defaultSourceFile;
  if (line === undefined || !file) return undefined;
  return lookupSource(options.sourceTextByFile, file)?.split(/\r?\n/)[line - 1];
}

function lookupSource(
  sourceTextByFile: Record<string, string> | undefined,
  file: string,
): string | undefined {
  if (!sourceTextByFile) return undefined;
  const normalized = file.replaceAll("\\", "/");
  return sourceTextByFile[normalized] ?? sourceTextByFile[file] ??
    Object.entries(sourceTextByFile).find(([key]) => key.endsWith(`/${normalized}`))?.[1];
}

function sourceOf(
  node: JsonRecord,
  options: { sourceTextByFile?: Record<string, string>; defaultSourceFile?: string },
): AttributeSource | undefined {
  const loc = record(node.loc) ?? record(record(node.range)?.begin);
  if (!loc) return undefined;
  const attributes = Array.isArray(node.inner) ? node.inner.filter(isRecord) : [];
  const firstAttributeLocation = attributes
    .map((attribute) => record(record(attribute.range)?.begin))
    .map((begin) => record(begin?.expansionLoc) ?? record(begin?.spellingLoc) ?? begin)
    .find((candidate) => stringValue(candidate?.file) !== undefined);
  const formatAttributeLocation = attributes
    .filter((attribute) => attribute.kind === "FormatAttr")
    .map((attribute) => record(record(attribute.range)?.begin))
    .map((begin) => record(begin?.expansionLoc) ?? record(begin?.spellingLoc) ?? begin)
    .find((candidate) => stringValue(candidate?.file) !== undefined);
  const attributeLocation = stringValue(firstAttributeLocation?.file) !== undefined
    ? firstAttributeLocation
    : formatAttributeLocation ?? firstAttributeLocation;
  let file = stringValue(loc.file) ?? stringValue(record(loc.spellingLoc)?.file) ??
    stringValue(record(loc.expansionLoc)?.file) ?? stringValue(attributeLocation?.file) ??
    options.defaultSourceFile;
  const line = numberValue(loc.line) ?? numberValue(record(loc.spellingLoc)?.line) ??
    numberValue(record(loc.expansionLoc)?.line) ?? numberValue(attributeLocation?.line);
  if (
    !file && line !== undefined && options.sourceTextByFile && typeof node.name === "string" &&
    attributes.some((attribute) => attribute.kind === "FormatAttr")
  ) {
    const candidates = Object.entries(options.sourceTextByFile)
      .filter(([, text]) => text.split(/\r?\n/)[line - 1]?.includes(node.name as string))
      .map(([candidate]) => candidate);
    if (candidates.length === 1) file = candidates[0];
  }
  if (!file || line === undefined) return undefined;
  return { file: file.replaceAll("\\", "/"), line, column: numberValue(loc.col) };
}

function visibility(value: unknown): DeclarationSemantics["linkage"] {
  const name = stringValue(value);
  if (name === "hidden") return "hidden";
  if (name === "protected" || name === "default") return "exported";
  return "default";
}

function isPublicSource(file: string, prefixes: string[]): boolean {
  const normalizedFile = file.replaceAll("\\", "/");
  return prefixes.length === 0 || prefixes.some((prefix) => {
    const normalizedPrefix = prefix.replaceAll("\\", "/");
    if (normalizedFile.startsWith(normalizedPrefix)) return true;
    // Clang's JSON may preserve a repository-relative expansion path while the analysis
    // configuration carries an absolute public-header path. Accept that stable suffix match;
    // system headers cannot satisfy it because they are outside the configured public roots.
    return !normalizedFile.startsWith("/") &&
      normalizedPrefix.endsWith(`/${normalizedFile}`);
  });
}

function record(value: unknown): JsonRecord | undefined {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as JsonRecord
    : undefined;
}

function isRecord(value: unknown): value is JsonRecord {
  return !!record(value);
}

function stringValue(value: unknown): string | undefined {
  return typeof value === "string" ? value : undefined;
}

function numberValue(value: unknown): number | undefined {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && /^\d+$/.test(value)) return Number(value);
  return undefined;
}
