//! Port of SDL's examples/renderer/11-color-mods.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: texture color modulation", 640, 480, .{});
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
        const phase: f32 = @as(f32, @floatFromInt(sdl.timer.getTicks())) / 900.0;
        const red: u8 = @intFromFloat(128.0 + 127.0 * @sin(phase));
        const green: u8 = @intFromFloat(128.0 + 127.0 * @sin(phase + 2.0));
        const blue: u8 = @intFromFloat(128.0 + 127.0 * @sin(phase + 4.0));
        try sdl.render.setTextureColorMod(texture, red, green, blue);
        try renderer.setRenderDrawColor(18, 18, 24, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, null, &.{ .x = 120, .y = 40, .w = 400, .h = 400 });
        try renderer.renderPresent();
    }
}
