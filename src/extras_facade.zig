const std = @import("std");

/// A simple frame limiter based on a monotonic clock.
pub const FramerateCapper = struct {
    interval_ns: u64,
    frame_start: ?u64 = null,

    pub fn init(frames_per_second: u32) !@This() {
        if (frames_per_second == 0) return error.InvalidFramerate;
        return .{ .interval_ns = std.time.ns_per_s / frames_per_second };
    }

    pub fn begin(self: *@This()) void {
        self.frame_start = std.time.nanoTimestamp();
    }

    pub fn end(self: *@This()) void {
        const started = self.frame_start orelse return;
        const elapsed: u64 = @intCast(@max(0, std.time.nanoTimestamp() - started));
        if (elapsed < self.interval_ns) std.Thread.sleep(self.interval_ns - elapsed);
        self.frame_start = null;
    }

    pub fn reset(self: *@This()) void {
        self.frame_start = null;
    }
};

pub fn ErrorHandler(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, anyerror, []const u8) void,

        pub fn init(userdata: *UserData, handler: *const fn (*UserData, anyerror, []const u8) void) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub fn report(self: @This(), err: anyerror, context: []const u8) void {
            self.handler(self.userdata, err, context);
        }
    };
}

pub const LogLevel = enum { debug, info, warning, error_ };

pub fn Logger(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, LogLevel, []const u8) void,

        pub fn init(userdata: *UserData, handler: *const fn (*UserData, LogLevel, []const u8) void) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub fn write(self: @This(), level: LogLevel, message: []const u8) void {
            self.handler(self.userdata, level, message);
        }
    };
}

test "framerate capper rejects an invalid rate" {
    try std.testing.expectError(error.InvalidFramerate, FramerateCapper.init(0));
}
