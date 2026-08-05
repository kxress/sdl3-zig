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
      priorities that `std.log` cannot express. S13 remains a gated prototype because SDL assertion
      retry/break/ignore, handlers, trigger counts, and persistent report lists are not supplied by
      Zig assertions.

## Dependency-ordered implementation checklist

The strict order is P00 -> S01 -> S02. After S02, S03 and S04 are independent; this file lists S03
first to keep semantic-model work together. S05 requires S04; S07 requires S03; S08 requires S07;
S09 requires S04; S12 and S14 require S03; S13 requires S12. S15 waits for every non-cancelled slice
and every recorded prototype disposition.

### P00 — Restore an executable full validation baseline

- [ ] **P00 complete.** Check only after every P00 task and exit criterion below passes.

**Why first:** on 2026-08-04, formatting, lint, type checking, metadata/source validation, all 18
codegen tests, byte-identical regeneration, allocator-bridge runtime tests, system SDL linking,
bindings-only consumption, and MinGW prebuilt cross-compilation passed. `deno task check` still
failed because `test:build` could not execute temporary `cmake-source-all` consumers and was not
allowed to invoke `readelf`. This is a permission-harness failure, not evidence of a binding/CMake
failure. No characterization slice is complete until the unmodified release result passes the
repaired gate.

- [ ] Update `deno.json`'s `test:build` permissions to allow the known object-inspection tool
      (`readelf`) explicitly.
- [ ] Change the Linux temporary-consumer execution path in `tests/build/linux.test.ts` so newly
      built `cmake-source-all` executables can run without granting Deno unrestricted subprocess
      permission. Keep the mechanism reviewable and cross-platform; do not replace the allowlist
      with an unbounded `--allow-run`.
- [ ] Run the full task against otherwise unmodified generated bindings. Do not combine this repair
      with allocator, format, declaration-attribute, or public API changes.
- [ ] Verify the source static/shared consumers execute and the cross-compiled object is inspected.
- [ ] Verify `deno task check` passes and the repair causes no generated binding, metadata, or
      coverage diff.

### S01 — Characterize the current release result

- [ ] **S01 complete.** Check only after every S01 task and exit criterion below passes.

**Dependency:** P00. **Purpose:** protect correct shipped behavior without freezing known defects.
The current tree already exposes `sdl.allocator`, `AllocatorBridge.install`, 50 allocator-taking
ownership wrappers, comptime C-format/default-promotion wrappers plus `std.builtin.VaList` wrappers,
thread creation hooks, thread-safety documentation, and direct Zig builtin translations.

- [ ] Record the effective versions, the 11 configured analysis targets, and the clean coverage
      baseline: 6,283 entries, 6,218 covered, 65 intentional, zero limitations.
- [ ] Run `mise trust`, `mise install`, `deno task setup`, `deno task fetch`, `deno task generate`,
      and `deno task check`; confirm a second generation is byte-identical. If versions/counts
      drift, stop and refresh the inventory/checklist rather than hiding drift in a feature slice.
- [ ] Extend `tests/codegen/semantic_rules.test.ts` with release-result assertions for all 13
      existing direct ports:
  - [ ] `SDL_COMPILE_TIME_ASSERT`: positive compilation and a negative fixture that checks the
        supplied diagnostic name.
  - [ ] `SDL_const_cast`, `SDL_reinterpret_cast`, and `SDL_static_cast`: valid pointer/value
        conversions, invalid-target compile failures, and no hidden runtime evaluation.
  - [ ] `SDL_SINT64_C` and `SDL_UINT64_C`: boundary literals and exact comptime `i64`/`u64` types.
  - [ ] `SDL_PRILLd`, `SDL_PRILLu`, `SDL_PRILLx`, and `SDL_PRILLX`: target-selected strings compared
        with the C import for every ABI in the matrix.
  - [ ] `SDL_TriggerBreakpoint` and `SDL_AssertBreakpoint`: compile on all targets and run only in a
        debugger/subprocess-safe fixture while preserving the caller-visible break location.
  - [ ] `SDL_CompilerBarrier`: inspect code generation/ordering on pinned Zig and prove its
        documented compiler-ordering contract; do not describe the SDL acquire-barrier call as a Zig
        primitive without evidence.
- [ ] Characterize existing C-format and `VaList` wrappers, thread-hook forwarding in
      `SDL_CreateThread`/`SDL_CreateThreadWithProperties`, and forced-inline helper semantics.
- [ ] Extend `tests/build/fixtures/allocator_bridge/` only for already intended behavior:
      installation lifetime, callback pairing, `calloc` zeroing, `realloc` failure preservation, and
      rejection after a positive outstanding-allocation count.
- [ ] Add compile consumers for representative allocator-taking results without changing allocator
      selection or bridge ABI yet.
- [ ] Assert the coverage baseline and absence of limitations in a focused coverage/generated-output
      test.
- [ ] Exit only when characterization is green on the pre-feature generator, every known defect has
      a named later slice, and no generated public API changed. Run `deno task test:bindings` and
      `deno task test:build`.

### S02 — Make coverage relational before changing behavior

- [ ] **S02 complete.** Check only after every S02 task and exit criterion below passes.

**Dependency:** S01. **Purpose:** make generated coverage, rather than this file, answer what
happens to every exclusion. Preserve the existing inventory numerator/denominator while adding a
separate handling axis.

- [ ] Extend `scripts/codegen/profile.ts` with typed exclusion policies and evidence relations
      rather than parallel name arrays and broad group prose.
- [ ] Preserve `covered | intentional | limitation` in `scripts/codegen/coverage.ts`; separately
      model `direct | indirect | semantic | additive | unrepresentable` handling.
- [ ] Let evidence point to declaration applications, normalized effects, generated paths,
      validations, tests, and optional additive facilities.
- [ ] Give every evidence record a stable kind, C source identity, configured targets, and detail.
      Never store generated line numbers or Clang process-local node IDs.
- [ ] Replace broad exclusion groups in `scripts/codegen/config.ts` with a specific contract and
      disposition for each of the 65 entries. Shared wording is acceptable only when each entry
      retains its own structured record.
- [ ] Render compact per-entry evidence in generated `COVERAGE.md`, retaining the summary
      denominator and complete limitations list.
- [ ] Ensure the report answers for every entry: whether the macro itself is directly bound; whether
      current SDL declarations apply it; whether every application is consumed; what generated API,
      documentation, or validation carries the effect; and why an unrepresentable effect has no
      honest port.
- [ ] Add failing tests for orphan evidence, duplicate relations, unknown names, missing limitation
      reasons, and stale relation endpoints.
- [ ] Prove one intentional entry can have semantic and additive evidence without becoming directly
      covered.
- [ ] Exit with the summary still at 6,218 covered, 65 intentional, zero limitations unless this
      slice unexpectedly adds a genuine direct binding (it should not). Run `deno task typecheck`
      and `deno task test:bindings`.

### S03 — Add normalized supplemental Clang attribute analysis

- [ ] **S03 complete.** Check only after every S03 task and exit criterion below passes.

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

- [ ] Keep command construction and merge ownership in `scripts/codegen/analysis.ts`; if JSON
      traversal obscures it, add focused `scripts/codegen/clang-attributes.ts` that returns
      normalized records only.
- [ ] Invoke Clang with the same targets, includes, ordinary defines, and public-source filters as
      CastXML. Do not enable `SDL_THREAD_SAFETY_ANALYSIS=1` or import analyzer-only declarations.
- [ ] Traverse Clang JSON for recognized public format, deprecation, result-use, return-flow,
      visibility/linkage, inline, unused, allocation-size, alignment, malloc-like, and restrict
      attributes. Use expansion provenance when a typed node omits a required macro argument.
- [ ] Convert one-based C macro indexes to zero-based typed indexes exactly once in analysis.
- [ ] Match supplemental records to CastXML declarations by normalized public file, line, C name,
      and signature. Emit source-located candidate details for zero/multiple matches; never persist
      process-local pointer IDs.
- [ ] Merge across all 11 configured targets, representing legitimate target variation and failing
      contradictory contracts.
- [ ] Carry normalized semantics through `ApiModel`, `generator.ts`, and `function-plan.ts`; raw
      Clang JSON must never reach planning or rendering.
- [ ] Add `tests/codegen/fixtures/attributes.h` plus focused tests covering every accepted spelling,
      target-varying cases, unused definitions, malformed indexes/applications, reordered JSON, and
      changed process-local IDs.
- [ ] Add a pinned-header inventory assertion so a new upstream attribute application requires
      review instead of silently disappearing.
- [ ] Prove the pinned inventory finds all 27 format applications: 20 printf variadic, five printf
      `va_list`, one scanf variadic, and one scanf `va_list`, with dialect and exact indexes.
- [ ] Prove analyzer-only `SDL_ThreadID` never enters the ABI model.
- [ ] Exit after `deno task test:bindings` passes and no raw full-header AST dump is committed.

### S04 — Correct `sdl.allocator` and `AllocatorBridge` ABI/semantics

- [ ] **S04 complete.** Check only after every S04 task and exit criterion below passes.

**Dependency:** S02; may be implemented independently of S03. **Known defects:** callbacks hard-code
`c_ulong` even though SDL uses `size_t` (different on 64-bit Windows); ordinary allocation assumes
`max_align_t` although SDL guarantees only `min(alignof(max_align_t), 2 * sizeof(void *))`;
installing `sdl.allocator` recurses through `SDL_malloc`; and allocation count zero is only an
advisory outstanding-count check while `-1` means unavailable.

- [ ] Put the ordinary-allocation alignment guarantee in the allocator profile/typed plan. Use
      `SDL_malloc` only up to `min(@alignOf(std.c.max_align_t), 2 * @sizeOf(*anyopaque))`; otherwise
      pair `SDL_aligned_alloc` exactly with `SDL_aligned_free`.
- [ ] Limit `remap` to allocations whose pairing remains valid. Return `null` for over-aligned
      allocations so `std.mem.Allocator` performs allocate/copy/free fallback.
- [ ] Verify zero-length allocation and resize behavior against SDL's zero-to-one-byte rule.
- [ ] Derive callback parameter types and calling convention from imported SDL callback typedefs or
      function types. Remove `c_ulong` and unchecked function-pointer casts.
- [ ] Reject direct installation of `sdl.allocator` and add a fixture proving rejection before
      recursion/stack overflow.
- [ ] Document that a backing allocator must be callable from every SDL thread, be process-lifetime,
      and have a context that outlives the process. Non-thread-safe arenas, fixed buffers, and
      caller-scoped stack fallbacks are invalid global backing allocators.
- [ ] Resolve the installation API with fixtures for `-1`, zero, positive, already-installed, and
      recursive backing:
  - [ ] positive outstanding count rejects installation;
  - [ ] `-1` is “check unavailable,” never proof of safety;
  - [ ] zero is advisory and does not prove no previous SDL allocation;
  - [ ] preserve source compatibility for `install` unless evidence requires a split trusted
        first-call API.
- [ ] Ensure callback/OOM failures return `NULL` without unwinding across C. Define a safety-build
      diagnostic for foreign/corrupt allocation headers; silent leaks must not be the only signal.
- [ ] Add compile-time header layout/alignment assertions and checked arithmetic for every
      header/padding/length/calloc multiplication path.
- [ ] Expand `tests/build/fixtures/allocator_bridge/` with C signatures and counters that expose
      wrong widths, alignments, release pairing, copies, zeroing, and failure preservation.
- [ ] Test ordinary/over-aligned allocation, moving remap, remap failure preserving the old block,
      exact free pairing, overflow, OOM, `calloc`, `realloc(NULL, n)`, in-place resize, shrink, and
      move-and-copy.
- [ ] Keep allocator construction owned by the SDL module; companion modules may explicitly use or
      re-export it but must not construct incompatible copies.
- [ ] Compile the fixture for `x86_64-windows-gnu` and every configured analysis target; run it on
      native CI hosts. Native Windows `deno task test:windows-build` is a release gate for the
      `size_t` correction.
- [ ] Exit after the focused allocator test, `deno task test:build`, and applicable target gates
      pass.

### S05 — Prove allocator-generic ownership transformations

- [ ] **S05 complete.** Check only after every S05 task and exit criterion below passes.

**Dependency:** S04. All 50 current allocator-taking wrappers must accept arbitrary
`std.mem.Allocator` implementations. Passing `sdl.allocator` may allocate/copy/free through SDL
twice; that is correct. Do not fold zero-copy adoption into this correctness slice without separate
allocator-identity, ownership, length, alignment, and failure proofs.

- [ ] Add `function_plan` assertions for allocator-first position, hidden C bookkeeping, cleanup
      order, and retention of the allocator in owning results that need `deinit`.
- [ ] Build fake-ABI coverage for one representative of each transformation:
  - [ ] owned sentinel string;
  - [ ] owned byte slice;
  - [ ] count-terminated scalar list;
  - [ ] list of copied strings;
  - [ ] list of copied records containing strings;
  - [ ] owned audio output/result structure; and
  - [ ] owned variadic output such as `asprintf`.
- [ ] Exercise each public signature with `std.testing.allocator`, `sdl.allocator`, a fixed-buffer
      allocator, and a directly constructed `std.heap.stackFallback(N, sdl.allocator)`.
- [ ] For every shape/allocator, verify success, `deinit`/free pairing, and that no SDL-owned
      pointer escapes after return.
- [ ] Fail OOM at every allocation step; prove partial strings, records, buffers, and source SDL
      allocations are released exactly once.
- [ ] Update generated documentation to identify the result owner and required `free`/`deinit`.
- [ ] Exit when no ownership renderer assumes SDL allocation for a caller-owned copy and every
      cleanup-bearing result retains the original allocator. Run `deno task test:bindings` and the
      native fake-ABI fixture.

### S07 — Drive C-format wrappers from declaration attributes

- [ ] **S07 complete.** Check only after every S07 task and exit criterion below passes.

**Dependency:** S03. The current generator guesses scanf via `name.includes("scanf")` and assumes
the format is the last fixed parameter. Replace both guesses with `FormatContract`. Keep the four
annotation macros intentional as standalone names; their applications receive semantic evidence.

- [ ] Add `FormatContract` to function facts/plans and use only zero-based typed indexes after
      analysis.
- [ ] Validate that the annotated format parameter is a compatible narrow/wide string, the
      fixed/variadic boundary matches, and `FUNCV` has the recognized `va_list` shape.
- [ ] Remove the scanf-name heuristic, final-fixed-argument assumption, and equivalent renderer-side
      guesses.
- [ ] Emit actionable errors with C name, header location, dialect, format index, and variadic index
      for incompatible strings, out-of-range indexes, missing varargs, and unsupported `va_list`
      shapes.
- [ ] Preserve direct `std.builtin.VaList` wrappers for `FUNCV`; a Zig tuple cannot portably create
      a `va_list`.
- [ ] Attach semantic evidence from `SDL_PRINTF_VARARG_FUNC`, `SDL_PRINTF_VARARG_FUNCV`,
      `SDL_SCANF_VARARG_FUNC`, and `SDL_SCANF_VARARG_FUNCV` to every pinned application/wrapper.
- [ ] Test all 27 applications, a printf-named scanf declaration, a non-final format parameter, and
      unannotated variadic policy. Prove name and position are irrelevant.
- [ ] Exit after `deno task test:bindings` passes.

### S08 — Complete the supported C-format Zig API and ABI matrix

- [ ] **S08 complete.** Check only after every S08 task and exit criterion below passes.

**Dependency:** S07. This is not a libc formatter. Generated Zig parses comptime C formats only to
validate tuple types/default promotions/mutable destinations, then passes the original format and
arguments to the SDL operation. Retain a convenience wrapper only when it preserves result, side
effects, bounds, allocation ownership, and portable supported-format behavior. Raw ABI or `VaList`
availability alone does not satisfy this gate.

- [ ] Keep the parser in generated Zig support so consumer comptime strings and tuple types are
      checked during consumer compilation. Factor its TypeScript source builder out of `render.ts`
      if helpful, but keep declaration semantics in `function-plan.ts`.
- [ ] Replace ad hoc switches with a table-driven printf/scanf grammar and ABI type model covering:
  - [ ] flags, width, precision, `*` width/precision, and argument order;
  - [ ] positional syntax when SDL supports it, otherwise a precise compile error;
  - [ ] integer lengths `hh`, `h`, default, `l`, `ll`, `j`, `z`, and `t`;
  - [ ] supported floating and long-double behavior;
  - [ ] `%c`, `%s`, `%p`, `%n`, and literal `%%`;
  - [ ] scanf suppression, widths, mutable destinations, and scansets including `^`, leading `]`,
        ranges, empty/malformed sets;
  - [ ] exact scanf pointer type for every length (never map `h`/`hh` or `%n` indiscriminately to
        `*c_int`);
  - [ ] default argument promotion; and
  - [ ] narrow/wide format policy.
- [ ] Add positive/negative Zig consumers with stable diagnostic fragments for argument count,
      promotion, signedness/length, non-sentinel `%s`, immutable scanf output, `%p`, malformed
      format, and unsupported conversions.
- [ ] Back valid cases with C varargs stubs that inspect boundary values, promoted types, argument
      order, and mutable scanf destinations; compilation-only text assertions are insufficient.
- [ ] Exercise at least one SDL logging, error, IOStream, render-debug, and SDL_test declaration
      plus `SDL_snprintf`, `SDL_asprintf`, and `SDL_sscanf` families.
- [ ] Decide eligibility per declaration shape. If a comparable Zig call cannot be proved, retain
      raw access, remove/omit the convenience transformation, and record a limitation or explicit
      compatibility disposition with the reason.
- [ ] Exit when every retained variadic convenience wrapper has a comparable Zig call, supported
      cases compile/run, unsupported cases fail precisely, no case is selected by function name, and
      `FUNCV` stays a direct `VaList` call. Run `deno task test:bindings` and the native format
      fixture.

### S09 — Add Zig-format SDL logging and an opt-in `std.log` backend

- [ ] **S09 complete.** Check only after every S09 task and exit criterion below passes.

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

- [ ] Settle the public name, OOM behavior, and scope mapping using consumer fixtures before locking
      generated docs.
- [ ] Generate a direct entry point beside existing C-format wrappers. Accept SDL category/priority,
      format into caller-local fixed storage, use `std.heap.stackFallback(N, sdl.allocator)` for
      overflow if useful, and create sentinel-terminated UTF-8.
- [ ] Forward only with a fixed C `"%s"` so percent characters in user text are never interpreted.
      Do not append a newline unless the selected SDL output contract requires one.
- [ ] Generate a Zig 0.16.0 `std.Options.logFn`-compatible function; document that only the root
      application can opt in through `std_options`.
- [ ] Map `.debug`, `.info`, `.warn`, `.err` to SDL priorities; map default scope to application and
      prefix named scopes unless fixtures justify a documented alternative. Keep trace, verbose, and
      critical available only through the explicit SDL API.
- [ ] Make format/allocation failure non-recursive and allocation-free. Conservative default: emit
      one fixed diagnostic, never recursively log, panic, or silently truncate the user's message.
- [ ] Add a reentrancy guard for allocation failure and custom SDL output callbacks.
- [ ] Test exact text, percent signs, Unicode/named scopes, all direct categories/priorities, all
      mapped levels, long fallback messages, forced OOM, custom callbacks, multithreaded calls, and
      no recursion.
- [ ] Preserve source compatibility of existing C-format and `VaList` wrappers; record direct and
      backend adapters as additive interoperability without changing the four format-macro inventory
      statuses.
- [ ] Exit after `deno task test:bindings` and the native logging fixture pass.

### S12 — Consume declaration and control-flow attributes

- [ ] **S12 complete.** Check only after every S12 task and exit criterion below passes.

**Dependency:** S03. Land attribute families in independently reviewable commits/sub-slices. Update
`documentation.ts` for presentation and `function-plan.ts` only when call behavior changes. Keep
visibility/ABI at the C import/build boundary. Never turn analyzer advice into a Zig `noreturn`.

- [ ] Implement and test return-flow handling:
  - [ ] `SDL_NORETURN`: map a real `NoReturnAttr` function to Zig `noreturn` at the raw signature or
        wrapper ending in that call; add control-flow and cross-target ABI fixtures.
  - [ ] `SDL_ANALYZER_NORETURN`: preserve the real returning type of `SDL_ReportAssertion`; record
        analyzer metadata for assertion planning/docs only.
- [ ] Implement and test user-facing metadata:
  - [ ] `SDL_DEPRECATED`: combine `DeprecatedAttr` and Doxygen text into prominent docs with a
        replacement link when available; Zig 0.16.0 has no warning-only declaration attribute, so do
        not turn compatibility into an error.
  - [ ] `SDL_NODISCARD`: record result-use intent and document it; do not manufacture a call-site
        warning Zig cannot express. Keep revalidation evidence for future Zig upgrades.
- [ ] Implement and test linkage/inlining/unused semantics:
  - [ ] `SDL_DECLSPEC`: prove imported/exported ABI, calling convention, and linker visibility
        across targets. Convenience wrappers are ordinary Zig `pub`, not exported SDL symbols.
  - [ ] `SDL_FORCE_INLINE`: treat static body availability as the contract; use Zig `inline fn` only
        when translation/performance/comptime semantics require it. Prove header-only rect, endian,
        bit, and overflow helpers remain callable without an SDL linker symbol.
  - [ ] `SDL_INLINE`: record a hint but normally let Zig optimize; semantic `inline fn` is stronger
        than the C hint. Audit the generator's existing broad `inline fn` use separately.
  - [ ] `SDL_UNUSED`: use unnamed parameters or `_ = value` in generated implementations only; no
        consumer-facing declaration.
- [ ] Record no-code semantics:
  - [ ] `SDL_FALLTHROUGH`: translated switch bodies combine cases/share a labeled block; Zig does
        not fall through and needs no standalone declaration.
  - [ ] `SDL_RESTRICT`: retain only validation metadata that can detect contradictory generated
        promises; expose no runtime aliasing guarantee.
  - [ ] unused capability definitions from R01: explicit unrepresentable records, no dead normalized
        capability subsystem.
- [ ] Use a synthetic fixture for every row, target-specific declspec spellings, future applied
      deprecation/nodiscard, and a real `NoReturnAttr` versus `AnalyzerNoReturnAttr` distinction.
- [ ] Prove every applied attribute is normalized and either consumed or explicitly ignored with a
      reason; forced-inline helpers retain one-evaluation/caller-location behavior; linkage remains
      valid.
- [ ] Exit after `deno task test:bindings`, `deno task test:build`, and applicable platform linkage
      tasks pass.

### S13 — Gate additive SDL assertion integration on proof

- [ ] **S13 complete.** Check only after every S13 task and exit criterion below passes, whether the
      gated prototype is accepted or rejected with full evidence.

**Dependency:** S12. This adapter is only for consumers needing SDL handlers, retry/break/ignore,
trigger counts, and retained report data; ordinary invariants should keep using Zig assertions. The
six direct exclusions remain `SDL_assert`, `SDL_assert_release`, `SDL_assert_paranoid`,
`SDL_assert_always`, `SDL_enabled_assert`, and `SDL_disabled_assert`. A bool-taking function cannot
suppress evaluation at disabled levels or recover source token spelling, and raw
`SDL_ReportAssertion` is unsafe because SDL retains `SDL_AssertData` in its report list.

Candidate call pattern:

```zig
if (comptime sdl.assert.isEnabled(.debug)) {
    sdl.assert.check(@src(), "connection != null", connection != null);
}
sdl.assert.checkAlways(@src(), "connection != null", connection != null);
```

- [ ] Derive `.release`, `.debug`, and `.paranoid` enablement from imported `SDL_ASSERT_LEVEL`.
- [ ] Accept `@src()` and an explicit comptime sentinel condition description.
- [ ] Prototype stable, independent per-call-site `SDL_AssertData` storage using comptime source and
      condition parameters. Never expose temporary/stack-backed data to SDL's persistent report
      list.
- [ ] Reproduce `SDL_enabled_assert` behavior: retry loop, break, ignore, always-ignore, trigger
      count, custom handler, persistent report linkage, function/file/line, and abort.
- [ ] Preserve `SDL_ReportAssertion`'s returning type despite analyzer-only metadata.
- [ ] Prove disabled conditions are not evaluated, including an expression with observable side
      effects. Do not expose `disabledAssert(condition: bool)`.
- [ ] Run break and abort cases only in subprocess-safe fixtures.
- [ ] Test enabled/disabled levels, retry, break, abort, ignore, always-ignore, custom handlers,
      report reset/linkage, exact source fields, repeated trigger counts, stable independent sites,
      and concurrent calls.
- [ ] Add the public API and additive coverage relation only after all mandatory fixtures pass.
- [ ] If static lifetime, independence, thread safety, or compile-time elision cannot be proved on
      pinned Zig, discard the public prototype and record all six macros as
      intentional/unrepresentable with a concise failed-proof summary.
- [ ] Exit after the accepted facility or rejected disposition is fully recorded, then run
      `deno task test:bindings`, the native assertion fixture, and every configured target compile
      gate because static storage/breakpoint behavior is target-sensitive.

### S14 — Finish allocation metadata and every explicit no-code exclusion

- [ ] **S14 complete.** Check only after every S14 task and exit criterion below passes.

**Dependency:** S03. This slice closes semantic consistency checks and makes “no code” a tested,
source-located disposition rather than a prose bucket.

- [ ] Cross-check applications of `SDL_MALLOC`, `SDL_ALIGNED`, `SDL_ALLOC_SIZE`, and
      `SDL_ALLOC_SIZE2` against allocator profiles, size parameters, ownership docs, overflow
      planning, record/field alignment, and release functions. Never infer ownership from
      `SDL_MALLOC` alone.
- [ ] Fail contradictory configured allocator/release/size contracts with C declaration and source
      location; add synthetic contradiction fixtures.
- [ ] Finish `SDL_RESTRICT` consistency handling without exposing a Zig aliasing promise.
- [ ] Record each `SDL_HAS_BUILTIN` application by the operation selected, not as a public
      `hasBuiltin("name")` query:
  - [ ] retain target-tested breakpoint/trap and byte-swap helpers;
  - [ ] retain checked add/multiply wrappers;
  - [ ] audit compiler/CPU fence fallback against Zig atomic primitives and preserve documented
        ordering;
  - [ ] use `@prefetch` only if a public SDL semantic operation needs it (current uses are
        internal).
- [ ] Keep `SDL_STRINGIFY_ARG` intentional/unrepresentable: Zig can accept explicit comptime strings
      and expose `@tagName`/`@typeName`, but cannot recover original caller token spelling after
      parsing. Do not add `stringify(value)`.
- [ ] Keep the full ELF-note family intentional/unrepresentable unless this package itself starts
      building an object that needs a note: `SDL_DLNOTE_JOIN`, `SDL_DLNOTE_JOIN2`,
      `SDL_DLNOTE_JSON_ARRAY`, `SDL_DLNOTE_JSON_ARRAY_GET`, `SDL_DLNOTE_JSON_ARRAY1`,
      `SDL_DLNOTE_JSON_ARRAY2`, `SDL_DLNOTE_JSON_ARRAY3`, `SDL_DLNOTE_JSON_ARRAY4`,
      `SDL_DLNOTE_JSON_ARRAY5`, `SDL_DLNOTE_JSON_ARRAY6`, `SDL_DLNOTE_JSON_ARRAY7`,
      `SDL_DLNOTE_JSON_ARRAY8`, `SDL_ELF_NOTE_DLOPEN`, `SDL_ELF_NOTE_INTERNAL`, and
      `SDL_ELF_NOTE_INTERNAL2`.
- [ ] If an actual package object later needs an ELF note, split a new Linux-only build-integration
      slice that emits exact section/name/header/alignment/owner/type/JSON/visibility and inspects
      the final object/archive with an ELF reader. Keep it outside `src/sdl.zig` and direct API
      coverage.
- [ ] Confirm R01 capability macros and R02 stack macros have explicit no-code/native-Zig evidence,
      not pending implementation relations.
- [ ] Prove every real allocation/optimizer application is consumed or explicitly non-actionable and
      no test-only public API was added to improve coverage.
- [ ] Exit after `deno task test:bindings` passes.

### S15 — Integrate, audit all 65 exclusions, and prepare the release result

- [ ] **S15 complete.** Check only after every S15 task and release exit criterion below passes.

**Dependency:** every active slice above plus a recorded accepted/rejected S13 result. R01-R03 are
already resolved and are not implementation blockers. Do not increment a binding revision merely for
planning or unreleased intermediate work.

- [ ] Run `deno task fetch`; confirm verified inputs match `mise.sdl.toml`.
- [ ] Run `deno task generate`; inspect the complete diff for all eight generated binding modules,
      `sdl_metadata.zig`, and generated `COVERAGE.md`.
- [ ] Confirm every generated file retains its do-not-edit header and a second generation is
      byte-identical.
- [ ] Reconcile the exact 65-entry inventory with no orphan declaration application:
  - [ ] 20 capability/thread-analysis macros -> R01 unrepresentable/native `defer` disposition;
  - [ ] two stack macros -> R02 unrepresentable/`std.heap.stackFallback` disposition;
  - [ ] four format macros -> S07/S08 semantic application evidence;
  - [ ] two thread hooks (`SDL_BeginThreadFunction`, `SDL_EndThreadFunction`) -> indirect wrapper
        evidence for both create-thread transformations, compiled on Windows and Linux, with no new
        public hook names;
  - [ ] six assertion macros -> S13 accepted additive facility or recorded rejection;
  - [ ] nine declaration/control-flow macros -> S12 semantic/unrepresentable evidence;
  - [ ] five allocation/alias annotations -> S14 validation/unrepresentable evidence;
  - [ ] `SDL_HAS_BUILTIN` -> S14 operation-specific evidence;
  - [ ] `SDL_STRINGIFY_ARG` -> S14 unrepresentable evidence; and
  - [ ] 15 ELF-note helpers -> S14 unrepresentable/build-integration-only evidence.
- [ ] Verify every coverage relation endpoint exists, every current declaration application is
      consumed or explicitly rejected, and no indirect/semantic/additive relation lowered the direct
      intentional count.
- [ ] Audit public API compatibility: no unexplained raw declaration/wrapper removal, ownership
      contract change, generated limitation, target variation, or irreproducible diff.
- [ ] Record allocator ownership/cleanup/return-flow corrections and other consumer-visible behavior
      changes in release notes even when the Zig signature is unchanged.
- [ ] Run the full validation matrix below and record unavailable host-only commands. S15 remains
      unchecked until required CI gates report success.
- [ ] Run `deno task release-check`; inspect documentation and the release archive/reproduction
      result.
- [ ] If and only if publishing a binding-only fix on unchanged SDL 3.4.12, follow the repository's
      `prepare-release` workflow, increment `scripts/sdl-release.ts` once, and regenerate metadata
      as one reviewed unit.

## Universal per-slice completion audit

Before checking any active slice, verify every applicable item below. These are requirements, not
suggestions; copy relevant evidence into the slice's change description.

- [ ] Upstream declaration and documentation evidence is captured in a focused test.
- [ ] The earliest semantic stage owns the rule; no renderer-side C-name exception substitutes for
      typed metadata.
- [ ] Unsupported or contradictory shapes fail with actionable C name/source location.
- [ ] Generated output is deterministic and retains do-not-edit headers.
- [ ] All configured libraries regenerate byte-identically after the intended update.
- [ ] Public docs state ownership, lifetime, thread safety, errors, and direct-versus-additive
      status wherever relevant.
- [ ] Positive and negative compile fixtures cover the consumer contract and stable diagnostics.
- [ ] ABI-sensitive behavior compiles across every applicable configured target.
- [ ] Native runtime behavior is tested where cross-compilation cannot prove it.
- [ ] Coverage inventory and handling relations match the actual generated surface.
- [ ] No release-specific function-name exception remains where a generic semantic rule works.
- [ ] The focused tests, `deno task fmt`, `deno task typecheck`, `deno task test:bindings`,
      applicable platform gates, and `deno task check` pass before the slice lands.

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
