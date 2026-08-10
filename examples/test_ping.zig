const std = @import("std");

/// Small lifecycle hook used by the Deno example smoke runner.
pub const TestPing = struct {
    io: std.Io,
    args: std.process.Args.Iterator,
    path: ?[]const u8,
    ready: bool = false,

    pub fn init(process_init: std.process.Init) !TestPing {
        var args = try std.process.Args.Iterator.initAllocator(
            process_init.minimal.args,
            std.heap.page_allocator,
        );
        errdefer args.deinit();
        _ = args.next();

        var path: ?[]const u8 = null;
        while (args.next()) |argument| {
            if (!std.mem.eql(u8, argument, "--test-ping")) continue;
            path = args.next() orelse return error.MissingTestPingPath;
            break;
        }

        return .{ .io = process_init.io, .args = args, .path = path };
    }

    pub fn deinit(self: *TestPing) void {
        if (self.ready) self.write("ok") catch |err| std.debug.panic(
            "unable to write test-ping result: {s}",
            .{@errorName(err)},
        );
        self.args.deinit();
    }

    pub fn shouldExit(self: *TestPing) bool {
        if (self.path == null) return false;
        self.ready = true;
        return true;
    }

    fn write(self: *TestPing, contents: []const u8) !void {
        const path = self.path orelse return;
        try std.Io.Dir.cwd().writeFile(self.io, .{ .sub_path = path, .data = contents });
    }
};
