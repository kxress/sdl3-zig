//! Port of SDL's examples/demo/03-infinite-monkeys.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

const target = "twas brillig and the slithy toves did gyre and gimble in the wabe";

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL demo: infinite monkeys", 720, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var random: u64 = 0x9e3779b97f4a7c15;
    var progress: usize = 0;
    var guesses: u64 = 0;
    var monkey_line: [80:0]u8 = [_:0]u8{' '} ** 80;
    var matched_line: [80:0]u8 = [_:0]u8{0} ** 80;
    var line_cursor: usize = 0;
    var counter_buffer: [100]u8 = undefined;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        var iteration: usize = 0;
        while (iteration < 5000 and progress < target.len) : (iteration += 1) {
            random ^= random << 13;
            random ^= random >> 7;
            random ^= random << 17;
            const character: u8 = if (random % 27 == 26) ' ' else @intCast('a' + random % 26);
            monkey_line[line_cursor] = character;
            line_cursor = (line_cursor + 1) % (monkey_line.len - 1);
            guesses += 1;
            if (character == target[progress]) progress += 1;
        }
        const counter = try std.fmt.bufPrintZ(
            &counter_buffer,
            "{d} monkeys' guesses; matched {d}/{d} ordered characters",
            .{ guesses, progress, target.len },
        );
        @memset(&matched_line, 0);
        @memcpy(matched_line[0..progress], target[0..progress]);
        try renderer.setRenderDrawColor(18, 18, 22, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(110, 230, 150, 255);
        try renderer.renderDebugText(24, 32, counter);
        try renderer.setRenderDrawColor(225, 225, 225, 255);
        try renderer.renderDebugText(24, 80, monkey_line[0..monkey_line.len :0]);
        try renderer.setRenderDrawColor(245, 190, 80, 255);
        try renderer.renderDebugText(24, 120, matched_line[0..matched_line.len :0]);
        try renderer.renderPresent();
    }
}
