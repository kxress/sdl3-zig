const sdl = @import("sdl");

pub fn EnumValue(comptime Enum: type) type {
    return struct {
        raw: Enum,
        pub fn fromSdl(raw: Enum) @This() {
            return .{ .raw = raw };
        }
        pub fn toSdl(self: @This()) Enum {
            return self.raw;
        }
    };
}

pub const Flags = struct {
    raw: sdl.surface.Flags = .{},
    pub fn fromSdl(raw: sdl.surface.Flags) Flags {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Flags) sdl.surface.Flags {
        return self.raw;
    }
};
pub const FlipMode = EnumValue(sdl.surface.FlipMode);
pub const ScaleMode = EnumValue(sdl.surface.ScaleMode);

pub const Surface = struct {
    raw: *sdl.surface.Surface,

    pub fn init(width: i32, height: i32, format: sdl.pixels.PixelFormat) sdl.Error!Surface {
        return .{ .raw = try sdl.surface.create(width, height, format) };
    }

    pub fn initFrom(width: i32, height: i32, format: sdl.pixels.PixelFormat, pixels: ?*anyopaque, pitch: i32) sdl.Error!Surface {
        return .{ .raw = try sdl.surface.createFrom(width, height, format, pixels, pitch) };
    }

    pub fn initFromFile(path: [:0]const u8) sdl.Error!Surface {
        return .{ .raw = try sdl.surface.load(path) };
    }

    pub fn initFromIo(stream: ?sdl.ioStream.IoStream, close_io: bool) sdl.Error!Surface {
        return .{ .raw = try sdl.surface.loadIo(stream, close_io) };
    }

    pub fn deinit(self: *@This()) void {
        sdl.surface.destroy(self.raw);
        self.* = undefined;
    }
};

pub const raw = sdl.surface;
