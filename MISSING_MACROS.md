# Missing C macros

This inventory compares the public C headers in the pinned SDL-family inputs with the generated Zig
modules. The pinned inputs are SDL 3.4.12, SDL_image 3.4.4, SDL_ttf 3.2.2, SDL_mixer 3.2.4, SDL_net
3.2.0, SDL_shadercross 3.0.0, ControllerImage 1.0.2, and the SDL3 test headers. The configured
target matrix is the one in `scripts/codegen/config.ts`.

## Findings

- The SDL3 target matrix contains 1,050 numeric/string macro constants after target merging. All of
  those recognized by the generator are emitted through the generated C import and Zig aliases; none
  is missing from the generated result.
- SDL3 has 150 public function-like macros in the analyzed matrix. Forty are rendered as inline Zig
  helpers; 110 are not rendered.
- The companion generators do not recognize several version/property prefixes. This leaves 49
  object-like/type-style macros absent, plus four companion `VERSION_ATLEAST` function-like macros.
- The list below intentionally excludes include guards, private build configuration macros,
  compiler-provided macros, and SDL 2 compatibility names disabled by the repository's
  `SDL_DISABLE_OLD_NAMES=1` definition. Those are not consumer API symbols.

The comparison was made against the analyzer's `clang -E -dD` macro model and an external
regeneration into a temporary output directory. The relevant implementation is
[`analysis.ts`](scripts/codegen/analysis.ts), which parses object-like and function-like macros, and
[`render.ts`](scripts/codegen/render.ts), which renders constants and supported function-like
macros.

## Object-like and type-style macros missing from the public Zig surface

These are generally straightforward to expose as `pub const` values, except for the two CRC type
macros, which should become Zig type aliases. Version and property strings should retain the C value
and be placed in the corresponding companion module namespace.

### SDL_image — `vendor/SDL3_image/include/SDL3_image/SDL_image.h`

| C macro                   | Port recommendation                                     |
| ------------------------- | ------------------------------------------------------- |
| `SDL_IMAGE_MAJOR_VERSION` | `image.major_version` constant                          |
| `SDL_IMAGE_MINOR_VERSION` | `image.minor_version` constant                          |
| `SDL_IMAGE_MICRO_VERSION` | `image.micro_version` constant                          |
| `SDL_IMAGE_VERSION`       | `image.version` constant, using the pinned header value |

### SDL_ttf — `vendor/SDL3_ttf/include/SDL3_ttf/SDL_ttf.h`

| C macro                 | Port recommendation                                   |
| ----------------------- | ----------------------------------------------------- |
| `SDL_TTF_MAJOR_VERSION` | `ttf.major_version` constant                          |
| `SDL_TTF_MINOR_VERSION` | `ttf.minor_version` constant                          |
| `SDL_TTF_MICRO_VERSION` | `ttf.micro_version` constant                          |
| `SDL_TTF_VERSION`       | `ttf.version` constant, using the pinned header value |

### SDL_mixer — `vendor/SDL3_mixer/include/SDL3_mixer/SDL_mixer.h`

| C macro                   | Port recommendation                                     |
| ------------------------- | ------------------------------------------------------- |
| `SDL_MIXER_MAJOR_VERSION` | `mixer.major_version` constant                          |
| `SDL_MIXER_MINOR_VERSION` | `mixer.minor_version` constant                          |
| `SDL_MIXER_MICRO_VERSION` | `mixer.micro_version` constant                          |
| `SDL_MIXER_VERSION`       | `mixer.version` constant, using the pinned header value |

### SDL_net — `vendor/SDL3_net/include/SDL3_net/SDL_net.h`

| C macro                 | Port recommendation                                   |
| ----------------------- | ----------------------------------------------------- |
| `SDL_NET_MAJOR_VERSION` | `net.major_version` constant                          |
| `SDL_NET_MINOR_VERSION` | `net.minor_version` constant                          |
| `SDL_NET_MICRO_VERSION` | `net.micro_version` constant                          |
| `SDL_NET_VERSION`       | `net.version` constant, using the pinned header value |

### SDL_shadercross — `vendor/SDL3_shadercross/include/SDL3_shadercross/SDL_shadercross.h`

The configured function prefix is `SDL_ShaderCross_`, while these macros use the all-uppercase
`SDL_SHADERCROSS_` prefix. Add a separate macro prefix or an equivalent profile rule; do not copy
these values by hand into generated output.

| C macro                                                    | Port recommendation                                    |
| ---------------------------------------------------------- | ------------------------------------------------------ |
| `SDL_SHADERCROSS_MAJOR_VERSION`                            | `shadercross.major_version` constant                   |
| `SDL_SHADERCROSS_MINOR_VERSION`                            | `shadercross.minor_version` constant                   |
| `SDL_SHADERCROSS_MICRO_VERSION`                            | `shadercross.micro_version` constant                   |
| `SDL_SHADERCROSS_PROP_SHADER_DEBUG_ENABLE_BOOLEAN`         | `shadercross.prop_shader_debug_enable_boolean`         |
| `SDL_SHADERCROSS_PROP_SHADER_DEBUG_NAME_STRING`            | `shadercross.prop_shader_debug_name_string`            |
| `SDL_SHADERCROSS_PROP_SHADER_CULL_UNUSED_BINDINGS_BOOLEAN` | `shadercross.prop_shader_cull_unused_bindings_boolean` |
| `SDL_SHADERCROSS_PROP_SPIRV_PSSL_COMPATIBILITY_BOOLEAN`    | `shadercross.prop_spirv_pssl_compatibility_boolean`    |
| `SDL_SHADERCROSS_PROP_SPIRV_MSL_VERSION_STRING`            | `shadercross.prop_spirv_msl_version_string`            |
| `SDL_SHADERCROSS_PROP_HLSL_SKIP_SPIRV_ROUNDTRIP_BOOLEAN`   | `shadercross.prop_hlsl_skip_spirv_roundtrip_boolean`   |

### ControllerImage — `vendor/ControllerImage/src/controllerimage.h`

The header uses `CONTROLLERIMAGE_`, while the configured API prefix is `ControllerImage_`.

| C macro                         | Port recommendation                       |
| ------------------------------- | ----------------------------------------- |
| `CONTROLLERIMAGE_MAJOR_VERSION` | `controller_image.major_version` constant |
| `CONTROLLERIMAGE_MINOR_VERSION` | `controller_image.minor_version` constant |
| `CONTROLLERIMAGE_MICRO_VERSION` | `controller_image.micro_version` constant |
| `CONTROLLERIMAGE_VERSION`       | `controller_image.version` constant       |

### SDL_test — `vendor/SDL3/include/SDL3/SDL_test_*.h`

The test profile currently recognizes only the `VERBOSE_` flag family. The following public test
macros are consequently absent. `DEFAULT_WINDOW_*` are target-dependent, and `CRC32_POLY` is
selected by `ORIGINAL_METHOD`; those conditions must remain explicit in the generator.

| C macro                         | Port recommendation                                           |
| ------------------------------- | ------------------------------------------------------------- |
| `SDLTEST_MAX_LOGMESSAGE_LENGTH` | typed integer constant                                        |
| `ASSERT_FAIL`                   | typed integer constant                                        |
| `ASSERT_PASS`                   | typed integer constant                                        |
| `CrcUint32`                     | Zig type alias, normally `u32`                                |
| `CrcUint8`                      | Zig type alias, normally `u8`                                 |
| `CRC32_POLY`                    | typed integer constant with its build-time variant documented |
| `DEFAULT_WINDOW_WIDTH`          | target-aware test constant                                    |
| `DEFAULT_WINDOW_HEIGHT`         | target-aware test constant                                    |
| `FONT_LINE_HEIGHT`              | inline value/helper based on `FONT_CHARACTER_SIZE`            |
| `TEST_ENABLED`                  | typed integer constant                                        |
| `TEST_DISABLED`                 | typed integer constant                                        |
| `TEST_ABORTED`                  | typed integer constant                                        |
| `TEST_STARTED`                  | typed integer constant                                        |
| `TEST_COMPLETED`                | typed integer constant                                        |
| `TEST_SKIPPED`                  | typed integer constant                                        |
| `TEST_RESULT_PASSED`            | typed integer constant                                        |
| `TEST_RESULT_FAILED`            | typed integer constant                                        |
| `TEST_RESULT_NO_ASSERT`         | typed integer constant                                        |
| `TEST_RESULT_SKIPPED`           | typed integer constant                                        |
| `TEST_RESULT_SETUP_FAILURE`     | typed integer constant                                        |

## Companion function-like version macros

These are simple integer expressions and should be handled by the same generic function-macro
renderer used for SDL3's `SDL_VERSIONNUM*` family.

| C macro                              | Header        | Port recommendation              |
| ------------------------------------ | ------------- | -------------------------------- |
| `SDL_IMAGE_VERSION_ATLEAST(X, Y, Z)` | `SDL_image.h` | `image.version_atleast(x, y, z)` |
| `SDL_TTF_VERSION_ATLEAST(X, Y, Z)`   | `SDL_ttf.h`   | `ttf.version_atleast(x, y, z)`   |
| `SDL_MIXER_VERSION_ATLEAST(X, Y, Z)` | `SDL_mixer.h` | `mixer.version_atleast(x, y, z)` |
| `SDL_NET_VERSION_ATLEAST(X, Y, Z)`   | `SDL_net.h`   | `net.version_atleast(x, y, z)`   |

## SDL3 function-like macros absent from the generated surface

The names below are the complete 110-name omission set from the full configured target matrix. They
are grouped by the kind of Zig support that would be appropriate.

### Compiler annotations and declaration attributes — do not expose as runtime functions

`SDL_ACQUIRE`, `SDL_ACQUIRE_SHARED`, `SDL_ACQUIRED_AFTER`, `SDL_ACQUIRED_BEFORE`, `SDL_ALIGNED`,
`SDL_ALLOC_SIZE`, `SDL_ALLOC_SIZE2`, `SDL_ASSERT_CAPABILITY`, `SDL_ASSERT_SHARED_CAPABILITY`,
`SDL_CAPABILITY`, `SDL_EXCLUDES`, `SDL_GUARDED_BY`, `SDL_HAS_BUILTIN`, `SDL_PRINTF_VARARG_FUNC`,
`SDL_PRINTF_VARARG_FUNCV`, `SDL_PT_GUARDED_BY`, `SDL_RELEASE`, `SDL_RELEASE_GENERIC`,
`SDL_RELEASE_SHARED`, `SDL_REQUIRES`, `SDL_REQUIRES_SHARED`, `SDL_RETURN_CAPABILITY`,
`SDL_SCANF_VARARG_FUNC`, `SDL_SCANF_VARARG_FUNCV`, `SDL_TRY_ACQUIRE`, `SDL_TRY_ACQUIRE_SHARED`.

These expand to compiler attributes, feature tests, or static-analysis annotations. They have no
portable runtime value. If the Zig generator needs equivalent metadata, it belongs in function
analysis or Zig annotations, not in a callable macro-shaped API.

### Assertions and breakpoints — possible, but not a mechanical macro translation

`SDL_assert`, `SDL_assert_always`, `SDL_assert_paranoid`, `SDL_assert_release`,
`SDL_AssertBreakpoint`, `SDL_disabled_assert`, `SDL_enabled_assert`, `SDL_TriggerBreakpoint`.

The assertion macros create source-location state, select behavior from `SDL_ASSERT_LEVEL`, and may
retry, break, or continue through SDL's assertion callback. A faithful port needs a generic Zig
assertion adapter plus an explicit decision about file/line/caller information.
`SDL_TriggerBreakpoint` and `SDL_AssertBreakpoint` are target-specific compiler/debugger operations
and should remain C imports or use a dedicated target-aware implementation.

### Typed numeric/audio helpers — good candidates for generic inline Zig functions

`SDL_AUDIO_BITSIZE`, `SDL_AUDIO_FRAMESIZE`.

`SDL_BITSPERPIXEL`, `SDL_BYTESPERPIXEL`, `SDL_COLORSPACECHROMA`, `SDL_COLORSPACEMATRIX`,
`SDL_COLORSPACEPRIMARIES`, `SDL_COLORSPACERANGE`, `SDL_COLORSPACETRANSFER`, `SDL_COLORSPACETYPE`,
`SDL_ISCOLORSPACE_MATRIX_BT601`, `SDL_ISPIXELFORMAT_10BIT`, `SDL_ISPIXELFORMAT_ALPHA`,
`SDL_ISPIXELFORMAT_ARRAY`, `SDL_ISPIXELFORMAT_FLOAT`, `SDL_ISPIXELFORMAT_FOURCC`,
`SDL_ISPIXELFORMAT_INDEXED`, `SDL_ISPIXELFORMAT_PACKED`, `SDL_PIXELFLAG`, `SDL_PIXELLAYOUT`,
`SDL_PIXELORDER`.

These are pure bit extraction and classification expressions. They can be ported as `inline fn`
helpers with SDL's integer widths and enum conversions made explicit. The generated wrappers must
preserve the C return behavior where a predicate returns an integer mask rather than a Zig `bool`.

### Generic C utility macros — use Zig idioms, not textual emulation

`SDL_arraysize`, `SDL_clamp`, `SDL_COMPILE_TIME_ASSERT`, `SDL_CompilerBarrier`, `SDL_const_cast`,
`SDL_copyp`, `SDL_max`, `SDL_min`, `SDL_reinterpret_cast`, `SDL_SINT64_C`, `SDL_stack_alloc`,
`SDL_stack_free`, `SDL_static_cast`, `SDL_STRINGIFY_ARG`, `SDL_UINT64_C`, `SDL_zero`, `SDL_zeroa`,
`SDL_zerop`.

`SDL_min`, `SDL_max`, `SDL_clamp`, and `SDL_arraysize` are reasonable generic inline functions.
`SDL_zero*` and `SDL_copyp` can use compile-time-sized `@memset`/`@memcpy` helpers. Cast macros,
stringification, compile-time assertions, integer literal suffixes, and stack allocation are
language/preprocessor features with no one-to-one public Zig function. `SDL_CompilerBarrier`
requires target-specific atomics or assembly and remains omitted. `SDL_CPUPauseInstruction` is
represented by the inline `std.atomic.spinLoopHint()` adapter.

### SDL ELF note construction — not portable application API

`SDL_DLNOTE_JOIN`, `SDL_DLNOTE_JOIN2`, `SDL_DLNOTE_JSON_ARRAY`, `SDL_DLNOTE_JSON_ARRAY_GET`,
`SDL_DLNOTE_JSON_ARRAY1`, `SDL_DLNOTE_JSON_ARRAY2`, `SDL_DLNOTE_JSON_ARRAY3`,
`SDL_DLNOTE_JSON_ARRAY4`, `SDL_DLNOTE_JSON_ARRAY5`, `SDL_DLNOTE_JSON_ARRAY6`,
`SDL_DLNOTE_JSON_ARRAY7`, `SDL_DLNOTE_JSON_ARRAY8`, `SDL_ELF_NOTE_DLOPEN`, `SDL_ELF_NOTE_INTERNAL`,
`SDL_ELF_NOTE_INTERNAL2`.

These construct ELF sections, unique identifiers, token-pasted names, and JSON strings at C
preprocessing/compilation time. They should not be exposed as Zig runtime functions. If a future Zig
API needs SDL's dynamic-library note behavior, it should be a platform-specific build step.

### Iconv convenience macros — possible wrappers around existing C functions

`SDL_iconv_utf8_locale`, `SDL_iconv_utf8_ucs2`, `SDL_iconv_utf8_ucs4`, `SDL_iconv_wchar_utf8`.

These can be represented as sentinel-string Zig helpers that call `SDL_iconv_string`, with the same
ownership and null-result contract. They are lower priority because they are convenience macros
around an already imported function and include platform-specific `wchar_t` behavior.

### Interface initialization and error helpers — straightforward semantic wrappers

`SDL_INIT_INTERFACE`, `SDL_InvalidParamError`, `SDL_Unsupported`.

`SDL_INIT_INTERFACE` can become a typed generic initializer that zeroes an interface and writes its
size, but it must only accept the interface records for which SDL documents the macro. The two error
helpers can be small wrappers around `SDL_SetError`; their Zig result type should match the existing
error translation policy rather than expose a raw C `bool` unexpectedly.

### Memory barriers — call the existing function variants

`SDL_MemoryBarrierAcquire`, `SDL_MemoryBarrierRelease`.

The headers choose compiler intrinsics, assembly, or `SDL_MemoryBarrier*Function` by target. The
portable binding should expose the imported function variants (already present) or add a
target-aware inline adapter that calls them, instead of trying to reproduce every C preprocessor
branch in Zig.

### Endian helpers — good candidates for typed inline functions

`SDL_Swap16`, `SDL_Swap16BE`, `SDL_Swap32`, `SDL_Swap32BE`, `SDL_Swap64`, `SDL_Swap64BE`.

The corresponding little-endian and floating-point helpers are already rendered. The missing helpers
can use `@byteSwap` plus `builtin.cpu.arch.endian()` or delegate to the imported C function
variants, preserving the exact integer widths.

### Size-overflow and version arithmetic

`SDL_size_add_check_overflow` and `SDL_size_mul_check_overflow` write a caller-provided result and
select compiler builtins. They are represented by typed inline Zig helpers using
`@addWithOverflow`/`@mulWithOverflow`, preserving the result-pointer and boolean-success contract.

`SDL_VERSIONNUM`, `SDL_VERSIONNUM_MAJOR`, `SDL_VERSIONNUM_MICRO`, and `SDL_VERSIONNUM_MINOR` are
pure integer arithmetic and should be rendered as typed inline functions. The core SDL equivalents
are already rendered; the companion `VERSION_ATLEAST` gaps above should follow the same rule.

## Recommended implementation order

1. Add the missing companion macro prefixes (`SDL_IMAGE_`, `SDL_TTF_`, `SDL_MIXER_`, `SDL_NET_`,
   `SDL_SHADERCROSS_`, `CONTROLLERIMAGE_`) and the SDL_test macro families to the typed generator
   configuration. Regenerate and validate the public result.
2. Extend generic function-macro rendering for version arithmetic, numeric pixel/audio helpers,
   endian helpers, iconv convenience wrappers, and the two error helpers.
3. Add carefully designed generic Zig helpers for min/max/clamp, zero/copy, and interface
   initialization only where the C contract can be preserved.
4. Leave compiler annotations, ELF-note construction, textual casts/stringification, stack macros,
   and target-specific barriers/breakpoints out of the public runtime API unless a separate Zig
   contract and target matrix prove that the translation is sound.

## Implementation status

The inventory has now been addressed through the generic generator. The companion version/property
prefixes, ControllerImage prefixes, SDL_test families and CRC type aliases are emitted; the four
companion `VERSION_ATLEAST` macros, numeric/audio/pixel helpers, endian helpers, iconv convenience
wrappers, error helpers, memory barriers, overflow checks, interface initialization, and generic
utility helpers are emitted as inline Zig adapters. Generated output remains target-aware and is
regenerated from the configured profiles rather than hand-maintained.

The remaining deliberate omissions are compiler/static-analysis annotations, assertion and
debugger-breakpoint macros, ELF-note construction, compiler barriers, textual casts/stringification,
stack allocation, compile-time assertion syntax, and other preprocessor-only declarations. These
have no portable public Zig runtime contract in the configured target matrix; the rationale for each
group is documented above.
