//! Port of SDL's examples/renderer/05-rectangles.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: rectangles", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const outlines = [_]sdl.rect.F{
        .{ .x = 80, .y = 60, .w = 480, .h = 360 },
        .{ .x = 140, .y = 110, .w = 360, .h = 260 },
        .{ .x = 200, .y = 160, .w = 240, .h = 160 },
    };

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(12, 24, 32, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(70, 180, 240, 255);
        try renderer.renderRects(&outlines);
        try renderer.setRenderDrawColor(230, 80, 100, 255);
        try renderer.renderFillRect(&.{ .x = 270, .y = 205, .w = 100, .h = 70 });
        try renderer.renderPresent();
    }
}
