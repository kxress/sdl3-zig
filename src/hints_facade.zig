const sdl = @import("sdl");
const std = @import("std");

pub fn Callback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, ?[:0]const u8, ?[:0]const u8, ?[:0]const u8) void,

        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, ?[:0]const u8, ?[:0]const u8, ?[:0]const u8) void;
        pub fn cCallback(_: *@This()) sdl.hints.HintCallback {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }

        fn invoke(userdata: ?*anyopaque, name: ?[*:0]const u8, old: ?[*:0]const u8, new: ?[*:0]const u8) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            self.handler(self.userdata, toSlice(name), toSlice(old), toSlice(new));
        }
        fn toSlice(value: ?[*:0]const u8) ?[:0]const u8 {
            return if (value) |item| std.mem.span(item) else null;
        }
    };
}

pub const raw = sdl.hints;
comptime {
    _ = Callback(u8);
}
