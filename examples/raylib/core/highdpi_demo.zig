//! RAYLIB-DERIVED: SDL3 port of examples/core/core_highdpi_demo.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer(
        "raylib port: high DPI",
        800,
        450,
        .{ .high_pixel_density = true, .resizable = true },
    );
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var line_buffer: [160]u8 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const size = try window.getSize();
        var pixel_w: c_int = 0;
        var pixel_h: c_int = 0;
        try window.getSizeInPixels(&pixel_w, &pixel_h);
        const line = try std.fmt.bufPrintZ(
            &line_buffer,
            "Window {d}x{d}; pixels {d}x{d}; density {d:.2}",
            .{ size.w, size.h, pixel_w, pixel_h, window.getPixelDensity() },
        );
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(35, 55, 80, 255);
        try renderer.renderDebugText(30, 40, line);
        try renderer.renderDebugText(30, 75, "Resize or move between displays to observe scaling.");
        try renderer.renderPresent();
    }
}
