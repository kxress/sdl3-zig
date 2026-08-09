//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_npatch_drawing.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const image = @import("image");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: nine-patch drawing", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = image.loadTexture(&renderer, "raylib/ninepatch_button.png") orelse
        return error.SdlFailure;
    defer sdl.render.destroyTexture(texture);
    const size = try sdl.render.getTextureSize(texture);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const mouse = sdl.mouse.getState();
        const destination = sdl.rect.F{
            .x = 80,
            .y = 80,
            .w = @max(100, mouse.x - 80),
            .h = @max(80, mouse.y - 80),
        };
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.renderTexture9Grid(
            texture,
            &.{ .x = 0, .y = 0, .w = size.w, .h = size.h },
            16,
            16,
            16,
            16,
            1,
            &destination,
        );
        try renderer.setRenderDrawColor(50, 50, 60, 255);
        try renderer.renderDebugText(80, 48, "Move the mouse to resize the nine-patch.");
        try renderer.renderPresent();
    }
}
