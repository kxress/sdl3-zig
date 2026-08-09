//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_fog_of_war.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: fog of war", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var explored = [_]bool{false} ** (40 * 23);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const mouse = sdl.mouse.getState();
        const center_x: i32 = @intFromFloat(mouse.x / 20);
        const center_y: i32 = @intFromFloat(mouse.y / 20);
        var y: i32 = 0;
        while (y < 23) : (y += 1) {
            var x: i32 = 0;
            while (x < 40) : (x += 1) {
                const dx = x - center_x;
                const dy = y - center_y;
                if (dx * dx + dy * dy < 36) explored[@intCast(y * 40 + x)] = true;
            }
        }
        try renderer.setRenderDrawColor(70, 110, 75, 255);
        try renderer.renderClear();
        y = 0;
        while (y < 23) : (y += 1) {
            var x: i32 = 0;
            while (x < 40) : (x += 1) {
                const dx = x - center_x;
                const dy = y - center_y;
                const visible = dx * dx + dy * dy < 36;
                if (!visible) {
                    try renderer.setRenderDrawColor(8, 10, 12, if (explored[@intCast(y * 40 + x)]) 180 else 245);
                    try renderer.renderFillRect(&.{
                        .x = @floatFromInt(x * 20),
                        .y = @floatFromInt(y * 20),
                        .w = 20,
                        .h = 20,
                    });
                }
            }
        }
        try renderer.renderPresent();
    }
}
