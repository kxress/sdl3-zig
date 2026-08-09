const sdl = @import("sdl");
const std = @import("std");

pub const FileMode = enum { read, write, read_write };

fn modeString(mode: FileMode) [:0]const u8 {
    return switch (mode) {
        .read => "rb",
        .write => "wb",
        .read_write => "w+b",
    };
}

pub const Stream = struct {
    raw: sdl.ioStream.IoStream,

    pub fn initFromFile(path: [:0]const u8, mode: FileMode) sdl.Error!Stream {
        return .{ .raw = try sdl.ioStream.ioFromFile(path, modeString(mode)) };
    }

    pub fn initFromConstMem(memory: []const u8) sdl.Error!Stream {
        return .{ .raw = try sdl.ioStream.ioFromConstMem(memory) };
    }

    pub fn initFromMem(memory: []u8) sdl.Error!Stream {
        return .{ .raw = try sdl.ioStream.ioFromMem(memory) };
    }

    pub fn initNoCopy(memory: []u8) sdl.Error!Stream {
        return initFromMem(memory);
    }

    pub fn initFromDynamicMem() sdl.Error!Stream {
        return .{ .raw = try sdl.ioStream.ioFromDynamicMem() };
    }

    pub fn initFromFsFile(path: [:0]const u8, mode: FileMode) sdl.Error!Stream {
        return initFromFile(path, mode);
    }

    pub fn deinit(self: *@This()) sdl.Error!void {
        try self.raw.close();
        self.* = undefined;
    }

    fn required(comptime T: type, value: ?T) sdl.Error!T {
        return value orelse error.SdlFailure;
    }

    pub fn readS16Be(self: @This()) sdl.Error!sdl.ioStream.ReadS16BeResult {
        return required(sdl.ioStream.ReadS16BeResult, self.raw.readS16Be());
    }
    pub fn readS16Le(self: @This()) sdl.Error!sdl.ioStream.ReadS16LeResult {
        return required(sdl.ioStream.ReadS16LeResult, self.raw.readS16Le());
    }
    pub fn readS32Be(self: @This()) sdl.Error!sdl.ioStream.ReadS32BeResult {
        return required(sdl.ioStream.ReadS32BeResult, self.raw.readS32Be());
    }
    pub fn readS32Le(self: @This()) sdl.Error!sdl.ioStream.ReadS32LeResult {
        return required(sdl.ioStream.ReadS32LeResult, self.raw.readS32Le());
    }
    pub fn readS64Be(self: @This()) sdl.Error!sdl.ioStream.ReadS64BeResult {
        return required(sdl.ioStream.ReadS64BeResult, self.raw.readS64Be());
    }
    pub fn readS64Le(self: @This()) sdl.Error!sdl.ioStream.ReadS64LeResult {
        return required(sdl.ioStream.ReadS64LeResult, self.raw.readS64Le());
    }
    pub fn readS8(self: @This()) sdl.Error!sdl.ioStream.ReadS8Result {
        return self.raw.readS8();
    }
    pub fn readU16Be(self: @This()) sdl.Error!sdl.ioStream.ReadU16BeResult {
        return required(sdl.ioStream.ReadU16BeResult, self.raw.readU16Be());
    }
    pub fn readU16Le(self: @This()) sdl.Error!sdl.ioStream.ReadU16LeResult {
        return required(sdl.ioStream.ReadU16LeResult, self.raw.readU16Le());
    }
    pub fn readU32Be(self: @This()) sdl.Error!sdl.ioStream.ReadU32BeResult {
        return required(sdl.ioStream.ReadU32BeResult, self.raw.readU32Be());
    }
    pub fn readU32Le(self: @This()) sdl.Error!sdl.ioStream.ReadU32LeResult {
        return required(sdl.ioStream.ReadU32LeResult, self.raw.readU32Le());
    }
    pub fn readU64Be(self: @This()) sdl.Error!sdl.ioStream.ReadU64BeResult {
        return required(sdl.ioStream.ReadU64BeResult, self.raw.readU64Be());
    }
    pub fn readU64Le(self: @This()) sdl.Error!sdl.ioStream.ReadU64LeResult {
        return required(sdl.ioStream.ReadU64LeResult, self.raw.readU64Le());
    }
    pub fn readU8(self: @This()) sdl.Error!sdl.ioStream.ReadU8Result {
        return self.raw.readU8();
    }

    pub fn writeS16Be(self: @This(), value: i16) sdl.Error!void {
        if (!self.raw.writeS16Be(value)) return error.SdlFailure;
    }
    pub fn writeS16Le(self: @This(), value: i16) sdl.Error!void {
        if (!self.raw.writeS16Le(value)) return error.SdlFailure;
    }
    pub fn writeS32Be(self: @This(), value: i32) sdl.Error!void {
        if (!self.raw.writeS32Be(value)) return error.SdlFailure;
    }
    pub fn writeS32Le(self: @This(), value: i32) sdl.Error!void {
        if (!self.raw.writeS32Le(value)) return error.SdlFailure;
    }
    pub fn writeS64Be(self: @This(), value: i64) sdl.Error!void {
        if (!self.raw.writeS64Be(value)) return error.SdlFailure;
    }
    pub fn writeS64Le(self: @This(), value: i64) sdl.Error!void {
        if (!self.raw.writeS64Le(value)) return error.SdlFailure;
    }
    pub fn writeS8(self: @This(), value: i8) sdl.Error!void {
        if (!self.raw.writeS8(value)) return error.SdlFailure;
    }
    pub fn writeU16Be(self: @This(), value: u16) sdl.Error!void {
        if (!self.raw.writeU16Be(value)) return error.SdlFailure;
    }
    pub fn writeU16Le(self: @This(), value: u16) sdl.Error!void {
        if (!self.raw.writeU16Le(value)) return error.SdlFailure;
    }
    pub fn writeU32Be(self: @This(), value: u32) sdl.Error!void {
        if (!self.raw.writeU32Be(value)) return error.SdlFailure;
    }
    pub fn writeU32Le(self: @This(), value: u32) sdl.Error!void {
        if (!self.raw.writeU32Le(value)) return error.SdlFailure;
    }
    pub fn writeU64Be(self: @This(), value: u64) sdl.Error!void {
        if (!self.raw.writeU64Be(value)) return error.SdlFailure;
    }
    pub fn writeU64Le(self: @This(), value: u64) sdl.Error!void {
        if (!self.raw.writeU64Le(value)) return error.SdlFailure;
    }
    pub fn writeU8(self: @This(), value: u8) sdl.Error!void {
        if (!self.raw.writeU8(value)) return error.SdlFailure;
    }
};

pub const Reader = struct {
    stream: Stream,
    buffer: []u8,
    start: usize = 0,
    end: usize = 0,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, stream: Stream, capacity: usize) !Reader {
        return .{
            .stream = stream,
            .buffer = try allocator.alloc(u8, capacity),
            .allocator = allocator,
        };
    }

    pub fn read(self: *@This(), output: []u8) usize {
        var written: usize = 0;
        while (written < output.len) {
            if (self.start == self.end) {
                self.start = 0;
                self.end = self.stream.raw.read(self.buffer);
                if (self.end == 0) break;
            }
            const count = @min(output.len - written, self.end - self.start);
            @memcpy(output[written .. written + count], self.buffer[self.start .. self.start + count]);
            self.start += count;
            written += count;
        }
        return written;
    }

    pub fn deinit(self: *@This()) void {
        self.allocator.free(self.buffer);
        self.stream.deinit() catch {};
        self.* = undefined;
    }
};

pub const Writer = struct {
    stream: Stream,
    buffer: []u8,
    length: usize = 0,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, stream: Stream, capacity: usize) !Writer {
        return .{ .stream = stream, .buffer = try allocator.alloc(u8, capacity), .allocator = allocator };
    }

    pub fn write(self: *@This(), input: []const u8) sdl.Error!usize {
        var consumed: usize = 0;
        while (consumed < input.len) {
            if (self.buffer.len == self.length) try self.flush();
            const count = @min(input.len - consumed, self.buffer.len - self.length);
            @memcpy(self.buffer[self.length .. self.length + count], input[consumed .. consumed + count]);
            self.length += count;
            consumed += count;
        }
        return consumed;
    }

    pub fn flush(self: *@This()) sdl.Error!void {
        var written: usize = 0;
        while (written < self.length) {
            const count = self.stream.raw.write(self.buffer[written..self.length]);
            if (count == 0) return error.SdlFailure;
            written += count;
        }
        self.length = 0;
        try self.stream.raw.flush();
    }

    pub fn deinit(self: *@This()) void {
        self.flush() catch {};
        self.allocator.free(self.buffer);
        self.stream.deinit() catch {};
        self.* = undefined;
    }
};

pub fn loadFile(allocator: std.mem.Allocator, path: ?[:0]const u8) sdl.Error![:0]u8 {
    return sdl.ioStream.loadFile(allocator, path);
}

pub fn loadFileIo(allocator: std.mem.Allocator, stream: ?*sdl.ioStream.IoStream, close_stream: bool) sdl.Error![:0]u8 {
    return sdl.ioStream.loadFileIo(allocator, stream, close_stream);
}

pub fn saveFile(path: ?[:0]const u8, data: []const u8) sdl.Error!void {
    return sdl.ioStream.saveFile(path, data);
}

pub fn saveFileIo(stream: ?*sdl.ioStream.IoStream, data: []const u8, close_stream: bool) sdl.Error!void {
    return sdl.ioStream.saveFileIo(stream, data, close_stream);
}

pub fn Interface(comptime UserData: type) type {
    return struct {
        const Self = @This();
        pub const Callbacks = struct {
            seek: *const fn (*UserData, i64, sdl.ioStream.IoWhence) i64,
            read: *const fn (*UserData, []u8, *sdl.ioStream.IoStatus) usize,
            write: *const fn (*UserData, []const u8, *sdl.ioStream.IoStatus) usize,
            flush: *const fn (*UserData, *sdl.ioStream.IoStatus) bool,
            close: *const fn (*UserData) bool,
        };

        const Context = struct { callbacks: Callbacks, userdata: *UserData };
        context: Context,
        raw: sdl.ioStream.Interface,

        pub fn init(userdata: *UserData, callbacks: Callbacks) Self {
            var result: Self = undefined;
            result.context = .{ .callbacks = callbacks, .userdata = userdata };
            result.raw = .{
                .version = @sizeOf(sdl.ioStream.Interface),
                .size = null,
                .seek = seek,
                .read = read,
                .write = write,
                .flush = flush,
                .close = close,
            };
            return result;
        }

        pub fn open(self: *Self) sdl.Error!Stream {
            return .{ .raw = try sdl.ioStream.openIo(&self.raw, @ptrCast(&self.context)) };
        }

        fn seek(context: ?*anyopaque, offset: i64, whence: sdl.ioStream.IoWhence) callconv(.c) i64 {
            const state: *Context = @ptrCast(@alignCast(context.?));
            return state.callbacks.seek(state.userdata, offset, whence);
        }
        fn read(context: ?*anyopaque, ptr: ?*anyopaque, size: usize, status: ?*sdl.ioStream.IoStatus) callconv(.c) usize {
            const state: *Context = @ptrCast(@alignCast(context.?));
            return state.callbacks.read(state.userdata, @as([*]u8, @ptrCast(ptr.?))[0..size], &status.?.*);
        }
        fn write(context: ?*anyopaque, ptr: ?*const anyopaque, size: usize, status: ?*sdl.ioStream.IoStatus) callconv(.c) usize {
            const state: *Context = @ptrCast(@alignCast(context.?));
            return state.callbacks.write(state.userdata, @as([*]const u8, @ptrCast(ptr.?))[0..size], &status.?.*);
        }
        fn flush(context: ?*anyopaque, status: ?*sdl.ioStream.IoStatus) callconv(.c) bool {
            const state: *Context = @ptrCast(@alignCast(context.?));
            return state.callbacks.flush(state.userdata, &status.?.*);
        }
        fn close(context: ?*anyopaque) callconv(.c) bool {
            const state: *Context = @ptrCast(@alignCast(context.?));
            return state.callbacks.close(state.userdata);
        }
    };
}

pub const raw = sdl.ioStream;

test "typed interface instantiates" {
    _ = Interface(struct {});
}
