//! Port of SDL's examples/renderer/02-primitives.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: primitives", 640, 480, .{});
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
        try renderer.setRenderDrawColor(33, 33, 33, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(255, 255, 255, 255);
        try renderer.renderLine(20, 20, 620, 460);
        try renderer.renderLine(20, 460, 620, 20);
        try renderer.renderRect(&.{ .x = 100, .y = 80, .w = 440, .h = 320 });
        try renderer.setRenderDrawColor(0, 160, 255, 255);
        try renderer.renderFillRect(&.{ .x = 260, .y = 180, .w = 120, .h = 120 });
        try renderer.renderPresent();
    }
}
