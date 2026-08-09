const sdl = @import("sdl");

pub const Renderer = struct {
    raw: sdl.render.Renderer,

    pub const Options = struct {
        window: ?sdl.video.Window = null,
        name: ?[:0]const u8 = null,
    };

    pub const Texture = struct {
        raw: *sdl.render.Texture,

        pub const Options = struct {
            format: sdl.pixels.PixelFormat,
            access: sdl.render.TextureAccess = .static,
            width: i32,
            height: i32,
        };

        pub fn deinit(self: *@This()) void {
            sdl.render.destroyTexture(self.raw);
            self.* = undefined;
        }
    };

    pub fn init(options: Options) sdl.Error!Renderer {
        const renderer = sdl.render.createRenderer(options.window, options.name) orelse return error.SdlFailure;
        return .{ .raw = renderer };
    }

    pub fn initWithWindow(window: sdl.video.Window, name: ?[:0]const u8) sdl.Error!Renderer {
        return init(.{ .window = window, .name = name });
    }

    pub fn initGpu(device: ?sdl.gpu.Device, window: ?sdl.video.Window) sdl.Error!Renderer {
        return .{ .raw = sdl.render.createGpuRenderer(device, window) orelse return error.SdlFailure };
    }

    pub fn initSoftwareRenderer(surface: *sdl.surface.Surface) sdl.Error!Renderer {
        return .{ .raw = sdl.render.createSoftwareRenderer(surface) orelse return error.SdlFailure };
    }

    pub fn createTexture(self: Renderer, options: Texture.Options) sdl.Error!Texture {
        return .{ .raw = try self.raw.createTexture(options.format, options.access, options.width, options.height) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.render;
