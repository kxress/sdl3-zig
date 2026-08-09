//! Port of SDL's examples/renderer/01-clear.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();

    const result = try sdl.render.createWindowAndRenderer(
        "SDL renderer: clear",
        640,
        480,
        .{},
    );
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            if (polled.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }

        const now: f32 = @floatFromInt(sdl.timer.getTicks());
        const red = 0.5 + 0.5 * @sin(now / 1000.0);
        const green = 0.5 + 0.5 * @sin(now / 1000.0 + 2.0);
        const blue = 0.5 + 0.5 * @sin(now / 1000.0 + 4.0);
        try renderer.setRenderDrawColorFloat(red, green, blue, 1.0);
        try renderer.renderClear();
        try renderer.renderPresent();
    }
}
