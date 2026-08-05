const sdl = @import("sdl");

test "printf rejects the wrong signed length" {
    var output: [16]u8 = undefined;
    _ = sdl.stdinc.snprintf(&output, output.len, "%lld", .{@as(c_long, 1)});
}
