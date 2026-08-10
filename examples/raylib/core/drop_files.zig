//! RAYLIB-DERIVED: SDL3 port of examples/core/core_drop_files.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: drop files", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var path_buffer: [512:0]u8 = [_:0]u8{0} ** 512;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.drop_file)) {
                const path = std.mem.span(@as([*:0]const u8, @ptrCast(event.drop.data orelse continue)));
                const length = @min(path.len, path_buffer.len);
                @memset(&path_buffer, 0);
                @memcpy(path_buffer[0..length], path[0..length]);
            }
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(80, 80, 80, 255);
        try renderer.renderDebugText(30, 40, "Drop a file onto this window.");
        try renderer.setRenderDrawColor(90, 130, 220, 255);
        try renderer.renderDebugText(30, 80, path_buffer[0..path_buffer.len :0]);
        try renderer.renderPresent();
    }
}
