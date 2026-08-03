//! Port of SDL's examples/demo/02-woodeneye-008.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const sdl = @import("sdl");

const Point3 = struct { x: f32, y: f32, z: f32 };

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL demo: woodeneye-008", 800, 600, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const cube = [_]Point3{
        .{ .x = -1, .y = -1, .z = -1 }, .{ .x = 1, .y = -1, .z = -1 },
        .{ .x = 1, .y = 1, .z = -1 },   .{ .x = -1, .y = 1, .z = -1 },
        .{ .x = -1, .y = -1, .z = 1 },  .{ .x = 1, .y = -1, .z = 1 },
        .{ .x = 1, .y = 1, .z = 1 },    .{ .x = -1, .y = 1, .z = 1 },
    };
    const edges = [_][2]usize{
        .{ 0, 1 }, .{ 1, 2 }, .{ 2, 3 }, .{ 3, 0 }, .{ 4, 5 }, .{ 5, 6 },
        .{ 6, 7 }, .{ 7, 4 }, .{ 0, 4 }, .{ 1, 5 }, .{ 2, 6 }, .{ 3, 7 },
    };

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const angle: f32 = @as(f32, @floatFromInt(sdl.timer.getTicks())) / 1300.0;
        var projected: [cube.len]sdl.rect.FPoint = undefined;
        for (cube, 0..) |point, index| {
            const rx = point.x * @cos(angle) - point.z * @sin(angle);
            const rz0 = point.x * @sin(angle) + point.z * @cos(angle);
            const ry = point.y * @cos(angle * 0.7) - rz0 * @sin(angle * 0.7);
            const rz = point.y * @sin(angle * 0.7) + rz0 * @cos(angle * 0.7) + 4.0;
            projected[index] = .{ .x = 400 + rx / rz * 420, .y = 300 + ry / rz * 420 };
        }
        try renderer.setRenderDrawColor(0, 0, 0, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(100, 230, 160, 255);
        for (edges) |edge| {
            const a = projected[edge[0]];
            const b = projected[edge[1]];
            try renderer.renderLine(a.x, a.y, b.x, b.y);
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderDebugText(20, 20, "Native main-loop port of SDL's wireframe multiplayer demo.");
        try renderer.renderPresent();
    }
}
