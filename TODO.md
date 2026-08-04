# SDL3 for Zig TODO

This list was audited against SDL 3.4.12 / package revision 9 and the verified trees in
`mise.sdl.toml`. Correctness is measured solely against upstream SDL-family headers and
documentation plus this repository's declared generation, build, and release contracts.

Only unresolved work remains below. A checked item, rejected proposal, or statement that merely
describes current behavior does not belong in this file.

## Cross-cutting generator and test policy

These rules apply to every task below:

- Treat binding work as translation-policy maintenance. Tests should describe recurring SDL-family
  declaration and documentation patterns with small synthetic headers/fixtures, then validate that
  the same rule holds across the public declarations discovered from the current pinned headers. Do
  not make a checked-in list of one SDL release's expected Zig symbols, names, types, or counts the
  primary oracle.
- Derive release-result expectations from the inputs under test: parsed headers, documentation,
  target metadata, and the independent coverage ledger. Exact versions, revisions, hashes, archive
  members, and byte-for-byte generated drift remain valid acquisition, reproducibility, and release
  invariants. They must not substitute for testing the generic rule that produced the bindings.
- Updating an SDL-family pin should require regeneration and review, but no test-source edits when
  the new headers use already-supported patterns. A new or ambiguous upstream shape should fail with
  enough evidence to add one conservative generator rule and one reusable pattern fixture; avoid
  release-specific symbol allowlists and exceptions.
- Generate the complete supported surface and rely on Zig's lazy analysis plus target gates to keep
  unused or unavailable declarations out of consumer binaries. Do not omit public declarations or
  split inputs merely to imitate C preprocessing or reduce the apparent size of generated source.
- Generate ergonomic and high-level adapters whenever their ownership, allocation, failure,
  callback, or namespace behavior can be established from repeatable header and documentation
  evidence. Hand-written wrappers are acceptable only when the policy cannot be derived safely; keep
  them separate from generated ABI modules, document why generation is impractical, and preserve raw
  access.

## P0 — prove generated API correctness and completeness

- [x] **Fix public record field types and versioned interface descriptors.** The C fields in
      `SDL_IOStreamInterface`, `SDL_StorageInterface`, `SDL_VirtualJoystickDesc`, and
      `TTF_TextEngine` are nullable function pointers, but the committed bindings render all 27 as
      `?**const fn`; `src/{sdl,ttf}.zig` size/alignment/offset checks cannot distinguish this from a
      single pointer. Public C `void *` record fields also render as `?*void` instead of
      `?*anyopaque`. Correct the generic pointer/type analysis, then generate ABI-checked
      `init`/`default` helpers equivalent to `SDL_INIT_INTERFACE`: zero every field and set
      `version` to the target C `sizeof` value. Regress the nullable-function-pointer,
      opaque-pointer, and versioned-interface patterns with neutral synthetic declarations; use the
      named SDL interfaces as header-discovered release validation rather than as the test's fixed
      symbol list. Compile and run representative generated interfaces on every supported target.

- [x] **Build an independent upstream API coverage ledger.** Extract functions, typedefs, records,
      enums, callbacks, documented macros, and public inline functions directly from Doxygen XML and
      public-header/preprocessor evidence in a checker that does not reuse generator analysis,
      planning, naming, or rendered Zig output as its oracle. Record each stable upstream source
      identity as generated, available through `.c`, manually ported with justification, or
      intentionally excluded with a reason and target set. Gate a previously covered declaration
      becoming missing/excluded or changing translation class without review; route ordinary new
      declarations through existing rules and report only unsupported patterns. Do not assert a
      release's Zig spellings, types, or symbol count. Emit the reviewed ledger and input revisions
      as release evidence, not as a package-manager manifest.

- [x] **Validate semantic translation rules independently of the generated API snapshot.** Cover
      pointer depth, constness, nullability, sentinel strings, arrays/counts, callbacks, return and
      error conventions, borrowed/owned handles, allocation/cleanup pairs, callback lifetime,
      namespaces, and target availability with neutral header+Doxygen fixtures whose expected Zig
      semantics are reviewed directly. Use C ABI and runtime probes where Zig size/alignment checks
      cannot prove equivalence. Apply those rules across ledger entries to detect unhandled shapes,
      but never derive the expected answer from the current generated declaration. Preserve exact
      `.c` access when an ergonomic transformation loses information or its semantics cannot be
      inferred safely.

- [x] **Cover standalone SDL public headers and compile-time revision metadata.** The configured
      core translation includes only `SDL3/SDL.h`, whose umbrella excludes `SDL_main.h`,
      `SDL_vulkan.h`, and `SDL_revision.h`. Provide generated profiles or deliberate separate
      modules for `SDL_RunApp`, `SDL_SetMainReady`, `SDL_EnterAppMainCallbacks`, and the
      `SDL_Vulkan_*` APIs with explicit platform/Vulkan type policy. Preserve the pinned header
      `SDL_REVISION` value in generated metadata separately from `sdl.version.getRevision()`, which
      reports the linked runtime. Test ordinary main, callback-main, representative Vulkan calls,
      and the compile-time revision value on supported targets. Make header inclusion and symbol
      coverage ledger-driven so a later release can add or remove standalone public declarations
      without editing an expected-symbol list. Generate the full supported surface and rely on Zig's
      lazy analysis rather than C-style input reduction.

- [x] **Expose SDL logical keycode constants through a generic macro-family rule.** The current
      `SDL_keycode.h` defines a large `SDLK_*` object-like macro family, but `src/sdl.zig` exposes
      `Keycode = u32` without its values. Associate constants with an open integer typedef from
      declaration identity, documented type, and value shape; do not encode the current member count
      or names in generator policy. Test printable, expression-derived, keypad, media, extended, and
      collision-prone patterns with a synthetic family, then compare the generated release family
      exhaustively with the pinned header-derived inventory.

- [x] **Preserve documented public macro/inline helpers and reject implementation artifacts.** Model
      documented helpers by header identity before preprocessing substitutes their bodies. Cover
      endian conversion, pixel/colorspace and audio-format inspection, time conversion, mouse masks,
      window positions, surface locking, keycode construction, version packing, and similar public
      families discovered in each pinned header; this list is illustrative, not a fixed API
      snapshot. Reject compiler and private helper names unless a profile explicitly admits them:
      the committed core currently leaks `builtinBswap32`, `builtinClz`, zero-argument overflow
      builtins, and private `SDL_size_*_check_overflow_builtin` functions. Verify retained helper
      values and single evaluation through reusable macro-shape fixtures on every generator target.
      Prefer generated zero-runtime-cost `inline`/`comptime` Zig equivalents. When a macro's public
      semantics cannot be recovered safely enough to automate, allow a small traced manual port with
      a focused fixture instead of exposing the preprocessor artifact.

- [x] **Handle public function-like API macros with ABI-sensitive behavior.** Provide target-correct
      Zig entry points for the documented `SDL_CreateThread` and `SDL_CreateThreadWithProperties`
      macros without exposing their runtime-hook entry points as the preferred API. Preserve the
      Windows C-runtime begin/end hooks for GNU and MSVC. Also expose the documented
      `SDL_AtomicIncRef` and `SDL_AtomicDecRef` semantics. Test creation, waiting, and
      reference-count transitions on Linux, macOS, Windows GNU, and Windows MSVC. Regress the
      documented-macro-to-runtime-hook and atomic-expression shapes generically; treat these names
      as current release witnesses, not as a complete function-like-macro allowlist. Keep platform
      branches target-gated and rely on Zig lazy analysis instead of omitting APIs globally.

- [x] **Make variadic and `va_list` APIs target-correct.** The universal core module currently
      embeds the SysV x86_64 `va_list` register-save struct in `logMessageV`, `error_.setV`, IO, and
      `v*printf`/`v*scanf` wrappers, although Windows and macOS AArch64 use different ABIs. Define a
      per-target policy: keep exact C variadic and `va_list` declarations target-correct under `.c`,
      and omit `va_list` from the ergonomic layer unless Zig can represent it correctly for the
      consumer target. Generate Zig-idiomatic formatting, reader/writer, or typed-tuple adapters
      when the documented behavior permits them; do not merely forward arbitrary `anytype` values to
      C. Enforce C default promotions and sentinel format strings at any retained C-varargs
      boundary, and test integer, floating-point, pointer, and string arguments on Linux, macOS,
      Windows GNU, and Windows MSVC. Generation must fail if one analysis target's `va_list`
      representation leaks into the universal source.

- [x] **Complete typed flag families from header evidence.** The generic packed-flag renderer
      preserves unknown bits for the families it recognizes, but `TTF_FontStyleFlags`,
      `TTF_SubStringFlags`, and `SDLTest_VerboseFlags` remain plain `u32` because their constant
      prefixes do not match the typedef-derived prefix rule. Generalize prefix association from
      declaration and documentation evidence. Use those names as current defect witnesses, while
      testing mismatched prefixes, masks/composites, and integer round trips with generic fixtures
      plus ledger-derived release coverage. Do not turn every integer or enum into a flag wrapper;
      open Zig enums already preserve unknown enum values.

- [x] **Force target-aware public-surface and ABI reachability.** The generator records declaration
      target sets for Linux x86_64, Windows GNU x86_64, and macOS AArch64, and generated records
      have extensive ABI checks. Existing package fixtures also compile all advertised Windows
      prebuilt architectures and both macOS architectures, but they reference only a small sample of
      the generated API. Add a declaration-level reachability harness that forces analysis of every
      public type, callback, constant, and callable signature for each advertised target, including
      every configured module. Use the same target metadata for namespaces and ABI checks, and emit
      an exception report for declarations that are intentionally target-gated. Generate the harness
      from the independent coverage ledger so upstream API additions need no hand-written test
      updates.

## P1 — provide a lossless escape hatch

- [x] **Expose the existing translated C imports under a compact `.c` namespace.** The generated
      modules privately import `sdl3_*_c`, and `build.zig` does not expose those modules to
      consumers. Re-export the target-correct imports rather than maintaining a second declaration
      set. Keep this surface deliberately thin: prove it shares the ergonomic layer's translated
      module and link selection, then let normal compilation cover its topology. Its purpose is
      lossless access when an ergonomic transformation is unavailable or wrong, not another API to
      organize by hand.

## P1 — build, distribution, and platform gates

- [x] **Centralize the supported distribution matrix.** Move component, target, ABI, architecture,
      distribution, linkage, optional-runtime, and source-build support into typed metadata used by
      `build.zig`, generated package metadata, documentation, and tests. The existing fixtures
      already cover Windows GNU x86/x86_64, Windows MSVC x86/x86_64/AArch64, and macOS
      x86_64/AArch64 prebuilts; retain that coverage and make unsupported combinations derive their
      diagnostics from the same matrix. Record host/SDK-only gates explicitly rather than implying
      they ran everywhere. Remove `.auto`: callers of `addTo` must choose `.none`, `.system`,
      `.prebuilt`, or `.source` explicitly, and the repository's top-level build must use one
      documented non-host-switching default.

- [x] **Constrain system libraries to compatible API baselines.** `.system` exposes the pinned
      headers but currently calls `linkSystemLibrary` without checking a discovered version. Put
      each component's minimum compatible version in generated metadata. Enforce it when pkg-config
      metadata is available; define an explicit policy/override for caller-supplied libraries whose
      version cannot be discovered at configure time. Test too-old, matching, newer-compatible,
      missing-metadata, and core/companion mismatch cases for static and shared linkage.

- [x] **Run the existing macOS build suite in CI.** `.github/workflows/ci.yml` has Linux and Windows
      jobs but never schedules `tests/build/macos.test.ts`. Add a macOS runner for source static and
      shared builds plus universal-framework x86_64/AArch64 prebuilt consumers. Report unavailable
      SDK or upstream-artifact limitations in the job output.

- [x] **Test the actual release archive as a clean consumer and prove reproducibility.** Current
      build tests consume a staged release tree, not the `.tar.gz` produced by `package:release`.
      Assemble twice from clean acquisition/build caches, compare generated bindings, metadata,
      staged prebuilts, the coverage ledger, notice inventory, archive member metadata/order,
      SHA-256, and Zig hash, then use `zig fetch` on the archive in a clean project. Exercise
      `.none`, `.system`, `.prebuilt`, and `.source`; for shared builds validate installed names and
      runtime loading.

- [x] **Make the source SDL feature profile explicit and useful.** The generic
      `source_cmake_options` can override defaults because it is appended after repository options,
      so source features are configurable today. The public source API now names the `headless` and
      `desktop` profiles, exposes focused audio/video/GPU/renderer/camera overrides, documents the
      precedence rules, and tests both profile configuration and Linux SDL initialization,
      audio/video/camera drivers, GPU support queries, hidden-window creation, and renderer creation
      through the offscreen driver.

- [x] **Expose and install selected shared source-build runtimes.** Source builds now stage exact
      selected runtime artifacts behind a public `sourceRuntimeArtifact` API and install them into
      the consumer prefix by default, with platform rpaths and an `install_runtime = false` escape
      hatch. Versioned Linux loader files are copied as regular artifacts rather than broken CMake
      symlinks; the clean Linux source consumer installs and runs with no cache library path, and
      the existing macOS/Windows source suites retain their component-specific build/run coverage.

- [x] **Make ControllerImage data an explicit source-build artifact.** Source builds expose the
      generated standard database through `sourceControllerImageDataArtifact` and can install both
      verified-art databases under `share/ControllerImage` with
      `install_controller_image_data = true`; `.system` leaves deployment to the application. Clean
      Linux shared builds generate only from `vendor/ControllerImage/art`, install the data, and
      load it through `addDataFromFile` without a cache-local library path.

- [x] **Close the SDL_shadercross DXC runtime contract.** Bundled and external DXC now validate
      target/architecture pairs before CMake, stage exact `dxcompiler`/`dxil` artifacts for both
      shared and static consumers, expose them through `sourceRuntimeArtifact`, and install them
      with the source runtime step. Source synchronization validates the pinned `mise.sdl.toml` URLs
      and hashes against SDL_shadercross's downloader. A clean Linux static consumer passed HLSL
      generation, HLSL-to-DXIL compilation, runtime loading, and relative-runpath execution. Native
      Windows execution was not available in this WSL workspace and remains a CI follow-up.

- [x] **Test the remaining real source cross-compilation inputs.** The Linux fixture now derives the
      Zig CMake target from the consumer target and cross-compiles an AArch64 static SDL plus
      image/ttf/mixer/net consumer while retaining sysroot and include-directory inputs in every
      component configure. Add the still-uncovered macOS framework/rpath and Windows
      import/runtime-artifact fixtures when their SDKs and runnable validation are available.

## P1 — tests and release quality

- [x] **Make committed generated bindings a checked invariant.** `test:bindings` regenerates all
      configured modules through the existing `outputRoot` option into a temporary directory,
      rejects missing, stale, and unexpected outputs without modifying the worktree, and includes a
      harness regression that perturbs a copied output. The same gate runs through `deno task check`
      and before release-tree assembly. This remains a repository-hygiene check: it proves that
      committed files match the pinned inputs, not that their API is semantically correct.

- [x] **Verify upstream source signatures where they exist.** `mise.sdl.toml` pins the detached
      `.tar.gz.sig` assets for SDL, SDL_image, SDL_ttf, SDL_mixer, and SDL_net; source checks verify
      the exact archive and signature bytes with `gpgv` against the two fingerprint-pinned SDL
      release keys before accepting a cached vendor tree. Isolated regressions cover bad, missing,
      expired, and untrusted signatures, and the README documents key bootstrap and rotation. Other
      release assets retain SHA-256 verification and are not represented as signed when upstream
      publishes no signature.

- [x] **Prove packaged third-party notices are complete.** Release staging derives a sorted notice
      inventory from every copied vendor and prebuilt input, requires the locked source notices and
      ControllerImage art credits, rejects missing or unexpected notice paths, and emits a
      hash-bearing human-readable `THIRD_PARTY_NOTICES` file in the package. Archive member
      validation includes that file; this remains an attribution closure rather than a general SBOM,
      vulnerability, or package-manager metadata system.

- [x] **Add link-and-run subsystem and companion smoke tests.** The Linux source consumer now covers
      SDL initialization, events and offscreen renderer setup, allocation/free, ControllerImage
      data, SDL_image GIF decoding, SDL_shadercross conversion, SDL_ttf initialization, SDL_mixer
      generated-audio mixing, and SDL_net local datagram creation/receive. Hardware-dependent paths
      remain opt-in; the host static and shared source suites execute the functional operations.

- [x] **Declare Zig 0.16.0 as the exact supported consumer version.** `build.zig.zon`, mise, the
      README, CI tool installation, and build fixtures now agree on exactly 0.16.0. The package
      build script rejects other compiler versions with a direct diagnostic; newer Zig versions are
      unsupported until the repository deliberately advances this pin as one reviewed change.

- [x] **Make generated-documentation validation semantic.** Doxygen output is supplemented from the
      original header comments when malformed XML drops a declaration or appends it to a `\sa`
      reference. Category references resolve through generated namespaces, local macro references
      resolve to generated paths or explicit outside-module annotations, and the generated-source
      gate rejects declaration fragments, unresolved category links, bare macro placeholders, and
      generator markers. Synthetic Doxygen and malformed-output fixtures cover the named SDL_image
      and `CategoryTime` defects; `zig build docs` and the binding gate both pass.

- [x] **Assess SDL-family stable releases as one coordinated update.** Inspect only published stable
      releases, never development branches, and stage the selected core and companion pins together
      in an isolated cache. Report independent upstream declarations, unsupported/new translation
      patterns, source/artifact/license closure, and declared component compatibility without
      changing the pinned tree. Prefer one reviewed family update over repeated component-by-
      component churn. The 2026-08-03 audit records SDL 3.4.14 as the only newer stable family
      member and defers the coordinated baseline update; that update must still change
      `mise.sdl.toml`, metadata, vendor cache, bindings, and package artifacts as one coherent unit.

## P2 — evidence-gated target and ergonomics work

- [x] **Prototype Emscripten as one explicit package target.** Add an Emscripten analysis identity
      and consumer-target mapping, then prototype a pinned emsdk compile/link/run fixture with
      callback main, filesystem/preload behavior, JavaScript glue, and HTML/runtime staging. The
      `wasm32-emscripten` target now drives dedicated binding analysis and conditional namespaces;
      the source-distribution fixture uses emsdk 6.0.5, compiles SDL with its CMake toolchain,
      stages all four runtime files, and runs the generated JavaScript under Node. The explicit
      support boundary and required sysroot/toolchain options are recorded in
      `EMSCRIPTEN_TARGET.md`; this does not advertise Zig-native-only or prebuilt support.

- [x] **Prototype Android as an application target.** Add Android analysis identities and inventory
      `SDL_system.h`/`SDL_main.h` availability before choosing either verified official AAR/Prefab
      artifacts or a reproducible NDK source path. `ANDROID_TARGET.md` records the selected pinned
      NDK source path and its constraints. The `aarch64-linux-android` fixture compiles the
      generated Android surface, exports `SDL_main`, packages SDL's Java activity shim and a
      verified asset into a Gradle APK, and installs/starts it when `adb` has a device. Missing
      SDK/NDK/JDK inputs name their exact paths; this environment has no executable emulator/device,
      so execution is an explicit skipped diagnostic rather than a claimed device result.

- [x] **Prototype the pinned Apple mobile slices before packaging them.** The pinned SDL-family DMGs
      contain iOS/tvOS device and simulator XCFramework slices, but release staging intentionally
      retains only `macos-arm64_x86_64`. Add distinct analysis identities, public-header
      availability, framework embedding/rpath/signing contracts, compile/link fixtures for every
      retained slice, and a simulator lifecycle smoke test before expanding the archive. Keep
      visionOS out until a verified artifact or source path exists.

- [x] **Offer a narrow shader build helper only after the shadercross runtime contract is stable.**
      `scripts/build-shaders.ts` and `examples/shaders/manifest.json` provide an opt-in workflow for
      checked-in GLSL, HLSL, and Zig-exported graphics and compute shader source. Each entry emits
      SPIR-V, DXIL, MSL, and shadercross reflection JSON plus stable SHA-256 metadata; repeated-tool
      runs are compared byte-for-byte when `SDL_SHADERCROSS` and `GLSLANG_VALIDATOR` are supplied.
      Focused tests cover safe manifest validation, actionable missing-tool diagnostics, and an
      optional host-runner gate. The `sdl-shader-device-load` example creates and releases one
      SDL_GPU shader for each retained SPIR-V, DXIL, or MSL format; execution remains host/backend
      opt-in because this WSL workspace has no SDL3 runtime or GPU.

- [x] **Offer a tested `std.mem.Allocator` bridge only with explicit global-lifetime rules.** The
      generated core surface now exposes `AllocatorBridge`, which must be installed before any SDL
      call, borrows the backing allocator for process lifetime, rejects tracked pre-existing
      allocations, and rejects replacement or teardown. Its header preserves C maximum alignment and
      exact backing spans across realloc/free; the fake-ABI fixture covers calloc zeroing, realloc
      copy/free pairing, failed-realloc preservation, alignment, and late-install rejection.

- [x] **Publish generated API documentation through GitHub Pages after the coverage and target
      contracts stabilize.** `scripts/package-documentation.ts` packages docs from an exact tag and
      commit, links each ergonomic module to its generated C header path and pinned upstream header
      and symbol search, and writes a content- and coverage-hashed manifest. The release-only
      `.github/workflows/documentation-pages.yml` retains existing version directories, publishes an
      immutable `v3.4.12+N` path plus `latest/`, and deploys only the already-validated artifact;
      local-link, coverage-ledger, version, commit, and post-download content mismatch checks are
      publication gates. Pull requests and ordinary CI have no publication trigger.

## Completion criteria

- [x] Updating any pinned SDL-family component whose headers use supported patterns requires no
      edits to test source, expected-symbol lists, or release-specific generator exceptions. Clean
      regeneration is configuration-driven, coverage is derived from pinned headers/Doxygen, and
      documentation references now use generic external C API/macro fallbacks instead of
      release-specific alias tables; the 19-test binding suite and coverage gate pass.
- [x] Every semantic generator rule has a focused pattern fixture, and current-release coverage is
      derived from an independent Doxygen/header ledger rather than generated Zig output or a
      hand-maintained API snapshot. The semantic, function-plan, record, naming, category, target,
      documentation, clean-regeneration, and coverage suites exercise the supported rule families;
      `scripts/api-coverage.ts` parses pinned headers and Doxygen directly and never reads `src/`.
- [x] Every upstream public identity in the independent coverage ledger has a reviewed disposition,
      with zero unexplained losses, exclusions, or translation-class changes across releases.
      Current validation requires a reason for every non-generated identity; `api-coverage.ts diff`
      permits only reviewed additions and rejects removals or disposition/target changes. The
      release-only Pages preparation gate compares each release ledger with the previous tag, while
      the current repository has no earlier tagged ledger and therefore establishes the baseline.
- [x] Every advertised target forces analysis of every public declaration and passes target-gated
      ABI/signature checks. `tests/codegen/target_matrix.test.ts` runs the full configured target
      list against a synthetic public header; clean repository regeneration validates every real
      target model, generated ABI assertions, and target reachability. Android now compiles both
      advertised Android ABIs in its fixture, while Apple, Emscripten, Linux, macOS, and Windows
      fixtures cover their advertised target families when their SDK/toolchain is available.
- [x] Generated drift, clean archive consumption, runtime staging, and two-run reproducibility gates
      pass. `deno task test:release-archive` now passes the generated-drift check, stages the
      runtime-bearing prebuilts, compares two independent archives and their hashes, validates
      archive members, and builds clean archive consumers for the supported distribution modes.
- [x] `.auto` is absent, every distribution choice is explicit, and system libraries are checked
      against the supported API baseline when their version is discoverable. `AddOptions` requires
      an explicit distribution, the top-level build defaults to documented `.none`, and the Linux
      pkg-config fixture passes matching, newer, too-old, missing-metadata, override, static, and
      shared cases.
- [x] Release metadata, versions, input hashes, required third-party notices, generated files, and
      packaged archive contents agree. Metadata and verified-source checks pass; the release gate
      validates generated bindings, required notices, exact archive members, SHA-256/Zig hashes, and
      the package version across two independently staged archives.
- [x] Package metadata, documentation, CI, and fixtures support Zig 0.16.0 exactly. The focused
      `tests/zig-version-contract.test.ts` gate checks the package and generated-metadata inputs,
      exact build-time rejection, mise/CI installation, README contract, every build fixture, and
      the active compiler version.
