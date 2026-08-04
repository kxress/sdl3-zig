# Android target

This repository supports a source-build Android application target for the pinned SDL 3.4.12 family.
It is an application-target fixture, not an Android AAR/Prefab distribution.

The binding generator analyzes one Android header identity, `aarch64-linux-android21`, with SDL's
Android macros. Zig 0.16 represents Android targets as Linux with the `android` ABI, so generated
namespaces select Android with `builtin.abi == .android` (or `.androideabi`). The analysis traversal
uses a host LP64 compiler model because SDL's public headers do not require NDK headers and Zig 0.16
`translate-c` cannot parse all Android NDK nullability declarations. Consumer modules are still
compiled for the requested Android ABIs and linked against the NDK sysroot.

The supported application path is:

1. Build the Zig consumer shared library for `aarch64-linux-android` with the pinned SDL source
   distribution and Android NDK CMake toolchain.
2. Copy `libmain.so` into an SDL Android project using a Java `SDLActivity` subclass that loads only
   the application library. SDL is statically linked into that library, so no separate SDL3 shared
   object is packaged.
3. Run the Gradle wrapper with `assembleDebug`, package the `arm64-v8a` library, and inspect the
   APK. If `adb devices` reports a connected device or emulator, the test installs and starts the
   activity as an additional smoke test.

Run the fixture with:

```sh
deno task test:android
```

It uses SDK platform 35, build tools 35.0.1, NDK `28.2.13676358`, Gradle 8.12, and JDK 17 when the
ignored local cache is present. Set `ANDROID_SDK_ROOT`, `ANDROID_NDK_ROOT`, and `JAVA_HOME` to use
an external installation. Missing inputs produce a diagnostic naming each required path.

The fixture sets `use_llvm = false` for the Android shared library because Zig 0.16's LLVM backend
rejects the AArch64 `std.builtin.VaList` definition as disabled due to known miscompilations. This
is an explicit constraint of the pinned Zig toolchain. APK execution is an optional smoke test when
an emulator or device is available.

The source path covers JNI/activity integration, Android-specific generated bindings from
`SDL_system.h`, `SDL_main` export, Gradle/APK packaging, and the manifest's vibrate permission.
Official Android AAR/Prefab artifacts and release prebuilts remain outside the package contract
until they are acquired and verified as part of the pinned SDL family.
