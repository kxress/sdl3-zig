const sdl = @import("sdl");

pub const IoMode = enum { read, write, read_write };
fn modeString(mode: IoMode) [:0]const u8 {
    return switch (mode) {
        .read => "rb",
        .write => "wb",
        .read_write => "w+b",
    };
}

pub const File = struct {
    raw: sdl.asyncIo.AsyncIo,
    pub fn init(path: [:0]const u8, mode: IoMode) sdl.Error!File {
        return .{ .raw = try sdl.asyncIo.asyncIoFromFile(path, modeString(mode)) };
    }
    pub fn getSize(self: File) sdl.Error!i64 {
        return self.raw.getSize();
    }
};

pub const Queue = struct {
    raw: sdl.asyncIo.Queue,
    pub fn init() sdl.Error!Queue {
        return .{ .raw = sdl.asyncIo.createQueue() orelse return error.SdlFailure };
    }
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
    pub fn closeFile(self: Queue, file: *File, flush: bool, userdata: ?*anyopaque) sdl.Error!void {
        try file.raw.close(flush, self.raw, userdata);
    }
    pub fn loadFile(self: Queue, path: [:0]const u8, userdata: ?*anyopaque) sdl.Error!void {
        return sdl.asyncIo.loadFileAsync(path, self.raw, userdata);
    }
};

pub const raw = sdl.asyncIo;
