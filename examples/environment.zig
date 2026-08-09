const std = @import("std");

pub const Distribution = enum { auto, none, system, prebuilt, source };

pub const Configuration = struct {
    distribution: ?[]const u8,
    cmake_generator: ?[]const u8,
    cmake_c_compiler: ?[]const u8,
    cmake_cxx_compiler: ?[]const u8,
    cmake_make_program: ?[]const u8,
};

pub fn load(b: *std.Build) Configuration {
    return .{
        .distribution = value(b, "SDL3_ZIG_EXAMPLES_DISTRIBUTION"),
        .cmake_generator = value(b, "SDL3_ZIG_EXAMPLES_CMAKE_GENERATOR"),
        .cmake_c_compiler = value(b, "SDL3_ZIG_EXAMPLES_C_COMPILER"),
        .cmake_cxx_compiler = value(b, "SDL3_ZIG_EXAMPLES_CXX_COMPILER"),
        .cmake_make_program = value(b, "SDL3_ZIG_EXAMPLES_MAKE_PROGRAM"),
    };
}

pub fn parseDistribution(text: []const u8) Distribution {
    return std.meta.stringToEnum(Distribution, text) orelse
        std.debug.panic(
            "SDL3_ZIG_EXAMPLES_DISTRIBUTION must be one of auto, none, system, prebuilt, or source; got '{s}'",
            .{text},
        );
}

fn value(b: *std.Build, name: []const u8) ?[]const u8 {
    const text = b.graph.environ_map.get(name) orelse return null;
    if (text.len == 0) std.debug.panic("{s} must not be empty", .{name});
    return text;
}
