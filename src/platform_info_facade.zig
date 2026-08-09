const builtin = @import("builtin");
const std = @import("std");

pub const bits = struct {
    pub fn count(value: anytype) u32 {
        return @popCount(value);
    }
    pub fn leadingZeros(value: anytype) u32 {
        return @clz(value);
    }
    pub fn trailingZeros(value: anytype) u32 {
        return @ctz(value);
    }
};

pub const cpu_info = struct {
    pub const arch = builtin.target.cpu.arch;
    pub const os = builtin.target.os.tag;
    pub const abi = builtin.target.abi;
};

pub const endian = struct {
    pub const native = builtin.target.cpu.arch.endian();
    pub const little = native == .little;
    pub const big = native == .big;
};

pub const intrin = struct {
    pub const sse = switch (builtin.target.cpu.arch) {
        .x86, .x86_64 => builtin.target.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.sse)),
        else => false,
    };
    pub const avx2 = switch (builtin.target.cpu.arch) {
        .x86, .x86_64 => builtin.target.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.avx2)),
        else => false,
    };
    pub const neon = switch (builtin.target.cpu.arch) {
        .aarch64 => builtin.target.cpu.features.isEnabled(@intFromEnum(std.Target.aarch64.Feature.neon)),
        .arm, .armeb => builtin.target.cpu.features.isEnabled(@intFromEnum(std.Target.arm.Feature.neon)),
        else => false,
    };
};
