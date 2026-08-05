const sdl = @import("sdl");

test "SDL_static_cast rejects an incompatible target" {
    _ = sdl.stdinc.staticCast(u8, @as(u16, 300));
}
