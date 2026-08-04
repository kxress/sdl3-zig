const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("shim.h"),
        .target = target,
        .optimize = optimize,
    });
    translate_c.defineCMacro("SDL_DISABLE_OLD_NAMES", "1");
    translate_c.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const c_module = translate_c.createModule();
    const test_module = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl3_c", .module = c_module },
        },
    });
    const sdl_module = b.createModule(.{
        .root_source_file = b.path("../../../../src/sdl.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl3_c", .module = c_module },
            .{ .name = "sdl3_support", .module = b.createModule(.{
                .root_source_file = b.path("../../../../src/support.zig"),
                .target = target,
                .optimize = optimize,
            }) },
        },
    });
    test_module.addImport("sdl", sdl_module);
    const tests = b.addTest(.{ .root_module = test_module });
    tests.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    tests.root_module.addCSourceFile(.{ .file = b.path("stubs.c"), .flags = &.{} });
    tests.root_module.linkSystemLibrary("c", .{});
    b.default_step.dependOn(&b.addRunArtifact(tests).step);

    const preexisting_module = b.createModule(.{
        .root_source_file = b.path("preexisting.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const preexisting = b.addTest(.{ .root_module = preexisting_module });
    preexisting.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    preexisting.root_module.addCSourceFile(.{ .file = b.path("stubs.c"), .flags = &.{} });
    preexisting.root_module.linkSystemLibrary("c", .{});
    b.default_step.dependOn(&b.addRunArtifact(preexisting).step);
}
