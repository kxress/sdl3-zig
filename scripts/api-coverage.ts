import { relative, resolve } from "@std/path";
import { codegenConfiguration, renderTranslationUnit } from "./codegen/config.ts";
import { collectDoxygenDocumentation } from "./codegen/doxygen.ts";
import { repositoryRoot } from "./utils/paths.ts";
import { runCommand } from "./utils/command.ts";

export type CoverageKind =
  | "function"
  | "typedef"
  | "record"
  | "enum"
  | "callback"
  | "macro"
  | "inline";
export type TranslationClass = "generated" | "c" | "manual" | "excluded";

export interface CoverageIdentity {
  component: string;
  header: string;
  kind: CoverageKind;
  name: string;
  documented: boolean;
  preprocessed: boolean;
  targets: string[];
  translation: TranslationClass;
  reason?: string;
}

export interface CoverageInventory {
  format: 1;
  input_sha256: string;
  mise_sdl_sha256: string;
  identities: CoverageIdentity[];
}
export type CoverageEvolutionChange =
  | { kind: "added"; key: string; current: CoverageIdentity }
  | { kind: "removed"; key: string; previous: CoverageIdentity }
  | {
    kind: "disposition-changed";
    key: string;
    previous: CoverageIdentity;
    current: CoverageIdentity;
  };
type CoverageOverride = Pick<CoverageIdentity, "translation" | "reason" | "targets">;

export function validateCoverageInventory(inventory: CoverageInventory): void {
  const configuredTargets = new Set(codegenConfiguration.targets);
  const seen = new Set<string>();
  for (const identity of inventory.identities) {
    const key = `${identity.component}\0${identity.header}\0${identity.kind}\0${identity.name}`;
    if (seen.has(key)) throw new Error(`Duplicate coverage identity: ${key}`);
    seen.add(key);
    if (
      identity.targets.length === 0 ||
      identity.targets.some((target) => !configuredTargets.has(target))
    ) {
      throw new Error(`Coverage identity has unsupported target metadata: ${key}`);
    }
    if (identity.translation === "generated" && !identity.documented) {
      throw new Error(`Generated coverage identity is not a documented declaration: ${key}`);
    }
    if (identity.translation !== "generated" && !identity.reason) {
      throw new Error(`Non-generated coverage identity needs a reason: ${key}`);
    }
  }
}

export function compareCoverageInventories(
  previous: CoverageInventory,
  current: CoverageInventory,
): CoverageEvolutionChange[] {
  validateCoverageInventory(previous);
  validateCoverageInventory(current);
  const previousByKey = new Map(
    previous.identities.map((identity) => [coverageKey(identity), identity]),
  );
  const currentByKey = new Map(
    current.identities.map((identity) => [coverageKey(identity), identity]),
  );
  const changes: CoverageEvolutionChange[] = [];
  for (const [key, identity] of previousByKey) {
    const currentIdentity = currentByKey.get(key);
    if (!currentIdentity) {
      changes.push({ kind: "removed", key, previous: identity });
      continue;
    }
    if (
      identity.translation !== currentIdentity.translation ||
      identity.reason !== currentIdentity.reason ||
      !sameStrings(identity.targets, currentIdentity.targets)
    ) {
      changes.push({
        kind: "disposition-changed",
        key,
        previous: identity,
        current: currentIdentity,
      });
    }
  }
  for (const [key, identity] of currentByKey) {
    if (!previousByKey.has(key)) changes.push({ kind: "added", key, current: identity });
  }
  return changes.sort((left, right) => left.key.localeCompare(right.key));
}

export function validateCoverageEvolution(
  previous: CoverageInventory,
  current: CoverageInventory,
): void {
  const changes = compareCoverageInventories(previous, current);
  const unexplained = changes.filter((change) => change.kind !== "added");
  if (unexplained.length === 0) return;
  throw new Error(
    `Coverage evolution requires a reviewed baseline update:\n${
      unexplained.map((change) => `${change.kind}: ${change.key}`).join("\n")
    }`,
  );
}

export async function collectCoverageInventory(): Promise<CoverageInventory> {
  const identities = new Map<string, CoverageIdentity>();
  const overrides = JSON.parse(
    await Deno.readTextFile(`${repositoryRoot}/api_coverage_overrides.json`),
  ) as Record<string, Partial<CoverageOverride>>;
  const usedOverrides = new Set<string>();
  const inputs: string[] = [];
  for (const library of codegenConfiguration.libraries) {
    const documentation = await documentedNames(library);
    const preprocessed = await preprocessedNames(library);
    for (const directory of library.publicIncludeDirectories) {
      for await (const path of headerPaths(resolve(repositoryRoot, directory))) {
        if (path.replaceAll("\\", "/").includes("/build_config/")) continue;
        const source = await Deno.readTextFile(path);
        inputs.push(`${relative(repositoryRoot, path)}\n${source}`);
        for (
          const identity of extractHeaderIdentities(
            source,
            library.id,
            relative(repositoryRoot, path),
            [
              ...library.profile.symbolPrefixes,
              ...(library.profile.constantFamilies?.map((family) => family.prefix) ?? []),
            ],
            documentation,
            preprocessed,
            library.profile.constantFamilies?.map((family) => family.prefix) ?? [],
          )
        ) {
          const overrideKey = `${identity.component}:${identity.kind}:${identity.name}`;
          const override = overrides[overrideKey];
          if (override) usedOverrides.add(overrideKey);
          identities.set(
            `${identity.component}\0${identity.header}\0${identity.kind}\0${identity.name}`,
            { ...identity, ...override },
          );
        }
      }
    }
  }
  const unusedOverrides = Object.keys(overrides).filter((key) => !usedOverrides.has(key));
  if (unusedOverrides.length > 0) {
    throw new Error(
      `Coverage overrides do not match upstream identities: ${unusedOverrides.join(", ")}`,
    );
  }
  const input_sha256 = await sha256(inputs.sort().join("\n\0\n"));
  const mise_sdl_sha256 = await sha256(await Deno.readTextFile(`${repositoryRoot}/mise.sdl.toml`));
  const inventory: CoverageInventory = {
    format: 1,
    input_sha256,
    mise_sdl_sha256,
    identities: [...identities.values()].sort(compareIdentity),
  };
  validateCoverageInventory(inventory);
  return inventory;
}

export async function writeCoverageInventory(
  path = `${repositoryRoot}/api_coverage.json`,
): Promise<void> {
  const inventory = await collectCoverageInventory();
  validateCoverageInventory(inventory);
  await Deno.writeTextFile(path, `${JSON.stringify(inventory, null, 2)}\n`);
}

export async function checkCoverageInventory(
  path = `${repositoryRoot}/api_coverage.json`,
): Promise<void> {
  const expected = `${JSON.stringify(await collectCoverageInventory(), null, 2)}\n`;
  const actual = await Deno.readTextFile(path);
  if (actual !== expected) {
    throw new Error("api_coverage.json is stale; run `deno task generate:coverage`");
  }
}

export function extractHeaderIdentities(
  source: string,
  component: string,
  header: string,
  prefixes: readonly string[],
  documented = new Set<string>(),
  preprocessed = new Set<string>(),
  generatedMacroPrefixes: readonly string[] = [],
): CoverageIdentity[] {
  const result = new Map<string, CoverageIdentity>();
  const add = (kind: CoverageKind, name: string) => {
    if (!prefixes.some((prefix) => name.startsWith(prefix))) return;
    const isDocumented = documented.has(name);
    const isMacro = kind === "macro";
    const generatedMacro = isMacro &&
      (generatedMacroPrefixes.some((prefix) => name.startsWith(prefix)) ||
        safeFunctionMacros.has(name));
    result.set(`${kind}\0${name}`, {
      component,
      header,
      kind,
      name,
      documented: isDocumented,
      preprocessed: preprocessed.has(name),
      targets: [...codegenConfiguration.targets],
      translation: isDocumented && (!isMacro || generatedMacro) ? "generated" : "excluded",
      reason: isDocumented && (!isMacro || generatedMacro)
        ? undefined
        : isMacro
        ? isDocumented
          ? "Documented macro semantics require an explicit macro-family rule."
          : "Undocumented preprocessor artifact is not part of the supported public API."
        : "Undocumented header artifact is not part of the supported public API.",
    });
  };
  const compact = source.replaceAll(/\/\*[\s\S]*?\*\//g, " ").replaceAll(/\/\/.*$/gm, " ")
    .replaceAll(/\\\r?\n/g, " ");
  const functionMacroDefinitions = [...compact.matchAll(
    /^\s*#\s*define\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s+([^\n]*)/gm,
  )].map((match) => ({
    name: match[1],
    parameters: match[2].split(",").map((part) => part.trim()),
    replacement: match[3],
  }));
  const castMacroNames = new Set(
    functionMacroDefinitions
      .filter(({ parameters, replacement }) => isIntegerCastMacro(parameters, replacement))
      .map(({ name }) => name),
  );
  const functionNames = new Set(
    [...compact.matchAll(
      /\b(?:extern|static\s+inline)\b[\s\S]{0,240}?\b(\w+)\s*\([^;{}]*\)\s*(?:;|\{)/g,
    )].map((match) => match[1]),
  );
  const safeFunctionMacros = new Set<string>();
  let changed = true;
  while (changed) {
    changed = false;
    for (const macro of functionMacroDefinitions) {
      if (
        !safeFunctionMacros.has(macro.name) && (
          isSafeIntegerMacro(
            macro.parameters,
            macro.replacement,
            prefixes,
            safeFunctionMacros,
            castMacroNames,
          ) || isSafeFunctionMacro(
            macro.parameters,
            macro.replacement,
            prefixes,
            functionNames,
            safeFunctionMacros,
          )
        )
      ) {
        safeFunctionMacros.add(macro.name);
        changed = true;
      }
    }
  }
  for (const match of compact.matchAll(/^\s*#\s*define\s+([A-Za-z_]\w*)(?=[ \t(]|$)/gm)) {
    if (!match[1].endsWith("_h_")) add("macro", match[1]);
  }
  for (const match of compact.matchAll(/\btypedef\s+(?:struct|union)\s+(\w+)/g)) {
    add("record", match[1]);
  }
  for (const match of compact.matchAll(/\btypedef\s+enum\s+(\w+)/g)) add("enum", match[1]);
  for (
    const match of compact.matchAll(/\btypedef\b[\s\S]{0,200}?\(\s*[^)]*\*\s*(\w+)\s*\)\s*\(/g)
  ) add("callback", match[1]);
  for (const match of compact.matchAll(/\btypedef\b[\s\S]{0,200}?\b(\w+)\s*;/g)) {
    add("typedef", match[1]);
  }
  for (
    const match of compact.matchAll(
      /\b(?:extern|static\s+inline)\b[\s\S]{0,240}?\b(\w+)\s*\([^;{}]*\)\s*(?:;|\{)/g,
    )
  ) {
    add(match[0].includes("static inline") ? "inline" : "function", match[1]);
  }
  return [...result.values()];
}

function isSafeIntegerMacro(
  parameters: string[],
  replacement: string,
  prefixes: readonly string[],
  safeFunctionMacros: ReadonlySet<string>,
  castMacroNames: ReadonlySet<string>,
): boolean {
  if (parameters.length === 0 || parameters.some((parameter) => !/^\w+$/.test(parameter))) {
    return false;
  }
  if (/[\\'\"]/.test(replacement)) return false;
  if (
    parameters.some((parameter) =>
      new RegExp("\\b" + escapeRegExp(parameter) + "\\b", "g").exec(replacement) === null ||
      [...replacement.matchAll(new RegExp("\\b" + escapeRegExp(parameter) + "\\b", "g"))]
          .length !== 1 ||
      new RegExp("\\(\\s*" + escapeRegExp(parameter) + "\\s*\\)\\s*\\(").test(replacement)
    )
  ) return false;
  const identifiers = replacement.match(/\b[A-Za-z_]\w*\b/g) ?? [];
  for (const identifier of identifiers) {
    if (parameters.includes(identifier)) continue;
    if (new RegExp("->\\s*" + escapeRegExp(identifier) + "\\b").test(replacement)) continue;
    if (new RegExp("\\b" + escapeRegExp(identifier) + "\\s*\\(").test(replacement)) {
      if (!safeFunctionMacros.has(identifier) && !castMacroNames.has(identifier)) return false;
      continue;
    }
    if (
      new RegExp("SDL_static_cast\\s*\\(\\s*" + escapeRegExp(identifier) + "\\b")
        .test(replacement)
    ) continue;
    if (!prefixes.some((prefix) => identifier.startsWith(prefix))) return false;
  }
  return /^[A-Za-z0-9_().\s|&^+\-*/%<>=!~]+$/.test(replacement);
}

function isSafeFunctionMacro(
  parameters: string[],
  replacement: string,
  prefixes: readonly string[],
  functionNames: ReadonlySet<string>,
  safeFunctionMacros: ReadonlySet<string>,
): boolean {
  if (parameters.length === 0 || parameters.some((parameter) => !/^\w+$/.test(parameter))) {
    return false;
  }
  const expression = stripOuterParentheses(replacement.trim());
  const call = parseFunctionCall(expression);
  const comparison = expression.match(/^(.+?)\s*(?:==|!=)\s*-?\d+$/);
  const comparedCall = comparison
    ? parseFunctionCall(stripOuterParentheses(comparison[1]))
    : undefined;
  const parsed = call ?? comparedCall;
  if (!parsed || !prefixes.some((prefix) => parsed.name.startsWith(prefix))) return false;
  if (!functionNames.has(parsed.name) && !safeFunctionMacros.has(parsed.name)) return false;

  const normalizedParameters = new Set(parameters);
  const ordinaryArguments = parsed.args.slice(0, parameters.length);
  if (ordinaryArguments.length !== parameters.length) return false;
  if (
    ordinaryArguments.some((argument) => {
      const value = stripOuterParentheses(argument.trim());
      return !normalizedParameters.has(value) && !/^-?\d+$/.test(value);
    })
  ) return false;

  const extraArguments = parsed.args.slice(parameters.length);
  if (extraArguments.length === 0) return true;
  if (extraArguments.every((argument) => /^-?\d+$/.test(argument.trim()))) return true;
  return parsed.name.endsWith("Runtime") && extraArguments.every(isRuntimeHookArgument);
}

function parseFunctionCall(expression: string): { name: string; args: string[] } | undefined {
  const match = expression.match(/^([A-Za-z_]\w*)\s*\(/);
  if (!match) return undefined;
  const open = expression.indexOf("(", match[0].length - 1);
  let depth = 0;
  let close = -1;
  for (let index = open; index < expression.length; index++) {
    if (expression[index] === "(") depth++;
    else if (expression[index] === ")") {
      depth--;
      if (depth === 0) {
        close = index;
        break;
      }
    }
  }
  if (close < 0 || expression.slice(close + 1).trim() !== "") return undefined;
  const body = expression.slice(open + 1, close);
  const args: string[] = [];
  let start = 0;
  depth = 0;
  for (let index = 0; index <= body.length; index++) {
    const character = body[index];
    if (character === "(") depth++;
    else if (character === ")") depth--;
    else if ((character === "," && depth === 0) || index === body.length) {
      args.push(body.slice(start, index).trim());
      start = index + 1;
    }
  }
  return { name: match[1], args: args.length === 1 && args[0] === "" ? [] : args };
}

function stripOuterParentheses(value: string): string {
  let result = value.trim();
  while (result.startsWith("(") && matchingParenthesis(result, 0) === result.length - 1) {
    result = result.slice(1, -1).trim();
  }
  return result;
}

function matchingParenthesis(value: string, open: number): number {
  let depth = 0;
  for (let index = open; index < value.length; index++) {
    if (value[index] === "(") depth++;
    else if (value[index] === ")" && --depth === 0) return index;
  }
  return -1;
}

function isRuntimeHookArgument(value: string): boolean {
  return /^\(\s*[A-Za-z_]\w*FunctionPointer\s*\)\s*\(\s*[A-Za-z_]\w*\s*\)$/.test(
    value.trim(),
  );
}

function isIntegerCastMacro(parameters: string[], replacement: string): boolean {
  return parameters.length === 2 &&
    new RegExp(
      "^\\s*\\(\\s*\\(\\s*" + escapeRegExp(parameters[0]) +
        "\\s*\\)\\s*\\(\\s*" + escapeRegExp(parameters[1]) + "\\s*\\)\\s*\\)\\s*$",
    ).test(replacement);
}

function escapeRegExp(value: string): string {
  return value.replace(/[\\^$.*+?()[\]{}|]/g, "\\$&");
}

async function documentedNames(
  library: (typeof codegenConfiguration.libraries)[number],
): Promise<Set<string>> {
  const outputDirectory = await Deno.makeTempDir({ prefix: "sdl-zig-coverage-doxygen-" });
  try {
    const documentation = await collectDoxygenDocumentation({
      inputDirectory: resolve(repositoryRoot, library.documentation),
      outputDirectory,
      apiPrefixes: library.profile.symbolPrefixes,
      projectName: library.profile.displayName,
      predefined: codegenConfiguration.documentationPredefined,
    });
    return new Set(documentation.documentation.map(({ name }) => name));
  } finally {
    await Deno.remove(outputDirectory, { recursive: true });
  }
}

async function* headerPaths(directory: string): AsyncGenerator<string> {
  const info = await Deno.stat(directory);
  if (info.isFile) {
    if (directory.endsWith(".h")) yield directory;
    return;
  }
  for await (const entry of Deno.readDir(directory)) {
    const path = `${directory}/${entry.name}`;
    if (entry.isDirectory) yield* headerPaths(path);
    else if (entry.isFile && entry.name.endsWith(".h")) yield path;
  }
}

async function sha256(input: string): Promise<string> {
  return [...new Uint8Array(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(input)))]
    .map((byte) => byte.toString(16).padStart(2, "0")).join("");
}

function compareIdentity(left: CoverageIdentity, right: CoverageIdentity): number {
  return left.component.localeCompare(right.component) || left.header.localeCompare(right.header) ||
    left.kind.localeCompare(right.kind) || left.name.localeCompare(right.name);
}

function coverageKey(identity: CoverageIdentity): string {
  return `${identity.component}\0${identity.header}\0${identity.kind}\0${identity.name}`;
}

function sameStrings(left: readonly string[], right: readonly string[]): boolean {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

if (import.meta.main) {
  if (Deno.args[0] === "write" || Deno.args[0] === "check") {
    if (Deno.args.length !== 1) throw new Error("usage: api-coverage.ts <write|check>");
    if (Deno.args[0] === "write") await writeCoverageInventory();
    else await checkCoverageInventory();
  } else if (Deno.args[0] === "diff") {
    if (Deno.args.length < 2 || Deno.args.length > 3) {
      throw new Error("usage: api-coverage.ts diff <previous-ledger> [current-ledger]");
    }
    const previous = JSON.parse(await Deno.readTextFile(Deno.args[1])) as CoverageInventory;
    const currentPath = Deno.args[2] ?? `${repositoryRoot}/api_coverage.json`;
    const current = JSON.parse(await Deno.readTextFile(currentPath)) as CoverageInventory;
    validateCoverageEvolution(previous, current);
  } else {
    throw new Error("usage: api-coverage.ts <write|check|diff>");
  }
}

async function preprocessedNames(
  library: (typeof codegenConfiguration.libraries)[number],
): Promise<Set<string>> {
  const input = await Deno.makeTempFile({ suffix: ".c" });
  try {
    await Deno.writeTextFile(input, renderTranslationUnit(library.headers));
    const output = await runCommand("clang", [
      "-E",
      "-dM",
      "-x",
      "c",
      ...library.includeDirectories.map((directory) => `-I${resolve(repositoryRoot, directory)}`),
      ...codegenConfiguration.defines.map((define) => `-D${define}`),
      input,
    ]);
    return new Set([...output.stdout.matchAll(/^#define\s+([A-Za-z_]\w*)\b/gm)].map((m) => m[1]));
  } finally {
    await Deno.remove(input).catch(() => {});
  }
}
