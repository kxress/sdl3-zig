const sdl = @import("sdl");

comptime {
    _ = sdl.allocator;
    _ = sdl.AllocatorBridge;
}

test "C format wrappers compile with target-native long double ABI" {
    _ = sdl.allocator;
    var output: [32]u8 = undefined;
    _ = sdl.stdinc.snprintf(&output, output.len, "%f", .{@as(f64, 1.25)});
    _ = sdl.stdinc.snprintf(&output, output.len, "%lf", .{@as(f64, 1.25)});
    // The wrapper's c_longdouble type follows each target's C ABI. Runtime
    // formatting remains host-SDK gated; this matrix proves the call surface
    // instantiates without forcing one target's long-double representation.
    _ = sdl.stdinc.snprintf(&output, output.len, "%Lf", .{@as(c_longdouble, 1.25)});
}
