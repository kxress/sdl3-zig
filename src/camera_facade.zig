const std = @import("std");
const sdl = @import("sdl");

pub const Specification = struct {
    format: sdl.pixels.PixelFormat,
    colorspace: sdl.pixels.Colorspace,
    width: i32,
    height: i32,
    framerate_numerator: i32,
    framerate_denominator: i32,

    pub fn fromSdl(value: sdl.camera.Spec) Specification {
        return .{ .format = value.format, .colorspace = value.colorspace, .width = value.width, .height = value.height, .framerate_numerator = value.framerate_numerator, .framerate_denominator = value.framerate_denominator };
    }

    pub fn toSdl(self: Specification) sdl.camera.Spec {
        return .{ .format = self.format, .colorspace = self.colorspace, .width = self.width, .height = self.height, .framerate_numerator = self.framerate_numerator, .framerate_denominator = self.framerate_denominator };
    }
};

pub const Camera = struct {
    raw: sdl.camera.Camera,
    pub fn init(id: sdl.camera.Id, spec: ?Specification) sdl.Error!Camera {
        return .{ .raw = try sdl.camera.open(id, if (spec) |value| &value.toSdl() else null) };
    }
    pub fn deinit(self: *@This()) void {
        self.raw.close();
        self.* = undefined;
    }
};

pub fn getCameras(allocator: std.mem.Allocator) sdl.Error![]sdl.camera.Id {
    return sdl.camera.getCameras(allocator);
}

pub const CameraList = struct {
    allocator: std.mem.Allocator,
    ids: []sdl.camera.Id,

    pub fn init(allocator: std.mem.Allocator) sdl.Error!CameraList {
        return .{ .allocator = allocator, .ids = try getCameras(allocator) };
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.ids);
        self.* = undefined;
    }
};
pub const raw = sdl.camera;
