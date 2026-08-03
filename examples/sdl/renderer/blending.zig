//! Port of SDL's examples/renderer/20-blending.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: blending", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    try renderer.setRenderDrawBlendMode(sdl.blendmode.blend_mode_blend);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(16, 18, 28, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(255, 50, 80, 150);
        try renderer.renderFillRect(&.{ .x = 120, .y = 90, .w = 280, .h = 240 });
        try renderer.setRenderDrawColor(40, 120, 255, 150);
        try renderer.renderFillRect(&.{ .x = 240, .y = 150, .w = 280, .h = 240 });
        try renderer.setRenderDrawColor(255, 220, 30, 130);
        try renderer.renderFillRect(&.{ .x = 180, .y = 210, .w = 280, .h = 180 });
        try renderer.renderPresent();
    }
}
