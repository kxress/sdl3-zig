//! Port of SDL's examples/renderer/10-geometry.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: geometry", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const vertices = [_]sdl.render.Vertex{
        .{ .position = .{ .x = 320, .y = 55 }, .color = .{ .r = 1, .g = 0, .b = 0, .a = 1 }, .tex_coord = .{ .x = 0, .y = 0 } },
        .{ .position = .{ .x = 80, .y = 420 }, .color = .{ .r = 0, .g = 1, .b = 0, .a = 1 }, .tex_coord = .{ .x = 0, .y = 0 } },
        .{ .position = .{ .x = 560, .y = 420 }, .color = .{ .r = 0, .g = 0, .b = 1, .a = 1 }, .tex_coord = .{ .x = 0, .y = 0 } },
    };

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(18, 18, 24, 255);
        try renderer.renderClear();
        try renderer.renderGeometry(null, &vertices, &.{});
        try renderer.renderPresent();
    }
}
