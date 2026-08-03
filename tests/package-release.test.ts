import { assert, assertEquals, assertRejects } from "@std/assert";
import { validateReleaseTree } from "../scripts/package-release.ts";
import { binaryArtifactNames, loadSdlRelease, packagePaths } from "../scripts/sdl-release.ts";
import { withTempDirectory } from "./build/support.ts";

Deno.test("release staging rejects local source-build roots", async () => {
  await withTempDirectory("sdl-release-tree-", async (temporary) => {
    await Deno.mkdir(`${temporary}/sdl3-source`);
    await assertRejects(
      () => validateReleaseTree(temporary),
      Error,
      "Release tree contains a local build root: sdl3-source",
    );
  });
});

Deno.test("source-only modules and their source assets are packaged without prebuilt staging", async () => {
  const release = await loadSdlRelease();
  for (
    const [key, path] of [
      ["test", "vendor/SDL3"],
      ["controller_image", "vendor/ControllerImage"],
      ["shadercross", "vendor/SDL3_shadercross"],
    ]
  ) {
    const component = release.components.find((candidate) => candidate.key === key);
    if (!component) throw new Error(`missing ${key} release component`);
    assertEquals(component.prebuilt, false);
    assert(packagePaths(release).includes(path));
    assert(!release.components.filter((candidate) => candidate.prebuilt).includes(component));
  }
  await Deno.stat("vendor/SDL3/test/CMakeLists.txt");
  await Deno.stat("vendor/ControllerImage/art/standard/credits.txt");
  await Deno.stat("vendor/SDL3_shadercross/external/SPIRV-Cross/CMakeLists.txt");
});

Deno.test("SDL3_test shares SDL3's verified vendor tree", async () => {
  const release = await loadSdlRelease();
  const testComponent = release.components.find((component) => component.key === "test");
  if (!testComponent) throw new Error("missing SDL3_test release component");
  assertEquals(testComponent.vendorId, "SDL3");
  assert(packagePaths(release).includes("vendor/SDL3"));
  assert(!packagePaths(release).includes("vendor/SDL3_test"));
});

Deno.test("package metadata declares every official optional Windows runtime artifact", async () => {
  const release = await loadSdlRelease();
  const expected = new Map([
    [
      "image",
      {
        dlls: [
          "libavif-16.dll",
          "libpng16-16.dll",
          "libtiff-6.dll",
          "libwebp-7.dll",
          "libwebpdemux-2.dll",
          "libwebpmux-3.dll",
        ],
        licenses: [
          "LICENSE.aom.txt",
          "LICENSE.avif.txt",
          "LICENSE.dav1d.txt",
          "LICENSE.libpng.txt",
          "LICENSE.tiff.txt",
          "LICENSE.webp.txt",
        ],
      },
    ],
    [
      "mixer",
      {
        dlls: [
          "libgme.dll",
          "libogg-0.dll",
          "libopus-0.dll",
          "libopusfile-0.dll",
          "libwavpack-1.dll",
          "libxmp.dll",
        ],
        licenses: [
          "LICENSE.gme.txt",
          "LICENSE.ogg-vorbis.txt",
          "LICENSE.opus.txt",
          "LICENSE.opusfile.txt",
          "LICENSE.wavpack.txt",
          "LICENSE.xmp.txt",
        ],
      },
    ],
  ]);
  for (const [key, runtime] of expected) {
    const component = release.components.find((candidate) => candidate.key === key);
    if (!component || !component.windowsOptionalRuntime) {
      throw new Error(`missing ${key} optional Windows runtime metadata`);
    }
    const artifacts = binaryArtifactNames(component);
    assert(artifacts.includes(`http:sdl-${key}-mingw-x86-runtime`));
    assert(artifacts.includes(`http:sdl-${key}-mingw-x86_64-runtime`));
    assertEquals(component.windowsOptionalRuntime.dlls, runtime.dlls);
    assertEquals(component.windowsOptionalRuntime.licenses, runtime.licenses);
  }
});
