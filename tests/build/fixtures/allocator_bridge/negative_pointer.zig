const sdl = @import("sdl");

test "printf rejects a non-pointer for percent p" {
    var output: [16]u8 = undefined;
    _ = sdl.stdinc.snprintf(&output, output.len, "%p", .{@as(usize, 1)});
}
