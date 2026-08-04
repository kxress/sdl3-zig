extern fn SDL_GetVersion() c_int;
extern fn IMG_Version() c_int;
extern fn TTF_Version() c_int;
extern fn MIX_Version() c_int;
extern fn NET_Version() c_int;

pub fn main() void {
    _ = SDL_GetVersion();
    _ = IMG_Version();
    _ = TTF_Version();
    _ = MIX_Version();
    _ = NET_Version();
}
