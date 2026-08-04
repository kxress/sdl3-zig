const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(sdl3.Linkage, "linkage", "Selected SDL linkage") orelse .shared;
    const image = b.option(bool, "image", "Enable SDL_image") orelse false;
    const ttf = b.option(bool, "ttf", "Enable SDL_ttf") orelse false;
    const mixer = b.option(bool, "mixer", "Enable SDL_mixer") orelse false;
    const net = b.option(bool, "net", "Enable SDL_net") orelse false;
    const optional_codecs = b.option(
        bool,
        "optional_codecs",
        "Install optional image and mixer codecs",
    ) orelse false;
    const install_runtime = b.option(
        bool,
        "install_runtime",
        "Install shared libraries next to the consumer",
    ) orelse true;
    const distribution = b.option(
        sdl3.Distribution,
        "distribution",
        "Select none, system, or prebuilt",
    ) orelse .none;
    if (!image) @panic("the provided SDL fixture requires -Dimage=true");

    const executable = b.addExecutable(.{
        .name = "sdl-distribution-consumer",
        .root_module = b.createModule(.{
            .root_source_file = b.path(if (image and ttf and mixer and net)
                "all.zig"
            else
                "image.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    _ = sdl3.addTo(b, executable, .{
        .distribution = distribution,
        .linkage = linkage,
        .image = image,
        .ttf = ttf,
        .mixer = mixer,
        .net = net,
        .optional_codecs = optional_codecs,
        .install_runtime = install_runtime,
    });
    b.installArtifact(executable);
}
