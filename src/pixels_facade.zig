const sdl = @import("sdl");

/// A round-trippable typed value for an SDL enum.
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

pub const Order = EnumValue(sdl.pixels.PackedOrder);
pub const Layout = EnumValue(sdl.pixels.PackedLayout);
pub const Type = EnumValue(sdl.pixels.PixelType);
pub const Range = EnumValue(sdl.pixels.ColorRange);
pub const Primaries = EnumValue(sdl.pixels.ColorPrimaries);
pub const Matrix = EnumValue(sdl.pixels.MatrixCoefficients);
pub const Transfer = EnumValue(sdl.pixels.TransferCharacteristics);

/// Owned palette wrapper with receiver-oriented lifecycle.
pub const Palette = struct {
    raw: *sdl.pixels.Palette,

    pub fn init(color_count: usize) sdl.Error!Palette {
        return .{ .raw = try sdl.pixels.createPalette(@intCast(color_count)) };
    }

    pub fn deinit(self: *@This()) void {
        sdl.pixels.destroyPalette(self.raw);
        self.* = undefined;
    }
};

/// Ergonomic pixel-format value layered over the generated SDL pixel namespace.
pub const Format = struct {
    raw: sdl.pixels.PixelFormat,

    pub fn fromSdl(value: sdl.pixels.PixelFormat) Format {
        return .{ .raw = value };
    }

    pub fn toSdl(self: Format) sdl.pixels.PixelFormat {
        return self.raw;
    }

    pub fn isIndexed(self: Format) bool {
        return sdl.pixels.ispixelformatIndexed(self.raw);
    }

    pub fn isPacked(self: Format) bool {
        return sdl.pixels.ispixelformatPacked(self.raw);
    }

    pub fn isArray(self: Format) bool {
        return sdl.pixels.ispixelformatArray(self.raw);
    }

    pub fn isFloat(self: Format) bool {
        return sdl.pixels.ispixelformatFloat(self.raw);
    }

    pub fn isAlpha(self: Format) bool {
        return sdl.pixels.ispixelformatAlpha(self.raw);
    }

    pub fn details(self: Format) sdl.Error!*const sdl.pixels.PixelFormatDetails {
        return sdl.pixels.getPixelFormatDetails(self.raw);
    }
};

/// The complete generated namespace remains available for ABI-oriented callers.
pub const raw = sdl.pixels;

test "pixel format values round-trip and expose predicates" {
    const format = Format.fromSdl(.rgba8888);
    try @import("std").testing.expectEqual(.rgba8888, format.toSdl());
    try @import("std").testing.expect(format.isPacked());
}

test "pixel component values round-trip" {
    const order = Order.fromSdl(.rgba);
    const range = Range.fromSdl(.limited);
    const matrix = Matrix.fromSdl(.bt709);
    try @import("std").testing.expectEqual(.rgba, order.toSdl());
    try @import("std").testing.expectEqual(.limited, range.toSdl());
    try @import("std").testing.expectEqual(.bt709, matrix.toSdl());
}

test "palette exposes owned lifecycle" {
    comptime {
        _ = Palette.init;
        _ = Palette.deinit;
    }
}
