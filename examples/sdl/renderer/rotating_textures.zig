//! Port of SDL's examples/renderer/08-rotating-textures.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: rotating texture", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const surface = try sdl.surface.loadPng("sdl/sample.png");
    defer sdl.surface.destroy(surface);
    const texture = try renderer.createTextureFromSurface(surface);
    defer sdl.render.destroyTexture(texture);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const angle: f64 = @floatFromInt((sdl.timer.getTicks() / 10) % 360);
        try renderer.setRenderDrawColor(15, 15, 22, 255);
        try renderer.renderClear();
        try renderer.renderTextureRotated(
            texture,
            null,
            &.{ .x = 170, .y = 90, .w = 300, .h = 300 },
            angle,
            null,
            .none,
        );
        try renderer.renderPresent();
    }
}
