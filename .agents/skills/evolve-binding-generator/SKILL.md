---
name: evolve-binding-generator
description: Evolve this repository's generic SDL-to-Zig binding analysis, naming, function planning, rendering, or documentation rules. Use when an upstream SDL declaration or documentation pattern is new or changed, generated bindings are wrong or incomplete, or generator behavior needs a pattern-driven correction; use the separate extend-binding-platforms skill for target-platform expansion.
---

# Evolve Binding Generator

Treat binding work as translation-policy maintenance, not as a hand-maintained API port. Learn the
recurring SDL-family pattern, encode a conservative generic rule, and validate the generated public
result.

## Locate the owning stage

Start from the affected upstream header and documentation, then trace the declaration through the
pipeline:

- Keep `scripts/generate-bindings.ts` as the argument-free repository orchestration entrypoint.
- Keep repository translation inputs and generation policy in `scripts/codegen/config.ts`.
- Use `generator.ts` for analysis orchestration and source validation.
- Use `analysis.ts`, `doxygen.ts`, and `naming.ts` for input models and semantic analysis.
- Use `function-plan.ts` to plan each function transformation once.
- Use `render.ts` and `documentation.ts` for deterministic Zig and documentation output.
- Use `profile.ts` for internal library policy and public API exchange types.

Pass dependency APIs between library generations in memory. Do not add a root configuration file, a
nested Deno package, or committed one-use translation shims.

## Implement a generic rule

1. Identify the changed C shape and its documented contract. Distinguish a new recurring pattern
   from a one-symbol anomaly.
2. Reproduce the problem in the committed release result. Add a focused regression check only when
   release-result validation cannot express the contract clearly.
3. Update the earliest semantic stage that can establish the transformation. Keep rendering driven
   by analyzed or planned data instead of rediscovering semantics.
4. Preserve the original declaration when its shape and metadata do not establish a safe
   transformation. Fail unsupported signatures and unresolved documentation references with an
   actionable error.
5. Avoid release-specific symbol lists as the normal extension mechanism. Remove temporary
   exceptions after the general rule covers the pattern.
6. Regenerate all repository-configured libraries and inspect the complete generated diff.

Useful generic patterns include header-derived namespaces, documented failure conventions,
pointer/count pairs, output values, sentinel strings, ownership and release conventions, shared SDL
allocation, first-handle methods, flag groups, result structures, and ABI-sensitive records. Use
`extend-binding-platforms` for target-availability work.

Keep the compatibility claim scoped to the SDL family of coding patterns. Do not infer SDL1 or SDL2
support without separate verified inputs, analysis identities, fixtures, and ABI/runtime evidence.

## Protect generated contracts

Never hand-edit `src/{sdl,image,ttf,mixer,net}.zig`. Preserve the generated do-not-edit header and
deterministic output. Review changes for:

- ownership and allocator pairing;
- error and nullable-result semantics;
- ABI size, alignment, and field offsets;
- namespace and documentation paths;
- target selection; and
- Zig lazy-analysis safety.

## Validate

Run the narrowest relevant checks while iterating:

```sh
deno task fmt
deno task typecheck
deno task generate:bindings
deno task test:bindings
```

`test:bindings` regenerates into a temporary directory and requires byte-identical committed
modules. Finish with `deno task check`. Report any check that cannot finish.
