const std = @import("std");
const config = @import("config.zig");

/// Adds repository-only documentation and example steps without polluting package configuration.
pub fn add(b: *std.Build, options: config.PackageOptions, comptime catalog: type) void {
    addProxy(b, options, "docs", "[Documentation] Generate HTML for every public module", false);
    addProxy(b, options, "examples-list", "[Examples] List examples by origin and category", false);
    addProxy(b, options, "examples", "[Examples] Build and install every native example", false);
    addProxy(b, options, "examples-sdl", "[Examples / SDL] Build and install every SDL example", false);
    addProxy(b, options, "examples-raylib", "[Examples / raylib] Build and install every raylib port", false);
    addProxy(b, options, "build-example", "[Examples] Build the example selected with -Dexample", false);
    addProxy(b, options, "run-example", "[Examples] Run the example selected with -Dexample", true);
    addProxy(b, options, "example", "[Examples] Build sdl-renderer-clear (legacy alias)", false);

    for (catalog.examples) |example| {
        addProxy(b, options, example.name, b.fmt(
            "[Examples / {s} / {s}] Build and install {s}",
            .{ example.origin.label(), example.category, example.shortName() },
        ), false);
        addProxy(b, options, b.fmt("run-{s}", .{example.name}), b.fmt(
            "[Examples / {s} / {s}] Run {s}",
            .{ example.origin.label(), example.category, example.shortName() },
        ), true);
    }
}

fn addProxy(
    b: *std.Build,
    options: config.PackageOptions,
    name: []const u8,
    description: []const u8,
    forward_arguments: bool,
) void {
    const step = b.step(name, description);
    const command = b.addSystemCommand(&.{
        b.graph.zig_exe,
        "build",
        "--build-file",
        "build-maintenance.zig",
        name,
        b.fmt("-Dtarget={s}", .{
            options.target.query.zigTriple(b.allocator) catch @panic("OOM"),
        }),
        b.fmt("-Dcpu={s}", .{
            options.target.query.serializeCpuAlloc(b.allocator) catch @panic("OOM"),
        }),
        b.fmt("-Doptimize={s}", .{@tagName(options.optimize)}),
    });
    if (options.requested_distribution) |distribution| {
        command.addArg(b.fmt("-Ddistribution={s}", .{@tagName(distribution)}));
    }
    if (options.target.query.ofmt) |format| {
        command.addArg(b.fmt("-Dofmt={s}", .{@tagName(format)}));
    }
    if (options.target.query.dynamic_linker) |dynamic_linker| {
        command.addArg(b.fmt("-Ddynamic-linker={s}", .{dynamic_linker.get() orelse ""}));
    }
    if (options.selected_example) |example| command.addArg(b.fmt("-Dexample={s}", .{example}));
    if (forward_arguments) {
        if (b.args) |arguments| {
            command.addArg("--");
            command.addArgs(arguments);
        }
    }
    command.setCwd(b.path("."));
    step.dependOn(&command.step);
}
