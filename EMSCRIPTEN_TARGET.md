# Emscripten target prototype

The package has an explicit `wasm32-emscripten` analysis target. Generated bindings select
Emscripten namespaces and the package build adds the Emscripten sysroot to Zig's C translation
inputs and library search paths.

The supported prototype is source distribution only. It builds the pinned SDL source with the
Emscripten CMake toolchain, compiles the Zig consumer to a relocatable WebAssembly object, and lets
`emcc` perform the final runtime link. The fixture stages HTML, JavaScript glue, WebAssembly, and a
preload data file, then executes the generated JavaScript with Node:

```sh
source /path/to/emsdk/emsdk_env.sh
deno task test:emscripten
```

The fixture currently uses emsdk 6.0.5 for its reproducible validation. The active SDK must expose
`EMSDK`; the task is skipped when that variable is absent. The direct build inputs are:

```text
-Dtarget=wasm32-emscripten
-Demscripten_sysroot=$EMSDK/upstream/emscripten/cache/sysroot
-Dsource_cmake_toolchain=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake
```

This is not a prebuilt SDL artifact target and does not claim browser or mobile-platform support.
Browser deployment still needs the staged HTML/JavaScript/data files and an application-specific web
host configuration.
