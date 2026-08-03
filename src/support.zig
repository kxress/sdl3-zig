const std = @import("std");

/// Copies a sentinel-terminated string into a caller-owned allocation.
pub fn copyOwnedZString(
    allocator: std.mem.Allocator,
    source: [*:0]const u8,
) error{OutOfMemory}![:0]u8 {
    const span = std.mem.span(source);
    const copy = allocator.allocSentinel(u8, span.len, 0) catch return error.OutOfMemory;
    @memcpy(copy, span);
    return copy;
}

/// Frees every string in an owned string slice and then the slice itself.
pub fn deinitOwnedStrings(allocator: std.mem.Allocator, items: [][:0]u8) void {
    for (items) |item| allocator.free(item);
    allocator.free(items);
}
