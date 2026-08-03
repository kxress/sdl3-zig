const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(sdl3.Linkage, "linkage", "Source linkage") orelse .shared;
    const shadercross_dxc = b.option(
        sdl3.ShadercrossDxc,
        "shadercross_dxc",
        "SDL_shadercross DXC mode",
    ) orelse .disabled;
    const disable_image_bmp = b.option(
        bool,
        "disable_image_bmp",
        "Pass an upstream SDL_image CMake option through the package",
    ) orelse false;
    const source_cmake_options: []const []const u8 = if (disable_image_bmp)
        &.{"-DSDLIMAGE_BMP=OFF"}
    else
        &.{};
    const source_cmake_toolchain: ?[]const u8 = if (target.result.os.tag == .linux)
        std.fs.path.join(
            b.allocator,
            &.{ b.build_root.path orelse ".", "zig-toolchain.cmake" },
        ) catch @panic("OOM")
    else
        null;
    const executable = b.addExecutable(.{
        .name = "cmake-source-all",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    _ = sdl3.addTo(b, executable, .{
        .distribution = .source,
        .linkage = linkage,
        .sdl3_test = true,
        .controller_image = true,
        .shadercross = true,
        .shadercross_dxc = shadercross_dxc,
        .image = true,
        .ttf = true,
        .mixer = true,
        .net = true,
        .source_cmake_options = source_cmake_options,
        .source_cmake_toolchain = source_cmake_toolchain,
    });
    b.installArtifact(executable);
}
