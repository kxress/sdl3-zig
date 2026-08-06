const std = @import("std");
const sdl3 = @import("sdl3");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(sdl3.Linkage, "linkage", "Source linkage") orelse .shared;
    const source_feature_profile = b.option(
        sdl3.SourceFeatureProfile,
        "source_feature_profile",
        "Source SDL core feature profile",
    ) orelse .headless;
    const source_audio = b.option(bool, "source_audio", "Enable SDL audio");
    const source_video = b.option(bool, "source_video", "Enable SDL video");
    const source_gpu = b.option(bool, "source_gpu", "Enable SDL GPU");
    const source_renderer = b.option(bool, "source_renderer", "Enable SDL renderer");
    const source_camera = b.option(bool, "source_camera", "Enable SDL camera");
    const source_feature_smoke = b.option(
        bool,
        "source_feature_smoke",
        "Run SDL core feature availability checks",
    ) orelse false;
    const install_runtime = b.option(
        bool,
        "install_runtime",
        "Install shared source runtimes into the consumer prefix",
    ) orelse true;
    const install_controller_image_data = b.option(
        bool,
        "install_controller_image_data",
        "Install generated ControllerImage data",
    ) orelse false;
    const controller_image_data_smoke = b.option(
        bool,
        "controller_image_data_smoke",
        "Stop after loading installed ControllerImage data",
    ) orelse false;
    const shadercross_dxc_smoke = b.option(
        bool,
        "shadercross_dxc_smoke",
        "Run an SDL_shadercross DXC conversion smoke test",
    ) orelse false;
    const shadercross_dxc = b.option(
        sdl3.ShadercrossDxc,
        "shadercross_dxc",
        "SDL_shadercross DXC mode",
    ) orelse .disabled;
    const shadercross_dxc_root = b.option(
        []const u8,
        "shadercross_dxc_root",
        "Root containing an externally supplied DXC runtime",
    );
    const disable_image_bmp = b.option(
        bool,
        "disable_image_bmp",
        "Pass an upstream SDL_image CMake option through the package",
    ) orelse false;
    const source_cmake_options: []const []const u8 = if (disable_image_bmp)
        &.{"-DSDLIMAGE_BMP=OFF"}
    else
        &.{};
    const source_cmake_generator: ?[]const u8 = if (target.result.os.tag == .windows)
        "Visual Studio 17 2022"
    else
        null;
    const source_sysroot = b.option(
        []const u8,
        "source_sysroot",
        "CMake sysroot forwarded to every source component",
    );
    const source_include_dir = b.option(
        []const u8,
        "source_include_dir",
        "Additional C and C++ include directory forwarded to every source component",
    );
    const enable_mixer_mp3 = b.option(
        bool,
        "enable_mixer_mp3",
        "Enable SDL3_mixer's self-contained MP3 decoder",
    ) orelse false;
    const source_mixer_cmake_options: []const []const u8 = if (enable_mixer_mp3)
        &.{"-DSDLMIXER_MP3=ON"}
    else
        &.{};
    const source_cmake_toolchain: ?[]const u8 = if (target.result.os.tag == .linux)
        std.fs.path.join(
            b.allocator,
            &.{ b.build_root.path orelse ".", "zig-toolchain.cmake" },
        ) catch @panic("OOM")
    else
        null;
    var source_cmake_options_list: std.ArrayList([]const u8) = .empty;
    if (target.result.os.tag == .linux) {
        const target_triple = target.result.zigTriple(b.allocator) catch @panic("OOM");
        source_cmake_options_list.append(
            b.allocator,
            b.fmt("-DCMAKE_C_COMPILER_TARGET={s}", .{target_triple}),
        ) catch @panic("OOM");
        source_cmake_options_list.append(
            b.allocator,
            b.fmt("-DCMAKE_CXX_COMPILER_TARGET={s}", .{target_triple}),
        ) catch @panic("OOM");
    }
    if (source_sysroot) |path| {
        source_cmake_options_list.append(b.allocator, b.fmt("-DCMAKE_SYSROOT={s}", .{path})) catch
            @panic("OOM");
    }
    if (source_include_dir) |path| {
        source_cmake_options_list.append(
            b.allocator,
            b.fmt("-DCMAKE_C_FLAGS=-isystem{s}", .{path}),
        ) catch @panic("OOM");
        source_cmake_options_list.append(
            b.allocator,
            b.fmt("-DCMAKE_CXX_FLAGS=-isystem{s}", .{path}),
        ) catch @panic("OOM");
    }
    if (target.result.os.tag == .windows) {
        source_cmake_options_list.append(b.allocator, "-A") catch @panic("OOM");
        source_cmake_options_list.append(b.allocator, "x64") catch @panic("OOM");
        // The native CI image does not provide an external LibUSB package. HIDAPI's optional
        // backend is not required by this source smoke fixture.
        source_cmake_options_list.append(b.allocator, "-DSDL_HIDAPI_LIBUSB=OFF") catch @panic("OOM");
    }
    source_cmake_options_list.appendSlice(b.allocator, source_cmake_options) catch @panic("OOM");
    const executable = b.addExecutable(.{
        .name = "cmake-source-all",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const build_options = b.addOptions();
    build_options.addOption(bool, "source_feature_smoke", source_feature_smoke);
    build_options.addOption(bool, "controller_image_data_smoke", controller_image_data_smoke);
    build_options.addOption(bool, "shadercross_dxc_smoke", shadercross_dxc_smoke);
    executable.root_module.addOptions("source_all_options", build_options);
    _ = sdl3.addTo(b, executable, .{
        .distribution = .source,
        .linkage = linkage,
        .sdl3_test = true,
        .controller_image = true,
        .shadercross = true,
        .shadercross_dxc = shadercross_dxc,
        .shadercross_dxc_root = shadercross_dxc_root,
        .image = true,
        .ttf = true,
        .mixer = true,
        .net = true,
        .source_cmake_options = source_cmake_options_list.items,
        .source_cmake_generator = source_cmake_generator,
        .source_mixer_cmake_options = source_mixer_cmake_options,
        .source_cmake_toolchain = source_cmake_toolchain,
        .source_features = .{
            .profile = source_feature_profile,
            .audio = source_audio,
            .video = source_video,
            .gpu = source_gpu,
            .renderer = source_renderer,
            .camera = source_camera,
        },
        .install_runtime = install_runtime,
        .install_controller_image_data = install_controller_image_data,
    });
    b.installArtifact(executable);
}
