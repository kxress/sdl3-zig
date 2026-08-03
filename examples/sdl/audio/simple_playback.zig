//! Port of SDL's examples/audio/01-simple-playback.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .audio = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL audio: simple playback", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    const spec = sdl.audio.Spec{ .channels = 1, .format = .f32_, .freq = 8000 };
    var stream = try sdl.audio.openDeviceStream(std.math.maxInt(u32), &spec, null, null);
    defer stream.deinit();
    try stream.resumeDevice();
    var current_sample: usize = 0;
    var samples: [512]f32 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        if (try stream.getQueued() < 4000 * @sizeOf(f32)) {
            for (&samples) |*sample| {
                const phase = @as(f32, @floatFromInt(current_sample)) * 440.0 / 8000.0;
                sample.* = @sin(phase * std.math.tau);
                current_sample = (current_sample + 1) % 8000;
            }
            try stream.putData(std.mem.sliceAsBytes(&samples));
        }
        try renderer.setRenderDrawColor(18, 22, 28, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(90, 210, 250, 255);
        try renderer.renderDebugText(32, 48, "Streaming a 440 Hz sine wave.");
        try renderer.renderPresent();
    }
}
