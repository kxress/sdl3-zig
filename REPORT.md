# Intentional-exclusion porting report

This report audits every entry currently listed under **Intentional exclusions** in `COVERAGE.md`.
The audit asks whether the C macro has a stable consumer-facing Zig equivalent, not merely whether a
declaration can be made to compile. Entries marked **ported** are removed from the profile
exclusions and emitted by the generic renderer. Entries marked **retained** stay excluded because a
wrapper would lose C preprocessor context, target-specific behavior, caller source information, or
ABI/ownership semantics.

## Ported in this pass

| C API entry               | Zig surface         | Porting decision                                                                                          |
| ------------------------- | ------------------- | --------------------------------------------------------------------------------------------------------- |
| `SDL_COMPILE_TIME_ASSERT` | `compileTimeAssert` | Zig compile-time boolean check with a diagnostic label.                                                   |
| `SDL_CompilerBarrier`     | `compilerBarrier`   | SDL's portable memory-barrier function; stronger than the C compiler-only barrier but preserves ordering. |
| `SDL_const_cast`          | `constCast`         | Generic Zig const removal for pointer values.                                                             |
| `SDL_reinterpret_cast`    | `reinterpretCast`   | Generic Zig pointer reinterpretation.                                                                     |
| `SDL_SINT64_C`            | `sint64c`           | Compile-time signed 64-bit literal helper.                                                                |
| `SDL_static_cast`         | `staticCast`        | Generic Zig type-directed cast.                                                                           |
| `SDL_TriggerBreakpoint`   | `triggerBreakpoint` | Zig target-aware debugger breakpoint builtin.                                                             |
| `SDL_AssertBreakpoint`    | `assertBreakpoint`  | Same breakpoint behavior as `SDL_TriggerBreakpoint`.                                                      |
| `SDL_UINT64_C`            | `uint64c`           | Compile-time unsigned 64-bit literal helper.                                                              |
| `SDL_PRILLd`              | `prilLd`            | Target-selected C `printf` format string exposed through the C import.                                    |
| `SDL_PRILLu`              | `prilLu`            | Target-selected C `printf` format string exposed through the C import.                                    |
| `SDL_PRILLx`              | `prilLx`            | Target-selected C `printf` format string exposed through the C import.                                    |
| `SDL_PRILLX`              | `prillx`            | Target-selected C `printf` format string exposed through the C import.                                    |

## Retained exclusions

| C API entry                     | Kind           | Decision | Reason                                                                                                                            |
| ------------------------------- | -------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `SDL_BeginThreadFunction`       | object macro   | retained | Thread entry annotation or platform hook selected by the C headers; no portable Zig value.                                        |
| `SDL_EndThreadFunction`         | object macro   | retained | Thread exit annotation or platform hook selected by the C headers; no portable Zig value.                                         |
| `SDL_MALLOC`                    | object macro   | retained | Allocation attribute attached to declarations, not a callable allocator operation.                                                |
| `SDL_NO_THREAD_SAFETY_ANALYSIS` | object macro   | retained | Disables compiler thread-safety analysis and has no runtime meaning.                                                              |
| `SDL_ACQUIRE`                   | function macro | retained | Static-analysis lock annotation.                                                                                                  |
| `SDL_ACQUIRE_SHARED`            | function macro | retained | Static-analysis shared-lock annotation.                                                                                           |
| `SDL_ACQUIRED_AFTER`            | function macro | retained | Static-analysis lock-order annotation.                                                                                            |
| `SDL_ACQUIRED_BEFORE`           | function macro | retained | Static-analysis lock-order annotation.                                                                                            |
| `SDL_ALIGNED`                   | function macro | retained | Declaration/object alignment spelling varies by compiler and is not a runtime helper.                                             |
| `SDL_ALLOC_SIZE`                | function macro | retained | Allocation-result attribute consumed by the C compiler.                                                                           |
| `SDL_ALLOC_SIZE2`               | function macro | retained | Two-argument allocation-result attribute consumed by the C compiler.                                                              |
| `SDL_ASSERT_CAPABILITY`         | function macro | retained | Static-analysis capability assertion.                                                                                             |
| `SDL_ASSERT_SHARED_CAPABILITY`  | function macro | retained | Static-analysis shared-capability assertion.                                                                                      |
| `SDL_CAPABILITY`                | function macro | retained | Static-analysis capability declaration.                                                                                           |
| `SDL_EXCLUDES`                  | function macro | retained | Static-analysis exclusion annotation.                                                                                             |
| `SDL_GUARDED_BY`                | function macro | retained | Static-analysis guarded-data annotation.                                                                                          |
| `SDL_HAS_BUILTIN`               | function macro | retained | Compiler feature query whose result depends on the C preprocessor/compiler.                                                       |
| `SDL_PRINTF_VARARG_FUNC`        | function macro | retained | Compiler format-checking attribute for C varargs.                                                                                 |
| `SDL_PRINTF_VARARG_FUNCV`       | function macro | retained | Compiler format-checking attribute for C `va_list` functions.                                                                     |
| `SDL_PT_GUARDED_BY`             | function macro | retained | Static-analysis guarded-pointer annotation.                                                                                       |
| `SDL_RELEASE`                   | function macro | retained | Static-analysis lock-release annotation.                                                                                          |
| `SDL_RELEASE_GENERIC`           | function macro | retained | Static-analysis generic lock-release annotation.                                                                                  |
| `SDL_RELEASE_SHARED`            | function macro | retained | Static-analysis shared-lock release annotation.                                                                                   |
| `SDL_REQUIRES`                  | function macro | retained | Static-analysis lock precondition.                                                                                                |
| `SDL_REQUIRES_SHARED`           | function macro | retained | Static-analysis shared-lock precondition.                                                                                         |
| `SDL_RETURN_CAPABILITY`         | function macro | retained | Static-analysis capability-return annotation.                                                                                     |
| `SDL_SCANF_VARARG_FUNC`         | function macro | retained | Compiler format-checking attribute for C scanf-style varargs.                                                                     |
| `SDL_SCANF_VARARG_FUNCV`        | function macro | retained | Compiler format-checking attribute for C scanf-style `va_list` functions.                                                         |
| `SDL_TRY_ACQUIRE`               | function macro | retained | Static-analysis conditional lock-acquisition annotation.                                                                          |
| `SDL_TRY_ACQUIRE_SHARED`        | function macro | retained | Static-analysis conditional shared-lock acquisition annotation.                                                                   |
| `SDL_assert`                    | function macro | retained | Depends on build-time assertion level, caller source location, condition stringification, and SDL's assertion handler loop.       |
| `SDL_assert_always`             | function macro | retained | Same caller-location and assertion-handler requirements as `SDL_assert`, but always enabled.                                      |
| `SDL_assert_paranoid`           | function macro | retained | Depends on build-time paranoid assertion level and caller source information.                                                     |
| `SDL_assert_release`            | function macro | retained | Depends on build-time release assertion level and caller source information.                                                      |
| `SDL_disabled_assert`           | function macro | retained | Its key contract is compile-time elimination without evaluating side effects; a Zig function argument would already be evaluated. |
| `SDL_enabled_assert`            | function macro | retained | Requires C expression stringification, static assertion data, caller location, retry behavior, and target breakpoint behavior.    |
| `SDL_stack_alloc`               | function macro | retained | Chooses stack or SDL heap allocation by target/compiler; a Zig allocator wrapper would change lifetime and failure semantics.     |
| `SDL_stack_free`                | function macro | retained | Must pair with the target-selected implementation of `SDL_stack_alloc`; no portable Zig pairing can preserve both modes.          |
| `SDL_STRINGIFY_ARG`             | function macro | retained | C token stringification cannot be reproduced from an already-evaluated Zig value.                                                 |
| `SDL_DLNOTE_JOIN`               | function macro | retained | Token-pasting helper used only to construct ELF note symbol names.                                                                |
| `SDL_DLNOTE_JOIN2`              | function macro | retained | Second-stage token-pasting helper used only to construct ELF note symbol names.                                                   |
| `SDL_DLNOTE_JSON_ARRAY`         | function macro | retained | Variadic preprocessor dispatch used to build linker metadata.                                                                     |
| `SDL_DLNOTE_JSON_ARRAY_GET`     | function macro | retained | Preprocessor argument-count dispatch for linker metadata.                                                                         |
| `SDL_DLNOTE_JSON_ARRAY1`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY2`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY3`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY4`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY5`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY6`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY7`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_DLNOTE_JSON_ARRAY8`        | function macro | retained | ELF note JSON construction helper, not runtime API.                                                                               |
| `SDL_ELF_NOTE_DLOPEN`           | function macro | retained | Emits ELF/linker note data rather than a callable operation.                                                                      |
| `SDL_ELF_NOTE_INTERNAL`         | function macro | retained | Emits ELF/linker note data rather than a callable operation.                                                                      |
| `SDL_ELF_NOTE_INTERNAL2`        | function macro | retained | Emits ELF/linker note data rather than a callable operation.                                                                      |
| `SDL_ANALYZER_NORETURN`         | object macro   | retained | Compiler/static-analysis declaration annotation.                                                                                  |
| `SDL_DECLSPEC`                  | object macro   | retained | Export/visibility declaration annotation.                                                                                         |
| `SDL_DEPRECATED`                | object macro   | retained | Compiler deprecation declaration annotation.                                                                                      |
| `SDL_FALLTHROUGH`               | object macro   | retained | Compiler switch-fallthrough annotation.                                                                                           |
| `SDL_FORCE_INLINE`              | object macro   | retained | Compiler inlining declaration annotation.                                                                                         |
| `SDL_INLINE`                    | object macro   | retained | Compiler inline declaration spelling.                                                                                             |
| `SDL_NODISCARD`                 | object macro   | retained | Compiler unused-result declaration annotation.                                                                                    |
| `SDL_NORETURN`                  | object macro   | retained | Compiler non-returning declaration annotation.                                                                                    |
| `SDL_RESTRICT`                  | object macro   | retained | C pointer aliasing declaration qualifier.                                                                                         |
| `SDL_SCOPED_CAPABILITY`         | object macro   | retained | Static-analysis capability declaration annotation.                                                                                |
| `SDL_UNUSED`                    | object macro   | retained | Compiler unused-variable declaration annotation.                                                                                  |

The regenerated coverage report contains no generator limitations. The remaining 65 intentional
entries are all accounted for above; the 13 ported entries are no longer exclusions.
