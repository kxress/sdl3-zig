const sdl = @import("sdl");

pub const Io = sdl.process.Io;
pub const PropertiesId = sdl.properties.Id;

pub const Process = struct {
    raw: sdl.process.Process,

    pub fn init(args: ?*const ?[*:0]const u8, pipe_stdio: bool) ?Process {
        return if (sdl.process.create(args, pipe_stdio)) |raw| .{ .raw = raw } else null;
    }

    pub fn initWithProperties(properties: PropertiesId) ?Process {
        return if (sdl.process.createWithProperties(properties)) |raw| .{ .raw = raw } else null;
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }

    pub fn getInput(self: @This()) sdl.Error!sdl.ioStream.IoStream {
        return self.raw.getInput();
    }

    pub fn getOutput(self: @This()) sdl.Error!sdl.ioStream.IoStream {
        return self.raw.getOutput();
    }

    pub fn kill(self: @This(), force: bool) sdl.Error!void {
        return self.raw.kill(force);
    }

    pub fn wait(self: @This(), block: bool) ?sdl.process.WaitResult {
        return self.raw.wait(block);
    }
};

/// Typed process creation properties, retaining explicit SDL IO modes.
pub const Properties = struct {
    args: []const [:0]const u8,
    working_directory: ?[:0]const u8 = null,
    stdin: sdl.process.Io = .null_,
    stdout: sdl.process.Io = .inherited,
    stderr: sdl.process.Io = .inherited,
    stderr_to_stdout: bool = false,
    background: bool = false,
    command_line: ?[:0]const u8 = null,
};

pub const raw = sdl.process;
