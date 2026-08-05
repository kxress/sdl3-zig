const std = @import("std");
const sdl_metadata = @import("sdl_metadata.zig");
const maintenance_steps = @import("examples/steps.zig");

pub const Distribution = enum {
    /// Import bindings without selecting or linking an SDL implementation.
    none,
    /// Link SDL libraries supplied by the system or consumer.
    system,
    /// Link the pinned official shared libraries shipped in the release package.
    prebuilt,
    /// Build the verified upstream sources in the consumer's build cache.
    source,
};

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

/// Returns the exact staged runtime artifact for a selected shared source component.
///
/// The artifact is available after the source dependency's install step. This is useful when a
/// consumer owns a custom packaging step instead of using `install_runtime`.
pub fn sourceRuntimeArtifact(
    b: *std.Build,
    dependency: *std.Build.Dependency,
    runtime: SourceRuntime,
) std.Build.LazyPath {
    return dependency.namedLazyPath(b.fmt("source-runtime-{s}", .{@tagName(runtime)}));
}

/// Returns the generated standard ControllerImage database for a source distribution.
pub fn sourceControllerImageDataArtifact(
    b: *std.Build,
    dependency: *std.Build.Dependency,
) std.Build.LazyPath {
    _ = b;
    return dependency.namedLazyPath("source-controller-image-data");
}

pub const SourceFeatureOptions = struct {
    profile: SourceFeatureProfile = .headless,
    audio: ?bool = null,
    video: ?bool = null,
    gpu: ?bool = null,
    renderer: ?bool = null,
    camera: ?bool = null,

    fn enabled(self: @This(), feature: Feature) bool {
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

    const Feature = enum { audio, video, gpu, renderer, camera };
};

pub const AddOptions = struct {
    /// Select the native library distribution explicitly for this consumer.
    distribution: Distribution,
    linkage: Linkage = .shared,
    sdl3_test: bool = false,
    controller_image: bool = false,
    install_controller_image_data: bool = false,
    shadercross: bool = false,
    image: bool = false,
    ttf: bool = false,
    mixer: bool = false,
    net: bool = false,
    optional_codecs: bool = false,
    install_runtime: bool = true,
    /// Component=version entries used when pkg-config cannot discover a system version.
    system_version_overrides: []const []const u8 = &.{},
    /// Permit caller-supplied system libraries without discoverable pkg-config metadata.
    allow_unknown_system_versions: bool = false,
    source_cmake_generator: ?[]const u8 = null,
    source_cmake_toolchain: ?[]const u8 = null,
    /// Emscripten sysroot containing the C headers required by Zig translate-c.
    emscripten_sysroot: ?[]const u8 = null,
    /// Android NDK root containing the sysroot required by Zig translate-c.
    android_ndk_root: ?[]const u8 = null,
    source_features: SourceFeatureOptions = .{},
    source_cmake_options: []const []const u8 = &.{},
    /// Additional arguments passed only to the SDL3_mixer source CMake configure step.
    source_mixer_cmake_options: []const []const u8 = &.{},
    shadercross_dxc: ShadercrossDxc = .disabled,
    shadercross_dxc_root: ?[]const u8 = null,
};

/// Adds the selected modules and shared implementation to an executable or library.
pub fn addTo(
    b: *std.Build,
    artifact: *std.Build.Step.Compile,
    options: AddOptions,
) *std.Build.Dependency {
    const target = artifact.root_module.resolved_target orelse
        std.debug.panic("sdl3.addTo requires an artifact with a resolved target", .{});
    const optimize = artifact.root_module.optimize orelse
        std.debug.panic("sdl3.addTo requires an artifact with an optimization mode", .{});
    const dependency = b.dependencyFromBuildZig(@This(), .{
        .target = target,
        .optimize = optimize,
        .distribution = options.distribution,
        .linkage = options.linkage,
        .enable_image = options.image,
        .enable_test = options.sdl3_test,
        .enable_controller_image = options.controller_image,
        .enable_shadercross = options.shadercross,
        .enable_ttf = options.ttf,
        .enable_mixer = options.mixer,
        .enable_net = options.net,
        .link_sdl = true,
        .link_test = options.sdl3_test,
        .link_controller_image = options.controller_image,
        .link_shadercross = options.shadercross,
        .link_image = options.image,
        .link_ttf = options.ttf,
        .link_mixer = options.mixer,
        .link_net = options.net,
        .optional_codecs = options.optional_codecs,
        .system_version_overrides = options.system_version_overrides,
        .allow_unknown_system_versions = options.allow_unknown_system_versions,
        .source_cmake_generator = options.source_cmake_generator,
        .source_cmake_toolchain = options.source_cmake_toolchain,
        .emscripten_sysroot = options.emscripten_sysroot,
        .android_ndk_root = options.android_ndk_root,
        .source_feature_profile = options.source_features.profile,
        .source_audio = options.source_features.audio,
        .source_video = options.source_features.video,
        .source_gpu = options.source_features.gpu,
        .source_renderer = options.source_features.renderer,
        .source_camera = options.source_features.camera,
        .source_cmake_options = options.source_cmake_options,
        .source_mixer_cmake_options = options.source_mixer_cmake_options,
        .shadercross_dxc = options.shadercross_dxc,
        .shadercross_dxc_root = options.shadercross_dxc_root,
    });

    if (options.distribution == .source) {
        artifact.step.dependOn(dependency.builder.getInstallStep());
        const install_source_runtime = options.install_runtime and
            (options.linkage == .shared or
                (options.shadercross and options.shadercross_dxc != .disabled));
        if (install_source_runtime) {
            if (target.result.os.tag == .linux) {
                artifact.root_module.addRPathSpecial("$ORIGIN/../lib");
            } else if (target.result.os.tag == .macos) {
                artifact.root_module.addRPathSpecial("@executable_path/../lib");
            }
            installSourceRuntime(b, dependency, target);
        }
        if (options.controller_image and options.install_controller_image_data) {
            installSourceControllerImageData(b, dependency);
        }
    }

    artifact.root_module.addImport("sdl", dependency.module("sdl"));
    artifact.root_module.addImport("sdl3", dependency.module("sdl3"));
    if (options.image) artifact.root_module.addImport("image", dependency.module("image"));
    if (options.sdl3_test) artifact.root_module.addImport("test", dependency.module("test"));
    if (options.controller_image) artifact.root_module.addImport("controller_image", dependency.module("controller_image"));
    if (options.shadercross) artifact.root_module.addImport("shadercross", dependency.module("shadercross"));
    if (options.ttf) artifact.root_module.addImport("ttf", dependency.module("ttf"));
    if (options.mixer) artifact.root_module.addImport("mixer", dependency.module("mixer"));
    if (options.net) artifact.root_module.addImport("net", dependency.module("net"));

    if (options.distribution == .prebuilt) {
        if (target.result.os.tag == .macos) {
            artifact.root_module.addRPathSpecial("@executable_path/../lib");
        }
        if (options.install_runtime) installRuntime(b, dependency, target, options);
    }
    return dependency;
}

const BuiltLibrary = struct {
    configuration: *const sdl_metadata.Library,
    module: *std.Build.Module,
};

const LinkOptions = struct {
    sdl: bool = false,
    test_: bool = false,
    controller_image: bool = false,
    shadercross: bool = false,
    image: bool = false,
    ttf: bool = false,
    mixer: bool = false,
    net: bool = false,
    system_version_overrides: []const []const u8 = &.{},
    allow_unknown_system_versions: bool = false,
};

const SourceBuild = struct {
    prefix: []const u8,
    step: *std.Build.Step,
    linkage: Linkage,
    shadercross_dxc: ShadercrossDxc,
    runtime_directory: ?[]const u8,
};

fn findLibraryModule(library_modules: []const BuiltLibrary, module_name: []const u8) *std.Build.Module {
    for (library_modules) |library| {
        if (std.mem.eql(u8, library.configuration.module_name, module_name)) return library.module;
    }
    std.debug.panic("library configuration dependency '{s}' was not created first", .{module_name});
}

pub const RepositoryModules = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    native_build: ?*std.Build.Step,
    sdl: *std.Build.Module,
    test_: *std.Build.Module,
    controller_image: *std.Build.Module,
    shadercross: *std.Build.Module,
    image: *std.Build.Module,
    ttf: *std.Build.Module,
    mixer: *std.Build.Module,
    net: *std.Build.Module,
};

pub const RepositoryOptions = struct {
    distribution: Distribution = .none,
    linkage: Linkage = .shared,
    image: bool = false,
    ttf: bool = false,
    mixer: bool = false,
    net: bool = false,
    source_cmake_generator: ?[]const u8 = null,
    source_cmake_toolchain: ?[]const u8 = null,
    source_features: SourceFeatureOptions = .{},
    source_cmake_options: []const []const u8 = &.{},
    source_mixer_cmake_options: []const []const u8 = &.{},
    install_runtime: bool = true,
};

pub fn addRepositoryModules(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) RepositoryModules {
    return addRepositoryModulesWithOptions(b, target, optimize, .{});
}

pub fn addRepositoryModulesWithOptions(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    options: RepositoryOptions,
) RepositoryModules {
    const support = b.createModule(.{
        .root_source_file = b.path("src/support.zig"),
        .target = target,
        .optimize = optimize,
    });
    const link_options = LinkOptions{
        .sdl = options.distribution != .none,
        .image = options.image,
        .ttf = options.ttf,
        .mixer = options.mixer,
        .net = options.net,
    };
    const source_build: ?SourceBuild = if (options.distribution == .source)
        addCmakeSourceBuild(
            b,
            target,
            link_options,
            options.linkage,
            options.source_cmake_generator,
            options.source_cmake_toolchain,
            options.source_features,
            options.source_cmake_options,
            options.source_mixer_cmake_options,
            .disabled,
            null,
        )
    else
        null;
    const library_modules = addLibraryModules(
        b,
        target,
        optimize,
        support,
        options.distribution,
        link_options,
        options.linkage,
        null,
        null,
        &sdl_metadata.libraries,
        source_build,
    );
    const modules = RepositoryModules{
        .target = target,
        .optimize = optimize,
        .native_build = if (source_build) |source| source.step else null,
        .sdl = findLibraryModule(library_modules, "sdl"),
        .test_ = findLibraryModule(library_modules, "test"),
        .controller_image = findLibraryModule(library_modules, "controller_image"),
        .shadercross = findLibraryModule(library_modules, "shadercross"),
        .image = findLibraryModule(library_modules, "image"),
        .ttf = findLibraryModule(library_modules, "ttf"),
        .mixer = findLibraryModule(library_modules, "mixer"),
        .net = findLibraryModule(library_modules, "net"),
    };
    if (options.distribution == .prebuilt) {
        configurePrebuilt(b, target, options.linkage, .{
            .sdl = modules.sdl,
            .test_ = null,
            .controller_image = null,
            .shadercross = null,
            .image = if (options.image) modules.image else null,
            .ttf = if (options.ttf) modules.ttf else null,
            .mixer = if (options.mixer) modules.mixer else null,
            .net = if (options.net) modules.net else null,
            .optional_codecs = false,
        });
    }
    if (options.distribution == .source and options.install_runtime) {
        installRepositorySourceRuntime(b, source_build.?, target);
    }
    return modules;
}

fn linkOptionEnabled(configuration: sdl_metadata.Library, options: LinkOptions) bool {
    if (std.mem.eql(u8, configuration.module_name, "sdl")) return options.sdl;
    if (std.mem.eql(u8, configuration.module_name, "test")) return options.test_;
    if (std.mem.eql(u8, configuration.module_name, "controller_image")) return options.controller_image;
    if (std.mem.eql(u8, configuration.module_name, "shadercross")) return options.shadercross;
    if (std.mem.eql(u8, configuration.module_name, "image")) return options.image;
    if (std.mem.eql(u8, configuration.module_name, "ttf")) return options.ttf;
    if (std.mem.eql(u8, configuration.module_name, "mixer")) return options.mixer;
    if (std.mem.eql(u8, configuration.module_name, "net")) return options.net;
    std.debug.panic("library configuration has unsupported module '{s}'", .{configuration.module_name});
}

fn verifySystemVersion(
    b: *std.Build,
    configuration: sdl_metadata.Library,
    options: LinkOptions,
) void {
    const override = findSystemVersionOverride(configuration, options.system_version_overrides);
    const discovered = if (override == null)
        discoverPkgConfigVersion(b, configuration.pkg_config_name)
    else
        null;
    const actual = override orelse discovered orelse {
        if (options.allow_unknown_system_versions) return;
        std.debug.panic(
            "system SDL library {s} has no discoverable pkg-config version; pass {s}=<version> or -Dallow_unknown_system_versions=true",
            .{
                configuration.id,
                configuration.module_name,
            },
        );
    };
    if (!versionAtLeast(actual, configuration.minimum_version)) {
        std.debug.panic(
            "system SDL library {s} version {s} is older than the required {s}",
            .{ configuration.id, actual, configuration.minimum_version },
        );
    }
}

fn findSystemVersionOverride(
    configuration: sdl_metadata.Library,
    overrides: []const []const u8,
) ?[]const u8 {
    for (overrides) |entry| {
        const separator = std.mem.indexOfScalar(u8, entry, '=') orelse continue;
        const name = entry[0..separator];
        if (std.mem.eql(u8, name, configuration.key) or
            std.mem.eql(u8, name, configuration.id) or
            std.mem.eql(u8, name, configuration.module_name))
        {
            return entry[separator + 1 ..];
        }
    }
    return null;
}

fn discoverPkgConfigVersion(
    b: *std.Build,
    name: []const u8,
) ?[]const u8 {
    const result = std.process.run(b.allocator, b.graph.io, .{
        .argv = &.{ "pkg-config", "--modversion", name },
    }) catch return null;
    const exit_code = switch (result.term) {
        .exited => |code| code,
        else => return null,
    };
    if (exit_code != 0) return null;
    return std.mem.trim(u8, result.stdout, " \t\r\n");
}

fn versionAtLeast(actual: []const u8, minimum: []const u8) bool {
    const actualParts = versionParts(actual) orelse return false;
    const minimumParts = versionParts(minimum) orelse return false;
    for (actualParts, minimumParts) |actualPart, minimumPart| {
        if (actualPart > minimumPart) return true;
        if (actualPart < minimumPart) return false;
    }
    return true;
}

fn versionParts(value: []const u8) ?[3]u32 {
    var parts: [3]u32 = undefined;
    var iterator = std.mem.splitScalar(u8, value, '.');
    for (&parts) |*part| {
        const text = iterator.next() orelse return null;
        const end = std.mem.indexOfScalar(u8, text, '-') orelse text.len;
        part.* = std.fmt.parseUnsigned(u32, text[0..end], 10) catch return null;
    }
    return parts;
}

fn addLibraryModules(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    support: *std.Build.Module,
    distribution: Distribution,
    link_options: LinkOptions,
    linkage: Linkage,
    emscripten_sysroot: ?[]const u8,
    android_ndk_root: ?[]const u8,
    configurations: []const sdl_metadata.Library,
    source_build: ?SourceBuild,
) []BuiltLibrary {
    var library_modules: std.ArrayList(BuiltLibrary) = .empty;
    const translation_units = b.addWriteFiles();
    for (configurations) |*configuration| {
        const translation_unit = translation_units.add(
            b.fmt("{s}.h", .{configuration.module_name}),
            configuration.translation_unit,
        );
        const translation_target = if (isAndroidTarget(target))
            b.resolveTargetQuery(.{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu })
        else if (target.result.os.tag == .windows and target.result.cpu.arch == .aarch64)
            // The Windows SDK's ARM64 UCRT headers use compiler intrinsics that Zig 0.16
            // translate-c cannot lower. Windows ARM64 and x86_64 share the LLP64 data model,
            // so translate declarations with the host-compatible x86_64 headers and compile
            // the generated Zig module for the requested target below.
            b.resolveTargetQuery(.{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .msvc })
        else
            target;
        const translate_c = b.addTranslateC(.{
            .root_source_file = translation_unit,
            .target = translation_target,
            .optimize = optimize,
        });
        for (sdl_metadata.translation_defines) |definition| {
            translate_c.defineCMacroRaw(definition);
        }
        if (target.result.os.tag == .windows) {
            // Zig's C frontend does not accept MSVC's `ui64` literal suffix, while SDL's
            // headers select it whenever `_MSC_VER` is defined. Use the portable suffix.
            translate_c.defineCMacroRaw("SDL_UINT64_C(c)=c ## ULL");
        }
        addTranslateCTargetDefines(translate_c, target);
        if (target.result.os.tag == .emscripten) {
            const sysroot = emscripten_sysroot orelse
                @panic("wasm32-emscripten requires -Demscripten_sysroot=<emsdk sysroot>");
            translate_c.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sysroot, "include" }) });
        }
        if (isAndroidTarget(target) and android_ndk_root == null)
            @panic("Android targets require -Dandroid_ndk_root=<NDK root>");
        for (configuration.include_directories) |include_directory| {
            translate_c.addIncludePath(b.path(include_directory));
        }
        var imports: std.ArrayList(std.Build.Module.Import) = .empty;
        imports.append(b.allocator, .{ .name = configuration.abi_import_name, .module = translate_c.createModule() }) catch @panic("OOM");
        imports.append(b.allocator, .{ .name = "sdl3_support", .module = support }) catch @panic("OOM");
        for (configuration.dependencies) |dependency_name| {
            imports.append(b.allocator, .{ .name = dependency_name, .module = findLibraryModule(library_modules.items, dependency_name) }) catch @panic("OOM");
        }
        const module = b.addModule(configuration.module_name, .{
            .root_source_file = b.path(configuration.source),
            .target = target,
            .optimize = optimize,
            .imports = imports.items,
        });
        if (target.result.os.tag == .emscripten) {
            const sysroot = emscripten_sysroot orelse
                @panic("wasm32-emscripten requires -Demscripten_sysroot=<emsdk sysroot>");
            module.addLibraryPath(.{ .cwd_relative = b.pathJoin(&.{
                sysroot,
                "lib",
                "wasm32-emscripten",
            }) });
            module.linkSystemLibrary("dlmalloc", .{});
        }
        if (distribution == .system and linkOptionEnabled(configuration.*, link_options)) {
            verifySystemVersion(b, configuration.*, link_options);
            module.linkSystemLibrary(configuration.library_name, .{
                .preferred_link_mode = switch (linkage) {
                    .static => .static,
                    .shared => .dynamic,
                },
            });
        }
        if (distribution == .source and linkOptionEnabled(configuration.*, link_options)) {
            const source = source_build orelse @panic("missing source build");
            module.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{source.prefix}) });
            const library_path = if (configuration.source_build_directory.len == 0)
                b.fmt("{s}/lib", .{source.prefix})
            else
                b.cache_root.join(
                    b.allocator,
                    &.{ "sdl3-source-build", configuration.source_build_directory },
                ) catch @panic("OOM");
            module.addLibraryPath(.{ .cwd_relative = library_path });
            module.linkSystemLibrary(sourceLibraryName(b, configuration.library_name, target, source.linkage), .{});
            if (target.result.os.tag == .macos) linkMacosSourceDependencies(module);
            if (std.mem.eql(u8, configuration.module_name, "shadercross") and source.linkage == .static) {
                module.linkSystemLibrary("spirv-cross-c", .{});
                module.linkSystemLibrary("spirv-cross-glsl", .{});
                module.linkSystemLibrary("spirv-cross-hlsl", .{});
                module.linkSystemLibrary("spirv-cross-msl", .{});
                module.linkSystemLibrary("spirv-cross-cpp", .{});
                module.linkSystemLibrary("spirv-cross-reflect", .{});
                module.linkSystemLibrary("spirv-cross-core", .{});
                module.linkSystemLibrary("c++", .{});
                if (source.shadercross_dxc == .bundled or source.shadercross_dxc == .external) {
                    const dxc_library_path = b.cache_root.join(
                        b.allocator,
                        &.{
                            "sdl3-source-build",
                            "SDL3_shadercross-source",
                            "external",
                            "DirectXShaderCompiler-binaries",
                            dxcLibrarySubdirectory(target, source.shadercross_dxc),
                        },
                    ) catch @panic("OOM");
                    module.addLibraryPath(.{ .cwd_relative = dxc_library_path });
                    module.linkSystemLibrary("dxcompiler", .{});
                    module.linkSystemLibrary("dxil", .{});
                }
            }
            b.getInstallStep().dependOn(source.step);
        }
        library_modules.append(b.allocator, .{ .configuration = configuration, .module = module }) catch @panic("OOM");
    }
    return library_modules.toOwnedSlice(b.allocator) catch @panic("OOM");
}

fn linkMacosSourceDependencies(module: *std.Build.Module) void {
    // SDL's CMake target carries these transitive dependencies, but a Zig consumer linking the
    // produced static archives does not inherit CMake's INTERFACE_LINK_LIBRARIES metadata.
    // Keep the same Apple runtime/framework surface on the Zig module boundary.
    module.linkSystemLibrary("objc", .{});
    for ([_][]const u8{
        "AudioToolbox",
        "AVFoundation",
        "Carbon",
        "Cocoa",
        "CoreAudio",
        "CoreBluetooth",
        "CoreFoundation",
        "CoreGraphics",
        "CoreHaptics",
        "CoreMedia",
        "CoreMotion",
        "CoreVideo",
        "ForceFeedback",
        "Foundation",
        "GameController",
        "IOKit",
        "Metal",
        "OpenGLES",
        "QuartzCore",
        "UniformTypeIdentifiers",
    }) |framework| module.linkFramework(framework, .{});
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const link_sdl = b.option(
        bool,
        "link_sdl",
        "Propagate a system SDL3 link dependency through the sdl module",
    ) orelse false;
    const link_test = b.option(
        bool,
        "link_test",
        "Propagate an SDL3_test link dependency through the test module",
    ) orelse false;
    const link_controller_image = b.option(
        bool,
        "link_controller_image",
        "Propagate a ControllerImage link dependency through the controller_image module",
    ) orelse false;
    const link_shadercross = b.option(
        bool,
        "link_shadercross",
        "Propagate an SDL_shadercross link dependency through the shadercross module",
    ) orelse false;
    const link_image = b.option(
        bool,
        "link_image",
        "Propagate a system SDL3_image link dependency through the image module",
    ) orelse false;
    const link_ttf = b.option(
        bool,
        "link_ttf",
        "Propagate a system SDL3_ttf link dependency through the ttf module",
    ) orelse false;
    const link_mixer = b.option(
        bool,
        "link_mixer",
        "Propagate a system SDL3_mixer link dependency through the mixer module",
    ) orelse false;
    const link_net = b.option(
        bool,
        "link_net",
        "Propagate a system SDL3_net link dependency through the net module",
    ) orelse false;
    const system_version_overrides = b.option(
        []const []const u8,
        "system_version_overrides",
        "Component=version overrides for system SDL libraries",
    ) orelse &.{};
    const allow_unknown_system_versions = b.option(
        bool,
        "allow_unknown_system_versions",
        "Allow system SDL libraries without discoverable pkg-config versions",
    ) orelse false;
    const effective_link_sdl = link_sdl or link_test or link_controller_image or link_shadercross or link_image or link_ttf or link_mixer or link_net;
    const distribution = b.option(
        Distribution,
        "distribution",
        "SDL library distribution: none, system, prebuilt, or source",
    ) orelse .none;
    const optional_codecs = b.option(
        bool,
        "optional_codecs",
        "Install and link the official SDL_image and SDL_mixer codec dependencies",
    ) orelse false;
    const linkage = b.option(Linkage, "linkage", "SDL library linkage") orelse .shared;
    const source_cmake_generator = b.option([]const u8, "source_cmake_generator", "CMake generator") orelse null;
    const source_cmake_toolchain = b.option([]const u8, "source_cmake_toolchain", "CMake toolchain file") orelse null;
    const emscripten_sysroot = b.option(
        []const u8,
        "emscripten_sysroot",
        "Emscripten sysroot containing libc headers for wasm32-emscripten",
    ) orelse null;
    const android_ndk_root = b.option(
        []const u8,
        "android_ndk_root",
        "Android NDK root containing the sysroot for Android targets",
    ) orelse null;
    const source_feature_profile = b.option(
        SourceFeatureProfile,
        "source_feature_profile",
        "Source SDL core feature profile: headless or desktop",
    ) orelse .headless;
    const source_audio = b.option(bool, "source_audio", "Enable SDL audio in source builds");
    const source_video = b.option(bool, "source_video", "Enable SDL video in source builds");
    const source_gpu = b.option(bool, "source_gpu", "Enable SDL GPU in source builds");
    const source_renderer = b.option(bool, "source_renderer", "Enable SDL renderer in source builds");
    const source_camera = b.option(bool, "source_camera", "Enable SDL camera in source builds");
    const source_cmake_options = b.option(
        []const []const u8,
        "source_cmake_options",
        "Additional arguments passed to each upstream CMake configure step",
    ) orelse &.{};
    const source_mixer_cmake_options = b.option(
        []const []const u8,
        "source_mixer_cmake_options",
        "Additional arguments passed only to the SDL3_mixer CMake configure step",
    ) orelse &.{};
    const shadercross_dxc = b.option(
        ShadercrossDxc,
        "shadercross_dxc",
        "SDL_shadercross DXC mode: disabled, bundled, external, or source",
    ) orelse .disabled;
    const shadercross_dxc_root = b.option(
        []const u8,
        "shadercross_dxc_root",
        "Root containing an externally supplied DirectXShaderCompiler runtime",
    ) orelse null;
    const enable_image = b.option(
        bool,
        "enable_image",
        "Expose SDL_image through the sdl3 façade",
    ) orelse false;
    const enable_test = b.option(
        bool,
        "enable_test",
        "Expose SDL3_test through the sdl3 façade",
    ) orelse false;
    const enable_controller_image = b.option(
        bool,
        "enable_controller_image",
        "Expose ControllerImage through the sdl3 façade",
    ) orelse false;
    const enable_shadercross = b.option(
        bool,
        "enable_shadercross",
        "Expose SDL_shadercross through the sdl3 façade",
    ) orelse false;
    const enable_ttf = b.option(
        bool,
        "enable_ttf",
        "Expose SDL_ttf through the sdl3 façade",
    ) orelse false;
    const enable_mixer = b.option(
        bool,
        "enable_mixer",
        "Expose SDL_mixer through the sdl3 façade",
    ) orelse false;
    const enable_net = b.option(
        bool,
        "enable_net",
        "Expose SDL_net through the sdl3 façade",
    ) orelse false;
    const support = b.createModule(.{
        .root_source_file = b.path("src/support.zig"),
        .target = target,
        .optimize = optimize,
    });

    const link_options = LinkOptions{
        .sdl = effective_link_sdl,
        .test_ = link_test,
        .controller_image = link_controller_image,
        .shadercross = link_shadercross,
        .image = link_image,
        .ttf = link_ttf,
        .mixer = link_mixer,
        .net = link_net,
        .system_version_overrides = system_version_overrides,
        .allow_unknown_system_versions = allow_unknown_system_versions,
    };
    const source_build = if (distribution == .source)
        addCmakeSourceBuild(
            b,
            target,
            link_options,
            linkage,
            source_cmake_generator,
            source_cmake_toolchain,
            .{
                .profile = source_feature_profile,
                .audio = source_audio,
                .video = source_video,
                .gpu = source_gpu,
                .renderer = source_renderer,
                .camera = source_camera,
            },
            source_cmake_options,
            source_mixer_cmake_options,
            shadercross_dxc,
            shadercross_dxc_root,
        )
    else
        null;
    const library_modules = addLibraryModules(
        b,
        target,
        optimize,
        support,
        distribution,
        link_options,
        linkage,
        emscripten_sysroot,
        android_ndk_root,
        &sdl_metadata.libraries,
        source_build,
    );
    const sdl = findLibraryModule(library_modules, "sdl");
    const image = findLibraryModule(library_modules, "image");
    const controller_image = findLibraryModule(library_modules, "controller_image");
    const shadercross = findLibraryModule(library_modules, "shadercross");
    const ttf = findLibraryModule(library_modules, "ttf");
    const mixer = findLibraryModule(library_modules, "mixer");
    const net = findLibraryModule(library_modules, "net");
    const facade_options_files = b.addWriteFiles();
    const facade_options = b.createModule(.{
        .root_source_file = facade_options_files.add("sdl3_options.zig", b.fmt(
            "pub const test_ = {};\npub const controller_image = {};\npub const shadercross = {};\npub const image = {};\npub const ttf = {};\npub const mixer = {};\npub const net = {};\n",
            .{ enable_test, enable_controller_image, enable_shadercross, enable_image, enable_ttf, enable_mixer, enable_net },
        )),
        .target = target,
        .optimize = optimize,
    });
    var facade_imports: std.ArrayList(std.Build.Module.Import) = .empty;
    facade_imports.append(b.allocator, .{ .name = "sdl", .module = sdl }) catch @panic("OOM");
    facade_imports.append(b.allocator, .{ .name = "sdl3_options", .module = facade_options }) catch @panic("OOM");
    const test_module = findLibraryModule(library_modules, "test");
    if (enable_test) {
        facade_imports.append(b.allocator, .{ .name = "test", .module = test_module }) catch @panic("OOM");
    }
    if (enable_controller_image) {
        facade_imports.append(b.allocator, .{ .name = "controller_image", .module = controller_image }) catch @panic("OOM");
    }
    if (enable_shadercross) {
        facade_imports.append(b.allocator, .{ .name = "shadercross", .module = shadercross }) catch @panic("OOM");
    }
    if (enable_image) {
        facade_imports.append(b.allocator, .{ .name = "image", .module = image }) catch @panic("OOM");
    }
    if (enable_ttf) {
        facade_imports.append(b.allocator, .{ .name = "ttf", .module = ttf }) catch @panic("OOM");
    }
    if (enable_mixer) {
        facade_imports.append(b.allocator, .{ .name = "mixer", .module = mixer }) catch @panic("OOM");
    }
    if (enable_net) {
        facade_imports.append(b.allocator, .{ .name = "net", .module = net }) catch @panic("OOM");
    }
    _ = b.addModule("sdl3", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = facade_imports.items,
    });

    if (distribution == .prebuilt) {
        configurePrebuilt(b, target, linkage, .{
            .sdl = if (effective_link_sdl) sdl else null,
            .test_ = if (link_test) test_module else null,
            .controller_image = if (link_controller_image) controller_image else null,
            .shadercross = if (link_shadercross) shadercross else null,
            .image = if (link_image) image else null,
            .ttf = if (link_ttf) ttf else null,
            .mixer = if (link_mixer) mixer else null,
            .net = if (link_net) net else null,
            .optional_codecs = optional_codecs,
        });
    }

    addMaintenanceProxy(b, "docs");
    addMaintenanceProxy(b, "examples");
    addMaintenanceProxy(b, "examples-sdl");
    addMaintenanceProxy(b, "examples-raylib");
    addMaintenanceProxy(b, "example");
    for (maintenance_steps.names) |name| {
        addMaintenanceProxy(b, name);
        addMaintenanceProxy(b, b.fmt("run-{s}", .{name}));
    }
}

fn addMaintenanceProxy(b: *std.Build, name: []const u8) void {
    const step = b.step(name, b.fmt("Run repository maintenance step {s}", .{name}));
    const command = b.addSystemCommand(&.{ "zig", "build", "--build-file", "build-maintenance.zig", name });
    command.setCwd(b.path("."));
    step.dependOn(&command.step);
}

fn addCmakeSourceBuild(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    link_options: LinkOptions,
    linkage: Linkage,
    generator: ?[]const u8,
    toolchain: ?[]const u8,
    source_features: SourceFeatureOptions,
    extra_options: []const []const u8,
    mixer_options: []const []const u8,
    shadercross_dxc: ShadercrossDxc,
    shadercross_dxc_root: ?[]const u8,
) SourceBuild {
    const shared = linkage == .shared;
    const shared_value = if (shared) "ON" else "OFF";
    const static_value = if (shared) "OFF" else "ON";
    const shadercross_uses_external_dxc = shadercross_dxc == .bundled or shadercross_dxc == .external;
    const dxc_runtime_selected = link_options.shadercross and shadercross_uses_external_dxc;
    if (dxc_runtime_selected) validateShadercrossDxcTarget(target);
    const package_root = b.build_root.path orelse ".";
    const prefix = b.cache_root.join(b.allocator, &.{"sdl3-source"}) catch @panic("OOM");
    var runtime_directory_path: ?[]const u8 = null;
    if (linkage == .shared or dxc_runtime_selected) {
        const runtime_directory = b.cache_root.join(
            b.allocator,
            &.{"sdl3-source-runtimes"},
        ) catch @panic("OOM");
        runtime_directory_path = runtime_directory;
        b.addNamedLazyPath(
            "source-runtime-directory",
            .{ .cwd_relative = runtime_directory },
        );
    }
    if (link_options.controller_image) {
        const data_directory = b.cache_root.join(
            b.allocator,
            &.{"sdl3-source-controllerimage-data"},
        ) catch @panic("OOM");
        b.addNamedLazyPath(
            "source-controller-image-data-directory",
            .{ .cwd_relative = data_directory },
        );
        b.addNamedLazyPath(
            "source-controller-image-data",
            .{ .cwd_relative = b.fmt("{s}/controllerimage-standard.bin", .{data_directory}) },
        );
    }
    var previous: ?*std.Build.Step = null;
    for ([_][]const u8{ "SDL3", "ControllerImage", "SDL3_shadercross", "SDL3_image", "SDL3_ttf", "SDL3_mixer", "SDL3_net" }) |component| {
        const selected = if (std.mem.eql(u8, component, "SDL3")) link_options.sdl else if (std.mem.eql(u8, component, "ControllerImage")) link_options.controller_image else if (std.mem.eql(u8, component, "SDL3_shadercross")) link_options.shadercross else if (std.mem.eql(u8, component, "SDL3_image")) link_options.image else if (std.mem.eql(u8, component, "SDL3_ttf")) link_options.ttf else if (std.mem.eql(u8, component, "SDL3_mixer")) link_options.mixer else link_options.net;
        if (!selected) continue;
        const component_build_name = if (std.mem.eql(u8, component, "SDL3_shadercross") and
            shadercross_uses_external_dxc)
            b.fmt("{s}-{s}", .{ component, @tagName(shadercross_dxc) })
        else
            component;
        const component_build = b.cache_root.join(
            b.allocator,
            &.{ "sdl3-source-build", component_build_name },
        ) catch @panic("OOM");
        var source_path = std.fs.path.join(b.allocator, &.{ package_root, "vendor", component }) catch @panic("OOM");
        var shadercross_runtime: ?*std.Build.Step = null;
        var source_runtime_stage: ?struct {
            source: []const u8,
            destination: []const u8,
        } = null;
        if (std.mem.eql(u8, component, "SDL3_shadercross") and shadercross_uses_external_dxc) {
            const staged_source = b.cache_root.join(
                b.allocator,
                &.{ "sdl3-source-build", "SDL3_shadercross-source" },
            ) catch @panic("OOM");
            const stage_source = b.addSystemCommand(&.{ "cmake", "-E", "copy_directory", source_path, staged_source });
            if (previous) |step| stage_source.step.dependOn(step);
            source_path = staged_source;
            if (shadercross_dxc == .bundled) {
                const system_name = switch (target.result.os.tag) {
                    .linux => "Linux",
                    .windows => "Windows",
                    else => @panic("shadercross_dxc=bundled is available only for Linux and Windows"),
                };
                const download = b.addSystemCommand(&.{
                    "cmake",
                    b.fmt("-DCMAKE_SYSTEM_NAME={s}", .{system_name}),
                    "-P",
                    b.pathJoin(&.{ source_path, "build-scripts", "download-prebuilt-DirectXShaderCompiler.cmake" }),
                });
                download.step.dependOn(&stage_source.step);
                shadercross_runtime = &download.step;
            } else {
                const dxc_root = shadercross_dxc_root orelse
                    @panic("shadercross_dxc=external requires -Dshadercross_dxc_root=<path>");
                const stage_runtime = b.addSystemCommand(&.{
                    "cmake",
                    "-E",
                    "copy_directory",
                    dxc_root,
                    b.pathJoin(&.{ source_path, "external", "DirectXShaderCompiler-binaries" }),
                });
                stage_runtime.step.dependOn(&stage_source.step);
                shadercross_runtime = &stage_runtime.step;
            }
        }
        if (linkage == .shared and sourceRuntimeSelected(component, link_options)) {
            const library_name = sourceRuntimeLibraryName(component);
            const runtime_directory = if (target.result.os.tag == .windows) "bin" else "lib";
            const source_runtime_filename = if (target.result.os.tag == .windows)
                b.fmt("{s}.dll", .{library_name})
            else if (target.result.os.tag == .macos)
                b.fmt("lib{s}.dylib", .{library_name})
            else
                b.fmt("lib{s}.so", .{library_name});
            const runtime_filename = if (target.result.os.tag == .windows)
                source_runtime_filename
            else if (target.result.os.tag == .macos)
                b.fmt("lib{s}.dylib", .{library_name})
            else
                b.fmt("lib{s}.so.0", .{library_name});
            const source_runtime_path = b.fmt("{s}/{s}/{s}", .{ prefix, runtime_directory, source_runtime_filename });
            const staged_runtime_path = b.cache_root.join(
                b.allocator,
                &.{ "sdl3-source-runtimes", runtime_filename },
            ) catch @panic("OOM");
            source_runtime_stage = .{
                .source = source_runtime_path,
                .destination = staged_runtime_path,
            };
            b.addNamedLazyPath(
                b.fmt("source-runtime-{s}", .{sourceRuntimeKey(component)}),
                .{ .cwd_relative = staged_runtime_path },
            );
        }
        if (std.mem.eql(u8, component, "SDL3_shadercross") and shadercross_uses_external_dxc) {
            const spirv_cross_source = std.fs.path.join(
                b.allocator,
                &.{ source_path, "external", "SPIRV-Cross" },
            ) catch @panic("OOM");
            const spirv_cross_build = b.cache_root.join(
                b.allocator,
                &.{ "sdl3-source-build", b.fmt("SPIRV-Cross-{s}", .{@tagName(shadercross_dxc)}) },
            ) catch @panic("OOM");
            const configure_spirv_cross = b.addSystemCommand(&.{
                "cmake",
                "-S",
                spirv_cross_source,
                "-B",
                spirv_cross_build,
                b.fmt("-DCMAKE_INSTALL_PREFIX={s}", .{prefix}),
                "-DSPIRV_CROSS_SHARED=OFF",
                "-DSPIRV_CROSS_STATIC=ON",
                "-DSPIRV_CROSS_CLI=OFF",
                "-DSPIRV_CROSS_ENABLE_TESTS=OFF",
            });
            configure_spirv_cross.addArg("-DCMAKE_INSTALL_LIBDIR=lib");
            if (generator) |value| configure_spirv_cross.addArgs(&.{ "-G", value });
            if (toolchain) |value| configure_spirv_cross.addArg(b.fmt("-DCMAKE_TOOLCHAIN_FILE={s}", .{value}));
            configure_spirv_cross.addArgs(extra_options);
            if (previous) |step| configure_spirv_cross.step.dependOn(step);
            if (shadercross_runtime) |step| configure_spirv_cross.step.dependOn(step);
            const install_spirv_cross = b.addSystemCommand(
                &.{ "cmake", "--build", spirv_cross_build, "--target", "install" },
            );
            install_spirv_cross.step.dependOn(&configure_spirv_cross.step);
            previous = &install_spirv_cross.step;
        }
        const configure = b.addSystemCommand(&.{ "cmake", "-S", source_path, "-B", component_build, b.fmt("-DCMAKE_INSTALL_PREFIX={s}", .{prefix}) });
        configure.addArg(b.fmt("-DCMAKE_PREFIX_PATH={s}", .{prefix}));
        configure.addArg(b.fmt("-DBUILD_SHARED_LIBS={s}", .{shared_value}));
        configure.addArg("-DCMAKE_INSTALL_LIBDIR=lib");
        addCmakeComponentOptions(
            b,
            configure,
            component,
            shared_value,
            static_value,
            link_options.test_,
            target,
            shadercross_dxc,
            source_features,
        );
        if (generator) |value| configure.addArgs(&.{ "-G", value });
        if (toolchain) |value| configure.addArg(b.fmt("-DCMAKE_TOOLCHAIN_FILE={s}", .{value}));
        configure.addArgs(extra_options);
        if (std.mem.eql(u8, component, "SDL3_mixer")) configure.addArgs(mixer_options);
        if (previous) |step| configure.step.dependOn(step);
        if (shadercross_runtime) |step| configure.step.dependOn(step);
        const install = b.addSystemCommand(if (std.mem.eql(u8, component, "ControllerImage"))
            &.{ "cmake", "--build", component_build, "--target", "controllerimage", "make-controllerimage-data" }
        else
            &.{ "cmake", "--build", component_build, "--target", "install" });
        install.step.dependOn(&configure.step);
        var component_last_step: ?*std.Build.Step = null;
        if (source_runtime_stage) |stage| {
            const runtime_directory = std.fs.path.dirname(stage.destination) orelse @panic("source runtime has no parent directory");
            const make_runtime_directory = b.addSystemCommand(&.{ "cmake", "-E", "make_directory", runtime_directory });
            const stage_runtime = b.addSystemCommand(&.{ "cmake", "-E", "copy", stage.source, stage.destination });
            stage_runtime.step.dependOn(&install.step);
            stage_runtime.step.dependOn(&make_runtime_directory.step);
            component_last_step = &stage_runtime.step;
        }
        if (dxc_runtime_selected and std.mem.eql(u8, component, "SDL3_shadercross")) {
            const runtime_directory = b.cache_root.join(
                b.allocator,
                &.{"sdl3-source-runtimes"},
            ) catch @panic("OOM");
            const make_runtime_directory = b.addSystemCommand(&.{ "cmake", "-E", "make_directory", runtime_directory });
            const dxc_root = b.pathJoin(&.{ source_path, "external", "DirectXShaderCompiler-binaries" });
            const dxc_files = [_]struct {
                name: []const u8,
                source_subpath: []const u8,
                artifact_key: []const u8,
            }{
                .{ .name = dxcRuntimeName(target, .dxcompiler), .source_subpath = dxcRuntimeSourceSubpath(target, .dxcompiler, shadercross_dxc), .artifact_key = "dxc_dxcompiler" },
                .{ .name = dxcRuntimeName(target, .dxil), .source_subpath = dxcRuntimeSourceSubpath(target, .dxil, shadercross_dxc), .artifact_key = "dxc_dxil" },
            };
            for (dxc_files) |file| {
                const source = b.pathJoin(&.{ dxc_root, file.source_subpath });
                const destination = b.pathJoin(&.{ runtime_directory, file.name });
                const stage_runtime = b.addSystemCommand(&.{ "cmake", "-E", "copy", source, destination });
                stage_runtime.step.dependOn(&install.step);
                if (shadercross_runtime) |step| stage_runtime.step.dependOn(step);
                stage_runtime.step.dependOn(&make_runtime_directory.step);
                if (component_last_step) |step| stage_runtime.step.dependOn(step);
                component_last_step = &stage_runtime.step;
                b.addNamedLazyPath(
                    b.fmt("source-runtime-{s}", .{file.artifact_key}),
                    .{ .cwd_relative = destination },
                );
            }
        }
        if (component_last_step) |step| {
            previous = step;
        } else if (std.mem.eql(u8, component, "ControllerImage")) {
            const data_directory = b.cache_root.join(
                b.allocator,
                &.{"sdl3-source-controllerimage-data"},
            ) catch @panic("OOM");
            const make_data_directory = b.addSystemCommand(&.{ "cmake", "-E", "make_directory", data_directory });
            const generator_name = if (target.result.os.tag == .windows) "make-controllerimage-data.exe" else "make-controllerimage-data";
            const command_cwd = std.Io.Dir.cwd().realPathFileAlloc(b.graph.io, ".", b.allocator) catch
                @panic("unable to resolve source build working directory");
            const generator_path = if (std.fs.path.isAbsolute(component_build))
                b.pathJoin(&.{ component_build, generator_name })
            else
                std.fs.path.join(b.allocator, &.{ command_cwd, component_build, generator_name }) catch @panic("OOM");
            const absolute_data_directory = if (std.fs.path.isAbsolute(data_directory))
                data_directory
            else
                std.fs.path.join(b.allocator, &.{ command_cwd, data_directory }) catch @panic("OOM");
            const generate_data = b.addSystemCommand(&.{
                "cmake",
                "-E",
                "chdir",
                absolute_data_directory,
                generator_path,
            });
            generate_data.addDirectoryArg(b.path("vendor/ControllerImage/art"));
            generate_data.step.dependOn(&install.step);
            generate_data.step.dependOn(&make_data_directory.step);
            previous = &generate_data.step;
        } else {
            previous = &install.step;
        }
    }
    return .{
        .prefix = prefix,
        .step = previous.?,
        .linkage = linkage,
        .shadercross_dxc = shadercross_dxc,
        .runtime_directory = runtime_directory_path,
    };
}

fn installRepositorySourceRuntime(
    b: *std.Build,
    source: SourceBuild,
    target: std.Build.ResolvedTarget,
) void {
    const runtime_directory = source.runtime_directory orelse return;
    const install = b.addInstallDirectory(.{
        .source_dir = .{ .cwd_relative = runtime_directory },
        .install_dir = .prefix,
        .install_subdir = if (target.result.os.tag == .windows) "bin" else "lib",
    });
    install.step.dependOn(source.step);
    b.getInstallStep().dependOn(&install.step);
}

const DxcRuntime = enum { dxcompiler, dxil };

fn validateShadercrossDxcTarget(target: std.Build.ResolvedTarget) void {
    switch (target.result.os.tag) {
        .linux => if (target.result.cpu.arch != .x86_64) {
            @panic("bundled or external shadercross DXC supports only x86_64 Linux targets");
        },
        .windows => switch (target.result.cpu.arch) {
            .x86, .x86_64, .aarch64 => {},
            else => @panic("bundled or external shadercross DXC supports only x86, x86_64, or aarch64 Windows targets"),
        },
        else => @panic("bundled or external shadercross DXC supports only Linux and Windows targets"),
    }
}

fn dxcLibrarySubdirectory(target: std.Build.ResolvedTarget, mode: ShadercrossDxc) []const u8 {
    return switch (target.result.os.tag) {
        .linux => if (mode == .bundled) "linux/lib" else "lib",
        .windows => switch (target.result.cpu.arch) {
            .x86 => if (mode == .bundled) "windows/lib/x86" else "lib/x86",
            .x86_64 => if (mode == .bundled) "windows/lib/x64" else "lib/x64",
            .aarch64 => if (mode == .bundled) "windows/lib/arm64" else "lib/arm64",
            else => @panic("shadercross DXC has no Windows runtime for this architecture"),
        },
        else => @panic("shadercross DXC has no runtime library directory for this target"),
    };
}

fn dxcRuntimeName(target: std.Build.ResolvedTarget, runtime: DxcRuntime) []const u8 {
    return switch (runtime) {
        .dxcompiler => if (target.result.os.tag == .windows) "dxcompiler.dll" else "libdxcompiler.so",
        .dxil => if (target.result.os.tag == .windows) "dxil.dll" else "libdxil.so",
    };
}

fn dxcRuntimeSourceSubpath(
    target: std.Build.ResolvedTarget,
    runtime: DxcRuntime,
    mode: ShadercrossDxc,
) []const u8 {
    if (target.result.os.tag == .linux) {
        return switch (runtime) {
            .dxcompiler => if (mode == .bundled) "linux/lib/libdxcompiler.so" else "lib/libdxcompiler.so",
            .dxil => if (mode == .bundled) "linux/lib/libdxil.so" else "lib/libdxil.so",
        };
    }
    return switch (target.result.cpu.arch) {
        .x86 => switch (runtime) {
            .dxcompiler => if (mode == .bundled) "windows/bin/x86/dxcompiler.dll" else "bin/x86/dxcompiler.dll",
            .dxil => if (mode == .bundled) "windows/bin/x86/dxil.dll" else "bin/x86/dxil.dll",
        },
        .x86_64 => switch (runtime) {
            .dxcompiler => if (mode == .bundled) "windows/bin/x64/dxcompiler.dll" else "bin/x64/dxcompiler.dll",
            .dxil => if (mode == .bundled) "windows/bin/x64/dxil.dll" else "bin/x64/dxil.dll",
        },
        .aarch64 => switch (runtime) {
            .dxcompiler => if (mode == .bundled) "windows/bin/arm64/dxcompiler.dll" else "bin/arm64/dxcompiler.dll",
            .dxil => if (mode == .bundled) "windows/bin/arm64/dxil.dll" else "bin/arm64/dxil.dll",
        },
        else => @panic("shadercross DXC has no Windows runtime for this architecture"),
    };
}

fn sourceRuntimeKey(component: []const u8) []const u8 {
    if (std.mem.eql(u8, component, "SDL3")) return "sdl";
    if (std.mem.eql(u8, component, "SDL3_shadercross")) return "shadercross";
    if (std.mem.eql(u8, component, "SDL3_image")) return "image";
    if (std.mem.eql(u8, component, "SDL3_ttf")) return "ttf";
    if (std.mem.eql(u8, component, "SDL3_mixer")) return "mixer";
    if (std.mem.eql(u8, component, "SDL3_net")) return "net";
    std.debug.panic("unsupported SDL source runtime component '{s}'", .{component});
}

fn sourceRuntimeLibraryName(component: []const u8) []const u8 {
    if (std.mem.eql(u8, component, "SDL3")) return "SDL3";
    if (std.mem.eql(u8, component, "SDL3_shadercross")) return "SDL3_shadercross";
    if (std.mem.eql(u8, component, "SDL3_image")) return "SDL3_image";
    if (std.mem.eql(u8, component, "SDL3_ttf")) return "SDL3_ttf";
    if (std.mem.eql(u8, component, "SDL3_mixer")) return "SDL3_mixer";
    if (std.mem.eql(u8, component, "SDL3_net")) return "SDL3_net";
    std.debug.panic("unsupported SDL source runtime component '{s}'", .{component});
}

fn sourceRuntimeSelected(component: []const u8, link_options: LinkOptions) bool {
    if (std.mem.eql(u8, component, "SDL3")) return link_options.sdl;
    if (std.mem.eql(u8, component, "SDL3_shadercross")) return link_options.shadercross;
    if (std.mem.eql(u8, component, "SDL3_image")) return link_options.image;
    if (std.mem.eql(u8, component, "SDL3_ttf")) return link_options.ttf;
    if (std.mem.eql(u8, component, "SDL3_mixer")) return link_options.mixer;
    if (std.mem.eql(u8, component, "SDL3_net")) return link_options.net;
    return false;
}

fn installSourceRuntime(
    b: *std.Build,
    dependency: *std.Build.Dependency,
    target: std.Build.ResolvedTarget,
) void {
    const install = b.addInstallDirectory(.{
        .source_dir = dependency.namedLazyPath("source-runtime-directory"),
        .install_dir = .prefix,
        .install_subdir = if (target.result.os.tag == .windows) "bin" else "lib",
    });
    install.step.dependOn(dependency.builder.getInstallStep());
    b.getInstallStep().dependOn(&install.step);
}

fn installSourceControllerImageData(
    b: *std.Build,
    dependency: *std.Build.Dependency,
) void {
    const install = b.addInstallDirectory(.{
        .source_dir = dependency.namedLazyPath("source-controller-image-data-directory"),
        .install_dir = .prefix,
        .install_subdir = "share/ControllerImage",
    });
    install.step.dependOn(dependency.builder.getInstallStep());
    b.getInstallStep().dependOn(&install.step);
}

fn sourceLibraryName(
    b: *std.Build,
    library_name: []const u8,
    target: std.Build.ResolvedTarget,
    linkage: Linkage,
) []const u8 {
    if (linkage == .static and target.result.os.tag == .windows and
        std.mem.startsWith(u8, library_name, "SDL3") and
        !std.mem.eql(u8, library_name, "SDL3_test"))
    {
        return b.fmt("{s}-static", .{library_name});
    }
    return library_name;
}

fn addCmakeComponentOptions(
    b: *std.Build,
    configure: *std.Build.Step.Run,
    component: []const u8,
    shared_value: []const u8,
    static_value: []const u8,
    build_test: bool,
    target: std.Build.ResolvedTarget,
    shadercross_dxc: ShadercrossDxc,
    source_features: SourceFeatureOptions,
) void {
    if (std.mem.eql(u8, component, "SDL3")) {
        configure.addArg("-DSDL_TESTS=OFF");
        configure.addArg("-DSDL_EXAMPLES=OFF");
        configure.addArgs(&.{
            b.fmt("-DSDL_AUDIO={s}", .{if (source_features.enabled(.audio)) "ON" else "OFF"}),
            b.fmt("-DSDL_VIDEO={s}", .{if (source_features.enabled(.video)) "ON" else "OFF"}),
            b.fmt("-DSDL_GPU={s}", .{if (source_features.enabled(.gpu)) "ON" else "OFF"}),
            b.fmt("-DSDL_RENDER={s}", .{if (source_features.enabled(.renderer)) "ON" else "OFF"}),
            b.fmt("-DSDL_CAMERA={s}", .{if (source_features.enabled(.camera)) "ON" else "OFF"}),
        });
        configure.addArg("-DSDL_UNIX_CONSOLE_BUILD=ON");
        configure.addArg(b.fmt("-DSDL_TEST_LIBRARY={s}", .{if (build_test) "ON" else "OFF"}));
        configure.addArg(b.fmt("-DSDL_SHARED={s}", .{shared_value}));
        configure.addArg(b.fmt("-DSDL_STATIC={s}", .{static_value}));
        return;
    }
    if (std.mem.eql(u8, component, "SDL3_image")) {
        configure.addArg("-DSDLIMAGE_INSTALL=ON");
        configure.addArg("-DSDLIMAGE_SAMPLES=OFF");
        configure.addArg("-DSDLIMAGE_TESTS=OFF");
        configure.addArgs(&.{
            "-DSDLIMAGE_AVIF=OFF",
            "-DSDLIMAGE_JPG=OFF",
            "-DSDLIMAGE_JXL=OFF",
            "-DSDLIMAGE_PNG=OFF",
            "-DSDLIMAGE_TIF=OFF",
            "-DSDLIMAGE_WEBP=OFF",
        });
        return;
    }
    if (std.mem.eql(u8, component, "ControllerImage")) return;
    if (std.mem.eql(u8, component, "SDL3_shadercross")) {
        const use_external_dxc = shadercross_dxc == .bundled or shadercross_dxc == .external;
        configure.addArgs(&.{
            b.fmt("-DSDLSHADERCROSS_DXC={s}", .{if (shadercross_dxc == .disabled) "OFF" else "ON"}),
            b.fmt("-DSDLSHADERCROSS_VENDORED={s}", .{if (use_external_dxc) "OFF" else "ON"}),
            "-DSDLSHADERCROSS_SPIRVCROSS_SHARED=OFF",
            "-DSDLSHADERCROSS_CLI=ON",
            "-DSDLSHADERCROSS_INSTALL=ON",
            "-DSDLSHADERCROSS_INSTALL_RUNTIME=OFF",
            b.fmt("-DSDLSHADERCROSS_SHARED={s}", .{shared_value}),
            b.fmt("-DSDLSHADERCROSS_STATIC={s}", .{static_value}),
        });
        if (shadercross_dxc == .bundled and target.result.os.tag != .linux and
            target.result.os.tag != .windows) @panic("shadercross_dxc=bundled is available only for Linux and Windows");
        return;
    }
    if (std.mem.eql(u8, component, "SDL3_ttf")) {
        configure.addArgs(&.{
            "-DSDLTTF_INSTALL=ON",
            "-DSDLTTF_SAMPLES=OFF",
            "-DSDLTTF_VENDORED=ON",
            "-DSDLTTF_HARFBUZZ=OFF",
            "-DSDLTTF_PLUTOSVG=OFF",
        });
        return;
    }
    if (std.mem.eql(u8, component, "SDL3_mixer")) {
        configure.addArgs(&.{
            "-DSDLMIXER_INSTALL=ON",
            "-DSDLMIXER_TESTS=OFF",
            "-DSDLMIXER_EXAMPLES=OFF",
            "-DSDLMIXER_FLAC=OFF",
            "-DSDLMIXER_GME=OFF",
            "-DSDLMIXER_MOD=OFF",
            "-DSDLMIXER_MP3=OFF",
            "-DSDLMIXER_MP3_MPG123=OFF",
            "-DSDLMIXER_MIDI=OFF",
            "-DSDLMIXER_OPUS=OFF",
            "-DSDLMIXER_VORBIS_STB=OFF",
            "-DSDLMIXER_VORBIS_VORBISFILE=OFF",
            "-DSDLMIXER_VORBIS_TREMOR=OFF",
            "-DSDLMIXER_WAVPACK=OFF",
        });
        return;
    }
    if (std.mem.eql(u8, component, "SDL3_net")) {
        configure.addArgs(&.{ "-DSDLNET_INSTALL=ON", "-DSDLNET_SAMPLES=OFF" });
        return;
    }
    std.debug.panic("unsupported SDL CMake source component '{s}'", .{component});
}

fn addTranslateCTargetDefines(
    translate_c: *std.Build.Step.TranslateC,
    target: std.Build.ResolvedTarget,
) void {
    // Zig's C compiler defines this for the target, but `translate-c` 0.16 omits it. MinGW's
    // own malloc.h requires the marker on 32-bit Windows.
    if (target.result.os.tag == .windows and target.result.cpu.arch == .x86) {
        translate_c.defineCMacro("_X86_", null);
    }
    if (isAndroidTarget(target)) {
        // Translate SDL's public declarations with the host LP64 headers while retaining the
        // Android-only SDL_PLATFORM namespace. The actual target ABI is compiled by Zig/NDK;
        // this avoids Android NDK nullability constructs that Zig 0.16 translate-c cannot parse.
        translate_c.defineCMacro("SDL_PLATFORM_ANDROID", "1");
        // SDL_dlopennote.h disables these ELF annotation macros on Android, while the generated
        // root module keeps their numeric/string constants for the cross-platform API surface.
        translate_c.defineCMacro("SDL_ELF_NOTE_DLOPEN_TYPE", "0x407c0c0aU");
        translate_c.defineCMacro("SDL_ELF_NOTE_DLOPEN_VENDOR", "\"FDO\"");
    }
}

fn isAndroidTarget(target: std.Build.ResolvedTarget) bool {
    return target.result.abi == .android or target.result.abi == .androideabi;
}

const PrebuiltModules = struct {
    sdl: ?*std.Build.Module,
    test_: ?*std.Build.Module,
    controller_image: ?*std.Build.Module,
    shadercross: ?*std.Build.Module,
    image: ?*std.Build.Module,
    ttf: ?*std.Build.Module,
    mixer: ?*std.Build.Module,
    net: ?*std.Build.Module,
    optional_codecs: bool,
};

const PrebuiltFamily = enum {
    mingw,
    msvc,
    macos,
};

fn configurePrebuilt(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    linkage: Linkage,
    modules: PrebuiltModules,
) void {
    if (!std.mem.eql(u8, @tagName(linkage), sdl_metadata.prebuilt_linkage)) {
        std.debug.panic(
            "package-local SDL prebuilts provide shared libraries only; use linkage=.shared or distribution=.system/.source",
            .{},
        );
    }
    const policy = findPrebuiltTarget(target) orelse switch (target.result.os.tag) {
        .windows => std.debug.panic(
            "official SDL prebuilts do not support {s}-windows-{s}",
            .{ @tagName(target.result.cpu.arch), @tagName(target.result.abi) },
        ),
        .macos => std.debug.panic(
            "official SDL prebuilts do not support {s}-macos",
            .{@tagName(target.result.cpu.arch)},
        ),
        .linux => std.debug.panic("package-local SDL prebuilts do not support Linux", .{}),
        else => std.debug.panic(
            "package-local SDL prebuilts are not available for {s}; use distribution=.system or .none",
            .{@tagName(target.result.os.tag)},
        ),
    };
    const family: PrebuiltFamily = if (std.mem.eql(u8, policy.family, "mingw"))
        .mingw
    else if (std.mem.eql(u8, policy.family, "msvc"))
        .msvc
    else if (std.mem.eql(u8, policy.family, "macos"))
        .macos
    else
        std.debug.panic("unknown prebuilt family in distribution policy: {s}", .{policy.family});

    const sdl_library = sdl_metadata.byKey("sdl");
    const test_library = sdl_metadata.byKey("test");
    const controller_image_library = sdl_metadata.byKey("controller_image");
    const shadercross_library = sdl_metadata.byKey("shadercross");
    const image_library = sdl_metadata.byKey("image");
    const ttf_library = sdl_metadata.byKey("ttf");
    const mixer_library = sdl_metadata.byKey("mixer");
    const net_library = sdl_metadata.byKey("net");
    const selections = [_]struct {
        library: *const sdl_metadata.Library,
        module: ?*std.Build.Module,
    }{
        .{ .library = sdl_library, .module = modules.sdl },
        .{ .library = test_library, .module = modules.test_ },
        .{ .library = controller_image_library, .module = modules.controller_image },
        .{ .library = shadercross_library, .module = modules.shadercross },
        .{ .library = image_library, .module = modules.image },
        .{ .library = ttf_library, .module = modules.ttf },
        .{ .library = mixer_library, .module = modules.mixer },
        .{ .library = net_library, .module = modules.net },
    };
    for (selections) |selection| {
        const module = selection.module orelse continue;
        if (!selection.library.prebuilt) {
            std.debug.panic(
                "{s} has no package-local prebuilt; use distribution=.system, .source, or .none",
                .{selection.library.id},
            );
        }
        switch (family) {
            .mingw => {
                const library_root = b.fmt(
                    "prebuilt/{s}/{s}/{s}",
                    .{ selection.library.key, policy.package_family, policy.arch },
                );
                module.addObjectFile(
                    b.path(b.fmt(
                        "{s}/lib/lib{s}.dll.a",
                        .{ library_root, selection.library.library_name },
                    )),
                );
                b.addNamedLazyPath(
                    b.fmt("runtime-{s}", .{selection.library.key}),
                    b.path(b.fmt(
                        "{s}/bin/{s}.dll",
                        .{ library_root, selection.library.library_name },
                    )),
                );
            },
            .msvc => {
                const library_root = b.fmt(
                    "prebuilt/{s}/{s}/{s}",
                    .{ selection.library.key, policy.package_family, policy.arch },
                );
                module.addObjectFile(
                    b.path(b.fmt(
                        "{s}/lib/{s}.lib",
                        .{ library_root, selection.library.library_name },
                    )),
                );
                b.addNamedLazyPath(
                    b.fmt("runtime-{s}", .{selection.library.key}),
                    b.path(b.fmt(
                        "{s}/bin/{s}.dll",
                        .{ library_root, selection.library.library_name },
                    )),
                );
            },
            .macos => {
                const library_root = b.fmt("prebuilt/{s}/macos", .{selection.library.key});
                module.addFrameworkPath(b.path(b.fmt("{s}/frameworks", .{library_root})));
                module.linkFramework(selection.library.framework_name, .{});
                b.addNamedLazyPath(
                    b.fmt("runtime-{s}", .{selection.library.key}),
                    b.path(b.fmt(
                        "{s}/frameworks/{s}.framework",
                        .{ library_root, selection.library.framework_name },
                    )),
                );
                if (modules.optional_codecs and
                    selection.library.macos_optional_frameworks.len != 0)
                {
                    module.addFrameworkPath(b.path(b.fmt("{s}/optional", .{library_root})));
                }
            },
        }
        b.addNamedLazyPath(
            b.fmt("license-{s}", .{selection.library.key}),
            b.path(b.fmt("vendor/{s}/LICENSE.txt", .{selection.library.id})),
        );
        if (modules.optional_codecs and
            selection.library.windows_optional_runtime != null and
            (family == .mingw or family == .msvc))
        {
            const optional = selection.library.windows_optional_runtime.?;
            const architectures = if (family == .mingw)
                optional.mingw_architectures
            else
                optional.msvc_architectures;
            if (!containsString(architectures, @tagName(target.result.cpu.arch))) {
                std.debug.panic(
                    "optional codecs for {s} do not support {s}-{s}",
                    .{
                        selection.library.id,
                        @tagName(target.result.cpu.arch),
                        if (family == .mingw) "windows-gnu" else "windows-msvc",
                    },
                );
            }
            b.addNamedLazyPath(
                b.fmt("optional-{s}", .{selection.library.key}),
                b.path(b.fmt(
                    "prebuilt/{s}/{s}/{s}/optional",
                    .{ selection.library.key, policy.package_family, policy.arch },
                )),
            );
        } else if (modules.optional_codecs and family == .macos and
            selection.library.macos_optional_frameworks.len != 0)
        {
            b.addNamedLazyPath(
                b.fmt("optional-{s}", .{selection.library.key}),
                b.path(b.fmt("prebuilt/{s}/macos/optional", .{selection.library.key})),
            );
        }
    }
}

fn containsString(values: []const []const u8, expected: []const u8) bool {
    for (values) |value| {
        if (std.mem.eql(u8, value, expected)) return true;
    }
    return false;
}

fn findPrebuiltTarget(
    target: std.Build.ResolvedTarget,
) ?*const sdl_metadata.PrebuiltTarget {
    const os = @tagName(target.result.os.tag);
    const abi = if (target.result.os.tag == .windows) @tagName(target.result.abi) else "";
    const arch = @tagName(target.result.cpu.arch);
    for (&sdl_metadata.prebuilt_targets) |*candidate| {
        if (std.mem.eql(u8, candidate.os, os) and
            std.mem.eql(u8, candidate.abi, abi) and
            std.mem.eql(u8, candidate.arch, arch))
        {
            return candidate;
        }
    }
    return null;
}

fn installRuntime(
    b: *std.Build,
    dependency: *std.Build.Dependency,
    target: std.Build.ResolvedTarget,
    options: AddOptions,
) void {
    const selections = [_]struct {
        selected: bool,
        library: *const sdl_metadata.Library,
    }{
        .{ .selected = true, .library = sdl_metadata.byKey("sdl") },
        .{ .selected = options.image, .library = sdl_metadata.byKey("image") },
        .{ .selected = options.ttf, .library = sdl_metadata.byKey("ttf") },
        .{ .selected = options.mixer, .library = sdl_metadata.byKey("mixer") },
        .{ .selected = options.net, .library = sdl_metadata.byKey("net") },
    };
    for (selections) |selection| {
        if (!selection.selected) continue;
        const runtime = dependency.namedLazyPath(b.fmt("runtime-{s}", .{selection.library.key}));
        switch (target.result.os.tag) {
            .windows => {
                const install = b.addInstallBinFile(
                    runtime,
                    b.fmt("{s}.dll", .{selection.library.library_name}),
                );
                b.getInstallStep().dependOn(&install.step);
            },
            .macos => {
                const install = b.addInstallDirectory(.{
                    .source_dir = runtime,
                    .install_dir = .lib,
                    .install_subdir = b.fmt("{s}.framework", .{selection.library.framework_name}),
                });
                b.getInstallStep().dependOn(&install.step);
            },
            else => unreachable,
        }
        const license = b.addInstallFile(
            dependency.namedLazyPath(b.fmt("license-{s}", .{selection.library.key})),
            b.fmt("share/licenses/{s}/LICENSE.txt", .{selection.library.id}),
        );
        b.getInstallStep().dependOn(&license.step);
    }

    if (!options.optional_codecs) return;
    if (options.image) installOptionalCodecs(b, dependency, target, sdl_metadata.byKey("image"));
    if (options.mixer) installOptionalCodecs(b, dependency, target, sdl_metadata.byKey("mixer"));
}

fn installOptionalCodecs(
    b: *std.Build,
    dependency: *std.Build.Dependency,
    target: std.Build.ResolvedTarget,
    library: *const sdl_metadata.Library,
) void {
    const root = dependency.namedLazyPath(b.fmt("optional-{s}", .{library.key}));
    if (target.result.os.tag == .macos) {
        for (library.macos_optional_frameworks) |name| {
            const install = b.addInstallDirectory(.{
                .source_dir = root.path(b, b.fmt("{s}.framework", .{name})),
                .install_dir = .lib,
                .install_subdir = b.fmt("{s}.framework", .{name}),
            });
            b.getInstallStep().dependOn(&install.step);
        }
        return;
    }

    const optional = library.windows_optional_runtime orelse
        std.debug.panic("{s} has no Windows optional runtime", .{library.id});
    for (optional.dlls) |name| {
        const install = b.addInstallBinFile(root.path(b, name), name);
        b.getInstallStep().dependOn(&install.step);
    }
    for (optional.licenses) |name| {
        const install = b.addInstallFile(
            root.path(b, name),
            b.fmt("share/licenses/optional/{s}/{s}", .{ library.key, name }),
        );
        b.getInstallStep().dependOn(&install.step);
    }
}
