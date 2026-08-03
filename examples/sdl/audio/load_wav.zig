//! Port of SDL's examples/audio/03-load-wav.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .audio = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL audio: load WAV", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const wav = try sdl.audio.loadWav(std.heap.page_allocator, "sdl/sample.wav");
    defer std.heap.page_allocator.free(wav.data);
    var stream = try sdl.audio.openDeviceStream(std.math.maxInt(u32), &wav.spec, null, null);
    defer stream.deinit();
    try stream.putData(wav.data);
    try stream.resumeDevice();

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        if (try stream.getQueued() == 0) try stream.putData(wav.data);
        try renderer.setRenderDrawColor(20, 28, 24, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(100, 235, 150, 255);
        try renderer.renderDebugText(32, 48, "Loaded sdl/sample.wav; replaying when drained.");
        try renderer.renderPresent();
    }
}
