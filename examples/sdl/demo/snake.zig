//! Port of SDL's examples/demo/01-snake.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

const Cell = struct { x: i32, y: i32 };
const Direction = enum { up, down, left, right };

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL demo: snake", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var snake: [32 * 24]Cell = undefined;
    snake[0] = .{ .x = 16, .y = 12 };
    snake[1] = .{ .x = 15, .y = 12 };
    snake[2] = .{ .x = 14, .y = 12 };
    var length: usize = 3;
    var direction: Direction = .right;
    var food = Cell{ .x = 23, .y = 8 };
    var random: u32 = 0x12345678;
    var next_step: u64 = 0;
    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.key_down)) {
                switch (event.key.scancode) {
                    .scancode_up => if (direction != .down) {
                        direction = .up;
                    },
                    .scancode_down => if (direction != .up) {
                        direction = .down;
                    },
                    .scancode_left => if (direction != .right) {
                        direction = .left;
                    },
                    .scancode_right => if (direction != .left) {
                        direction = .right;
                    },
                    else => {},
                }
            }
        }
        const now = sdl.timer.getTicks();
        if (now >= next_step) {
            var head = snake[0];
            switch (direction) {
                .up => head.y -= 1,
                .down => head.y += 1,
                .left => head.x -= 1,
                .right => head.x += 1,
            }
            head.x = @mod(head.x, 32);
            head.y = @mod(head.y, 24);
            var collided = false;
            for (snake[0..length]) |cell| {
                if (cell.x == head.x and cell.y == head.y) collided = true;
            }
            if (collided) {
                length = 3;
                head = .{ .x = 16, .y = 12 };
            }
            var index = length;
            while (index > 1) : (index -= 1) snake[index - 1] = snake[index - 2];
            snake[0] = head;
            if (head.x == food.x and head.y == food.y) {
                if (length < snake.len) length += 1;
                random = random *% 1664525 +% 1013904223;
                food.x = @intCast(random % 32);
                food.y = @intCast((random >> 8) % 24);
            }
            next_step = now + 90;
        }

        try renderer.setRenderDrawColor(12, 22, 18, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(245, 80, 80, 255);
        try renderer.renderFillRect(&.{
            .x = @floatFromInt(food.x * 20 + 2),
            .y = @floatFromInt(food.y * 20 + 2),
            .w = 16,
            .h = 16,
        });
        for (snake[0..length], 0..) |cell, i| {
            try renderer.setRenderDrawColor(if (i == 0) 130 else 70, 220, 110, 255);
            try renderer.renderFillRect(&.{
                .x = @floatFromInt(cell.x * 20 + 1),
                .y = @floatFromInt(cell.y * 20 + 1),
                .w = 18,
                .h = 18,
            });
        }
        try renderer.renderPresent();
    }
}
