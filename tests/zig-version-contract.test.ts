import { assertEquals, assertStringIncludes } from "@std/assert";

const supportedVersion = "0.16.0";

Deno.test("package, documentation, CI, and fixtures agree on exact Zig version", async () => {
  const packageManifest = await Deno.readTextFile("build.zig.zon");
  assertStringIncludes(packageManifest, `.minimum_zig_version = "${supportedVersion}"`);

  const mise = await Deno.readTextFile("mise.toml");
  assertStringIncludes(mise, `zig = "${supportedVersion}"`);

  const buildScript = await Deno.readTextFile("build.zig");
  assertStringIncludes(buildScript, ".major = 0, .minor = 16, .patch = 0");
  assertStringIncludes(buildScript, `SDL3 requires exactly Zig ${supportedVersion}`);

  const metadataScript = await Deno.readTextFile("scripts/sync-package-metadata.ts");
  assertStringIncludes(metadataScript, `.minimum_zig_version = "${supportedVersion}"`);
  const reproducibilityScript = await Deno.readTextFile("scripts/release-repro.ts");
  assertStringIncludes(reproducibilityScript, `.minimum_zig_version = "${supportedVersion}"`);

  const readme = await Deno.readTextFile("README.md");
  assertStringIncludes(readme, `exactly Zig ${supportedVersion}`);

  const ci = await Deno.readTextFile(".github/workflows/ci.yml");
  assertStringIncludes(ci, "uses: jdx/mise-action@v3");
  assertStringIncludes(ci, "install: true");

  const fixtureRoot = "tests/build/fixtures";
  for await (const entry of Deno.readDir(fixtureRoot)) {
    if (!entry.isDirectory) continue;
    const path = `${fixtureRoot}/${entry.name}/build.zig.zon`;
    const manifest = await Deno.readTextFile(path).catch(() => undefined);
    if (manifest !== undefined) {
      assertStringIncludes(manifest, `.minimum_zig_version = "${supportedVersion}"`);
    }
  }

  const zigVersion = (await new Deno.Command("zig", { args: ["version"] }).output()).stdout;
  assertEquals(new TextDecoder().decode(zigVersion).trim(), supportedVersion);
});
