//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_sprite_button.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const std = @import("std");
const image = @import("image");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true, .audio = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: sprite button", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = image.loadTexture(&renderer, "raylib/button.png") orelse return error.SdlFailure;
    defer sdl.render.destroyTexture(texture);
    const size = try sdl.render.getTextureSize(texture);
    const wav = try sdl.audio.loadWav(std.heap.page_allocator, "raylib/buttonfx.wav");
    defer std.heap.page_allocator.free(wav.data);
    var sound = try sdl.audio.openDeviceStream(std.math.maxInt(u32), &wav.spec, null, null);
    defer sound.deinit();
    try sound.resumeDevice();
    const frame_height = size.h / 3;
    const bounds = sdl.rect.F{ .x = 400 - size.w / 2, .y = 225 - frame_height / 2, .w = size.w, .h = frame_height };
    var state: usize = 0;

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_button_up) and state == 2) {
                try sound.putData(wav.data);
            }
        }
        const mouse = sdl.mouse.getState();
        const inside = mouse.x >= bounds.x and mouse.x <= bounds.x + bounds.w and
            mouse.y >= bounds.y and mouse.y <= bounds.y + bounds.h;
        state = if (!inside) 0 else if (mouse.value != 0) 2 else 1;
        const source = sdl.rect.F{
            .x = 0,
            .y = @as(f32, @floatFromInt(state)) * frame_height,
            .w = size.w,
            .h = frame_height,
        };
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.renderTexture(texture, &source, &bounds);
        try renderer.renderPresent();
    }
}
