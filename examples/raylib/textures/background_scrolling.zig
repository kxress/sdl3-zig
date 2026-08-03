//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_background_scrolling.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const image = @import("image");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: background scrolling", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const background = image.loadTexture(&renderer, "raylib/cyberpunk_street_background.png") orelse
        return error.SdlFailure;
    defer sdl.render.destroyTexture(background);
    const midground = image.loadTexture(&renderer, "raylib/cyberpunk_street_midground.png") orelse
        return error.SdlFailure;
    defer sdl.render.destroyTexture(midground);
    const foreground = image.loadTexture(&renderer, "raylib/cyberpunk_street_foreground.png") orelse
        return error.SdlFailure;
    defer sdl.render.destroyTexture(foreground);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const ticks: f32 = @floatFromInt(sdl.timer.getTicks());
        try renderer.setRenderDrawColor(20, 20, 30, 255);
        try renderer.renderClear();
        const layers = [_]struct { texture: *sdl.render.Texture, speed: f32 }{
            .{ .texture = background, .speed = 0.010 },
            .{ .texture = midground, .speed = 0.025 },
            .{ .texture = foreground, .speed = 0.050 },
        };
        for (layers) |layer| {
            const offset = -@mod(ticks * layer.speed, 800.0);
            try renderer.renderTexture(layer.texture, null, &.{ .x = offset, .y = 0, .w = 800, .h = 450 });
            try renderer.renderTexture(layer.texture, null, &.{ .x = offset + 800, .y = 0, .w = 800, .h = 450 });
        }
        try renderer.renderPresent();
    }
}
