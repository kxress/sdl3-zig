//! Port of SDL's examples/camera/01-read-and-draw.
//! Upstream: libsdl-org/SDL@6880bed495226e7b87e9ef08fc552c0bcfd5fc29.

const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    try sdl.init(.{ .video = true, .camera = true });
    defer sdl.quit();
    const result = try sdl.render.createWindowAndRenderer("SDL camera: read and draw", 640, 480, .{});
    var window = result.window;
    defer window.deinit();
    var renderer = result.renderer;
    defer renderer.deinit();
    try renderer.setRenderVSync(1);
    const ids = try sdl.camera.getCameras(std.heap.page_allocator);
    defer std.heap.page_allocator.free(ids);
    var camera: ?sdl.camera.Camera = if (ids.len > 0) try sdl.camera.open(ids[0], null) else null;
    defer if (camera) |*device| device.close();

    var running = true;
    while (running) {
        while (sdl.events.pollEvent()) |event| {
            if (event.event.type_ == @intFromEnum(sdl.events.EventType.quit)) running = false;
        }
        try renderer.setRenderDrawColor(12, 12, 16, 255);
        try renderer.renderClear();
        if (camera) |device| {
            if (device.acquireFrame(null)) |frame| {
                const texture = try renderer.createTextureFromSurface(frame);
                try renderer.renderTexture(texture, null, &.{ .x = 0, .y = 0, .w = 640, .h = 480 });
                sdl.render.destroyTexture(texture);
                device.releaseFrame(frame);
            } else {
                try renderer.setRenderDrawColor(245, 245, 245, 255);
                try renderer.renderDebugText(24, 24, "Waiting for camera permission or a frame...");
            }
        } else {
            try renderer.setRenderDrawColor(245, 245, 245, 255);
            try renderer.renderDebugText(24, 24, "No camera found.");
        }
        try renderer.renderPresent();
    }
}
