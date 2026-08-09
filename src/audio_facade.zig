const sdl = @import("sdl");
const std = @import("std");

pub fn StreamCallback(comptime UserData: type) type {
    return *const fn (*UserData, sdl.audio.Stream, c_int, c_int) void;
}

pub fn streamCallback(comptime UserData: type) type {
    return struct {
        const Self = @This();
        userdata: *UserData,
        callback: StreamCallback(UserData),

        pub fn init(userdata: *UserData, callback: StreamCallback(UserData)) Self {
            return .{ .userdata = userdata, .callback = callback };
        }

        pub fn cCallback(_: *Self) sdl.audio.StreamCallback {
            return invoke;
        }

        pub fn cUserdata(self: *Self) ?*anyopaque {
            return @ptrCast(self);
        }

        fn invoke(context: ?*anyopaque, stream: ?sdl.audio.Stream, additional_amount: c_int, total_amount: c_int) callconv(.c) void {
            const self: *Self = @ptrCast(@alignCast(context.?));
            self.callback(self.userdata, stream.?, additional_amount, total_amount);
        }
    };
}

pub const Device = struct {
    id: sdl.audio.DeviceId,
    physical: bool,
    playback: bool,

    pub fn open(id: sdl.audio.DeviceId, spec: ?sdl.audio.Spec) sdl.Error!Device {
        const opened = try sdl.audio.openDevice(id, if (spec) |*value| value else null);
        return .{ .id = opened, .physical = sdl.audio.isDevicePhysical(opened), .playback = sdl.audio.isDevicePlayback(opened) };
    }

    pub fn deinit(self: *@This()) void {
        sdl.audio.closeDevice(self.id);
        self.* = undefined;
    }

    pub fn openStream(self: Device, spec: ?sdl.audio.Spec, callback: sdl.audio.StreamCallback, userdata: ?*anyopaque) sdl.Error!sdl.audio.Stream {
        return sdl.audio.openDeviceStream(self.id, if (spec) |*value| value else null, callback, userdata);
    }
};

pub const DeviceList = struct {
    allocator: std.mem.Allocator,
    ids: []sdl.audio.DeviceId,

    pub fn initPlayback(allocator: std.mem.Allocator) sdl.Error!DeviceList {
        return .{ .allocator = allocator, .ids = try sdl.audio.getPlaybackDevices(allocator) };
    }

    pub fn initRecording(allocator: std.mem.Allocator) sdl.Error!DeviceList {
        return .{ .allocator = allocator, .ids = try sdl.audio.getRecordingDevices(allocator) };
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.ids);
        self.* = undefined;
    }
};

pub const Stream = struct {
    raw: sdl.audio.Stream,
    pub const Options = struct {
        source: ?sdl.audio.Spec = null,
        destination: ?sdl.audio.Spec = null,
    };

    pub fn init(options: Options) sdl.Error!Stream {
        return .{ .raw = try sdl.audio.createStream(
            if (options.source) |*value| value else null,
            if (options.destination) |*value| value else null,
        ) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.audio;

test "typed stream callback factory instantiates" {
    _ = streamCallback(u8);
}

test "typed stream callback invokes userdata handler" {
    const State = struct { calls: usize = 0 };
    const StateCallback = streamCallback(State);
    const handler = struct {
        fn call(state: *State, _: sdl.audio.Stream, _: c_int, _: c_int) void {
            state.calls += 1;
        }
    }.call;
    var state = State{};
    var callback = StateCallback.init(&state, handler);
    var stream: sdl.audio.Stream = undefined;
    callback.cCallback()(callback.cUserdata(), stream, 0, 0);
    try std.testing.expectEqual(@as(usize, 1), state.calls);
}
