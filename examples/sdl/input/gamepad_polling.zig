//! Port of SDL's examples/input/03-gamepad-polling.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .gamepad = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL input: gamepad polling", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const ids = try sdl.gamepad.getGamepads(std.heap.page_allocator);
    defer std.heap.page_allocator.free(ids);
    var gamepad: ?sdl.gamepad.Gamepad = if (ids.len > 0) sdl.gamepad.open(ids[0]) else null;
    defer if (gamepad) |*device| device.close();

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(22, 25, 32, 255);
        try renderer.renderClear();
        if (gamepad) |device| {
            try renderer.setRenderDrawColor(245, 245, 245, 255);
            try renderer.renderDebugText(24, 24, device.getName() orelse "Unnamed gamepad");
            const x = @as(f32, @floatFromInt(device.getAxis(.leftx))) / 32768.0;
            const y = @as(f32, @floatFromInt(device.getAxis(.lefty))) / 32768.0;
            try renderer.setRenderDrawColor(80, 190, 245, 255);
            try renderer.renderFillRect(&.{ .x = 300 + x * 140, .y = 220 + y * 140, .w = 40, .h = 40 });
            try renderer.setRenderDrawColor(if (device.getButton(.south)) 255 else 80, 90, 100, 255);
            try renderer.renderFillRect(&.{ .x = 520, .y = 210, .w = 44, .h = 44 });
        } else {
            try renderer.setRenderDrawColor(245, 245, 245, 255);
            try renderer.renderDebugText(24, 24, "No mapped gamepad connected.");
        }
        try renderer.renderPresent();
    }
}
