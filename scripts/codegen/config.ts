import type { ConstantFamily, LibraryProfile } from "./profile.ts";

export interface LibraryConfiguration {
  id: string;
  profile: LibraryProfile;
  headers: string[];
  includeDirectories: string[];
  publicIncludeDirectories: string[];
  documentation: string;
  output: string;
  sourceLabel: string;
}

export interface CodegenConfiguration {
  defines: string[];
  targets: string[];
  documentationPredefined: string[];
  libraries: LibraryConfiguration[];
}

const documentationPredefined = [
  "SDL_WIKI_DOCUMENTATION_SECTION=1",
  "SDL_DISABLE_OLD_NAMES=1",
  "SDL_PLATFORM_LINUX=1",
  "SDL_PLATFORM_WINDOWS=1",
  "SDL_PLATFORM_WIN32=1",
  "SDL_PLATFORM_APPLE=1",
  "SDL_PLATFORM_MACOS=1",
];
const coreIncludeDirectory = "vendor/SDL3/include";
const coreTestHeaders = [
  "SDL_test.h",
  "SDL_test_assert.h",
  "SDL_test_common.h",
  "SDL_test_compare.h",
  "SDL_test_crc32.h",
  "SDL_test_font.h",
  "SDL_test_fuzzer.h",
  "SDL_test_harness.h",
  "SDL_test_log.h",
  "SDL_test_md5.h",
  "SDL_test_memory.h",
].map((header) => `${coreIncludeDirectory}/SDL3/${header}`);

export const codegenConfiguration: CodegenConfiguration = {
  defines: ["SDL_DISABLE_OLD_NAMES=1"],
  targets: [
    "x86_64-linux-gnu",
    "x86_64-windows-gnu",
    "aarch64-macos",
    "aarch64-ios",
    "aarch64-ios-simulator",
    "x86_64-ios-simulator",
    "aarch64-tvos",
    "aarch64-tvos-simulator",
    "x86_64-tvos-simulator",
    "wasm32-emscripten",
    "aarch64-linux-android21",
    "x86_64-linux-android21",
  ],
  documentationPredefined,
  libraries: [
    {
      id: "SDL3",
      profile: {
        moduleName: "sdl",
        displayName: "SDL",
        abiImportName: "sdl3_c",
        symbolPrefixes: ["SDL_"],
        dependencies: [],
        error: { provider: "local" },
        allocator: {
          provider: "local",
          malloc: "SDL_malloc",
          realloc: "SDL_realloc",
          free: "SDL_free",
          alignedAlloc: "SDL_aligned_alloc",
          alignedFree: "SDL_aligned_free",
          setMemoryFunctions: "SDL_SetMemoryFunctions",
          getNumAllocations: "SDL_GetNumAllocations",
        },
        releaseFunctions: ["SDL_free"],
        headerPrefixes: ["SDL_"],
        rootHeaders: ["SDL_main.h"],
        namespaceStrategy: { kind: "documented_category" },
        constantFamilies: [{ prefix: "SDLK_", typedef: "SDL_Keycode" }],
      },
      headers: [
        "SDL3/SDL.h",
        "SDL3/SDL_main.h",
        "SDL3/SDL_vulkan.h",
        "SDL3/SDL_revision.h",
      ],
      includeDirectories: [coreIncludeDirectory],
      publicIncludeDirectories: [coreIncludeDirectory],
      documentation: `${coreIncludeDirectory}/SDL3`,
      sourceLabel: "SDL3 public headers",
      output: "sdl.zig",
    },
    {
      id: "SDL3_test",
      profile: {
        moduleName: "test",
        displayName: "SDL_test",
        abiImportName: "sdl3_test_c",
        symbolPrefixes: ["SDLTest_"],
        dependencies: ["sdl"],
        error: { provider: "dependency", importName: "sdl", publicPath: "Error" },
        allocator: {
          provider: "dependency",
          importName: "sdl",
          publicPath: "allocator",
          free: "SDL_free",
        },
        releaseFunctions: ["SDL_free"],
        constantFamilies: [{ prefix: "VERBOSE_", typedef: "SDLTest_VerboseFlags" }],
        headerPrefixes: ["SDL_"],
        rootHeaders: ["SDL_test.h"],
        namespaceStrategy: { kind: "header_stem" },
      },
      headers: ["SDL3/SDL_test.h"],
      includeDirectories: [coreIncludeDirectory],
      publicIncludeDirectories: coreTestHeaders,
      documentation: `${coreIncludeDirectory}/SDL3`,
      sourceLabel: "SDL3/SDL_test.h",
      output: "test.zig",
    },
    companionLibrary({
      id: "ControllerImage",
      moduleName: "controller_image",
      displayName: "ControllerImage",
      symbolPrefix: "ControllerImage_",
      headers: ["controllerimage.h"],
      rootHeaders: ["controllerimage.h"],
      headerPrefixes: ["controllerimage"],
      releaseFunctions: ["ControllerImage_DestroyDevice"],
      includeDirectory: "vendor/ControllerImage/src",
      documentation: "vendor/ControllerImage/src",
    }),
    companionLibrary({
      id: "SDL3_shadercross",
      moduleName: "shadercross",
      displayName: "SDL_shadercross",
      symbolPrefix: "SDL_ShaderCross_",
      headers: ["SDL3_shadercross/SDL_shadercross.h"],
      rootHeaders: ["SDL3_shadercross/SDL_shadercross.h"],
    }),
    companionLibrary({
      id: "SDL3_image",
      moduleName: "image",
      displayName: "SDL_image",
      symbolPrefix: "IMG_",
      headers: ["SDL3_image/SDL_image.h"],
      rootHeaders: ["SDL_image.h"],
    }),
    companionLibrary({
      id: "SDL3_ttf",
      moduleName: "ttf",
      displayName: "SDL_ttf",
      symbolPrefix: "TTF_",
      headers: [
        "SDL3_ttf/SDL_ttf.h",
        "SDL3_ttf/SDL_textengine.h",
      ],
      rootHeaders: ["SDL_ttf.h"],
      constantFamilies: [{ prefix: "TTF_SUBSTRING_", typedef: "TTF_SubStringFlags" }],
      sourceLabel: "SDL3_ttf public headers",
    }),
    companionLibrary({
      id: "SDL3_mixer",
      moduleName: "mixer",
      displayName: "SDL_mixer",
      symbolPrefix: "MIX_",
      headers: ["SDL3_mixer/SDL_mixer.h"],
      rootHeaders: ["SDL_mixer.h"],
    }),
    companionLibrary({
      id: "SDL3_net",
      moduleName: "net",
      displayName: "SDL_net",
      symbolPrefix: "NET_",
      headers: ["SDL3_net/SDL_net.h"],
      rootHeaders: ["SDL_net.h"],
      releaseFunctions: ["NET_FreeLocalAddresses"],
    }),
  ],
};

validateCodegenConfiguration(codegenConfiguration);

function validateCodegenConfiguration(
  configuration: CodegenConfiguration,
): void {
  if (
    configuration.targets.length === 0 ||
    configuration.libraries.length === 0 ||
    configuration.defines.some((define) => !/^[A-Za-z_][A-Za-z0-9_]*(?:=.*)?$/.test(define)) ||
    new Set(configuration.defines).size !== configuration.defines.length
  ) {
    throw new Error("Unsupported or invalid binding-generator configuration");
  }

  const ids = new Set<string>();
  const moduleNames = new Set<string>();
  for (const library of configuration.libraries) {
    const moduleName = library.profile.moduleName;
    if (
      !library.id || !library.output || !library.sourceLabel ||
      library.headers.length === 0 || library.includeDirectories.length === 0 ||
      library.publicIncludeDirectories.length === 0
    ) {
      throw new Error(`Binding configuration entry ${library.id || "<unnamed>"} is incomplete`);
    }
    if (
      ids.has(library.id) || moduleNames.has(moduleName) ||
      library.headers.some((header) => !header || /[<>\r\n]/.test(header)) ||
      new Set(library.headers).size !== library.headers.length
    ) {
      throw new Error(`Binding configuration ${library.id} is invalid or duplicated`);
    }
    for (const dependency of library.profile.dependencies) {
      if (!moduleNames.has(dependency)) {
        throw new Error(`Binding configuration ${library.id} must list ${dependency} first`);
      }
    }
    ids.add(library.id);
    moduleNames.add(moduleName);
  }
}

export function renderTranslationUnit(headers: string[]): string {
  return `${headers.map((header) => `#include <${header}>`).join("\n")}\n`;
}

interface CompanionLibraryOptions {
  id: string;
  moduleName: string;
  displayName: string;
  symbolPrefix: string;
  headers: string[];
  rootHeaders: string[];
  sourceLabel?: string;
  releaseFunctions?: string[];
  constantFamilies?: ConstantFamily[];
  headerPrefixes?: string[];
  documentation?: string;
  includeDirectory?: string;
}

function companionLibrary(
  options: CompanionLibraryOptions,
): LibraryConfiguration {
  const includeDirectory = options.includeDirectory ?? `vendor/${options.id}/include`;
  return {
    id: options.id,
    profile: {
      moduleName: options.moduleName,
      displayName: options.displayName,
      abiImportName: `sdl3_${options.moduleName}_c`,
      symbolPrefixes: [options.symbolPrefix],
      dependencies: ["sdl"],
      error: { provider: "dependency", importName: "sdl", publicPath: "Error" },
      allocator: {
        provider: "dependency",
        importName: "sdl",
        publicPath: "allocator",
        free: "SDL_free",
      },
      releaseFunctions: options.releaseFunctions ?? ["SDL_free"],
      constantFamilies: options.constantFamilies,
      headerPrefixes: options.headerPrefixes ?? ["SDL_"],
      rootHeaders: options.rootHeaders,
      namespaceStrategy: { kind: "header_stem" },
    },
    headers: options.headers,
    includeDirectories: [includeDirectory, coreIncludeDirectory],
    publicIncludeDirectories: [includeDirectory],
    documentation: options.documentation ?? `${includeDirectory}/${options.id}`,
    sourceLabel: options.sourceLabel ?? options.headers.join(", "),
    output: `${options.moduleName}.zig`,
  };
}
