const sdl = @import("sdl");

comptime {
    if (!@hasDecl(sdl, "InitFlags")) @compileError("SDL public binding is unavailable");
    if (!@hasDecl(sdl, "system")) @compileError("SDL system namespace is unavailable");
}
