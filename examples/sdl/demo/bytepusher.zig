//! Port of SDL's examples/demo/04-bytepusher.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL demo: BytePusher", 768, 768, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = try renderer.createTexture(.rgba32, .streaming, 256, 256);
    defer sdl.render.destroyTexture(texture);
    var display: [256 * 256]u32 = undefined;
    var memory: [256]u8 = undefined;
    for (&memory, 0..) |*byte, i| byte.* = @truncate(i * 73);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const frame: usize = @intCast(sdl.timer.getTicks() / 16);
        for (&display, 0..) |*pixel, index| {
            const x = index % 256;
            const y = index / 256;
            const opcode = memory[(x + y + frame) % memory.len];
            const r: u32 = opcode;
            const g: u32 = memory[(x * 3 + frame) % memory.len];
            const b: u32 = memory[(y * 5 + frame) % memory.len];
            pixel.* = 0xff000000 | (r << 16) | (g << 8) | b;
        }
        try sdl.render.updateTexture(texture, null, &display, 256 * @sizeOf(u32));
        try renderer.setRenderDrawColor(0, 0, 0, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, null, null);
        try renderer.setRenderDrawColor(255, 255, 255, 255);
        try renderer.renderDebugText(12, 12, "BytePusher-style 24-bit memory display");
        try renderer.renderPresent();
    }
}
