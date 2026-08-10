//! Port of SDL's examples/misc/01-power.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL misc: power", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var message_buffer: [160]u8 = undefined;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const info = try sdl.power.getInfo();
        const state = switch (info.value) {
            .unknown => "unknown",
            .on_battery => "on battery",
            .no_battery => "plugged in, no battery",
            .charging => "charging",
            .charged => "charged",
            else => "error",
        };
        const message = try std.fmt.bufPrintZ(
            &message_buffer,
            "Power: {s}; {d}% / {d}s",
            .{ state, info.percent, info.seconds },
        );
        try renderer.setRenderDrawColor(24, 28, 34, 255);
        try renderer.renderClear();
        if (info.percent >= 0) {
            const width = 440.0 * @as(f32, @floatFromInt(info.percent)) / 100.0;
            try renderer.setRenderDrawColor(50, 210, 100, 255);
            try renderer.renderFillRect(&.{ .x = 100, .y = 200, .w = width, .h = 80 });
            try renderer.setRenderDrawColor(255, 255, 255, 255);
            try renderer.renderRect(&.{ .x = 100, .y = 200, .w = 440, .h = 80 });
        }
        try renderer.setRenderDrawColor(255, 255, 255, 255);
        try renderer.renderDebugText(100, 300, message);
        try renderer.renderPresent();
    }
}
