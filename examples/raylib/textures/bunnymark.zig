//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_bunnymark.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const image = @import("image");
const sdl = @import("sdl");

const Bunny = struct { x: f32, y: f32, vx: f32, vy: f32, color: [3]u8 };

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: bunnymark", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = image.loadTexture(&renderer, "raylib/raybunny.png") orelse return error.SdlFailure;
    defer sdl.render.destroyTexture(texture);
    var bunnies: [5000]Bunny = undefined;
    var count: usize = 0;
    var random: u32 = 0x1234abcd;
    var line_buffer: [100]u8 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const mouse = sdl.mouse.getState();
        if (mouse.value != 0) {
            var added: usize = 0;
            while (added < 100 and count < bunnies.len) : (added += 1) {
                random = random *% 1664525 +% 1013904223;
                bunnies[count] = .{
                    .x = mouse.x,
                    .y = mouse.y,
                    .vx = @as(f32, @floatFromInt(@as(i32, @intCast(random % 500)) - 250)) / 50.0,
                    .vy = @as(f32, @floatFromInt(@as(i32, @intCast((random >> 9) % 500)) - 250)) / 50.0,
                    .color = .{ @truncate(random), @truncate(random >> 8), @truncate(random >> 16) },
                };
                count += 1;
            }
        }
        for (bunnies[0..count]) |*bunny| {
            bunny.x += bunny.vx;
            bunny.y += bunny.vy;
            if (bunny.x < 0 or bunny.x > 780) bunny.vx = -bunny.vx;
            if (bunny.y < 40 or bunny.y > 430) bunny.vy = -bunny.vy;
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        for (bunnies[0..count]) |bunny| {
            try sdl.render.setTextureColorMod(texture, bunny.color[0], bunny.color[1], bunny.color[2]);
            try renderer.renderTexture(texture, null, &.{ .x = bunny.x, .y = bunny.y, .w = 20, .h = 20 });
        }
        try sdl.render.setTextureColorMod(texture, 255, 255, 255);
        const line = try std.fmt.bufPrintZ(&line_buffer, "Bunnies: {d} (hold mouse button to add)", .{count});
        try renderer.setRenderDrawColor(55, 55, 65, 255);
        try renderer.renderDebugText(16, 16, line);
        try renderer.renderPresent();
    }
}
