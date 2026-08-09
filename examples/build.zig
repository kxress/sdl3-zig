const std = @import("std");
const catalog = @import("catalog.zig");

const Distribution = enum { auto, none, system, prebuilt, source };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const distribution = b.option(
        Distribution,
        "distribution",
        "[Distribution] Native SDL libraries: auto, none, system, prebuilt, or source",
    );
    const selected_example = b.option(
        []const u8,
        "example",
        "[Examples] Exact name used by build-example and run-example",
    );

    addProxy(b, target, optimize, distribution, selected_example, "examples-list", "[Examples] List examples by origin and category", false);
    addProxy(b, target, optimize, distribution, selected_example, "examples", "[Examples] Build and install every native example", false);
    addProxy(b, target, optimize, distribution, selected_example, "examples-sdl", "[Examples / SDL] Build every SDL example", false);
    addProxy(b, target, optimize, distribution, selected_example, "examples-raylib", "[Examples / raylib] Build every raylib port", false);
    addProxy(b, target, optimize, distribution, selected_example, "build-example", "[Examples] Build the example selected with -Dexample", false);
    addProxy(b, target, optimize, distribution, selected_example, "run-example", "[Examples] Run the example selected with -Dexample", true);
    addProxy(b, target, optimize, distribution, selected_example, "example", "[Examples] Build sdl-renderer-clear (legacy alias)", false);

    for (catalog.examples) |example| {
        addProxy(b, target, optimize, distribution, selected_example, example.name, b.fmt(
            "[Examples / {s} / {s}] Build and install {s}",
            .{ example.origin.label(), example.category, example.shortName() },
        ), false);
        addProxy(b, target, optimize, distribution, selected_example, b.fmt("run-{s}", .{example.name}), b.fmt(
            "[Examples / {s} / {s}] Run {s}",
            .{ example.origin.label(), example.category, example.shortName() },
        ), true);
    }
}

fn addProxy(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    distribution: ?Distribution,
    selected_example: ?[]const u8,
    name: []const u8,
    description: []const u8,
    forward_arguments: bool,
) void {
    const step = b.step(name, description);
    const command = b.addSystemCommand(&.{
        b.graph.zig_exe,
        "build",
        "--build-file",
        "../build.zig",
        name,
        b.fmt("-Dtarget={s}", .{target.query.zigTriple(b.allocator) catch @panic("OOM")}),
        b.fmt("-Dcpu={s}", .{target.query.serializeCpuAlloc(b.allocator) catch @panic("OOM")}),
        b.fmt("-Doptimize={s}", .{@tagName(optimize)}),
    });
    if (distribution) |value| {
        command.addArg(b.fmt("-Ddistribution={s}", .{@tagName(value)}));
    }
    if (target.query.ofmt) |format| {
        command.addArg(b.fmt("-Dofmt={s}", .{@tagName(format)}));
    }
    if (target.query.dynamic_linker) |dynamic_linker| {
        command.addArg(b.fmt("-Ddynamic-linker={s}", .{dynamic_linker.get() orelse ""}));
    }
    if (selected_example) |example| command.addArg(b.fmt("-Dexample={s}", .{example}));
    if (forward_arguments) {
        if (b.args) |arguments| {
            command.addArg("--");
            command.addArgs(arguments);
        }
    }
    step.dependOn(&command.step);
}
