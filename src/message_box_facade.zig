const sdl = @import("sdl");

pub const BoxFlags = struct {
    raw: sdl.messagebox.MessageBoxFlags,
    pub fn fromSdl(raw: sdl.messagebox.MessageBoxFlags) BoxFlags {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: BoxFlags) sdl.messagebox.MessageBoxFlags {
        return self.raw;
    }
};

pub const BoxData = struct {
    raw: sdl.messagebox.MessageBoxData,
    pub fn fromSdl(raw: sdl.messagebox.MessageBoxData) BoxData {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: BoxData) sdl.messagebox.MessageBoxData {
        return self.raw;
    }
};

pub const Button = struct {
    pub const Flags = struct {
        raw: sdl.messagebox.MessageBoxButtonFlags,
        pub fn fromSdl(raw: sdl.messagebox.MessageBoxButtonFlags) Flags {
            return .{ .raw = raw };
        }
        pub fn toSdl(self: Flags) sdl.messagebox.MessageBoxButtonFlags {
            return self.raw;
        }
    };
};

pub const Color = struct {
    raw: sdl.messagebox.MessageBoxColor,
    pub fn fromSdl(raw: sdl.messagebox.MessageBoxColor) Color {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Color) sdl.messagebox.MessageBoxColor {
        return self.raw;
    }
    pub fn fromHex(value: u24) Color {
        return .{ .raw = .{ .r = @intCast(value >> 16), .g = @intCast(value >> 8), .b = @intCast(value) } };
    }
};

pub const ColorScheme = struct {
    colors: [5]Color,
    pub fn toSdl(self: ColorScheme) sdl.messagebox.MessageBoxColorScheme {
        var result: sdl.messagebox.MessageBoxColorScheme = undefined;
        for (self.colors, 0..) |color, index| result.colors[index] = color.toSdl();
        return result;
    }
};

pub const raw = sdl.messagebox;
