const image = @import("image");
const sdl = @import("sdl");

extern fn core_link_pattern() c_int;
extern fn image_link_pattern() c_int;

comptime {
    _ = image;
    _ = sdl;
}

pub fn main() void {
    if (core_link_pattern() != 0 or image_link_pattern() != 0) unreachable;
}
