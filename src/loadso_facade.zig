const sdl = @import("sdl");

pub const SharedObject = struct {
    raw: sdl.sharedObject.SharedObject,

    pub fn init(path: ?[:0]const u8) sdl.Error!SharedObject {
        return .{ .raw = try sdl.sharedObject.loadObject(path) };
    }

    pub fn loadFunction(self: @This(), name: ?[:0]const u8) sdl.Error!sdl.sharedObject.FunctionPointer {
        return self.raw.loadFunction(name);
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.sharedObject;
