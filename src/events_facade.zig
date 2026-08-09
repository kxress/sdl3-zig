const sdl = @import("sdl");
const std = @import("std");

pub fn Filter(comptime UserData: type) type {
    return struct {
        userdata: *UserData,
        handler: *const fn (*UserData, *sdl.events.Event) bool,

        pub fn init(userdata: *UserData, handler: @This().Handler) @This() {
            return .{ .userdata = userdata, .handler = handler };
        }

        pub const Handler = *const fn (*UserData, *sdl.events.Event) bool;

        pub fn cFilter(_: *@This()) sdl.events.EventFilter {
            return invoke;
        }

        pub fn cUserdata(self: *@This()) ?*anyopaque {
            return @ptrCast(self);
        }

        fn invoke(userdata: ?*anyopaque, event: ?*sdl.events.Event) callconv(.c) bool {
            const self: *@This() = @ptrCast(@alignCast(userdata.?));
            return self.handler(self.userdata, event.?);
        }
    };
}

pub const TaggedEvent = union(enum) {
    quit: sdl.events.QuitEvent,
    window: sdl.events.WindowEvent,
    keyboard: sdl.events.KeyboardEvent,
    mouse_motion: sdl.events.MouseMotionEvent,
    mouse_button: sdl.events.MouseButtonEvent,
    display: sdl.events.DisplayEvent,
    audio: sdl.events.AudioDeviceEvent,
    camera: sdl.events.CameraDeviceEvent,
    controller_axis: sdl.events.GamepadAxisEvent,
    controller_button: sdl.events.GamepadButtonEvent,
    touch: sdl.events.TouchFingerEvent,
    sensor: sdl.events.SensorEvent,
    pen: sdl.events.PenMotionEvent,
    drop: sdl.events.DropEvent,
    other: sdl.events.Event,

    pub fn fromRaw(event: sdl.events.Event) TaggedEvent {
        return switch (event.type_) {
            .quit => .{ .quit = @bitCast(event) },
            .window_shown, .window_hidden, .window_exposed, .window_moved, .window_resized, .window_pixel_size_changed, .window_metal_view_resized => .{ .window = @bitCast(event) },
            .key_down, .key_up, .text_editing, .text_input => .{ .keyboard = @bitCast(event) },
            .mouse_motion => .{ .mouse_motion = @bitCast(event) },
            .mouse_button_down, .mouse_button_up => .{ .mouse_button = @bitCast(event) },
            .display_orientation, .display_added, .display_removed, .display_moved, .display_desktop_mode_changed, .display_current_mode_changed, .display_content_scale_changed, .display_usable_bounds_changed => .{ .display = @bitCast(event) },
            .audio_device_added, .audio_device_removed, .audio_device_format_changed => .{ .audio = @bitCast(event) },
            .camera_device_added, .camera_device_removed, .camera_device_approved, .camera_device_denied => .{ .camera = @bitCast(event) },
            .gamepad_axis_motion => .{ .controller_axis = @bitCast(event) },
            .gamepad_button_down, .gamepad_button_up => .{ .controller_button = @bitCast(event) },
            .finger_down, .finger_up, .finger_motion, .finger_canceled => .{ .touch = @bitCast(event) },
            .sensor_update, .gamepad_sensor_update => .{ .sensor = @bitCast(event) },
            .pen_motion => .{ .pen = @bitCast(event) },
            .drop_file, .drop_text, .drop_begin, .drop_complete, .drop_position => .{ .drop = @bitCast(event) },
            else => .{ .other = event },
        };
    }
};

pub const Drop = struct {
    raw: sdl.events.DropEvent,

    pub fn sourceBorrowed(self: @This()) ?[:0]const u8 {
        return if (self.raw.source) |value| std.mem.span(@as([*:0]const u8, @ptrCast(value))) else null;
    }

    pub fn dataBorrowed(self: @This()) ?[:0]const u8 {
        return if (self.raw.data) |value| std.mem.span(@as([*:0]const u8, @ptrCast(value))) else null;
    }

    pub fn copyData(self: @This(), allocator: std.mem.Allocator) !?[:0]u8 {
        const data = self.dataBorrowed() orelse return null;
        return try allocator.dupeZ(u8, data);
    }
};

pub fn poll() ?TaggedEvent {
    const result = sdl.events.pollEvent() orelse return null;
    return TaggedEvent.fromRaw(result.event);
}

pub fn waitAndPop() sdl.Error!TaggedEvent {
    const result = try sdl.events.waitEvent();
    return TaggedEvent.fromRaw(result.event);
}

pub const raw = sdl.events;

comptime {
    _ = Filter(u8);
}

test "tagged event round trip preserves quit payload" {
    const raw_quit: sdl.events.QuitEvent = .{ .type_ = .quit, .reserved = 0, .timestamp = 42 };
    const tagged = TaggedEvent.fromRaw(@bitCast(raw_quit));
    switch (tagged) {
        .quit => |event| try std.testing.expectEqual(@as(u64, 42), event.timestamp),
        else => return error.WrongEventTag,
    }
}
