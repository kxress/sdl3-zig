const std = @import("std");

/// Apply the facade convention for a value type that provides `fromSdl`.
pub fn fromSdl(comptime Value: type, raw: anytype) Value {
    return Value.fromSdl(raw);
}

/// Apply the facade convention for a value type that provides `toSdl`.
pub fn toSdl(value: anytype) @TypeOf(value.toSdl()) {
    return value.toSdl();
}

/// Convert an unknown integer enum value to an optional Zig enum.
pub fn enumFromSdl(comptime Enum: type, raw: anytype) ?Enum {
    return std.meta.intToEnum(Enum, raw) catch null;
}

/// Convert a Zig enum to its SDL integer representation.
pub fn enumToSdl(value: anytype) @TypeOf(@intFromEnum(value)) {
    return @intFromEnum(value);
}

test "value conversion conventions" {
    const Value = struct {
        value: u32,
        fn fromSdl(raw: u32) @This() {
            return .{ .value = raw };
        }
        fn toSdl(self: @This()) u32 {
            return self.value;
        }
    };
    const converted = fromSdl(Value, 7);
    try std.testing.expectEqual(@as(u32, 7), toSdl(converted));
}
