const std = @import("std");
const sdl = @import("sdl");
const ownership = @import("ownership");

pub fn EnumerationCallback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, ?[:0]const u8, ?[:0]const u8) sdl.filesystem.EnumerationResult,

        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub const Handler = *const fn (*UserData, ?[:0]const u8, ?[:0]const u8) sdl.filesystem.EnumerationResult;

        pub fn cCallback(_: *@This()) sdl.filesystem.EnumerateDirectoryCallback {
            return invoke;
        }

        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }

        fn invoke(userdata: ?*anyopaque, directory: ?[*:0]const u8, name: ?[*:0]const u8) callconv(.c) sdl.filesystem.EnumerationResult {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            return self.handler(self.userdata, if (directory) |value| std.mem.span(value) else null, if (name) |value| std.mem.span(value) else null);
        }
    };
}

pub const Path = struct {
    allocator: std.mem.Allocator,
    value: [:0]u8,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Path {
        return .{ .allocator = allocator, .value = try allocator.dupeZ(u8, path) };
    }
    pub fn get(self: Path) [:0]const u8 {
        return self.value;
    }
    pub fn baseName(self: Path) []const u8 {
        return std.fs.path.basename(self.value);
    }
    pub fn join(allocator: std.mem.Allocator, left: []const u8, right: []const u8) !Path {
        return .{ .allocator = allocator, .value = try std.fs.path.joinZ(allocator, &.{ left, right }) };
    }
    pub fn parent(self: Path) ?[]const u8 {
        return std.fs.path.dirname(self.value);
    }
    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.value);
        self.* = undefined;
    }
};

pub const DirectoryItems = struct {
    allocator: std.mem.Allocator,
    items: [][:0]u8,

    pub fn deinit(self: *@This()) void {
        for (self.items) |item| self.allocator.free(item);
        self.allocator.free(self.items);
        self.* = undefined;
    }
};

const Collector = struct { allocator: std.mem.Allocator, items: std.ArrayList([:0]u8) };

fn collectDirectoryItem(userdata: ?*anyopaque, _: ?[*:0]const u8, name: ?[*:0]const u8) callconv(.c) sdl.filesystem.EnumerationResult {
    const collector: *Collector = @ptrCast(@alignCast(userdata.?));
    const item = collector.allocator.dupeZ(u8, std.mem.span(name orelse return .failure)) catch return .failure;
    collector.items.append(collector.allocator, item) catch {
        collector.allocator.free(item);
        return .failure;
    };
    return .continue_;
}

pub const PathType = sdl.filesystem.PathType;
pub const PathInfo = sdl.filesystem.PathInfo;
pub const Info = struct {
    raw: sdl.filesystem.PathInfo,
    pub fn fromSdl(raw: sdl.filesystem.PathInfo) Info {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Info) sdl.filesystem.PathInfo {
        return self.raw;
    }
};
pub const EnumerationResult = sdl.filesystem.EnumerationResult;
pub const GlobFlags = struct {
    raw: sdl.filesystem.GlobFlags = 0,
    pub fn fromSdl(raw: sdl.filesystem.GlobFlags) GlobFlags {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: GlobFlags) sdl.filesystem.GlobFlags {
        return self.raw;
    }
};

pub fn getPathInfo(path: [:0]const u8) sdl.Error!Info {
    const result = try sdl.filesystem.getPathInfo(path);
    return Info.fromSdl(result.info);
}

pub fn getBasePathOwned(allocator: std.mem.Allocator) sdl.Error!ownership.OwnedZString {
    const path = sdl.filesystem.getBasePath() orelse return error.SdlFailure;
    return .{ .allocator = allocator, .value = try allocator.dupeZ(u8, path) };
}

pub fn getPrefPathOwned(allocator: std.mem.Allocator, organization: ?[:0]const u8, application: ?[:0]const u8) sdl.Error!ownership.OwnedZString {
    return .{ .allocator = allocator, .value = try sdl.filesystem.getPrefPath(allocator, organization, application) };
}

pub fn getUserFolderOwned(allocator: std.mem.Allocator, folder: sdl.filesystem.Folder) sdl.Error!ownership.OwnedZString {
    const path = sdl.filesystem.getUserFolder(folder) orelse return error.SdlFailure;
    return .{ .allocator = allocator, .value = try allocator.dupeZ(u8, path) };
}

pub fn globDirectory(
    allocator: std.mem.Allocator,
    path: ?[:0]const u8,
    pattern: ?[:0]const u8,
    flags: GlobFlags,
) sdl.Error!sdl.OwnedStrings {
    return sdl.filesystem.globDirectory(allocator, path, pattern, flags.raw);
}

pub fn enumerateDirectory(
    path: [:0]const u8,
    callback: sdl.filesystem.EnumerateDirectoryCallback,
    userdata: ?*anyopaque,
) sdl.Error!void {
    return sdl.filesystem.enumerateDirectory(path, callback, userdata);
}

pub fn getAllDirectoryItems(allocator: std.mem.Allocator, path: [:0]const u8) sdl.Error!DirectoryItems {
    var collector = Collector{ .allocator = allocator, .items = .empty };
    errdefer {
        for (collector.items.items) |item| allocator.free(item);
        collector.items.deinit(allocator);
    }
    try sdl.filesystem.enumerateDirectory(path, collectDirectoryItem, &collector);
    return .{ .allocator = allocator, .items = try collector.items.toOwnedSlice(allocator) };
}

pub fn freeAllDirectoryItems(items: *DirectoryItems) void {
    items.deinit();
}
pub const raw = sdl.filesystem;

comptime {
    _ = EnumerationCallback(u8);
}
