//! RAYLIB-DERIVED: SDL3 port of examples/core/core_input_mouse_wheel.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: mouse wheel", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var box_y: f32 = 180;
    var message_buffer: [100]u8 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_wheel)) box_y -= event.wheel.y * 20;
        }
        box_y = @max(20, @min(380, box_y));
        const message = try std.fmt.bufPrintZ(&message_buffer, "Box position: {d:.1}", .{box_y});
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(130, 85, 220, 255);
        try renderer.renderFillRect(&.{ .x = 350, .y = box_y, .w = 100, .h = 50 });
        try renderer.setRenderDrawColor(80, 80, 80, 255);
        try renderer.renderDebugText(24, 24, "Use the mouse wheel to move the box.");
        try renderer.renderDebugText(24, 48, message);
        try renderer.renderPresent();
    }
}
