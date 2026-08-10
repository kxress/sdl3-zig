const std = @import("std");
const sdl = @import("build.zig");
const example_environment = @import("examples/environment.zig");
const example_project = @import("examples/project.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const environment = example_environment.load(b);
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

    const requested_example_distribution = b.option(
        sdl.Distribution,
        "distribution",
        "[Distribution] Native SDL libraries: auto, none, system, prebuilt, or source",
    );
    const default_example_distribution: sdl.Distribution = if (target.result.os.tag == .windows)
        .prebuilt
    else
        .auto;
    const example_distribution: sdl.Distribution = requested_example_distribution orelse
        distributionFromEnvironment(environment.distribution) orelse
        default_example_distribution;
    if (target.result.os.tag == .windows and example_distribution == .prebuilt) {
        requireWindowsExamplePrebuilts(b, target);
    }
    var source_cmake_options: std.ArrayList([]const u8) = .empty;
    appendCmakeOption(b, &source_cmake_options, "CMAKE_C_COMPILER", environment.cmake_c_compiler);
    appendCmakeOption(b, &source_cmake_options, "CMAKE_CXX_COMPILER", environment.cmake_cxx_compiler);
    appendCmakeOption(b, &source_cmake_options, "CMAKE_MAKE_PROGRAM", environment.cmake_make_program);
    const example_modules = sdl.addRepositoryModulesWithOptions(b, target, optimize, .{
        .distribution = example_distribution,
        .image = true,
        .ttf = true,
        .mixer = true,
        .source_cmake_generator = environment.cmake_generator,
        .source_cmake_options = source_cmake_options.items,
        .source_features = .{ .profile = .desktop },
    });
    const test_ping = b.createModule(.{
        .root_source_file = b.path("examples/test_ping.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_project.add(b, .{
        .target = target,
        .optimize = optimize,
        .native_build = example_modules.native_build,
        .prebuilt_runtime_files = example_modules.prebuilt_runtime_files,
        .sdl = example_modules.sdl,
        .image = example_modules.image,
        .ttf = example_modules.ttf,
        .mixer = example_modules.mixer,
        .test_ping = test_ping,
    }, .{}, sdl.ExampleCatalog);
}

fn distributionFromEnvironment(value: ?[]const u8) ?sdl.Distribution {
    return switch (example_environment.parseDistribution(value orelse return null)) {
        .auto => .auto,
        .none => .none,
        .system => .system,
        .prebuilt => .prebuilt,
        .source => .source,
    };
}

fn appendCmakeOption(
    b: *std.Build,
    options: *std.ArrayList([]const u8),
    name: []const u8,
    value: ?[]const u8,
) void {
    const text = value orelse return;
    options.append(b.allocator, b.fmt("-D{s}={s}", .{ name, text })) catch @panic("OOM");
}

fn requireWindowsExamplePrebuilts(b: *std.Build, target: std.Build.ResolvedTarget) void {
    if (target.result.abi != .gnu) return;
    const root = b.fmt(
        "prebuilt/sdl/windows-gnu/{s}/lib/libSDL3.dll.a",
        .{@tagName(target.result.cpu.arch)},
    );
    b.build_root.handle.access(b.graph.io, root, .{}) catch {
        std.debug.panic(
            "Windows GNU examples require the verified SDL prebuilts; run 'deno task fetch' before building examples",
            .{},
        );
    };
}
