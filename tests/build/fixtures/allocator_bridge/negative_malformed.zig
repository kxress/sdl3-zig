const sdl = @import("sdl");

test "printf rejects an unterminated conversion" {
    var output: [16]u8 = undefined;
    _ = sdl.stdinc.snprintf(&output, output.len, "%", .{});
}
