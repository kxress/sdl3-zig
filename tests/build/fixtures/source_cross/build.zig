const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const source_sysroot = b.option(
        []const u8,
        "source_sysroot",
        "CMake sysroot forwarded to every source component",
    );
    const source_include_dir = b.option(
        []const u8,
        "source_include_dir",
        "Additional C and C++ include directory forwarded to every source component",
    );
    const toolchain = std.fs.path.join(
        b.allocator,
        &.{ b.build_root.path orelse ".", "zig-toolchain.cmake" },
    ) catch @panic("OOM");

    var source_cmake_options: std.ArrayList([]const u8) = .empty;
    if (target.result.os.tag == .linux) {
        const target_triple = target.result.zigTriple(b.allocator) catch @panic("OOM");
        source_cmake_options.append(
            b.allocator,
            b.fmt("-DCMAKE_C_COMPILER_TARGET={s}", .{target_triple}),
        ) catch @panic("OOM");
        source_cmake_options.append(
            b.allocator,
            b.fmt("-DCMAKE_CXX_COMPILER_TARGET={s}", .{target_triple}),
        ) catch @panic("OOM");
    }
    if (source_sysroot) |path| {
        source_cmake_options.append(b.allocator, b.fmt("-DCMAKE_SYSROOT={s}", .{path})) catch
            @panic("OOM");
    }
    if (source_include_dir) |path| {
        source_cmake_options.append(
            b.allocator,
            b.fmt("-DCMAKE_C_FLAGS=-isystem{s}", .{path}),
        ) catch @panic("OOM");
        source_cmake_options.append(
            b.allocator,
            b.fmt("-DCMAKE_CXX_FLAGS=-isystem{s}", .{path}),
        ) catch @panic("OOM");
    }

    const executable = b.addExecutable(.{
        .name = "cmake-source-cross",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    _ = sdl3.addTo(b, executable, .{
        .distribution = .source,
        .linkage = .static,
        .image = true,
        .ttf = true,
        .mixer = true,
        .net = true,
        .source_cmake_toolchain = toolchain,
        .source_cmake_options = source_cmake_options.items,
        .source_features = .{ .profile = .headless, .audio = false },
    });
    b.installArtifact(executable);
}
