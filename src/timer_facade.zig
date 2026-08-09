const sdl = @import("sdl");

pub fn MillisecondCallback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, sdl.timer.Id, u32) u32,
        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, sdl.timer.Id, u32) u32;
        pub fn cCallback(_: *@This()) sdl.timer.Callback {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque, id: sdl.timer.Id, interval: u32) callconv(.c) u32 {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            return self.handler(self.userdata, id, interval);
        }
    };
}

pub fn NanosecondCallback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, sdl.timer.Id, u64) u64,
        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, sdl.timer.Id, u64) u64;
        pub fn cCallback(_: *@This()) sdl.timer.NsCallback {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque, id: sdl.timer.Id, interval: u64) callconv(.c) u64 {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            return self.handler(self.userdata, id, interval);
        }
    };
}

pub const Timer = struct {
    id: sdl.timer.Id,

    pub fn initMilliseconds(interval: u32, callback: sdl.timer.Callback, userdata: ?*anyopaque) sdl.Error!Timer {
        return .{ .id = try sdl.timer.add(interval, callback, userdata) };
    }
    pub fn initNanoseconds(interval: u64, callback: sdl.timer.NsCallback, userdata: ?*anyopaque) sdl.Error!Timer {
        return .{ .id = try sdl.timer.addNs(interval, callback, userdata) };
    }
    pub fn deinit(self: *@This()) void {
        sdl.timer.remove(self.id);
        self.* = undefined;
    }
};

pub const raw = sdl.timer;

comptime {
    _ = MillisecondCallback(u8);
    _ = NanosecondCallback(u8);
}
