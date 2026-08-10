//! RAYLIB-DERIVED: SDL3 port of examples/audio/audio_music_stream.c.
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
    const result = try sdl.render.createWindowAndRenderer("raylib port: music stream", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var audio_mixer = try mixer_api.createMixerDevice(std.math.maxInt(u32), null);
    defer audio_mixer.deinit();
    var music = try mixer_api.loadAudio(audio_mixer, "raylib/country.mp3", false);
    defer music.deinit();
    var track = mixer_api.createTrack(audio_mixer) orelse return error.SdlFailure;
    defer track.deinit();
    try track.setAudio(music);
    try track.play(0);
    const duration = @max(music.getDuration(), 1);
    var paused = false;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down) and
                event.key.scancode == .scancode_space and !event.key.repeat)
            {
                if (paused) {
                    _ = track.resume_();
                } else {
                    _ = track.pause();
                }
                paused = !paused;
            }
        }
        if (!paused and track.getRemaining() == 0) try track.play(0);
        const position = try track.getPlaybackPosition();
        const progress = @min(1.0, @as(f32, @floatFromInt(position)) / @as(f32, @floatFromInt(duration)));
        try renderer.setRenderDrawColor(245, 245, 240, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(80, 80, 90, 255);
        try renderer.renderRect(&.{ .x = 100, .y = 210, .w = 600, .h = 24 });
        try renderer.setRenderDrawColor(90, 160, 230, 255);
        try renderer.renderFillRect(&.{ .x = 102, .y = 212, .w = 596 * progress, .h = 20 });
        try renderer.setRenderDrawColor(60, 60, 70, 255);
        try renderer.renderDebugText(100, 170, "Streaming country.mp3 -- space pauses/resumes");
        try renderer.renderDebugText(100, 250, if (paused) "PAUSED" else "PLAYING");
        try renderer.renderPresent();
    }
}
