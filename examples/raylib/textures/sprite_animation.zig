//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_sprite_animation.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const image = @import("image");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: sprite animation", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = image.loadTexture(&renderer, "raylib/scarfy.png") orelse return error.SdlFailure;
    defer sdl.render.destroyTexture(texture);
    const size = try sdl.render.getTextureSize(texture);
    var speed: u32 = 8;
    var line_buffer: [80]u8 = undefined;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down) and !event.key.repeat) {
                if (event.key.scancode == .scancode_right) speed = @min(15, speed + 1);
                if (event.key.scancode == .scancode_left) speed = @max(1, speed - 1);
            }
        }
        const frame = (sdl.timer.getTicks() * speed / 1000) % 6;
        const frame_width = size.w / 6;
        const source = sdl.rect.F{
            .x = @as(f32, @floatFromInt(frame)) * frame_width,
            .y = 0,
            .w = frame_width,
            .h = size.h,
        };
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, &source, &.{ .x = 350, .y = 245, .w = frame_width, .h = size.h });
        const line = try std.fmt.bufPrintZ(&line_buffer, "Animation speed: {d} FPS", .{speed});
        try renderer.setRenderDrawColor(65, 65, 70, 255);
        try renderer.renderDebugText(280, 200, line);
        try renderer.renderDebugText(240, 220, "Use left/right arrows to change speed.");
        try renderer.renderPresent();
    }
}
