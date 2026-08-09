const sdl = @import("sdl");
const image = @import("image");
const surface_api = @import("surface_facade");

pub fn initBmpFromIo(stream: ?*sdl.ioStream.IoStream) sdl.Error!surface_api.Surface {
    return .{ .raw = image.loadBmpIo(stream) orelse return error.SdlFailure };
}

pub fn initPngFromIo(stream: ?*sdl.ioStream.IoStream) sdl.Error!surface_api.Surface {
    return .{ .raw = image.loadPngIo(stream) orelse return error.SdlFailure };
}
