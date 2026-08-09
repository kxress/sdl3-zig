const sdl = @import("sdl");
const std = @import("std");

pub fn OutputCallback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, c_int, sdl.log.Priority, ?[:0]const u8) void,

        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, c_int, sdl.log.Priority, ?[:0]const u8) void;
        pub fn cCallback(_: *@This()) sdl.log.OutputFunction {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque, category: c_int, priority: sdl.log.Priority, message: ?[*:0]const u8) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            self.handler(self.userdata, category, priority, if (message) |value| std.mem.span(value) else null);
        }
    };
}

pub const raw = sdl.log;
comptime {
    _ = OutputCallback(u8);
}
