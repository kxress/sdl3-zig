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

| Library         | Zig module                                  | Enable with `addTo`        | Distribution                               |
| --------------- | ------------------------------------------- | -------------------------- | ------------------------------------------ |
| SDL3            | `sdl`, `sdl3.core`                          | always                     | auto, system, official prebuilt, or source |
| SDL3_image      | `image`, `sdl3.image`                       | `.image = true`            | auto, system, official prebuilt, or source |
| SDL3_ttf        | `ttf`, `sdl3.ttf`                           | `.ttf = true`              | auto, system, official prebuilt, or source |
| SDL3_mixer      | `mixer`, `sdl3.mixer`                       | `.mixer = true`            | auto, system, official prebuilt, or source |
| SDL3_net        | `net`, `sdl3.net`                           | `.net = true`              | auto, system, official prebuilt, or source |
| SDL3_test       | `test`, `sdl3.@"test"`                      | `.sdl3_test = true`        | system or source                           |
| ControllerImage | `controller_image`, `sdl3.controller_image` | `.controller_image = true` | system or source                           |
| SDL_shadercross | `shadercross`, `sdl3.shadercross`           | `.shadercross = true`      | system or source                           |

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

The package requires Zig 0.16.0 or newer. The repository pins Zig 0.16.0 for reproducible
development and CI.

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
        .distribution = .system,
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
| `.auto`      | Prefers a shipped official prebuilt, then compatible system libraries, then verified sources.                                 |
| `.prebuilt`  | Requires a supported official Windows or macOS prebuilt. Upstream publishes shared libraries only.                            |
| `.system`    | Links libraries supplied by the system or by the application. Static and shared both work when those libraries are available. |
| `.source`    | Builds the selected verified upstream source trees with their upstream CMake projects in the consumer's Zig cache.            |
| `.none`      | Exposes bindings without choosing or linking a native implementation.                                                         |

`addTo` defaults to `.auto`, which prefers a package-local official prebuilt, then compatible system
libraries, and finally a verified source build. Explicit distributions remain available when a
consumer needs deterministic control. The top-level package build defaults to `.none` when no
distribution is specified because it does not know which native components a consumer wants.

System distributions require each selected library's pkg-config version to meet the pinned component
baseline. For caller-supplied libraries without metadata, pass
`-Dallow_unknown_system_versions=true` or provide entries such as
`-Dsystem_version_overrides=image=3.4.12`.

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
prebuilts, so select `.system` or `.source` there. Package-local prebuilts are desktop-only; mobile
and web targets use caller-supplied libraries or a source build.

### Target-aware bindings

The generated declarations retain availability for the configured Linux, Windows, macOS, iOS, tvOS,
Emscripten, and Android targets. Platform-specific APIs are selected at compile time from the
consumer target, rather than being removed from the generated modules. The release archive ships
official prebuilts only for Windows and macOS desktop; iOS, tvOS, Android, and Emscripten consumers
must provide their own native distribution or configure `.source`.

For a source Emscripten build, pass the Emscripten CMake toolchain and sysroot used by your SDK:

```zig
_ = sdl3.addTo(b, exe, .{
    .distribution = .source,
    .emscripten_sysroot = "/path/to/emsdk/upstream/emscripten/cache/sysroot",
    .source_cmake_toolchain = "/path/to/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake",
});
```

For Android source builds, provide the NDK root and its CMake toolchain. SDL's Android project owns
the final APK packaging and Java activity integration:

```zig
_ = sdl3.addTo(b, shared_library, .{
    .distribution = .source,
    .android_ndk_root = "/path/to/android-ndk",
    .source_cmake_toolchain = "/path/to/android-ndk/build/cmake/android.toolchain.cmake",
});
```

Both cross-target examples assume the application has selected the corresponding Zig target. The
default headless source profile remains appropriate for build-only consumers; enable the required
SDL subsystems through `source_features` for an application that uses them.

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
    },
    .source_mixer_cmake_options = &.{
        "-DSDLMIXER_MP3=ON",
    },
});
```

The consumer controls its compiler, SDK, sysroot, CMake generator, toolchain, feature settings, and
runtime deployment. For shared source builds, `install_runtime` stages the selected SDL-family
runtime libraries into the consumer's `bin`/`lib` install prefix and adds a relative runtime search
path on Linux and macOS. Set `install_runtime = false` when another packaging step owns runtime
deployment; the source libraries then remain cache-local.

Custom packagers can obtain a selected source runtime as a `std.Build.LazyPath` from the dependency
returned by `addTo`, for example `sdl3.sourceRuntimeArtifact(b, dependency, .sdl)`. The returned
artifact is staged as a regular loader-facing file after CMake completes, so packaging does not
depend on the private CMake or Zig cache layout.

When ControllerImage is enabled for a source distribution, set
`install_controller_image_data = true` to install the generated databases at
`share/ControllerImage/controllerimage-standard.bin` and
`share/ControllerImage/controllerimage-kenney.bin`. The standard database is also available to a
custom packager as `sdl3.sourceControllerImageDataArtifact(b, dependency)`; both files are generated
only from the verified `vendor/ControllerImage/art` tree. This option is source-only and has no
effect for `.system`, where the application owns the ControllerImage data deployment.

SDL source builds use the explicit `headless` feature profile by default. It disables SDL's audio,
video, GPU, renderer, and camera subsystems so a source build does not silently depend on a display
or device SDK. Select the `desktop` profile, or override individual features, through the public
`AddOptions.source_features` field:

```zig
_ = sdl3.addTo(b, exe, .{
    .distribution = .source,
    .source_features = .{
        .profile = .desktop,
        .camera = false,
    },
});
```

The equivalent build options are `-Dsource_feature_profile=headless|desktop` and `-Dsource_audio`,
`-Dsource_video`, `-Dsource_gpu`, `-Dsource_renderer`, and `-Dsource_camera`. These focused
overrides take precedence over the profile. Raw `source_cmake_options` are appended last and
therefore remain the final escape hatch for upstream options and platform-specific driver selection.
Enabling a subsystem does not guarantee that a runtime device or display is available; applications
should still handle `SDL_Init` and resource-creation failures.

The default source profile enables the SDL_image and SDL_mixer features that need no additional
third-party source, uses the verified FreeType bundled for SDL_ttf, and leaves HarfBuzz, PlutoSVG,
and optional image/audio codecs disabled until explicitly configured.

### Install a consumer allocator

The generated core module exposes `sdl3.core.AllocatorBridge` for applications that must route SDL's
process-wide `malloc`, `calloc`, `realloc`, and `free` callbacks through a `std.mem.Allocator`:

```zig
var backing = std.heap.DebugAllocator(.{}){};
defer _ = backing.deinit();
try sdl3.core.AllocatorBridge.install(backing.allocator());
```

Install it before any other SDL call and keep the backing allocator state alive for the rest of the
process. The copied allocator value is borrowed globally; the bridge has no replacement or teardown
operation, and a second install returns `error.AlreadyInstalled`. If SDL reports existing tracked
allocations, installation returns `error.AllocationsAlreadyMade`. The bridge stores an allocation
header so reallocations and frees return the exact original span to the backing allocator while
retaining C's maximum alignment. `SDL_SetMemoryFunctions` has no aligned-allocation callback, so
`SDL_aligned_alloc` remains SDL-managed; over-aligned Zig allocations should continue to use the
existing `sdl3.core.allocator` directly.

Use `source_mixer_cmake_options` for upstream SDL3_mixer codec and dependency switches without
passing them to the other source builds. For example, `-DSDLMIXER_MP3=ON` enables Mixer’s
self-contained `dr_mp3` decoder; use Mixer’s `SDLMIXER_VENDORED` and backend-specific CMake options
when selecting bundled or system codec libraries.

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
- ControllerImage includes verified `art/` source assets. For a source distribution,
  `install_controller_image_data = true` installs its generated databases under
  `share/ControllerImage`; otherwise a custom packager can use `sourceControllerImageDataArtifact`.
  Load the standard database through `sdl3.controller_image.addDataFromFile()`.
- SDL_shadercross always includes SPIRV-Cross for source builds. Its default
  `.shadercross_dxc = .disabled` supports SPIR-V translation but not DXIL operations. Use `.bundled`
  for pinned official Microsoft DXC runtimes on Linux or Windows, `.external` with
  `shadercross_dxc_root` for a consumer-supplied runtime, or `.source` to build the pinned DXC
  source closure locally. Bundled and external DXC support x86_64 Linux and x86, x86_64, or AArch64
  Windows targets; unsupported pairs are rejected before CMake. For those modes, `install_runtime`
  also installs `dxcompiler` and `dxil` beside the selected SDL runtimes, while custom packagers can
  obtain them with `sourceRuntimeArtifact(b, dependency, .shadercross_dxc_dxcompiler)` and
  `sourceRuntimeArtifact(b, dependency, .shadercross_dxc_dxil)`. This project does not release
  locally built DXC or shadercross binaries.
- The opt-in [shader build helper](examples/shaders/README.md) consumes checked-in GLSL, HLSL, or
  Zig shader inputs and emits SPIR-V, DXIL, MSL, and reflection metadata. It is a small artifact
  workflow, not a rendering framework; GLSL requires an external `glslangValidator`, and DXIL
  requires a shadercross build with DXC enabled.

## What “Zig-idiomatic” means here

These are generated bindings, not a hand-maintained object wrapper. The generator retains SDL's
documented API organization and names while translating recurring C patterns into safer, clearer Zig
forms:

- C failures become `sdl.Error` error unions where the API documents failure.
- Pointer-and-count parameters become slices where ownership permits it.
- Output parameters become named result structs when that better represents the call.
- SDL-owned strings and arrays use explicit ownership-aware types.
- Resource lifetimes become methods when the documented lifecycle is unambiguous.
- Bit flags preserve unknown bits, and recurring ABI-sensitive shapes are covered by focused
  generator and consumer validation.

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

The `Documentation Pages` workflow publishes only an existing release tag. Its prepare job runs the
target, binding, and documentation gates, then packages the generated HTML once. The deploy job
downloads that artifact without regenerating it. Published versions live under their immutable
`v3.4.12+N` path, while `latest/` is the explicit stable alias; prior version directories are
retained when a new release is published.

## Generation and maintenance

`mise.sdl.toml` is the artifact lock, recording SDL-family releases, source URLs, checksums, and
extraction rules. `scripts/generate-bindings.ts` is the argument-free generation entry point. Its
codegen modules combine Clang/CastXML analysis with Doxygen parsing to render the public Zig modules
deterministically.

Both the generator and generated output are reviewed, so changes to a pin or generation rule are
reproducible and visible in the binding diff.

For repository work with the `.system` distribution, install your platform's SDL development
packages, then the pinned tools and use the explicit workflows:

```sh
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
consumer build tests. Binding checks compare generated output with the committed bindings.
`deno task package:release` requires that prepared cache and generated bindings, then assembles the
deterministic archive and its SHA-256 and Zig-hash sidecars.

Source archives and all other release inputs are verified by their pinned SHA-256 checksums.

## Examples

The repository includes SDL and selected 2D raylib-derived example ports. By default, examples use
the same automatic distribution order as library consumers: shipped official prebuilts, compatible
system libraries, then the verified SDL-family sources bundled in the repository. The authoritative
example inventory is the table in [`examples/build.zig`](examples/build.zig); see
[`examples/README.md`](examples/README.md) for assets, origins, and licensing.

```sh
zig build examples
zig build examples-sdl
zig build examples-raylib
zig build run-sdl-renderer-clear
```

## License

Repository code uses the SDL-style license in [LICENSE](LICENSE). Vendored upstream source trees and
release artifacts retain their own notices; the release archive includes the applicable licenses.
