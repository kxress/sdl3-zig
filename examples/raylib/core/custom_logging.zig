//! RAYLIB-DERIVED: SDL3 port of examples/core/core_custom_logging.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const sdl = @import("sdl");

fn customLogger(_: ?*anyopaque, category: c_int, priority: sdl.LogPriority, message: ?[*:0]const u8) callconv(.c) void {
    std.debug.print("[SDL category {d}, {s}] {s}\n", .{
        category,
        @tagName(priority),
        if (message) |text| std.mem.span(text) else "",
    });
}

pub fn main() !void {
    sdl.setLogOutputFunction(customLogger, null);
    sdl.logInfo(0, "custom logger installed at tick {d}", .{sdl.timer.getTicks()});
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: custom logging", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.mouse_button_down)) {
                sdl.logInfo(0, "mouse button {d} clicked", .{event.event.button.button});
            }
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(60, 60, 70, 255);
        try renderer.renderDebugText(30, 40, "Click to send messages through the custom SDL logger.");
        try renderer.renderPresent();
    }
}
