const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const ndk = b.option([]const u8, "android_ndk", "Android NDK root") orelse
        @panic("-Dandroid_ndk is required");
    const toolchain = b.option([]const u8, "source_cmake_toolchain", "Android CMake toolchain") orelse
        @panic("-Dsource_cmake_toolchain is required");
    const sysroot = b.fmt("{s}/toolchains/llvm/prebuilt/linux-x86_64/sysroot", .{ndk});
    const libc = b.addWriteFiles().add("android-libc.txt", b.fmt(
        "include_dir={s}/usr/include\nsys_include_dir={s}/usr/include\ncrt_dir={s}/usr/lib/aarch64-linux-android/21\nmsvc_lib_dir=\nkernel32_lib_dir=\ngcc_dir=\n",
        .{ sysroot, sysroot, sysroot },
    ));

    const library = b.addLibrary(.{
        .name = "main",
        .linkage = .dynamic,
        .use_llvm = false,
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    library.setLibCFile(libc);
    _ = sdl3.addTo(b, library, .{
        .distribution = .source,
        .linkage = .static,
        .android_ndk_root = ndk,
        .source_cmake_toolchain = toolchain,
        .source_cmake_options = &.{
            "-DANDROID_ABI=arm64-v8a",
            "-DANDROID_PLATFORM=android-21",
            "-DSDL_ANDROID_JAR=OFF",
            "-DSDL_SHARED=OFF",
            "-DSDL_STATIC=ON",
        },
        .source_features = .{ .profile = .headless },
    });
    b.installArtifact(library);
}
