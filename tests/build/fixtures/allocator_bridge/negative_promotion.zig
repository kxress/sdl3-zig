const sdl = @import("sdl");

test "printf rejects a non-default-promoted integer" {
    var output: [16]u8 = undefined;
    _ = sdl.stdinc.snprintf(&output, output.len, "%d", .{@as(i64, 1)});
}
