//! Port of SDL's examples/audio/05-planar-data.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .audio = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL audio: planar data", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const spec = sdl.audio.Spec{ .channels = 2, .format = .f32_, .freq = 16000 };
    var stream = try sdl.audio.openDeviceStream(std.math.maxInt(u32), &spec, null, null);
    defer stream.deinit();
    try stream.resumeDevice();
    var left: [512]f32 = undefined;
    var right: [512]f32 = undefined;
    var cursor: usize = 0;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        if (try stream.getQueued() < 8000) {
            for (&left, &right) |*l, *r| {
                const phase = @as(f32, @floatFromInt(cursor)) / 16000.0 * std.math.tau;
                l.* = @sin(phase * 330.0) * 0.3;
                r.* = @sin(phase * 440.0) * 0.3;
                cursor = (cursor + 1) % 16000;
            }
            const channels = [_]?*const anyopaque{ &left, &right };
            try stream.putPlanarData(&channels[0], channels.len, left.len);
        }
        try renderer.setRenderDrawColor(24, 20, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(220, 160, 255, 255);
        try renderer.renderDebugText(32, 48, "Separate left/right planes: 330 Hz and 440 Hz.");
        try renderer.renderPresent();
    }
}
