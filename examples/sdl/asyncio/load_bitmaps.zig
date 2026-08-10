//! Port of SDL's examples/asyncio/01-load-bitmaps.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");

const paths = [_][:0]const u8{
    "sdl/sample.png",
    "sdl/gamepad_front.png",
    "sdl/speaker.png",
    "sdl/icon2x.png",
};

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL asyncio: load bitmaps", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var queue = sdl.asyncIo.createQueue() orelse return error.SdlFailure;
    defer queue.deinit();
    var textures = [_]?*sdl.render.Texture{null} ** paths.len;
    defer for (textures) |texture| sdl.render.destroyTexture(texture);
    for (paths, 0..) |path, index| {
        try sdl.asyncIo.loadFileAsync(path, queue, @ptrFromInt(index + 1));
    }

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        if (queue.getResult()) |completed| {
            const outcome = completed.outcome;
            defer sdl.stdinc.free(@ptrCast(outcome.buffer));
            if (outcome.result == .complete) {
                const index = @intFromPtr(outcome.userdata orelse unreachable) - 1;
                const surface = try sdl.surface.loadPng(paths[index]);
                defer sdl.surface.destroy(surface);
                textures[index] = try renderer.createTextureFromSurface(surface);
            }
        }

        try renderer.setRenderDrawColor(0, 0, 0, 255);
        try renderer.renderClear();
        const destinations = [_]sdl.rect.F{
            .{ .x = 116, .y = 156, .w = 408, .h = 167 },
            .{ .x = 20, .y = 200, .w = 96, .h = 60 },
            .{ .x = 525, .y = 180, .w = 96, .h = 96 },
            .{ .x = 288, .y = 375, .w = 64, .h = 64 },
        };
        for (textures, destinations) |texture, destination| {
            if (texture) |loaded| renderer.renderTexture(loaded, null, &destination) catch {};
        }
        try renderer.renderPresent();
    }
}
