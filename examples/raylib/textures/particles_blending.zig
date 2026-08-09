//! RAYLIB-DERIVED: SDL3 port of examples/textures/textures_particles_blending.c.
//! Upstream: raysan5/raylib@3e49c8079949c51f69d55a879d490cd6d41a58fa.

const image = @import("image");
const sdl = @import("sdl");

const Particle = struct { x: f32, y: f32, vx: f32, vy: f32, life: f32 };

pub fn main() !void {
    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    const result = try sdl.render.createWindowAndRenderer("raylib port: particles blending", 800, 450, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const texture = image.loadTexture(&renderer, "raylib/spark_flame.png") orelse return error.SdlFailure;
    defer sdl.render.destroyTexture(texture);
    try sdl.render.setTextureBlendMode(texture, sdl.blendmode.blend_mode_add);
    var particles: [300]Particle = undefined;
    var random: u32 = 0x4f1bbcdc;
    for (&particles) |*particle| particle.life = 0;

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        const mouse = sdl.mouse.getState();
        for (&particles) |*particle| {
            if (particle.life <= 0) {
                random = random *% 1664525 +% 1013904223;
                particle.* = .{
                    .x = mouse.x,
                    .y = mouse.y,
                    .vx = @as(f32, @floatFromInt(@as(i32, @intCast(random % 200)) - 100)) / 100.0,
                    .vy = -1.0 - @as(f32, @floatFromInt((random >> 8) % 200)) / 100.0,
                    .life = 1,
                };
            } else {
                particle.x += particle.vx;
                particle.y += particle.vy;
                particle.life -= 0.015;
            }
        }
        try renderer.setRenderDrawColor(12, 10, 20, 255);
        try renderer.renderClear();
        for (particles) |particle| {
            try sdl.render.setTextureAlphaModFloat(texture, @max(0, particle.life));
            const size = 20 + particle.life * 30;
            try renderer.renderTexture(
                texture,
                null,
                &.{ .x = particle.x - size / 2, .y = particle.y - size / 2, .w = size, .h = size },
            );
        }
        try renderer.renderPresent();
    }
}
