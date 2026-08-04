const std = @import("std");
const sdl = @import("sdl");

pub fn main() !void {
    var args = try std.process.argsWithAllocator(std.heap.page_allocator);
    defer args.deinit();
    _ = args.next();
    const format_name = args.next() orelse return usage();
    const path = args.next() orelse return usage();
    if (args.next() != null) return usage();

    const format = parseFormat(format_name) orelse return usage();
    const bytes = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, path, 64 * 1024 * 1024);
    defer std.heap.page_allocator.free(bytes);

    try sdl.init.default(.{ .video = true });
    defer sdl.init.quit();
    var device = try sdl.gpu.createDevice(format, false, null);
    defer device.deinit();
    if (device.getShaderFormats() & format == 0) return error.UnsupportedShaderFormat;

    var info = sdl.gpu.ShaderCreateInfo{
        .code_size = bytes.len,
        .code = bytes.ptr,
        .entrypoint = "main",
        .format = format,
        .stage = .vertex,
        .num_samplers = 0,
        .num_storage_textures = 0,
        .num_storage_buffers = 0,
        .num_uniform_buffers = 0,
        .props = 0,
    };
    var shader = try sdl.gpu.createShader(device, &info);
    shader.deinit();
}

fn parseFormat(name: []const u8) ?u32 {
    if (std.mem.eql(u8, name, "spirv")) return sdl.gpu.shader_format_spirv;
    if (std.mem.eql(u8, name, "dxil")) return sdl.gpu.shader_format_dxil;
    if (std.mem.eql(u8, name, "msl")) return sdl.gpu.shader_format_msl;
    return null;
}

fn usage() error{InvalidArguments} {
    std.debug.print(
        "usage: sdl-shader-device-load <spirv|dxil|msl> <shader-file>\n",
        .{},
    );
    return error.InvalidArguments;
}
