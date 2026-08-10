const sdl = @import("sdl");
const ttf = @import("ttf");
const std = @import("std");

pub fn EnumValue(comptime Enum: type) type {
    return struct {
        raw: Enum,
        pub fn fromSdl(value: Enum) @This() {
            return .{ .raw = value };
        }
        pub fn toSdl(self: @This()) Enum {
            return self.raw;
        }
    };
}

pub const Direction = EnumValue(ttf.Direction);
pub const Hinting = EnumValue(ttf.HintingFlags);
pub const HorizontalAlignment = EnumValue(ttf.HorizontalAlignment);
pub const ImageType = EnumValue(ttf.ImageType);
pub const GpuTextEngineWinding = EnumValue(ttf.GpuTextEngineWinding);

pub const StyleFlags = struct {
    raw: ttf.FontStyleFlags = .{},
    pub fn fromSdl(value: ttf.FontStyleFlags) StyleFlags {
        return .{ .raw = value };
    }
    pub fn toSdl(self: StyleFlags) ttf.FontStyleFlags {
        return self.raw;
    }
    pub fn bold(self: StyleFlags) bool {
        return self.raw.bold;
    }
    pub fn italic(self: StyleFlags) bool {
        return self.raw.italic;
    }
};

pub const Color = struct {
    raw: sdl.pixels.Color,
    pub fn fromSdl(value: sdl.pixels.Color) Color {
        return .{ .raw = value };
    }
    pub fn toSdl(self: Color) sdl.pixels.Color {
        return self.raw;
    }
};

pub fn Descriptor(comptime Raw: type) type {
    return struct {
        raw: Raw,
        pub fn fromSdl(value: Raw) @This() {
            return .{ .raw = value };
        }
        pub fn toSdl(self: @This()) Raw {
            return self.raw;
        }
        pub fn default() @This() {
            return .{ .raw = std.mem.zeroes(Raw) };
        }
    };
}

pub const TextData = Descriptor(ttf.textengine.TextData);
pub const DrawOperation = Descriptor(ttf.textengine.DrawOperation);
pub const FillOperation = Descriptor(ttf.textengine.FillOperation);
pub const CopyOperation = Descriptor(ttf.textengine.CopyOperation);

pub const Font = struct {
    raw: ttf.Font,

    pub fn init(path: ?[:0]const u8, point_size: f32) sdl.Error!Font {
        return .{ .raw = try ttf.openFont(path, point_size) };
    }

    pub fn initIo(stream: ?*sdl.ioStream.IoStream, close_stream: bool, point_size: f32) sdl.Error!Font {
        return .{ .raw = try ttf.openFontIo(stream, close_stream, point_size) };
    }

    pub fn initWithProperties(properties: sdl.properties.Id) sdl.Error!Font {
        return .{ .raw = try ttf.openFontWithProperties(properties) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const TextEngine = ttf.textengine.TextEngine;

pub const text_engine = struct {
    pub const createGpu = ttf.createGpuTextEngine;
    pub const createGpuWithProperties = ttf.createGpuTextEngineWithProperties;
    pub const createRenderer = ttf.createRendererTextEngine;
    pub const createRendererWithProperties = ttf.createRendererTextEngineWithProperties;
    pub const createSurface = ttf.createSurfaceTextEngine;
    pub const destroyGpu = ttf.destroyGpuTextEngine;
    pub const destroyRenderer = ttf.destroyRendererTextEngine;
    pub const destroySurface = ttf.destroySurfaceTextEngine;
};

pub const raw = ttf;
