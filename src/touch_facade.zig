const sdl = @import("sdl");
const std = @import("std");

pub const Id = struct {
    raw: sdl.touch.Id,
    pub fn fromSdl(value: sdl.touch.Id) ?Id {
        if (value == 0) return null;
        return .{ .raw = value };
    }
    pub fn toSdl(self: Id) sdl.touch.Id {
        return self.raw;
    }
};

pub const FingerId = struct {
    raw: sdl.touch.FingerId,
    pub fn fromSdl(value: sdl.touch.FingerId) ?FingerId {
        if (value == 0) return null;
        return .{ .raw = value };
    }
    pub fn toSdl(self: FingerId) sdl.touch.FingerId {
        return self.raw;
    }
};

pub const Finger = struct {
    id: FingerId,
    x: f32,
    y: f32,
    pressure: f32,

    pub fn fromSdl(value: sdl.touch.Finger) ?Finger {
        return .{ .id = FingerId.fromSdl(value.id) orelse return null, .x = value.x, .y = value.y, .pressure = value.pressure };
    }
};

pub const DeviceList = struct {
    allocator: std.mem.Allocator,
    ids: []sdl.touch.Id,
    pub fn init(allocator: std.mem.Allocator) sdl.Error!DeviceList {
        return .{ .allocator = allocator, .ids = try sdl.touch.getDevices(allocator) };
    }
    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.ids);
        self.* = undefined;
    }
};

pub const raw = sdl.touch;
