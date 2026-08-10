const sdl = @import("sdl");

/// Optional-safe scancode value with name lookup helpers.
pub const Scancode = struct {
    raw: sdl.scancode.Scancode,

    pub fn fromSdl(value: sdl.scancode.Scancode) ?Scancode {
        if (value == .scancode_unknown) return null;
        return .{ .raw = value };
    }

    pub fn toSdl(self: Scancode) sdl.scancode.Scancode {
        return self.raw;
    }

    pub fn name(self: Scancode) ?[:0]const u8 {
        return sdl.keyboard.getScancodeName(self.raw);
    }
};

pub const raw = sdl.scancode;

test "scancode values reject unknown and expose names" {
    try @import("std").testing.expect(Scancode.fromSdl(.scancode_unknown) == null);
    const key = Scancode.fromSdl(.scancode_a).?;
    try @import("std").testing.expectEqual(.scancode_a, key.toSdl());
}
