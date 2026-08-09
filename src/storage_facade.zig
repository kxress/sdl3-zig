const sdl = @import("sdl");
const filesystem = @import("filesystem_facade");

pub const Path = filesystem.Path;
pub const EnumerationCallback = filesystem.EnumerationCallback;

pub const Storage = struct {
    raw: sdl.storage.Storage,

    pub fn initFile(path: [:0]const u8) sdl.Error!Storage {
        return .{ .raw = try sdl.storage.openFile(path) };
    }
    pub fn initTitle(override_path: ?[:0]const u8, props: u32) sdl.Error!Storage {
        return .{ .raw = try sdl.storage.openTitle(override_path, props) };
    }
    pub fn initUser(organization: [:0]const u8, application: [:0]const u8, props: u32) sdl.Error!Storage {
        return .{ .raw = try sdl.storage.openUser(organization, application, props) };
    }
    pub fn deinit(self: *@This()) sdl.Error!void {
        try self.raw.close();
        self.* = undefined;
    }

    pub fn enumerateDirectory(self: @This(), path: ?[:0]const u8, callback: anytype) sdl.Error!void {
        return self.raw.enumerateDirectory(path, callback.cCallback(), callback.cUserdata());
    }
};

pub const raw = sdl.storage;
