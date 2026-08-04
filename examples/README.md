# SDL3 Zig examples

This directory contains native SDL3 examples:

- `sdl/` contains ports from
  [`libsdl-org/SDL@6880bed`](https://github.com/libsdl-org/SDL/tree/6880bed495226e7b87e9ef08fc552c0bcfd5fc29/examples).
- `raylib/` contains selected 2D ports from
  [`raysan5/raylib@3e49c80`](https://github.com/raysan5/raylib/tree/3e49c8079949c51f69d55a879d490cd6d41a58fa/examples).

Raylib-derived source files start with `RAYLIB-DERIVED`, live only under `raylib/`, and produce
executables whose names start with `raylib-`. The SDL examples use the `sdl-` prefix. Every source
file records its exact upstream example and commit.

## Building and running

The examples use ordinary Zig `main` functions and native SDL event loops. They intentionally do not
use SDL's callback-main/Wasm path.

```sh
# Build and install one group, or both groups.
zig build examples-sdl
zig build examples-raylib
zig build examples

# Build or run one example.
zig build sdl-renderer-clear
zig build run-sdl-renderer-clear
zig build raylib-textures-bunnymark
zig build run-raylib-textures-bunnymark
```

The group and individual build/run steps link against system SDL3 libraries. Examples that load
images, fonts, or music additionally link the matching SDL3_image, SDL3_ttf, or SDL3_mixer system
library. `zig build example` remains an alias for `sdl-renderer-clear`.

The repository-owned `shaders/` directory is a separate opt-in helper. It builds deterministic
SPIR-V, DXIL, MSL, and reflection outputs from GLSL, HLSL, or Zig shader inputs, then provides a
small SDL_GPU device-load smoke executable. See [shaders/README.md](shaders/README.md); it requires
the source-built SDL_shadercross CLI and an external `glslangValidator` for GLSL.

Builds install assets beside the executables under `zig-out/bin/sdl` and `zig-out/bin/raylib`. Run
steps set their working directory to `examples/assets`, so source checkouts can also find them
without installation.

## SDL ports

All native examples present at the pinned SDL commit are included, along with the repository-owned
shader device-load smoke:

| Category | Count | Examples                                                                      |
| -------- | ----: | ----------------------------------------------------------------------------- |
| asyncio  |     1 | load bitmaps                                                                  |
| audio    |     5 | simple playback, playback callback, WAV, multiple streams, planar data        |
| camera   |     1 | read and draw                                                                 |
| demo     |     4 | snake, woodeneye-008, infinite monkeys, bytepusher                            |
| input    |     5 | joystick polling/events, gamepad polling/events/rumble                        |
| misc     |     3 | power, clipboard, locale                                                      |
| pen      |     1 | drawing lines                                                                 |
| renderer |    17 | clear through blending, including textures, geometry, viewports, and readback |
| storage  |     1 | user storage                                                                  |
| shader   |     1 | SDL_GPU shader device-load smoke                                              |

## Raylib-derived ports

The selected raylib set stays within functionality that maps cleanly to SDL3 and its image, TTF, and
mixer companion libraries:

| Category | Count | Examples                                                                         |
| -------- | ----: | -------------------------------------------------------------------------------- |
| core     |     9 | keys, mouse, wheel, multitouch, window flags, monitors, drops, high-DPI, logging |
| shapes   |     2 | collision area, rectangle scaling                                                |
| textures |     8 | scrolling, bunnymark, fog, GIF, nine-patch, particles, animation, button         |
| text     |     3 | input box, word alignment, writing animation                                     |
| audio    |     2 | tracker module, music stream                                                     |

The selection excludes 3D, raygui, physics, shaders, and examples that depend on higher-level raylib
rendering abstractions without a reasonably direct SDL equivalent. It also excludes web-only
variants for now.

## Licensing

The SDL example source is upstream public-domain example code ported to Zig. The raylib-derived
source retains raylib's zlib license; see [RAYLIB_LICENSE.txt](RAYLIB_LICENSE.txt). Media assets
retain their upstream terms in `assets/sdl/ASSET_LICENSES.txt` and the license inventories under
`assets/raylib/`.
