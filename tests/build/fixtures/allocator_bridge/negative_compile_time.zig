const sdl = @import("sdl");

test "SDL_COMPILE_TIME_ASSERT reports its supplied diagnostic name" {
    sdl.stdinc.compileTimeAssert("SDL_COMPILE_TIME_ASSERT failure", false);
}
