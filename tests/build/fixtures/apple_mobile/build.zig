const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const object = b.addObject(.{
        .name = "apple-mobile-binding-check",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    _ = sdl3.addTo(b, object, .{
        .distribution = .none,
        .install_runtime = false,
    });
    b.default_step.dependOn(&object.step);
}
