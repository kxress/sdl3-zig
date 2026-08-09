const std = @import("std");
const sdl = @import("build.zig");
const example_project = @import("examples/project.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const modules = sdl.addRepositoryModules(b, target, optimize);

    const docs_options_files = b.addWriteFiles();
    const docs_options = b.createModule(.{
        .root_source_file = docs_options_files.add(
            "sdl3_docs_options.zig",
            "pub const test_ = true;\npub const controller_image = true;\npub const shadercross = true;\npub const image = true;\npub const ttf = true;\npub const mixer = true;\npub const net = true;\n",
        ),
        .target = target,
        .optimize = optimize,
    });
    const docs = b.addObject(.{
        .name = "sdl3-docs",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "sdl", .module = modules.sdl },
                .{ .name = "test", .module = modules.test_ },
                .{ .name = "controller_image", .module = modules.controller_image },
                .{ .name = "shadercross", .module = modules.shadercross },
                .{ .name = "image", .module = modules.image },
                .{ .name = "ttf", .module = modules.ttf },
                .{ .name = "mixer", .module = modules.mixer },
                .{ .name = "net", .module = modules.net },
                .{ .name = "sdl3_options", .module = docs_options },
            },
        }),
    });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    b.step("docs", "[Documentation] Generate HTML for every public SDL module")
        .dependOn(&install_docs.step);

    const example_distribution = b.option(
        sdl.Distribution,
        "distribution",
        "[Distribution] Native SDL libraries: auto, none, system, prebuilt, or source",
    ) orelse .auto;
    const example_modules = sdl.addRepositoryModulesWithOptions(b, target, optimize, .{
        .distribution = example_distribution,
        .image = true,
        .ttf = true,
        .mixer = true,
        .source_features = .{ .profile = .desktop },
    });
    example_project.add(b, .{
        .target = target,
        .optimize = optimize,
        .native_build = example_modules.native_build,
        .sdl = example_modules.sdl,
        .image = example_modules.image,
        .ttf = example_modules.ttf,
        .mixer = example_modules.mixer,
    }, .{}, sdl.ExampleCatalog);
}
