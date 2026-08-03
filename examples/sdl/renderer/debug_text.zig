//! Port of SDL's examples/renderer/18-debug-text.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: debug text", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var text_buffer: [128]u8 = undefined;
    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const text = try std.fmt.bufPrintZ(
            &text_buffer,
            "SDL_RenderDebugText() -- ticks: {d}",
            .{sdl.timer.getTicks()},
        );
        try renderer.setRenderDrawColor(24, 24, 32, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(80, 220, 120, 255);
        try renderer.renderDebugText(40, 60, text);
        try renderer.renderDebugText(40, 88, "The built-in font needs no asset.");
        try renderer.renderPresent();
    }
}
