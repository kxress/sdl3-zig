const std = @import("std");
const sdl = @import("sdl");

/// Value-oriented GUID conversion with allocator-owned string output.
pub const Guid = struct {
    raw: sdl.guid.Guid,

    pub fn fromString(value: [:0]const u8) Guid {
        return .{ .raw = sdl.guid.stringTo(value) };
    }

    pub fn toString(self: Guid, allocator: std.mem.Allocator) ![:0]u8 {
        var buffer: [33]u8 = undefined;
        sdl.guid.toString(self.raw, &buffer, buffer.len);
        const result = try allocator.allocSentinel(u8, 32, 0);
        @memcpy(result, buffer[0..32]);
        return result;
    }
};

pub const raw = sdl.guid;

test "guid facade exposes value conversions" {
    comptime {
        _ = Guid.fromString;
        _ = Guid.toString;
    }
}
