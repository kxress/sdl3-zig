//! RAYLIB-DERIVED: SDL3 port of examples/text/text_input_box.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const sdl = @import("sdl");
const ttf = @import("ttf");

fn drawText(
    renderer: sdl.render.Renderer,
    font: ttf.Font,
    text: []const u8,
    x: f32,
    y: f32,
    color: sdl.pixels.Color,
) !void {
    const surface = font.renderTextBlended(text, color) orelse return error.SdlFailure;
    defer sdl.surface.destroy(surface);
    const texture = try renderer.createTextureFromSurface(surface);
    defer sdl.render.destroyTexture(texture);
    const size = try sdl.render.getTextureSize(texture);
    try renderer.renderTexture(texture, null, &.{ .x = x, .y = y, .w = size.w, .h = size.h });
}

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    try ttf.init();
    defer ttf.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: text input box", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    try window.startTextInput();
    defer window.stopTextInput() catch {};
    var font = try ttf.openFont("raylib/pixantiqua.ttf", 28);
    defer font.close();
    var text: [128:0]u8 = [_:0]u8{0} ** 128;
    var length: usize = 0;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.text_input)) {
                const input = std.mem.span(@as([*:0]const u8, @ptrCast(event.text.text orelse continue)));
                const amount = @min(input.len, text.len - length);
                @memcpy(text[length .. length + amount], input[0..amount]);
                length += amount;
                text[length] = 0;
            }
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down) and
                event.key.scancode == .scancode_back_space and length > 0)
            {
                length -= 1;
                while (length > 0 and text[length] & 0xc0 == 0x80) length -= 1;
                text[length] = 0;
            }
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(90, 90, 95, 255);
        try renderer.renderRect(&.{ .x = 120, .y = 180, .w = 560, .h = 70 });
        if (length > 0) {
            try drawText(renderer, font, text[0..length], 135, 195, .{ .r = 55, .g = 55, .b = 65, .a = 255 });
        } else {
            try renderer.setRenderDrawColor(140, 140, 145, 255);
            try renderer.renderDebugText(140, 210, "Type something...");
        }
        try renderer.renderPresent();
    }
}
