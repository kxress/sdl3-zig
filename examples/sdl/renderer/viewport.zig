//! Port of SDL's examples/renderer/14-viewport.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: viewport", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    const viewports = [_]sdl.rect.Rect{
        .{ .x = 0, .y = 0, .w = 320, .h = 240 },
        .{ .x = 320, .y = 0, .w = 320, .h = 240 },
        .{ .x = 0, .y = 240, .w = 320, .h = 240 },
        .{ .x = 320, .y = 240, .w = 320, .h = 240 },
    };
    const colors = [_][4]u8{
        .{ 230, 70, 70, 255 },
        .{ 70, 200, 90, 255 },
        .{ 70, 120, 230, 255 },
        .{ 220, 190, 60, 255 },
    };
    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        for (viewports, colors) |viewport, color| {
            try renderer.setRenderViewport(&viewport);
            try renderer.setRenderDrawColor(color[0], color[1], color[2], color[3]);
            try renderer.renderClear();
            try renderer.setRenderDrawColor(255, 255, 255, 255);
            try renderer.renderLine(0, 0, 320, 240);
        }
        try renderer.setRenderViewport(null);
        try renderer.renderPresent();
    }
}
