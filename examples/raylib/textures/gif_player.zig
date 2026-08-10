//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_gif_player.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.
const std = @import("std");

const image = @import("image");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: GIF player", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const animation = image.loadAnimation("raylib/scarfy_run.gif") orelse return error.SdlFailure;
    defer image.freeAnimation(animation);
    if (animation.count <= 0) return error.SdlFailure;
    var frame: usize = 0;
    var next_frame: u64 = 0;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const now = sdl.timer.getTicks();
        if (now >= next_frame) {
            frame = (frame + 1) % @as(usize, @intCast(animation.count));
            const delays: [*]c_int = @ptrCast(animation.delays orelse return error.SdlFailure);
            next_frame = now + @as(u64, @intCast(@max(delays[frame], 20)));
        }
        const frames: [*]?*sdl.surface.Surface = @ptrCast(animation.frames orelse return error.SdlFailure);
        const texture = try renderer.createTextureFromSurface(frames[frame]);
        defer sdl.render.destroyTexture(texture);
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, null, &.{ .x = 260, .y = 65, .w = 280, .h = 320 });
        try renderer.renderPresent();
    }
}
