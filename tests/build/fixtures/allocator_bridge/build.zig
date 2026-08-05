const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("shim.h"),
        .target = target,
        .optimize = optimize,
    });
    translate_c.defineCMacro("SDL_DISABLE_OLD_NAMES", "1");
    translate_c.addIncludePath(b.path("."));
    translate_c.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const c_module = translate_c.createModule();
    const test_module = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl3_c", .module = c_module },
        },
    });
    const sdl_module = b.createModule(.{
        .root_source_file = b.path("../../../../src/sdl.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl3_c", .module = c_module },
            .{ .name = "sdl3_support", .module = b.createModule(.{
                .root_source_file = b.path("../../../../src/support.zig"),
                .target = target,
                .optimize = optimize,
            }) },
        },
    });
    test_module.addImport("sdl", sdl_module);
    const sdl_test_module = b.createModule(.{
        .root_source_file = b.path("../../../../src/test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl", .module = sdl_module },
            .{ .name = "sdl3_test_c", .module = c_module },
        },
    });
    test_module.addImport("sdl_test", sdl_test_module);
    const tests = b.addTest(.{ .root_module = test_module });
    tests.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    tests.root_module.addCSourceFile(.{ .file = b.path("stubs.c"), .flags = &.{} });
    tests.root_module.linkSystemLibrary("c", .{});
    b.default_step.dependOn(&b.addRunArtifact(tests).step);
    const compileCheck = b.step("compile-check", "Compile the allocator bridge fixture without running it");
    compileCheck.dependOn(&tests.step);

    const matrix_c_module = b.createModule(.{
        .root_source_file = b.path("matrix_c.zig"),
        .target = target,
        .optimize = optimize,
    });
    const matrix_module = b.createModule(.{
        .root_source_file = b.path("matrix.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sdl", .module = b.createModule(.{
                .root_source_file = b.path("../../../../src/sdl.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "sdl3_c", .module = matrix_c_module },
                    .{ .name = "sdl3_support", .module = b.createModule(.{
                        .root_source_file = b.path("../../../../src/support.zig"),
                        .target = target,
                        .optimize = optimize,
                    }) },
                },
            }) },
            .{ .name = "sdl3_c", .module = matrix_c_module },
            .{ .name = "sdl3_support", .module = b.createModule(.{
                .root_source_file = b.path("../../../../src/support.zig"),
                .target = target,
                .optimize = optimize,
            }) },
        },
    });
    const matrix = b.addObject(.{ .name = "allocator_matrix", .root_module = matrix_module });
    const matrixCheck = b.step("matrix-check", "Compile the allocator bridge for a target without a C SDK");
    matrixCheck.dependOn(&matrix.step);

    const ownership_module = b.createModule(.{
        .root_source_file = b.path("generated_ownership.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const ownership = b.addObject(.{ .name = "allocator_ownership", .root_module = ownership_module });
    const ownershipCheck = b.step(
        "ownership-check",
        "Compile the generator-driven allocator ownership inventory",
    );
    ownershipCheck.dependOn(&ownership.step);

    const preexisting_module = b.createModule(.{
        .root_source_file = b.path("preexisting.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const preexisting = b.addTest(.{ .root_module = preexisting_module });
    preexisting.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    preexisting.root_module.addCSourceFile(.{ .file = b.path("stubs.c"), .flags = &.{} });
    preexisting.root_module.linkSystemLibrary("c", .{});
    b.default_step.dependOn(&b.addRunArtifact(preexisting).step);

    const recursive_module = b.createModule(.{
        .root_source_file = b.path("recursive.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const recursive = b.addTest(.{ .root_module = recursive_module });
    recursive.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    recursive.root_module.addCSourceFile(.{ .file = b.path("stubs.c"), .flags = &.{} });
    recursive.root_module.linkSystemLibrary("c", .{});
    b.default_step.dependOn(&b.addRunArtifact(recursive).step);

    const negativeCompileTimeModule = b.createModule(.{
        .root_source_file = b.path("negative_compile_time.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeCompileTime = b.addTest(.{ .root_module = negativeCompileTimeModule });
    negativeCompileTime.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeCompileTimeStep = b.step(
        "negative-compile-time",
        "Compile the expected SDL_COMPILE_TIME_ASSERT diagnostic fixture",
    );
    negativeCompileTimeStep.dependOn(&negativeCompileTime.step);

    const negativeCastModule = b.createModule(.{
        .root_source_file = b.path("negative_cast.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeCast = b.addTest(.{ .root_module = negativeCastModule });
    negativeCast.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeCastStep = b.step(
        "negative-cast",
        "Compile the expected invalid SDL cast diagnostic fixture",
    );
    negativeCastStep.dependOn(&negativeCast.step);

    const negativeFormatModule = b.createModule(.{
        .root_source_file = b.path("negative_format.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeFormat = b.addTest(.{ .root_module = negativeFormatModule });
    negativeFormat.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeFormatStep = b.step(
        "negative-format",
        "Compile the expected SDL scanf destination diagnostic fixture",
    );
    negativeFormatStep.dependOn(&negativeFormat.step);

    const negativeGrammarModule = b.createModule(.{
        .root_source_file = b.path("negative_grammar.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeGrammar = b.addTest(.{ .root_module = negativeGrammarModule });
    negativeGrammar.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeGrammarStep = b.step(
        "negative-grammar",
        "Compile the expected positional-format diagnostic fixture",
    );
    negativeGrammarStep.dependOn(&negativeGrammar.step);

    const negativeScansetModule = b.createModule(.{
        .root_source_file = b.path("negative_scanset.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeScanset = b.addTest(.{ .root_module = negativeScansetModule });
    negativeScanset.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeScansetStep = b.step(
        "negative-scanset",
        "Compile the expected malformed-scanset diagnostic fixture",
    );
    negativeScansetStep.dependOn(&negativeScanset.step);

    const negativeArgumentCountModule = b.createModule(.{
        .root_source_file = b.path("negative_argument_count.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeArgumentCount = b.addTest(.{ .root_module = negativeArgumentCountModule });
    negativeArgumentCount.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeArgumentCountStep = b.step(
        "negative-argument-count",
        "Compile the expected C format argument-count diagnostic fixture",
    );
    negativeArgumentCountStep.dependOn(&negativeArgumentCount.step);

    const negativePromotionModule = b.createModule(.{
        .root_source_file = b.path("negative_promotion.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativePromotion = b.addTest(.{ .root_module = negativePromotionModule });
    negativePromotion.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativePromotionStep = b.step(
        "negative-promotion",
        "Compile the expected C format promotion diagnostic fixture",
    );
    negativePromotionStep.dependOn(&negativePromotion.step);

    const negativeSignedLengthModule = b.createModule(.{
        .root_source_file = b.path("negative_signed_length.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeSignedLength = b.addTest(.{ .root_module = negativeSignedLengthModule });
    negativeSignedLength.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeSignedLengthStep = b.step(
        "negative-signed-length",
        "Compile the expected C format signed-length diagnostic fixture",
    );
    negativeSignedLengthStep.dependOn(&negativeSignedLength.step);

    const negativeStringModule = b.createModule(.{
        .root_source_file = b.path("negative_string.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeString = b.addTest(.{ .root_module = negativeStringModule });
    negativeString.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeStringStep = b.step(
        "negative-string",
        "Compile the expected non-sentinel C string diagnostic fixture",
    );
    negativeStringStep.dependOn(&negativeString.step);

    const negativeImmutableScanModule = b.createModule(.{
        .root_source_file = b.path("negative_immutable_scan.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeImmutableScan = b.addTest(.{ .root_module = negativeImmutableScanModule });
    negativeImmutableScan.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeImmutableScanStep = b.step(
        "negative-immutable-scan",
        "Compile the expected immutable scanf destination diagnostic fixture",
    );
    negativeImmutableScanStep.dependOn(&negativeImmutableScan.step);

    const negativePointerModule = b.createModule(.{
        .root_source_file = b.path("negative_pointer.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativePointer = b.addTest(.{ .root_module = negativePointerModule });
    negativePointer.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativePointerStep = b.step(
        "negative-pointer",
        "Compile the expected C format pointer diagnostic fixture",
    );
    negativePointerStep.dependOn(&negativePointer.step);

    const negativeMalformedModule = b.createModule(.{
        .root_source_file = b.path("negative_malformed.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeMalformed = b.addTest(.{ .root_module = negativeMalformedModule });
    negativeMalformed.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeMalformedStep = b.step(
        "negative-malformed",
        "Compile the expected malformed C format diagnostic fixture",
    );
    negativeMalformedStep.dependOn(&negativeMalformed.step);

    const negativeUnsupportedModule = b.createModule(.{
        .root_source_file = b.path("negative_unsupported.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "sdl", .module = sdl_module }},
    });
    const negativeUnsupported = b.addTest(.{ .root_module = negativeUnsupportedModule });
    negativeUnsupported.root_module.addIncludePath(b.path("../../../../vendor/SDL3/include"));
    const negativeUnsupportedStep = b.step(
        "negative-unsupported",
        "Compile the expected unsupported C format diagnostic fixture",
    );
    negativeUnsupportedStep.dependOn(&negativeUnsupported.step);
}
