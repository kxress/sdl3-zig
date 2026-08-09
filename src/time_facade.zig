const sdl = @import("sdl");

/// Round-trippable wrapper for a generated time enum.
pub fn EnumValue(comptime Enum: type) type {
    return struct {
        raw: Enum,

        pub fn fromSdl(raw: Enum) @This() {
            return .{ .raw = raw };
        }
        pub fn toSdl(self: @This()) Enum {
            return self.raw;
        }
    };
}

pub const DateFormat = EnumValue(sdl.time.DateFormat);
pub const Format = EnumValue(sdl.time.Format);

pub const Month = enum(u8) {
    january = 1,
    february,
    march,
    april,
    may,
    june,
    july,
    august,
    september,
    october,
    november,
    december,
};

/// Calendar time value with explicit SDL conversion.
pub const DateTime = struct {
    raw: sdl.time.Date,

    pub fn fromSdl(raw: sdl.time.Date) DateTime {
        return .{ .raw = raw };
    }

    pub fn toSdl(self: DateTime) sdl.time.Date {
        return self.raw;
    }

    pub fn toTime(self: DateTime) sdl.Error!Time {
        const result = try sdl.time.dateToTime(&self.raw);
        return .{ .ticks = result.ticks };
    }
};

/// SDL nanosecond time value with conversion helpers.
pub const Time = struct {
    ticks: sdl.time.Time,

    pub fn fromSdl(ticks: sdl.time.Time) Time {
        return .{ .ticks = ticks };
    }

    pub fn toSdl(self: Time) sdl.time.Time {
        return self.ticks;
    }

    pub fn fromWindows(low: u32, high: u32) Time {
        return .{ .ticks = sdl.time.fromWindows(low, high) };
    }

    pub fn toWindows(self: Time) sdl.time.ToWindowsResult {
        return sdl.time.toWindows(self.ticks);
    }

    pub fn toDateTime(self: Time, local_time: bool) sdl.Error!DateTime {
        const result = try sdl.time.toDate(self.ticks, local_time);
        return .{ .raw = result.dt };
    }

    pub fn getCurrent() sdl.Error!Time {
        const result = try sdl.time.getCurrent();
        return .{ .ticks = result.ticks };
    }
};

pub const raw = sdl.time;

test "time values expose conversion methods" {
    comptime {
        _ = DateTime.fromSdl;
        _ = DateTime.toSdl;
        _ = Time.fromWindows;
        _ = Time.toWindows;
        _ = Time.getCurrent;
    }
}
