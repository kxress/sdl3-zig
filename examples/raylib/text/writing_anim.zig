//! RAYLIB-DERIVED: SDL3 port of examples/text/text_writing_anim.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const sdl = @import("sdl");
const ttf = @import("ttf");

const message =
    "This sample illustrates a text writing animation using SDL_ttf. " ++
    "The sentence is revealed character by character and restarts on click.";

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    try ttf.init();
    defer ttf.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: writing animation", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var font = try ttf.openFont("raylib/pixantiqua.ttf", 24);
    defer font.close();
    var started = sdl.timer.getTicks();

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_button_down)) {
                started = sdl.timer.getTicks();
            }
        }
        const count = @min(message.len, @as(usize, @intCast((sdl.timer.getTicks() - started) / 45)));
        const surface = font.renderTextBlendedWrapped(
            message[0..count],
            .{ .r = 45, .g = 48, .b = 58, .a = 255 },
            680,
        ) orelse return error.SdlFailure;
        defer sdl.surface.destroy(surface);
        const texture = try renderer.createTextureFromSurface(surface);
        defer sdl.render.destroyTexture(texture);
        const size = try sdl.render.getTextureSize(texture);
        try renderer.setRenderDrawColor(245, 245, 240, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, null, &.{ .x = 60, .y = 120, .w = size.w, .h = size.h });
        try renderer.setRenderDrawColor(110, 110, 120, 255);
        try renderer.renderDebugText(60, 350, "Click to restart the animation.");
        try renderer.renderPresent();
    }
}
