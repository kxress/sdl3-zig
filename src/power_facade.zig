const sdl = @import("sdl");

/// Optional-safe power state value.
pub const State = struct {
    raw: sdl.power.State,

    pub fn fromSdl(value: sdl.power.State) ?State {
        return switch (value) {
            .error_, .unknown => null,
            else => .{ .raw = value },
        };
    }

    pub fn toSdl(self: State) sdl.power.State {
        return self.raw;
    }
};

pub const raw = sdl.power;

test "power state conversion treats unknown states as absent" {
    try @import("std").testing.expect(State.fromSdl(.unknown) == null);
    try @import("std").testing.expect(State.fromSdl(.charging) != null);
}
