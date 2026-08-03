//! Port of SDL's examples/misc/03-locale.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL misc: preferred locales", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var locales = try sdl.locale.getPreferredLocales(std.heap.page_allocator);
    defer locales.deinit();

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(22, 26, 34, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(255, 220, 90, 255);
        try renderer.renderDebugText(32, 32, "Preferred locales, in system order:");
        for (locales.items, 0..) |locale, index| {
            var line_buffer: [96]u8 = undefined;
            const line = try std.fmt.bufPrintZ(
                &line_buffer,
                "{d}: {s}_{s}",
                .{ index + 1, locale.language orelse "?", locale.country orelse "*" },
            );
            try renderer.renderDebugText(48, 64 + @as(f32, @floatFromInt(index)) * 18, line);
        }
        try renderer.renderPresent();
    }
}
