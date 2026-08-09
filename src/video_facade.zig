const sdl = @import("sdl");

pub const VSync = union(enum) {
    disabled,
    adaptive,
    interval: i32,

    pub fn fromSdl(value: i32) VSync {
        if (value == sdl.render.renderer_vsync_disabled) return .disabled;
        if (value == sdl.render.renderer_vsync_adaptive) return .adaptive;
        return .{ .interval = value };
    }

    pub fn toSdl(self: VSync) i32 {
        return switch (self) {
            .disabled => sdl.render.renderer_vsync_disabled,
            .adaptive => sdl.render.renderer_vsync_adaptive,
            .interval => |value| value,
        };
    }
};

pub const Window = struct {
    raw: sdl.video.Window,

    pub const Options = struct {
        title: [:0]const u8,
        width: i32,
        height: i32,
        flags: sdl.video.WindowFlags = .{},
    };

    pub fn init(options: Options) sdl.Error!Window {
        return .{ .raw = try sdl.video.createWindow(options.title, options.width, options.height, options.flags) };
    }

    pub fn initWithProperties(properties: u32) sdl.Error!Window {
        return .{ .raw = try sdl.video.createWindowWithProperties(properties) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }

    pub fn close(self: *@This()) void {
        self.deinit();
    }
};

pub const raw = sdl.video;
