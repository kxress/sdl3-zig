import { assert, assertEquals, assertRejects } from "@std/assert";
import {
  packageDocumentation,
  packageVersion,
  validateDocumentationArtifact,
  validateManifest,
} from "../scripts/package-documentation.ts";

Deno.test("documentation publication derives and validates release metadata", async () => {
  assertEquals(packageVersion('.{ .version = "3.4.12+9" }'), "3.4.12+9");
  await assertRejects(
    () =>
      Promise.resolve().then(() =>
        validateManifest({
          format: 1,
          package_version: "3.4.12+9",
          release_tag: "v3.4.12+9",
          commit: "a".repeat(40),
          version_path: "v3.4.12+9",
          latest_path: "latest",
          content_sha256: "a".repeat(64),
          coverage_sha256: "b".repeat(64),
          coverage_identity_count: 1,
          links: [],
        }, "v3.4.12+8")
      ),
    Error,
    "wrong release tag",
  );
});

Deno.test("documentation publication retains versions and detects artifact drift", async () => {
  const directory = await Deno.makeTempDir({ prefix: "sdl-docs-publication-" });
  try {
    const input = `${directory}/generated`;
    const output = `${directory}/site`;
    const existing = `${directory}/existing`;
    await Deno.mkdir(input, { recursive: true });
    await Deno.mkdir(`${existing}/.git`, { recursive: true });
    await Deno.mkdir(`${existing}/v3.4.12`, { recursive: true });
    await Deno.writeTextFile(`${existing}/v3.4.12/index.html`, "old docs\n");
    await Deno.writeTextFile(`${input}/index.html`, "generated docs\n");

    const manifest = await packageDocumentation({
      input,
      output,
      existing,
      tag: "v3.4.12+9",
      commit: "a".repeat(40),
    });
    assertEquals(manifest.version_path, "v3.4.12+9");
    assert(await Deno.stat(`${output}/v3.4.12+9/index.html`));
    assert(await Deno.stat(`${output}/v3.4.12/index.html`));
    assert(await Deno.stat(`${output}/latest/index.html`));
    await assertRejects(() => Deno.stat(`${output}/.git`), Deno.errors.NotFound);
    await validateDocumentationArtifact(output, "v3.4.12+9", "a".repeat(40));

    await Deno.writeTextFile(`${output}/latest/index.html`, "tampered docs\n");
    await assertRejects(
      () => validateDocumentationArtifact(output),
      Error,
      "content does not match",
    );

    await Deno.writeTextFile(`${output}/index.html`, '<a href="missing/">broken</a>\n');
    await assertRejects(
      () => validateDocumentationArtifact(output),
      Error,
      "broken link",
    );
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});
