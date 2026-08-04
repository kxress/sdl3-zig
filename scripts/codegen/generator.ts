import { dirname } from "@std/path";
import { analyzeTargets, type ApiModel, mergeApiModels } from "./analysis.ts";
import type { LibraryProfile, PublicApi, PublicReference, PublicSymbol } from "./profile.ts";
import { renderSemanticBindings } from "./render.ts";

export interface GenerateOptions {
  translationUnit: string;
  output: string;
  includeDirectories: string[];
  publicIncludeDirectories: string[];
  profile: LibraryProfile;
  dependencyApis: ReadonlyMap<string, PublicApi>;
  defines: string[];
  macroPrefixes?: string[];
  targets: string[];
  documentationInput: string;
  documentationPredefined: string[];
  sourceLabel: string;
}

export async function generateBindings(options: GenerateOptions): Promise<PublicApi> {
  const models = await analyzeTargets({
    translationUnit: options.translationUnit,
    includeDirectories: options.includeDirectories,
    publicIncludeDirectories: options.publicIncludeDirectories,
    apiPrefixes: options.profile.symbolPrefixes,
    macroPrefixes: options.macroPrefixes,
    defines: options.defines,
    targets: options.targets,
    documentationInput: options.documentationInput,
    documentationProjectName: options.profile.displayName,
    documentationPredefined: options.documentationPredefined,
  });
  const mergedModel = mergeApiModels(models);
  const rendered = renderSemanticBindings(
    mergedModel,
    options.profile,
    options.dependencyApis,
  );
  validateGeneratedSource(rendered.source);
  await writeGeneratedFile(options.output, rendered.source, options.sourceLabel);
  return {
    moduleName: options.profile.moduleName,
    symbolPrefixes: [...options.profile.symbolPrefixes],
    symbols: rendered.symbols,
    references: collectPublicReferences(mergedModel, rendered.symbols, options.profile),
  };
}

function collectPublicReferences(
  model: ApiModel,
  symbols: PublicSymbol[],
  profile: LibraryProfile,
): PublicReference[] {
  const emitted = new Set(symbols.map((symbol) => symbol.cName));
  const references = new Map<string, PublicReference>();
  for (const documentation of model.documentation) {
    if (
      emitted.has(documentation.name) ||
      !profile.symbolPrefixes.some((prefix) => documentation.name.startsWith(prefix))
    ) continue;
    const existing = references.get(documentation.name);
    if (!existing || documentation.kind === "define") {
      references.set(documentation.name, {
        cName: documentation.name,
        kind: documentation.kind,
      });
    }
  }
  return [...references.values()].sort((left, right) =>
    left.cName.localeCompare(right.cName) || left.kind.localeCompare(right.kind)
  );
}

function renderGeneratedFile(sourceLabel: string, generatedSource: string): string {
  const normalizedSource = generatedSource.replaceAll(/[ \t]+$/gm, "").trimEnd();
  return [
    `// Generated from ${sourceLabel} by sdl-zig-codegen. Do not edit.`,
    "",
    normalizedSource,
    "",
  ].join("\n");
}

function validateGeneratedSource(source: string): void {
  if (source.includes("[*c]")) {
    throw new Error("Generated public API leaks an unsupported C pointer type");
  }
  if (/^pub const support\b/m.test(source)) {
    throw new Error("Generated public API exposes the private support module");
  }
  if (
    /^\s*pub (?:const|fn|var)\b[^\n]*\bsupport\./m.test(source) ||
    /^\s*pub (?:const|fn|var)\b[^\n]*@TypeOf\(c\./m.test(source)
  ) {
    throw new Error("Generated public API exposes a private module type");
  }

  const lines = source.split("\n");
  const reExportedRootNames = new Set(
    lines.flatMap((line) => {
      const match = line.match(
        /^\s*pub const [A-Za-z_@][A-Za-z0-9_@]* = root\.([A-Za-z_@][A-Za-z0-9_@]*);$/,
      );
      return match ? [match[1]] : [];
    }),
  );
  for (const [index, line] of lines.entries()) {
    const declaration = line.match(
      /^(\s*)(pub )?(?:const|fn|var)\s+([A-Za-z_@][A-Za-z0-9_@]*)/,
    );
    if (!declaration) continue;
    if (declaration[3] === "c") continue;
    const isForwardingAlias = declaration[2] && /^\s*pub const [^=]+ = root\./.test(line);
    const previous = lines[index - 1] ?? "";
    if (isForwardingAlias) {
      if (previous.startsWith(`${declaration[1]}///`)) {
        throw new Error(`Generated forwarding alias is documented: ${line.trim()}`);
      }
      continue;
    }
    const isExportedRootDeclaration = declaration[1] === "" &&
      !declaration[2] &&
      reExportedRootNames.has(declaration[3]);
    if (!declaration[2] && !isExportedRootDeclaration) continue;
    if (!previous.startsWith(`${declaration[1]}///`)) {
      throw new Error(`Generated public declaration is undocumented: ${line.trim()}`);
    }
  }
}

async function writeGeneratedFile(
  output: string,
  source: string,
  sourceLabel: string,
): Promise<void> {
  const outputDirectory = dirname(output);
  if (outputDirectory !== ".") await Deno.mkdir(outputDirectory, { recursive: true });
  await Deno.writeTextFile(output, renderGeneratedFile(sourceLabel, source));
}
