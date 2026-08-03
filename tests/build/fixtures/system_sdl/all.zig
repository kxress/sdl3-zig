const image = @import("image");
const ttf = @import("ttf");
const mixer = @import("mixer");
const net = @import("net");
const sdl = @import("sdl");

extern fn core_link_pattern() c_int;
extern fn image_link_pattern() c_int;
extern fn ttf_link_pattern() c_int;
extern fn mixer_link_pattern() c_int;
extern fn net_link_pattern() c_int;

comptime {
    _ = image;
    _ = ttf;
    _ = mixer;
    _ = net;
    _ = sdl;
}

pub fn main() void {
    if (core_link_pattern() != 0) unreachable;
    if (image_link_pattern() != 0) unreachable;
    if (ttf_link_pattern() != 0) unreachable;
    if (mixer_link_pattern() != 0) unreachable;
    if (net_link_pattern() != 0) unreachable;
}
