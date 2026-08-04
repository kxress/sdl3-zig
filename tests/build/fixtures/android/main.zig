const sdl = @import("sdl");

export fn SDL_main(argc: c_int, argv: ?*?[*:0]u8) callconv(.c) c_int {
    _ = argc;
    _ = argv;
    _ = sdl.system.getAndroidSdkVersion();
    return 0;
}
