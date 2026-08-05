const sdl = @import("sdl");

test "printf rejects an unsupported conversion" {
    var output: [16]u8 = undefined;
    _ = sdl.stdinc.snprintf(&output, output.len, "%q", .{@as(c_int, 1)});
}
