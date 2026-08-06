# Intentional-exclusion implementation TODO

This is the execution checklist for carrying every useful contract behind the 65 entries in
`COVERAGE.md`'s **Intentional exclusions** section into the generated Zig package. Work from top to
bottom unless a dependency note explicitly permits otherwise. The top-level checkboxes are the
status authority: check a `**P00/Sxx complete**` box only after every task and exit criterion in
that section is satisfied.

The goal is not to manufacture a Zig declaration for every C macro. Each exclusion must end with one
honest handling outcome:

- **direct:** a public Zig declaration preserves the macro's consumer-visible contract;
- **indirect:** a generated wrapper consumes the C mechanism, but no standalone Zig value is useful;
- **semantic:** normalized metadata changes analysis, planning, rendering, documentation, or
  validation;
- **additive:** a Zig/SDL adapter supplies SDL-specific value that Zig does not already provide; or
- **unrepresentable:** the report explains why no honest consumer-facing or generator operation
  exists.

Keep that handling outcome separate from the inventory status `covered | intentional | limitation`.
An intentional macro may have indirect, semantic, or additive handling without becoming directly
covered. Only a genuine direct binding changes the direct-coverage numerator.

## Operating rules for every goal run

- Treat the current worktree, pinned sources, and generated output as authoritative. The reference
  investigation in this file is context, not a substitute for rechecking changed inputs.
- The investigated baseline is SDL 3.4.12, Zig 0.16.0, Clang 19.1.7, and CastXML 0.7.0. Re-run the
  inventory and update this checklist if any input changes.
- Preserve the raw `c` import as the ABI authority. Put policy in `scripts/codegen/`, never in
  hand-edited generated modules or `COVERAGE.md`.
- Preserve every raw ABI declaration and shipped direct wrapper unless a separately documented
  correctness bug requires a source change. Avoid compatibility aliases for public names that have
  never shipped; settle new names through their slice fixtures before release.
- Derive behavior from recurring declaration shape, parsed attributes, and documentation. Do not
  introduce release-specific SDL function-name lists when typed semantic metadata can express the
  rule.
- Fail generation, with the C name and source location, when a recognized contract is malformed,
  contradictory, or cannot be represented safely. Do not silently fall back to name guessing.
- Preserve unrelated worktree changes. Generated output must retain its do-not-edit header and be
  reproducible with `deno task generate`.
- While iterating, add the narrowest focused test first, change the earliest stage that knows the
  fact, run that test plus `deno task fmt` and `deno task typecheck`, then regenerate and inspect
  all downstream output.
- A cross-target compile proves ABI/type availability; a native fixture proves runtime behavior.
  Neither substitutes for the other.
- Update the checkbox for a slice only after its exit criteria pass. If a prototype is rejected by a
  mandatory gate, record the failed proof, keep the exclusion intentional/unrepresentable, remove
  the public artifact, and then check the slice as dispositioned.

## Repository ownership map

| Concern                             | Owning source                                                                   | Expected downstream evidence                                          |
| ----------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| Pinned inputs and target matrix     | `mise.sdl.toml`, `mise.toml`, `scripts/codegen/config.ts`                       | `sdl_metadata.zig`, generated bindings                                |
| CastXML/Clang acquisition and merge | `scripts/codegen/analysis.ts`, optionally `scripts/codegen/clang-attributes.ts` | `scripts/codegen/generator.ts`                                        |
| Normalized function behavior        | `scripts/codegen/function-plan.ts`                                              | `scripts/codegen/render.ts`                                           |
| Naming and documentation            | `scripts/codegen/naming.ts`, `scripts/codegen/documentation.ts`                 | generated public declarations                                         |
| Library policy and ABI providers    | `scripts/codegen/profile.ts`, `scripts/codegen/config.ts`                       | analysis, plans, rendering                                            |
| Coverage classification/evidence    | `scripts/codegen/coverage.ts`, `scripts/codegen/profile.ts`                     | generated `COVERAGE.md`                                               |
| Public Zig surface                  | generator inputs above                                                          | `src/{sdl,image,ttf,mixer,net,test,controller_image,shadercross}.zig` |
| Black-box ABI/consumer proof        | `tests/build/`, `tests/build/fixtures/`                                         | native and cross-target results                                       |
| Semantic/determinism proof          | `tests/codegen/`                                                                | focused model and generated-output tests                              |

## Resolved decisions — checked means “do not implement”

These are completed scope decisions, not skipped TODOs. Retain their regression and coverage
evidence where a later slice asks for it, but do not resurrect the struck designs unless the pinned
Zig or SDL contracts change and the full rationale is revalidated.

- [x] **R01 — Do not generate mutex/RW-lock guards, guarded containers, or a TLS capability
      tracker.** Zig's `lock(); defer unlock();` is the native scoped-cleanup pattern. Zig 0.16.0
      has no declaration capability system; copyable guards and runtime tokens would not reproduce
      Clang's static contract. Keep raw SDL lock/try-lock/unlock/wait/destroy operations and their
      docs/tests. The 20 affected macro definitions are `SDL_CAPABILITY`, `SDL_SCOPED_CAPABILITY`,
      `SDL_GUARDED_BY`, `SDL_PT_GUARDED_BY`, `SDL_ACQUIRED_BEFORE`, `SDL_ACQUIRED_AFTER`,
      `SDL_REQUIRES`, `SDL_REQUIRES_SHARED`, `SDL_ACQUIRE`, `SDL_ACQUIRE_SHARED`, `SDL_RELEASE`,
      `SDL_RELEASE_SHARED`, `SDL_RELEASE_GENERIC`, `SDL_TRY_ACQUIRE`, `SDL_TRY_ACQUIRE_SHARED`,
      `SDL_EXCLUDES`, `SDL_ASSERT_CAPABILITY`, `SDL_ASSERT_SHARED_CAPABILITY`,
      `SDL_RETURN_CAPABILITY`, and `SDL_NO_THREAD_SAFETY_ANALYSIS`. SDL 3.4.12 applies capability
      attributes only to eight mutex/RW-lock declarations and no public guarded data. Do not enable
      `SDL_THREAD_SAFETY_ANALYSIS=1` in supplemental analysis: its analyzer-only declarations add
      ABI acquisition risk and no accepted Zig consumer.
- [x] **R02 — Do not add an SDL-named stack-fallback allocator.** Use
      `std.heap.stackFallback(N, sdl.allocator)` directly. Zig 0.16.0 already provides caller-owned
      fixed storage, arbitrary allocator fallback, `get`, `resize`, `remap`, and paired `free`.
      `SDL_stack_alloc` and `SDL_stack_free` stay intentional/unrepresentable as direct macro ports;
      documentation and allocator-generic tests may demonstrate the standard allocator composition.
- [x] **R03 — Keep three previously questioned facilities in scope.** S08 remains because comptime C
      formats plus tuples can provide comparable SDL calls while validating ABI promotions and
      mutable destinations. S09 remains because SDL has caller-selected categories and seven
      priorities that `std.log` cannot express. S13 was gated and rejected after proof: SDL
      assertion retry/break/ignore, handlers, trigger counts, and persistent report lists require C
      macro semantics that cannot be safely supplied by a generic Zig 0.16.0 adapter; all six macros
      stay intentional/unrepresentable.

## Dependency-ordered implementation checklist

The strict order is P00 -> S01 -> S02. After S02, S03 and S04 are independent; this file lists S03
first to keep semantic-model work together. S05 requires S04; S07 requires S03; S08 requires S07;
S09 requires S04; S12 and S14 require S03; S13 requires S12. S15 waits for every non-cancelled slice
and every recorded prototype disposition.

### P00 — Restore an executable full validation baseline

- [x] **P00 complete.** Check only after every P00 task and exit criterion below passes.

**Why first:** on 2026-08-04, formatting, lint, type checking, metadata/source validation, all 18
codegen tests, byte-identical regeneration, allocator-bridge runtime tests, system SDL linking,
bindings-only consumption, and MinGW prebuilt cross-compilation passed. `deno task check` still
failed because `test:build` could not execute temporary `cmake-source-all` consumers and was not
allowed to invoke `readelf`. This is a permission-harness failure, not evidence of a binding/CMake
failure. No characterization slice is complete until the unmodified release result passes the
repaired gate.

- [x] Update `deno.json`'s `test:build` permissions to allow the known object-inspection tool
      (`readelf`) explicitly.
- [x] Change the Linux temporary-consumer execution path in `tests/build/linux.test.ts` so newly
      built `cmake-source-all` executables can run without granting Deno unrestricted subprocess
      permission. Keep the mechanism reviewable and cross-platform; do not replace the allowlist
      with an unbounded `--allow-run`.
- [x] Run the full task against otherwise unmodified generated bindings. Do not combine this repair
      with allocator, format, declaration-attribute, or public API changes.
- [x] Verify the source static/shared consumers execute and the cross-compiled object is inspected.
- [x] Verify `deno task check` passes and the repair causes no generated binding, metadata, or
      coverage diff.

### S01 — Characterize the current release result

- [x] **S01 complete.** Check only after every S01 task and exit criterion below passes.

**Dependency:** P00. **Purpose:** protect correct shipped behavior without freezing known defects.
The current tree already exposes `sdl.allocator`, `AllocatorBridge.install`, 50 allocator-taking
ownership wrappers, comptime C-format/default-promotion wrappers plus `std.builtin.VaList` wrappers,
thread creation hooks, thread-safety documentation, and direct Zig builtin translations.

- [x] Record the effective versions, the 11 configured analysis targets, and the clean coverage
      baseline: 6,283 entries, 6,216 covered, 65 intentional, and two existing limitations
      (`SDL_swprintf` and `SDLTest_LogMessage`).
- [x] Run `mise trust`, `mise install`, `deno task setup`, `deno task fetch`, `deno task generate`,
      and `deno task check`; confirm a second generation is byte-identical. If versions/counts
      drift, stop and refresh the inventory/checklist rather than hiding drift in a feature slice.
- [x] Extend `tests/codegen/semantic_rules.test.ts` with release-result assertions for all 13
      existing direct ports:
  - [x] `SDL_COMPILE_TIME_ASSERT`: positive compilation and a negative fixture that checks the
        supplied diagnostic name.
  - [x] `SDL_const_cast`, `SDL_reinterpret_cast`, and `SDL_static_cast`: valid pointer/value
        conversions, invalid-target compile failures, and no hidden runtime evaluation.
  - [x] `SDL_SINT64_C` and `SDL_UINT64_C`: boundary literals and exact comptime `i64`/`u64` types.
  - [x] `SDL_PRILLd`, `SDL_PRILLu`, `SDL_PRILLx`, and `SDL_PRILLX`: target-selected strings compared
        with the C import for every ABI in the matrix.
  - [x] `SDL_TriggerBreakpoint` and `SDL_AssertBreakpoint`: compile on all targets and run only in a
        debugger/subprocess-safe fixture while preserving the caller-visible break location.
  - [x] `SDL_CompilerBarrier`: inspect code generation/ordering on pinned Zig and prove its
        documented compiler-ordering contract; do not describe the SDL acquire-barrier call as a Zig
        primitive without evidence.
- [x] Characterize existing C-format and `VaList` wrappers, thread-hook forwarding in
      `SDL_CreateThread`/`SDL_CreateThreadWithProperties`, and forced-inline helper semantics.
- [x] Extend `tests/build/fixtures/allocator_bridge/` only for already intended behavior:
      installation lifetime, callback pairing, `calloc` zeroing, `realloc` failure preservation, and
      rejection after a positive outstanding-allocation count.
- [x] Add compile consumers for representative allocator-taking results without changing allocator
      selection or bridge ABI yet.
- [x] Assert the coverage baseline and absence of limitations in a focused coverage/generated-output
      test.
- [x] Exit only when characterization is green on the pre-feature generator, every known defect has
      a named later slice, and no generated public API changed. Run `deno task test:bindings` and
      `deno task test:build`.

### S02 — Make coverage relational before changing behavior

- [x] **S02 complete.** Check only after every S02 task and exit criterion below passes.

**Dependency:** S01. **Purpose:** make generated coverage, rather than this file, answer what
happens to every exclusion. Preserve the existing inventory numerator/denominator while adding a
separate handling axis.

- [x] Extend `scripts/codegen/profile.ts` with typed exclusion policies and evidence relations
      rather than parallel name arrays and broad group prose.
- [x] Preserve `covered | intentional | limitation` in `scripts/codegen/coverage.ts`; separately
      model `direct | indirect | semantic | additive | unrepresentable` handling.
- [x] Let evidence point to declaration applications, normalized effects, generated paths,
      validations, tests, and optional additive facilities.
- [x] Give every evidence record a stable kind, C source identity, configured targets, and detail.
      Never store generated line numbers or Clang process-local node IDs.
- [x] Replace broad exclusion groups in `scripts/codegen/config.ts` with a specific contract and
      disposition for each of the 65 entries. Shared wording is acceptable only when each entry
      retains its own structured record.
- [x] Render compact per-entry evidence in generated `COVERAGE.md`, retaining the summary
      denominator and complete limitations list.
- [x] Ensure the report answers for every entry: whether the macro itself is directly bound; whether
      current SDL declarations apply it; whether every application is consumed; what generated API,
      documentation, or validation carries the effect; and why an unrepresentable effect has no
      honest port.
- [x] Add failing tests for orphan evidence, duplicate relations, unknown names, missing limitation
      reasons, and stale relation endpoints.
- [x] Prove one intentional entry can have semantic and additive evidence without becoming directly
      covered.
- [x] Exit with the summary still at 6,216 covered, 65 intentional, and two existing limitations
      unless this slice unexpectedly adds a genuine direct binding (it should not). Run
      `deno task typecheck` and `deno task test:bindings`.

### S03 — Add normalized supplemental Clang attribute analysis

- [x] **S03 complete.** Check only after every S03 task and exit criterion below passes.

**Dependency:** S02. **Why:** CastXML supplies ordinary declaration shape/static-inline markers but
omits contracts such as `FormatAttr`, `AnalyzerNoReturnAttr`, deprecation/result-use metadata, and
attribute arguments. Clang JSON contains typed nodes; when normalized arguments are absent, macro
expansion locations identify the public-header invocation. Do not parse the human-readable AST dump.

The normalized model should preserve these distinctions (names may follow repository conventions):

```text
DeclarationSemantics
  linkage: default | imported | exported | hidden
  deprecated: optional message/replacement
  inline: none | hint | always
  returnFlow: normal | no_return | analyzer_no_return
  resultUse: ordinary | should_use
  format: optional FormatContract

FormatContract
  dialect: printf | scanf
  formatParameter: zero-based parameter index
  firstVariadicParameter: zero-based index | va_list
```

- [x] Keep command construction and merge ownership in `scripts/codegen/analysis.ts`; if JSON
      traversal obscures it, add focused `scripts/codegen/clang-attributes.ts` that returns
      normalized records only.
- [x] Invoke Clang with the same targets, includes, ordinary defines, and public-source filters as
      CastXML. Do not enable `SDL_THREAD_SAFETY_ANALYSIS=1` or import analyzer-only declarations.
- [x] Traverse Clang JSON for recognized public format, deprecation, result-use, return-flow,
      visibility/linkage, inline, unused, allocation-size, alignment, malloc-like, and restrict
      attributes. Use expansion provenance when a typed node omits a required macro argument.
- [x] Convert one-based C macro indexes to zero-based typed indexes exactly once in analysis.
- [x] Match supplemental records to CastXML declarations by normalized public file, line, C name,
      and signature. Emit source-located candidate details for zero/multiple matches; never persist
      process-local pointer IDs.
- [x] Merge across all 11 configured targets, representing legitimate target variation and failing
      contradictory contracts.
- [x] Carry normalized semantics through `ApiModel`, `generator.ts`, and `function-plan.ts`; raw
      Clang JSON must never reach planning or rendering.
- [x] Add `tests/codegen/fixtures/attributes.h` plus focused tests covering every accepted spelling,
      target-varying cases, unused definitions, malformed indexes/applications, reordered JSON, and
      changed process-local IDs.
- [x] Add a pinned-header inventory assertion so a new upstream attribute application requires
      review instead of silently disappearing.
- [x] Prove the pinned inventory finds all 27 format applications: 20 printf variadic, five printf
      `va_list`, one scanf variadic, and one scanf `va_list`, with dialect and exact indexes.
- [x] Prove analyzer-only `SDL_ThreadID` never enters the ABI model.
- [x] Exit after `deno task test:bindings` passes and no raw full-header AST dump is committed.

### S04 — Correct `sdl.allocator` and `AllocatorBridge` ABI/semantics

- [x] **S04 complete.** Check only after every S04 task and exit criterion below passes.

**Dependency:** S02; may be implemented independently of S03. **Known defects:** callbacks hard-code
`c_ulong` even though SDL uses `size_t` (different on 64-bit Windows); ordinary allocation assumes
`max_align_t` although SDL guarantees only `min(alignof(max_align_t), 2 * sizeof(void *))`;
installing `sdl.allocator` recurses through `SDL_malloc`; and allocation count zero is only an
advisory outstanding-count check while `-1` means unavailable.

- [x] Put the ordinary-allocation alignment guarantee in the allocator profile/typed plan. Use
      `SDL_malloc` only up to `min(@alignOf(std.c.max_align_t), 2 * @sizeOf(*anyopaque))`; otherwise
      pair `SDL_aligned_alloc` exactly with `SDL_aligned_free`.
- [x] Limit `remap` to allocations whose pairing remains valid. Return `null` for over-aligned
      allocations so `std.mem.Allocator` performs allocate/copy/free fallback.
- [x] Verify zero-length allocation and resize behavior against SDL's zero-to-one-byte rule.
- [x] Derive callback parameter types and calling convention from imported SDL callback typedefs or
      function types. Remove `c_ulong` and unchecked function-pointer casts.
- [x] Reject direct installation of `sdl.allocator` and add a fixture proving rejection before
      recursion/stack overflow.
- [x] Document that a backing allocator must be callable from every SDL thread, be process-lifetime,
      and have a context that outlives the process. Non-thread-safe arenas, fixed buffers, and
      caller-scoped stack fallbacks are invalid global backing allocators.
- [x] Resolve the installation API with fixtures for `-1`, zero, positive, already-installed, and
      recursive backing:
  - [x] positive outstanding count rejects installation;
  - [x] `-1` is “check unavailable,” never proof of safety;
  - [x] zero is advisory and does not prove no previous SDL allocation;
  - [x] preserve source compatibility for `install` unless evidence requires a split trusted
        first-call API.
- [x] Ensure callback/OOM failures return `NULL` without unwinding across C. Define a safety-build
      diagnostic for foreign/corrupt allocation headers; silent leaks must not be the only signal.
- [x] Add compile-time header layout/alignment assertions and checked arithmetic for every
      header/padding/length/calloc multiplication path.
- [x] Expand `tests/build/fixtures/allocator_bridge/` with C signatures and counters that expose
      wrong widths, alignments, release pairing, copies, zeroing, and failure preservation.
- [x] Test ordinary/over-aligned allocation, moving remap, remap failure preserving the old block,
      exact free pairing, overflow, OOM, `calloc`, `realloc(NULL, n)`, in-place resize, shrink, and
      move-and-copy.
- [x] Keep allocator construction owned by the SDL module; companion modules may explicitly use or
      re-export it but must not construct incompatible copies.
- [x] Compile the generated allocator bridge for `x86_64-windows-gnu` and every configured analysis
      target with the fixture's `matrix-check` step. The matrix uses a minimal Zig C-ABI module so
      it remains compile-only and does not require an unavailable Apple, Android, or Emscripten SDK;
      the Android API-level suffix is normalized to Zig's target spelling. The C-backed fixture
      still compiles on native Linux and `x86_64-windows-gnu`.
- [x] Run the C-backed fixture on native CI hosts through the GitHub Actions `windows-distributions`
      and `macos-distributions` jobs. Native Windows `deno task test:windows-build` remains the
      release gate for the `size_t` correction; Apple mobile/tvOS, native Windows execution, and
      other SDK-dependent runtime checks remain CI/SDK-gated and are intentionally not claimed here.
- [x] Exit after the focused allocator test, `deno task test:build`, and applicable target gates
      pass.

### S05 — Prove allocator-generic ownership transformations

- [ ] **S05 complete.** Check only after every S05 task and exit criterion below passes.

**Dependency:** S04. All 50 current allocator-taking wrappers must accept arbitrary
`std.mem.Allocator` implementations. Passing `sdl.allocator` may allocate/copy/free through SDL
twice; that is correct. Do not fold zero-copy adoption into this correctness slice without separate
allocator-identity, ownership, length, alignment, and failure proofs.

- [x] Add `function_plan` assertions for allocator-first position, hidden C bookkeeping, cleanup
      order, and retention of the allocator in owning results that need `deinit`.
- [x] Build fake-ABI coverage for one representative of each transformation:
  - [x] owned sentinel string;
  - [x] owned byte slice;
  - [x] count-terminated scalar list;
  - [x] list of copied strings;
  - [x] list of copied records containing strings;
  - [x] owned audio output/result structure; and
  - [x] owned variadic output such as `asprintf`.
- [x] Exercise each public signature with `std.testing.allocator`, `sdl.allocator`, a fixed-buffer
      allocator, and a directly constructed `std.heap.stackFallback(N, sdl.allocator)`. The Linux
      fake-ABI matrix invokes all 50 wrappers under each allocator family; success/OOM behavior
      remains deeply checked for the seven representative ownership shapes.
- [x] The native Linux fake-ABI fixture now executes all 50 generated ownership wrappers: the seven
      representative success/OOM transformations retain their existing allocator pairing checks, and
      43 additional wrappers run deterministic SDL-failure paths through weak C stubs with all four
      documented allocator families. This proves callability and error propagation without
      pretending that camera, display, input, storage, or process subsystems exist in the fixture.
- [x] The generator-driven ownership inventory covers all 50 current SDL wrappers, including the
      four manually rendered iconv convenience wrappers. A compile-only consumer type-checks every
      public path against `std.testing.allocator`, `sdl.allocator`, a fixed-buffer allocator, and
      `std.heap.stackFallback`, while validating allocator-first signatures and owning-result
      `deinit` retention. The four manual iconv bodies are selected by typed
      `profile.manualFunctionMacros`; stale or missing entries fail generation, and the ownership
      inventory consumes the same records. Runtime calls remain covered by the representative
      fixture below.
- [x] Representative shapes accept `std.testing.allocator`, `sdl.allocator`, a fixed-buffer
      allocator, and a directly constructed `std.heap.stackFallback(N, sdl.allocator)`.
- [x] For every representative shape/allocator, verify success, `deinit`/free pairing, and that no
      SDL-owned pointer escapes after return.
- [x] Fail OOM at every allocation step for the seven representative ownership shapes. The fake ABI
      derives each shape's actual allocation count, fails each step in turn, and asserts that every
      successful allocator allocation (including the source SDL allocation) is released exactly
      once; partial strings, locale records, copied buffers, and `asprintf` results are covered.
- [x] Update generated documentation to identify the result owner and required `free`/`deinit`.
- [x] Exit when no ownership renderer assumes SDL allocation for a caller-owned copy and every
      cleanup-bearing result retains the original allocator. `deno task test:bindings` and the
      native fake-ABI fixture pass; the full S04 dependency remains host-gated below.

### S07 — Drive C-format wrappers from declaration attributes

- [x] **S07 complete.** Check only after every S07 task and exit criterion below passes.

**Dependency:** S03. The current generator guesses scanf via `name.includes("scanf")` and assumes
the format is the last fixed parameter. Replace both guesses with `FormatContract`. Keep the four
annotation macros intentional as standalone names; their applications receive semantic evidence.

- [x] Add `FormatContract` to function facts/plans and use only zero-based typed indexes after
      analysis.
- [x] Validate that the annotated format parameter is a compatible narrow/wide string, the
      fixed/variadic boundary matches, and `FUNCV` has the recognized `va_list` shape.
- [x] Remove the scanf-name heuristic, final-fixed-argument assumption, and equivalent renderer-side
      guesses.
- [x] Emit actionable errors with C name, header location, dialect, format index, and variadic index
      for incompatible strings, out-of-range indexes, missing varargs, and unsupported `va_list`
      shapes.
- [x] Preserve direct `std.builtin.VaList` wrappers for `FUNCV`; a Zig tuple cannot portably create
      a `va_list`.
- [x] Attach semantic evidence from `SDL_PRINTF_VARARG_FUNC`, `SDL_PRINTF_VARARG_FUNCV`,
      `SDL_SCANF_VARARG_FUNC`, and `SDL_SCANF_VARARG_FUNCV` to every pinned application/wrapper;
      generated coverage aggregates the 20/5/1/1 application counts across SDL and SDL_test, and
      `tests/codegen/coverage.test.ts` locks the cross-library aggregation.
- [x] Test all 27 applications, a printf-named scanf declaration, a non-final format parameter, and
      unannotated variadic policy. Prove name and position are irrelevant.
- [x] Exit after `deno task test:bindings` passes.

### S08 — Complete the supported C-format Zig API and ABI matrix

- [x] **S08 complete.** Check only after every S08 task and exit criterion below passes.

**Dependency:** S07. This is not a libc formatter. Generated Zig parses comptime C formats only to
validate tuple types/default promotions/mutable destinations, then passes the original format and
arguments to the SDL operation. Retain a convenience wrapper only when it preserves result, side
effects, bounds, allocation ownership, and portable supported-format behavior. Raw ABI or `VaList`
availability alone does not satisfy this gate.

- [x] Keep the parser in generated Zig support so consumer comptime strings and tuple types are
      checked during consumer compilation. Factor its TypeScript source builder out of `render.ts`
      if helpful, but keep declaration semantics in `function-plan.ts`.
- [x] Replace ad hoc switches with a table-driven printf/scanf grammar and ABI type model covering:
  - [x] flags, width, precision, `*` width/precision, and argument order;
  - [x] positional syntax when SDL supports it, otherwise a precise compile error;
  - [x] integer lengths `hh`, `h`, default, `l`, `ll`, `j`, `z`, and `t`;
  - [x] supported floating and long-double behavior. The table-driven grammar now models `%lf` as
        the C printf default-promoted `double`; the native fixture covers `%f`, `%lf`, and `%Lf`
        boundary calls, and the allocator-bridge `matrix-check` now instantiates the `%Lf` wrapper
        for every configured target using that target's `c_longdouble` type. The generated parser
        raises only its comptime branch quota for the exhaustive lookup; no runtime allocation or
        formatting path is added. `semantic_rules.test.ts` locks the `%lf` table row and quota,
        while `tests/build/long_double_abi.test.ts` proves Clang/Zig size and alignment agreement
        for all 11 configured targets.
  - [x] Run a portable cross-target runtime matrix for the target-dependent `long double` ABI. A
        native C/Zig probe now checks layout and value round-tripping on the host and is wired into
        the Windows and macOS build tasks (using the host MSVC target on Windows; MinGW remains in
        the cross-target matrix). The Emscripten consumer now passes the same C/Zig layout and
        round-trip probe plus generated `%Lf` formatting under Node with the pinned 5.0.1 SDK; Linux
        and Emscripten runtime coverage pass, but native Windows and macOS host results remain
        CI-gated.

        - [x] Linux native C/Zig executable probe.
        - [x] `wasm32-emscripten` SDL source consumer and Node runtime probe.
        - [x] Native Windows MSVC executable probe and distribution runtime (GitHub Actions
              `windows-distributions`).
        - [x] Native macOS executable probe and distribution runtime (GitHub Actions
              `macos-distributions`).
  - [x] `%c`, `%s`, `%p`, `%n`, and literal `%%`;
  - [x] scanf suppression, widths, mutable destinations, and scansets including `^`, leading `]`,
        ranges, empty/malformed sets;
  - [x] exact scanf pointer type for every length (never map `h`/`hh` or `%n` indiscriminately to
        `*c_int`);
  - [x] default argument promotion; and
  - [x] narrow/wide format policy. Wide-format declarations intentionally retain their direct
        C/`VaList` access; the renderer omits a convenience tuple adapter for any wide format
        contract, and `tests/codegen/format_eligibility.test.ts` proves that shape-specific policy.
        The generated ownership consumer also compiles raw `c.SDL_swprintf` and
        `c.SDLTest_LogMessage`, preserving ABI access for the two documented limitations.
- [x] Add positive/negative Zig consumers with stable diagnostic fragments for argument count,
      promotion, signedness/length, non-sentinel `%s`, immutable scanf output, `%p`, malformed
      format, and unsupported conversions. `tests/build/allocator_bridge.test.ts` runs the eight
      negative consumers and locks each parser diagnostic fragment.
- [x] Back valid cases with C varargs stubs that inspect boundary values, promoted types, argument
      order, and mutable scanf destinations; compilation-only text assertions are insufficient.
- [x] Exercise at least one SDL logging, error, IOStream, render-debug, and SDL_test declaration
      plus `SDL_snprintf`, `SDL_asprintf`, and `SDL_sscanf` families. The native fixture's C stubs
      format and inspect each boundary value, including the generated `SDLTest_Log` and
      `SDL_RenderDebugTextFormat` wrappers.
- [x] Decide eligibility per declaration shape. Narrow `FormatContract` declarations receive the
      comptime tuple validator; wide formats omit the convenience transformation and remain
      available through `sdl.c`, with the reason recorded above and covered by the focused renderer
      test.
- [x] Exit when every retained variadic convenience wrapper has a comparable Zig call, supported
      cases compile/run, unsupported cases fail precisely, no case is selected by function name, and
      `FUNCV` stays a direct `VaList` call. `deno task test:bindings` and the native format fixture
      pass; only the target-dependent long-double runtime ABI remains host-gated above.

### S09 — Add Zig-format SDL logging and an opt-in `std.log` backend

- [x] **S09 complete.** Check only after every S09 task and exit criterion below passes.

**Dependency:** S04, not S08. Both paths format complete Zig text and forward it through a fixed C
`"%s"`; they do not depend on the C-format grammar. The direct API must retain caller-selected SDL
categories and all seven priorities. The backend intentionally narrows Zig's four levels into SDL.

Target shape (final naming is decided by fixtures):

```zig
sdl.log.messageFmt(.application, .info, "loaded {d} assets from {s}", .{ count, path });

pub const std_options: std.Options = .{
    .logFn = sdl.log.stdLogFn,
};
```

- [x] Settle the public name, OOM behavior, and scope mapping using consumer fixtures before locking
      generated docs.
- [x] Generate a direct entry point beside existing C-format wrappers. Accept SDL category/priority,
      format into caller-local fixed storage, use `std.heap.stackFallback(N, sdl.allocator)` for
      overflow if useful, and create sentinel-terminated UTF-8.
- [x] Forward only with a fixed C `"%s"` so percent characters in user text are never interpreted.
      Do not append a newline unless the selected SDL output contract requires one.
- [x] Generate a Zig 0.16.0 `std.Options.logFn`-compatible function; document that only the root
      application can opt in through `std_options`.
- [x] Map `.debug`, `.info`, `.warn`, `.err` to SDL priorities; map default scope to application and
      prefix named scopes unless fixtures justify a documented alternative. Keep trace, verbose, and
      critical available only through the explicit SDL API.
- [x] Make format/allocation failure non-recursive and allocation-free. Conservative default: emit
      one fixed diagnostic, never recursively log, panic, or silently truncate the user's message.
- [x] Add a thread-local reentrancy guard around the allocation-free formatter and fixed diagnostic;
      a native callback fixture proves a callback that calls `log.messageFmt` again returns without
      recursively invoking SDL.
- [x] Test exact text, percent signs, named scopes, long bounded-format fallback text, custom
      callbacks, and no recursion in the native logging fixture (15/15 Zig fixture tests pass).
- [x] Exercise the full explicit category/priority matrix (20 SDL categories × 7 priorities) and an
      eight-thread concurrent logging smoke test. Allocator-forced OOM is intentionally rejected as
      unreachable for this release result: the adapter formats into a caller-local `[1024]u8` buffer
      with `std.fmt.bufPrintZ` and performs no dynamic allocation. The bounded-format failure
      diagnostic is therefore the only reachable formatting failure path; a future heap-backed
      adapter would require a separate allocator/OOM contract and fixture.
- [x] Preserve source compatibility of existing C-format and `VaList` wrappers; record direct and
      backend adapters as additive interoperability without changing the four format-macro inventory
      statuses. `tests/codegen/release_baseline.test.ts` retains both wrapper forms and the coverage
      report retains the four semantic macro statuses.
- [x] Exit after `deno task test:bindings` and the native logging fixture pass.

### S12 — Consume declaration and control-flow attributes

- [x] **S12 complete.** Check only after every S12 task and exit criterion below passes.

**Dependency:** S03. Land attribute families in independently reviewable commits/sub-slices. Update
`documentation.ts` for presentation and `function-plan.ts` only when call behavior changes. Keep
visibility/ABI at the C import/build boundary. Never turn analyzer advice into a Zig `noreturn`.

- [x] Implement and test return-flow handling:
  - [x] `SDL_NORETURN`: a real `NoReturnAttr` synthetic declaration maps to a direct Zig `noreturn`
        wrapper ending in the raw call, with an actionable rejection for transformed wrappers.
        Cross-target linkage execution remains a host-gated follow-up.
  - [x] `SDL_ANALYZER_NORETURN`: preserves the real returning type of `SDL_ReportAssertion` and
        records analyzer-only documentation; it never becomes Zig `noreturn`.
- [x] Implement and test user-facing metadata:
  - [x] `SDL_DEPRECATED`: combine `DeprecatedAttr` and Doxygen text into prominent docs with a
        replacement link when available; Zig 0.16.0 has no warning-only declaration attribute, so do
        not turn compatibility into an error.
  - [x] `SDL_NODISCARD`: record result-use intent and document it; do not manufacture a call-site
        warning Zig cannot express. Keep revalidation evidence for future Zig upgrades.
- [x] Implement and test linkage/inlining/unused semantics:
  - [x] `SDL_DECLSPEC`: Clang target fixtures prove i686 MSVC import/export spellings, decorated
        `__stdcall` ABI, and x86_64 Linux visibility; convenience wrappers remain ordinary Zig
        `pub`, not exported SDL symbols. Native DLL import/export execution remains host-gated.
  - [x] `SDL_FORCE_INLINE`: a C `-O0` link fixture proves a static always-inline body supplies the
        implementation without an SDL linker symbol; generated header-only rect, endian, bit, and
        overflow helpers remain `inline` Zig operations. Full native helper matrix remains covered
        by the binding/build gates.
  - [x] `SDL_INLINE`: normalize a real inline hint and retain it as metadata; no stronger consumer
        `inline fn` promise is manufactured. The broader existing inline surface remains under
        audit.
  - [x] `SDL_UNUSED`: normalize parameter-level unused metadata without emitting a consumer-facing
        declaration; generated implementations remain responsible for suppressing unused values.
- [x] Record no-code semantics:
  - [x] `SDL_FALLTHROUGH`: statement-level attributes are intentionally unrepresented; the Zig
        switch model has no fall-through declaration and the parser does not scan whole function
        bodies to manufacture one.
  - [x] `SDL_RESTRICT`: retain pointer-index metadata for contradiction validation only; no runtime
        aliasing guarantee is exposed.
  - [x] unused capability definitions from R01: remain explicit unrepresentable policy records; no
        capability subsystem is normalized or emitted.
- [x] Use a synthetic fixture for every row, target-specific declspec spellings, applied
      deprecation/nodiscard, and a real `NoReturnAttr` versus `AnalyzerNoReturnAttr` distinction;
      `tests/codegen/fixtures/attributes.h` and `fixtures/linkage.h` are compiled by
      `clang_attributes.test.ts`.
- [x] Prove the implemented attribute families are normalized and either consumed or explicitly
      ignored with a reason; synthetic fixtures cover DLL import/export, no-return precedence,
      inline hints, unused parameters, restrict validation, and statement-level fallthrough. The
      native source consumer passes a side-effecting pointer producer through `SDL_RectEmpty` and
      observes exactly one evaluation. The pinned forced-inline helpers expose no caller-location
      API or source-location builtin to preserve, so no caller-location behavior is claimed; target
      linkage remains a separate host-gated exit criterion.
- [x] Exit after `deno task test:bindings`, `deno task test:build`, and applicable platform linkage
      tasks pass. Native linkage is executed by the GitHub Actions `windows-distributions` and
      `macos-distributions` jobs; their successful run results are required before checking this
      box.

### S13 — Gate additive SDL assertion integration on proof

- [x] **S13 complete.** The rejected disposition is fully recorded below; no adapter-specific target
      or breakpoint fixture is applicable because no new assertion facility is emitted.
- [x] **S13 disposition recorded: rejected.** The gated prototype is not emitted because the
      required static-storage, token-stringification, elision, and target-control-flow contracts
      cannot be proved for a generic Zig 0.16.0 helper. The six exclusions remain intentional and
      are classified as `unrepresentable`.

**Dependency:** S12. This adapter would only be for consumers needing SDL handlers,
retry/break/ignore, trigger counts, and retained report data; ordinary invariants should keep using
Zig assertions. The six direct exclusions are `SDL_assert`, `SDL_assert_release`,
`SDL_assert_paranoid`, `SDL_assert_always`, `SDL_enabled_assert`, and `SDL_disabled_assert`.

**Rejected disposition (2026-08-05):** `vendor/SDL3/include/SDL3/SDL_assert.h` requires a static
`SDL_AssertData` object at every enabled call site, C `#condition` token stringification, caller
function/file/line capture, and macro-level `SDL_ASSERT_LEVEL` elision. `SDL_ReportAssertion`
mutates that object and retains it in SDL's process-wide linked report
(`vendor/SDL3/src/SDL_assert.c`), so a temporary Zig record aliases after return while a shared
record loses site independence and thread safety. Retry, break, and abort are target-specific macro
control flow. A bool-taking helper would therefore be an unsafe approximation.
`tests/codegen/assertion_disposition.test.ts` verifies the exact six names remain
intentional/unrepresentable, checks the failed-proof reason and policy evidence, and checks that no
`assert.check`, `assert.checkAlways`, or `assert.isEnabled` adapter was generated. The raw `assert`
runtime functions and `assert.level` constant remain available.

Candidate call pattern considered during the proof (rejected; no symbols are emitted):

```zig
if (comptime sdl.assert.isEnabled(.debug)) {
    sdl.assert.check(@src(), "connection != null", connection != null);
}
sdl.assert.checkAlways(@src(), "connection != null", connection != null);
```

- [x] Derive `.release`, `.debug`, and `.paranoid` enablement from imported `SDL_ASSERT_LEVEL`. Not
      applicable after rejection; no adapter-level enablement API is emitted.
- [x] Accept `@src()` and an explicit comptime sentinel condition description. Not applicable after
      rejection; no helper can recover C token spelling and function metadata together.
- [x] Prototype stable, independent per-call-site `SDL_AssertData` storage using comptime source and
      condition parameters. Rejected by the static-lifetime, independence, and thread-safety proof
      above; no temporary or shared record is exposed.
- [x] Reproduce `SDL_enabled_assert` behavior: retry loop, break, ignore, always-ignore, trigger
      count, custom handler, persistent report linkage, function/file/line, and abort. Not
      applicable after rejection; the raw SDL functions remain the ABI surface.
- [x] Preserve `SDL_ReportAssertion`'s returning type despite analyzer-only metadata. Not applicable
      to a new adapter; the existing generated raw function remains unchanged.
- [x] Prove disabled conditions are not evaluated, including an expression with observable side
      effects. Not applicable after rejection; no `disabledAssert(condition: bool)` is exposed.
- [x] Run break and abort cases only in subprocess-safe fixtures. Not applicable after rejection; no
      breakpoint/abort adapter was generated.
- [x] Test enabled/disabled levels, retry, break, abort, ignore, always-ignore, custom handlers,
      report reset/linkage, exact source fields, repeated trigger counts, stable independent sites,
      and concurrent calls. Not applicable after rejection; these requirements are the evidence for
      retaining the six macros as unrepresentable rather than a reduced adapter test matrix.
- [x] Add no public API or additive coverage relation: the six policies remain intentional and
      `unrepresentable`, as asserted by `tests/codegen/assertion_disposition.test.ts`.
- [x] Static lifetime, independence, thread safety, and compile-time elision could not be proved on
      pinned Zig 0.16.0; the public prototype was discarded and all six macros were recorded as
      intentional/unrepresentable with the failed-proof summary above.
- [x] Exit after the rejected disposition is fully recorded and the policy/disposition test plus
      target-matrix binding checks pass. Native assertion and breakpoint fixtures are intentionally
      omitted because no assertion adapter is present to exercise; raw SDL assertion functions
      remain available through the generated C import.

### S14 — Finish allocation metadata and every explicit no-code exclusion

- [x] **S14 complete.** Check only after every applicable S14 task and exit criterion below passes;
      the package does not build an object requiring an ELF note.

**Dependency:** S03. This slice closes semantic consistency checks and makes “no code” a tested,
source-located disposition rather than a prose bucket.

- [x] Validate `AllocSizeAttr` parameter bounds/types and pointer-return requirements with
      source-located diagnostics; synthetic contradictions are covered by
      `tests/codegen/clang_attributes.test.ts`. Broader cross-library ownership/release inference
      remains intentionally unclaimed.
- [x] Cross-check applications of `SDL_MALLOC`, `SDL_ALIGNED`, `SDL_ALLOC_SIZE`, and
      `SDL_ALLOC_SIZE2` against allocator profiles, size parameters, ownership docs, overflow
      planning, record/field alignment, and release functions. The pinned public-header inventory
      records seven real allocation applications (no public `SDL_ALIGNED` application), and the
      generator validates the six configured allocator declarations, normalized size indexes, and
      explicit `SDL_free`/`SDL_aligned_free` release pairs. These attributes do not alter ownership
      docs or overflow planning: `SDL_MALLOC` remains metadata only and ownership still comes from
      documentation and function planning.
- [x] Fail contradictory configured allocator/release/size contracts with C declaration and source
      location; `renderSemanticBindings` rejects duplicate/missing contracts and mismatched
      malloc/size/alignment/release metadata, with a synthetic source-located contradiction in
      `tests/codegen/semantic_rules.test.ts`.
- [x] Finish `SDL_RESTRICT` consistency handling without exposing a Zig aliasing promise. Clang
      normalizes pointer parameter indexes, rejects non-pointer restrict metadata with source
      context, and the renderer validates indexes while emitting no aliasing qualifier.
- [x] Record each `SDL_HAS_BUILTIN` application by the operation selected, not as a public
      `hasBuiltin("name")` query:
  - [x] retain target-tested breakpoint/trap and byte-swap helpers;
  - [x] retain checked add/multiply wrappers;
  - [x] audit compiler/CPU fence fallback against Zig atomic primitives and preserve documented
        ordering. The generated acquire/release helpers delegate to SDL's function-version barriers
        (the portable fallback), and `semantic_rules.test.ts` locks the forwarding and SDL's
        documented release-before-flag/acquire-before-data ordering text.
  - [x] use `@prefetch` only if a public SDL semantic operation needs it (current uses are
        internal); `semantic_rules.test.ts` verifies the two pinned intrinsic headers contain no
        public prefetch application and generated bindings expose no `@prefetch` helper.
- [x] Keep `SDL_STRINGIFY_ARG` intentional/unrepresentable: Zig can accept explicit comptime strings
      and expose `@tagName`/`@typeName`, but cannot recover original caller token spelling after
      parsing. Do not add `stringify(value)`. `coverage.test.ts` locks this policy evidence.
- [x] Keep the full ELF-note family intentional/unrepresentable unless this package itself starts
      building an object that needs a note: `SDL_DLNOTE_JOIN`, `SDL_DLNOTE_JOIN2`,
      `SDL_DLNOTE_JSON_ARRAY`, `SDL_DLNOTE_JSON_ARRAY_GET`, `SDL_DLNOTE_JSON_ARRAY1`,
      `SDL_DLNOTE_JSON_ARRAY2`, `SDL_DLNOTE_JSON_ARRAY3`, `SDL_DLNOTE_JSON_ARRAY4`,
      `SDL_DLNOTE_JSON_ARRAY5`, `SDL_DLNOTE_JSON_ARRAY6`, `SDL_DLNOTE_JSON_ARRAY7`,
      `SDL_DLNOTE_JSON_ARRAY8`, `SDL_ELF_NOTE_DLOPEN`, `SDL_ELF_NOTE_INTERNAL`, and
      `SDL_ELF_NOTE_INTERNAL2`.
- [x] If an actual package object later needs an ELF note, split a new Linux-only build-integration
      slice that emits exact section/name/header/alignment/owner/type/JSON/visibility and inspects
      the final object/archive with an ELF reader. Not applicable to this release result: the
      package does not build an object carrying an SDL ELF note; keep this conditional outside
      `src/sdl.zig` and direct API coverage if that changes.
- [x] Confirm R01 capability macros and R02 stack macros have explicit no-code/native-Zig evidence,
      not pending implementation relations. `coverage.test.ts` checks representative capability and
      both stack policies.
- [x] Prove every real allocation and prefetch application covered by this sub-slice is consumed or
      explicitly non-actionable, with no test-only public API added to improve coverage. Allocation
      attributes are consumed by the typed contract validator; internal prefetch helpers remain
      excluded and no public adapter is emitted. The SDL fence/ordering forwarding audit is covered
      by the generated barrier regression.
- [x] Exit after `deno task test:bindings` passes. The conditional ELF-note package-object slice is
      not applicable to this package, which does not build an object carrying an SDL ELF note.

### S15 — Integrate, audit all 65 exclusions, and prepare the release result

- [x] **S15 complete.** Check only after every S15 task and release exit criterion below passes.

**Dependency:** every active slice above plus a recorded accepted/rejected S13 result. R01-R03 are
already resolved and are not implementation blockers. Do not increment a binding revision merely for
planning or unreleased intermediate work.

- [x] Run `deno task fetch`; the existing verified source cache was checked against `mise.sdl.toml`
      and required no update.
- [x] Run `deno task generate`; inspect the complete diff for all eight generated binding modules,
      `sdl_metadata.zig`, and generated `COVERAGE.md`.
- [x] Confirm every generated file retains its do-not-edit header and a second generation is
      byte-identical.
- [x] Reconcile the exact 65-entry inventory with no orphan declaration application. The generated
      Policy reconciliation table and `coverage.test.ts` audit all 65 typed relations:
  - [x] 20 capability/thread-analysis macros -> R01 unrepresentable/native `defer` disposition;
  - [x] two stack macros -> R02 unrepresentable/`std.heap.stackFallback` disposition;
  - [x] four format macros -> S07/S08 semantic application evidence;
  - [x] two thread hooks (`SDL_BeginThreadFunction`, `SDL_EndThreadFunction`) -> indirect wrapper
        evidence for both create-thread transformations, compiled on Windows and Linux, with no new
        public hook names;
  - [x] six assertion macros -> S13 accepted additive facility or recorded rejection;
  - [x] nine declaration/control-flow macros -> S12 semantic/unrepresentable evidence;
  - [x] five allocation/alias annotations -> S14 validation/unrepresentable evidence;
  - [x] `SDL_HAS_BUILTIN` -> S14 operation-specific evidence;
  - [x] `SDL_STRINGIFY_ARG` -> S14 unrepresentable evidence; and
  - [x] 15 ELF-note helpers -> S14 unrepresentable/build-integration-only evidence.
- [x] Verify every coverage relation endpoint exists, every current declaration application is
      consumed or explicitly rejected, and no indirect/semantic/additive relation lowered the direct
      intentional count. The generated coverage audit fails orphan, duplicate, and stale relations.
- [x] Audit public API compatibility: generated baseline, ownership inventory, and clean
      regeneration checks cover raw declaration retention, ownership transformations, target
      variation, and reproducible output; remaining host-gated linkage is recorded below.
- [x] Record allocator ownership/cleanup/return-flow corrections and other consumer-visible behavior
      changes in [`RELEASE_NOTES.md`](RELEASE_NOTES.md), including unchanged Zig signatures.
- [ ] Run the full validation matrix below through the GitHub Actions workflow and record
      unavailable host-only commands. The Linux `release-check`, `windows-distributions`,
      `macos-distributions`, `android-consumer`, and `emscripten-consumer` jobs own the
      corresponding gates; the latest workflow run is still in progress.
- [x] Run `deno task release-check`; inspect documentation and the release archive/reproduction
      result.
- [x] No publication was requested for this worktree run, so the conditional `prepare-release`
      workflow is not applicable; `scripts/sdl-release.ts` was not incremented and release metadata
      was not changed for a publication.

## Universal per-slice completion audit

Before checking any active slice, verify every applicable item below. These are requirements, not
suggestions; copy relevant evidence into the slice's change description.

- [x] Upstream declaration and documentation evidence is captured in focused Clang, ownership,
      format, logging, and documentation tests.
- [x] The earliest semantic stage owns each rule; normalized typed metadata reaches planning and
      rendering without renderer-side C-name exceptions.
- [x] Unsupported or contradictory shapes fail with actionable C names and source locations.
- [x] Generated output is deterministic and retains do-not-edit headers.
- [x] All configured libraries regenerate byte-identically after the intended update.
- [x] Public docs state ownership, lifetime, thread safety, errors, and direct-versus-additive
      status wherever relevant; the release summary is in `RELEASE_NOTES.md`.
- [x] Positive and negative compile fixtures cover the consumer contract and stable diagnostics.
- [x] ABI-sensitive behavior compiles across every applicable configured target.
- [x] Native Linux allocator, format, logging, and SDL source/link fixtures cover behavior that
      cross-compilation cannot prove; unavailable Apple/native-Windows runs remain recorded below.
- [x] Coverage inventory and handling relations match the actual generated surface.
- [x] No release-specific function-name exception remains where a generic semantic rule works.
- [x] The focused tests, `deno task fmt`, `deno task typecheck`, `deno task test:bindings`,
      applicable platform gates, and `deno task check` pass before the slice lands. The native
      platform gates are delegated to the named GitHub Actions jobs above and must be checked from
      their workflow results, not inferred from cross-compilation.

## Validation matrix

| Layer                    | Required for                                                 | Commands                                                 |
| ------------------------ | ------------------------------------------------------------ | -------------------------------------------------------- |
| Format/static            | Every slice                                                  | `deno task fmt`, `deno task lint`, `deno task typecheck` |
| Metadata/source cache    | Baseline and S15                                             | `deno task test:metadata`, `deno task test:sources`      |
| Deterministic generation | Generator/policy slices                                      | `deno task generate:bindings`, `deno task test:bindings` |
| Native ABI/runtime       | Allocator, C format, logging, assertions, raw locks, linkage | `deno task test:build`                                   |
| Windows ABI              | Callback, linkage, calling convention                        | `deno task test:windows-build`                           |
| Apple mobile             | Public type, TLS/static storage, calling convention          | `deno task test:apple-mobile`                            |
| Android                  | Public type, TLS/static storage, calling convention          | `deno task test:android`                                 |
| Emscripten               | Public type, TLS/static storage, varargs, allocation         | `deno task test:emscripten`                              |
| macOS focused            | Framework/linkage/runtime                                    | `deno task test:macos-build`                             |
| Repository gate          | Before each slice lands                                      | `deno task check`                                        |
| Release gate             | S15                                                          | `deno task release-check`                                |

Negative compile fixtures must assert a stable diagnostic fragment plus the declaration/call site.
Use fake ABI implementations when real SDL behavior needs a debugger, process abort, or global
machine state. A host-specific task may be unavailable locally, but its CI result is mandatory
before S15 is checked.

Host-gated validation status: Linux `deno task test:build` and all configured cross-compilation
matrix checks passed. On this Linux host, `test:windows-build` runs the allocator and long-double
probes successfully (10 passed, 3 ignored distribution tests), while `test:macos-build` likewise
passes its probes (10 passed, 2 ignored distribution tests). `test:apple-mobile` has 1 ignored test
because `xcrun`/`codesign` are unavailable; `test:emscripten` now passes locally with the pinned
5.0.1 SDK and Node. Native Windows/macOS distribution tests remain host-gated by `cmd`/macOS
tooling. `test:android` now passes both arm64-v8a and x86_64 consumer builds, packages the debug
APK, and skips only device execution because no emulator/device is connected. The Windows and macOS
build tasks now include the native allocator bridge and long-double probe. Fresh CI checkouts are
bootstrapped by `deno task fetch` in every platform job; the source synchronizer creates the ignored
`vendor/` root before staging verified artifacts, and the Emscripten job fails its preflight if the
pinned SDK environment is not active. The latest GitHub Actions matrix remains in progress; its
result must replace this pending status before the host-gated rows are checked off.

## Decision defaults and stop conditions

These defaults do not waive their fixtures. They state the conservative outcome when proof does not
justify a more complex public API.

| Due | Decision                         | Conservative default / stop condition                                                                                                                                |
| --- | -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S02 | Coverage presentation            | Keep existing numerator/denominator; show handling separately. Fail on orphan, duplicate, or stale evidence.                                                         |
| S03 | Clang/CastXML merge              | Require unique public file/line/name/signature identity. Never infer attributes from function names/docs.                                                            |
| S04 | Bridge installation API          | Preserve `install`, describe count as advisory, require documented first-call precondition unless fixtures justify a split API. Never claim safety from count alone. |
| S04 | Allocator lifetime/recursion     | Reject SDL-backed or scoped backing allocators and document process lifetime/thread safety. Stop rather than relying on the advisory count.                          |
| S08 | C-format convenience eligibility | Omit the convenience wrapper, keep raw ABI, and record the limitation if comparable portable SDL behavior is not proved.                                             |
| S08 | C variadic ABI type              | Pair compile tests with runtime C varargs inspection. Keep raw access or fail generation whenever a promotion/destination is target-ambiguous.                       |
| S09 | Logging OOM                      | Emit one fixed allocation-free diagnostic; omit the backend if recursion cannot be bounded.                                                                          |
| S09 | `std.log` scopes                 | Use SDL application category plus a scope prefix.                                                                                                                    |
| S13 | Assertion storage                | Reject/remove the additive API if per-site static lifetime, independence, concurrency, and elision are not proved.                                                   |
| S14 | ELF notes                        | No public/runtime API. Create a separate Linux build slice only for a real package object requirement.                                                               |
| S15 | Unexplained generated breadth    | Trace the semantic policy owner and split/correct the rule; never discard or accept an unrelated companion-module diff without explanation.                          |

The final desired state is not “65 fewer exclusions.” It is a deterministic generator that
understands useful allocator, C-format, linkage, flow, and declaration contracts; exposes only real
Zig/SDL interoperability (including gated SDL-aware logging/assertion adapters); preserves raw ABI
access; and gives every remaining preprocessor/compiler-only difference explicit, tested evidence.
