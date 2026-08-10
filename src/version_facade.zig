const sdl = @import("sdl");

/// Packed SDL version value with component access and comparisons.
pub const Version = struct {
    value: u32,

    pub fn make(major_value: u32, minor_value: u32, micro_value: u32) Version {
        return .{ .value = major_value * 1_000_000 + minor_value * 1_000 + micro_value };
    }

    pub fn get() Version {
        return .{ .value = @intCast(sdl.version.get()) };
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

    pub fn atLeast(self: Version, other: Version) bool {
        return self.value >= other.value;
    }
};

pub const raw = sdl.version;

test "version values expose packed components" {
    const version = Version.make(3, 4, 12);
    try @import("std").testing.expectEqual(@as(u32, 3), version.major());
    try @import("std").testing.expectEqual(@as(u32, 4), version.minor());
    try @import("std").testing.expectEqual(@as(u32, 12), version.micro());
    try @import("std").testing.expect(version.atLeast(Version.make(3, 4, 0)));
}
