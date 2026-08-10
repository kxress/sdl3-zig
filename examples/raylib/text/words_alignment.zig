//! RAYLIB-DERIVED: SDL3 port of examples/text/text_words_alignment.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.
const std = @import("std");

const example_test = @import("example_test");
const sdl = @import("sdl");
const ttf = @import("ttf");

const Alignment = enum { left, center, right };

fn drawLine(
    renderer: sdl.render.Renderer,
    font: ttf.Font,
    line: []const u8,
    alignment: Alignment,
    y: f32,
) !void {
    const surface = font.renderTextBlended(line, .{ .r = 45, .g = 50, .b = 60, .a = 255 }) orelse
        return error.SdlFailure;
    defer sdl.surface.destroy(surface);
    const texture = try renderer.createTextureFromSurface(surface);
    defer sdl.render.destroyTexture(texture);
    const size = try sdl.render.getTextureSize(texture);
    const x: f32 = switch (alignment) {
        .left => 120,
        .center => 400 - size.w / 2,
        .right => 680 - size.w,
    };
    try renderer.renderTexture(texture, null, &.{ .x = x, .y = y, .w = size.w, .h = size.h });
}

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    try ttf.init();
    defer ttf.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: words alignment", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var font = try ttf.openFont("raylib/pixantiqua.ttf", 22);
    defer font.close();
    const lines = [_][]const u8{
        "SDL_ttf shapes these words while SDL renders",
        "the same paragraph with an explicit alignment.",
        "Press L, C, or R to change the layout.",
    };
    var alignment: Alignment = .left;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down)) switch (event.key.scancode) {
                .scancode_l => alignment = .left,
                .scancode_c => alignment = .center,
                .scancode_r => alignment = .right,
                else => {},
            };
        }
        try renderer.setRenderDrawColor(245, 245, 240, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(100, 140, 210, 255);
        try renderer.renderRect(&.{ .x = 100, .y = 100, .w = 600, .h = 250 });
        for (lines, 0..) |line, index| {
            try drawLine(renderer, font, line, alignment, 145 + @as(f32, @floatFromInt(index)) * 55);
        }
        try renderer.renderPresent();
    }
}
