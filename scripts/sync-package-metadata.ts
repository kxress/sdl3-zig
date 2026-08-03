import {
  type CodegenConfiguration,
  codegenConfiguration,
  type LibraryConfiguration,
  renderTranslationUnit,
} from "./codegen/config.ts";
import {
  loadSdlRelease,
  packagePaths,
  releaseVersion,
  type SdlComponent,
  type SdlRelease,
  windowsOptionalArchitectures,
} from "./sdl-release.ts";
import { repositoryRoot } from "./utils/paths.ts";

const root = repositoryRoot;
if (import.meta.main) {
  const [command, ...rest] = Deno.args;
  if (rest.length !== 0 || (command !== "write" && command !== "check")) {
    throw new Error("usage: sync-package-metadata.ts write|check");
  }
  const release = await loadSdlRelease();
  const zon = renderBuildZon(release);
  const zig = renderSdlMetadata(release, codegenConfiguration);
  if (command === "write") {
    await Deno.writeTextFile(`${root}/build.zig.zon`, zon);
    await Deno.writeTextFile(`${root}/sdl_metadata.zig`, zig);
    console.log("Synchronized build.zig.zon and sdl_metadata.zig.");
  } else {
    await requireCurrent(`${root}/build.zig.zon`, zon);
    await requireCurrent(`${root}/sdl_metadata.zig`, zig);
    console.log(`Validated package metadata for SDL ${releaseVersion(release)}.`);
  }
}

function renderBuildZon(release: SdlRelease): string {
  const paths = packagePaths(release);
  return [
    ".{",
    "    .name = .sdl3,",
    `    .version = "${releaseVersion(release)}",`,
    "    .fingerprint = 0x6188f62fec324241,",
    '    .minimum_zig_version = "0.16.0",',
    "    .dependencies = .{},",
    "    .paths = .{",
    ...paths.map((path) => `        "${path}",`),
    "    },",
    "}",
    "",
  ].join("\n");
}

function renderSdlMetadata(
  release: SdlRelease,
  bindings: CodegenConfiguration,
): string {
  const libraries = mergeLibraries(release, bindings).flatMap(({ component, binding }) => [
    "    .{",
    `        .key = ${quote(component.key)},`,
    `        .id = ${quote(component.id)},`,
    `        .vendor_id = ${quote(component.vendorId)},`,
    `        .module_name = ${quote(binding.profile.moduleName)},`,
    `        .abi_import_name = ${quote(binding.profile.abiImportName)},`,
    `        .source = ${quote(`src/${binding.output}`)},`,
    `        .translation_unit = ${quote(renderTranslationUnit(binding.headers))},`,
    `        .include_directories = ${renderStrings(binding.includeDirectories)},`,
    `        .dependencies = ${renderStrings(binding.profile.dependencies)},`,
    `        .library_name = ${quote(component.libraryName ?? component.id)},`,
    `        .framework_name = ${quote(component.id)},`,
    `        .prebuilt = ${component.prebuilt},`,
    `        .source_build_directory = ${quote(component.sourceBuildDirectory ?? "")},`,
    `        .macos_optional_frameworks = ${
      renderStrings(component.macosOptionalFrameworks ?? [])
    },`,
    `        .windows_optional_runtime = ${
      renderWindowsOptional(component.windowsOptionalRuntime)
    },`,
    "    },",
  ]);
  return [
    "// Generated from mise.sdl.toml, scripts/sdl-release.ts, and scripts/codegen/config.ts by scripts/sync-package-metadata.ts. Do not edit.",
    'const std = @import("std");',
    "",
    "pub const translation_defines: []const []const u8 = " +
    renderStrings(bindings.defines) + ";",
    "",
    "pub const WindowsOptionalRuntime = struct {",
    "    mingw_architectures: []const []const u8,",
    "    msvc_architectures: []const []const u8,",
    "    dlls: []const []const u8,",
    "    licenses: []const []const u8,",
    "};",
    "",
    "pub const Library = struct {",
    "    key: []const u8,",
    "    id: []const u8,",
    "    vendor_id: []const u8,",
    "    module_name: []const u8,",
    "    abi_import_name: []const u8,",
    "    source: []const u8,",
    "    translation_unit: []const u8,",
    "    include_directories: []const []const u8,",
    "    dependencies: []const []const u8,",
    "    library_name: []const u8,",
    "    framework_name: []const u8,",
    "    prebuilt: bool,",
    "    source_build_directory: []const u8,",
    "    macos_optional_frameworks: []const []const u8,",
    "    windows_optional_runtime: ?WindowsOptionalRuntime,",
    "};",
    "",
    "pub const libraries = [_]Library{",
    ...libraries,
    "};",
    "",
    "pub fn byKey(key: []const u8) *const Library {",
    "    inline for (&libraries) |*library| {",
    "        if (std.mem.eql(u8, key, library.key)) return library;",
    "    }",
    '    @panic("unknown SDL library key");',
    "}",
    "",
  ].join("\n");
}

function mergeLibraries(
  release: SdlRelease,
  bindings: CodegenConfiguration,
): Array<{ component: SdlComponent; binding: LibraryConfiguration }> {
  const components = new Map(release.components.map((component) => [component.id, component]));
  const merged = bindings.libraries.map((binding) => {
    const component = components.get(binding.id);
    if (!component) {
      throw new Error(
        `The codegen configuration contains ${binding.id}, which is absent from scripts/sdl-release.ts`,
      );
    }
    components.delete(binding.id);
    return { component, binding };
  });
  if (components.size !== 0) {
    throw new Error(
      `scripts/sdl-release.ts components missing from the codegen configuration: ${
        [...components.keys()].join(", ")
      }`,
    );
  }
  return merged;
}

function quote(value: string): string {
  return JSON.stringify(value);
}

function renderStrings(strings: readonly string[]): string {
  if (strings.length === 0) return "&.{}";
  if (strings.length === 1) return `&.{${quote(strings[0])}}`;
  return `&.{ ${strings.map(quote).join(", ")} }`;
}

function renderWindowsOptional(runtime: SdlComponent["windowsOptionalRuntime"]): string {
  if (!runtime) return "null";
  return ".{ .mingw_architectures = " + renderStrings(windowsOptionalArchitectures.mingw) +
    ", .msvc_architectures = " + renderStrings(windowsOptionalArchitectures.msvc) +
    ", .dlls = " + renderStrings(runtime.dlls) + ", .licenses = " +
    `${renderStrings(runtime.licenses)} }`;
}

async function requireCurrent(path: string, expected: string): Promise<void> {
  if (await Deno.readTextFile(path) !== expected) {
    throw new Error(`${path.slice(path.lastIndexOf("/") + 1)} is stale; run deno task generate`);
  }
}
