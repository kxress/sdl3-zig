const sdl = @import("sdl");
const std = @import("std");
const ownership = @import("ownership");

pub fn getTextOwned(allocator: std.mem.Allocator) sdl.Error!ownership.OwnedZString {
    return .{ .allocator = allocator, .value = try sdl.clipboard.getText(allocator) };
}

pub fn getDataOwned(allocator: std.mem.Allocator, mime_type: ?[:0]const u8) sdl.Error!ownership.OwnedZString {
    return .{ .allocator = allocator, .value = try sdl.clipboard.getData(allocator, mime_type) };
}

pub fn DataCallback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: Handler,
        pub const Handler = *const fn (*UserData, ?[:0]const u8) ?[]const u8;

        pub fn init(userdata: *UserData, handler: Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub fn cHandler(_: *@This()) sdl.clipboard.DataCallback {
            return invoke;
        }

        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }

        fn invoke(userdata: ?*anyopaque, mime_type: ?[*:0]const u8, size: ?*usize) callconv(.c) ?*const anyopaque {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            const mime = if (mime_type) |value| std.mem.span(value) else null;
            const data = self.handler(self.userdata, mime) orelse {
                size.?.* = 0;
                return null;
            };
            size.?.* = data.len;
            return data.ptr;
        }
    };
}

pub const raw = sdl.clipboard;

comptime {
    _ = DataCallback(u8);
}
