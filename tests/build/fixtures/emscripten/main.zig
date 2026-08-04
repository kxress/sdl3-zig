const std = @import("std");
const sdl = @import("sdl");

var preload_verified = false;

export fn SDL_AppInit(
    appstate: ?*?*anyopaque,
    argc: c_int,
    argv: ?*?[*]u8,
) callconv(.c) sdl.init.AppResult {
    _ = appstate;
    _ = argc;
    _ = argv;
    const data = sdl.ioStream.loadFile(std.heap.page_allocator, "assets/preloaded.txt") catch
        return .failure;
    defer std.heap.page_allocator.free(data);
    const bytes: []const u8 = data[0..data.len];
    preload_verified = std.mem.eql(u8, bytes, "SDL3 Emscripten preload\n");
    return if (preload_verified) .continue_ else .failure;
}

export fn SDL_AppIterate(appstate: ?*anyopaque) callconv(.c) sdl.init.AppResult {
    _ = appstate;
    return .success;
}

export fn SDL_AppEvent(appstate: ?*anyopaque, event: ?*sdl.events.Event) callconv(.c) sdl.init.AppResult {
    _ = appstate;
    _ = event;
    return .continue_;
}

export fn SDL_AppQuit(appstate: ?*anyopaque, result: sdl.init.AppResult) callconv(.c) void {
    _ = appstate;
    _ = result;
}

pub fn main() void {
    const result = sdl.enterAppMainCallbacks(
        0,
        null,
        &SDL_AppInit,
        &SDL_AppIterate,
        &SDL_AppEvent,
        &SDL_AppQuit,
    );
    if (result != 0) std.process.exit(1);
}
