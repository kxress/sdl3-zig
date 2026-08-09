//! Port of SDL's examples/renderer/19-affine-textures.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: affine texture", 640, 480, .{});
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
        const phase: f32 = @as(f32, @floatFromInt(sdl.timer.getTicks())) / 1000.0;
        const origin = sdl.rect.FPoint{ .x = 150 + @sin(phase) * 60, .y = 90 };
        const right = sdl.rect.FPoint{ .x = 500, .y = 100 + @cos(phase) * 70 };
        const down = sdl.rect.FPoint{ .x = 190, .y = 400 };
        try renderer.setRenderDrawColor(15, 15, 22, 255);
        try renderer.renderClear();
        try renderer.renderTextureAffine(texture, null, &origin, &right, &down);
        try renderer.renderPresent();
    }
}
