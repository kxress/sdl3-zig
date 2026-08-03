const std = @import("std");
const sdl = @import("sdl");
const sdl3 = @import("sdl3");
const controller_image = @import("controller_image");
const shadercross = @import("shadercross");
const image = @import("image");
const ttf = @import("ttf");
const mixer = @import("mixer");
const net = @import("net");
const shadercross_spirv = [_]u32{
    0x07230203, 0x00010000, 0,          6,          0,
    0x00020011, 1,          0x0003000e, 0,          1,
    0x0004000f, 5,          4,          0x6e69616d, 0x00060010,
    4,          17,         1,          1,          1,
    0x00020013, 2,          0x00030021, 3,          2,
    0x00050036, 2,          4,          0,          3,
    0x000200f8, 5,          0x000100fd, 0x00010038,
};
const decoder_gif = [_]u8{
    'G',  'I',  'F',  '8',  '9', 'a', 1,    0,    1, 0, 0x80, 0, 0,
    0xff, 0xff, 0xff, 0,    0,   0,   0x21, 0xf9, 4, 1, 0,    0, 0,
    0,    0x2c, 0,    0,    0,   0,   1,    0,    1, 0, 0,    2, 2,
    0x4c, 1,    0,    0x3b,
};

pub fn main() !void {
    std.debug.assert(sdl.version.get() > 0);
    sdl3.@"test".fuzzerInit(0x5d1);
    _ = sdl3.@"test".randomUint32();
    try controller_image.init();
    defer controller_image.quit();
    try controller_image.addDataFromFile("controllerimage-standard.bin");
    var gamepad = controller_image.createGamepadDeviceByIdString("xbox360") orelse
        @panic("ControllerImage did not discover the generated controller artwork");
    gamepad.deinit();
    const spirv_info: shadercross.shadercross.SpirvInfo = .{
        .bytecode = @ptrCast(&shadercross_spirv),
        .bytecode_size = @sizeOf(@TypeOf(shadercross_spirv)),
        .entrypoint = @ptrCast("main"),
        .shader_stage = .compute,
        .props = 0,
    };
    const shader = shadercross.shadercross.transpileHlslFromSpirv(&spirv_info) orelse
        @panic("SDL_shadercross did not transpile SPIR-V to HLSL");
    defer sdl.stdinc.free(shader);
    var decoder_stream = try sdl.ioStream.ioFromConstMem(&decoder_gif);
    defer decoder_stream.close() catch {};
    const decoded = image.loadGifIo(&decoder_stream) orelse
        @panic("SDL_image did not decode the built-in GIF fixture");
    defer sdl.surface.destroy(decoded);
    std.debug.assert(decoded.w == 1 and decoded.h == 1);
    std.debug.assert(image.version() > 0);
    std.debug.assert(ttf.version() > 0);
    std.debug.assert(mixer.version() > 0);
    std.debug.assert(net.version() > 0);
}
