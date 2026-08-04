# SDL shader build helper

This directory is a small, opt-in example for producing shader artifacts without adding a rendering
framework to the bindings. The helper accepts pinned GLSL, HLSL, or Zig source inputs and writes
four artifacts for each entry:

- SPIR-V (`.spv`)
- DXIL (`.dxil`)
- Metal Shading Language (`.metal`)
- SDL_shadercross reflection metadata (`.json`)

The checked-in manifest covers both graphics and compute stages. The source-built `shadercross`
executable is required. GLSL inputs additionally require an external `glslangValidator`;
SDL_shadercross itself accepts SPIR-V and HLSL, not GLSL. DXIL requires a shadercross build with DXC
enabled (`bundled`, `external`, or `source`). Missing tools are reported as actionable errors rather
than silently dropping an output.

From the repository root:

```sh
SDL_SHADERCROSS=/path/to/shadercross \
GLSLANG_VALIDATOR=/path/to/glslangValidator \
deno task build:shaders
```

The output directory defaults to `zig-out/shaders`; use `--manifest` and `--output` to select
different paths. `shader-manifest.json` contains only stable input, output, and SHA-256 metadata, so
running the helper twice with the same tools and inputs can be compared byte-for-byte.

`load.zig` is an opt-in SDL_GPU smoke loader. Build it with the normal examples workflow, then run
it once for each retained format on a host that provides the matching SDL GPU backend:

```sh
zig-out/bin/sdl-shader-device-load spirv zig-out/shaders/hlsl_vertex.spv
zig-out/bin/sdl-shader-device-load dxil zig-out/shaders/hlsl_vertex.dxil
zig-out/bin/sdl-shader-device-load msl zig-out/shaders/hlsl_vertex.metal
```

The loader only creates and releases one shader, so it verifies the device-level format contract
without becoming a pipeline or asset-management layer.
