// Generated from SDL3/SDL_test.h by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
pub const c = @import("sdl3_test_c");
const sdl = @import("sdl");
const root = @This();

const CVarargKind = enum {
    signed_int,
    unsigned_int,
    signed_long,
    unsigned_long,
    signed_long_long,
    unsigned_long_long,
    signed_size,
    unsigned_size,
    float,
    pointer,
    cstring,
    scan_signed_int,
    scan_unsigned_int,
    scan_signed_long,
    scan_unsigned_long,
    scan_signed_long_long,
    scan_unsigned_long_long,
    scan_signed_size,
    scan_unsigned_size,
    scan_float,
    scan_double,
    scan_char,
    scan_cstring,
    scan_pointer,
};

fn cVarargKinds(
    comptime format: [:0]const u8,
    comptime argument_count: usize,
    comptime scan: bool,
) [argument_count]CVarargKind {
    var kinds: [argument_count]CVarargKind = undefined;
    var count: usize = 0;
    var index: usize = 0;
    while (index < format.len) {
        if (format[index] != '%') {
            index += 1;
            continue;
        }
        index += 1;
        if (index >= format.len) @compileError("unterminated C format specifier");
        if (format[index] == '%') {
            index += 1;
            continue;
        }

        var suppressed = false;
        if (scan and format[index] == '*') {
            suppressed = true;
            index += 1;
        }
        while (index < format.len and
            (format[index] == '-' or format[index] == '+' or format[index] == '#' or
                format[index] == '0' or format[index] == ' ' or format[index] == '\'')) index += 1;
        if (!scan and index < format.len and format[index] == '*') {
            if (count >= argument_count) @compileError("C format has too few arguments");
            kinds[count] = .signed_int;
            count += 1;
            index += 1;
        } else {
            while (index < format.len and format[index] >= '0' and format[index] <= '9') index += 1;
        }
        if (index < format.len and format[index] == '.') {
            index += 1;
            if (!scan and index < format.len and format[index] == '*') {
                if (count >= argument_count) @compileError("C format has too few arguments");
                kinds[count] = .signed_int;
                count += 1;
                index += 1;
            } else {
                while (index < format.len and format[index] >= '0' and format[index] <= '9') index += 1;
            }
        }

        var length: u8 = 0;
        if (index < format.len and format[index] == 'h') {
            length = 1;
            index += 1;
            if (index < format.len and format[index] == 'h') index += 1;
        } else if (index < format.len and format[index] == 'l') {
            length = 2;
            index += 1;
            if (index < format.len and format[index] == 'l') {
                length = 3;
                index += 1;
            }
        } else if (index < format.len and format[index] == 'j') {
            length = 3;
            index += 1;
        } else if (index < format.len and format[index] == 'z') {
            length = 4;
            index += 1;
        } else if (index < format.len and format[index] == 't') {
            length = 5;
            index += 1;
        } else if (index < format.len and format[index] == 'L') {
            length = 6;
            index += 1;
        }
        if (index >= format.len) @compileError("unterminated C format specifier");
        const specifier = format[index];
        index += 1;
        if (specifier == '[') {
            while (index < format.len and format[index] != ']') index += 1;
            if (index >= format.len) @compileError("unterminated C scanf character set");
            index += 1;
        }
        if (suppressed) continue;
        if (count >= argument_count) @compileError("C format has too few arguments");
        kinds[count] = if (scan) switch (specifier) {
            'd', 'i' => switch (length) {
                0, 1 => .scan_signed_int,
                2 => .scan_signed_long,
                3 => .scan_signed_long_long,
                4, 5 => .scan_signed_size,
                else => @compileError("unsupported C scanf integer length"),
            },
            'o', 'u', 'x', 'X' => switch (length) {
                0, 1 => .scan_unsigned_int,
                2 => .scan_unsigned_long,
                3 => .scan_unsigned_long_long,
                4, 5 => .scan_unsigned_size,
                else => @compileError("unsupported C scanf integer length"),
            },
            'f' => if (length == 0) .scan_float else if (length == 2) .scan_double else @compileError("unsupported C scanf floating-point length"),
            'e', 'E', 'g', 'G', 'a', 'A' => if (length == 2) .scan_double else if (length == 0) .scan_float else @compileError("unsupported C scanf floating-point length"),
            'c' => .scan_char,
            's', '[' => .scan_cstring,
            'p' => .scan_pointer,
            'n' => .scan_signed_int,
            else => @compileError("unsupported C scanf conversion"),
        } else switch (specifier) {
            'd', 'i' => switch (length) {
                0, 1 => .signed_int,
                2 => .signed_long,
                3 => .signed_long_long,
                4, 5 => .signed_size,
                else => @compileError("unsupported C printf integer length"),
            },
            'o', 'u', 'x', 'X' => switch (length) {
                0, 1 => .unsigned_int,
                2 => .unsigned_long,
                3 => .unsigned_long_long,
                4, 5 => .unsigned_size,
                else => @compileError("unsupported C printf integer length"),
            },
            'f', 'F', 'e', 'E', 'g', 'G', 'a', 'A' => if (length == 0) .float else @compileError("unsupported C printf floating-point length"),
            'c' => .signed_int,
            's' => .cstring,
            'p', 'n' => .pointer,
            else => @compileError("unsupported C printf conversion"),
        };
        count += 1;
    }
    if (count != argument_count) @compileError("C format argument count does not match tuple");
    return kinds;
}

fn cVarargArgsType(comptime argument_type: type, comptime kinds: anytype) type {
    const fields = @typeInfo(argument_type).@"struct".fields;
    const types = comptime blk: {
        var result: [kinds.len]type = undefined;
        for (kinds, 0..) |kind, index| result[index] = switch (kind) {
            .signed_int => c_int,
            .unsigned_int => c_uint,
            .signed_long => c_long,
            .unsigned_long => c_ulong,
            .signed_long_long => c_longlong,
            .unsigned_long_long => c_ulonglong,
            .signed_size => isize,
            .unsigned_size => usize,
            .float => f64,
            else => fields[index].type,
        };
        break :blk result;
    };
    return std.meta.Tuple(&types);
}

fn cVarargIsPointer(comptime argument_type: type) bool {
    return switch (@typeInfo(argument_type)) {
        .optional => |info| cVarargIsPointer(info.child),
        .pointer => true,
        else => false,
    };
}

fn cVarargIsCString(comptime argument_type: type) bool {
    return switch (@typeInfo(argument_type)) {
        .optional => |info| cVarargIsCString(info.child),
        .pointer => |info| info.child == u8 and (info.sentinel != null or info.size == .c),
        else => false,
    };
}

fn cVarargIsWritableCString(comptime argument_type: type) bool {
    return switch (@typeInfo(argument_type)) {
        .optional => |info| cVarargIsWritableCString(info.child),
        .pointer => |info| info.child == u8 and !info.is_const,
        else => false,
    };
}

fn cVarargIsPointerToPointer(comptime argument_type: type) bool {
    return switch (@typeInfo(argument_type)) {
        .optional => |info| cVarargIsPointerToPointer(info.child),
        .pointer => |info| cVarargIsPointer(info.child),
        else => false,
    };
}

fn cVarargIsDefaultInt(comptime argument_type: type) bool {
    return argument_type == bool or argument_type == i8 or argument_type == u8 or
        argument_type == i16 or argument_type == u16 or argument_type == c_int or
        argument_type == c_uint or argument_type == comptime_int;
}

fn cVarargPromoteInt(comptime target: type, value: anytype) target {
    return if (@TypeOf(value) == bool) @as(target, @intFromBool(value)) else @as(target, value);
}

fn cVarargPromoteFloat(value: anytype) f64 {
    return @floatCast(value);
}

fn cVarargValidate(comptime kind: CVarargKind, comptime argument_type: type) void {
    switch (kind) {
        .signed_int => if (!cVarargIsDefaultInt(argument_type))
            @compileError("C printf integer arguments must be default-promoted to c_int"),
        .unsigned_int => if (!cVarargIsDefaultInt(argument_type))
            @compileError("C printf integer arguments must be default-promoted to c_uint"),
        .signed_long => if (argument_type != c_long and argument_type != comptime_int)
            @compileError("C printf %ld requires c_long"),
        .unsigned_long => if (argument_type != c_ulong and argument_type != comptime_int)
            @compileError("C printf %lu requires c_ulong"),
        .signed_long_long => if (argument_type != c_longlong and argument_type != comptime_int)
            @compileError("C printf %lld requires c_longlong"),
        .unsigned_long_long => if (argument_type != c_ulonglong and argument_type != comptime_int)
            @compileError("C printf %llu requires c_ulonglong"),
        .signed_size => if (argument_type != isize and argument_type != comptime_int)
            @compileError("C printf %zd requires isize"),
        .unsigned_size => if (argument_type != usize and argument_type != comptime_int)
            @compileError("C printf %zu requires usize"),
        .float => if (argument_type != f32 and argument_type != f64 and argument_type != comptime_float)
            @compileError("C printf floating-point arguments must be default-promoted to f64"),
        .pointer => if (!cVarargIsPointer(argument_type))
            @compileError("C printf pointer arguments must be pointers"),
        .cstring => if (!cVarargIsCString(argument_type))
            @compileError("C printf %s arguments must be sentinel-terminated C strings"),
        .scan_signed_int => if (argument_type != *c_int)
            @compileError("C scanf %d requires *c_int"),
        .scan_unsigned_int => if (argument_type != *c_uint)
            @compileError("C scanf %u requires *c_uint"),
        .scan_signed_long => if (argument_type != *c_long)
            @compileError("C scanf %ld requires *c_long"),
        .scan_unsigned_long => if (argument_type != *c_ulong)
            @compileError("C scanf %lu requires *c_ulong"),
        .scan_signed_long_long => if (argument_type != *c_longlong)
            @compileError("C scanf %lld requires *c_longlong"),
        .scan_unsigned_long_long => if (argument_type != *c_ulonglong)
            @compileError("C scanf %llu requires *c_ulonglong"),
        .scan_signed_size => if (argument_type != *isize)
            @compileError("C scanf %zd requires *isize"),
        .scan_unsigned_size => if (argument_type != *usize)
            @compileError("C scanf %zu requires *usize"),
        .scan_float => if (argument_type != *f32)
            @compileError("C scanf %f requires *f32"),
        .scan_double => if (argument_type != *f64)
            @compileError("C scanf %lf requires *f64"),
        .scan_char => if (argument_type != *u8)
            @compileError("C scanf %c requires *u8"),
        .scan_cstring => if (!cVarargIsWritableCString(argument_type))
            @compileError("C scanf string arguments must be writable pointers"),
        .scan_pointer => if (!cVarargIsPointerToPointer(argument_type))
            @compileError("C scanf %p arguments must be pointer-to-pointer values"),
    }
}

fn validateCVarargs(comptime format: [:0]const u8, args: anytype, comptime scan: bool) cVarargArgsType(
    @TypeOf(args),
    cVarargKinds(format, @typeInfo(@TypeOf(args)).@"struct".fields.len, scan),
) {
    const info = @typeInfo(@TypeOf(args));
    if (info != .@"struct" or !info.@"struct".is_tuple)
        @compileError("C variadic arguments must be a tuple literal");
    const kinds = cVarargKinds(format, args.len, scan);
    const Result = cVarargArgsType(@TypeOf(args), kinds);
    var result: Result = undefined;
    inline for (args, 0..) |argument, index| {
        cVarargValidate(kinds[index], @TypeOf(argument));
        result[index] = switch (kinds[index]) {
            .signed_int => cVarargPromoteInt(c_int, argument),
            .unsigned_int => cVarargPromoteInt(c_uint, argument),
            .signed_long => @as(c_long, argument),
            .unsigned_long => @as(c_ulong, argument),
            .signed_long_long => @as(c_longlong, argument),
            .unsigned_long_long => @as(c_ulonglong, argument),
            .signed_size => @as(isize, argument),
            .unsigned_size => @as(usize, argument),
            .float => cVarargPromoteFloat(argument),
            else => argument,
        };
    }
    return result;
}

/// SDL record `ArgumentParser`.
pub const ArgumentParser = extern struct {
    /// Field `parse_arguments`.
    parse_arguments: ParseArgumentsFp,
    /// Field `finalize`.
    finalize: FinalizeArgumentParserFp,
    /// Field `usage`.
    usage: ?*?*const u8,
    /// Field `data`.
    data: ?*anyopaque,
    /// Field `next`.
    next: ?*ArgumentParser,
};
comptime {
    if (@sizeOf(ArgumentParser) != @sizeOf(c.SDLTest_ArgumentParser)) @compileError("ABI size mismatch for ArgumentParser");
    if (@alignOf(ArgumentParser) != @alignOf(c.SDLTest_ArgumentParser)) @compileError("ABI alignment mismatch for ArgumentParser");
    if (@offsetOf(ArgumentParser, "parse_arguments") != @offsetOf(c.SDLTest_ArgumentParser, "parse_arguments")) @compileError("ABI field mismatch for ArgumentParser.parse_arguments");
    if (@offsetOf(ArgumentParser, "finalize") != @offsetOf(c.SDLTest_ArgumentParser, "finalize")) @compileError("ABI field mismatch for ArgumentParser.finalize");
    if (@offsetOf(ArgumentParser, "usage") != @offsetOf(c.SDLTest_ArgumentParser, "usage")) @compileError("ABI field mismatch for ArgumentParser.usage");
    if (@offsetOf(ArgumentParser, "data") != @offsetOf(c.SDLTest_ArgumentParser, "data")) @compileError("ABI field mismatch for ArgumentParser.data");
    if (@offsetOf(ArgumentParser, "next") != @offsetOf(c.SDLTest_ArgumentParser, "next")) @compileError("ABI field mismatch for ArgumentParser.next");
}

/// SDL record `Crc32Context`.
pub const Crc32Context = extern struct {
    /// Field `crc32_table`.
    crc32_table: [256]c_uint,
};
comptime {
    if (@sizeOf(Crc32Context) != @sizeOf(c.SDLTest_Crc32Context)) @compileError("ABI size mismatch for Crc32Context");
    if (@alignOf(Crc32Context) != @alignOf(c.SDLTest_Crc32Context)) @compileError("ABI alignment mismatch for Crc32Context");
    if (@offsetOf(Crc32Context, "crc32_table") != @offsetOf(c.SDLTest_Crc32Context, "crc32_table")) @compileError("ABI field mismatch for Crc32Context.crc32_table");
}

/// SDL record `Md5Context`.
pub const Md5Context = extern struct {
    /// Field `i`.
    i: [2]Md5Uint4,
    /// Field `buf`.
    buf: [4]Md5Uint4,
    /// Field `in`.
    in: [64]u8,
    /// Field `digest`.
    digest: [16]u8,
};
comptime {
    if (@sizeOf(Md5Context) != @sizeOf(c.SDLTest_Md5Context)) @compileError("ABI size mismatch for Md5Context");
    if (@alignOf(Md5Context) != @alignOf(c.SDLTest_Md5Context)) @compileError("ABI alignment mismatch for Md5Context");
    if (@offsetOf(Md5Context, "i") != @offsetOf(c.SDLTest_Md5Context, "i")) @compileError("ABI field mismatch for Md5Context.i");
    if (@offsetOf(Md5Context, "buf") != @offsetOf(c.SDLTest_Md5Context, "buf")) @compileError("ABI field mismatch for Md5Context.buf");
    if (@offsetOf(Md5Context, "in") != @offsetOf(c.SDLTest_Md5Context, "in")) @compileError("ABI field mismatch for Md5Context.in");
    if (@offsetOf(Md5Context, "digest") != @offsetOf(c.SDLTest_Md5Context, "digest")) @compileError("ABI field mismatch for Md5Context.digest");
}

/// SDL record `TestCaseReference`.
pub const TestCaseReference = extern struct {
    /// Field `testCase`.
    test_case: TestCaseFp,
    /// Field `name`.
    name: ?*const u8,
    /// Field `description`.
    description: ?*const u8,
    /// Field `enabled`.
    enabled: c_int,
};
comptime {
    if (@sizeOf(TestCaseReference) != @sizeOf(c.SDLTest_TestCaseReference)) @compileError("ABI size mismatch for TestCaseReference");
    if (@alignOf(TestCaseReference) != @alignOf(c.SDLTest_TestCaseReference)) @compileError("ABI alignment mismatch for TestCaseReference");
    if (@offsetOf(TestCaseReference, "test_case") != @offsetOf(c.SDLTest_TestCaseReference, "testCase")) @compileError("ABI field mismatch for TestCaseReference.test_case");
    if (@offsetOf(TestCaseReference, "name") != @offsetOf(c.SDLTest_TestCaseReference, "name")) @compileError("ABI field mismatch for TestCaseReference.name");
    if (@offsetOf(TestCaseReference, "description") != @offsetOf(c.SDLTest_TestCaseReference, "description")) @compileError("ABI field mismatch for TestCaseReference.description");
    if (@offsetOf(TestCaseReference, "enabled") != @offsetOf(c.SDLTest_TestCaseReference, "enabled")) @compileError("ABI field mismatch for TestCaseReference.enabled");
}

/// SDL record `TestSuiteReference`.
pub const TestSuiteReference = extern struct {
    /// Field `name`.
    name: ?*const u8,
    /// Field `testSetUp`.
    test_set_up: TestCaseSetUpFp,
    /// Field `testCases`.
    test_cases: ?*?*const TestCaseReference,
    /// Field `testTearDown`.
    test_tear_down: TestCaseTearDownFp,
};
comptime {
    if (@sizeOf(TestSuiteReference) != @sizeOf(c.SDLTest_TestSuiteReference)) @compileError("ABI size mismatch for TestSuiteReference");
    if (@alignOf(TestSuiteReference) != @alignOf(c.SDLTest_TestSuiteReference)) @compileError("ABI alignment mismatch for TestSuiteReference");
    if (@offsetOf(TestSuiteReference, "name") != @offsetOf(c.SDLTest_TestSuiteReference, "name")) @compileError("ABI field mismatch for TestSuiteReference.name");
    if (@offsetOf(TestSuiteReference, "test_set_up") != @offsetOf(c.SDLTest_TestSuiteReference, "testSetUp")) @compileError("ABI field mismatch for TestSuiteReference.test_set_up");
    if (@offsetOf(TestSuiteReference, "test_cases") != @offsetOf(c.SDLTest_TestSuiteReference, "testCases")) @compileError("ABI field mismatch for TestSuiteReference.test_cases");
    if (@offsetOf(TestSuiteReference, "test_tear_down") != @offsetOf(c.SDLTest_TestSuiteReference, "testTearDown")) @compileError("ABI field mismatch for TestSuiteReference.test_tear_down");
}

/// SDL handle `TestSuiteRunner`.
pub const TestSuiteRunner = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Ends this handle's SDL_test lifecycle.
    /// This method invalidates the handle after SDL_test consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.SDLTest_DestroyTestSuiteRunner(@ptrCast(self.value));
        self.* = undefined;
    }

    /// SDL operation `TestSuiteRunner.execute`.
    pub inline fn execute(self: @This()) c_int {
        return c.SDLTest_ExecuteTestSuiteRunner(@ptrCast(self.value));
    }
};

/// SDL record `TextWindow`.
pub const TextWindow = extern struct {
    /// Field `rect`.
    rect: sdl.rect.F,
    /// Field `current`.
    current: c_int,
    /// Field `numlines`.
    numlines: c_int,
    /// Field `lines`.
    lines: ?*?*u8,
};
comptime {
    if (@sizeOf(TextWindow) != @sizeOf(c.SDLTest_TextWindow)) @compileError("ABI size mismatch for TextWindow");
    if (@alignOf(TextWindow) != @alignOf(c.SDLTest_TextWindow)) @compileError("ABI alignment mismatch for TextWindow");
    if (@offsetOf(TextWindow, "rect") != @offsetOf(c.SDLTest_TextWindow, "rect")) @compileError("ABI field mismatch for TextWindow.rect");
    if (@offsetOf(TextWindow, "current") != @offsetOf(c.SDLTest_TextWindow, "current")) @compileError("ABI field mismatch for TextWindow.current");
    if (@offsetOf(TextWindow, "numlines") != @offsetOf(c.SDLTest_TextWindow, "numlines")) @compileError("ABI field mismatch for TextWindow.numlines");
    if (@offsetOf(TextWindow, "lines") != @offsetOf(c.SDLTest_TextWindow, "lines")) @compileError("ABI field mismatch for TextWindow.lines");
}

/// MD5 related functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library.
pub const Md5Uint4 = u32;

/// SDL type `CommonState`.
pub const CommonState = extern struct { argv: ?*?*u8, flags: sdl.init.Flags, verbose: VerboseFlags, videodriver: ?*const u8, display_index: c_int, display_id: sdl.video.DisplayId, window_title: ?*const u8, window_icon: ?*const u8, window_flags: sdl.video.WindowFlags, flash_on_focus_loss: bool, window_x: c_int, window_y: c_int, window_w: c_int, window_h: c_int, window_min_w: c_int, window_min_h: c_int, window_max_w: c_int, window_max_h: c_int, window_min_aspect: f32, window_max_aspect: f32, logical_w: c_int, logical_h: c_int, auto_scale_content: bool, logical_presentation: sdl.render.RendererLogicalPresentation, scale: f32, depth: c_int, refresh_rate: f32, fill_usable_bounds: bool, fullscreen_exclusive: bool, fullscreen_mode: sdl.video.DisplayMode, num_windows: c_int, windows: ?*?*sdl.video.Window, gpudriver: ?*const u8, renderdriver: ?*const u8, render_vsync: c_int, skip_renderer: bool, renderers: ?*?*sdl.render.Renderer, targets: ?*?*sdl.render.Texture, audiodriver: ?*const u8, audio_format: sdl.audio.Format, audio_channels: c_int, audio_freq: c_int, audio_id: sdl.audio.DeviceId, gl_red_size: c_int, gl_green_size: c_int, gl_blue_size: c_int, gl_alpha_size: c_int, gl_buffer_size: c_int, gl_depth_size: c_int, gl_stencil_size: c_int, gl_double_buffer: c_int, gl_accum_red_size: c_int, gl_accum_green_size: c_int, gl_accum_blue_size: c_int, gl_accum_alpha_size: c_int, gl_stereo: c_int, gl_release_behavior: c_int, gl_multisamplebuffers: c_int, gl_multisamplesamples: c_int, gl_retained_backing: c_int, gl_accelerated: c_int, gl_major_version: c_int, gl_minor_version: c_int, gl_debug: c_int, gl_profile_mask: c_int, confine: sdl.rect.Rect, hide_cursor: bool, quit_after_ms_interval: c_int, quit_after_ms_timer: sdl.timer.Id, common_argparser: ArgumentParser, video_argparser: ArgumentParser, audio_argparser: ArgumentParser, argparser: ?*ArgumentParser };

/// SDL type `FinalizeArgumentParserFp`.
pub const FinalizeArgumentParserFp = ?*const fn (arg0: ?*anyopaque) callconv(.c) void;

/// SDL type `ParseArgumentsFp`.
pub const ParseArgumentsFp = ?*const fn (arg0: ?*anyopaque, arg1: ?*?[*]u8, arg2: c_int) callconv(.c) c_int;

/// SDL type `TestCaseFp`.
pub const TestCaseFp = ?*const fn (arg0: ?*anyopaque) callconv(.c) c_int;

/// SDL type `TestCaseSetUpFp`.
pub const TestCaseSetUpFp = ?*const fn (arg0: ?*?*anyopaque) callconv(.c) void;

/// SDL type `TestCaseTearDownFp`.
pub const TestCaseTearDownFp = ?*const fn (arg0: ?*anyopaque) callconv(.c) void;

/// SDL type `Uint32`.
pub const VerboseFlags = packed struct(u32) {
    /// Flag bit `VERBOSE_VIDEO`.
    video: bool = false,
    /// Flag bit `VERBOSE_MODES`.
    modes: bool = false,
    /// Flag bit `VERBOSE_RENDER`.
    render: bool = false,
    /// Flag bit `VERBOSE_EVENT`.
    event: bool = false,
    /// Flag bit `VERBOSE_AUDIO`.
    audio: bool = false,
    /// Flag bit `VERBOSE_MOTION`.
    motion: bool = false,
    /// Unknown or currently unused bits preserved during integer round trips.
    reserved_0: u26 = 0,

    /// Preserve every known and unknown flag bit.
    pub inline fn fromInt(value: u32) @This() {
        return @bitCast(value);
    }

    /// Convert this flag set to its integer representation.
    pub inline fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }
};

/// SDL constant `VERBOSE_AUDIO`.
pub const verbose_flags_audio = c.VERBOSE_AUDIO;
/// SDL constant `VERBOSE_EVENT`.
pub const verbose_flags_event = c.VERBOSE_EVENT;
/// SDL constant `VERBOSE_MODES`.
pub const verbose_flags_modes = c.VERBOSE_MODES;
/// SDL constant `VERBOSE_MOTION`.
pub const verbose_flags_motion = c.VERBOSE_MOTION;
/// SDL constant `VERBOSE_RENDER`.
pub const verbose_flags_render = c.VERBOSE_RENDER;
/// SDL constant `VERBOSE_VIDEO`.
pub const verbose_flags_video = c.VERBOSE_VIDEO;

/// Access SDL variable `FONT_CHARACTER_SIZE`.
pub inline fn fontCharacterSizePtr() *c_int {
    return @ptrCast(&c.FONT_CHARACTER_SIZE);
}

/// SDL operation `assert`.
pub inline fn assert(assert_condition: c_int, comptime format: [:0]const u8, args: anytype) void {
    @call(.auto, c.SDLTest_Assert, .{ @as(@typeInfo(@TypeOf(c.SDLTest_Assert)).@"fn".params[0].type.?, assert_condition), @as(@typeInfo(@TypeOf(c.SDLTest_Assert)).@"fn".params[1].type.?, format.ptr) } ++ validateCVarargs(format, args, false));
}

/// SDL operation `assertCheck`.
pub inline fn assertCheck(assert_condition: c_int, comptime format: [:0]const u8, args: anytype) c_int {
    return @call(.auto, c.SDLTest_AssertCheck, .{ @as(@typeInfo(@TypeOf(c.SDLTest_AssertCheck)).@"fn".params[0].type.?, assert_condition), @as(@typeInfo(@TypeOf(c.SDLTest_AssertCheck)).@"fn".params[1].type.?, format.ptr) } ++ validateCVarargs(format, args, false));
}

/// SDL operation `assertPass`.
pub inline fn assertPass(comptime format: [:0]const u8, args: anytype) void {
    @call(.auto, c.SDLTest_AssertPass, .{@as(@typeInfo(@TypeOf(c.SDLTest_AssertPass)).@"fn".params[0].type.?, format.ptr)} ++ validateCVarargs(format, args, false));
}

/// SDL operation `assertSummaryToTestResult`.
pub inline fn assertSummaryToTestResult() c_int {
    return c.SDLTest_AssertSummaryToTestResult();
}

/// SDL operation `cleanupTextDrawing`.
pub inline fn cleanupTextDrawing() void {
    c.SDLTest_CleanupTextDrawing();
}

/// Process one common argument.
///
/// - **Parameters:**
///   - `state`: The common state describing the test window to create.
///   - `index`: The index of the argument to process in argv[].
///
/// - **Returns:** the number of arguments processed (i.e. 1 for fullscreen, 2 for video [videodriver], or -1 on error.
///
/// Returns `error.SdlFailure` when SDL_test reports failure.
pub inline fn commonArg(state: ?*CommonState, index: c_int) sdl.Error!c_int {
    const result = c.SDLTest_CommonArg(@ptrCast(state), index);
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Parse command line parameters and create common state.
///
/// - **Parameters:**
///   - `argv`: Array of command line parameters
///   - `flags`: Flags indicating which subsystem to initialize (i.e. sdl.init.Flags.video | sdl.init.Flags.audio)
///
/// - **Returns:** a newly allocated common state object.
pub inline fn commonCreateState(argv: ?*?[*]u8, flags: sdl.init.Flags) ?*CommonState {
    const result = c.SDLTest_CommonCreateState(@ptrCast(argv), flags);
    return if (result == null) null else @ptrCast(result);
}

/// Easy argument handling when test app doesn't need any custom args.
///
/// - **Parameters:**
///   - `state`: The common state describing the test window to create.
///   - `argc`: argc, as supplied to sdl.main
///   - `argv`: argv, as supplied to sdl.main
///
/// - **Returns:** false if app should quit, true otherwise.
pub inline fn commonDefaultArgs(state: ?*CommonState, argc: c_int, argv: ?*?[*]u8) bool {
    return c.SDLTest_CommonDefaultArgs(@ptrCast(state), argc, @ptrCast(argv));
}

/// Free the common state object.
///
/// You should call sdl.init.quit() before calling this function.
///
/// - **Parameters:**
///   - `state`: The common state object to destroy
pub inline fn commonDestroyState(state: ?*CommonState) void {
    c.SDLTest_CommonDestroyState(@ptrCast(state));
}

/// Draws various window information (position, size, etc.) to the renderer.
///
/// - **Parameters:**
///   - `renderer`: The renderer to draw to.
///   - `window`: The window whose information should be displayed.
///   - `used_height`: Returns the height used, so the caller can draw more below.
pub inline fn commonDrawWindowInfo(renderer: ?*sdl.render.Renderer, window: ?*sdl.video.Window, used_height: ?*f32) void {
    c.SDLTest_CommonDrawWindowInfo(@ptrCast(renderer), @ptrCast(window), @ptrCast(used_height));
}

/// Common event handler for test windows if you use a standard sdl.main.
///
/// - **Parameters:**
///   - `state`: The common state used to create test window.
///   - `event`: The event to handle.
///   - `done`: Flag indicating we are done.
pub inline fn commonEvent(state: ?*CommonState, event: ?*sdl.events.Event, done: ?*c_int) void {
    c.SDLTest_CommonEvent(@ptrCast(state), @ptrCast(event), @ptrCast(done));
}

/// Common event handler for test windows if you use SDL_AppEvent (C API outside this module).
///
/// This does *not* free anything in `event`.
///
/// - **Parameters:**
///   - `state`: The common state used to create test window.
///   - `event`: The event to handle.
///
/// - **Returns:** Value suitable for returning from SDL_AppEvent (C API outside this module)().
pub inline fn commonEventMainCallbacks(state: ?*CommonState, event: ?*const sdl.events.Event) sdl.init.AppResult {
    const result = c.SDLTest_CommonEventMainCallbacks(@ptrCast(state), @ptrCast(event));
    return @enumFromInt(result);
}

/// Open test window.
///
/// - **Parameters:**
///   - `state`: The common state describing the test window to create.
///
/// - **Returns:** true if initialization succeeded, false otherwise
pub inline fn commonInit(state: ?*CommonState) bool {
    return c.SDLTest_CommonInit(@ptrCast(state));
}

/// Logs command line usage info.
///
/// This logs the appropriate command line options for the subsystems in use plus other common options, and then any application-specific options. This uses the sdl.log.default2() function and splits up output to be friendly to 80-character-wide terminals.
///
/// - **Parameters:**
///   - `state`: The common state describing the test window for the app.
///   - `argv0`: argv[0], as passed to main/sdl.main.
///   - `options`: an array of strings for application specific options. The last element of the array should be NULL.
pub inline fn commonLogUsage(state: ?*CommonState, argv0: ?[:0]const u8, options: ?*?[*:0]const u8) void {
    c.SDLTest_CommonLogUsage(@ptrCast(state), if (argv0 != null) @ptrCast(argv0.?.ptr) else null, @ptrCast(options));
}

/// Close test window.
///
/// - **Parameters:**
///   - `state`: The common state used to create test window.
pub inline fn commonQuit(state: ?*CommonState) void {
    c.SDLTest_CommonQuit(@ptrCast(state));
}

/// Compares 2 memory blocks for equality
///
/// - **Parameters:**
///   - `actual`: Memory used in comparison, displayed on the left
///   - `size_actual`: Size of actual in bytes
///   - `reference`: Reference memory, displayed on the right
///   - `size_reference`: Size of reference in bytes
///
/// - **Returns:** 0 if the left and right memory block are equal, non-zero if they are non-equal.
/// - **Since:** This function is available since SDL 3.2.0.
pub inline fn compareMemory(actual: ?*const anyopaque, size_actual: c_ulong, reference: ?*const anyopaque, size_reference: c_ulong) c_int {
    return c.SDLTest_CompareMemory(@ptrCast(actual), size_actual, @ptrCast(reference), size_reference);
}

/// Comparison function of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library. Compares a surface and with reference image data for equality
///
/// - **Parameters:**
///   - `surface`: Surface used in comparison
///   - `reference_surface`: Test Surface used in comparison
///   - `allowable_error`: Allowable difference (=sum of squared difference for each RGB component) in blending accuracy.
///
/// - **Returns:** 0 if comparison succeeded, >0 (=number of pixels for which the comparison failed) if comparison failed, -1 if any of the surfaces were NULL, -2 if the surface sizes differ.
pub inline fn compareSurfaces(surface: ?*sdl.surface.Surface, reference_surface: ?*sdl.surface.Surface, allowable_error: c_int) c_int {
    return c.SDLTest_CompareSurfaces(@ptrCast(surface), @ptrCast(reference_surface), allowable_error);
}

/// SDL operation `compareSurfacesIgnoreTransparentPixels`.
pub inline fn compareSurfacesIgnoreTransparentPixels(surface: ?*sdl.surface.Surface, reference_surface: ?*sdl.surface.Surface, allowable_error: c_int) c_int {
    return c.SDLTest_CompareSurfacesIgnoreTransparentPixels(@ptrCast(surface), @ptrCast(reference_surface), allowable_error);
}

/// SDL operation `crc32Calc`.
pub inline fn crc32Calc(crc_context: ?*Crc32Context, in_buf: ?*u8, in_len: c_uint, crc32: ?*c_uint) bool {
    return c.SDLTest_Crc32Calc(@ptrCast(crc_context), @ptrCast(in_buf), in_len, @ptrCast(crc32));
}

/// SDL operation `crc32CalcBuffer`.
pub inline fn crc32CalcBuffer(crc_context: ?*Crc32Context, in_buf: ?*u8, in_len: c_uint, crc32: ?*c_uint) bool {
    return c.SDLTest_Crc32CalcBuffer(@ptrCast(crc_context), @ptrCast(in_buf), in_len, @ptrCast(crc32));
}

/// SDL operation `crc32CalcEnd`.
pub inline fn crc32CalcEnd(crc_context: ?*Crc32Context, crc32: ?*c_uint) bool {
    return c.SDLTest_Crc32CalcEnd(@ptrCast(crc_context), @ptrCast(crc32));
}

/// SDL operation `crc32CalcStart`.
pub inline fn crc32CalcStart(crc_context: ?*Crc32Context, crc32: ?*c_uint) bool {
    return c.SDLTest_Crc32CalcStart(@ptrCast(crc_context), @ptrCast(crc32));
}

/// SDL operation `crc32Done`.
pub inline fn crc32Done(crc_context: ?*Crc32Context) bool {
    return c.SDLTest_Crc32Done(@ptrCast(crc_context));
}

/// SDL operation `crc32Init`.
pub inline fn crc32Init(crc_context: ?*Crc32Context) bool {
    return c.SDLTest_Crc32Init(@ptrCast(crc_context));
}

/// SDL operation `createTestSuiteRunner`.
pub inline fn createTestSuiteRunner(state: ?*CommonState, test_suites: ?*?*TestSuiteReference) ?TestSuiteRunner {
    const result = c.SDLTest_CreateTestSuiteRunner(@ptrCast(state), @ptrCast(test_suites));
    return if (result) |value| TestSuiteRunner{ .value = @ptrCast(value) } else null;
}

/// SDL operation `drawCharacter`.
pub inline fn drawCharacter(renderer: ?*sdl.render.Renderer, x: f32, y: f32, c_2: u32) bool {
    return c.SDLTest_DrawCharacter(@ptrCast(renderer), x, y, c_2);
}

/// SDL operation `drawString`.
pub inline fn drawString(renderer: ?*sdl.render.Renderer, x: f32, y: f32, s: ?[:0]const u8) bool {
    return c.SDLTest_DrawString(@ptrCast(renderer), x, y, if (s != null) @ptrCast(s.?.ptr) else null);
}

/// SDL operation `TestSuiteRunner.execute`.
pub inline fn executeTestSuiteRunner(runner: ?TestSuiteRunner) c_int {
    return c.SDLTest_ExecuteTestSuiteRunner(if (runner) |resource| @ptrCast(resource.value) else null);
}

/// Fuzzer functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library. Note: The fuzzer implementation uses a static instance of random context internally which makes it thread-UNsafe. Initializes the fuzzer for a test
///
/// - **Parameters:**
///   - `exec_key`: Execution "Key" that initializes the random number generator uniquely for the test.
pub inline fn fuzzerInit(exec_key: u64) void {
    c.SDLTest_FuzzerInit(exec_key);
}

/// SDL operation `generateRunSeed`.
pub inline fn generateRunSeed(buffer: []u8) ?[*]u8 {
    const result = c.SDLTest_GenerateRunSeed(@ptrCast(buffer.ptr), @intCast(buffer.len));
    return if (result == null) null else @ptrCast(result);
}

/// Get the invocation count for the fuzzer since last ...FuzzerInit.
///
/// - **Returns:** the invocation count.
pub inline fn getFuzzerInvocationCount() c_int {
    return c.SDLTest_GetFuzzerInvocationCount();
}

/// Prints given message with a timestamp in the TEST category and INFO priority.
///
/// - **Parameters:**
///   - `fmt`: Message to be logged
pub inline fn log(comptime format: [:0]const u8, args: anytype) void {
    @call(.auto, c.SDLTest_Log, .{@as(@typeInfo(@TypeOf(c.SDLTest_Log)).@"fn".params[0].type.?, format.ptr)} ++ validateCVarargs(format, args, false));
}

/// Print a log of any outstanding allocations
///
/// > **Note:** This can be called after sdl.init.quit()
pub inline fn logAllocations() void {
    c.SDLTest_LogAllocations();
}

/// SDL operation `logAssertSummary`.
pub inline fn logAssertSummary() void {
    c.SDLTest_LogAssertSummary();
}

/// Prints given message with a timestamp in the TEST category and the ERROR priority.
///
/// - **Parameters:**
///   - `fmt`: Message to be logged
pub inline fn logError(comptime format: [:0]const u8, args: anytype) void {
    @call(.auto, c.SDLTest_LogError, .{@as(@typeInfo(@TypeOf(c.SDLTest_LogError)).@"fn".params[0].type.?, format.ptr)} ++ validateCVarargs(format, args, false));
}

/// Prints given prefix and buffer. Non-printible characters in the raw data are substituted by printible alternatives.
///
/// - **Parameters:**
///   - `prefix`: Prefix message.
///   - `buffer`: Raw data to be escaped.
pub inline fn logEscapedString(prefix: ?[:0]const u8, buffer: []const u8) void {
    c.SDLTest_LogEscapedString(if (prefix != null) @ptrCast(prefix.?.ptr) else null, @ptrCast(buffer.ptr), @intCast(buffer.len));
}

/// Logging related functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library. Prints given message with a timestamp in the TEST category and given priority.
///
/// - **Parameters:**
///   - `priority`: Priority of the message
///   - `fmt`: Message to be logged
pub inline fn logMessage(priority: sdl.log.Priority, comptime format: [:0]const u8, args: anytype) void {
    @call(.auto, c.SDLTest_LogMessage, .{ @as(@typeInfo(@TypeOf(c.SDLTest_LogMessage)).@"fn".params[0].type.?, @intCast(@intFromEnum(priority))), @as(@typeInfo(@TypeOf(c.SDLTest_LogMessage)).@"fn".params[1].type.?, format.ptr) } ++ validateCVarargs(format, args, false));
}

/// complete digest computation
///
/// - **Parameters:**
///   - `md_context`: pointer to context variable
///
/// Note: The function terminates the message-digest computation and ends with the desired message digest in mdContext.digest[0..15]. Always call before using the digest[] variable.
pub inline fn md5Final(md_context: ?*Md5Context) void {
    c.SDLTest_Md5Final(@ptrCast(md_context));
}

/// initialize the context
///
/// - **Parameters:**
///   - `md_context`: pointer to context variable
///
/// Note: The function initializes the message-digest context mdContext. Call before each new use of the context - all fields are set to zero.
pub inline fn md5Init(md_context: ?*Md5Context) void {
    c.SDLTest_Md5Init(@ptrCast(md_context));
}

/// update digest from variable length data
///
/// - **Parameters:**
///   - `md_context`: pointer to context variable
///   - `in_buf`: pointer to data array/string
///   - `in_len`: length of data array/string
///
/// Note: The function updates the message-digest context to account for the presence of each of the characters inBuf[0..inLen-1] in the message whose digest is being computed.
pub inline fn md5Update(md_context: ?*Md5Context, in_buf: ?*u8, in_len: c_uint) void {
    c.SDLTest_Md5Update(@ptrCast(md_context), @ptrCast(in_buf), in_len);
}

/// Print the details of an event.
///
/// This is automatically called by commonEvent() as needed.
///
/// - **Parameters:**
///   - `event`: The event to print.
pub inline fn printEvent(event: ?*const sdl.events.Event) void {
    c.SDLTest_PrintEvent(@ptrCast(event));
}

/// Fill allocations with random data
///
/// > **Note:** This implicitly calls trackAllocations()
pub inline fn randFillAllocations() void {
    c.SDLTest_RandFillAllocations();
}

/// Generates random null-terminated string. The minimum length for the string is 1 character, maximum length for the string is 255 characters and it can contain ASCII characters from 32 to 126.
///
/// Note: Returned string needs to be deallocated.
///
/// - **Returns:** a newly allocated random string; or NULL if length was invalid or string could not be allocated.
pub inline fn randomAsciiString() ?[*]u8 {
    const result = c.SDLTest_RandomAsciiString();
    return if (result == null) null else @ptrCast(result);
}

/// Generates random null-terminated string. The length for the string is defined by the size parameter. String can contain ASCII characters from 32 to 126.
///
/// Note: Returned string needs to be deallocated.
///
/// - **Parameters:**
///   - `size`: The length of the generated string
///
/// - **Returns:** a newly allocated random string; or NULL if size was invalid or string could not be allocated.
pub inline fn randomAsciiStringOfSize(size: c_int) ?[*]u8 {
    const result = c.SDLTest_RandomAsciiStringOfSize(size);
    return if (result == null) null else @ptrCast(result);
}

/// Generates random null-terminated string. The maximum length for the string is defined by the maxLength parameter. String can contain ASCII characters from 32 to 126.
///
/// Note: Returned string needs to be deallocated.
///
/// - **Parameters:**
///   - `max_length`: The maximum length of the generated string.
///
/// - **Returns:** a newly allocated random string; or NULL if maxLength was invalid or string could not be allocated.
pub inline fn randomAsciiStringWithMaximumLength(max_length: c_int) ?[*]u8 {
    const result = c.SDLTest_RandomAsciiStringWithMaximumLength(max_length);
    return if (result == null) null else @ptrCast(result);
}

/// - **Returns:** a random double.
pub inline fn randomDouble() f64 {
    return c.SDLTest_RandomDouble();
}

/// - **Returns:** a random float.
pub inline fn randomFloat() f32 {
    return c.SDLTest_RandomFloat();
}

/// Returns integer in range [min, max] (inclusive). Min and max values can be negative values. If Max in smaller than min, then the values are swapped. Min and max are the same value, that value will be returned.
///
/// - **Parameters:**
///   - `min`: Minimum inclusive value of returned random number
///   - `max`: Maximum inclusive value of returned random number
///
/// - **Returns:** a generated random integer in range
pub inline fn randomIntegerInRange(min: i32, max: i32) i32 {
    return c.SDLTest_RandomIntegerInRange(min, max);
}

/// Returns a random Sint16
///
/// - **Returns:** a generated signed integer
pub inline fn randomSint16() i16 {
    return c.SDLTest_RandomSint16();
}

/// Returns a random boundary value for Sint16 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomSint16BoundaryValue(-10, 20, true) returns -11, -10, 19 or 20 RandomSint16BoundaryValue(-100, -10, false) returns -101 or -9 RandomSint16BoundaryValue(SINT16_MIN, 99, false) returns 100 RandomSint16BoundaryValue(SINT16_MIN, SINT16_MAX, false) returns SINT16_MIN (== error value) with error set
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or SINT16_MIN with error set
pub inline fn randomSint16BoundaryValue(boundary1: i16, boundary2: i16, valid_domain: bool) i16 {
    return c.SDLTest_RandomSint16BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns a random integer
///
/// - **Returns:** a generated integer
pub inline fn randomSint32() i32 {
    return c.SDLTest_RandomSint32();
}

/// Returns a random boundary value for Sint32 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomSint32BoundaryValue(-10, 20, true) returns -11, -10, 19 or 20 RandomSint32BoundaryValue(-100, -10, false) returns -101 or -9 RandomSint32BoundaryValue(SINT32_MIN, 99, false) returns 100 RandomSint32BoundaryValue(SINT32_MIN, SINT32_MAX, false) returns SINT32_MIN (== error value)
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or SINT32_MIN with error set
pub inline fn randomSint32BoundaryValue(boundary1: i32, boundary2: i32, valid_domain: bool) i32 {
    return c.SDLTest_RandomSint32BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns random Sint64.
///
/// - **Returns:** a generated signed integer
pub inline fn randomSint64() i64 {
    return c.SDLTest_RandomSint64();
}

/// Returns a random boundary value for Sint64 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomSint64BoundaryValue(-10, 20, true) returns -11, -10, 19 or 20 RandomSint64BoundaryValue(-100, -10, false) returns -101 or -9 RandomSint64BoundaryValue(SINT64_MIN, 99, false) returns 100 RandomSint64BoundaryValue(SINT64_MIN, SINT64_MAX, false) returns SINT64_MIN (== error value) and error set
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or SINT64_MIN with error set
pub inline fn randomSint64BoundaryValue(boundary1: i64, boundary2: i64, valid_domain: bool) i64 {
    return c.SDLTest_RandomSint64BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns a random Sint8
///
/// - **Returns:** a generated signed integer
pub inline fn randomSint8() i8 {
    return c.SDLTest_RandomSint8();
}

/// Returns a random boundary value for Sint8 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomSint8BoundaryValue(-10, 20, true) returns -11, -10, 19 or 20 RandomSint8BoundaryValue(-100, -10, false) returns -101 or -9 RandomSint8BoundaryValue(SINT8_MIN, 99, false) returns 100 RandomSint8BoundaryValue(SINT8_MIN, SINT8_MAX, false) returns SINT8_MIN (== error value) with error set
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or SINT8_MIN with error set
pub inline fn randomSint8BoundaryValue(boundary1: i8, boundary2: i8, valid_domain: bool) i8 {
    return c.SDLTest_RandomSint8BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns a random Uint16
///
/// - **Returns:** a generated integer
pub inline fn randomUint16() u16 {
    return c.SDLTest_RandomUint16();
}

/// Returns a random boundary value for Uint16 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomUint16BoundaryValue(10, 20, true) returns 10, 11, 19 or 20 RandomUint16BoundaryValue(1, 20, false) returns 0 or 21 RandomUint16BoundaryValue(0, 99, false) returns 100 RandomUint16BoundaryValue(0, 0xFFFF, false) returns 0 (error set)
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or 0 with error set
pub inline fn randomUint16BoundaryValue(boundary1: u16, boundary2: u16, valid_domain: bool) u16 {
    return c.SDLTest_RandomUint16BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns a random positive integer
///
/// - **Returns:** a generated integer
pub inline fn randomUint32() u32 {
    return c.SDLTest_RandomUint32();
}

/// Returns a random boundary value for Uint32 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomUint32BoundaryValue(10, 20, true) returns 10, 11, 19 or 20 RandomUint32BoundaryValue(1, 20, false) returns 0 or 21 RandomUint32BoundaryValue(0, 99, false) returns 100 RandomUint32BoundaryValue(0, 0xFFFFFFFF, false) returns 0 (with error set)
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or 0 with error set
pub inline fn randomUint32BoundaryValue(boundary1: u32, boundary2: u32, valid_domain: bool) u32 {
    return c.SDLTest_RandomUint32BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns random Uint64.
///
/// - **Returns:** a generated integer
pub inline fn randomUint64() u64 {
    return c.SDLTest_RandomUint64();
}

/// Returns a random boundary value for Uint64 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomUint64BoundaryValue(10, 20, true) returns 10, 11, 19 or 20 RandomUint64BoundaryValue(1, 20, false) returns 0 or 21 RandomUint64BoundaryValue(0, 99, false) returns 100 RandomUint64BoundaryValue(0, 0xFFFFFFFFFFFFFFFF, false) returns 0 (with error set)
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or 0 with error set
pub inline fn randomUint64BoundaryValue(boundary1: u64, boundary2: u64, valid_domain: bool) u64 {
    return c.SDLTest_RandomUint64BoundaryValue(boundary1, boundary2, valid_domain);
}

/// Returns a random Uint8
///
/// - **Returns:** a generated integer
pub inline fn randomUint8() u8 {
    return c.SDLTest_RandomUint8();
}

/// Returns a random boundary value for Uint8 within the given boundaries. Boundaries are inclusive, see the usage examples below. If validDomain is true, the function will only return valid boundaries, otherwise non-valid boundaries are also possible. If boundary1 > boundary2, the values are swapped
///
/// Usage examples: RandomUint8BoundaryValue(10, 20, true) returns 10, 11, 19 or 20 RandomUint8BoundaryValue(1, 20, false) returns 0 or 21 RandomUint8BoundaryValue(0, 99, false) returns 100 RandomUint8BoundaryValue(0, 255, false) returns 0 (error set)
///
/// - **Parameters:**
///   - `boundary1`: Lower boundary limit
///   - `boundary2`: Upper boundary limit
///   - `valid_domain`: Should the generated boundary be valid (=within the bounds) or not?
///
/// - **Returns:** a random boundary value for the given range and domain or 0 with error set
pub inline fn randomUint8BoundaryValue(boundary1: u8, boundary2: u8, valid_domain: bool) u8 {
    return c.SDLTest_RandomUint8BoundaryValue(boundary1, boundary2, valid_domain);
}

/// - **Returns:** a random double in range [0.0 - 1.0]
pub inline fn randomUnitDouble() f64 {
    return c.SDLTest_RandomUnitDouble();
}

/// - **Returns:** a random float in range [0.0 - 1.0]
pub inline fn randomUnitFloat() f32 {
    return c.SDLTest_RandomUnitFloat();
}

/// SDL operation `resetAssertSummary`.
pub inline fn resetAssertSummary() void {
    c.SDLTest_ResetAssertSummary();
}

/// SDL operation `textWindowAddText`.
pub inline fn textWindowAddText(textwin: ?*TextWindow, comptime format: [:0]const u8, args: anytype) void {
    @call(.auto, c.SDLTest_TextWindowAddText, .{ @as(@typeInfo(@TypeOf(c.SDLTest_TextWindowAddText)).@"fn".params[0].type.?, @ptrCast(textwin)), @as(@typeInfo(@TypeOf(c.SDLTest_TextWindowAddText)).@"fn".params[1].type.?, format.ptr) } ++ validateCVarargs(format, args, false));
}

/// SDL operation `textWindowAddTextWithLength`.
pub inline fn textWindowAddTextWithLength(textwin: ?*TextWindow, text: ?[:0]const u8, len: c_ulong) void {
    c.SDLTest_TextWindowAddTextWithLength(@ptrCast(textwin), if (text != null) @ptrCast(text.?.ptr) else null, len);
}

/// SDL operation `textWindowClear`.
pub inline fn textWindowClear(textwin: ?*TextWindow) void {
    c.SDLTest_TextWindowClear(@ptrCast(textwin));
}

/// SDL operation `textWindowCreate`.
pub inline fn textWindowCreate(x: f32, y: f32, w: f32, h: f32) ?*TextWindow {
    const result = c.SDLTest_TextWindowCreate(x, y, w, h);
    return if (result == null) null else @ptrCast(result);
}

/// SDL operation `textWindowDestroy`.
pub inline fn textWindowDestroy(textwin: ?*TextWindow) void {
    c.SDLTest_TextWindowDestroy(@ptrCast(textwin));
}

/// SDL operation `textWindowDisplay`.
pub inline fn textWindowDisplay(textwin: ?*TextWindow, renderer: ?*sdl.render.Renderer) void {
    c.SDLTest_TextWindowDisplay(@ptrCast(textwin), @ptrCast(renderer));
}

/// Memory tracking related functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library. Start tracking SDL memory allocations
///
/// > **Note:** This should be called before any other SDL functions for complete tracking coverage
pub inline fn trackAllocations() void {
    c.SDLTest_TrackAllocations();
}

// Force target-specific public declarations through Zig's lazy analysis.
comptime {
    if (builtin.abi == .android or builtin.abi == .androideabi) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
    if (builtin.os.tag == .emscripten) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
    if (builtin.os.tag == .ios) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
    if (builtin.os.tag == .linux) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
    if (builtin.os.tag == .macos) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
    if (builtin.os.tag == .tvos) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
    if (builtin.os.tag == .windows) {
        _ = root.ArgumentParser;
        _ = root.CommonState;
        _ = root.Crc32Context;
        _ = root.FinalizeArgumentParserFp;
        _ = root.Md5Context;
        _ = root.Md5Uint4;
        _ = root.ParseArgumentsFp;
        _ = root.TestCaseFp;
        _ = root.TestCaseReference;
        _ = root.TestCaseSetUpFp;
        _ = root.TestCaseTearDownFp;
        _ = root.TestSuiteReference;
        _ = root.TestSuiteRunner;
        _ = root.TextWindow;
        _ = root.VerboseFlags;
        _ = root.assert;
        _ = root.assertCheck;
        _ = root.assertPass;
        _ = root.assertSummaryToTestResult;
        _ = root.cleanupTextDrawing;
        _ = root.commonArg;
        _ = root.commonCreateState;
        _ = root.commonDefaultArgs;
        _ = root.commonDestroyState;
        _ = root.commonDrawWindowInfo;
        _ = root.commonEvent;
        _ = root.commonEventMainCallbacks;
        _ = root.commonInit;
        _ = root.commonLogUsage;
        _ = root.commonQuit;
        _ = root.compareMemory;
        _ = root.compareSurfaces;
        _ = root.compareSurfacesIgnoreTransparentPixels;
        _ = root.crc32Calc;
        _ = root.crc32CalcBuffer;
        _ = root.crc32CalcEnd;
        _ = root.crc32CalcStart;
        _ = root.crc32Done;
        _ = root.crc32Init;
        _ = root.createTestSuiteRunner;
        _ = root.drawCharacter;
        _ = root.drawString;
        _ = root.executeTestSuiteRunner;
        _ = root.fontCharacterSizePtr;
        _ = root.fuzzerInit;
        _ = root.generateRunSeed;
        _ = root.getFuzzerInvocationCount;
        _ = root.log;
        _ = root.logAllocations;
        _ = root.logAssertSummary;
        _ = root.logError;
        _ = root.logEscapedString;
        _ = root.logMessage;
        _ = root.md5Final;
        _ = root.md5Init;
        _ = root.md5Update;
        _ = root.printEvent;
        _ = root.randFillAllocations;
        _ = root.randomAsciiString;
        _ = root.randomAsciiStringOfSize;
        _ = root.randomAsciiStringWithMaximumLength;
        _ = root.randomDouble;
        _ = root.randomFloat;
        _ = root.randomIntegerInRange;
        _ = root.randomSint16;
        _ = root.randomSint16BoundaryValue;
        _ = root.randomSint32;
        _ = root.randomSint32BoundaryValue;
        _ = root.randomSint64;
        _ = root.randomSint64BoundaryValue;
        _ = root.randomSint8;
        _ = root.randomSint8BoundaryValue;
        _ = root.randomUint16;
        _ = root.randomUint16BoundaryValue;
        _ = root.randomUint32;
        _ = root.randomUint32BoundaryValue;
        _ = root.randomUint64;
        _ = root.randomUint64BoundaryValue;
        _ = root.randomUint8;
        _ = root.randomUint8BoundaryValue;
        _ = root.randomUnitDouble;
        _ = root.randomUnitFloat;
        _ = root.resetAssertSummary;
        _ = root.textWindowAddText;
        _ = root.textWindowAddTextWithLength;
        _ = root.textWindowClear;
        _ = root.textWindowCreate;
        _ = root.textWindowDestroy;
        _ = root.textWindowDisplay;
        _ = root.trackAllocations;
        _ = root.verbose_flags_audio;
        _ = root.verbose_flags_event;
        _ = root.verbose_flags_modes;
        _ = root.verbose_flags_motion;
        _ = root.verbose_flags_render;
        _ = root.verbose_flags_video;
    }
}
