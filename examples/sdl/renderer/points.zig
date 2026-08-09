//! Port of SDL's examples/renderer/04-points.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: points", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var points: [500]sdl.rect.FPoint = undefined;
    for (&points, 0..) |*point, i| {
        point.* = .{
            .x = @floatFromInt((i * 97) % 640),
            .y = @floatFromInt((i * 57) % 480),
        };
    }
    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(18, 18, 28, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(255, 210, 32, 255);
        try renderer.renderPoints(&points);
        try renderer.renderPresent();
    }
}
