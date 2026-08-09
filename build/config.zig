const std = @import("std");

pub const Distribution = enum {
    /// Prefer package-local official prebuilts, then discoverable system libraries, then source.
    auto,
    /// Import bindings without selecting or linking an SDL implementation.
    none,
    /// Link SDL libraries supplied by the system or consumer.
    system,
    /// Link the pinned official shared libraries shipped in the release package.
    prebuilt,
    /// Build the verified upstream sources in the consumer's build cache.
    source,
};

/// Selects whether SDL libraries are linked statically or dynamically.
pub const Linkage = enum { static, shared };

/// Selects how a source SDL_shadercross build enables its optional DXC support.
pub const ShadercrossDxc = enum { disabled, bundled, external, source };

/// Selects the baseline for SDL's optional core subsystems in a source build.
///
/// `headless` keeps source builds independent of host audio and display SDKs. `desktop` enables
/// SDL's audio, video, GPU, renderer, and camera subsystems; platform-specific CMake checks still
/// decide which concrete drivers are available.
pub const SourceFeatureProfile = enum { headless, desktop };

/// A shared runtime emitted by a source distribution.
pub const SourceRuntime = enum {
    sdl,
    shadercross,
    image,
    ttf,
    mixer,
    net,
    shadercross_dxc_dxcompiler,
    shadercross_dxc_dxil,
};

/// Optional SDL core subsystem selection for source distributions.
pub const SourceFeatureOptions = struct {
    /// Baseline applied before individual subsystem overrides.
    profile: SourceFeatureProfile = .headless,
    audio: ?bool = null,
    video: ?bool = null,
    gpu: ?bool = null,
    renderer: ?bool = null,
    camera: ?bool = null,

    pub fn enabled(self: @This(), feature: Feature) bool {
        const override = switch (feature) {
            .audio => self.audio,
            .video => self.video,
            .gpu => self.gpu,
            .renderer => self.renderer,
            .camera => self.camera,
        };
        return override orelse switch (self.profile) {
            .headless => false,
            .desktop => true,
        };
    }

    pub const Feature = enum { audio, video, gpu, renderer, camera };
};

/// Configures the modules and native implementation attached by `sdl3.addTo`.
pub const AddOptions = struct {
    /// Native library selection. `auto` tries package prebuilts, system libraries, then source.
    distribution: Distribution = .auto,
    /// Static or shared native linkage.
    linkage: Linkage = .shared,
    /// Import and link SDL3_test.
    sdl3_test: bool = false,
    /// Import and link ControllerImage.
    controller_image: bool = false,
    /// Install the standard ControllerImage database with a source distribution.
    install_controller_image_data: bool = false,
    /// Import and link SDL_shadercross.
    shadercross: bool = false,
    /// Import and link SDL3_image.
    image: bool = false,
    /// Import and link SDL3_ttf.
    ttf: bool = false,
    /// Import and link SDL3_mixer.
    mixer: bool = false,
    /// Import and link SDL3_net.
    net: bool = false,
    /// Include official optional image and mixer codec dependencies.
    optional_codecs: bool = false,
    /// Install selected shared runtimes beside the consumer's artifacts.
    install_runtime: bool = true,
    /// Component=version entries used when pkg-config cannot discover a system version.
    system_version_overrides: []const []const u8 = &.{},
    /// Permit caller-supplied system libraries without discoverable pkg-config metadata.
    allow_unknown_system_versions: bool = false,
    /// CMake generator used for source distributions.
    source_cmake_generator: ?[]const u8 = null,
    /// CMake toolchain file used for source distributions.
    source_cmake_toolchain: ?[]const u8 = null,
    /// Emscripten sysroot containing the C headers required by Zig translate-c.
    emscripten_sysroot: ?[]const u8 = null,
    /// Android NDK root containing the sysroot required by Zig translate-c.
    android_ndk_root: ?[]const u8 = null,
    /// SDL core subsystems enabled in source distributions.
    source_features: SourceFeatureOptions = .{},
    /// Additional arguments passed to every SDL-family CMake configure step.
    source_cmake_options: []const []const u8 = &.{},
    /// Additional arguments passed only to the SDL3_mixer CMake configure step.
    source_mixer_cmake_options: []const []const u8 = &.{},
    /// DXC support mode for a source SDL_shadercross build.
    shadercross_dxc: ShadercrossDxc = .disabled,
    /// Root containing an externally supplied DirectXShaderCompiler runtime.
    shadercross_dxc_root: ?[]const u8 = null,
};

pub const PackageOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    requested_distribution: ?Distribution,
    linkage: Linkage,
    optional_codecs: bool,
    link: LinkSelection,
    facade: FacadeSelection,
    source: SourceOptions,
    emscripten_sysroot: ?[]const u8,
    android_ndk_root: ?[]const u8,
    selected_example: ?[]const u8,

    pub fn parse(b: *std.Build) PackageOptions {
        const target = b.standardTargetOptions(.{});
        const optimize = b.standardOptimizeOption(.{});

        // Distribution and linkage.
        const requested_distribution = b.option(
            Distribution,
            "distribution",
            "[Distribution] Native SDL libraries: auto, none, system, prebuilt, or source",
        );
        const linkage = b.option(
            Linkage,
            "linkage",
            "[Distribution] Link SDL libraries statically or dynamically",
        ) orelse .shared;
        const optional_codecs = b.option(
            bool,
            "optional_codecs",
            "[Distribution] Install and link official SDL_image and SDL_mixer codecs",
        ) orelse false;

        // Module linking.
        const link = LinkSelection{
            .sdl = b.option(bool, "link_sdl", "[Linking] Link SDL3 through the sdl module") orelse false,
            .test_ = b.option(bool, "link_test", "[Linking] Link SDL3_test through the test module") orelse false,
            .controller_image = b.option(bool, "link_controller_image", "[Linking] Link ControllerImage through its module") orelse false,
            .shadercross = b.option(bool, "link_shadercross", "[Linking] Link SDL_shadercross through its module") orelse false,
            .image = b.option(bool, "link_image", "[Linking] Link SDL3_image through the image module") orelse false,
            .ttf = b.option(bool, "link_ttf", "[Linking] Link SDL3_ttf through the ttf module") orelse false,
            .mixer = b.option(bool, "link_mixer", "[Linking] Link SDL3_mixer through the mixer module") orelse false,
            .net = b.option(bool, "link_net", "[Linking] Link SDL3_net through the net module") orelse false,
            .system_version_overrides = b.option(
                []const []const u8,
                "system_version_overrides",
                "[Linking] Component=version overrides for system SDL libraries",
            ) orelse &.{},
            .allow_unknown_system_versions = b.option(
                bool,
                "allow_unknown_system_versions",
                "[Linking] Allow system libraries without discoverable pkg-config versions",
            ) orelse false,
        };

        // Public façade imports.
        const facade = FacadeSelection{
            .image = b.option(bool, "enable_image", "[Modules] Expose SDL_image through sdl3") orelse false,
            .test_ = b.option(bool, "enable_test", "[Modules] Expose SDL3_test through sdl3") orelse false,
            .controller_image = b.option(bool, "enable_controller_image", "[Modules] Expose ControllerImage through sdl3") orelse false,
            .shadercross = b.option(bool, "enable_shadercross", "[Modules] Expose SDL_shadercross through sdl3") orelse false,
            .ttf = b.option(bool, "enable_ttf", "[Modules] Expose SDL_ttf through sdl3") orelse false,
            .mixer = b.option(bool, "enable_mixer", "[Modules] Expose SDL_mixer through sdl3") orelse false,
            .net = b.option(bool, "enable_net", "[Modules] Expose SDL_net through sdl3") orelse false,
        };

        // Source distribution configuration.
        const source = SourceOptions{
            .cmake_generator = b.option([]const u8, "source_cmake_generator", "[Source] CMake generator"),
            .cmake_toolchain = b.option([]const u8, "source_cmake_toolchain", "[Source] CMake toolchain file"),
            .features = .{
                .profile = b.option(SourceFeatureProfile, "source_feature_profile", "[Source] SDL core feature profile: headless or desktop") orelse .headless,
                .audio = b.option(bool, "source_audio", "[Source] Override SDL audio support"),
                .video = b.option(bool, "source_video", "[Source] Override SDL video support"),
                .gpu = b.option(bool, "source_gpu", "[Source] Override SDL GPU support"),
                .renderer = b.option(bool, "source_renderer", "[Source] Override SDL renderer support"),
                .camera = b.option(bool, "source_camera", "[Source] Override SDL camera support"),
            },
            .cmake_options = b.option([]const []const u8, "source_cmake_options", "[Source] Extra arguments for every CMake configure step") orelse &.{},
            .mixer_cmake_options = b.option([]const []const u8, "source_mixer_cmake_options", "[Source] Extra arguments for SDL3_mixer CMake") orelse &.{},
            .shadercross_dxc = b.option(ShadercrossDxc, "shadercross_dxc", "[Source] SDL_shadercross DXC mode") orelse .disabled,
            .shadercross_dxc_root = b.option([]const u8, "shadercross_dxc_root", "[Source] External DirectXShaderCompiler runtime root"),
        };

        return .{
            .target = target,
            .optimize = optimize,
            .requested_distribution = requested_distribution,
            .linkage = linkage,
            .optional_codecs = optional_codecs,
            .link = link,
            .facade = facade,
            .source = source,
            .emscripten_sysroot = b.option([]const u8, "emscripten_sysroot", "[Cross-target] Emscripten sysroot containing libc headers"),
            .android_ndk_root = b.option([]const u8, "android_ndk_root", "[Cross-target] Android NDK root containing the target sysroot"),
            .selected_example = b.option([]const u8, "example", "[Examples] Exact name used by build-example and run-example"),
        };
    }
};

pub const LinkSelection = struct {
    sdl: bool,
    test_: bool,
    controller_image: bool,
    shadercross: bool,
    image: bool,
    ttf: bool,
    mixer: bool,
    net: bool,
    system_version_overrides: []const []const u8,
    allow_unknown_system_versions: bool,

    pub fn effectiveSdl(link: @This()) bool {
        return link.sdl or link.test_ or link.controller_image or link.shadercross or link.image or
            link.ttf or link.mixer or link.net;
    }
};

pub const FacadeSelection = struct {
    image: bool,
    test_: bool,
    controller_image: bool,
    shadercross: bool,
    ttf: bool,
    mixer: bool,
    net: bool,
};

pub const SourceOptions = struct {
    cmake_generator: ?[]const u8,
    cmake_toolchain: ?[]const u8,
    features: SourceFeatureOptions,
    cmake_options: []const []const u8,
    mixer_cmake_options: []const []const u8,
    shadercross_dxc: ShadercrossDxc,
    shadercross_dxc_root: ?[]const u8,
};
