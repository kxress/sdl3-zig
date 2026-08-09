const sdl = @import("sdl");

pub const Init = struct {
    flags: sdl.init.Flags,

    pub fn init(flags: sdl.init.Flags) sdl.Error!Init {
        try sdl.init.default(flags);
        return .{ .flags = flags };
    }

    pub fn initSubsystem(flags: sdl.init.Flags) sdl.Error!Init {
        try sdl.init.subSystem(flags);
        return .{ .flags = flags };
    }

    pub fn deinit(self: *@This()) void {
        sdl.init.quitSubSystem(self.flags);
        self.* = undefined;
    }

    pub fn shutdown() void {
        sdl.init.quit();
    }
};

pub const raw = sdl.init;
