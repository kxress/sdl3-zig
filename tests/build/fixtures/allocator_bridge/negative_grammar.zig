const std = @import("std");
const sdl = @import("sdl");

test "positional C formats fail with an actionable diagnostic" {
    _ = sdl.stdinc.asprintf(std.testing.allocator, "%2$d", .{@as(c_int, 1)});
}
