---
name: prepare-release
description: Prepare, validate, package, or publish this repository's SDL Zig binding releases. Use when updating the pinned SDL family baseline, making a binding-only release revision, running release gates, assembling the release archive, checking release artifacts, tagging a release, or uploading release assets.
---

# Prepare Release

Keep `mise.sdl.toml`, `scripts/sdl-release.ts`, vendored sources, generated bindings, package
metadata, and release artifacts on one reviewed SDL-family baseline. Use the repository tasks as the
implementation; do not recreate their download, verification, generation, or packaging behavior in
the skill.

## Classify the release

Inspect the worktree, `mise.sdl.toml`, `scripts/sdl-release.ts`, `scripts/codegen/config.ts`, and
the requested changes before editing. Choose exactly one path:

- For an upstream baseline update, update the core and companion artifact tables as one unit. Reset
  `bindingRevision` in `scripts/sdl-release.ts` to zero.
- For a binding-only correction on the existing baseline, leave every upstream pin unchanged and
  increment `bindingRevision` in `scripts/sdl-release.ts`.
- For packaging an already-versioned tree, do not change the artifact versions or binding revision.

Derive the tag from the generated version in `build.zig.zon`: use `v<SDL version>` for revision zero
and `v<SDL version>+<revision>` otherwise.

## Update a baseline

1. Update source and desktop artifact versions, URLs, and SHA-256 checksums in `mise.sdl.toml`.
   Change `scripts/sdl-release.ts` only when component or runtime selection semantics changed.
2. Run `deno task fetch` to replace committed upstream source trees, headers, licenses, and source
   assets. Never hand-edit verified files under `vendor/`.
3. Change `scripts/codegen/config.ts` only when translation inputs or generation policy changed.
4. Run `deno task generate`.
5. Review the complete artifact lock, vendored input, metadata, and generated binding diff.
6. Require the component set, versions, hashes, generated modules, and package metadata to agree
   before continuing.

For a binding-only correction, skip source refresh unless the verified inputs themselves changed.
Regenerate and review every derived result affected by the correction.

## Run the release gates

1. Confirm the worktree contains only intended release changes and preserve unrelated user work.
2. Run `deno task release-check`.
3. Require `deno task test:windows-build` on a native Windows runner with the MSVC SDK. Its
   translated C imports need the SDK headers, so report this gate as outstanding when the current
   environment cannot run it rather than substituting a GNU-target cross-build.
4. Resolve every stale generated file, distribution failure, archive-boundary failure, or
   documentation failure before packaging.

## Assemble and inspect artifacts

1. Package from the exact intended release commit with `deno task package:release`.
2. Record the archive path, SHA-256, and Zig hash printed by the task.
3. Compare them with the release-package validator result from the same commit.
4. Inspect the archive boundary and upstream notices. Require one self-contained source archive with
   verified headers and supported prebuilts.
5. Reject caches, test fixtures, code-generation tooling, translated-C intermediates, or
   repository-only agent material in the archive.

The publishable set is the `.tar.gz` archive plus its `.sha256` and `.zig-hash` sidecars.

## Tag and publish safely

Do not create commits, tags, push refs, publish releases, or upload assets unless the user
explicitly authorizes those external changes. When authorized, tag the exact validated commit and
upload only the archive and two sidecars. Report the commit, tag, hashes, completed gates, and any
gate that could not run.
