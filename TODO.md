# Removal TODO

## Tests and validation machinery to remove

This is an audit of the current 56 top-level tests and the supporting release-validation machinery.
The standard used here is practical: a check should catch a plausible regression in a user-visible
binding, build, package, or runtime path. Merely proving that two repository files say the same
thing, that a helper rejects data produced only by the repository itself, or that an upstream tool
is deterministic is not enough.

Removing an item below must not remove a supported binding, build mode, target, package artifact,
example, or documentation site. Where validation is tangled into a feature, keep the feature and
delete only the policing around it.

### Remove outright

#### 1. The independent API coverage ledger

Remove:

- `scripts/api-coverage.ts`
- `tests/api-coverage.test.ts`
- `api_coverage.json`
- `api_coverage_overrides.json`
- `generate:coverage` and `test:coverage` from `deno.json`
- the two ledger paths from `build.zig.zon` and `scripts/sdl-release.ts`
- coverage hashes, counts, and previous-release comparison from `scripts/package-documentation.ts`,
  `tests/documentation-publication.test.ts`, and `.github/workflows/documentation-pages.yml`

This is the largest low-value subsystem in the repository. The committed ledger is about 2.8 MiB and
nearly 100,000 lines, yet it does not compare the discovered C identities with the generated Zig
declarations. It marks documented declarations as `generated` according to another set of regular
expressions, assigns the configured target list wholesale, and shares Doxygen inputs and repository
configuration with the generator it is meant to check independently. It can be green while the Zig
spelling, type, namespace, or declaration is absent or wrong.

The generated-binding drift check and the semantic generator fixtures are better evidence. Keep
those. If missing API coverage becomes a real problem, add a checker that actually resolves each C
identity to a generated Zig declaration; do not keep a parallel inventory that mostly inventories
headers.

#### 2. Third-party notice and license closure checks

Remove:

- `tests/third-party-notices.test.ts`
- `validateNoticeInventory`, `requiredNoticePaths`, and the hash inventory in
  `scripts/third-party-notices.ts`
- notice-path collection and fail-closed notice accounting in `scripts/package-release.ts`
- license-presence checks in `scripts/sync-sources.ts`
- license literals from the exact optional-runtime metadata test in `tests/package-release.test.ts`
- the notice test from `test:build` and `test:macos-build`

Keep the repository `LICENSE` and keep copying upstream trees and runtime payloads, including any
license files already present in those inputs. The useless part is making release success depend on
a closed, hand-maintained inventory of notice filenames and hashes. A new harmless `NOTICE` file is
currently treated as an error, while the test proves only that the validator rejects the examples
written into the test.

`THIRD_PARTY_NOTICES` may remain as a best-effort generated index if desired, but it should not be a
release gate. Removing it entirely would also be reasonable because it is not needed to consume the
package.

#### 3. Package-release self-validation tests

Delete `tests/package-release.test.ts`. Every test in it is low-value:

- `release staging rejects local source-build roots` tests a private directory-name filter.
- `release archive validation requires an exact, safe package member set` validates an archive the
  repository itself just created. Its negative `assertRejects` is also not awaited, so the test does
  not reliably wait for the assertion.
- `release archive validation checks a real tarball against its staged tree` tests `tar` plus the
  same member-list helper.
- `source-only modules and their source assets are packaged without prebuilt staging` restates
  `scripts/sdl-release.ts` and even checks for a credits file.
- `SDL3_test shares SDL3's verified vendor tree` restates one `vendorId` literal.
- `package metadata declares every official optional Windows runtime artifact` duplicates the DLL
  and license arrays from production metadata.
- `distribution policy accepts every packaged target and rejects matrix gaps` derives expected
  acceptance from `prebuiltTargets` and compares it with a lookup over `prebuiltTargets`; it is a
  tautology. The remaining assertions duplicate literals from `scripts/distribution-policy.ts`.

Keep a single clean archive consumer that fetches the produced tarball and builds the supported
distribution modes. That tests the package boundary users care about.

#### 4. Exact Zig-version consistency policing and the exact-version rejection

Remove `tests/zig-version-contract.test.ts` and `test:zig-version`. It searches repository text for
the same `0.16.0` literal in manifests, scripts, README prose, CI, and fixtures. This does not test
compatibility; it tests coordinated search-and-replace.

Also remove `requireSupportedZigVersion` from `build.zig`. Rejecting every newer patch or minor
version removes compatibility rather than providing a feature. Keep the tool version pinned in
`mise.toml`, keep CI on that version, and keep `.minimum_zig_version` in `build.zig.zon`. Actual
consumer builds are sufficient evidence for the supported version.

#### 5. Documentation artifact integrity framework

Remove:

- `tests/documentation-publication.test.ts`
- content and coverage hashes, identity counts, immutable-manifest validation, and local-link
  policing from `scripts/package-documentation.ts`
- the second checkout and post-download validation pass in
  `.github/workflows/documentation-pages.yml`

Keep generating and deploying versioned docs and `latest/`. GitHub already transports the exact
artifact uploaded by the prepare job, and the workflow can fail naturally if docs generation or
deployment fails. A custom manifest, a second checkout of validation code, and tests that tamper
with a temporary directory do not make the API docs more correct.

#### 6. Generated-documentation regex gate and release-specific snapshot assertions

Remove:

- `scripts/check-generated-documentation.ts`
- `generated documentation validation rejects malformed reference shapes`
- `generated bindings retain recovered SDL_image documentation`
- the call to `validateGeneratedDocumentation` from `scripts/check-generated-bindings.ts`

The four regexes recognize four defects named in the completed TODO, not a general documentation
contract. The SDL_image test then searches committed generated files for exact current-release prose
and symbols. Keep the neutral Doxygen parsing and corruption-recovery fixtures in
`tests/codegen/documentation_validation.test.ts`, and keep `zig build docs`; those exercise the
actual documentation path without freezing one release's wording.

#### 7. Synthetic source-signature test, and preferably the detached-signature subsystem

At minimum, delete `tests/source-signatures.test.ts`. It spends over 100 lines generating temporary
GPG keys to prove that `gpgv` rejects bad, missing, expired, and untrusted signatures. The
repository wrapper is only a small command invocation and status check; most behavior under test
belongs to GnuPG.

The stronger simplification is to remove `scripts/source-signature.ts`, the signature artifacts and
key fingerprints, and `verifyPinnedSourceSignatures` from `scripts/sync-sources.ts`. Every source
archive is already pinned by SHA-256. The signature layer adds keyserver availability, key rotation,
GPG tooling, and a second download path without improving reproducibility. Keep SHA-256
verification.

#### 8. Exact two-run release reproducibility

Prune `scripts/release-repro.ts` so it packages once, runs `zig fetch`, and builds clean consumers.
Remove:

- the second full package assembly
- byte-for-byte archive and sidecar comparison
- extraction of both archives and recursive tree comparison
- the extra archive member validation pass

The tar command already fixes order, time, owner, group, and PAX metadata. Running the entire
acquisition, prebuilt staging, generation, and packaging path twice mostly doubles the slowest gate.
A clean consumer catches material packaging failures. If deterministic archives are important for a
release, compare two archives in the release procedure, not in every ordinary repository check.

#### 9. Synthetic target-matrix loop test

Delete `tests/codegen/target_matrix.test.ts`. It gives every configured target the same trivial
header and verifies that `analyzeTargets` returned one model per input target. It does not exercise
a target-specific declaration, ABI difference, conditional namespace, or consumer target. Real
regeneration already analyzes the configured targets, and the platform consumers exercise the
meaningful differences.

#### 10. The negative self-test inside the generated drift test

Keep `committed generated bindings match a clean regeneration`, but remove the part that appends
`// drift` to a temporary output and asserts that the equality helper reports a difference. Directly
comparing regenerated output with committed output is valuable; testing that unequal strings are
unequal is not.

#### 11. Shader tool determinism test

Remove `shader helper produces stable metadata when the pinned tools are supplied` from
`tests/shader-build.test.ts`. It runs the full external shader toolchain twice and byte-compares 24
outputs. Determinism of glslang and shadercross is not a feature this repository implements, and the
test is skipped unless manually configured anyway.

Keep manifest parsing, actionable missing-tool errors, and the SDL_GPU load test. Those cover the
helper's own behavior and whether its output is usable.

#### 12. Completed planning and point-in-time audit files

Remove `TODO.md` and `SDL_FAMILY_RELEASE_AUDIT.md`. `TODO.md` contains 41 checked items and no
unchecked work. It is now a long retrospective specification that encourages preserving every proof
invented to close it. `SDL_FAMILY_RELEASE_AUDIT.md` is a dated snapshot that becomes stale as soon
as upstream publishes another release. Release history belongs in commits, tags, or release notes.

### Prune from otherwise useful tests and workflows

#### 13. Internal cache-layout assertions in platform build tests

In `tests/build/linux.test.ts`, `tests/build/macos.test.ts`, and `tests/build/windows.test.ts`,
remove the `Deno.stat` checks for private cache paths such as `sdl3-source/lib`,
`sdl3-source-build/ControllerImage`, and the private shadercross executable. A successful consumer
link/run and checks for installed public artifacts already prove that the build produced what was
needed. Cache directory names are implementation details.

Retain checks for files installed into the consumer prefix when those files are part of a public
runtime-installation feature.

#### 14. Exact upstream CMake-cache defaults

In the Linux source test, remove assertions for upstream defaults that the repository did not
explicitly request, especially `SDLIMAGE_GIF=ON` and the full SDL_mixer WAVE/AIFF/MP3/FLAC setting
list. They lock the test to upstream's present defaults.

Keep checks for options explicitly supplied by the package API, such as disabling BMP or selecting a
source feature profile, and keep runtime operations that prove enabled features actually work.

#### 15. Duplicate release-specific API witnesses in every consumer fixture

`tests/build/fixtures/distribution_sdl/all.zig` and `tests/build/fixtures/source_all/main.zig`
repeat interface initialization, a list of named APIs, macro values, and dead `if (false)` varargs
calls. These were witnesses for completed TODO defects. Keep each semantic rule in its focused
neutral codegen fixture and use package consumers to import, link, and run representative calls. Do
not repeat the same release-specific symbol checklist in multiple distribution fixtures.

#### 16. Android's synthetic asset assertion

Remove `tests/build/fixtures/android/assets/android-consumer.txt`, its copy step, and the APK member
assertion for that file. It tests SDL's copied Gradle project and Android asset packaging, not these
Zig bindings. Keep both ABI builds, the native library assertion, APK assembly, and optional device
launch.

#### 17. Daily full release-check schedule

Remove the daily `schedule` trigger from `.github/workflows/ci.yml`, or replace it with a much
narrower upstream-release probe. The same pinned inputs and tool versions are rebuilt on every run,
so a daily full source build, documentation build, prebuilt download, and release assembly has
little chance of discovering a repository regression that push and pull-request CI did not already
cover.

#### 18. Source-sync policy checks that duplicate the package manager

Consider removing these from `scripts/sync-sources.ts`:

- `verifySourceArtifactManifest`, which re-parses `mise.sdl.toml` to require fields mise itself uses
- `assertDxcRuntimeDownloaderMatchesMise`, which forces repository pins to match an upstream helper
  script even though the repository intentionally owns its pins
- the recursive `assertNoMiseMetadata` scan after the copy routine already removes extractor
  metadata

Keep checksum verification, exact source-tree synchronization, required headers, and the source
manifest fingerprint. Those directly protect reproducible generation. The checks above mostly
enforce how configuration is written or mirror another input.

#### 19. Exhaustive negative build-diagnostic matrices

The Linux tests enumerate unsupported DXC targets, prebuilt linkage/target combinations, and several
pkg-config failure variants. Keep the underlying diagnostics and one representative negative case
per decision path, but do not test every unsupported tuple or exact message. The positive system,
source, and prebuilt consumers carry much more value, and error wording should be free to improve.

### Keep

The following are not removal candidates because they exercise behavior rather than repository
self-consistency:

- focused semantic generator fixtures for pointers, callbacks, ownership, slices, errors, records,
  flags, naming collisions, and target availability
- clean regeneration compared with committed generated bindings
- allocator bridge ABI/lifetime behavior
- real Linux, macOS, Windows, Android, Apple mobile, and Emscripten compile/link/run consumers
- source, system, prebuilt, and bindings-only distribution consumers
- runtime installation and loader/rpath checks
- SHA-256-pinned acquisition and exact vendor-tree synchronization
- generated package metadata drift against its authoritative inputs
- actual shader compilation/load behavior when the tools and runtime are available
- one clean release archive fetched and consumed as a package

These checks are expensive in places, but they prove supported features. The removals above target
parallel ledgers, literal mirrors, closed-world inventories, internal-layout checks, and repeated
proofs of helpers rather than the features themselves.

## Additional things to remove

This is a second audit, intentionally excluding every candidate already listed in the tests and
validation section above. It covers implementation and repository bloat rather than repeating that
section's test, notice, coverage-ledger, archive, documentation-publication, signature, CI-schedule,
or source-sync recommendations.

The same boundary applies: keep every supported public binding, target, distribution, runtime,
example, and documentation command. Remove validation embedded in shipped code, repeated work, dead
metadata, and point-in-time process narrative. Where a repository-only facility is currently coupled
to the consumer package, separate it instead of deleting the facility.

### Remove outright

#### 1. Generated target-reachability blocks in the shipped bindings

Remove `renderTargetReachability` from `scripts/codegen/render.ts` and regenerate the bindings
without the trailing `// Force target-specific public declarations through Zig's lazy analysis`
blocks.

These blocks currently occupy 22,713 generated lines:

- 18,296 lines in `src/sdl.zig`
- 948 in `src/image.zig`
- 1,207 in `src/ttf.zig`
- 948 in `src/mixer.zig`
- 297 in `src/net.zig`
- 689 in `src/test.zig`
- 143 in `src/controller_image.zig`
- 185 in `src/shadercross.zig`

That is more than a quarter of the roughly 89,000 generated Zig lines. Most of it repeats the same
`_ = root.symbol;` inventory under Android, Emscripten, iOS, Linux, macOS, tvOS, and Windows
conditions even when a companion's surface is identical on every platform. `src/shadercross.zig`,
for example, repeats the same declarations seven times.

This is a test harness embedded in the public source package, not API. Keep target-selected
declarations and namespaces. Actual consumer compilation will analyze declarations a consumer uses;
repository checks can force broader analysis without shipping tens of thousands of inventory lines
to everyone.

#### 2. Consumer-time ABI assertion blocks in generated modules

Stop emitting `renderAbiAssertion` blocks beside every generated enum, record, and union. The
current modules contain about 1,410 `@sizeOf`, `@alignOf`, and `@offsetOf` failure lines comparing
the ergonomic declaration with the translated C import.

These assertions are generator validation paid by every consumer. They substantially enlarge the
public modules, and size/alignment checks cannot detect important semantic mistakes such as pointer
depth, nullability, ownership, or calling convention when the representation happens to have the
same size. Keep ABI correctness, but prove recurring record shapes in focused generator fixtures and
run any exhaustive C probes during repository validation. Do not make the shipped library source
carry the validator.

If a small consumer-side check remains useful, restrict it to records whose layout is deliberately
reconstructed rather than mechanically translated. Emitting checks for every integer-like enum and
ordinary record is not buying proportional confidence.

#### 3. The standalone system package installer

Remove `system_setup.sh` and its invocation from the README. It performs system-wide, privileged,
non-pinned `apt` or `pacman` installs, supports an arbitrary hand-maintained distro list, and is
unrelated to the repository's pinned mise toolchain. It also installs SDL system packages even when
the user wants `.none`, `.prebuilt`, or `.source`.

The `.system` distribution remains supported. Users choosing it can install their platform's SDL
development packages in the same way they install any other native dependency. A root-level script
that runs `sudo apt-get update` is not a binding feature or reproducible setup mechanism.

#### 4. Dead `vendor_id` data in generated Zig metadata

Remove `vendor_id` from the generated `Library` struct and entries in `sdl_metadata.zig`, and stop
rendering it in `scripts/sync-package-metadata.ts`. `build.zig` never reads the field. The
TypeScript release model may keep `vendorId`, where it is used to choose source directories during
packaging; copying it into Zig creates dead package metadata.

#### 5. README self-credit and exact inventory trivia

Remove the sentence saying that Codex helped build the generator. It does not help users or
maintainers understand the package and will age poorly.

Also remove exact prose counts such as “38 SDL example ports and 24 selected 2D raylib-derived
ports.” The authoritative inventory is already the `examples` table in `examples/build.zig`; a
manually synchronized count adds nothing. Keep the example commands and link to the inventory.

### Decouple rather than delete

#### 6. Repository-only docs and examples from the dependency build graph

The primary `build(b)` function always constructs:

- a documentation object importing all eight modules
- generated façade options enabling every companion for docs
- the docs install step
- every example executable, install step, and run step through `example_build.add`

This happens whenever Zig evaluates the package build, including when the package is only a
dependency and none of those steps can be requested from the consuming project. The example helper
alone declares more than 60 executables and matching run steps.

Move repository-only docs and examples to a separate maintenance build file or task. Preserve
`zig build docs`, `zig build examples`, the individual example steps, and all example sources; the
point is to stop constructing their graph as part of the library dependency. Once decoupled,
`build.zig` should no longer import `examples/build.zig`.

The release package also need not carry the entire example tree merely because the consumer build
script imports it. Keep examples in the repository or publish them as a separate optional archive
instead of making them part of every library dependency payload.

#### 7. Acquisition and code generation hidden inside package assembly

`stageReleaseTree` currently calls both `ensureVendoredSources` and
`assertRepositoryBindingsCurrent` before it copies files. As a result, packaging may download
artifacts, mutate the ignored vendor cache, invoke Doxygen/CastXML/Clang/Zig, and regenerate a full
temporary binding tree.

Those are separate workflow phases. `release-check` already acquires sources and runs the binding
drift gate before release assembly. Make `package:release` a read-only assembly operation over
prepared inputs, with a direct missing-input error when prerequisites were skipped. Preserve
`fetch`, `generate`, and the generated-drift check as explicit commands; remove their implicit rerun
from packaging.

This makes failures attributable and avoids repeating the most expensive maintenance work after it
has already passed.

#### 8. Platform prototype files as environment diaries

Keep stable target documentation, but remove the point-in-time workstation narrative from
`ANDROID_TARGET.md`, `APPLE_MOBILE_TARGET.md`, and `EMSCRIPTEN_TARGET.md`. Examples include:

- the current WSL host lacking `libnss3.so`
- `adb devices` having no connected device
- a statement that a particular checkout cannot claim a macOS gate passed
- “prototype” and “current environment” status that is already superseded by CI configuration

Replace the three completion reports with a concise target support table and per-target
prerequisites and commands. Target support is a feature; anecdotes about the machine on which the
TODO was closed are not.

### Simplify dubious generator policing

#### 9. Line-oriented documentation adjacency checks in `validateGeneratedSource`

Remove the loop in `scripts/codegen/generator.ts` that parses rendered Zig with regular expressions
and requires a `///` line immediately before every public declaration while forbidding comments on
forwarding aliases.

It does not establish useful documentation: a generic one-line comment passes, good documentation
separated by an attribute can fail, and the parser understands only a narrow declaration spelling.
The renderer already owns comment placement, and Zig's documentation build is the real parser.

This is separate from the generated-documentation validator discussed in the tests and validation
section above. That validator scans for four historical corruption patterns; this check is a second,
independent source-text linter inside the generator. Keep the small guards that prevent public
`[*c]` pointers or private support-module types from escaping if those still catch real generator
mistakes.

#### 10. Import-time validation of a static typed codegen configuration

Remove or sharply reduce `validateCodegenConfiguration` in `scripts/codegen/config.ts`. The module
constructs one repository-owned, typed constant and immediately walks it to check nonempty strings,
nonempty arrays, duplicate IDs, a regular expression over defines, and dependency ordering.

Most invalid edits already fail at the exact use site with a clearer error: missing dependency APIs,
missing headers, failed analysis, or duplicate generated modules. The validator is not protecting an
external configuration boundary. At most retain dependency topological-order validation, which is
not otherwise encoded by TypeScript; the generic “invalid or duplicated” policy checks are ceremony
around a static literal.

#### 11. Duplicate Android analysis identity

Collapse the two Android generator targets in `scripts/codegen/config.ts` into one Android analysis
identity while retaining both advertised consumer ABIs.

Today `aarch64-linux-android21` and `x86_64-linux-android21` are not actually analyzed with their
respective ABIs. `compilerTarget` maps every Android target to `x86_64-linux-gnu`, and
`targetIdentityArguments` supplies the same Android macros for both. Neither target creates
architecture-specific support headers. The generator therefore runs CastXML and two Clang
preprocessor passes twice over equivalent inputs solely to attach two different target strings to
the same declarations.

This does not mean dropping x86_64 or AArch64 Android support. The consumer's translated C module
and real NDK build still compile for the requested ABI. It means representing one header/platform
identity once instead of pretending the structural generator performed two independent ABI analyses.

### Keep

These neighboring facilities are not removal candidates:

- the actual ergonomic bindings and raw `.c` escape hatch
- target-gated public declarations and platform namespaces
- real consumer compilation for every advertised target and ABI
- the examples, shader helper, docs generation, and target support documentation after decoupling
- explicit acquisition, generation, package assembly, and release commands
- source, system, prebuilt, and bindings-only distributions
- source runtime installation, ControllerImage data, DXC selection, and allocator bridge APIs

The removals above cut validation payload and repository coupling without deleting those features.
