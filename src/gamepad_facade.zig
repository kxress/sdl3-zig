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

pub const Axis = EnumValue(sdl.gamepad.Axis);
pub const Button = EnumValue(sdl.gamepad.Button);
pub const BindingType = EnumValue(sdl.gamepad.BindingType);
pub const ButtonLabel = EnumValue(sdl.gamepad.ButtonLabel);

pub const Type = struct {
    raw: sdl.gamepad.Type,
    pub fn fromSdl(raw: sdl.gamepad.Type) ?Type {
        return switch (raw) {
            .unknown, .invalid => null,
            else => .{ .raw = raw },
        };
    }
    pub fn toSdl(self: Type) sdl.gamepad.Type {
        return self.raw;
    }
};

pub const Binding = sdl.gamepad.Binding;

pub const Id = sdl.joystick.Id;

pub const Gamepad = struct {
    raw: sdl.gamepad.Gamepad,

    pub fn init(id: Id) ?Gamepad {
        return if (sdl.gamepad.open(id)) |raw| .{ .raw = raw } else null;
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.gamepad;
