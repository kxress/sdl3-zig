//! Port of SDL's examples/input/04-gamepad-events.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true, .gamepad = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL input: gamepad events", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var line_buffer: [160]u8 = undefined;
    var line: [:0]const u8 = "Move a gamepad axis or press a button.";

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.gamepad_axis_motion)) {
                line = try std.fmt.bufPrintZ(
                    &line_buffer,
                    "Gamepad {d}: axis {d} = {d}",
                    .{ event.gaxis.which, event.gaxis.axis, event.gaxis.value },
                );
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.gamepad_button_down) or
                event.type_ == @intFromEnum(sdl.events.EventType.gamepad_button_up))
            {
                line = try std.fmt.bufPrintZ(
                    &line_buffer,
                    "Gamepad {d}: button {d} {s}",
                    .{ event.gbutton.which, event.gbutton.button, if (event.gbutton.down) "down" else "up" },
                );
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.gamepad_added)) {
                line = try std.fmt.bufPrintZ(&line_buffer, "Gamepad {d} added", .{event.gdevice.which});
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.gamepad_removed)) {
                line = try std.fmt.bufPrintZ(&line_buffer, "Gamepad {d} removed", .{event.gdevice.which});
            }
        }
        try renderer.setRenderDrawColor(20, 28, 30, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(110, 235, 170, 255);
        try renderer.renderDebugText(32, 64, "Latest mapped gamepad event:");
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderDebugText(32, 96, line);
        try renderer.renderPresent();
    }
}
