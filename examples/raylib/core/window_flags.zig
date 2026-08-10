//! RAYLIB-DERIVED: SDL3 port of examples/core/core_window_flags.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer(
        "raylib port: window flags",
        800,
        450,
        .{ .resizable = true },
    );
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var fullscreen = false;
    var bordered = true;
    var top = false;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down) and !event.key.repeat) {
                switch (event.key.scancode) {
                    .scancode_f => {
                        fullscreen = !fullscreen;
                        try window.setFullscreen(fullscreen);
                    },
                    .scancode_b => {
                        bordered = !bordered;
                        try window.setBordered(bordered);
                    },
                    .scancode_t => {
                        top = !top;
                        try window.setAlwaysOnTop(top);
                    },
                    else => {},
                }
            }
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(45, 45, 45, 255);
        try renderer.renderDebugText(30, 30, "F: fullscreen   B: border   T: always-on-top");
        try renderer.renderDebugText(30, 65, if (fullscreen) "FULLSCREEN enabled" else "FULLSCREEN disabled");
        try renderer.renderDebugText(30, 90, if (bordered) "BORDER enabled" else "BORDER disabled");
        try renderer.renderDebugText(30, 115, if (top) "ALWAYS ON TOP enabled" else "ALWAYS ON TOP disabled");
        try renderer.renderPresent();
    }
}
