//! RAYLIB-DERIVED: SDL3 port of examples/shapes/shapes_rectangle_scaling.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: rectangle scaling", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var rectangle = sdl.rect.F{ .x = 260, .y = 140, .w = 280, .h = 170 };
    var scaling = false;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_button_down)) {
                const mx = event.button.x;
                const my = event.button.y;
                scaling = mx >= rectangle.x + rectangle.w - 24 and
                    my >= rectangle.y + rectangle.h - 24;
            }
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_button_up)) scaling = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_motion) and scaling) {
                rectangle.w = @max(40, event.motion.x - rectangle.x);
                rectangle.h = @max(40, event.motion.y - rectangle.y);
            }
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(80, 170, 110, 255);
        try renderer.renderFillRect(&rectangle);
        try renderer.setRenderDrawColor(35, 70, 45, 255);
        try renderer.renderRect(&rectangle);
        try renderer.renderFillRect(&.{
            .x = rectangle.x + rectangle.w - 20,
            .y = rectangle.y + rectangle.h - 20,
            .w = 20,
            .h = 20,
        });
        try renderer.renderPresent();
    }
}
