/// Package entry point for SDL core and selected companion libraries.
const options = @import("sdl3_options");

/// SDL core facilities.
pub const core = @import("sdl");

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
