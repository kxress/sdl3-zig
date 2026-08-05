const sdl = @import("sdl");

test "scanf rejects immutable string output" {
    const output: [8]u8 = undefined;
    const destination = output;
    _ = sdl.stdinc.sscanf("ok", "%s", .{destination[0..].ptr});
}
