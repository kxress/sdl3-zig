//! Port of SDL's examples/misc/02-clipboard.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL misc: clipboard", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    try sdl.clipboard.setText("Clipboard text set by the SDL3 Zig example");

    var clipboard_text = try sdl.clipboard.getText(std.heap.page_allocator);
    defer std.heap.page_allocator.free(clipboard_text);
    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.clipboard_update)) {
                std.heap.page_allocator.free(clipboard_text);
                clipboard_text = try sdl.clipboard.getText(std.heap.page_allocator);
            }
        }
        try renderer.setRenderDrawColor(30, 26, 38, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderDebugText(32, 48, "Current clipboard text:");
        try renderer.setRenderDrawColor(90, 210, 255, 255);
        try renderer.renderDebugText(32, 80, clipboard_text);
        try renderer.renderPresent();
    }
}
