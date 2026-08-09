const sdl = @import("sdl");

pub const View = struct {
    raw: sdl.metal.View,

    pub fn init(window: sdl.video.Window) View {
        return .{ .raw = sdl.metal.createView(window) };
    }

    pub fn deinit(self: *@This()) void {
        sdl.metal.destroyView(self.raw);
        self.* = undefined;
    }

    pub fn getLayer(self: @This()) ?*anyopaque {
        return sdl.metal.getLayer(self.raw);
    }
};

pub const raw = sdl.metal;
