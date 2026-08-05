const std = @import("std");
const sdl = @import("sdl");

test "allocator bridge rejects the SDL-backed allocator" {
    try std.testing.expectError(
        error.InvalidBackingAllocator,
        sdl.AllocatorBridge.install(sdl.allocator),
    );
}
