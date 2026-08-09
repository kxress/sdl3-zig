const sdl = @import("sdl");
const std = @import("std");

pub const Direction = struct {
    raw: sdl.haptic.Direction,
    pub fn fromSdl(raw: sdl.haptic.Direction) Direction {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Direction) sdl.haptic.Direction {
        return self.raw;
    }
};

pub const Features = struct {
    raw: u32 = 0,
    pub fn fromSdl(raw: u32) Features {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Features) u32 {
        return self.raw;
    }
    pub fn contains(self: Features, feature: u32) bool {
        return self.raw & feature != 0;
    }
};

pub const Effect = struct {
    raw: sdl.haptic.Effect,
    pub fn fromSdl(raw: sdl.haptic.Effect) Effect {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Effect) sdl.haptic.Effect {
        return self.raw;
    }
    pub fn default() Effect {
        return .{ .raw = std.mem.zeroes(sdl.haptic.Effect) };
    }
};

pub fn Variant(comptime Raw: type) type {
    return struct {
        raw: Raw,
        pub fn fromSdl(raw: Raw) @This() {
            return .{ .raw = raw };
        }
        pub fn toSdl(self: @This()) Raw {
            return self.raw;
        }
        pub fn default() @This() {
            return .{ .raw = std.mem.zeroes(Raw) };
        }
    };
}

pub const Constant = Variant(sdl.haptic.Constant);
pub const Periodic = Variant(sdl.haptic.Periodic);
pub const Condition = Variant(sdl.haptic.Condition);
pub const Ramp = Variant(sdl.haptic.Ramp);
pub const LeftRight = Variant(sdl.haptic.LeftRight);
pub const Custom = Variant(sdl.haptic.Custom);

pub const Haptic = struct {
    raw: sdl.haptic.Haptic,

    pub fn init(id: sdl.haptic.Id) sdl.Error!Haptic {
        return .{ .raw = try sdl.haptic.open(id) };
    }

    pub fn initFromJoystick(joystick: sdl.joystick.Joystick) sdl.Error!Haptic {
        return .{ .raw = try sdl.haptic.openFromJoystick(joystick) };
    }

    pub fn initFromMouse() sdl.Error!Haptic {
        return .{ .raw = try sdl.haptic.openFromMouse() };
    }

    pub fn initRumble(self: @This()) sdl.Error!void {
        return self.raw.initRumble();
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.haptic;
