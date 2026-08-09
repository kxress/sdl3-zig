const std = @import("std");
const sdl3 = @import("../build.zig");
const catalog = @import("catalog.zig");

pub const Modules = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    sdl: *std.Build.Module,
    image: *std.Build.Module,
    ttf: *std.Build.Module,
    mixer: *std.Build.Module,
};

pub fn add(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const distribution = b.option(
        sdl3.Distribution,
        "distribution",
        "[Distribution] Native SDL libraries: auto, none, system, prebuilt, or source",
    ) orelse .auto;
    const selected_name = b.option(
        []const u8,
        "example",
        "[Examples] Exact example name used by build-example and run-example",
    );
    const selected_example = if (selected_name) |name| catalog.find(name) else null;
    const modules = sdl3.addRepositoryModulesWithOptions(b, target, optimize, .{
        .distribution = distribution,
        .image = true,
        .ttf = true,
        .mixer = true,
        .source_features = .{ .profile = .desktop },
    });
    const all = b.step("examples", "[Examples] Build and install every native example");
    const sdl_examples = b.step("examples-sdl", "[Examples / SDL] Build every SDL example");
    const raylib_examples = b.step(
        "examples-raylib",
        "[Examples / raylib] Build every curated raylib example port",
    );
    const compatibility = b.step("example", "[Examples] Build sdl-renderer-clear (legacy alias)");
    const build_selected = b.step(
        "build-example",
        "[Examples] Build and install the example selected with -Dexample",
    );
    const run_selected = b.step(
        "run-example",
        "[Examples] Run the example selected with -Dexample",
    );
    const list_executable = b.addExecutable(.{
        .name = "sdl3-example-list",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/list.zig"),
            .target = b.graph.host,
            .optimize = .Debug,
        }),
    });
    const list = b.addRunArtifact(list_executable);
    b.step("examples-list", "[Examples] List available examples by origin and category")
        .dependOn(&list.step);

    const install_sdl_assets = b.addInstallDirectory(.{
        .source_dir = b.path("examples/assets/sdl"),
        .install_dir = .bin,
        .install_subdir = "sdl",
    });
    const install_raylib_assets = b.addInstallDirectory(.{
        .source_dir = b.path("examples/assets/raylib"),
        .install_dir = .bin,
        .install_subdir = "raylib",
    });

    for (catalog.examples) |example| {
        const imports = importsFor(b, .{
            .target = target,
            .optimize = optimize,
            .sdl = modules.sdl,
            .image = modules.image,
            .ttf = modules.ttf,
            .mixer = modules.mixer,
        }, example);
        const root_module = b.createModule(.{
            .root_source_file = b.path(example.source),
            .target = target,
            .optimize = optimize,
            .imports = imports,
        });
        if (target.result.os.tag == .linux) {
            root_module.addRPathSpecial("$ORIGIN/../lib");
        } else if (target.result.os.tag == .macos) {
            root_module.addRPathSpecial("@executable_path/../lib");
        }
        const executable = b.addExecutable(.{
            .name = example.name,
            .root_module = root_module,
        });
        if (modules.native_build) |native_build| executable.step.dependOn(native_build);

        const install = b.addInstallArtifact(executable, .{});
        install.step.dependOn(if (example.origin == .sdl)
            &install_sdl_assets.step
        else
            &install_raylib_assets.step);

        const origin_step = if (example.origin == .sdl) sdl_examples else raylib_examples;
        origin_step.dependOn(&install.step);
        all.dependOn(&install.step);

        const build_one = b.step(example.name, b.fmt(
            "[Examples / {s} / {s}] Build and install {s}",
            .{ example.origin.label(), example.category, example.shortName() },
        ));
        build_one.dependOn(&install.step);
        if (std.mem.eql(u8, example.name, "sdl-renderer-clear")) {
            compatibility.dependOn(&install.step);
        }

        const run = b.addRunArtifact(executable);
        run.setCwd(b.path("examples/assets"));
        if (b.args) |arguments| run.addArgs(arguments);
        const run_step = b.step(
            b.fmt("run-{s}", .{example.name}),
            b.fmt(
                "[Examples / {s} / {s}] Run {s}",
                .{ example.origin.label(), example.category, example.shortName() },
            ),
        );
        run_step.dependOn(&run.step);

        if (selected_example) |selection| {
            if (std.mem.eql(u8, selection.name, example.name)) {
                build_selected.dependOn(&install.step);
                run_selected.dependOn(&run.step);
            }
        }
    }

    if (selected_example == null) {
        const reason = if (selected_name) |name|
            b.fmt("unknown example '{s}'; run 'zig build examples-list' to see valid names", .{name})
        else
            "missing -Dexample=<name>; run 'zig build examples-list' to see valid names";
        const selection_error = b.addFail(reason);
        build_selected.dependOn(&selection_error.step);
        run_selected.dependOn(&selection_error.step);
    }
}

fn importsFor(
    b: *std.Build,
    modules: Modules,
    example: catalog.Example,
) []const std.Build.Module.Import {
    var imports: std.ArrayList(std.Build.Module.Import) = .empty;
    imports.append(b.allocator, .{ .name = "sdl", .module = modules.sdl }) catch @panic("OOM");
    if (example.image) {
        imports.append(b.allocator, .{ .name = "image", .module = modules.image }) catch
            @panic("OOM");
    }
    if (example.ttf) {
        imports.append(b.allocator, .{ .name = "ttf", .module = modules.ttf }) catch
            @panic("OOM");
    }
    if (example.mixer) {
        imports.append(b.allocator, .{ .name = "mixer", .module = modules.mixer }) catch
            @panic("OOM");
    }
    return imports.toOwnedSlice(b.allocator) catch @panic("OOM");
}
