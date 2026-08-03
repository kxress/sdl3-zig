const std = @import("std");
const sdl_metadata = @import("sdl_metadata.zig");
const example_build = @import("examples/build.zig");

pub const Distribution = enum {
    /// Select package-local prebuilts on Windows/macOS and system SDL elsewhere.
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

pub const Linkage = enum { static, shared };

/// Selects how a source SDL_shadercross build enables its optional DXC support.
pub const ShadercrossDxc = enum { disabled, bundled, external, source };

pub const AddOptions = struct {
    distribution: Distribution = .auto,
    linkage: Linkage = .shared,
    test_: bool = false,
    controller_image: bool = false,
    shadercross: bool = false,
    image: bool = false,
    ttf: bool = false,
    mixer: bool = false,
    net: bool = false,
    optional_codecs: bool = false,
    install_runtime: bool = true,
    source_cmake_generator: ?[]const u8 = null,
    source_cmake_toolchain: ?[]const u8 = null,
    source_cmake_options: []const []const u8 = &.{},
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
        .enable_test = options.test_,
        .enable_controller_image = options.controller_image,
        .enable_shadercross = options.shadercross,
        .enable_ttf = options.ttf,
        .enable_mixer = options.mixer,
        .enable_net = options.net,
        .link_sdl = true,
        .link_test = options.test_,
        .link_controller_image = options.controller_image,
        .link_shadercross = options.shadercross,
        .link_image = options.image,
        .link_ttf = options.ttf,
        .link_mixer = options.mixer,
        .link_net = options.net,
        .optional_codecs = options.optional_codecs,
        .source_cmake_generator = options.source_cmake_generator,
        .source_cmake_toolchain = options.source_cmake_toolchain,
        .source_cmake_options = options.source_cmake_options,
        .shadercross_dxc = options.shadercross_dxc,
        .shadercross_dxc_root = options.shadercross_dxc_root,
    });

    if (resolveDistribution(options.distribution, target) == .source) {
        artifact.step.dependOn(dependency.builder.getInstallStep());
    }

    artifact.root_module.addImport("sdl", dependency.module("sdl"));
    artifact.root_module.addImport("sdl3", dependency.module("sdl3"));
    if (options.image) artifact.root_module.addImport("image", dependency.module("image"));
    if (options.test_) artifact.root_module.addImport("test", dependency.module("test"));
    if (options.controller_image) artifact.root_module.addImport("controller_image", dependency.module("controller_image"));
    if (options.shadercross) artifact.root_module.addImport("shadercross", dependency.module("shadercross"));
    if (options.ttf) artifact.root_module.addImport("ttf", dependency.module("ttf"));
    if (options.mixer) artifact.root_module.addImport("mixer", dependency.module("mixer"));
    if (options.net) artifact.root_module.addImport("net", dependency.module("net"));

    if (resolveDistribution(options.distribution, target) == .prebuilt) {
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
};

const SourceBuild = struct {
    prefix: []const u8,
    step: *std.Build.Step,
    linkage: Linkage,
    shadercross_dxc: ShadercrossDxc,
};

fn findLibraryModule(library_modules: []const BuiltLibrary, module_name: []const u8) *std.Build.Module {
    for (library_modules) |library| {
        if (std.mem.eql(u8, library.configuration.module_name, module_name)) return library.module;
    }
    std.debug.panic("library configuration dependency '{s}' was not created first", .{module_name});
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

fn addLibraryModules(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    support: *std.Build.Module,
    distribution: Distribution,
    link_options: LinkOptions,
    linkage: Linkage,
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
        const translate_c = b.addTranslateC(.{
            .root_source_file = translation_unit,
            .target = target,
            .optimize = optimize,
        });
        for (sdl_metadata.translation_defines) |definition| {
            translate_c.defineCMacroRaw(definition);
        }
        addTranslateCTargetDefines(translate_c, target);
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
        if (distribution == .system and linkOptionEnabled(configuration.*, link_options)) {
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
                            if (target.result.os.tag == .windows) "windows/lib/x64" else "linux/lib",
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
    const effective_link_sdl = link_sdl or link_test or link_controller_image or link_shadercross or link_image or link_ttf or link_mixer or link_net;
    const requested_distribution: Distribution = b.option(
        Distribution,
        "distribution",
        "SDL library distribution: auto, none, system, prebuilt, or source",
    ) orelse if (effective_link_sdl or link_image or link_ttf or link_mixer or link_net)
        .system
    else
        .none;
    const distribution = resolveDistribution(requested_distribution, target);
    const optional_codecs = b.option(
        bool,
        "optional_codecs",
        "Install and link the official SDL_image and SDL_mixer codec dependencies",
    ) orelse false;
    const linkage = b.option(Linkage, "linkage", "SDL library linkage") orelse .shared;
    const source_cmake_generator = b.option([]const u8, "source_cmake_generator", "CMake generator") orelse null;
    const source_cmake_toolchain = b.option([]const u8, "source_cmake_toolchain", "CMake toolchain file") orelse null;
    const source_cmake_options = b.option(
        []const []const u8,
        "source_cmake_options",
        "Additional arguments passed to each upstream CMake configure step",
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
    };
    const source_build = if (distribution == .source)
        addCmakeSourceBuild(
            b,
            target,
            link_options,
            linkage,
            source_cmake_generator,
            source_cmake_toolchain,
            source_cmake_options,
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

    const docs_options_files = b.addWriteFiles();
    const docs_options = b.createModule(.{
        .root_source_file = docs_options_files.add(
            "sdl3_docs_options.zig",
            "pub const test_ = true;\npub const controller_image = true;\npub const shadercross = true;\npub const image = true;\npub const ttf = true;\npub const mixer = true;\npub const net = true;\n",
        ),
        .target = target,
        .optimize = optimize,
    });
    const docs = b.addObject(.{
        .name = "sdl3-docs",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "sdl", .module = sdl },
                .{ .name = "test", .module = test_module },
                .{ .name = "controller_image", .module = controller_image },
                .{ .name = "shadercross", .module = shadercross },
                .{ .name = "image", .module = image },
                .{ .name = "ttf", .module = ttf },
                .{ .name = "mixer", .module = mixer },
                .{ .name = "net", .module = net },
                .{ .name = "sdl3_options", .module = docs_options },
            },
        }),
    });
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Generate HTML documentation for every public SDL module");
    docs_step.dependOn(&install_docs.step);

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

    example_build.add(b, .{
        .target = target,
        .optimize = optimize,
        .sdl = sdl,
        .image = image,
        .ttf = ttf,
        .mixer = mixer,
    });
}

fn addCmakeSourceBuild(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    link_options: LinkOptions,
    linkage: Linkage,
    generator: ?[]const u8,
    toolchain: ?[]const u8,
    extra_options: []const []const u8,
    shadercross_dxc: ShadercrossDxc,
    shadercross_dxc_root: ?[]const u8,
) SourceBuild {
    const shared = linkage == .shared;
    const shared_value = if (shared) "ON" else "OFF";
    const static_value = if (shared) "OFF" else "ON";
    const package_root = b.build_root.path orelse ".";
    const prefix = b.cache_root.join(b.allocator, &.{"sdl3-source"}) catch @panic("OOM");
    const shadercross_uses_external_dxc = shadercross_dxc == .bundled or shadercross_dxc == .external;
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
        );
        if (generator) |value| configure.addArgs(&.{ "-G", value });
        if (toolchain) |value| configure.addArg(b.fmt("-DCMAKE_TOOLCHAIN_FILE={s}", .{value}));
        configure.addArgs(extra_options);
        if (previous) |step| configure.step.dependOn(step);
        if (shadercross_runtime) |step| configure.step.dependOn(step);
        const install = b.addSystemCommand(if (std.mem.eql(u8, component, "ControllerImage"))
            &.{ "cmake", "--build", component_build, "--target", "controllerimage", "make-controllerimage-data" }
        else
            &.{ "cmake", "--build", component_build, "--target", "install" });
        install.step.dependOn(&configure.step);
        previous = &install.step;
    }
    return .{
        .prefix = prefix,
        .step = previous.?,
        .linkage = linkage,
        .shadercross_dxc = shadercross_dxc,
    };
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
) void {
    if (std.mem.eql(u8, component, "SDL3")) {
        configure.addArg("-DSDL_TESTS=OFF");
        configure.addArg("-DSDL_EXAMPLES=OFF");
        configure.addArg("-DSDL_AUDIO=OFF");
        configure.addArg("-DSDL_VIDEO=OFF");
        configure.addArg("-DSDL_GPU=OFF");
        configure.addArg("-DSDL_RENDER=OFF");
        configure.addArg("-DSDL_CAMERA=OFF");
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
}

fn resolveDistribution(distribution: Distribution, target: std.Build.ResolvedTarget) Distribution {
    if (distribution != .auto) return distribution;
    return switch (target.result.os.tag) {
        .windows, .macos => .prebuilt,
        else => .system,
    };
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
    if (linkage != .shared) {
        std.debug.panic(
            "package-local SDL prebuilts provide shared libraries only; use linkage=.shared or distribution=.system/.source",
            .{},
        );
    }
    const family: PrebuiltFamily = switch (target.result.os.tag) {
        .windows => switch (target.result.abi) {
            .gnu => if (target.result.cpu.arch == .x86 or target.result.cpu.arch == .x86_64)
                .mingw
            else
                std.debug.panic(
                    "official SDL prebuilts do not support {s}-windows-gnu",
                    .{@tagName(target.result.cpu.arch)},
                ),
            .msvc => if (target.result.cpu.arch == .x86 or
                target.result.cpu.arch == .x86_64 or
                target.result.cpu.arch == .aarch64)
                .msvc
            else
                std.debug.panic(
                    "official SDL prebuilts do not support {s}-windows-msvc",
                    .{@tagName(target.result.cpu.arch)},
                ),
            else => std.debug.panic(
                "official SDL prebuilts do not support the Windows {s} ABI",
                .{@tagName(target.result.abi)},
            ),
        },
        .macos => if (target.result.cpu.arch == .x86_64 or target.result.cpu.arch == .aarch64)
            .macos
        else
            std.debug.panic(
                "official SDL prebuilts do not support {s}-macos",
                .{@tagName(target.result.cpu.arch)},
            ),
        .linux => std.debug.panic("package-local SDL prebuilts do not support Linux", .{}),
        else => std.debug.panic(
            "package-local SDL prebuilts are not available for {s}; use distribution=.system or .none",
            .{@tagName(target.result.os.tag)},
        ),
    };

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
                const root = b.fmt(
                    "prebuilt/{s}/windows-gnu/{s}",
                    .{ selection.library.key, @tagName(target.result.cpu.arch) },
                );
                module.addObjectFile(
                    b.path(b.fmt(
                        "{s}/lib/lib{s}.dll.a",
                        .{ root, selection.library.library_name },
                    )),
                );
                b.addNamedLazyPath(
                    b.fmt("runtime-{s}", .{selection.library.key}),
                    b.path(b.fmt(
                        "{s}/bin/{s}.dll",
                        .{ root, selection.library.library_name },
                    )),
                );
            },
            .msvc => {
                const root = b.fmt(
                    "prebuilt/{s}/windows-msvc/{s}",
                    .{ selection.library.key, @tagName(target.result.cpu.arch) },
                );
                module.addObjectFile(
                    b.path(b.fmt(
                        "{s}/lib/{s}.lib",
                        .{ root, selection.library.library_name },
                    )),
                );
                b.addNamedLazyPath(
                    b.fmt("runtime-{s}", .{selection.library.key}),
                    b.path(b.fmt(
                        "{s}/bin/{s}.dll",
                        .{ root, selection.library.library_name },
                    )),
                );
            },
            .macos => {
                const root = b.fmt("prebuilt/{s}/macos", .{selection.library.key});
                module.addFrameworkPath(b.path(b.fmt("{s}/frameworks", .{root})));
                module.linkFramework(selection.library.framework_name, .{});
                b.addNamedLazyPath(
                    b.fmt("runtime-{s}", .{selection.library.key}),
                    b.path(b.fmt(
                        "{s}/frameworks/{s}.framework",
                        .{ root, selection.library.framework_name },
                    )),
                );
                if (modules.optional_codecs and
                    selection.library.macos_optional_frameworks.len != 0)
                {
                    module.addFrameworkPath(b.path(b.fmt("{s}/optional", .{root})));
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
            const family_name = if (family == .mingw) "windows-gnu" else "windows-msvc";
            b.addNamedLazyPath(
                b.fmt("optional-{s}", .{selection.library.key}),
                b.path(b.fmt(
                    "prebuilt/{s}/{s}/{s}/optional",
                    .{ selection.library.key, family_name, @tagName(target.result.cpu.arch) },
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
