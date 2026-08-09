//! Port of SDL's examples/renderer/07-streaming-textures.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL renderer: streaming texture", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = try renderer.createTexture(.rgba32, .streaming, 256, 256);
    defer sdl.render.destroyTexture(texture);
    var pixels: [256 * 256]u32 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const phase: u32 = @truncate(sdl.timer.getTicks() / 8);
        for (&pixels, 0..) |*pixel, i| {
            const x: u32 = @intCast(i % 256);
            const y: u32 = @intCast(i / 256);
            const value: u8 = @truncate(x ^ y ^ phase);
            pixel.* = 0xff000000 | (@as(u32, value) << 16) |
                (@as(u32, 255 - value) << 8) | @as(u32, value / 2);
        }
        try sdl.render.updateTexture(texture, null, &pixels, 256 * @sizeOf(u32));
        try renderer.setRenderDrawColor(18, 18, 24, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, null, &.{ .x = 192, .y = 112, .w = 256, .h = 256 });
        try renderer.renderPresent();
    }
}
