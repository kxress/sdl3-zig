const sdl = @import("sdl");
const std = @import("std");

pub const Id = struct {
    raw: sdl.sensor.Id,
    pub fn fromSdl(value: sdl.sensor.Id) ?Id {
        if (value == 0) return null;
        return .{ .raw = value };
    }
    pub fn toSdl(self: Id) sdl.sensor.Id {
        return self.raw;
    }
};

pub const Type = struct {
    raw: sdl.sensor.Type,
    pub fn fromSdl(value: sdl.sensor.Type) ?Type {
        return switch (value) {
            .unknown, .invalid => null,
            else => .{ .raw = value },
        };
    }
    pub fn toSdl(self: Type) sdl.sensor.Type {
        return self.raw;
    }
};

pub const Sensor = struct {
    raw: sdl.sensor.Sensor,

    pub fn init(id: Id) sdl.Error!Sensor {
        return .{ .raw = try sdl.sensor.open(id.raw) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.close();
        self.* = undefined;
    }

    pub fn getData(self: @This(), data: []f32) sdl.Error!void {
        return self.raw.getData(data);
    }
};

pub const SensorList = struct {
    allocator: std.mem.Allocator,
    ids: []sdl.sensor.Id,
    pub fn init(allocator: std.mem.Allocator) sdl.Error!SensorList {
        return .{ .allocator = allocator, .ids = try sdl.sensor.getSensors(allocator) };
    }
    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.ids);
        self.* = undefined;
    }
};

pub const raw = sdl.sensor;
