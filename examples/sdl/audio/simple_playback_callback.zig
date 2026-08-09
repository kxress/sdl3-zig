//! Port of SDL's examples/audio/02-simple-playback-callback.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

const Tone = struct {
    sample: usize = 0,
    requested: std.atomic.Value(bool) = .init(false),
};

fn requestTone(userdata: ?*anyopaque, _: ?*anyopaque, additional: c_int, _: c_int) callconv(.c) void {
    if (additional <= 0) return;
    const tone: *Tone = @ptrCast(@alignCast(userdata orelse return));
    tone.requested.store(true, .release);
}

pub fn main() !void {
    try sdl.init.default(.{ .video = true, .audio = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL audio: playback callback", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var tone = Tone{};
    const spec = sdl.audio.Spec{ .channels = 1, .format = .f32_, .freq = 8000 };
    var stream = try sdl.audio.openDeviceStream(
        std.math.maxInt(u32),
        &spec,
        @ptrCast(&requestTone),
        &tone,
    );
    defer stream.deinit();
    try stream.resumeDevice();
    var samples: [256]f32 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        if (tone.requested.swap(false, .acquire)) {
            for (&samples) |*sample| {
                const phase = @as(f32, @floatFromInt(tone.sample)) * 220.0 / 8000.0;
                sample.* = @sin(phase * std.math.tau) * 0.35;
                tone.sample = (tone.sample + 1) % 8000;
            }
            try stream.putData(std.mem.sliceAsBytes(&samples));
        }
        try renderer.setRenderDrawColor(28, 20, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(245, 190, 90, 255);
        try renderer.renderDebugText(32, 48, "A callback requests 220 Hz tone data.");
        try renderer.renderPresent();
    }
}
