const sdl = @import("sdl");

/// Typed blend-factor value with explicit SDL conversion.
pub const Factor = struct {
    raw: sdl.blendmode.BlendFactor,

    pub fn fromSdl(raw: sdl.blendmode.BlendFactor) Factor {
        return .{ .raw = raw };
    }

    pub fn toSdl(self: Factor) sdl.blendmode.BlendFactor {
        return self.raw;
    }
};

/// Typed blend-operation value with explicit SDL conversion.
pub const Operation = struct {
    raw: sdl.blendmode.BlendOperation,

    pub fn fromSdl(raw: sdl.blendmode.BlendOperation) Operation {
        return .{ .raw = raw };
    }

    pub fn toSdl(self: Operation) sdl.blendmode.BlendOperation {
        return self.raw;
    }
};

/// Composed blend mode value with validity and conversion helpers.
pub const Mode = struct {
    raw: sdl.blendmode.BlendMode,

    pub fn fromSdl(raw: sdl.blendmode.BlendMode) Mode {
        return .{ .raw = raw };
    }

    pub fn toSdl(self: Mode) sdl.blendmode.BlendMode {
        return self.raw;
    }

    pub fn isValid(self: Mode) bool {
        return self.raw != sdl.blendmode.blend_mode_invalid;
    }

    pub fn compose(
        src_color: Factor,
        dst_color: Factor,
        color_operation: Operation,
        src_alpha: Factor,
        dst_alpha: Factor,
        alpha_operation: Operation,
    ) Mode {
        return .{ .raw = sdl.blendmode.composeCustomBlendMode(
            src_color.toSdl(),
            dst_color.toSdl(),
            color_operation.toSdl(),
            src_alpha.toSdl(),
            dst_alpha.toSdl(),
            alpha_operation.toSdl(),
        ) };
    }
};

/// The generated blend namespace remains available for ABI-oriented callers.
pub const raw = sdl.blendmode;

test "blend values round-trip" {
    const factor = Factor.fromSdl(.one);
    const operation = Operation.fromSdl(.add);
    try @import("std").testing.expectEqual(.one, factor.toSdl());
    try @import("std").testing.expectEqual(.add, operation.toSdl());
    try @import("std").testing.expect(Mode.fromSdl(sdl.blendmode.blend_mode_blend).isValid());
}
