//! Port of SDL's examples/input/05-gamepad-rumble.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .gamepad = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL input: gamepad rumble", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const ids = try sdl.gamepad.getGamepads(std.heap.page_allocator);
    defer std.heap.page_allocator.free(ids);
    var gamepad: ?sdl.gamepad.Gamepad = if (ids.len > 0) sdl.gamepad.open(ids[0]) else null;
    defer if (gamepad) |*device| device.close();
    var next_rumble: u64 = 0;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const now = sdl.timer.getTicks();
        if (gamepad) |device| {
            if (now >= next_rumble) {
                try device.rumble(0xffff, 0x8000, 300);
                next_rumble = now + 2000;
            }
        }
        try renderer.setRenderDrawColor(25, 22, 34, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(235, 220, 255, 255);
        try renderer.renderDebugText(
            32,
            64,
            if (gamepad != null) "Rumbling for 300 ms every two seconds." else "No gamepad connected.",
        );
        try renderer.renderPresent();
    }
}
