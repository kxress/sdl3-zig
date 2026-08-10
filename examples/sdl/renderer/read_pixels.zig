//! Port of SDL's examples/renderer/17-read-pixels.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: read pixels", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var last_capture: u64 = 0;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const ticks = sdl.timer.getTicks();
        try renderer.setRenderDrawColor(20, 22, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(60, 180, 240, 255);
        const x = 40.0 + @as(f32, @floatFromInt((ticks / 4) % 500));
        try renderer.renderFillRect(&.{ .x = x, .y = 180, .w = 100, .h = 100 });
        if (ticks - last_capture >= 1000) {
            const captured = try sdl.render.readPixels(renderer, null);
            sdl.surface.destroy(captured);
            last_capture = ticks;
        }
        try renderer.renderPresent();
    }
}
