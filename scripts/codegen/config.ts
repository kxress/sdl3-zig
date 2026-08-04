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
        macroPrefixes: ["SDLK_"],
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
        coverageExclusions: [
          {
            names: [
              "SDL_ACQUIRE",
              "SDL_ACQUIRE_SHARED",
              "SDL_ACQUIRED_AFTER",
              "SDL_ACQUIRED_BEFORE",
              "SDL_ALIGNED",
              "SDL_ALLOC_SIZE",
              "SDL_ALLOC_SIZE2",
              "SDL_ASSERT_CAPABILITY",
              "SDL_ASSERT_SHARED_CAPABILITY",
              "SDL_CAPABILITY",
              "SDL_EXCLUDES",
              "SDL_GUARDED_BY",
              "SDL_HAS_BUILTIN",
              "SDL_PRINTF_VARARG_FUNC",
              "SDL_PRINTF_VARARG_FUNCV",
              "SDL_PT_GUARDED_BY",
              "SDL_RELEASE",
              "SDL_RELEASE_GENERIC",
              "SDL_RELEASE_SHARED",
              "SDL_REQUIRES",
              "SDL_REQUIRES_SHARED",
              "SDL_RETURN_CAPABILITY",
              "SDL_SCANF_VARARG_FUNC",
              "SDL_SCANF_VARARG_FUNCV",
              "SDL_TRY_ACQUIRE",
              "SDL_TRY_ACQUIRE_SHARED",
            ],
            reason: "Compiler or static-analysis annotation with no portable runtime Zig binding.",
          },
          {
            names: [
              "SDL_assert",
              "SDL_assert_always",
              "SDL_assert_paranoid",
              "SDL_assert_release",
              "SDL_AssertBreakpoint",
              "SDL_disabled_assert",
              "SDL_enabled_assert",
              "SDL_TriggerBreakpoint",
            ],
            reason:
              "Assertion or debugger macro requiring caller-location and target-specific behavior.",
          },
          {
            names: [
              "SDL_COMPILE_TIME_ASSERT",
              "SDL_CompilerBarrier",
              "SDL_const_cast",
              "SDL_reinterpret_cast",
              "SDL_SINT64_C",
              "SDL_stack_alloc",
              "SDL_stack_free",
              "SDL_static_cast",
              "SDL_STRINGIFY_ARG",
              "SDL_UINT64_C",
            ],
            reason:
              "C preprocessor, language, or target-specific compiler feature rather than a portable binding.",
          },
          {
            names: [
              "SDL_DLNOTE_JOIN",
              "SDL_DLNOTE_JOIN2",
              "SDL_DLNOTE_JSON_ARRAY",
              "SDL_DLNOTE_JSON_ARRAY_GET",
              "SDL_DLNOTE_JSON_ARRAY1",
              "SDL_DLNOTE_JSON_ARRAY2",
              "SDL_DLNOTE_JSON_ARRAY3",
              "SDL_DLNOTE_JSON_ARRAY4",
              "SDL_DLNOTE_JSON_ARRAY5",
              "SDL_DLNOTE_JSON_ARRAY6",
              "SDL_DLNOTE_JSON_ARRAY7",
              "SDL_DLNOTE_JSON_ARRAY8",
              "SDL_ELF_NOTE_DLOPEN",
              "SDL_ELF_NOTE_INTERNAL",
              "SDL_ELF_NOTE_INTERNAL2",
            ],
            reason:
              "ELF note construction performed by the C preprocessor and linker, not a runtime API.",
          },
          {
            names: [
              "SDL_ANALYZER_NORETURN",
              "SDL_DECLSPEC",
              "SDL_DEPRECATED",
              "SDL_FALLTHROUGH",
              "SDL_FORCE_INLINE",
              "SDL_INLINE",
              "SDL_NODISCARD",
              "SDL_NORETURN",
              "SDL_RESTRICT",
              "SDL_SCOPED_CAPABILITY",
              "SDL_UNUSED",
            ],
            reason:
              "Declaration annotation or compiler spelling with no standalone runtime Zig binding.",
          },
          {
            names: ["SDL_PRILLd", "SDL_PRILLu", "SDL_PRILLx", "SDL_PRILLX"],
            reason: "C format-string portability macro with no standalone Zig binding.",
          },
        ],
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
        macroPrefixes: [
          "SDLTEST_",
          "ASSERT_",
          "Crc",
          "CRC32_",
          "DEFAULT_WINDOW_",
          "FONT_",
          "TEST_",
        ],
        macroNamePrefixes: ["SDLTEST_"],
        macroTypeAliases: [
          { name: "CrcUint32", type: "u32" },
          { name: "CrcUint8", type: "u8" },
        ],
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
      macroPrefixes: ["CONTROLLERIMAGE_"],
      macroNamePrefixes: ["CONTROLLERIMAGE_"],
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
      macroPrefixes: ["SDL_SHADERCROSS_"],
      macroNamePrefixes: ["SDL_SHADERCROSS_"],
      headers: ["SDL3_shadercross/SDL_shadercross.h"],
      rootHeaders: ["SDL3_shadercross/SDL_shadercross.h"],
    }),
    companionLibrary({
      id: "SDL3_image",
      moduleName: "image",
      displayName: "SDL_image",
      symbolPrefix: "IMG_",
      macroPrefixes: ["SDL_IMAGE_"],
      macroNamePrefixes: ["SDL_IMAGE_"],
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
      macroPrefixes: ["SDL_TTF_", "TTF_SUBSTRING_"],
      macroNamePrefixes: ["SDL_TTF_"],
      sourceLabel: "SDL3_ttf public headers",
    }),
    companionLibrary({
      id: "SDL3_mixer",
      moduleName: "mixer",
      displayName: "SDL_mixer",
      symbolPrefix: "MIX_",
      macroPrefixes: ["SDL_MIXER_"],
      macroNamePrefixes: ["SDL_MIXER_"],
      headers: ["SDL3_mixer/SDL_mixer.h"],
      rootHeaders: ["SDL_mixer.h"],
    }),
    companionLibrary({
      id: "SDL3_net",
      moduleName: "net",
      displayName: "SDL_net",
      symbolPrefix: "NET_",
      macroPrefixes: ["SDL_NET_"],
      macroNamePrefixes: ["SDL_NET_"],
      headers: ["SDL3_net/SDL_net.h"],
      rootHeaders: ["SDL_net.h"],
      releaseFunctions: ["NET_FreeLocalAddresses"],
    }),
  ],
};

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
  macroPrefixes?: string[];
  macroNamePrefixes?: string[];
  macroTypeAliases?: LibraryProfile["macroTypeAliases"];
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
      macroPrefixes: options.macroPrefixes,
      macroNamePrefixes: options.macroNamePrefixes,
      macroTypeAliases: options.macroTypeAliases,
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
