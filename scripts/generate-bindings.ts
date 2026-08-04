import { resolve } from "@std/path";
import { codegenConfiguration, renderTranslationUnit } from "./codegen/config.ts";
import { writeCoverageReport } from "./codegen/coverage.ts";
import { generateBindings, type GeneratedBinding } from "./codegen/generator.ts";
import { repositoryRoot } from "./utils/paths.ts";
import { runCommand } from "./utils/command.ts";

export async function generateRepositoryBindings(
  options: { outputRoot?: string; coverageOutput?: string } = {},
): Promise<void> {
  const outputRoot = options.outputRoot ?? resolve(repositoryRoot, "src");
  const coverageOutput = options.coverageOutput ??
    (options.outputRoot === undefined ? resolve(repositoryRoot, "COVERAGE.md") : undefined);
  await Deno.mkdir(outputRoot, { recursive: true });

  const apiPromises = new Map<string, Promise<GeneratedBinding>>();
  const outputs = codegenConfiguration.libraries.map((library) =>
    resolve(outputRoot, library.output)
  );

  for (const library of codegenConfiguration.libraries) {
    const moduleName = library.profile.moduleName;
    const dependencies = library.profile.dependencies.map((dependency) => {
      const api = apiPromises.get(dependency);
      if (!api) {
        throw new Error(`Missing configured dependency ${dependency} for ${moduleName}`);
      }
      return api.then((resolvedApi) => [dependency, resolvedApi] as const);
    });
    const api = Promise.all(dependencies).then(async (resolvedDependencies) => {
      const output = resolve(outputRoot, library.output);
      const generated = await generateBindings({
        translationUnit: renderTranslationUnit(library.headers),
        output,
        includeDirectories: library.includeDirectories.map(resolveRepositoryPath),
        publicIncludeDirectories: library.publicIncludeDirectories.map(resolveRepositoryPath),
        profile: library.profile,
        dependencyApis: new Map(resolvedDependencies),
        defines: codegenConfiguration.defines,
        macroPrefixes: library.profile.macroPrefixes,
        targets: codegenConfiguration.targets,
        documentationInput: resolveRepositoryPath(library.documentation),
        documentationPredefined: codegenConfiguration.documentationPredefined,
        sourceLabel: library.sourceLabel,
      });
      console.log(`Wrote ${output}`);
      return generated;
    });
    apiPromises.set(moduleName, api);
  }

  await Promise.all(apiPromises.values());
  await runCommand("zig", ["fmt", ...outputs.sort()], {
    cwd: repositoryRoot,
    stdout: "inherit",
    stderr: "inherit",
  });
  if (coverageOutput) {
    const generated = await Promise.all(apiPromises.values());
    await writeCoverageReport(
      coverageOutput,
      generated.map((binding) => binding.coverage),
    );
    console.log(`Wrote ${coverageOutput}`);
  }
}

function resolveRepositoryPath(path: string): string {
  return resolve(repositoryRoot, path);
}

if (import.meta.main) {
  if (Deno.args.length !== 0) {
    throw new Error("generate-bindings.ts does not accept arguments");
  }
  await generateRepositoryBindings();
}
