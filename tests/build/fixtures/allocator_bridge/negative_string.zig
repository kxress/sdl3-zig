const sdl = @import("sdl");

test "printf rejects a non-sentinel string" {
    var output: [16]u8 = undefined;
    const value = [_]u8{ 'o', 'k' };
    _ = sdl.stdinc.snprintf(&output, output.len, "%s", .{value[0..]});
}
