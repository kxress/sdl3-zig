//! Port of SDL's examples/audio/04-multiple-streams.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .audio = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL audio: multiple streams", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const spec = sdl.audio.Spec{ .channels = 1, .format = .f32_, .freq = 16000 };
    var low = try sdl.audio.openDeviceStream(std.math.maxInt(u32), &spec, null, null);
    defer low.deinit();
    var high = try sdl.audio.openDeviceStream(std.math.maxInt(u32), &spec, null, null);
    defer high.deinit();
    try low.setGain(0.25);
    try high.setGain(0.20);
    try low.resumeDevice();
    try high.resumeDevice();
    var cursor: usize = 0;
    var low_samples: [512]f32 = undefined;
    var high_samples: [512]f32 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        if (try low.getQueued() < 8000) {
            for (&low_samples, &high_samples) |*a, *b| {
                const phase = @as(f32, @floatFromInt(cursor)) / 16000.0 * std.math.tau;
                a.* = @sin(phase * 220.0);
                b.* = @sin(phase * 660.0);
                cursor = (cursor + 1) % 16000;
            }
            try low.putData(std.mem.sliceAsBytes(&low_samples));
            try high.putData(std.mem.sliceAsBytes(&high_samples));
        }
        try renderer.setRenderDrawColor(18, 20, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(80, 180, 255, 255);
        try renderer.renderFillRect(&.{ .x = 100, .y = 170, .w = 440, .h = 50 });
        try renderer.setRenderDrawColor(255, 120, 100, 255);
        try renderer.renderFillRect(&.{ .x = 100, .y = 260, .w = 440, .h = 50 });
        try renderer.renderPresent();
    }
}
