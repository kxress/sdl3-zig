const image = @import("image");
const sdl = @import("sdl");
const sdl3 = @import("sdl3");

pub fn main() void {
    comptime {
        _ = image;
        _ = sdl;
        _ = sdl3.core;
    }
}
