const net = @import("net");
const sdl = @import("sdl");
const std = @import("std");

pub const AddressList = struct {
    allocator: std.mem.Allocator,
    addresses: []?*net.Address,

    pub fn init(allocator: std.mem.Allocator) sdl.Error!AddressList {
        const addresses = try net.getLocalAddresses(allocator);
        for (addresses) |address| _ = net.refAddress(address);
        return .{ .allocator = allocator, .addresses = addresses };
    }

    pub fn deinit(self: *@This()) void {
        for (self.addresses) |address| net.unrefAddress(address);
        self.allocator.free(self.addresses);
        self.* = undefined;
    }
};

pub const Pollable = union(enum) {
    stream: *anyopaque,
    datagram: *anyopaque,

    fn raw(self: Pollable) *anyopaque {
        return switch (self) {
            .stream => |value| value,
            .datagram => |value| value,
        };
    }
};

pub fn waitUntilInputAvailable(allocator: std.mem.Allocator, pollables: []const Pollable, timeout: Timeout) sdl.Error!usize {
    const raw_sockets = try allocator.alloc(?*anyopaque, pollables.len);
    defer allocator.free(raw_sockets);
    for (pollables, 0..) |pollable, index| raw_sockets[index] = pollable.raw();
    return @intCast(try net.waitUntilInputAvailable(raw_sockets.ptr, @intCast(raw_sockets.len), timeout.milliseconds));
}

/// Explicit SDL_net wait timeout.
pub const Timeout = struct {
    milliseconds: i32,

    pub const immediate = Timeout{ .milliseconds = 0 };
    pub const indefinite = Timeout{ .milliseconds = -1 };

    pub fn toSdl(self: Timeout) i32 {
        return self.milliseconds;
    }
};

pub const Status = struct {
    raw: net.Status,
    pub fn fromSdl(raw: net.Status) Status {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Status) net.Status {
        return self.raw;
    }
};

pub const Version = struct {
    value: u32,
    pub fn get() Version {
        return .{ .value = @intCast(net.versionDefault()) };
    }
    pub fn major(self: Version) u32 {
        return self.value / 1_000_000;
    }
    pub fn minor(self: Version) u32 {
        return (self.value / 1_000) % 1_000;
    }
    pub fn micro(self: Version) u32 {
        return self.value % 1_000;
    }
};

pub const raw = net;
