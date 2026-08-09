//! Port of SDL's examples/renderer/06-textures.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: textures", 640, 480, .{});
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
        try renderer.setRenderDrawColor(20, 20, 25, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, null, &.{ .x = 80, .y = 60, .w = 480, .h = 360 });
        try renderer.renderPresent();
    }
}
