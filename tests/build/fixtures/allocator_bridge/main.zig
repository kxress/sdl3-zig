const std = @import("std");
const sdl = @import("sdl");
const sdl_test = @import("sdl_test");

const TrackingAllocator = struct {
    fail_next: bool = false,
    fail_at: ?usize = null,
    failed: bool = false,
    attempts: usize = 0,
    resize_success: bool = false,
    allocations: usize = 0,
    deallocations: usize = 0,

    fn allocator(self: *@This()) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .remap = std.mem.Allocator.noRemap,
                .free = free,
            },
        };
    }

    fn alloc(
        context: *anyopaque,
        length: usize,
        alignment: std.mem.Alignment,
        return_address: usize,
    ) ?[*]u8 {
        const self: *@This() = @ptrCast(@alignCast(context));
        const attempt = self.attempts;
        self.attempts += 1;
        if (self.fail_next or self.fail_at == attempt) {
            self.failed = true;
            self.fail_next = false;
            return null;
        }
        const result = std.heap.page_allocator.rawAlloc(length, alignment, return_address) orelse
            return null;
        self.allocations += 1;
        return result;
    }

    fn free(
        context: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        return_address: usize,
    ) void {
        const self: *@This() = @ptrCast(@alignCast(context));
        std.heap.page_allocator.rawFree(memory, alignment, return_address);
        self.deallocations += 1;
    }

    fn resize(
        context: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        new_length: usize,
        return_address: usize,
    ) bool {
        const self: *@This() = @ptrCast(@alignCast(context));
        return self.resize_success and std.heap.page_allocator.rawResize(
            memory,
            alignment,
            new_length,
            return_address,
        );
    }
};

var backing: TrackingAllocator = .{};

comptime {
    _ = sdl.stdinc.asprintf;
    _ = sdl.log.messageFmt;
    _ = sdl.log.message;
    _ = sdl.error_.set;
    _ = sdl.ioStream.iOprintf;
    _ = sdl.render.debugTextFormat;
    _ = sdl_test.log;
    _ = sdl.audio.convertSamples;
    _ = sdl.audio.loadWav;
    _ = sdl.filesystem.getPrefPath;
}

test "ported SDL macro helpers instantiate as Zig APIs" {
    try std.testing.expectEqual(@as(i64, std.math.minInt(i64)), sdl.stdinc.sint64c(
        std.math.minInt(i64),
    ));
    try std.testing.expectEqual(@as(i64, std.math.maxInt(i64)), sdl.stdinc.sint64c(
        std.math.maxInt(i64),
    ));
    try std.testing.expectEqual(@as(u64, std.math.maxInt(u64)), sdl.stdinc.uint64c(
        std.math.maxInt(u64),
    ));
    try std.testing.expect(@TypeOf(sdl.stdinc.sint64c(0)) == i64);
    try std.testing.expect(@TypeOf(sdl.stdinc.uint64c(0)) == u64);
    try std.testing.expectEqual(@as(u32, 7), sdl.stdinc.staticCast(u32, @as(u8, 7)));

    var value: u32 = 11;
    const mutable: *u32 = sdl.stdinc.constCast(*u32, @as(*const u32, &value));
    const reinterpreted: *u32 = sdl.stdinc.reinterpretCast(*u32, mutable);
    reinterpreted.* = 13;
    try std.testing.expectEqual(@as(u32, 13), value);

    sdl.atomic.compilerBarrier();
    sdl.stdinc.compileTimeAssert("ported SDL macro helpers", true);
    try std.testing.expectEqual(sdl.c.SDL_PRILLd, sdl.stdinc.prilLd());
    try std.testing.expectEqual(sdl.c.SDL_PRILLu, sdl.stdinc.prilLu());
    try std.testing.expectEqual(sdl.c.SDL_PRILLx, sdl.stdinc.prilLx());
    try std.testing.expectEqual(sdl.c.SDL_PRILLX, sdl.stdinc.prillx());
    comptime {
        _ = sdl.assert.breakpoint;
        _ = sdl.assert.triggerBreakpoint;
    }
}

test "Zig log formatting forwards literal percent signs" {
    sdl.log.messageFmt(7, .info, "loaded {d}%", .{3});
    try std.testing.expectEqualStrings("loaded 3%", std.mem.span(sdl.c.SDL_test_last_log()));
}

test "std.log adapter maps levels and prefixes named scopes" {
    comptime {
        _ = @as(@TypeOf(std.options.logFn), sdl.stdLogFn);
    }
    sdl.stdLogFn(.warn, .default, "warning {d}", .{3});
    try std.testing.expectEqualStrings("warning 3", std.mem.span(sdl.c.SDL_test_last_log()));
    try std.testing.expectEqual(@as(c_int, sdl.c.SDL_LOG_CATEGORY_APPLICATION), sdl.c.SDL_test_last_log_category());
    try std.testing.expectEqual(@as(c_int, sdl.c.SDL_LOG_PRIORITY_WARN), sdl.c.SDL_test_last_log_priority());

    sdl.stdLogFn(.info, .worker, "loaded {d}%", .{3});
    try std.testing.expectEqualStrings("[worker] loaded 3%", std.mem.span(sdl.c.SDL_test_last_log()));
    try std.testing.expectEqual(@as(c_int, sdl.c.SDL_LOG_PRIORITY_INFO), sdl.c.SDL_test_last_log_priority());
}

test "explicit SDL logging preserves every category and priority" {
    const categories = [_]sdl.log.Category{
        .application,
        .error_,
        .assert,
        .system,
        .audio,
        .video,
        .render,
        .input,
        .test_,
        .gpu,
        .reserved2,
        .reserved3,
        .reserved4,
        .reserved5,
        .reserved6,
        .reserved7,
        .reserved8,
        .reserved9,
        .reserved10,
        .custom,
    };
    const priorities = [_]sdl.log.Priority{
        .trace,
        .verbose,
        .debug,
        .info,
        .warn,
        .error_,
        .critical,
    };
    for (categories) |category| {
        for (priorities) |priority| {
            sdl.log.messageFmt(@intCast(@intFromEnum(category)), priority, "matrix", .{});
            try std.testing.expectEqual(
                @as(c_int, @intCast(@intFromEnum(category))),
                sdl.c.SDL_test_last_log_category(),
            );
            try std.testing.expectEqual(
                @as(c_int, @intCast(@intFromEnum(priority))),
                sdl.c.SDL_test_last_log_priority(),
            );
        }
    }
}

fn concurrentLogWorker(index: usize) void {
    const priorities = [_]sdl.log.Priority{
        .trace,
        .verbose,
        .debug,
        .info,
        .warn,
        .error_,
        .critical,
    };
    sdl.log.messageFmt(@intCast(1000 + index), priorities[index % priorities.len], "thread {d}", .{index});
}

test "SDL logging remains callable from concurrent threads" {
    sdl.c.SDL_test_reset_log_count();
    var threads: [8]std.Thread = undefined;
    for (&threads, 0..) |*thread, index| {
        thread.* = try std.Thread.spawn(.{}, concurrentLogWorker, .{index});
    }
    for (threads) |thread| thread.join();
    try std.testing.expectEqual(@as(c_int, threads.len), sdl.c.SDL_test_log_count());
}

var recursive_log_callback_calls: usize = 0;

fn recursiveLogOutput(
    userdata: ?*anyopaque,
    category: c_int,
    priority: sdl.log.Priority,
    message: ?[*:0]const u8,
) callconv(.c) void {
    _ = userdata;
    _ = category;
    _ = priority;
    _ = message;
    recursive_log_callback_calls += 1;
    if (recursive_log_callback_calls == 1) {
        sdl.log.messageFmt(7, .error_, "callback recursion {s}", .{"must stop"});
    }
}

test "log adapter guards reentrant custom output callbacks" {
    recursive_log_callback_calls = 0;
    sdl.log.setOutputFunction(recursiveLogOutput, null);
    defer sdl.log.setOutputFunction(null, null);

    sdl.log.messageFmt(7, .info, "literal 100% exact", .{});
    try std.testing.expectEqual(@as(usize, 1), recursive_log_callback_calls);
    try std.testing.expectEqualStrings("literal 100% exact", std.mem.span(sdl.c.SDL_test_last_log()));
}

test "log adapter emits one fixed diagnostic on format overflow" {
    const long_message = [_]u8{'x'} ** 2048;
    recursive_log_callback_calls = 0;
    sdl.log.setOutputFunction(recursiveLogOutput, null);
    defer sdl.log.setOutputFunction(null, null);

    sdl.log.messageFmt(7, .info, "{s}", .{long_message[0..]});
    try std.testing.expectEqual(@as(usize, 1), recursive_log_callback_calls);
    try std.testing.expectEqualStrings("SDL log formatting failed", std.mem.span(sdl.c.SDL_test_last_log()));
}

test "typed scanf wrappers preserve mutable destination types" {
    var value: c_int = 0;
    try std.testing.expectEqual(@as(c_int, 1), sdl.stdinc.sscanf("ignored", "%d", .{&value}));
    try std.testing.expectEqual(@as(c_int, 42), value);
}

test "C format grammar preserves width precision order and exact scanf destinations" {
    var formatted: [32]u8 = undefined;
    const formatted_length = sdl.stdinc.snprintf(
        &formatted,
        formatted.len,
        "[%*.*lld]",
        .{ 8, 3, @as(c_longlong, -12) },
    );
    try std.testing.expectEqual(@as(c_int, 10), formatted_length);
    try std.testing.expectEqualStrings("[    -012]", formatted[0..@intCast(formatted_length)]);

    var signed_byte: i8 = 0;
    var unsigned_byte: u8 = 0;
    var signed_short: c_short = 0;
    var unsigned_short: c_ushort = 0;
    var maximum: std.c.intmax_t = 0;
    var size: usize = 0;
    var set: [8]u8 = undefined;
    const conversions = sdl.stdinc.sscanf(
        "-5 250 -123 65000 1234567890123 7 abc!",
        "%hhd %hhu %hd %hu %jd %zu %[a-z]",
        .{ &signed_byte, &unsigned_byte, &signed_short, &unsigned_short, &maximum, &size, set[0..].ptr },
    );
    try std.testing.expectEqual(@as(c_int, 7), conversions);
    try std.testing.expectEqual(@as(i8, -5), signed_byte);
    try std.testing.expectEqual(@as(u8, 250), unsigned_byte);
    try std.testing.expectEqual(@as(c_short, -123), signed_short);
    try std.testing.expectEqual(@as(c_ushort, 65000), unsigned_short);
    try std.testing.expectEqual(@as(std.c.intmax_t, 1234567890123), maximum);
    try std.testing.expectEqual(@as(usize, 7), size);
    try std.testing.expectEqualStrings("abc", std.mem.span(@as([*:0]u8, @ptrCast(&set))));

    var suppressed_set: [8]u8 = undefined;
    try std.testing.expectEqual(
        @as(c_int, 1),
        sdl.stdinc.sscanf("skip 12 345!", "skip %*d %3[0-9]", .{suppressed_set[0..].ptr}),
    );
    try std.testing.expectEqualStrings("345", std.mem.span(@as([*:0]u8, @ptrCast(&suppressed_set))));

    var negated_set: [8]u8 = undefined;
    try std.testing.expectEqual(
        @as(c_int, 1),
        sdl.stdinc.sscanf("abc!", "%[^]]", .{negated_set[0..].ptr}),
    );
    try std.testing.expectEqualStrings("abc!", std.mem.span(@as([*:0]u8, @ptrCast(&negated_set))));

    var leading_set: [8]u8 = undefined;
    try std.testing.expectEqual(
        @as(c_int, 1),
        sdl.stdinc.sscanf("]a!", "%[]a]", .{leading_set[0..].ptr}),
    );
    try std.testing.expectEqualStrings("]a", std.mem.span(@as([*:0]u8, @ptrCast(&leading_set))));

    var basic: [32]u8 = undefined;
    var written: c_int = -1;
    const basic_length = sdl.stdinc.snprintf(
        &basic,
        basic.len,
        "%% %c %s%n",
        .{ @as(c_int, 'X'), @as([:0]const u8, "ok"), &written },
    );
    try std.testing.expectEqual(@as(c_int, 6), basic_length);
    try std.testing.expectEqual(@as(c_int, 6), written);
    try std.testing.expectEqualStrings("% X ok", basic[0..@intCast(written)]);

    var pointer_text: [64]u8 = undefined;
    const pointer_length = sdl.stdinc.snprintf(
        &pointer_text,
        pointer_text.len,
        "%p",
        .{@as(*anyopaque, @ptrCast(&basic))},
    );
    try std.testing.expect(pointer_length > 0);

    var floating: [32]u8 = undefined;
    const floating_length = sdl.stdinc.snprintf(
        &floating,
        floating.len,
        "%.2f",
        .{@as(f64, 1.25)},
    );
    try std.testing.expectEqual(@as(c_int, 4), floating_length);
    try std.testing.expectEqualStrings("1.25", floating[0..@intCast(floating_length)]);

    var long_floating: [32]u8 = undefined;
    const long_floating_length = sdl.stdinc.snprintf(
        &long_floating,
        long_floating.len,
        "%.2lf",
        .{@as(f64, 1.25)},
    );
    try std.testing.expectEqual(@as(c_int, 4), long_floating_length);
    try std.testing.expectEqualStrings("1.25", long_floating[0..@intCast(long_floating_length)]);

    var long_double_text: [32]u8 = undefined;
    const long_double_length = sdl.stdinc.snprintf(
        &long_double_text,
        long_double_text.len,
        "%Lf",
        .{@as(c_longdouble, 1.25)},
    );
    try std.testing.expect(long_double_length > 0);
}

test "every representative SDL format declaration forwards typed varargs" {
    sdl.log.message(7, .info, "log %d %s", .{ @as(c_int, 42), @as([:0]const u8, "ok") });
    try std.testing.expectEqualStrings("log 42 ok", std.mem.span(sdl.c.SDL_test_last_log()));

    try std.testing.expect(!sdl.error_.set("error %u", .{@as(c_uint, 17)}));
    try std.testing.expectEqualStrings("error 17", sdl.error_.get().?);

    var io_memory: [64]u8 = undefined;
    const stream = try sdl.ioStream.ioFromMem(&io_memory);
    const io_written = sdl.ioStream.iOprintf(stream, "io %lld", .{@as(c_longlong, 11)});
    try std.testing.expectEqual(@as(usize, 5), io_written);
    try std.testing.expectEqualStrings("io 11", std.mem.span(sdl.c.SDL_test_last_io()));

    try std.testing.expect(sdl.render.debugTextFormat(null, 1, 2, "render %.1f", .{@as(f64, 1.5)}));
    try std.testing.expectEqualStrings("render 1.5", std.mem.span(sdl.c.SDL_test_last_log()));

    sdl_test.log("test %lld", .{@as(c_longlong, 23)});
    try std.testing.expectEqualStrings("test 23", std.mem.span(sdl.c.SDL_test_last_log()));
    sdl_test.logError("test-error %u", .{@as(c_uint, 29)});
    try std.testing.expectEqualStrings("test-error 29", std.mem.span(sdl.c.SDL_test_last_log()));
}

test "allocator bridge preserves alignment, pairing, failure cleanup, and lifetime rules" {
    try sdl.AllocatorBridge.install(backing.allocator());
    try std.testing.expect(sdl.AllocatorBridge.isInstalled());

    const pointer = sdl.stdinc.malloc(33) orelse return error.OutOfMemory;
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(pointer) % @alignOf(std.c.max_align_t));
    @memset(@as([*]u8, @ptrCast(pointer))[0..33], 0xa5);

    const replacement = sdl.stdinc.realloc(pointer, 97) orelse return error.OutOfMemory;
    for (@as([*]const u8, @ptrCast(replacement))[0..33]) |value| {
        try std.testing.expectEqual(@as(u8, 0xa5), value);
    }
    sdl.stdinc.free(replacement);

    backing.resize_success = true;
    const in_place = sdl.stdinc.malloc(48) orelse return error.OutOfMemory;
    @memset(@as([*]u8, @ptrCast(in_place))[0..48], 0x3c);
    const shrunk = sdl.stdinc.realloc(in_place, 16) orelse return error.OutOfMemory;
    try std.testing.expectEqual(@intFromPtr(in_place), @intFromPtr(shrunk));
    try std.testing.expectEqual(@as(u8, 0x3c), @as([*]const u8, @ptrCast(shrunk))[0]);
    sdl.stdinc.free(shrunk);
    backing.resize_success = false;

    const zeroed = sdl.stdinc.calloc(4, 8) orelse return error.OutOfMemory;
    const expected_zeroes = [_]u8{0} ** 32;
    try std.testing.expectEqualSlices(u8, &expected_zeroes, @as([*]const u8, @ptrCast(zeroed))[0..32]);
    sdl.stdinc.free(zeroed);

    const from_null = sdl.stdinc.realloc(null, 24) orelse return error.OutOfMemory;
    sdl.stdinc.free(from_null);

    const zero_length = sdl.stdinc.malloc(0) orelse return error.OutOfMemory;
    sdl.stdinc.free(zero_length);

    const over_aligned = sdl.allocator.rawAlloc(
        32,
        std.mem.Alignment.fromByteUnits(64),
        @returnAddress(),
    ) orelse return error.OutOfMemory;
    try std.testing.expectEqual(@as(usize, 0), @intFromPtr(over_aligned) % 64);
    sdl.allocator.rawFree(over_aligned[0..32], std.mem.Alignment.fromByteUnits(64), @returnAddress());

    const overflow = sdl.stdinc.calloc(std.math.maxInt(usize), 2);
    try std.testing.expect(overflow == null);

    try std.testing.expectEqual(backing.allocations, backing.deallocations);
    try std.testing.expectError(
        error.AlreadyInstalled,
        sdl.AllocatorBridge.install(backing.allocator()),
    );

    const failed_pointer = sdl.stdinc.malloc(41) orelse return error.OutOfMemory;
    @memset(@as([*]u8, @ptrCast(failed_pointer))[0..41], 0x5a);
    backing.fail_next = true;
    try std.testing.expect(sdl.stdinc.realloc(failed_pointer, 100) == null);
    try std.testing.expectEqual(backing.allocations - 1, backing.deallocations);
    sdl.stdinc.free(failed_pointer);
    try std.testing.expectEqual(backing.allocations, backing.deallocations);

    const owned_for_corruption = sdl.stdinc.malloc(16) orelse return error.OutOfMemory;
    const corrupt = @as(*anyopaque, @ptrFromInt(@intFromPtr(owned_for_corruption) + 16));
    sdl.stdinc.free(corrupt);
    sdl.stdinc.free(owned_for_corruption);
    try std.testing.expect(sdl.AllocatorBridge.hadSafetyFault());
}

test "ownership transformations retain arbitrary allocator ownership" {
    const allocator = backing.allocator();

    const pref_path = try sdl.filesystem.getPrefPath(allocator, "org", "app");
    defer allocator.free(pref_path);
    try std.testing.expectEqualStrings("/tmp/sdl-pref/", pref_path);

    var mime_types = try sdl.clipboard.getMimeTypes(allocator);
    defer mime_types.deinit();
    try std.testing.expectEqual(@as(usize, 2), mime_types.items.len);
    try std.testing.expectEqualStrings("text/plain", mime_types.items[0]);

    var locales = try sdl.locale.getPreferredLocales(allocator);
    defer locales.deinit();
    try std.testing.expectEqual(@as(usize, 2), locales.items.len);
    try std.testing.expectEqualStrings("en", locales.items[0].language.?);
    try std.testing.expectEqualStrings("US", locales.items[0].country.?);
    try std.testing.expectEqualStrings("pt", locales.items[1].language.?);
    try std.testing.expect(locales.items[1].country == null);

    const channels = try sdl.audio.getDeviceChannelMap(allocator, sdl.audio.deviceDefaultPlayback());
    defer allocator.free(channels);
    try std.testing.expectEqualSlices(c_int, &[_]c_int{ 0, 1 }, channels);

    const source = [_]u8{ 7, 8, 9, 10 };
    const converted = try sdl.audio.convertSamples(allocator, null, &source, null);
    defer allocator.free(converted);
    try std.testing.expectEqualSlices(u8, &source, converted);

    const wav = try sdl.audio.loadWav(allocator, "fixture.wav");
    defer allocator.free(wav.data);
    try std.testing.expectEqual(@as(usize, 4), wav.data.len);
    try std.testing.expectEqual(@as(c_int, 48000), wav.spec.freq);

    const formatted = try sdl.stdinc.asprintf(allocator, "value %d", .{7});
    defer allocator.free(formatted);
    try std.testing.expectEqualStrings("value 7", formatted);
}

fn exerciseOwnershipAllocator(allocator: std.mem.Allocator) !void {
    const pref_path = try sdl.filesystem.getPrefPath(allocator, "org", "app");
    defer allocator.free(pref_path);

    var mime_types = try sdl.clipboard.getMimeTypes(allocator);
    defer mime_types.deinit();

    var locales = try sdl.locale.getPreferredLocales(allocator);
    defer locales.deinit();

    const channels = try sdl.audio.getDeviceChannelMap(allocator, sdl.audio.deviceDefaultPlayback());
    defer allocator.free(channels);

    const source = [_]u8{ 7, 8, 9, 10 };
    const converted = try sdl.audio.convertSamples(allocator, null, &source, null);
    defer allocator.free(converted);

    const wav = try sdl.audio.loadWav(allocator, "fixture.wav");
    defer allocator.free(wav.data);

    const formatted = try sdl.stdinc.asprintf(allocator, "value %d", .{7});
    defer allocator.free(formatted);
}

fn resetOwnershipTracking(fail_at: ?usize) std.mem.Allocator {
    // The installed SDL bridge and the caller-owned copy use this same tracker. This makes each
    // injected failure cover both sides of the ownership transformation, including source cleanup.
    backing.fail_next = false;
    backing.fail_at = fail_at;
    backing.failed = false;
    backing.attempts = 0;
    backing.allocations = 0;
    backing.deallocations = 0;
    backing.resize_success = false;
    return backing.allocator();
}

fn runOwnershipCase(case_index: usize, allocator: std.mem.Allocator) !void {
    switch (case_index) {
        0 => {
            const result = sdl.filesystem.getPrefPath(allocator, "org", "app");
            if (result) |value| {
                allocator.free(value);
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        1 => {
            const result = sdl.clipboard.getMimeTypes(allocator);
            if (result) |*value| {
                var owned = value.*;
                owned.deinit();
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        2 => {
            const result = sdl.locale.getPreferredLocales(allocator);
            if (result) |*value| {
                var owned = value.*;
                owned.deinit();
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        3 => {
            const result = sdl.audio.getDeviceChannelMap(
                allocator,
                sdl.audio.deviceDefaultPlayback(),
            );
            if (result) |value| {
                allocator.free(value);
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        4 => {
            const source = [_]u8{ 7, 8, 9, 10 };
            const result = sdl.audio.convertSamples(allocator, null, &source, null);
            if (result) |value| {
                allocator.free(value);
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        5 => {
            const result = sdl.audio.loadWav(allocator, "fixture.wav");
            if (result) |value| {
                allocator.free(value.data);
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        6 => {
            const result = sdl.stdinc.asprintf(allocator, "value %d", .{7});
            if (result) |value| {
                allocator.free(value);
            } else |err| {
                try std.testing.expect(err == error.OutOfMemory or err == error.SdlFailure);
            }
        },
        else => unreachable,
    }
}

fn ownershipAllocationSteps(case_index: usize) !usize {
    const allocator = resetOwnershipTracking(null);
    try runOwnershipCase(case_index, allocator);
    try std.testing.expectEqual(backing.allocations, backing.deallocations);
    try std.testing.expect(backing.attempts > 0);
    return backing.attempts;
}

fn expectOwnershipOomCase(case_index: usize, fail_at: usize) !void {
    const allocator = resetOwnershipTracking(fail_at);
    try runOwnershipCase(case_index, allocator);
    try std.testing.expect(backing.failed);
    try std.testing.expectEqual(backing.allocations, backing.deallocations);
}

test "ownership transformations clean up at every allocator failure point" {
    inline for (0..7) |case_index| {
        const allocation_steps = try ownershipAllocationSteps(case_index);
        var fail_at: usize = 0;
        while (fail_at < allocation_steps) : (fail_at += 1) {
            try expectOwnershipOomCase(case_index, fail_at);
        }
    }
}

test "ownership transformations accept the documented allocator families" {
    try exerciseOwnershipAllocator(std.testing.allocator);

    var fixed_storage: [4096]u8 = undefined;
    var fixed = std.heap.FixedBufferAllocator.init(&fixed_storage);
    try exerciseOwnershipAllocator(fixed.allocator());

    var stack = std.heap.stackFallback(4096, sdl.allocator);
    try exerciseOwnershipAllocator(stack.get());

    try exerciseOwnershipAllocator(sdl.allocator);
}

fn expectOwnershipFailure(result: anytype) !void {
    if (result) |_| {
        return error.UnexpectedSuccess;
    } else |err| {
        // Every failure-only fake-ABI entry point returns SDL's documented failure path before it
        // can allocate.  The successful allocator transformations above cover the copy/deinit
        // path.
        try std.testing.expectEqual(error.SdlFailure, err);
    }
}

fn exerciseOwnershipFailureMatrix(allocator: std.mem.Allocator) !void {
    const zero_guid = std.mem.zeroes(sdl.guid.Guid);
    const empty_wide_storage = [_]std.c.wchar_t{0};
    const empty_wide: [*:0]const std.c.wchar_t = @ptrCast(&empty_wide_storage);
    try expectOwnershipFailure(sdl.stdinc.iconvUtf8Locale(allocator, "fixture"));
    try expectOwnershipFailure(sdl.stdinc.iconvUtf8Ucs2(allocator, "fixture"));
    try expectOwnershipFailure(sdl.stdinc.iconvUtf8Ucs4(allocator, "fixture"));
    try expectOwnershipFailure(sdl.stdinc.iconvWcharUtf8(allocator, empty_wide));
    try expectOwnershipFailure(sdl.audio.getPlaybackDevices(allocator));
    try expectOwnershipFailure(sdl.audio.getRecordingDevices(allocator));
    try expectOwnershipFailure(sdl.audio.getStreamInputChannelMap(allocator, null));
    try expectOwnershipFailure(sdl.audio.getStreamOutputChannelMap(allocator, null));
    try expectOwnershipFailure(sdl.camera.getCameras(allocator));
    try expectOwnershipFailure(sdl.camera.getSupportedFormats(allocator, 0));
    try expectOwnershipFailure(sdl.clipboard.getData(allocator, null));
    try expectOwnershipFailure(sdl.clipboard.getText(allocator));
    try expectOwnershipFailure(sdl.clipboard.getPrimarySelectionText(allocator));
    try expectOwnershipFailure(sdl.filesystem.getCurrentDirectory(allocator));
    try expectOwnershipFailure(sdl.video.getDisplays(allocator));
    try expectOwnershipFailure(sdl.stdinc.getEnvironmentVariables(allocator, null));
    try expectOwnershipFailure(sdl.video.getFullscreenDisplayModes(allocator, 0));
    try expectOwnershipFailure(sdl.gamepad.getBindings(allocator, null));
    try expectOwnershipFailure(sdl.gamepad.getMapping(allocator, null));
    try expectOwnershipFailure(sdl.gamepad.getMappingForGuid(allocator, zero_guid));
    try expectOwnershipFailure(sdl.gamepad.getMappingForId(allocator, 0));
    try expectOwnershipFailure(sdl.gamepad.getMappings(allocator));
    try expectOwnershipFailure(sdl.gamepad.getGamepads(allocator));
    try expectOwnershipFailure(sdl.haptic.getHaptics(allocator));
    try expectOwnershipFailure(sdl.joystick.getJoysticks(allocator));
    try expectOwnershipFailure(sdl.keyboard.getKeyboards(allocator));
    try expectOwnershipFailure(sdl.mouse.getMice(allocator));
    try expectOwnershipFailure(sdl.sensor.getSensors(allocator));
    try expectOwnershipFailure(sdl.surface.getImages(allocator, null));
    try expectOwnershipFailure(sdl.touch.getDevices(allocator));
    try expectOwnershipFailure(sdl.touch.getFingers(allocator, 0));
    try expectOwnershipFailure(sdl.video.getWindowIccProfile(allocator, null));
    try expectOwnershipFailure(sdl.video.getWindows(allocator));
    try expectOwnershipFailure(sdl.filesystem.globDirectory(allocator, null, null, 0));
    try expectOwnershipFailure(sdl.storage.globDirectory(allocator, null, null, null, 0));
    try expectOwnershipFailure(sdl.stdinc.iconvString(allocator, null, null, null, 0));
    try expectOwnershipFailure(sdl.ioStream.loadFile(allocator, null));
    try expectOwnershipFailure(sdl.ioStream.loadFileIo(allocator, null, false));
    try expectOwnershipFailure(sdl.audio.loadWavIo(allocator, null, false));
    try expectOwnershipFailure(sdl.process.read(allocator, null, null));
    try expectOwnershipFailure(sdl.stdinc.strdup(allocator, null));
    try expectOwnershipFailure(sdl.stdinc.strndup(allocator, "fixture"));
    try expectOwnershipFailure(sdl.stdinc.wcsdup(allocator, null));
}

test "all allocator wrappers execute their deterministic fake-ABI failure path" {
    // The C stubs for these platform-facing entry points return null/false on Linux.  Keeping
    // this matrix Linux-only avoids claiming that a cross target has a usable camera, display,
    // input, storage, or process subsystem while still executing every generated wrapper here.
    if (comptime @import("builtin").os.tag != .linux) return;

    try exerciseOwnershipFailureMatrix(std.testing.allocator);

    var fixed_storage: [4096]u8 = undefined;
    var fixed = std.heap.FixedBufferAllocator.init(&fixed_storage);
    try exerciseOwnershipFailureMatrix(fixed.allocator());

    var stack = std.heap.stackFallback(4096, sdl.allocator);
    try exerciseOwnershipFailureMatrix(stack.get());
    try exerciseOwnershipFailureMatrix(sdl.allocator);
}
