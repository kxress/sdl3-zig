# SDL3 for Zig

Generated bindings for SDL3 and its companion libraries, with a Zig-idiomatic API.

The generated API preserves the public upstream C API while using Zig's native tools: error unions,
slices instead of pointer/count pairs, typed flags, ownership-aware handles, methods where they
clarify resource ownership, and compile-time ABI checks. Adapters are forced inline, so the Zig
surface should not add a wrapper call that an equivalent hand-written Zig-to-C call would avoid.

Bindings are generated from pinned, verified upstream source trees. Upstream documentation is parsed
with Doxygen and included in the generated Zig declarations, so editor hovers and generated HTML
documentation describe the API instead of merely exposing translated declarations.

## Included libraries

| Library         | Zig module                                  | Enable with `addTo`        | Distribution                         |
| --------------- | ------------------------------------------- | -------------------------- | ------------------------------------ |
| SDL3            | `sdl`, `sdl3.core`                          | always                     | system, official prebuilt, or source |
| SDL3_image      | `image`, `sdl3.image`                       | `.image = true`            | system, official prebuilt, or source |
| SDL3_ttf        | `ttf`, `sdl3.ttf`                           | `.ttf = true`              | system, official prebuilt, or source |
| SDL3_mixer      | `mixer`, `sdl3.mixer`                       | `.mixer = true`            | system, official prebuilt, or source |
| SDL3_net        | `net`, `sdl3.net`                           | `.net = true`              | system, official prebuilt, or source |
| SDL3_test       | `test`, `sdl3.@"test"`                      | `.sdl3_test = true`        | system or source                     |
| ControllerImage | `controller_image`, `sdl3.controller_image` | `.controller_image = true` | system or source                     |
| SDL_shadercross | `shadercross`, `sdl3.shadercross`           | `.shadercross = true`      | system or source                     |

SDL3_test, ControllerImage, and SDL_shadercross are optional source-only SDL packages.

“Official prebuilt” means a binary published by the upstream SDL project. This project does not
publish binaries it built itself. Source builds happen in the consuming application's Zig cache.

## Install

Release archives contain the bindings, complete verified source trees, and supported official
desktop prebuilts. Add an archive to an application with Zig:

```sh
zig fetch --save /path/to/sdl3-3.4.12+9.tar.gz
```

The command also accepts an archive URL from a release page. It writes the `sdl3` dependency and its
content hash to `build.zig.zon`. During development, you can use a checkout instead:

```zig
.dependencies = .{
    .sdl3 = .{ .path = "../SDL3" },
},
```

The package requires Zig 0.16.0 or newer.

## Add SDL to your application

Import the build API and call `addTo` for each executable or library that uses SDL. It adds the
`sdl3` façade, the core `sdl` module, and enabled companion modules, then links the requested native
libraries.

```zig
const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello-sdl",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    _ = sdl3.addTo(b, exe, .{
        .image = true,
        .ttf = true,
        .mixer = true,
    });
    b.installArtifact(exe);
}
```

In application code, use the façade for a compact import. `core` is always available; companions are
available only when enabled in the build step.

```zig
const sdl3 = @import("sdl3");
const sdl = sdl3.core;

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();

    // Use SDL through documented namespaces such as sdl.video, sdl.audio, and sdl.render.
    // Enabled companions are available as sdl3.image, sdl3.ttf, and sdl3.mixer.
}
```

You can also import modules directly: `@import("sdl")`, `@import("image")`, `@import("ttf")`, and so
on. This lets a library expose only the dependency it uses.

## Choose a distribution and linkage

`AddOptions.distribution` selects where native libraries come from. `AddOptions.linkage` selects
static or shared linkage independently; it is never inferred from the host or toolchain.

| Distribution | Behavior                                                                                                                      |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| `.auto`      | Uses official package-local prebuilts on Windows and macOS; links system libraries elsewhere. Never selects source builds.    |
| `.prebuilt`  | Requires a supported official Windows or macOS prebuilt. Upstream publishes shared libraries only.                            |
| `.system`    | Links libraries supplied by the system or by the application. Static and shared both work when those libraries are available. |
| `.source`    | Builds the selected verified upstream source trees with their upstream CMake projects in the consumer's Zig cache.            |
| `.none`      | Exposes bindings without choosing or linking a native implementation.                                                         |

For example, a Linux application can request static system libraries explicitly:

```zig
_ = sdl3.addTo(b, exe, .{
    .distribution = .system,
    .linkage = .static,
    .image = true,
});
```

On Windows, `.prebuilt` installs selected DLLs beside the executable. On macOS, it installs selected
frameworks below `zig-out/lib` and adds an executable-relative rpath. Set `install_runtime = false`
when another packaging step handles runtime deployment. Enable SDL_image and SDL_mixer's optional
upstream codec runtimes with `optional_codecs = true`.

Windows GNU supports x86 and x86_64; Windows MSVC supports x86, x86_64, and AArch64. macOS prebuilts
are universal frameworks for x86_64 and AArch64. SDL does not publish generic Linux desktop
prebuilts, so select `.system` or `.source` there.

## Build from verified source

Source builds use each upstream CMake project rather than replacing its build system with a Zig
port. This preserves the upstream dependency and feature model while allowing a consumer to use
`zig cc` through its own CMake toolchain.

```zig
_ = sdl3.addTo(b, exe, .{
    .distribution = .source,
    .linkage = .shared,
    .image = true,
    .ttf = true,
    .mixer = true,
    .net = true,
    .source_cmake_generator = "Ninja",
    .source_cmake_toolchain = "cmake/toolchain.cmake",
    .source_cmake_options = &.{
        "-DSDLIMAGE_PNG=ON",
        "-DSDLMIXER_MP3=ON",
    },
});
```

The consumer controls its compiler, SDK, sysroot, CMake generator, toolchain, feature settings, and
runtime deployment. Static and shared source outputs stay cache-local, so an application selecting
`.shared` must stage its runtime libraries itself.

The default source profile enables the SDL_image and SDL_mixer features that need no additional
third-party source, uses the verified FreeType bundled for SDL_ttf, and leaves HarfBuzz, PlutoSVG,
and optional image/audio codecs disabled until explicitly configured.

### Optional source-only SDL packages

`SDL3_test`, ControllerImage, and SDL_shadercross have no official package-local prebuilts. Use
`.system` when the application supplies the libraries, or `.source` to build the verified sources.

```zig
_ = sdl3.addTo(b, exe, .{
    .distribution = .source,
    .linkage = .static,
    .sdl3_test = true,
    .controller_image = true,
    .shadercross = true,
});
```

- SDL3_test appears as `sdl3.@"test"`, because `test` is a Zig keyword.
- ControllerImage includes verified `art/` source assets. Generate and ship its
  `controllerimage-standard.bin` data file with the application, then load it through
  `sdl3.controller_image.addDataFromFile()`.
- SDL_shadercross always includes SPIRV-Cross for source builds. Its default
  `.shadercross_dxc = .disabled` supports SPIR-V translation but not DXIL operations. Use `.bundled`
  for pinned official Microsoft DXC runtimes on Linux or Windows, `.external` with
  `shadercross_dxc_root` for a consumer-supplied runtime, or `.source` to build the pinned DXC
  source closure locally. This project does not release locally built DXC or shadercross binaries.

## What “Zig-idiomatic” means here

These are generated bindings, not a hand-maintained object wrapper. The generator retains SDL's
documented API organization and names while translating recurring C patterns into safer, clearer Zig
forms:

- C failures become `sdl.Error` error unions where the API documents failure.
- Pointer-and-count parameters become slices where ownership permits it.
- Output parameters become named result structs when that better represents the call.
- SDL-owned strings and arrays use explicit ownership-aware types.
- Resource lifetimes become methods when the documented lifecycle is unambiguous.
- Bit flags preserve unknown bits, and every generated ABI-facing declaration gets compile-time
  size, alignment, and relevant field-offset checks.

The API is still evolving. Its direction—making SDL3 natural to use from Zig—is stable, but
generated names and shapes may change as the generator handles more SDL patterns. The binding layer
is limited to adaptations an application would otherwise write around SDL: translating C conventions
into Zig types, checking documented failure results, and expressing ownership. It does not add a
framework, hidden runtime, or abstraction that forces an extra call or allocation.

Core SDL declarations are organized into SDL's documented categories: `sdl.audio`, `sdl.video`,
`sdl.render`, `sdl.ioStream`, `sdl.gpu`, and more. Declarations without a documented category remain
at the module root. Platform-specific declarations are selected at compile time for the consumer's
target rather than removed from the generated source.

After checking out the repository, build the complete API documentation locally with:

```sh
zig build docs
```

The HTML output in `zig-out/docs` includes every public module and optional companion.

## Generation and maintenance

`mise.sdl.toml` is the artifact lock, recording SDL-family releases, source URLs, checksums, and
extraction rules. `scripts/generate-bindings.ts` is the argument-free generation entry point. Its
codegen modules combine Clang/CastXML analysis with Doxygen parsing to render the public Zig modules
deterministically.

Codex helped build the generator and its maintenance tooling. Both the generator and generated
output are reviewed, so changes to a pin or generation rule are reproducible and visible in the
binding diff.

For repository work on Debian/Ubuntu, Arch, Artix, CachyOS, or MSYS2, install the system packages,
then the pinned tools and use the explicit workflows:

```sh
./system_setup.sh
mise trust
mise install
deno task setup

deno task fetch
deno task generate
deno task check
deno task release-check
```

`fetch` populates the ignored local cache of verified upstream source trees when it is absent or
does not match the pinned artifact manifest. `generate` rewrites bindings and package metadata.
`check` runs formatting, type checks, source verification, metadata tests, binding tests, and
consumer build tests. `deno task package:release` validates or repopulates that cache, then
assembles the deterministic archive and its SHA-256 and Zig-hash sidecars.

## Examples

The repository includes 38 SDL example ports and 24 selected 2D raylib-derived ports. They
intentionally use system libraries:

```sh
zig build examples
zig build examples-sdl
zig build examples-raylib
zig build run-sdl-renderer-clear
```

See [examples/README.md](examples/README.md) for the inventory, assets, origins, and licensing.

## License

Repository code uses the SDL-style license in [LICENSE](LICENSE). Vendored upstream source trees and
release artifacts retain their own notices; the release archive includes the applicable licenses.
