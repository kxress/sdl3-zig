const sdl = @import("sdl");

pub fn X11EventHook(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, ?*sdl.system.XEvent) bool,
        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, ?*sdl.system.XEvent) bool;
        pub fn cCallback(_: *@This()) sdl.system.X11EventHook {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque, event: ?*sdl.system.XEvent) callconv(.c) bool {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            return self.handler(self.userdata, event);
        }
    };
}

pub const raw = sdl.system;
comptime {
    _ = X11EventHook(u8);
}
