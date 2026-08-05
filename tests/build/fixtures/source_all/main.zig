const std = @import("std");
const sdl = @import("sdl");
const sdl3 = @import("sdl3");
const controller_image = @import("controller_image");
const shadercross = @import("shadercross");
const image = @import("image");
const ttf = @import("ttf");
const mixer = @import("mixer");
const net = @import("net");
const build_options = @import("source_all_options");

fn threadEntry(data: ?*anyopaque) callconv(.c) c_int {
    const refcount: *sdl.atomic.Int = @ptrCast(@alignCast(data.?));
    _ = sdl.atomic.incRef(refcount);
    return 37;
}

fn countedRect(counter: *usize, rect: *const sdl.rect.Rect) ?*const sdl.rect.Rect {
    counter.* += 1;
    return rect;
}

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
    // SDL_RectEmpty is SDL_FORCE_INLINE in the pinned headers. A side-effecting argument
    // producer proves the generated wrapper and the C helper observe C's one-evaluation call
    // contract without adding any production bookkeeping.
    var rect_evaluation_count: usize = 0;
    const non_empty_rect = sdl.rect.Rect{ .x = 0, .y = 0, .w = 1, .h = 1 };
    std.debug.assert(!sdl.rect.empty(countedRect(&rect_evaluation_count, &non_empty_rect)));
    std.debug.assert(rect_evaluation_count == 1);

    if (build_options.source_feature_smoke) {
        try sdl.init.default(.{
            .audio = true,
            .video = true,
            .camera = true,
        });
        defer sdl.init.quit();

        std.debug.assert(sdl.audio.getNumDrivers() > 0);
        std.debug.assert(sdl.video.getNumDrivers() > 0);
        std.debug.assert(sdl.camera.getNumDrivers() > 0);
        _ = sdl.gpu.getNumDrivers();
        _ = sdl.gpu.supportsShaderFormats(sdl.gpu.shader_format_spirv, null);

        var window = try sdl.video.createWindow("sdl3-source-features", 64, 64, .{ .hidden = true });
        defer window.deinit();
        var renderer = sdl.render.createRenderer(window, null) orelse
            @panic("SDL source feature profile could not create a renderer");
        defer renderer.deinit();
        if (!build_options.controller_image_data_smoke) return;
    }
    try ttf.init();
    defer ttf.quit();
    const freetype_version = ttf.getFreeTypeVersion();
    std.debug.assert(freetype_version.major > 0);
    var refcount: sdl.atomic.Int = .{ .value = 1 };
    var worker = sdl.thread.create(threadEntry, null, &refcount) orelse
        @panic("SDL thread creation failed");
    std.debug.assert(worker.wait() == 37);
    std.debug.assert(sdl.atomic.getInt(&refcount) == 2);
    std.debug.assert(!sdl.atomic.decRef(&refcount));
    std.debug.assert(sdl.atomic.getInt(&refcount) == 1);
    std.debug.assert(sdl.version.get() > 0);
    const spirv_info: shadercross.shadercross.SpirvInfo = .{
        .bytecode = @ptrCast(&shadercross_spirv),
        .bytecode_size = @sizeOf(@TypeOf(shadercross_spirv)),
        .entrypoint = @ptrCast("main"),
        .shader_stage = .compute,
        .props = 0,
    };
    sdl3.@"test".fuzzerInit(0x5d1);
    _ = sdl3.@"test".randomUint32();
    try controller_image.init();
    defer controller_image.quit();
    try controller_image.addDataFromFile("controllerimage-standard.bin");
    var gamepad = controller_image.createGamepadDeviceByIdString("xbox360") orelse
        @panic("ControllerImage did not discover the generated controller artwork");
    gamepad.deinit();
    if (build_options.shadercross_dxc_smoke) {
        const shader = shadercross.shadercross.transpileHlslFromSpirv(&spirv_info) orelse
            @panic("SDL_shadercross did not transpile SPIR-V to HLSL with DXC");
        sdl.stdinc.free(shader);
        const hlsl_info: shadercross.shadercross.HlslInfo = .{
            .source = @ptrCast("[numthreads(1, 1, 1)] void main() {}"),
            .entrypoint = @ptrCast("main"),
            .include_dir = null,
            .defines = null,
            .shader_stage = .compute,
            .props = 0,
        };
        var dxil_size: c_ulong = 0;
        const dxil = shadercross.shadercross.compileDxilFromHlsl(&hlsl_info, &dxil_size) orelse
            @panic("SDL_shadercross did not compile HLSL to DXIL with DXC");
        std.debug.assert(dxil_size != 0);
        sdl.stdinc.free(dxil);
        return;
    }
    if (build_options.controller_image_data_smoke) return;
    const shader = shadercross.shadercross.transpileHlslFromSpirv(&spirv_info) orelse
        @panic("SDL_shadercross did not transpile SPIR-V to HLSL");
    defer sdl.stdinc.free(shader);
    var decoder_stream = try sdl.ioStream.ioFromConstMem(&decoder_gif);
    defer decoder_stream.close() catch {};
    const decoded = image.loadGifIo(&decoder_stream) orelse
        @panic("SDL_image did not decode the built-in GIF fixture");
    defer sdl.surface.destroy(decoded);
    std.debug.assert(decoded.w == 1 and decoded.h == 1);
    std.debug.assert(image.versionDefault() > 0);

    try mixer.init();
    defer mixer.quit();
    var mixer_spec = sdl.audio.Spec{ .format = .s16, .channels = 2, .freq = 48_000 };
    var generated_mixer = try mixer.createMixer(&mixer_spec);
    defer generated_mixer.deinit();
    var sine = try mixer.createSineWaveAudio(generated_mixer, 440, 0.1, 10);
    defer sine.deinit();
    var track = mixer.createTrack(generated_mixer) orelse
        @panic("SDL_mixer could not create a generated-audio track");
    defer track.deinit();
    try track.setAudio(sine);
    try track.play(0);
    var mixed_audio: [4096]u8 = undefined;
    const mixed_bytes = try mixer.generate(generated_mixer, mixed_audio[0..]);
    std.debug.assert(mixed_bytes > 0);

    try net.init();
    defer net.quit();
    var datagram_socket = net.createDatagramSocket(null, 0, 0) orelse
        @panic("SDL_net could not create a local datagram socket");
    defer datagram_socket.deinit();
    var datagram: ?*net.Datagram = null;
    std.debug.assert(datagram_socket.receive(&datagram));
    std.debug.assert(datagram == null);
    std.debug.assert(net.versionDefault() > 0);
}
