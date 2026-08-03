//! Port of SDL's examples/renderer/15-cliprect.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: clip rectangle", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const clip = sdl.rect.Rect{ .x = 160, .y = 100, .w = 320, .h = 280 };

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(20, 20, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderClipRect(&clip);
        try renderer.setRenderDrawColor(30, 170, 240, 255);
        var x: f32 = -100;
        while (x < 700) : (x += 35) try renderer.renderLine(x, 0, x + 240, 480);
        try renderer.setRenderClipRect(null);
        try renderer.setRenderDrawColor(255, 255, 255, 255);
        try renderer.renderRect(&.{ .x = 160, .y = 100, .w = 320, .h = 280 });
        try renderer.renderPresent();
    }
}
