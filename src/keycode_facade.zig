const sdl = @import("sdl");

/// Keyboard key value with explicit unknown-value handling.
pub const Keycode = struct {
    raw: sdl.keycode.Keycode,

    pub fn fromSdl(raw: sdl.keycode.Keycode) ?Keycode {
        if (raw == 0) return null;
        return .{ .raw = raw };
    }

    pub fn toSdl(self: Keycode) sdl.keycode.Keycode {
        return self.raw;
    }

    pub fn isExtended(self: Keycode) bool {
        return self.raw & sdl.keycode.extended_mask != 0;
    }

    pub fn isScancode(self: Keycode) bool {
        return self.raw & sdl.keycode.scancode_mask == sdl.keycode.scancode_mask;
    }

    pub fn fromScancode(
        scancode: sdl.scancode.Scancode,
        modifiers: sdl.keycode.Keymod,
        key_event: bool,
    ) ?Keycode {
        return fromSdl(sdl.keyboard.getKeyFromScancode(scancode, modifiers, key_event));
    }
};

/// Named modifier predicates over SDL's packed keyboard modifier mask.
pub const KeyModifier = struct {
    raw: sdl.keycode.Keymod,

    pub fn fromSdl(raw: sdl.keycode.Keymod) KeyModifier {
        return .{ .raw = raw };
    }

    pub fn toSdl(self: KeyModifier) sdl.keycode.Keymod {
        return self.raw;
    }

    pub fn controlDown(self: KeyModifier) bool {
        return self.raw & sdl.keycode.kmod_ctrl != 0;
    }

    pub fn shiftDown(self: KeyModifier) bool {
        return self.raw & (sdl.keycode.kmod_lshift | sdl.keycode.kmod_rshift) != 0;
    }

    pub fn altDown(self: KeyModifier) bool {
        return self.raw & sdl.keycode.kmod_alt != 0;
    }

    pub fn guiDown(self: KeyModifier) bool {
        return self.raw & sdl.keycode.kmod_gui != 0;
    }
};

/// The complete generated keycode namespace remains available as `raw`.
pub const raw = sdl.keycode;

test "keycode values expose conversion and modifier predicates" {
    const key = Keycode.fromSdl(sdl.keycode.a).?;
    try @import("std").testing.expect(!key.isExtended());
    try @import("std").testing.expect(KeyModifier.fromSdl(sdl.keycode.kmod_ctrl).controlDown());
}
