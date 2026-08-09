const sdl = @import("sdl");

pub fn FileCallback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, ?[*:0]const u8, usize) void,
        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, ?[*:0]const u8, usize) void;
        pub fn cCallback(_: *@This()) sdl.dialog.FileCallback {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque, paths: ?*const ?[*:0]const u8, count: c_int) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            self.handler(self.userdata, if (paths) |value| value.*[0] else null, @intCast(@max(count, 0)));
        }
    };
}

pub const FileFilter = struct {
    name: [:0]const u8,
    pattern: [:0]const u8,
    pub fn toSdl(self: FileFilter) sdl.dialog.FileFilter {
        return .{ .name = self.name.ptr, .pattern = self.pattern.ptr };
    }
};

pub const Properties = struct {
    title: ?[:0]const u8 = null,
    default_location: ?[:0]const u8 = null,
    allow_many: bool = false,
    accept: ?[:0]const u8 = null,
    cancel: ?[:0]const u8 = null,
};

pub const raw = sdl.dialog;
comptime {
    _ = FileCallback(u8);
}
