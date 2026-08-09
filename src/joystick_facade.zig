const sdl = @import("sdl");

pub const Id = struct {
    raw: sdl.joystick.Id,
    pub fn fromSdl(raw: sdl.joystick.Id) ?Id {
        if (raw == 0) return null;
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Id) sdl.joystick.Id {
        return self.raw;
    }
};

pub const AxisMask = struct {
    raw: u32,
    pub fn contains(self: AxisMask, axis: u5) bool {
        return self.raw & (@as(u32, 1) << axis) != 0;
    }
    pub fn with(self: AxisMask, axis: u5) AxisMask {
        return .{ .raw = self.raw | (@as(u32, 1) << axis) };
    }
};

pub const ButtonMask = struct {
    raw: u32,
    pub fn contains(self: ButtonMask, button: u5) bool {
        return self.raw & (@as(u32, 1) << button) != 0;
    }
    pub fn with(self: ButtonMask, button: u5) ButtonMask {
        return .{ .raw = self.raw | (@as(u32, 1) << button) };
    }
};

pub const ConnectionState = struct {
    raw: sdl.joystick.ConnectionState,
    pub fn fromSdl(raw: sdl.joystick.ConnectionState) ConnectionState {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: ConnectionState) sdl.joystick.ConnectionState {
        return self.raw;
    }
};

pub const VirtualDesc = sdl.joystick.VirtualDesc;

pub fn VirtualJoystickDescription(comptime UserData: type) type {
    return struct {
        raw: VirtualDesc,
        userdata: *UserData,
        callbacks: Callbacks,

        pub const Callbacks = struct {
            update: ?*const fn (*UserData) void = null,
            set_player_index: ?*const fn (*UserData, i32) void = null,
            rumble: ?*const fn (*UserData, u16, u16) bool = null,
            rumble_triggers: ?*const fn (*UserData, u16, u16) bool = null,
            set_led: ?*const fn (*UserData, u8, u8, u8) bool = null,
            send_effect: ?*const fn (*UserData, []const u8) bool = null,
            set_sensors_enabled: ?*const fn (*UserData, bool) bool = null,
            cleanup: ?*const fn (*UserData) void = null,
        };

        pub fn init(base: VirtualDesc, userdata: *UserData, callbacks: Callbacks) @This() {
            var result = @This(){ .raw = base, .userdata = userdata, .callbacks = callbacks };
            result.raw.userdata = @ptrCast(&result);
            result.raw.update = if (callbacks.update != null) update else null;
            result.raw.set_player_index = if (callbacks.set_player_index != null) setPlayerIndex else null;
            result.raw.rumble = if (callbacks.rumble != null) rumble else null;
            result.raw.rumble_triggers = if (callbacks.rumble_triggers != null) rumbleTriggers else null;
            result.raw.set_led = if (callbacks.set_led != null) setLed else null;
            result.raw.send_effect = if (callbacks.send_effect != null) sendEffect else null;
            result.raw.set_sensors_enabled = if (callbacks.set_sensors_enabled != null) setSensorsEnabled else null;
            result.raw.cleanup = if (callbacks.cleanup != null) cleanup else null;
            return result;
        }

        fn state(value: ?*anyopaque) *@This() {
            return @ptrCast(@alignCast(value.?));
        }
        fn update(value: ?*anyopaque) callconv(.c) void {
            state(value).callbacks.update.?(state(value).userdata);
        }
        fn setPlayerIndex(value: ?*anyopaque, index: c_int) callconv(.c) void {
            state(value).callbacks.set_player_index.?(state(value).userdata, index);
        }
        fn rumble(value: ?*anyopaque, low: u16, high: u16) callconv(.c) bool {
            return state(value).callbacks.rumble.?(state(value).userdata, low, high);
        }
        fn rumbleTriggers(value: ?*anyopaque, left: u16, right: u16) callconv(.c) bool {
            return state(value).callbacks.rumble_triggers.?(state(value).userdata, left, right);
        }
        fn setLed(value: ?*anyopaque, red: u8, green: u8, blue: u8) callconv(.c) bool {
            return state(value).callbacks.set_led.?(state(value).userdata, red, green, blue);
        }
        fn sendEffect(value: ?*anyopaque, data: ?*const anyopaque, size: c_int) callconv(.c) bool {
            return state(value).callbacks.send_effect.?(state(value).userdata, @as([*]const u8, @ptrCast(data.?))[0..@intCast(size)]);
        }
        fn setSensorsEnabled(value: ?*anyopaque, enabled: bool) callconv(.c) bool {
            return state(value).callbacks.set_sensors_enabled.?(state(value).userdata, enabled);
        }
        fn cleanup(value: ?*anyopaque) callconv(.c) void {
            state(value).callbacks.cleanup.?(state(value).userdata);
        }
    };
}

pub const Joystick = struct {
    raw: sdl.joystick.Joystick,

    pub fn init(id: Id) sdl.Error!Joystick {
        return .{ .raw = try sdl.joystick.open(id.raw) };
    }

    pub fn initVirtual(desc: *const VirtualDesc) sdl.Error!Id {
        return .{ .raw = try sdl.joystick.attachVirtual(desc) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub fn deinitVirtual(id: Id) sdl.Error!void {
    return sdl.joystick.detachVirtual(id.raw);
}

pub const raw = sdl.joystick;
comptime {
    _ = VirtualJoystickDescription(u8);
}
