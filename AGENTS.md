# AGENTS.md

This repository generates Zig bindings from a pinned SDL3 release family. Keep changes focused on
reproducible acquisition, generation, validation, and release.

## Repository map

- `mise.sdl.toml`: authoritative upstream SDL source and binary artifact versions, URLs, checksums,
  and extraction settings.
- `scripts/generate-bindings.ts`: the repository binding-regeneration entrypoint.
- `scripts/codegen/`: reusable binding analysis and rendering plus the typed repository
  configuration in `scripts/codegen/config.ts`.
- `scripts/`: SDL source synchronization, package metadata generation, release assembly, and their
  focused support modules.
- `tests/`: repository checks and their black-box consumer/linking fixtures.
- `vendor/`: ignored local cache of verified upstream SDL-family source trees, headers, licenses,
  and source assets. `deno task fetch` repopulates it when absent or stale; release assembly
  validates it before packaging.
- `src/`: committed public Zig modules and private support.
- `scripts/sdl-release.ts`: release revision, artifact installation, and typed SDL packaging
  semantics.
- `sdl_metadata.zig`: package build metadata generated from `mise.sdl.toml`,
  `scripts/sdl-release.ts`, and `scripts/codegen/config.ts`.
- `.agents/skills/evolve-binding-generator/`: generic binding-analysis and rendering maintenance.
- `.agents/skills/extend-binding-platforms/`: target-aware binding-analysis and surface expansion.
- `.agents/skills/prepare-release/`: repository release preparation and publication workflow.
- `deno.json` and `deno.lock`: the single Deno workspace configuration and dependency lock.
- `mise.toml`: pinned executable tool versions; `mise.sdl.toml` is loaded only by SDL acquisition
  tasks. Workflow tasks live in `deno.json`.

## Tooling and commands

Install the pinned tools and cache Deno dependencies:

```sh
mise trust
mise install
deno task setup
```

Run maintenance workflows from Linux, macOS, or WSL. Native Windows is reserved for
`deno task test:windows-build`; translated MSVC C imports require the MSVC SDK, and mise skips the
Unix tools there.

The repository workflow is explicit:

```sh
deno task fetch
deno task generate
deno task check
deno task release-check
```

`fetch` updates verified inputs, `generate` updates bindings and build metadata, `check` runs the
repository checks, and `release-check` adds documentation validation. Run concrete tasks while
iterating:

```sh
deno task fmt
deno task fmt:check
deno task lint
deno task typecheck
deno task test:metadata
deno task test:sources
deno task test:bindings
```

## Change guidelines

- Follow `deno.json`: 100-column TypeScript/JSON formatting, semicolons, and double quotes.
- Keep `scripts/generate-bindings.ts` as an argument-free repository entrypoint. Put generator
  behavior in focused `scripts/codegen/` modules.
- Keep repository translation inputs and generation policy in `scripts/codegen/config.ts`.
- Keep structured release behavior in focused TypeScript modules under `scripts/`. Use Bash only for
  transparent Unix/WSL command and filesystem workflows.
- Use explicit Deno permissions and preserve cross-platform path handling, especially Windows paths.
- Prefer release-result validation over fixtures coupled to generator internals. Keep black-box
  fixtures minimal and limited to package, distribution, or linking boundaries.
- Keep generated output deterministic and retain the do-not-edit header.
- Run the narrowest relevant validator while iterating, then `deno task check` before finishing.

## Release and generated files

- Repository release versions follow core SDL: `v3.4.12` for revision zero, then `v3.4.12+1`,
  `v3.4.12+2`, and so on for binding-only fixes on the same SDL baseline.
- Update `mise.sdl.toml` as one reviewed unit. Core SDL version, companion pins, source and binary
  hashes, generated build metadata, the verified local source cache, and bindings must agree.
- Increment the binding revision in `scripts/sdl-release.ts` only for binding-only fixes on an
  unchanged SDL baseline.
- Do not hand-edit generated `src/{sdl,image,ttf,mixer,net,test,controller_image,shadercross}.zig`
  or generated `sdl_metadata.zig`; change their inputs and regenerate.
- Do not hand-edit verified files under `vendor/`. The directory is an ignored local cache; release
  prebuilts are downloaded and verified during package assembly, not committed.
- Commit generated bindings for releases; they are the package's public source.

## Working-tree hygiene

- Preserve unrelated user changes and untracked files.
- Avoid destructive Git operations and broad cleanup commands.
- Keep patches scoped. If a tool rewrites unrelated files, revert only those tool-produced changes.
- In the final handoff, report files changed and checks run, including checks that could not finish.
