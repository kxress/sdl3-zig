//! Port of SDL's examples/input/01-joystick-polling.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true, .joystick = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL input: joystick polling", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const ids = try sdl.joystick.getJoysticks(std.heap.page_allocator);
    defer std.heap.page_allocator.free(ids);
    var joystick: ?sdl.joystick.Joystick = if (ids.len > 0) try sdl.joystick.open(ids[0]) else null;
    defer if (joystick) |*device| device.close();

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(22, 24, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(235, 235, 235, 255);
        if (joystick) |device| {
            try renderer.renderDebugText(24, 24, device.getName() orelse "Unnamed joystick");
            const axis_count = try device.getNumAxes();
            var axis: c_int = 0;
            while (axis < @min(axis_count, 8)) : (axis += 1) {
                const value = device.getAxis(axis);
                const width = @as(f32, @floatFromInt(value)) / 32768.0 * 180.0;
                try renderer.setRenderDrawColor(70, 180, 240, 255);
                try renderer.renderFillRect(&.{
                    .x = if (width < 0) 320 + width else 320,
                    .y = 70 + @as(f32, @floatFromInt(axis)) * 38,
                    .w = @abs(width),
                    .h = 20,
                });
            }
        } else {
            try renderer.renderDebugText(24, 24, "No joystick connected.");
        }
        try renderer.renderPresent();
    }
}
