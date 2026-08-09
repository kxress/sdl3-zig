const sdl = @import("sdl");

pub fn App(comptime UserData: type) type {
    return struct {
        var active: ?*@This() = null;

        userdata: *UserData,
        init_handler: *const fn (*UserData, c_int, ?*?[*]u8) sdl.init.AppResult,
        iterate_handler: *const fn (*UserData) sdl.init.AppResult,
        event_handler: *const fn (*UserData, ?*sdl.events.Event) sdl.init.AppResult,
        quit_handler: *const fn (*UserData, sdl.init.AppResult) void,

        pub fn init(userdata: *UserData, callbacks: Callbacks) @This() {
            return .{ .userdata = userdata, .init_handler = callbacks.init, .iterate_handler = callbacks.iterate, .event_handler = callbacks.event, .quit_handler = callbacks.quit };
        }

        pub const Callbacks = struct {
            init: *const fn (*UserData, c_int, ?*?[*]u8) sdl.init.AppResult,
            iterate: *const fn (*UserData) sdl.init.AppResult,
            event: *const fn (*UserData, ?*sdl.events.Event) sdl.init.AppResult,
            quit: *const fn (*UserData, sdl.init.AppResult) void,
        };

        pub fn run(self: *@This(), argc: c_int, argv: ?*?[*]u8) c_int {
            active = self;
            defer active = null;
            return sdl.init.enterAppMainCallbacks(argc, argv, initCallback, iterateCallback, eventCallback, quitCallback);
        }

        pub const enterAppMainCallbacks = run;

        fn initCallback(state: ?*?*anyopaque, argc: c_int, argv: ?*?[*]u8) callconv(.c) sdl.init.AppResult {
            const self = active orelse return .failure;
            state.?.* = @ptrCast(self);
            return self.init_handler(self.userdata, argc, argv);
        }
        fn iterateCallback(state: ?*anyopaque) callconv(.c) sdl.init.AppResult {
            const self: *@This() = @ptrCast(@alignCast(state.?));
            return self.iterate_handler(self.userdata);
        }
        fn eventCallback(state: ?*anyopaque, event: ?*sdl.events.Event) callconv(.c) sdl.init.AppResult {
            const self: *@This() = @ptrCast(@alignCast(state.?));
            return self.event_handler(self.userdata, event);
        }
        fn quitCallback(state: ?*anyopaque, result: sdl.init.AppResult) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(state.?));
            self.quit_handler(self.userdata, result);
        }
    };
}

/// A typed wrapper for SDL's platform-aware `runApp` entry point.
pub fn Main(comptime UserData: type) type {
    return struct {
        var active: ?*@This() = null;
        userdata: *UserData,
        handler: *const fn (*UserData, c_int, ?*?[*]u8) c_int,

        pub fn init(userdata: *UserData, handler: *const fn (*UserData, c_int, ?*?[*]u8) c_int) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub fn run(self: *@This(), argc: c_int, argv: ?*?[*]u8) c_int {
            active = self;
            defer active = null;
            return sdl.runApp(argc, argv, mainCallback, null);
        }

        pub const runApp = run;

        fn mainCallback(argc: c_int, argv: ?*?[*]u8) callconv(.c) c_int {
            const self = active orelse return -1;
            return self.handler(self.userdata, argc, argv);
        }
    };
}

comptime {
    _ = App(u8);
    _ = Main(u8);
}
