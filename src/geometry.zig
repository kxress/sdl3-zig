const std = @import("std");

/// Numeric point value with receiver-oriented geometry helpers.
pub fn Point(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        pub fn asOther(self: @This(), comptime U: type) Point(U) {
            return .{ .x = @as(U, self.x), .y = @as(U, self.y) };
        }

        pub fn equal(self: @This(), other: @This()) bool {
            return self.x == other.x and self.y == other.y;
        }

        pub fn empty(self: @This()) bool {
            return self.x == 0 and self.y == 0;
        }
    };
}

/// Numeric rectangle value with safe value-level geometry operations.
pub fn Rect(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        w: T,
        h: T,

        pub fn asOther(self: @This(), comptime U: type) Rect(U) {
            return .{
                .x = @as(U, self.x),
                .y = @as(U, self.y),
                .w = @as(U, self.w),
                .h = @as(U, self.h),
            };
        }

        pub fn empty(self: @This()) bool {
            return self.w <= 0 or self.h <= 0;
        }

        pub fn equal(self: @This(), other: @This()) bool {
            return self.x == other.x and self.y == other.y and self.w == other.w and self.h == other.h;
        }

        pub fn pointIn(self: @This(), point: Point(T)) bool {
            return point.x >= self.x and point.y >= self.y and
                point.x < self.x + self.w and point.y < self.y + self.h;
        }

        pub fn intersection(self: @This(), other: @This()) ?@This() {
            const left = @max(self.x, other.x);
            const top = @max(self.y, other.y);
            const right = @min(self.x + self.w, other.x + other.w);
            const bottom = @min(self.y + self.h, other.y + other.h);
            if (right <= left or bottom <= top) return null;
            return .{ .x = left, .y = top, .w = right - left, .h = bottom - top };
        }
    };
}

pub const FPoint = Point(f32);
pub const IPoint = Point(i32);
pub const FRect = Rect(f32);
pub const IRect = Rect(i32);

test "generic points and rectangles provide value helpers" {
    const rect = IRect{ .x = 0, .y = 0, .w = 10, .h = 10 };
    try std.testing.expect(rect.pointIn(.{ .x = 3, .y = 4 }));
    try std.testing.expect(!rect.pointIn(.{ .x = 10, .y = 4 }));
    try std.testing.expectEqual(@as(?IRect, .{ .x = 5, .y = 5, .w = 5, .h = 5 }), rect.intersection(.{ .x = 5, .y = 5, .w = 5, .h = 5 }));
}
