//! RAYLIB-DERIVED: SDL3 port of examples/core/core_input_mouse.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: input mouse", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const mouse = sdl.mouse.getState();
        const color: [3]u8 = if (mouse.value != 0) .{ 230, 70, 80 } else .{ 90, 150, 235 };
        try renderer.setRenderDrawColor(248, 248, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(color[0], color[1], color[2], 255);
        try renderer.renderFillRect(&.{ .x = mouse.x - 20, .y = mouse.y - 20, .w = 40, .h = 40 });
        try renderer.setRenderDrawColor(80, 80, 80, 255);
        try renderer.renderDebugText(24, 24, "The marker follows the mouse; click to change color.");
        try renderer.renderPresent();
    }
}
