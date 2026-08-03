//! RAYLIB-DERIVED: SDL3 port of examples/core/core_input_keys.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: input keys", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var x: f32 = 400;
    var y: f32 = 225;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const keys = sdl.keyboard.getState();
        if (keys[@intFromEnum(sdl.scancode.Scancode.scancode_left)]) x -= 4;
        if (keys[@intFromEnum(sdl.scancode.Scancode.scancode_right)]) x += 4;
        if (keys[@intFromEnum(sdl.scancode.Scancode.scancode_up)]) y -= 4;
        if (keys[@intFromEnum(sdl.scancode.Scancode.scancode_down)]) y += 4;
        x = @max(12, @min(788, x));
        y = @max(12, @min(438, y));
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(120, 70, 220, 255);
        try renderer.renderFillRect(&.{ .x = x - 12, .y = y - 12, .w = 24, .h = 24 });
        try renderer.setRenderDrawColor(90, 90, 90, 255);
        try renderer.renderDebugText(230, 32, "Move the box with the arrow keys");
        try renderer.renderPresent();
    }
}
