# SDL3 Zig bindings — unreleased binding changes

These notes describe the current binding-only work on the pinned SDL 3.4.12 baseline.

- `sdl.allocator` now documents and validates alignment, ownership, release pairing, zero-size,
  resize, and callback failure behavior through the generated allocator bridge and its native
  fixture. Existing allocator-taking Zig signatures remain source-compatible.
- The four manual iconv convenience wrappers are selected and ownership-tracked from typed profile
  policy records; generation rejects stale or missing manual entries.
- C-format convenience wrappers now validate comptime formats, default promotions, mutable scanf
  destinations, and supported length/pointer combinations. Wide-format declarations retain their
  direct C/`VaList` access where a portable Zig tuple ABI cannot be proved.
- SDL logging adds typed Zig formatting and an opt-in `std.Options.logFn` adapter. Messages are
  forwarded with a fixed `%s`; category/priority selection, bounded failure diagnostics, and
  callback reentrancy are covered by native tests.
- Clang declaration metadata is normalized for deprecation, result-use, linkage, inline hints,
  no-return flow, allocation contracts, and restrict parameters. Metadata is documented or used for
  validation without inventing unsupported Zig warnings or aliasing guarantees. Native source
  consumers prove forced-inline rectangle helpers evaluate side-effecting arguments once.
- The Android build fixture now derives both CMake ABI and NDK CRT paths from the requested Zig
  target, so arm64-v8a and x86_64 consumers build and package independently.
- Native build tasks include a C/Zig `long double` layout and value-round-trip probe; non-Linux
  runtime coverage remains CI-host dependent.
- The Emscripten consumer runtime fixture now validates C/Zig `long double` layout and round-trip
  ABI plus generated `%Lf` formatting under Node with the pinned Emscripten SDK; the fixture passes
  locally with Emscripten 5.0.1.
- SDL assertion macro adapters remain intentionally unrepresentable on generic Zig 0.16.0; the raw
  SDL assertion functions remain available.
