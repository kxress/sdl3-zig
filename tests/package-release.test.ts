import { assert, assertEquals, assertRejects } from "@std/assert";
import {
  validateReleaseArchive,
  validateReleaseArchiveMembers,
  validateReleaseTree,
} from "../scripts/package-release.ts";
import { binaryArtifactNames, loadSdlRelease, packagePaths } from "../scripts/sdl-release.ts";
import {
  distributionPolicy,
  findPrebuiltTarget,
  prebuiltTargets,
  targetName,
  windowsOptionalArchitectures,
} from "../scripts/distribution-policy.ts";
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

Deno.test("release archive validation requires an exact, safe package member set", () => {
  const expected = ["sdl3-3.4.12+9", "sdl3-3.4.12+9/README.md"];
  validateReleaseArchiveMembers(
    ["sdl3-3.4.12+9/", "sdl3-3.4.12+9/README.md"],
    "sdl3-3.4.12+9",
    expected,
  );
  validateReleaseArchiveMembers(
    ["sdl3-3.4.12+9/README.md", "sdl3-3.4.12+9/"],
    "sdl3-3.4.12+9",
    expected,
  );
  assertRejects(
    () =>
      Promise.resolve().then(() =>
        validateReleaseArchiveMembers(
          ["sdl3-3.4.12+9/", "../outside"],
          "sdl3-3.4.12+9",
        )
      ),
    Error,
    "Unsafe",
  );
});

Deno.test("release archive validation checks a real tarball against its staged tree", async () => {
  await withTempDirectory("sdl-release-archive-", async (temporary) => {
    const packageName = "sdl3-test";
    const packageRoot = `${temporary}/${packageName}`;
    const archive = `${temporary}/${packageName}.tar.gz`;
    await Deno.mkdir(`${packageRoot}/src`, { recursive: true });
    await Deno.writeTextFile(`${packageRoot}/README.md`, "release");
    await Deno.writeTextFile(`${packageRoot}/src/module.zig`, "pub const value = 1;\n");
    const result = await new Deno.Command("tar", {
      args: ["--sort=name", "--mtime=@0", "-czf", archive, "-C", temporary, packageName],
    }).output();
    if (!result.success) throw new Error(new TextDecoder().decode(result.stderr));
    await validateReleaseArchive(archive, packageName, [
      packageName,
      `${packageName}/README.md`,
      `${packageName}/src`,
      `${packageName}/src/module.zig`,
    ]);
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

Deno.test("distribution policy accepts every packaged target and rejects matrix gaps", () => {
  for (const target of prebuiltTargets) {
    assertEquals(findPrebuiltTarget(target.os, target.abi, target.arch), target);
    assert(targetName(target).length !== 0);
  }

  for (const os of ["windows", "macos"] as const) {
    for (const abi of os === "windows" ? ["gnu", "msvc"] as const : [null]) {
      for (const arch of ["x86", "x86_64", "aarch64"] as const) {
        const accepted = prebuiltTargets.some((target) =>
          target.os === os && target.abi === abi && target.arch === arch
        );
        assertEquals(findPrebuiltTarget(os, abi, arch) !== undefined, accepted);
      }
    }
  }

  assertEquals(distributionPolicy.modes, ["none", "system", "prebuilt", "source"]);
  assertEquals(distributionPolicy.prebuilt.linkage, "shared");
  assertEquals(windowsOptionalArchitectures, {
    mingw: ["x86", "x86_64"],
    msvc: ["x86", "x86_64"],
  });
});
