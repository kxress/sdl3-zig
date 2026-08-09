const sdl = @import("sdl");

pub const BusType = sdl.hidApi.HidBusType;
pub const DeviceInfo = sdl.hidApi.HidDeviceInfo;

pub const Enumeration = struct {
    first: ?*DeviceInfo,

    pub fn init(vendor_id: u16, product_id: u16) Enumeration {
        return .{ .first = sdl.hidApi.hidEnumerate(vendor_id, product_id) };
    }

    pub fn deinit(self: *@This()) void {
        sdl.hidApi.hidFreeEnumeration(self.first);
        self.* = undefined;
    }
};

pub fn enumerate(vendor_id: u16, product_id: u16) Enumeration {
    return Enumeration.init(vendor_id, product_id);
}

pub const Device = struct {
    raw: sdl.hidApi.HidDevice,

    pub fn init(vendor_id: u16, product_id: u16, serial_number: ?*const anyopaque) sdl.Error!Device {
        return .{ .raw = try sdl.hidApi.hidOpen(vendor_id, product_id, @ptrCast(serial_number)) };
    }

    pub fn initPath(path: ?[:0]const u8) sdl.Error!Device {
        return .{ .raw = try sdl.hidApi.hidOpenPath(path) };
    }

    pub fn deinit(self: *@This()) sdl.Error!void {
        try self.raw.close();
        self.* = undefined;
    }
};

pub fn init() sdl.Error!c_int {
    return sdl.hidApi.hidInit();
}

pub fn deinit() sdl.Error!void {
    _ = try sdl.hidApi.hidExit();
}

pub const raw = sdl.hidApi;
