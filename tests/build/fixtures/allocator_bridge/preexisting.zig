const std = @import("std");
const sdl = @import("sdl");

extern fn SDL_test_set_num_allocations(count: c_int) void;

test "allocator bridge rejects installation after an existing allocation" {
    SDL_test_set_num_allocations(1);
    try std.testing.expectError(
        error.AllocationsAlreadyMade,
        sdl.AllocatorBridge.install(std.heap.page_allocator),
    );
}
