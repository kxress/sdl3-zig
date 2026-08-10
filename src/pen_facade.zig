const sdl = @import("sdl");

pub const Axis = struct {
    raw: sdl.pen.Axis,
    pub fn fromSdl(value: sdl.pen.Axis) Axis {
        return .{ .raw = value };
    }
    pub fn toSdl(self: Axis) sdl.pen.Axis {
        return self.raw;
    }
};

pub const Id = struct {
    raw: sdl.pen.Id,
    pub fn fromSdl(value: sdl.pen.Id) ?Id {
        if (value == 0) return null;
        return .{ .raw = value };
    }
    pub fn toSdl(self: Id) sdl.pen.Id {
        return self.raw;
    }
};

pub const InputFlags = struct {
    raw: sdl.pen.InputFlags,
    pub fn fromSdl(value: sdl.pen.InputFlags) InputFlags {
        return .{ .raw = value };
    }
    pub fn toSdl(self: InputFlags) sdl.pen.InputFlags {
        return self.raw;
    }
    pub fn contains(self: InputFlags, flag: sdl.pen.InputFlags) bool {
        return self.raw & flag != 0;
    }
};

pub const DeviceType = struct {
    raw: sdl.pen.DeviceType,
    pub fn fromSdl(value: sdl.pen.DeviceType) ?DeviceType {
        return switch (value) {
            .invalid, .unknown => null,
            else => .{ .raw = value },
        };
    }
    pub fn toSdl(self: DeviceType) sdl.pen.DeviceType {
        return self.raw;
    }
};

pub const raw = sdl.pen;
