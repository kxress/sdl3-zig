const std = @import("std");

pub const Origin = enum {
    sdl,
    raylib,

    pub fn label(origin: @This()) []const u8 {
        return switch (origin) {
            .sdl => "SDL",
            .raylib => "raylib",
        };
    }

    pub fn prefix(origin: @This()) []const u8 {
        return @tagName(origin);
    }
};

/// One native example exposed through the repository build.
pub const Example = struct {
    /// Stable build-step and executable name.
    name: []const u8,
    /// Repository-relative Zig entrypoint.
    source: []const u8,
    origin: Origin,
    /// Display category used by help and `examples-list`.
    category: []const u8,
    image: bool = false,
    ttf: bool = false,
    mixer: bool = false,

    pub fn shortName(example: @This()) []const u8 {
        const prefix_length = example.origin.prefix().len + example.category.len + 2;
        return example.name[prefix_length..];
    }
};

/// Authoritative example inventory, ordered by origin and category for readable build help.
pub const examples = [_]Example{
    .{ .name = "sdl-asyncio-load-bitmaps", .source = "examples/sdl/asyncio/load_bitmaps.zig", .origin = .sdl, .category = "asyncio" },
    .{ .name = "sdl-audio-simple-playback", .source = "examples/sdl/audio/simple_playback.zig", .origin = .sdl, .category = "audio" },
    .{ .name = "sdl-audio-simple-playback-callback", .source = "examples/sdl/audio/simple_playback_callback.zig", .origin = .sdl, .category = "audio" },
    .{ .name = "sdl-audio-load-wav", .source = "examples/sdl/audio/load_wav.zig", .origin = .sdl, .category = "audio" },
    .{ .name = "sdl-audio-multiple-streams", .source = "examples/sdl/audio/multiple_streams.zig", .origin = .sdl, .category = "audio" },
    .{ .name = "sdl-audio-planar-data", .source = "examples/sdl/audio/planar_data.zig", .origin = .sdl, .category = "audio" },
    .{ .name = "sdl-camera-read-and-draw", .source = "examples/sdl/camera/read_and_draw.zig", .origin = .sdl, .category = "camera" },
    .{ .name = "sdl-demo-snake", .source = "examples/sdl/demo/snake.zig", .origin = .sdl, .category = "demo" },
    .{ .name = "sdl-demo-woodeneye-008", .source = "examples/sdl/demo/woodeneye_008.zig", .origin = .sdl, .category = "demo" },
    .{ .name = "sdl-demo-infinite-monkeys", .source = "examples/sdl/demo/infinite_monkeys.zig", .origin = .sdl, .category = "demo" },
    .{ .name = "sdl-demo-bytepusher", .source = "examples/sdl/demo/bytepusher.zig", .origin = .sdl, .category = "demo" },
    .{ .name = "sdl-input-joystick-polling", .source = "examples/sdl/input/joystick_polling.zig", .origin = .sdl, .category = "input" },
    .{ .name = "sdl-input-joystick-events", .source = "examples/sdl/input/joystick_events.zig", .origin = .sdl, .category = "input" },
    .{ .name = "sdl-input-gamepad-polling", .source = "examples/sdl/input/gamepad_polling.zig", .origin = .sdl, .category = "input" },
    .{ .name = "sdl-input-gamepad-events", .source = "examples/sdl/input/gamepad_events.zig", .origin = .sdl, .category = "input" },
    .{ .name = "sdl-input-gamepad-rumble", .source = "examples/sdl/input/gamepad_rumble.zig", .origin = .sdl, .category = "input" },
    .{ .name = "sdl-misc-power", .source = "examples/sdl/misc/power.zig", .origin = .sdl, .category = "misc" },
    .{ .name = "sdl-misc-clipboard", .source = "examples/sdl/misc/clipboard.zig", .origin = .sdl, .category = "misc" },
    .{ .name = "sdl-misc-locale", .source = "examples/sdl/misc/locale.zig", .origin = .sdl, .category = "misc" },
    .{ .name = "sdl-pen-drawing-lines", .source = "examples/sdl/pen/drawing_lines.zig", .origin = .sdl, .category = "pen" },
    .{ .name = "sdl-renderer-clear", .source = "examples/sdl/renderer/clear.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-primitives", .source = "examples/sdl/renderer/primitives.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-lines", .source = "examples/sdl/renderer/lines.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-points", .source = "examples/sdl/renderer/points.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-rectangles", .source = "examples/sdl/renderer/rectangles.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-textures", .source = "examples/sdl/renderer/textures.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-streaming-textures", .source = "examples/sdl/renderer/streaming_textures.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-rotating-textures", .source = "examples/sdl/renderer/rotating_textures.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-scaling-textures", .source = "examples/sdl/renderer/scaling_textures.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-geometry", .source = "examples/sdl/renderer/geometry.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-color-mods", .source = "examples/sdl/renderer/color_mods.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-viewport", .source = "examples/sdl/renderer/viewport.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-cliprect", .source = "examples/sdl/renderer/cliprect.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-read-pixels", .source = "examples/sdl/renderer/read_pixels.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-debug-text", .source = "examples/sdl/renderer/debug_text.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-affine-textures", .source = "examples/sdl/renderer/affine_textures.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-renderer-blending", .source = "examples/sdl/renderer/blending.zig", .origin = .sdl, .category = "renderer" },
    .{ .name = "sdl-shader-device-load", .source = "examples/shaders/load.zig", .origin = .sdl, .category = "shader" },
    .{ .name = "sdl-storage-user", .source = "examples/sdl/storage/user.zig", .origin = .sdl, .category = "storage" },

    .{ .name = "raylib-core-input-keys", .source = "examples/raylib/core/input_keys.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-input-mouse", .source = "examples/raylib/core/input_mouse.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-input-mouse-wheel", .source = "examples/raylib/core/input_mouse_wheel.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-input-multitouch", .source = "examples/raylib/core/input_multitouch.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-window-flags", .source = "examples/raylib/core/window_flags.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-monitor-detector", .source = "examples/raylib/core/monitor_detector.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-drop-files", .source = "examples/raylib/core/drop_files.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-highdpi-demo", .source = "examples/raylib/core/highdpi_demo.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-core-custom-logging", .source = "examples/raylib/core/custom_logging.zig", .origin = .raylib, .category = "core" },
    .{ .name = "raylib-shapes-collision-area", .source = "examples/raylib/shapes/collision_area.zig", .origin = .raylib, .category = "shapes" },
    .{ .name = "raylib-shapes-rectangle-scaling", .source = "examples/raylib/shapes/rectangle_scaling.zig", .origin = .raylib, .category = "shapes" },
    .{ .name = "raylib-textures-background-scrolling", .source = "examples/raylib/textures/background_scrolling.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-textures-bunnymark", .source = "examples/raylib/textures/bunnymark.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-textures-fog-of-war", .source = "examples/raylib/textures/fog_of_war.zig", .origin = .raylib, .category = "textures" },
    .{ .name = "raylib-textures-gif-player", .source = "examples/raylib/textures/gif_player.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-textures-npatch-drawing", .source = "examples/raylib/textures/npatch_drawing.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-textures-particles-blending", .source = "examples/raylib/textures/particles_blending.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-textures-sprite-animation", .source = "examples/raylib/textures/sprite_animation.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-textures-sprite-button", .source = "examples/raylib/textures/sprite_button.zig", .origin = .raylib, .category = "textures", .image = true },
    .{ .name = "raylib-text-input-box", .source = "examples/raylib/text/input_box.zig", .origin = .raylib, .category = "text", .ttf = true },
    .{ .name = "raylib-text-words-alignment", .source = "examples/raylib/text/words_alignment.zig", .origin = .raylib, .category = "text", .ttf = true },
    .{ .name = "raylib-text-writing-anim", .source = "examples/raylib/text/writing_anim.zig", .origin = .raylib, .category = "text", .ttf = true },
    .{ .name = "raylib-audio-module-playing", .source = "examples/raylib/audio/module_playing.zig", .origin = .raylib, .category = "audio", .mixer = true },
    .{ .name = "raylib-audio-music-stream", .source = "examples/raylib/audio/music_stream.zig", .origin = .raylib, .category = "audio", .mixer = true },
};

pub fn find(name: []const u8) ?Example {
    for (examples) |example| {
        if (std.mem.eql(u8, example.name, name)) return example;
    }
    return null;
}

comptime {
    @setEvalBranchQuota(10_000);
    for (examples, 0..) |example, index| {
        const prefix = example.origin.prefix();
        const category_start = prefix.len + 1;
        const short_name_start = category_start + example.category.len + 1;
        if (!std.mem.startsWith(u8, example.name, prefix) or
            example.name.len <= short_name_start or
            example.name[prefix.len] != '-' or
            !std.mem.startsWith(u8, example.name[category_start..], example.category) or
            example.name[short_name_start - 1] != '-' or
            !std.mem.startsWith(u8, example.source, "examples/"))
        {
            @compileError("example names must match <origin>-<category>-<name>");
        }
        for (examples[index + 1 ..]) |other| {
            if (std.mem.eql(u8, example.name, other.name)) {
                @compileError("example names must be unique");
            }
        }
    }
}
