const sdl = @import("sdl");

test "scanf rejects a destination with the wrong C width" {
    var value: c_long = 0;
    _ = sdl.stdinc.sscanf("ignored", "%d", .{&value});
}
