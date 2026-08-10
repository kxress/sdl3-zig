const sdl = @import("sdl");

pub fn Function(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData) c_int,
        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData) c_int;
        pub fn cFunction(_: *@This()) sdl.thread.Function {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque) callconv(.c) c_int {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            return self.handler(self.userdata);
        }
    };
}

pub const PropertiesId = sdl.properties.Id;

pub const Thread = struct {
    raw: sdl.thread.Thread,

    pub fn init(function: Function, name: ?[:0]const u8, data: ?*anyopaque) ?Thread {
        return if (sdl.thread.create(function, name, data)) |thread| .{ .raw = thread } else null;
    }

    pub fn initWithProperties(properties: PropertiesId) ?Thread {
        return if (sdl.thread.createWithProperties(properties)) |thread| .{ .raw = thread } else null;
    }

    pub fn wait(self: *@This()) c_int {
        const status = self.raw.wait();
        self.* = undefined;
        return status;
    }

    pub fn detach(self: *@This()) void {
        self.raw.detach();
        self.* = undefined;
    }
};

pub const TlsId = struct {
    raw: sdl.thread.TlsId = .{ .value = 0 },

    pub fn init() TlsId {
        return .{};
    }
};

pub const raw = sdl.thread;

comptime {
    _ = Function(u8);
}
