//! Port of SDL's examples/renderer/09-scaling-textures.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: scaling texture", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const surface = try sdl.surface.loadPng("sdl/sample.png");
    defer sdl.surface.destroy(surface);
    const texture = try renderer.createTextureFromSurface(surface);
    defer sdl.render.destroyTexture(texture);

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const phase: f32 = @as(f32, @floatFromInt(sdl.timer.getTicks())) / 700.0;
        const size = 180.0 + @sin(phase) * 110.0;
        try renderer.setRenderDrawColor(25, 20, 32, 255);
        try renderer.renderClear();
        try renderer.renderTexture(
            texture,
            null,
            &.{ .x = 320 - size / 2, .y = 240 - size / 2, .w = size, .h = size },
        );
        try renderer.renderPresent();
    }
}
