const sdl = @import("sdl");

test "malformed C scansets fail with an actionable diagnostic" {
    var destination: [8]u8 = undefined;
    _ = sdl.stdinc.sscanf("abc", "%[]", .{destination[0..].ptr});
}
