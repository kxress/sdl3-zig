//! RAYLIB-DERIVED: SDL3 port of examples/core/core_input_multitouch.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const sdl = @import("sdl");

const Touch = struct { id: u64 = 0, x: f32 = 0, y: f32 = 0, active: bool = false };

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: multitouch", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    var touches = [_]Touch{.{}} ** 10;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |polled| {
            const event = polled.event;
            if (event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
            if (event.type_ == @intFromEnum(sdl.events.EventType.finger_down) or
                event.type_ == @intFromEnum(sdl.events.EventType.finger_motion))
            {
                var slot: usize = 0;
                while (slot < touches.len and touches[slot].active and
                    touches[slot].id != event.tfinger.finger_id) : (slot += 1)
                {}
                if (slot < touches.len) touches[slot] = .{
                    .id = event.tfinger.finger_id,
                    .x = event.tfinger.x * 800,
                    .y = event.tfinger.y * 450,
                    .active = true,
                };
            } else if (event.type_ == @intFromEnum(sdl.events.EventType.finger_up) or
                event.type_ == @intFromEnum(sdl.events.EventType.finger_canceled))
            {
                for (&touches) |*touch| if (touch.id == event.tfinger.finger_id) {
                    touch.active = false;
                };
            }
        }
        try renderer.setRenderDrawColor(245, 245, 245, 255);
        try renderer.renderClear();
        try renderer.setRenderDrawColor(70, 130, 230, 255);
        for (touches) |touch| if (touch.active) {
            try renderer.renderFillRect(&.{ .x = touch.x - 16, .y = touch.y - 16, .w = 32, .h = 32 });
        };
        try renderer.setRenderDrawColor(80, 80, 80, 255);
        try renderer.renderDebugText(24, 24, "Touch the window with multiple fingers.");
        try renderer.renderPresent();
    }
}
