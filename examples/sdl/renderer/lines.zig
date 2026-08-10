//! Port of SDL's examples/renderer/03-lines.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: lines", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const ticks: f32 = @floatFromInt(sdl.timer.getTicks());
        const center_x: f32 = 320;
        const center_y: f32 = 240;
        try renderer.setRenderDrawColor(0, 0, 0, 255);
        try renderer.renderClear();
        var spoke: usize = 0;
        while (spoke < 48) : (spoke += 1) {
            const angle = ticks / 800.0 + @as(f32, @floatFromInt(spoke)) * std.math.tau / 48.0;
            try renderer.setRenderDrawColor(
                @intFromFloat(128.0 + 127.0 * @sin(angle)),
                @intFromFloat(128.0 + 127.0 * @sin(angle + 2.0)),
                255,
                255,
            );
            try renderer.renderLine(
                center_x,
                center_y,
                center_x + @cos(angle) * 210.0,
                center_y + @sin(angle) * 210.0,
            );
        }
        try renderer.renderPresent();
    }
}

const std = @import("std");
