const image = @import("image");
const mixer = @import("mixer");
const net = @import("net");
const sdl = @import("sdl");
const sdl3 = @import("sdl3");
const ttf = @import("ttf");

pub fn main() void {
    comptime {
        _ = image;
        _ = mixer;
        _ = net;
        _ = sdl;
        _ = sdl3.core;
        _ = ttf;
    }
}
