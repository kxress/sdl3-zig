const sdl = @import("sdl");

pub fn Callback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, ?*const sdl.assert.Data) sdl.assert.State,

        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub const Handler = *const fn (*UserData, ?*const sdl.assert.Data) sdl.assert.State;

        pub fn cHandler(_: *@This()) sdl.assert.AssertionHandler {
            return invoke;
        }

        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }

        fn invoke(data: ?*const sdl.assert.Data, context: ?*anyopaque) callconv(.c) sdl.assert.State {
            const self: *@This() = @ptrCast(@alignCast(context.?));
            return self.handler(self.userdata, data);
        }
    };
}

pub const raw = sdl.assert;

comptime {
    _ = Callback(u8);
}
