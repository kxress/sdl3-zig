//! Port of SDL's examples/input/02-joystick-events.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const example_test = @import("example_test");
const sdl = @import("sdl");

pub fn main(init: std.process.Init) !void {
    var test_ping = try example_test.TestPing.init(init);
    defer test_ping.deinit();
    try sdl.init.default(.{ .video = true, .joystick = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL input: joystick events", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var line_buffer: [160]u8 = undefined;
    var line: [:0]const u8 = "Move an axis or press a joystick button.";

    if (test_ping.shouldExit()) return;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.joystick_axis_motion)) {
                line = try std.fmt.bufPrintZ(
                    &line_buffer,
                    "Joystick {d}: axis {d} = {d}",
                    .{ event.jaxis.which, event.jaxis.axis, event.jaxis.value },
                );
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.joystick_button_down) or
                event.type_ == @intFromEnum(sdl.events.EventType.joystick_button_up))
            {
                line = try std.fmt.bufPrintZ(
                    &line_buffer,
                    "Joystick {d}: button {d} {s}",
                    .{ event.jbutton.which, event.jbutton.button, if (event.jbutton.down) "down" else "up" },
                );
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.joystick_added)) {
                line = try std.fmt.bufPrintZ(&line_buffer, "Joystick {d} added", .{event.jdevice.which});
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.joystick_removed)) {
                line = try std.fmt.bufPrintZ(&line_buffer, "Joystick {d} removed", .{event.jdevice.which});
            }
        }
        try renderer.setRenderDrawColor(28, 20, 34, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(245, 210, 80, 255);
        try renderer.renderDebugText(32, 64, "Latest joystick event:");
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderDebugText(32, 96, line);
        try renderer.renderPresent();
    }
}
