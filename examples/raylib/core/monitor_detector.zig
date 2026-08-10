//! RAYLIB-DERIVED: SDL3 port of examples/core/core_monitor_detector.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: monitor detector", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const displays = try sdl.video.getDisplays(std.heap.page_allocator);
    defer std.heap.page_allocator.free(displays);

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(242, 242, 240, 255);
        try renderer.renderClear();
        for (displays, 0..) |display, index| {
            const bounds = try sdl.video.getDisplayBounds(display);
            var line_buffer: [180]u8 = undefined;
            const line = try std.fmt.bufPrintZ(
                &line_buffer,
                "#{d} {s}: {d}x{d} at ({d},{d}), scale {d:.2}",
                .{
                    index,
                    try sdl.video.getDisplayName(display),
                    bounds.rect.w,
                    bounds.rect.h,
                    bounds.rect.x,
                    bounds.rect.y,
                    sdl.video.getDisplayContentScale(display),
                },
            );
            try renderer.setRenderDrawColor(50, 70, 90, 255);
            try renderer.renderDebugText(24, 32 + @as(f32, @floatFromInt(index)) * 28, line);
        }
        try renderer.renderPresent();
    }
}
