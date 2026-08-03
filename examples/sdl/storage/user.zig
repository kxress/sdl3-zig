//! Port of SDL's examples/storage/01-user.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL storage: user", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var status: enum { idle, saved, loaded, failed } = .idle;
    var loaded_world: u64 = 0;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.mouse_button_down)) {
                var storage = sdl.storage.openUser("libsdl", "User Storage Example", 0) catch {
                    status = .failed;
                    continue;
                };
                defer storage.close() catch {};
                var attempts: usize = 0;
                while (!storage.ready() and attempts < 100) : (attempts += 1) sdl.timer.delay(10);
                if (!storage.ready()) {
                    status = .failed;
                } else if (event.button.button == sdl.mouse.button_left) {
                    var world = sdl.timer.getPerformanceCounter();
                    status = if (storage.writeFile("save.sav", std.mem.asBytes(&world))) .saved else .failed;
                } else if (storage.getFileSize("save.sav")) |size| {
                    if (size.length == @sizeOf(u64) and storage.readFile(
                        "save.sav",
                        std.mem.asBytes(&loaded_world),
                    )) {
                        status = .loaded;
                    } else status = .failed;
                } else status = .failed;
            }
        }
        const color: [3]u8 = switch (status) {
            .idle => .{ 30, 70, 190 },
            .saved => .{ 30, 170, 80 },
            .loaded => .{ 40, 170, 150 },
            .failed => .{ 190, 40, 50 },
        };
        try renderer.setRenderDrawColor(color[0], color[1], color[2], 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(255, 255, 255, 255);
        try renderer.renderDebugText(32, 40, "Left click: save. Other click: load.");
        var value_buffer: [80]u8 = undefined;
        const value = try std.fmt.bufPrintZ(&value_buffer, "Loaded world value: {d}", .{loaded_world});
        try renderer.renderDebugText(32, 72, value);
        try renderer.renderPresent();
    }
}
