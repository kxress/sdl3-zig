const std = @import("std");

/// An allocator-owned slice returned by a facade operation.
pub fn OwnedSlice(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        items: []T,

        pub fn deinit(self: *@This()) void {
            self.allocator.free(self.items);
            self.* = undefined;
        }
    };
}

/// A borrowed slice marker with no deinit operation.
pub fn BorrowedSlice(comptime T: type) type {
    return struct { items: []const T };
}

/// An allocator-owned sentinel string returned by a facade operation.
pub const OwnedZString = struct {
    allocator: std.mem.Allocator,
    value: [:0]u8,

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.value);
        self.* = undefined;
    }
};

test "owned values expose explicit deinit" {
    var owned = OwnedSlice(u8){
        .allocator = std.testing.allocator,
        .items = try std.testing.allocator.alloc(u8, 1),
    };
    owned.items[0] = 1;
    owned.deinit();
}

test "borrowed and owned slices are distinct contracts" {
    const borrowed = BorrowedSlice(u8){ .items = "SDL" };
    try std.testing.expectEqual(@as(usize, 3), borrowed.items.len);
}
