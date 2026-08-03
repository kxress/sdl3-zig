const std = @import("std");

pub const Modules = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    sdl: *std.Build.Module,
    image: *std.Build.Module,
    ttf: *std.Build.Module,
    mixer: *std.Build.Module,
};

const Origin = enum {
    sdl,
    raylib,
};

const Example = struct {
    name: []const u8,
    source: []const u8,
    origin: Origin,
    image: bool = false,
    ttf: bool = false,
    mixer: bool = false,
};

const examples = [_]Example{
    .{ .name = "sdl-asyncio-load-bitmaps", .source = "examples/sdl/asyncio/load_bitmaps.zig", .origin = .sdl },
    .{ .name = "sdl-audio-simple-playback", .source = "examples/sdl/audio/simple_playback.zig", .origin = .sdl },
    .{ .name = "sdl-audio-simple-playback-callback", .source = "examples/sdl/audio/simple_playback_callback.zig", .origin = .sdl },
    .{ .name = "sdl-audio-load-wav", .source = "examples/sdl/audio/load_wav.zig", .origin = .sdl },
    .{ .name = "sdl-audio-multiple-streams", .source = "examples/sdl/audio/multiple_streams.zig", .origin = .sdl },
    .{ .name = "sdl-audio-planar-data", .source = "examples/sdl/audio/planar_data.zig", .origin = .sdl },
    .{ .name = "sdl-camera-read-and-draw", .source = "examples/sdl/camera/read_and_draw.zig", .origin = .sdl },
    .{ .name = "sdl-demo-snake", .source = "examples/sdl/demo/snake.zig", .origin = .sdl },
    .{ .name = "sdl-demo-woodeneye-008", .source = "examples/sdl/demo/woodeneye_008.zig", .origin = .sdl },
    .{ .name = "sdl-demo-infinite-monkeys", .source = "examples/sdl/demo/infinite_monkeys.zig", .origin = .sdl },
    .{ .name = "sdl-demo-bytepusher", .source = "examples/sdl/demo/bytepusher.zig", .origin = .sdl },
    .{ .name = "sdl-input-joystick-polling", .source = "examples/sdl/input/joystick_polling.zig", .origin = .sdl },
    .{ .name = "sdl-input-joystick-events", .source = "examples/sdl/input/joystick_events.zig", .origin = .sdl },
    .{ .name = "sdl-input-gamepad-polling", .source = "examples/sdl/input/gamepad_polling.zig", .origin = .sdl },
    .{ .name = "sdl-input-gamepad-events", .source = "examples/sdl/input/gamepad_events.zig", .origin = .sdl },
    .{ .name = "sdl-input-gamepad-rumble", .source = "examples/sdl/input/gamepad_rumble.zig", .origin = .sdl },
    .{ .name = "sdl-misc-power", .source = "examples/sdl/misc/power.zig", .origin = .sdl },
    .{ .name = "sdl-misc-clipboard", .source = "examples/sdl/misc/clipboard.zig", .origin = .sdl },
    .{ .name = "sdl-misc-locale", .source = "examples/sdl/misc/locale.zig", .origin = .sdl },
    .{ .name = "sdl-pen-drawing-lines", .source = "examples/sdl/pen/drawing_lines.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-clear", .source = "examples/sdl/renderer/clear.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-primitives", .source = "examples/sdl/renderer/primitives.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-lines", .source = "examples/sdl/renderer/lines.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-points", .source = "examples/sdl/renderer/points.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-rectangles", .source = "examples/sdl/renderer/rectangles.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-textures", .source = "examples/sdl/renderer/textures.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-streaming-textures", .source = "examples/sdl/renderer/streaming_textures.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-rotating-textures", .source = "examples/sdl/renderer/rotating_textures.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-scaling-textures", .source = "examples/sdl/renderer/scaling_textures.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-geometry", .source = "examples/sdl/renderer/geometry.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-color-mods", .source = "examples/sdl/renderer/color_mods.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-viewport", .source = "examples/sdl/renderer/viewport.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-cliprect", .source = "examples/sdl/renderer/cliprect.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-read-pixels", .source = "examples/sdl/renderer/read_pixels.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-debug-text", .source = "examples/sdl/renderer/debug_text.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-affine-textures", .source = "examples/sdl/renderer/affine_textures.zig", .origin = .sdl },
    .{ .name = "sdl-renderer-blending", .source = "examples/sdl/renderer/blending.zig", .origin = .sdl },
    .{ .name = "sdl-storage-user", .source = "examples/sdl/storage/user.zig", .origin = .sdl },

    .{ .name = "raylib-core-input-keys", .source = "examples/raylib/core/input_keys.zig", .origin = .raylib },
    .{ .name = "raylib-core-input-mouse", .source = "examples/raylib/core/input_mouse.zig", .origin = .raylib },
    .{ .name = "raylib-core-input-mouse-wheel", .source = "examples/raylib/core/input_mouse_wheel.zig", .origin = .raylib },
    .{ .name = "raylib-core-input-multitouch", .source = "examples/raylib/core/input_multitouch.zig", .origin = .raylib },
    .{ .name = "raylib-core-window-flags", .source = "examples/raylib/core/window_flags.zig", .origin = .raylib },
    .{ .name = "raylib-core-monitor-detector", .source = "examples/raylib/core/monitor_detector.zig", .origin = .raylib },
    .{ .name = "raylib-core-drop-files", .source = "examples/raylib/core/drop_files.zig", .origin = .raylib },
    .{ .name = "raylib-core-highdpi-demo", .source = "examples/raylib/core/highdpi_demo.zig", .origin = .raylib },
    .{ .name = "raylib-core-custom-logging", .source = "examples/raylib/core/custom_logging.zig", .origin = .raylib },
    .{ .name = "raylib-shapes-collision-area", .source = "examples/raylib/shapes/collision_area.zig", .origin = .raylib },
    .{ .name = "raylib-shapes-rectangle-scaling", .source = "examples/raylib/shapes/rectangle_scaling.zig", .origin = .raylib },
    .{ .name = "raylib-textures-background-scrolling", .source = "examples/raylib/textures/background_scrolling.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-textures-bunnymark", .source = "examples/raylib/textures/bunnymark.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-textures-fog-of-war", .source = "examples/raylib/textures/fog_of_war.zig", .origin = .raylib },
    .{ .name = "raylib-textures-gif-player", .source = "examples/raylib/textures/gif_player.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-textures-npatch-drawing", .source = "examples/raylib/textures/npatch_drawing.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-textures-particles-blending", .source = "examples/raylib/textures/particles_blending.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-textures-sprite-animation", .source = "examples/raylib/textures/sprite_animation.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-textures-sprite-button", .source = "examples/raylib/textures/sprite_button.zig", .origin = .raylib, .image = true },
    .{ .name = "raylib-text-input-box", .source = "examples/raylib/text/input_box.zig", .origin = .raylib, .ttf = true },
    .{ .name = "raylib-text-words-alignment", .source = "examples/raylib/text/words_alignment.zig", .origin = .raylib, .ttf = true },
    .{ .name = "raylib-text-writing-anim", .source = "examples/raylib/text/writing_anim.zig", .origin = .raylib, .ttf = true },
    .{ .name = "raylib-audio-module-playing", .source = "examples/raylib/audio/module_playing.zig", .origin = .raylib, .mixer = true },
    .{ .name = "raylib-audio-music-stream", .source = "examples/raylib/audio/music_stream.zig", .origin = .raylib, .mixer = true },
};

pub fn add(b: *std.Build, modules: Modules) void {
    const all = b.step("examples", "Build and install every native example");
    const sdl_examples = b.step("examples-sdl", "Build and install all SDL example ports");
    const raylib_examples = b.step(
        "examples-raylib",
        "Build and install the curated raylib example ports",
    );
    const compatibility = b.step("example", "Build the SDL renderer-clear example");

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

    for (examples) |example| {
        const imports = importsFor(b, modules, example);
        const root_module = b.createModule(.{
            .root_source_file = b.path(example.source),
            .target = modules.target,
            .optimize = modules.optimize,
            .imports = imports,
        });
        const executable = b.addExecutable(.{
            .name = example.name,
            .root_module = root_module,
        });
        executable.root_module.linkSystemLibrary("SDL3", .{});
        if (example.image) executable.root_module.linkSystemLibrary("SDL3_image", .{});
        if (example.ttf) executable.root_module.linkSystemLibrary("SDL3_ttf", .{});
        if (example.mixer) executable.root_module.linkSystemLibrary("SDL3_mixer", .{});

        const install = b.addInstallArtifact(executable, .{});
        install.step.dependOn(if (example.origin == .sdl)
            &install_sdl_assets.step
        else
            &install_raylib_assets.step);

        const origin_step = if (example.origin == .sdl) sdl_examples else raylib_examples;
        origin_step.dependOn(&install.step);
        all.dependOn(&install.step);

        const build_one = b.step(example.name, b.fmt("Build and install {s}", .{example.name}));
        build_one.dependOn(&install.step);
        if (std.mem.eql(u8, example.name, "sdl-renderer-clear")) {
            compatibility.dependOn(&install.step);
        }

        const run = b.addRunArtifact(executable);
        run.setCwd(b.path("examples/assets"));
        const run_step = b.step(
            b.fmt("run-{s}", .{example.name}),
            b.fmt("Run {s}", .{example.name}),
        );
        run_step.dependOn(&run.step);
    }
}

fn importsFor(
    b: *std.Build,
    modules: Modules,
    example: Example,
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
