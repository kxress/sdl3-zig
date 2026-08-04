const std = @import("std");
const sdl = @import("sdl");

const TrackingAllocator = struct {
    fail_next: bool = false,
    allocations: usize = 0,
    deallocations: usize = 0,

    fn allocator(self: *@This()) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = std.mem.Allocator.noResize,
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
        if (self.fail_next) {
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
};

var backing: TrackingAllocator = .{};

test "ported SDL macro helpers instantiate as Zig APIs" {
    try std.testing.expectEqual(@as(i64, 0x7fff), sdl.stdinc.sint64c(0x7fff));
    try std.testing.expectEqual(@as(u64, 0xffff), sdl.stdinc.uint64c(0xffff));
    try std.testing.expectEqual(@as(u32, 7), sdl.stdinc.staticCast(u32, @as(u8, 7)));

    var value: u32 = 11;
    const mutable: *u32 = sdl.stdinc.constCast(*u32, @as(*const u32, &value));
    const reinterpreted: *u32 = sdl.stdinc.reinterpretCast(*u32, mutable);
    reinterpreted.* = 13;
    try std.testing.expectEqual(@as(u32, 13), value);

    sdl.atomic.compilerBarrier();
    sdl.stdinc.compileTimeAssert("ported SDL macro helpers", true);
    comptime {
        _ = sdl.assert.breakpoint;
        _ = sdl.assert.triggerBreakpoint;
    }
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

    const zeroed = sdl.stdinc.calloc(4, 8) orelse return error.OutOfMemory;
    const expected_zeroes = [_]u8{0} ** 32;
    try std.testing.expectEqualSlices(u8, &expected_zeroes, @as([*]const u8, @ptrCast(zeroed))[0..32]);
    sdl.stdinc.free(zeroed);

    try std.testing.expectEqual(@as(usize, 3), backing.allocations);
    try std.testing.expectEqual(@as(usize, 3), backing.deallocations);
    try std.testing.expectError(
        error.AlreadyInstalled,
        sdl.AllocatorBridge.install(backing.allocator()),
    );

    const failed_pointer = sdl.stdinc.malloc(41) orelse return error.OutOfMemory;
    @memset(@as([*]u8, @ptrCast(failed_pointer))[0..41], 0x5a);
    backing.fail_next = true;
    try std.testing.expect(sdl.stdinc.realloc(failed_pointer, 100) == null);
    try std.testing.expectEqual(@as(usize, 3), backing.deallocations);
    sdl.stdinc.free(failed_pointer);
    try std.testing.expectEqual(@as(usize, 4), backing.deallocations);
}
