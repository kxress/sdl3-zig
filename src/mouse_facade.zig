const sdl = @import("sdl");

pub const Id = struct {
    raw: sdl.mouse.Id,
    pub fn fromSdl(raw: sdl.mouse.Id) ?Id {
        if (raw == 0) return null;
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Id) sdl.mouse.Id {
        return self.raw;
    }
};

pub const ButtonFlags = struct {
    raw: sdl.mouse.ButtonFlags,
    pub fn fromSdl(raw: sdl.mouse.ButtonFlags) ButtonFlags {
        return .{ .raw = raw };
    }
    pub fn toSdl(self: ButtonFlags) sdl.mouse.ButtonFlags {
        return self.raw;
    }
    pub fn contains(self: ButtonFlags, flag: sdl.mouse.ButtonFlags) bool {
        return self.raw & flag != 0;
    }
    pub fn with(self: ButtonFlags, flag: sdl.mouse.ButtonFlags) ButtonFlags {
        return .{ .raw = self.raw | flag };
    }
};

pub const SystemCursor = sdl.mouse.SystemCursor;
pub const CursorFrameInfo = sdl.mouse.CursorFrameInfo;

pub const State = struct {
    buttons: ButtonFlags,
    x: f32,
    y: f32,
};

pub fn getGlobalState() State {
    const result = sdl.mouse.getGlobalState();
    return .{ .buttons = ButtonFlags.fromSdl(result.value), .x = result.x, .y = result.y };
}

pub fn getRelativeState() State {
    const result = sdl.mouse.getRelativeState();
    return .{ .buttons = ButtonFlags.fromSdl(result.value), .x = result.x, .y = result.y };
}

pub const Cursor = struct {
    raw: sdl.mouse.Cursor,

    pub fn init(data: ?*const u8, mask: ?*const u8, width: i32, height: i32, hot_x: i32, hot_y: i32) sdl.Error!Cursor {
        return .{ .raw = try sdl.mouse.createCursor(data, mask, width, height, hot_x, hot_y) };
    }

    pub fn initAnimated(frames: []CursorFrameInfo, hot_x: i32, hot_y: i32) sdl.Error!Cursor {
        return .{ .raw = try sdl.mouse.createAnimatedCursor(frames, hot_x, hot_y) };
    }

    pub fn initColor(surface: ?*sdl.surface.Surface, hot_x: i32, hot_y: i32) sdl.Error!Cursor {
        return .{ .raw = try sdl.mouse.createColorCursor(surface, hot_x, hot_y) };
    }

    pub fn initSystem(cursor: SystemCursor) sdl.Error!Cursor {
        return .{ .raw = try sdl.mouse.createSystemCursor(cursor) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.mouse;
