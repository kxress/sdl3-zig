const fixture = @import("fixture");

fn linkPattern() callconv(.c) c_int {
    return 0;
}

comptime {
    @export(&linkPattern, .{ .name = fixture.symbol });
}
