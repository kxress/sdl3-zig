/// Package entry point for SDL core and selected companion libraries.
const options = @import("sdl3_options");

/// SDL core facilities.
pub const core = @import("sdl");

/// Focused aliases for the generated SDL namespaces. The `core` namespace remains available for
/// source compatibility, while these names provide the discoverable root-level module graph.
pub const assert = core.assert;
pub const async_io = core.asyncIo;
pub const atomic = core.atomic;
pub const audio = core.audio;
pub const camera = core.camera;
pub const events = core.events;
pub const filesystem = core.filesystem;
pub const gamepad = core.gamepad;
pub const gpu = core.gpu;
pub const joystick = core.joystick;
pub const mutex = core.mutex;
pub const pixels = @import("pixels_facade");
pub const properties = core.properties;
pub const render = core.render;
pub const surface = core.surface;
pub const thread = core.thread;
pub const timer = core.timer;
pub const tray = core.tray;
pub const video = core.video;
pub const vulkan = core.vulkan;

/// Canonical spelling aliases retained alongside generated namespace spellings.
pub const blend_mode = @import("blend_facade");
pub const hid_api = @import("hid_facade");
pub const message_box = @import("message_box_facade");
pub const keycode = @import("keycode_facade");
pub const scancode = @import("scancode_facade");
pub const guid = @import("guid_facade");
pub const version = @import("version_facade");
pub const time = @import("time_facade");
pub const power = @import("power_facade");
pub const pen = @import("pen_facade");
pub const touch = @import("touch_facade");
pub const net_api = if (options.net) @import("net_facade") else unavailableModule("SDL_net");
pub const gpu_api = @import("gpu_facade");
pub const ttf_api = if (options.ttf) @import("ttf_facade") else unavailableModule("SDL_ttf");
pub const mixer_api = if (options.mixer) @import("mixer_facade") else unavailableModule("SDL_mixer");
pub const haptic_api = @import("haptic_facade");
pub const video_api = @import("video_facade");
pub const dialog_api = @import("dialog_facade");
pub const process_api = @import("process_facade");
pub const render_api = @import("render_facade");
pub const surface_api = @import("surface_facade");
pub const surface_image_api = if (options.image) @import("surface_image_facade") else unavailableModule("SDL_image");
pub const audio_api = @import("audio_facade");
pub const camera_api = @import("camera_facade");
pub const io_stream_api = @import("io_stream_facade");
pub const async_io_api = @import("async_io_facade");
pub const filesystem_api = @import("filesystem_facade");
pub const properties_api = @import("properties_facade");
pub const storage_api = @import("storage_facade");
pub const timer_api = @import("timer_facade");
pub const tray_api = @import("tray_facade");
pub const thread_api = @import("thread_facade");
pub const mutex_api = @import("mutex_facade");
pub const mouse_api = @import("mouse_facade");
pub const image_api = if (options.image) @import("image_facade") else unavailableModule("SDL_image");
pub const metal_api = @import("metal_facade");
pub const vulkan_api = @import("vulkan_facade");
pub const assert_api = @import("assert_facade");
pub const clipboard_api = @import("clipboard_facade");
pub const events_api = @import("events_facade");
pub const hints_api = @import("hints_facade");
pub const log_api = @import("log_facade");
pub const system_api = @import("system_facade");
pub const app_api = @import("app_facade");
pub const shader_assets_api = @import("shader_assets_facade");
pub const extras = @import("extras_facade");
pub const atomic_api = @import("atomic_facade");
pub const platform_info = @import("platform_info_facade");
pub const platform_api = core.platform;
pub const loadso_api = core.loadso;
pub const loadso_facade = @import("loadso_facade");
pub const init_api = @import("init_facade");
pub const version_api = @import("version_facade");
pub const bits = platform_info.bits;
pub const cpu_info = platform_info.cpu_info;
pub const endian = platform_info.endian;
pub const intrin = platform_info.intrin;
pub const joystick = @import("joystick_facade");
pub const mouse = @import("mouse_facade");
pub const keyboard = @import("keyboard_facade");
pub const gamepad = @import("gamepad_facade");
pub const sensor = @import("sensor_facade");

/// Reusable checked-result helpers for ergonomic facade modules.
pub const errors = @import("errors");
pub const value = @import("value");
pub const ownership = @import("ownership");
pub const geometry = @import("geometry");

/// SDL test helper facilities when enabled by the package build option.
pub const @"test" = if (options.test_) @import("test") else unavailableModule("SDL3_test");

/// Controller image facilities when enabled by the package build option.
pub const controller_image = if (options.controller_image)
    @import("controller_image")
else
    unavailableModule("ControllerImage");

/// SDL shader cross-compilation facilities when enabled by the package build option.
pub const shadercross = if (options.shadercross)
    @import("shadercross")
else
    unavailableModule("SDL_shadercross");

/// SDL_image facilities when enabled by the package build option.
pub const image = if (options.image) @import("image") else unavailableModule("SDL_image");

/// SDL_ttf facilities when enabled by the package build option.
pub const ttf = if (options.ttf) @import("ttf") else unavailableModule("SDL_ttf");

/// SDL_mixer facilities when enabled by the package build option.
pub const mixer = if (options.mixer) @import("mixer") else unavailableModule("SDL_mixer");

/// SDL_net facilities when enabled by the package build option.
pub const net = if (options.net) @import("net") else unavailableModule("SDL_net");

fn unavailableModule(comptime library: []const u8) type {
    return struct {
        /// Explains how to make this companion available.
        pub fn unavailable() noreturn {
            @compileError(library ++ " is not enabled; set the corresponding build option.");
        }
    };
}

test "focused root aliases remain importable" {
    _ = assert;
    _ = async_io;
    _ = atomic;
    _ = audio;
    _ = camera;
    _ = events;
    _ = filesystem;
    _ = gamepad;
    _ = gpu;
    _ = joystick;
    _ = mutex;
    _ = pixels;
    _ = properties;
    _ = render;
    _ = surface;
    _ = thread;
    _ = timer;
    _ = tray;
    _ = video;
    _ = vulkan;
    _ = blend_mode;
    _ = hid_api;
    _ = message_box;
    _ = errors;
}
