# Intentional-exclusion porting plan

This is an audit of every entry under **Intentional exclusions** in `COVERAGE.md`. The goal is a
useful Zig API, not a cosmetic one-to-one list of names. A no-op function in place of a C attribute,
preprocessor operator, or linker directive is not a port: it makes the name available while silently
discarding the only contract the C entry had.

`COVERAGE.md` currently has 65 exclusions; its baseline also records thirteen already-completed
direct ports outside that exclusion set. Two of the 65 are already preserved as implementation
details of the generated thread-creation API. The remaining 63 should stay out of direct macro
coverage; six of those warrant a separate, explicitly Zig-native convenience API, while the other 57
have no consumer-facing operation to expose.

## Existing direct ports

| C API entry               | Zig surface                | Why this is a real port                                             |
| ------------------------- | -------------------------- | ------------------------------------------------------------------- |
| `SDL_COMPILE_TIME_ASSERT` | `stdinc.compileTimeAssert` | Checks a comptime boolean and reports a useful diagnostic.          |
| `SDL_CompilerBarrier`     | `atomic.compilerBarrier`   | Preserves the ordering guarantee with Zig's target-aware primitive. |
| `SDL_const_cast`          | `stdinc.constCast`         | Performs the corresponding pointer const-removal operation.         |
| `SDL_reinterpret_cast`    | `stdinc.reinterpretCast`   | Performs the corresponding typed pointer reinterpretation.          |
| `SDL_SINT64_C`            | `stdinc.sint64c`           | Produces a compile-time `i64` literal without C suffix spelling.    |
| `SDL_static_cast`         | `stdinc.staticCast`        | Performs a type-directed Zig cast.                                  |
| `SDL_TriggerBreakpoint`   | `assert.triggerBreakpoint` | Uses Zig's target-aware debugger breakpoint support.                |
| `SDL_AssertBreakpoint`    | `assert.breakpoint`        | Exposes the same breakpoint operation used by SDL assertions.       |
| `SDL_UINT64_C`            | `stdinc.uint64c`           | Produces a compile-time `u64` literal without C suffix spelling.    |
| `SDL_PRILLd`              | `stdinc.prilLd`            | Exposes the target-selected C format string.                        |
| `SDL_PRILLu`              | `stdinc.prilLu`            | Exposes the target-selected C format string.                        |
| `SDL_PRILLx`              | `stdinc.prilLx`            | Exposes the target-selected C format string.                        |
| `SDL_PRILLX`              | `stdinc.prillx`            | Exposes the target-selected C format string.                        |

## Functionality already preserved indirectly

`SDL_BeginThreadFunction` and `SDL_EndThreadFunction` are not useful Zig values. They are C runtime
hooks: on Windows they normally select `_beginthreadex` and `_endthreadex`; elsewhere they are
`NULL`; C callers may override them before including the header. Exposing either as a Zig constant
would freeze a C compiler/runtime decision and encourage callers to pass it to the wrong ABI.

The consumer-facing effect is already preserved. Generated `thread.create` and
`thread.createWithProperties` call the runtime entry points through the header-expanded
`c.SDL_BeginThreadFunction` and `c.SDL_EndThreadFunction`. This is the right boundary: Zig users
receive the normal two- and one-argument thread APIs, while the C import supplies any
platform-specific hooks.

What should change is coverage accounting, not the Zig API:

1. Add an explicit "satisfied by generated wrapper" relation to the coverage model, linking both
   hook macros to `SDL_CreateThread` and `SDL_CreateThreadWithProperties`.
2. Report them as **indirectly preserved**, rather than as intentional exclusions or as fictitious
   standalone Zig symbols.
3. Add a release-result check that the generated wrappers continue to use the two imported hooks,
   and compile that fixture for Windows as well as Linux.

After that change, the report should show 13 direct ports and 2 indirectly preserved entries. It
must not add `beginThreadFunction` or `endThreadFunction` to the public Zig namespace.

## Worth adding, but not claiming as macro ports

The six assertion macros have real user value, unlike the annotation-only entries below. A normal
Zig function that accepts `condition: bool`, however, cannot implement the C macros: its argument is
evaluated before the function runs, even when an assertion level is disabled. It also cannot
stringify the caller's expression automatically.

Add a Zig-native assertion facility only if it is documented as an additive API and tested for the
contracts it can actually provide:

```zig
if (comptime sdl.assert.isEnabled(.debug)) {
    sdl.assert.check(@src(), "connection != null", connection != null);
}
sdl.assert.checkAlways(@src(), "connection != null", connection != null);
```

The proposed generator-owned helpers should:

- expose `isEnabled(.debug | .release | .paranoid)` from the imported `SDL_ASSERT_LEVEL`, so a
  caller-side `if (comptime ...)` removes the condition and its side effects when disabled;
- accept an explicit condition description and `@src()` because Zig does not offer C-style
  expression stringification or an implicit caller location;
- create stable, per-call-site `SDL_AssertData` storage before calling `SDL_ReportAssertion`,
  retaining SDL's handler, retry, ignore, report, and breakpoint behavior; and
- offer `checkAlways` for the always-enabled case.

This is genuinely useful for applications that use SDL's assertion handler, but it is not a literal
binding of `SDL_assert`, `SDL_assert_always`, `SDL_assert_paranoid`, `SDL_assert_release`,
`SDL_disabled_assert`, or `SDL_enabled_assert`. Keep all six excluded from direct macro coverage. In
particular, do not implement a `disabledAssert(condition: bool)` helper: it would evaluate side
effects that the C macro deliberately discards.

Validate the facility with enabled, disabled, retry, break, and `always_ignore` handler cases, plus
a compile-time-elision fixture whose condition has an observable side effect. If stable
per-call-site storage is not possible with the supported Zig version, leave the facility out rather
than passing temporary `SDL_AssertData` to SDL.

## Retained direct exclusions

The following entries should remain exclusions. The groups name every current entry and explain the
missing contract and the useful Zig-level alternative, where one exists.

| Entries                                                                                                                                                                                                                                                                                                                                                                                                                                               | Why no standalone Zig port is honest                                                                                                                                                                                                                                                            | Useful handling instead                                                                                                                                                                                                                    |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `SDL_NO_THREAD_SAFETY_ANALYSIS`, `SDL_ACQUIRE`, `SDL_ACQUIRE_SHARED`, `SDL_ACQUIRED_AFTER`, `SDL_ACQUIRED_BEFORE`, `SDL_ASSERT_CAPABILITY`, `SDL_ASSERT_SHARED_CAPABILITY`, `SDL_CAPABILITY`, `SDL_EXCLUDES`, `SDL_GUARDED_BY`, `SDL_PT_GUARDED_BY`, `SDL_RELEASE`, `SDL_RELEASE_GENERIC`, `SDL_RELEASE_SHARED`, `SDL_REQUIRES`, `SDL_REQUIRES_SHARED`, `SDL_RETURN_CAPABILITY`, `SDL_SCOPED_CAPABILITY`, `SDL_TRY_ACQUIRE`, `SDL_TRY_ACQUIRE_SHARED` | These are Clang/MSVC static-analysis annotations. They describe lock ownership and ordering to a C analyzer; their expansion is usually empty on other compilers. A no-op Zig helper supplies neither lock checking nor a declaration annotation position.                                      | Preserve the documented thread-safety text on the affected Zig APIs. A future Zig-specific lock-analysis system would be a separate feature, not a binding of these macros.                                                                |
| `SDL_MALLOC`, `SDL_ALIGNED`, `SDL_ALLOC_SIZE`, `SDL_ALLOC_SIZE2`, `SDL_RESTRICT`                                                                                                                                                                                                                                                                                                                                                                      | These constrain a C declaration, object placement, aliasing, or optimizer assumptions. They have no call-time behavior. In particular, `SDL_ALIGNED` applies where a C object is declared, and `SDL_MALLOC`/`SDL_ALLOC_SIZE*` do not establish ownership by themselves.                         | Keep ABI alignment from the parsed declarations. Continue using documented ownership plus `SDL_free`/the allocator bridge for returned allocations; add an ownership rule only when documentation and the release function prove it.       |
| `SDL_HAS_BUILTIN`, `SDL_PRINTF_VARARG_FUNC`, `SDL_PRINTF_VARARG_FUNCV`, `SDL_SCANF_VARARG_FUNC`, `SDL_SCANF_VARARG_FUNCV`                                                                                                                                                                                                                                                                                                                             | `SDL_HAS_BUILTIN` is a C-preprocessor query about the compiler compiling the header. The other four attach C format checking to C varargs or `va_list` declarations. Zig has different compile-time reflection and formatting, and a wrapper cannot transfer the C compiler's diagnostics.      | Use Zig's native comptime formatting for new Zig APIs. Do not expose a string-keyed builtin probe or fake printf/scanf annotations.                                                                                                        |
| `SDL_ANALYZER_NORETURN`, `SDL_DECLSPEC`, `SDL_DEPRECATED`, `SDL_FALLTHROUGH`, `SDL_FORCE_INLINE`, `SDL_INLINE`, `SDL_NODISCARD`, `SDL_NORETURN`, `SDL_UNUSED`                                                                                                                                                                                                                                                                                         | These control C linkage, diagnostics, control-flow analysis, or code generation at a declaration or statement position. Several expand to nothing on some targets. None denotes a runtime service.                                                                                              | Preserve actual ABI/calling-convention facts in the generated declarations. When an annotation affects a function's observable contract, derive that contract from documentation and the declaration, not from a public annotation helper. |
| `SDL_stack_alloc`, `SDL_stack_free`                                                                                                                                                                                                                                                                                                                                                                                                                   | The pair selects `alloca` or `SDL_malloc` according to compiler configuration and must be freed only in the matching mode. A Zig allocator wrapper would have heap lifetime/error semantics; a stack array requires a compile-time size. Either changes the API's safety and lifetime contract. | Use a normal Zig allocator, a fixed-size stack buffer, or `std.heap.stackFallback` at the application call site. Do not offer an allocator that pretends to be this C pair.                                                                |
| `SDL_STRINGIFY_ARG`                                                                                                                                                                                                                                                                                                                                                                                                                                   | C stringification receives preprocessing tokens before evaluation. A Zig function receives a value or an already-written string and cannot recover token spelling.                                                                                                                              | Use an explicit comptime string; use `@tagName`, `@typeName`, or formatting for their separate Zig purposes.                                                                                                                               |
| `SDL_DLNOTE_JOIN`, `SDL_DLNOTE_JOIN2`, `SDL_DLNOTE_JSON_ARRAY`, `SDL_DLNOTE_JSON_ARRAY_GET`, `SDL_DLNOTE_JSON_ARRAY1`, `SDL_DLNOTE_JSON_ARRAY2`, `SDL_DLNOTE_JSON_ARRAY3`, `SDL_DLNOTE_JSON_ARRAY4`, `SDL_DLNOTE_JSON_ARRAY5`, `SDL_DLNOTE_JSON_ARRAY6`, `SDL_DLNOTE_JSON_ARRAY7`, `SDL_DLNOTE_JSON_ARRAY8`, `SDL_ELF_NOTE_DLOPEN`, `SDL_ELF_NOTE_INTERNAL`, `SDL_ELF_NOTE_INTERNAL2`                                                                 | These tokenize and count macro arguments, then emit named ELF-note data into the C object file. Building a Zig string would not produce the note section, symbol names, relocation behavior, or linker-visible metadata. They are only analyzed for the Linux target.                           | If a Zig-built SDL component ever needs these notes, design a Linux-only build/link integration that emits and inspects the exact ELF section. Keep it outside the runtime bindings and do not count its private helpers as SDL API ports. |

## Implementation order and acceptance criteria

1. Implement the thread-hook coverage relation first. It has no new public API, reflects code that
   already exists, and prevents the report from treating a preserved platform contract as an
   omission.
2. Prototype the additive assertion facility in the earliest semantic/planning stage that can own a
   generated helper. Do not add a release-specific symbol list; model assertion level, source data,
   and failure reporting as a reusable generator pattern.
3. Keep the 57 categorically non-consumer-facing entries excluded with the family reasons above. Do
   not reduce the exclusion count by emitting no-op functions, empty structs, or target guesses.
4. Regenerate every configured library, then run:

   - `deno task fmt`
   - `deno task typecheck`
   - `deno task generate:bindings`
   - `deno task test:bindings`
   - `deno task check`

The desired end state is therefore 13 direct macro ports, 2 indirectly preserved thread-hook
entries, an optional documented Zig assertion convenience that is not misrepresented as C-macro
compatibility, and 63 explicit direct exclusions with reasons tied to the contract that cannot be
carried across.
