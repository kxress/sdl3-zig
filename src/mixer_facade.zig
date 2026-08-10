const mixer = @import("mixer");
const sdl = @import("sdl");

pub const Duration = union(enum) {
    frames: i64,
    unknown,
    infinite,

    pub fn fromSdl(value: i64) Duration {
        if (value == mixer.duration_unknown) return .unknown;
        if (value == mixer.duration_infinite) return .infinite;
        return .{ .frames = value };
    }
};

pub const LoopCount = union(enum) {
    finite: i32,
    infinite,

    pub fn toSdl(self: LoopCount) i32 {
        return switch (self) {
            .finite => |value| value,
            .infinite => -1,
        };
    }
};

pub const PlayOptions = struct {
    loops: LoopCount = .{ .finite = 0 },
    loop_start_frame: i64 = 0,
    loop_start_millisecond: i64 = 0,
    fade_in_frames: i64 = 0,
    halt_when_exhausted: bool = true,
};

pub const Mixer = struct {
    raw: mixer.Mixer,

    pub fn init(spec: ?*const anyopaque) sdl.Error!Mixer {
        return .{ .raw = try mixer.createMixer(@ptrCast(spec)) };
    }

    pub fn initDevice(device: anytype, spec: ?*const anyopaque) sdl.Error!Mixer {
        return .{ .raw = try mixer.createMixerDevice(device, @ptrCast(spec)) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }

    pub fn createTrack(self: @This()) ?Track {
        return if (mixer.createTrack(self.raw)) |track| .{ .raw = track } else null;
    }

    pub fn createGroup(self: @This()) ?Group {
        return if (mixer.createGroup(self.raw)) |group| .{ .raw = group } else null;
    }
};

pub const Audio = struct {
    raw: mixer.Audio,

    pub fn init(mixer_instance: Mixer, path: ?[:0]const u8, predecode: bool) sdl.Error!Audio {
        return .{ .raw = try mixer.loadAudio(mixer_instance.raw, path, predecode) };
    }

    pub fn initIo(mixer_instance: Mixer, io: ?*anyopaque, predecode: bool, close_io: bool) sdl.Error!Audio {
        return .{ .raw = try mixer.loadAudioIo(mixer_instance.raw, @ptrCast(io), predecode, close_io) };
    }

    pub fn initNoCopy(mixer_instance: Mixer, data: []const u8, free_when_done: bool) sdl.Error!Audio {
        return .{ .raw = try mixer.loadAudioNoCopy(mixer_instance.raw, data, free_when_done) };
    }

    pub fn initRaw(mixer_instance: Mixer, data: []const u8, spec: ?*const anyopaque) sdl.Error!Audio {
        return .{ .raw = try mixer.loadRawAudio(mixer_instance.raw, data, @ptrCast(spec)) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const Group = struct {
    raw: mixer.Group,
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const Track = struct {
    raw: mixer.Track,
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = mixer;
