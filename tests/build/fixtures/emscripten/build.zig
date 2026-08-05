const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const sysroot = b.option([]const u8, "emscripten_sysroot", "Emscripten sysroot") orelse
        @panic("-Demscripten_sysroot is required");
    const toolchain = b.option([]const u8, "source_cmake_toolchain", "Emscripten CMake toolchain") orelse
        @panic("-Dsource_cmake_toolchain is required");
    const libc = b.addWriteFiles().add("emscripten-libc.txt", b.fmt(
        "include_dir={s}/include\nsys_include_dir={s}/include\ncrt_dir={s}/lib/wasm32-emscripten\nmsvc_lib_dir=\nkernel32_lib_dir=\ngcc_dir=\n",
        .{ sysroot, sysroot, sysroot },
    ));

    const object = b.addObject(.{
        .name = "sdl-emscripten-consumer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    object.setLibCFile(libc);
    object.root_module.addCSourceFile(.{ .file = b.path("long_double_probe.c"), .flags = &.{} });
    _ = sdl3.addTo(b, object, .{
        .distribution = .source,
        .linkage = .static,
        .emscripten_sysroot = sysroot,
        .source_cmake_toolchain = toolchain,
        .source_features = .{ .profile = .headless },
    });

    const output_base = b.cache_root.join(b.allocator, &.{"sdl-emscripten-consumer"}) catch
        @panic("unable to allocate Emscripten output path");
    const source_library = b.cache_root.join(b.allocator, &.{ "sdl3-source", "lib" }) catch
        @panic("unable to allocate SDL source library path");
    const emcc = b.addSystemCommand(&.{"emcc"});
    emcc.addFileArg(object.getEmittedBin());
    emcc.addArg("-L");
    emcc.addArg(source_library);
    emcc.addArg("-lSDL3");
    emcc.addArg("--preload-file");
    emcc.addArg(b.fmt("{s}@assets", .{b.pathFromRoot("assets")}));
    emcc.addArg("-o");
    emcc.addArg(b.fmt("{s}.html", .{output_base}));
    const install_html = b.addInstallFile(
        .{ .cwd_relative = b.fmt("{s}.html", .{output_base}) },
        "sdl-emscripten-consumer.html",
    );
    const install_js = b.addInstallFile(
        .{ .cwd_relative = b.fmt("{s}.js", .{output_base}) },
        "sdl-emscripten-consumer.js",
    );
    const install_data = b.addInstallFile(
        .{ .cwd_relative = b.fmt("{s}.data", .{output_base}) },
        "sdl-emscripten-consumer.data",
    );
    const install_wasm = b.addInstallFile(
        .{ .cwd_relative = b.fmt("{s}.wasm", .{output_base}) },
        "sdl-emscripten-consumer.wasm",
    );
    install_html.step.dependOn(&emcc.step);
    install_js.step.dependOn(&emcc.step);
    install_data.step.dependOn(&emcc.step);
    install_wasm.step.dependOn(&emcc.step);
    b.getInstallStep().dependOn(&install_html.step);
    b.getInstallStep().dependOn(&install_js.step);
    b.getInstallStep().dependOn(&install_data.step);
    b.getInstallStep().dependOn(&install_wasm.step);
}
