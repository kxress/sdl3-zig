---
name: extend-binding-platforms
description: Extend this repository's target-aware SDL binding analysis and Zig surface selection. Use when adding iOS, Android, GDK, another operating system, architecture-, ABI-, or environment-specific declarations, or correcting platform availability, target identities, macro provenance, conditional namespaces, or target-gated ABI assertions.
---

# Extend Binding Platforms

Model target availability as declaration metadata while preserving the upstream header-derived API
layout. Do not move declarations into invented operating-system namespaces.

## Preserve the target-selection model

Keep integration APIs in the namespace derived from their defining public header. For example,
declarations from `SDL_system.h` remain in `sdl.system`, while `sdl.platform` remains the API from
`SDL_platform.h`. Keep target-dependent macros with the same header-derived namespace.

Generate one Zig source file for the supported matrix:

1. Keep implementation declarations private at module root.
2. Select the complete header-derived namespace with a compile-time consumer-target condition.
3. Export only declarations recorded for the selected target.

Ensure unselected branches do not resolve translated-C references. Preserve `@hasDecl` behavior and
avoid analyzing unavailable types, functions, constants, or ABI assertions.

## Add or correct target support

1. Identify the public header boundary, controlling upstream macros, and the exact declaration or
   macro availability expected on every supported target.
2. Update the structural analysis matrix in `scripts/codegen/config.ts`. Keep documentation
   predefined macros aligned when Doxygen needs a union of platform-visible APIs.
3. Update `targetIdentityArguments` and `createTargetAnalysisSupport` in
   `scripts/codegen/analysis.ts` when CastXML needs explicit platform identity or minimal SDK header
   substitutes. Keep substitutes temporary and structural; do not emulate unrelated SDK behavior.
4. Preserve availability while merging per-target models. Keep declarations keyed by stable source
   identity and constants keyed by source plus name.
5. Extend `targetPlatform` and `platformConditionForName` in `scripts/codegen/render.ts` with an
   explicit consumer-target mapping. Use the corresponding Zig target fields for architecture, ABI,
   or environment distinctions instead of forcing them into `builtin.os.tag`.
6. Gate platform-specific namespaces and ABI assertions with the same availability model.
7. Add build or consumer coverage for the new target, regenerate, and inspect the affected
   namespaces and root declarations.

Current structural analysis covers Linux, Windows, and macOS and maps them to `builtin.os.tag`.
Adding iOS, Android, GDK, or another platform requires all three: an analysis identity, validation
coverage, and an explicit consumer-target mapping.

## Preserve macro provenance

Derive macro provenance from Clang preprocessor line markers. Discard compiler and command-line
macros whose defining locations fall outside configured public include roots. Keep the defining
header and target set when merging declarations and macros.

Keep CastXML graphs, Doxygen XML, translated C, target-support headers, and macro probes temporary.
Regenerate only through the complete repository-configured entrypoint.

## Validate

Run:

```sh
deno task fmt
deno task typecheck
deno task generate:bindings
deno task test:bindings
deno task test:consumers
```

Inspect the generated diff for namespace placement, target-specific `@hasDecl` behavior, conditional
translated-C references, and ABI checks. Finish with `deno task check`; report target coverage that
requires another host or SDK.
