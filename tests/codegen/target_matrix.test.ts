import { assert, assertEquals } from "@std/assert";
import { analyzeTargets } from "../../scripts/codegen/analysis.ts";
import { codegenConfiguration } from "../../scripts/codegen/config.ts";

Deno.test("every advertised target receives an independent public-header analysis", async () => {
  const directory = await Deno.makeTempDir({ prefix: "sdl-target-matrix-" });
  try {
    await Deno.writeTextFile(
      `${directory}/pattern.h`,
      `/** Returns the target-independent pattern value. */\n` +
        `extern int PATTERN_Value(void);\n`,
    );
    const targets = [...codegenConfiguration.targets];
    const models = await analyzeTargets({
      translationUnit: '#include "pattern.h"\n',
      includeDirectories: [directory],
      publicIncludeDirectories: [directory],
      apiPrefixes: ["PATTERN_"],
      defines: [],
      targets,
      documentationInput: directory,
      documentationProjectName: "Pattern",
      documentationPredefined: [],
    });

    assertEquals(models.map((model) => model.target), targets);
    for (const model of models) {
      assertEquals(model.analysisTargets, targets);
      assert(
        model.publicNodeIds.some((id) =>
          model.nodes.find((node) => node.id === id)?.attributes.name === "PATTERN_Value"
        ),
      );
      assertEquals(
        model.publicNodeTargets[
          model.publicNodeIds.find((id) =>
            model.nodes.find((node) => node.id === id)?.attributes.name === "PATTERN_Value"
          )!
        ],
        [model.target],
      );
    }
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});
