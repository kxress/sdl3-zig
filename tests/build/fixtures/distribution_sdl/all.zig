const std = @import("std");
const builtin = @import("builtin");
const image = @import("image");
const mixer = @import("mixer");
const net = @import("net");
const sdl = @import("sdl");
const sdl3 = @import("sdl3");
const ttf = @import("ttf");

pub fn main() void {
    const io_interface = sdl.ioStream.Interface.init();
    std.debug.assert(io_interface.version == @sizeOf(sdl.ioStream.Interface));
    std.debug.assert(io_interface.size == null and io_interface.close == null);
    const storage_interface = sdl.storage.Interface.default;
    std.debug.assert(storage_interface.version == @sizeOf(sdl.storage.Interface));
    std.debug.assert(storage_interface.close == null and storage_interface.write_file == null);
    const virtual_joystick = sdl.joystick.VirtualDesc.init();
    std.debug.assert(virtual_joystick.version == @sizeOf(sdl.joystick.VirtualDesc));
    std.debug.assert(virtual_joystick.userdata == null and virtual_joystick.update == null);
    const text_engine = ttf.textengine.TextEngine.default;
    std.debug.assert(text_engine.version == @sizeOf(ttf.textengine.TextEngine));
    std.debug.assert(text_engine.userdata == null and text_engine.create_text == null);
    comptime {
        if (sdl.revision.len == 0) @compileError("SDL revision must not be empty");
    }
    comptime {
        _ = sdl.main;
        _ = sdl.runApp;
        _ = sdl.setMainReady;
        _ = sdl.enterAppMainCallbacks;
        _ = sdl.atomic.incRef;
        _ = sdl.atomic.decRef;
        _ = sdl.thread.create;
        _ = sdl.thread.createWithProperties;
        _ = sdl.surface.mustlock;
        _ = sdl.vulkan.loadLibrary;
        _ = sdl.vulkan.getInstanceExtensions;
        _ = sdl.vulkan.getVkGetInstanceProcAddr;
    }
    comptime {
        const pixel_format = sdl.pixels.definePixelFormat(2, 3, 4, 5, 6);
        if (sdl.pixels.pixelType(pixel_format) != 2) @compileError("pixel macro mismatch");
        if (sdl.pixels.definePixelfourcc('Y', 'V', '1', '2') != 0x32315659) {
            @compileError("fourcc macro mismatch");
        }
        if (sdl.audio.bitSize(0x8010) != 16) @compileError("audio macro mismatch");
        if (!sdl.audio.islittleendian(0x8010)) @compileError("audio endian macro mismatch");
        if (sdl.mouse.buttonMask(1) != 1) @compileError("mouse macro mismatch");
        if (sdl.keycode.scancodeTo(1) != (1 | sdl.keycode.scancode_mask)) {
            @compileError("keycode macro mismatch");
        }
        if (sdl.timer.msToNs(2) != 2_000_000) @compileError("timer macro mismatch");
        if (sdl.version.numMajor(sdl.version.num(3, 4, 12)) != 3) {
            @compileError("version macro mismatch");
        }
        const centered = sdl.video.windowPosCenteredDisplay(7);
        if (!sdl.video.windowPosIscentered(centered)) @compileError("window macro mismatch");
    }
    if (builtin.os.tag == .linux) {
        if (false) {
            const ap: std.builtin.VaList = undefined;
            var buffer: [64]u8 = undefined;
            _ = sdl.stdinc.vsnprintf(buffer[0..], "%d %f %p %s", ap);
        }
    }
    if (false) {
        var buffer: [64]u8 = undefined;
        var scanned: c_int = 0;
        _ = sdl.stdinc.snprintf(
            buffer[0..].ptr,
            @as(c_ulong, buffer.len),
            "%d %f %p %s",
            .{ @as(u8, 1), @as(f32, 2.0), @as(*anyopaque, undefined), @as([*:0]const u8, "x") },
        );
        _ = sdl.stdinc.sscanf("1", "%d", .{&scanned});
    }
    comptime {
        _ = image;
        _ = mixer;
        _ = net;
        _ = sdl;
        _ = sdl3.core;
        _ = ttf;
    }
}
