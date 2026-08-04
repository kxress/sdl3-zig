import { relative, resolve } from "@std/path";
import { codegenConfiguration } from "./codegen/config.ts";
import { generateRepositoryBindings } from "./generate-bindings.ts";
import { repositoryRoot } from "./utils/paths.ts";

export async function assertRepositoryBindingsCurrent(): Promise<void> {
  const cacheRoot = resolve(repositoryRoot, ".zig-cache");
  await Deno.mkdir(cacheRoot, { recursive: true });
  const temporary = await Deno.makeTempDir({ dir: cacheRoot, prefix: "generated-bindings-" });
  try {
    await generateRepositoryBindings({ outputRoot: temporary });
    await assertGeneratedBindingsMatch(temporary);
  } finally {
    await Deno.remove(temporary, { recursive: true });
  }
}

export async function assertGeneratedBindingsMatch(
  generatedRoot: string,
  committedRoot = resolve(repositoryRoot, "src"),
): Promise<void> {
  const expected = codegenConfiguration.libraries.map((library) => library.output).sort();
  const actual = (await filesUnder(generatedRoot)).filter((file) => file !== "COVERAGE.md").sort();
  if (actual.join("\n") !== expected.join("\n")) {
    throw new Error(
      `Generated binding file set differs. Expected ${expected.join(", ")}; got ${
        actual.join(", ")
      }`,
    );
  }

  for (const output of expected) {
    const generated = await Deno.readTextFile(resolve(generatedRoot, output));
    const committed = await Deno.readTextFile(resolve(committedRoot, output));
    if (generated !== committed) {
      throw new Error(`Generated binding ${output} differs from the committed source`);
    }
  }
}

export async function assertGeneratedCoverageReportMatch(
  generatedRoot: string,
  committedReport = resolve(repositoryRoot, "COVERAGE.md"),
): Promise<void> {
  const generated = await Deno.readTextFile(resolve(generatedRoot, "COVERAGE.md"));
  const committed = await Deno.readTextFile(committedReport);
  if (generated !== committed) {
    throw new Error("Generated COVERAGE.md differs from the committed report");
  }
}

async function filesUnder(root: string): Promise<string[]> {
  const files: string[] = [];
  for await (const entry of Deno.readDir(root)) {
    const path = resolve(root, entry.name);
    if (entry.isDirectory) {
      files.push(...(await filesUnder(path)).map((file) => `${entry.name}/${file}`));
    } else if (entry.isFile) {
      files.push(relative(root, path));
    }
  }
  return files;
}
