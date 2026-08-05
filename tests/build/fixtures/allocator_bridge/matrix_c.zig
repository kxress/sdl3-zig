// Compile-only target matrix surface. These declarations model the SDL allocator ABI without
// linking or translating an SDK-specific C header on targets unavailable to the host.
pub const SDL_malloc_func = *const fn (usize) callconv(.c) ?*anyopaque;
pub const SDL_calloc_func = *const fn (usize, usize) callconv(.c) ?*anyopaque;
pub const SDL_realloc_func = *const fn (?*anyopaque, usize) callconv(.c) ?*anyopaque;
pub const SDL_free_func = *const fn (?*anyopaque) callconv(.c) void;
pub fn SDL_malloc(_: usize) ?*anyopaque { return null; }
pub fn SDL_calloc(_: usize, _: usize) ?*anyopaque { return null; }
pub fn SDL_realloc(_: ?*anyopaque, _: usize) ?*anyopaque { return null; }
pub fn SDL_free(_: ?*anyopaque) void {}
pub fn SDL_aligned_alloc(_: usize, _: usize) ?*anyopaque { return null; }
pub fn SDL_aligned_free(_: ?*anyopaque) void {}
pub fn SDL_GetNumAllocations() c_int { return 0; }
pub fn SDL_SetMemoryFunctions(_: SDL_malloc_func, _: SDL_calloc_func, _: SDL_realloc_func, _: SDL_free_func) bool { return true; }
pub const SDL_LOG_CATEGORY_APPLICATION: c_int = 0;
pub const SDL_LOG_PRIORITY_WARN: c_int = 0;
pub const SDL_LOG_PRIORITY_INFO: c_int = 0;
// C variadic declaration used by the target-only format ABI compile probe.
pub extern fn SDL_snprintf(text: [*c]u8, maxlen: usize, fmt: [*c]const u8, ...) c_int;
pub const SDL_PRILLd = "%lld";
pub const SDL_PRILLu = "%llu";
pub const SDL_PRILLx = "%llx";
pub const SDL_PRILLX = "%llX";
pub const SDLK_UNKNOWN = 0;
