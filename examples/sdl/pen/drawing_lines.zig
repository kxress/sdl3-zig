//! Port of SDL's examples/pen/01-drawing-lines.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL pen: drawing lines", 800, 600, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var points: [2048]sdl.rect.FPoint = undefined;
    var point_count: usize = 0;
    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.pen_motion)) {
                if (point_count == points.len) point_count = 0;
                points[point_count] = .{ .x = event.pmotion.x, .y = event.pmotion.y };
                point_count += 1;
            }
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_motion)) {
                if (point_count == points.len) point_count = 0;
                points[point_count] = .{ .x = event.motion.x, .y = event.motion.y };
                point_count += 1;
            }
        }
        try renderer.setRenderDrawColor(250, 248, 240, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(18, 35, 48, 255);
        if (point_count > 1) try renderer.renderLines(points[0..point_count]);
        try renderer.setRenderDrawColor(190, 70, 60, 255);
        try renderer.renderDebugText(20, 20, "Draw with a pen or move the mouse.");
        try renderer.renderPresent();
    }
}
