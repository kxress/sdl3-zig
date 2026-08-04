const std = @import("std");

const Linkage = enum { static, shared };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(Linkage, "linkage", "System library linkage") orelse .shared;
    const allow_unknown_system_versions = b.option(
        bool,
        "allow_unknown_system_versions",
        "Allow system SDL libraries without discoverable pkg-config versions",
    ) orelse false;
    const system_version_overrides = b.option(
        []const []const u8,
        "system_version_overrides",
        "Component=version overrides for system SDL libraries",
    ) orelse &.{};
    const image = b.option(bool, "link_image", "Link SDL_image dynamically") orelse false;
    const ttf = b.option(bool, "link_ttf", "Link SDL_ttf dynamically") orelse false;
    const mixer = b.option(bool, "link_mixer", "Link SDL_mixer dynamically") orelse false;
    const net = b.option(bool, "link_net", "Link SDL_net dynamically") orelse false;
    const all = image and ttf and mixer and net;
    if (!image or (!all and (ttf or mixer or net))) {
        @panic("the system SDL fixture supports image-only or all companions");
    }

    const dependency = b.dependency("sdl3", .{
        .target = target,
        .optimize = optimize,
        .link_sdl = true,
        .link_image = image,
        .link_ttf = ttf,
        .link_mixer = mixer,
        .link_net = net,
        .linkage = linkage,
        .distribution = .system,
        .allow_unknown_system_versions = allow_unknown_system_versions,
        .system_version_overrides = system_version_overrides,
    });
    const executable = b.addExecutable(.{
        .name = "system-sdl-check",
        .root_module = b.createModule(.{
            .root_source_file = b.path(if (all) "all.zig" else "image.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    executable.root_module.addImport("sdl", dependency.module("sdl"));
    executable.root_module.addImport("image", dependency.module("image"));
    if (all) {
        executable.root_module.addImport("ttf", dependency.module("ttf"));
        executable.root_module.addImport("mixer", dependency.module("mixer"));
        executable.root_module.addImport("net", dependency.module("net"));
    }

    addSystemLibrary(b, executable, target, optimize, linkage, "SDL3", "core_link_pattern");
    addSystemLibrary(b, executable, target, optimize, linkage, "SDL3_image", "image_link_pattern");
    if (all) {
        addSystemLibrary(b, executable, target, optimize, linkage, "SDL3_ttf", "ttf_link_pattern");
        addSystemLibrary(b, executable, target, optimize, linkage, "SDL3_mixer", "mixer_link_pattern");
        addSystemLibrary(b, executable, target, optimize, linkage, "SDL3_net", "net_link_pattern");
    }
    b.default_step.dependOn(&executable.step);
}

fn addSystemLibrary(
    b: *std.Build,
    executable: *std.Build.Step.Compile,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    linkage: Linkage,
    name: []const u8,
    symbol: []const u8,
) void {
    const options = b.addOptions();
    options.addOption([]const u8, "symbol", symbol);
    const library = b.addLibrary(.{
        .name = name,
        .linkage = switch (linkage) {
            .static => .static,
            .shared => .dynamic,
        },
        .root_module = b.createModule(.{
            .root_source_file = b.path("library.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    library.root_module.addOptions("fixture", options);
    executable.root_module.addLibraryPath(library.getEmittedBinDirectory());
}
