const sdl = @import("sdl");

pub const Id = struct {
    raw: sdl.keyboard.Id,
    pub fn fromSdl(raw: sdl.keyboard.Id) ?Id {
        if (raw == 0) return null;
        return .{ .raw = raw };
    }
    pub fn toSdl(self: Id) sdl.keyboard.Id {
        return self.raw;
    }
};

/// Typed text-input configuration values used at the facade boundary.
pub const TextInputProperties = struct {
    input_type: sdl.keyboard.TextInputType = .text,
    capitalization: sdl.keyboard.Capitalization = .none,
    multiline: bool = false,
    autocorrect: bool = true,

    pub fn toSdl(self: @This()) sdl.Error!sdl.properties.Id {
        const id = try sdl.properties.create();
        errdefer sdl.properties.destroy(id);
        try sdl.properties.setNumberProperty(id, sdl.keyboard.prop_text_input_type_number, @intFromEnum(self.input_type));
        try sdl.properties.setNumberProperty(id, sdl.keyboard.prop_text_input_capitalization_number, @intFromEnum(self.capitalization));
        try sdl.properties.setBooleanProperty(id, sdl.keyboard.prop_text_input_multiline_boolean, self.multiline);
        try sdl.properties.setBooleanProperty(id, sdl.keyboard.prop_text_input_autocorrect_boolean, self.autocorrect);
        return id;
    }
};

pub const raw = sdl.keyboard;
