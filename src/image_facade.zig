const image = @import("image");
const sdl = @import("sdl");

pub const Animation = struct {
    raw: *image.Animation,

    pub fn init(raw: *image.Animation) Animation {
        return .{ .raw = raw };
    }

    pub fn deinit(self: *@This()) void {
        image.freeAnimation(self.raw);
        self.* = undefined;
    }

    pub fn initIo(stream: ?*sdl.ioStream.IoStream, close_stream: bool) ?Animation {
        return if (image.loadAnimationIo(stream, close_stream)) |raw| .{ .raw = raw } else null;
    }

    pub fn initTypedIo(stream: ?*sdl.ioStream.IoStream, close_stream: bool, type_name: ?[:0]const u8) ?Animation {
        return if (image.loadAnimationTypedIo(stream, close_stream, type_name)) |raw| .{ .raw = raw } else null;
    }

    pub fn initGifIo(stream: ?*sdl.ioStream.IoStream) ?Animation {
        return if (image.loadGifAnimationIo(stream)) |raw| .{ .raw = raw } else null;
    }

    pub fn initWebpIo(stream: ?*sdl.ioStream.IoStream) ?Animation {
        return if (image.loadWebpAnimationIo(stream)) |raw| .{ .raw = raw } else null;
    }
};

pub fn loadIo(stream: ?*sdl.ioStream.IoStream, close_stream: bool) ?*sdl.surface.Surface {
    return image.loadIo(stream, close_stream);
}

pub fn loadTypedIo(stream: ?*sdl.ioStream.IoStream, close_stream: bool, type_name: ?[:0]const u8) ?*sdl.surface.Surface {
    return image.loadTypedIo(stream, close_stream, type_name);
}

pub fn loadGifIo(stream: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    return image.loadGifIo(stream);
}

pub fn loadWebpIo(stream: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    return image.loadWebpIo(stream);
}

/// Explicit format entry points remain discoverable together under one namespace.
pub const formats = struct {
    pub const loadBmpIo = image.loadBmpIo;
    pub const loadCurIo = image.loadCurIo;
    pub const loadGifIo = image.loadGifIo;
    pub const loadIcoIo = image.loadIcoIo;
    pub const loadJpgIo = image.loadJpgIo;
    pub const loadJxlIo = image.loadJxlIo;
    pub const loadLbmIo = image.loadLbmIo;
    pub const loadPcxIo = image.loadPcxIo;
    pub const loadPngIo = image.loadPngIo;
    pub const loadPnmIo = image.loadPnmIo;
    pub const loadQoiIo = image.loadQoiIo;
    pub const loadSvgIo = image.loadSvgIo;
    pub const loadTgaIo = image.loadTgaIo;
    pub const loadTifIo = image.loadTifIo;
    pub const loadWebpIo = image.loadWebpIo;
    pub const loadXcfIo = image.loadXcfIo;
    pub const loadXpmIo = image.loadXpmIo;
    pub const loadXvIo = image.loadXvIo;
    pub const saveBmpIo = image.saveBmpIo;
    pub const saveCurIo = image.saveCurIo;
    pub const saveGifIo = image.saveGifIo;
    pub const saveIcoIo = image.saveIcoIo;
    pub const saveJpgIo = image.saveJpgIo;
    pub const savePngIo = image.savePngIo;
    pub const saveTgaIo = image.saveTgaIo;
    pub const saveWebpIo = image.saveWebpIo;
};

pub const raw = image;
