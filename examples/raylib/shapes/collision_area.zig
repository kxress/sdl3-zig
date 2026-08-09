//! RAYLIB-DERIVED: SDL3 port of examples/shapes/shapes_collision_area.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const sdl = @import("sdl");

fn intersection(a: sdl.rect.F, b: sdl.rect.F) ?sdl.rect.F {
    const x = @max(a.x, b.x);
    const y = @max(a.y, b.y);
    const right = @min(a.x + a.w, b.x + b.w);
    const bottom = @min(a.y + a.h, b.y + b.h);
    return if (right > x and bottom > y)
        .{ .x = x, .y = y, .w = right - x, .h = bottom - y }
    else
        null;
}

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: collision area", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const mouse = sdl.mouse.getState();
        const box_a = sdl.rect.F{ .x = mouse.x - 100, .y = mouse.y - 50, .w = 200, .h = 100 };
        const box_b = sdl.rect.F{ .x = 300, .y = 180, .w = 260, .h = 150 };
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(60, 120, 230, 255);
        try renderer.renderFillRect(&box_a);
        try renderer.setRenderDrawColor(230, 80, 80, 255);
        try renderer.renderFillRect(&box_b);
        if (intersection(box_a, box_b)) |area| {
            try renderer.setRenderDrawColor(120, 220, 90, 255);
            try renderer.renderFillRect(&area);
        }
        try renderer.renderPresent();
    }
}
