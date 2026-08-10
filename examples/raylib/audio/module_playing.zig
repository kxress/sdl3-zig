//! RAYLIB-DERIVED: SDL3 port of examples/audio/audio_module_playing.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const mixer_api = @import("mixer");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true, .audio = true });
    defer sdl.init.quit();
    try mixer_api.init();
    defer mixer_api.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: module playing", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var audio_mixer = try mixer_api.createMixerDevice(std.math.maxInt(u32), null);
    defer audio_mixer.deinit();
    // Keep this example runnable with the portable source profile, which does not
    // require the optional libxmp dependency for tracker-module decoding.
    var module = try mixer_api.loadAudio(audio_mixer, "raylib/buttonfx.wav", false);
    defer module.deinit();
    var track = mixer_api.createTrack(audio_mixer) orelse return error.SdlFailure;
    defer track.deinit();
    try track.setAudio(module);
    try track.play(0);
    var frequency: f32 = 1;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down) and !event.key.repeat) {
                if (event.key.scancode == .scancode_up) frequency = @min(2, frequency + 0.05);
                if (event.key.scancode == .scancode_down) frequency = @max(0.25, frequency - 0.05);
                try track.setFrequencyRatio(frequency);
            }
        }
        if (track.getRemaining() == 0) try track.play(0);
        const position = try track.getPlaybackPosition();
        try renderer.setRenderDrawColor(22, 18, 32, 255);
        try renderer.renderClear();
        var row: usize = 0;
        while (row < 12) : (row += 1) {
            const active = @as(usize, @intCast(@divTrunc(position, 2048))) % 12 == row;
            try renderer.setRenderDrawColor(if (active) 240 else 80, if (active) 180 else 80, 130, 255);
            try renderer.renderFillRect(&.{
                .x = 180,
                .y = 55 + @as(f32, @floatFromInt(row)) * 27,
                .w = 440,
                .h = 20,
            });
        }
        try renderer.setRenderDrawColor(240, 240, 245, 255);
        try renderer.renderDebugText(20, 20, "mini1111.xm -- up/down changes playback rate");
        try renderer.renderPresent();
    }
}
