const sdl = @import("sdl");

pub fn Callback(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, ?*Entry) void,
        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }
        pub const Handler = *const fn (*UserData, ?*Entry) void;
        pub fn cCallback(_: *@This()) sdl.tray.Callback {
            return invoke;
        }
        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }
        fn invoke(userdata: ?*anyopaque, entry: ?*Entry) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            self.handler(self.userdata, entry);
        }
    };
}

pub const EntryFlags = sdl.tray.EntryFlags;
pub const Entry = sdl.tray.Entry;
pub const Menu = sdl.tray.Menu;

pub const Tray = struct {
    raw: sdl.tray.Tray,

    pub fn init(icon: ?*sdl.surface.Surface, tooltip: ?[:0]const u8) ?Tray {
        return if (sdl.tray.create(icon, tooltip)) |tray| .{ .raw = tray } else null;
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }

    pub fn createMenu(self: @This()) ?*Menu {
        return self.raw.createMenu();
    }

    pub fn getMenu(self: @This()) ?*Menu {
        return self.raw.getMenu();
    }

    pub fn setIcon(self: @This(), icon: ?*sdl.surface.Surface) void {
        self.raw.setIcon(icon);
    }

    pub fn setTooltip(self: @This(), tooltip: ?[:0]const u8) void {
        self.raw.setTooltip(tooltip);
    }
};

pub fn createMenu(tray: Tray) ?*Menu {
    return sdl.tray.createMenu(tray.raw);
}

pub fn createSubmenu(entry: ?*Entry) ?*Menu {
    return sdl.tray.createSubmenu(entry);
}

pub fn insertEntryAt(menu: ?*Menu, position: i32, label: ?[:0]const u8, flags: EntryFlags) ?*Entry {
    return sdl.tray.insertEntryAt(menu, position, label, flags);
}

pub fn removeEntry(entry: ?*Entry) void {
    sdl.tray.removeEntry(entry);
}

pub fn setEntryCallback(entry: ?*Entry, callback: Callback, userdata: ?*anyopaque) void {
    sdl.tray.setEntryCallback(entry, callback, userdata);
}

pub const raw = sdl.tray;
comptime {
    _ = Callback(u8);
}
