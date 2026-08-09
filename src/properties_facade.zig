const sdl = @import("sdl");

pub const Property = union(enum) {
    pointer: ?*anyopaque,
    string: ?[:0]const u8,
    number: i64,
    float: f32,
    boolean: bool,
};

pub const Group = struct {
    id: sdl.properties.Id,

    pub fn init() sdl.Error!Group {
        return .{ .id = try sdl.properties.create() };
    }
    pub fn fromSdl(id: sdl.properties.Id) Group {
        return .{ .id = id };
    }
    pub fn toSdl(self: Group) sdl.properties.Id {
        return self.id;
    }
    pub fn deinit(self: *@This()) void {
        sdl.properties.destroy(self.id);
        self.* = undefined;
    }
    pub fn lock(self: Group) sdl.Error!void {
        return sdl.properties.lock(self.id);
    }
    pub fn unlock(self: Group) void {
        sdl.properties.unlock(self.id);
    }
    pub fn copyTo(self: Group, destination: Group) sdl.Error!void {
        return sdl.properties.copy(self.id, destination.id);
    }

    pub fn get(self: Group, name: [:0]const u8) Property {
        return switch (sdl.properties.getPropertyType(self.id, name)) {
            .pointer => .{ .pointer = sdl.properties.getPointerProperty(self.id, name, null) },
            .string => .{ .string = sdl.properties.getStringProperty(self.id, name, null) },
            .number => .{ .number = sdl.properties.getNumberProperty(self.id, name, 0) },
            .float => .{ .float = sdl.properties.getFloatProperty(self.id, name, 0) },
            .boolean => .{ .boolean = sdl.properties.getBooleanProperty(self.id, name, false) },
            else => .{ .pointer = null },
        };
    }

    pub fn set(self: Group, name: [:0]const u8, property: Property) sdl.Error!void {
        return switch (property) {
            .pointer => |value| sdl.properties.setPointerProperty(self.id, name, value),
            .string => |value| sdl.properties.setStringProperty(self.id, name, value),
            .number => |value| sdl.properties.setNumberProperty(self.id, name, value),
            .float => |value| sdl.properties.setFloatProperty(self.id, name, value),
            .boolean => |value| sdl.properties.setBooleanProperty(self.id, name, value),
        };
    }

    pub fn setPointerWithCleanup(
        self: Group,
        name: [:0]const u8,
        value: ?*anyopaque,
        cleanup: sdl.properties.CleanupPropertyCallback,
        userdata: ?*anyopaque,
    ) sdl.Error!void {
        return sdl.properties.setPointerPropertyWithCleanup(self.id, name, value, cleanup, userdata);
    }
};

pub const raw = sdl.properties;
