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
    signed_max,
    unsigned_max,
    signed_size,
    unsigned_size,
    float,
    long_double,
    pointer,
    cstring,
    scan_signed_char,
    scan_unsigned_char,
    scan_signed_short,
    scan_unsigned_short,
    scan_signed_int,
    scan_unsigned_int,
    scan_signed_long,
    scan_unsigned_long,
    scan_signed_long_long,
    scan_unsigned_long_long,
    scan_signed_max,
    scan_unsigned_max,
    scan_signed_size,
    scan_unsigned_size,
    scan_float,
    scan_double,
    scan_long_double,
    scan_char,
    scan_cstring,
    scan_pointer,
};

const CVarargLength = enum { none, hh, h, l, ll, j, z, t, long_double };

const CVarargRule = struct {
    specifier: u8,
    length: CVarargLength,
    printf: ?CVarargKind,
    scanf: ?CVarargKind,
};

// Keep the conversion/type model in data. The parser below only recognizes the grammar and
// looks up one of these rows, so adding a supported length does not require another switch.
const cVarargRules = [_]CVarargRule{
    .{ .specifier = 'd', .length = .none, .printf = .signed_int, .scanf = .scan_signed_int },
    .{ .specifier = 'd', .length = .hh, .printf = .signed_int, .scanf = .scan_signed_char },
    .{ .specifier = 'd', .length = .h, .printf = .signed_int, .scanf = .scan_signed_short },
    .{ .specifier = 'd', .length = .l, .printf = .signed_long, .scanf = .scan_signed_long },
    .{ .specifier = 'd', .length = .ll, .printf = .signed_long_long, .scanf = .scan_signed_long_long },
    .{ .specifier = 'd', .length = .j, .printf = .signed_max, .scanf = .scan_signed_max },
    .{ .specifier = 'd', .length = .z, .printf = .signed_size, .scanf = .scan_signed_size },
    .{ .specifier = 'd', .length = .t, .printf = .signed_size, .scanf = .scan_signed_size },
    .{ .specifier = 'i', .length = .none, .printf = .signed_int, .scanf = .scan_signed_int },
    .{ .specifier = 'i', .length = .hh, .printf = .signed_int, .scanf = .scan_signed_char },
    .{ .specifier = 'i', .length = .h, .printf = .signed_int, .scanf = .scan_signed_short },
    .{ .specifier = 'i', .length = .l, .printf = .signed_long, .scanf = .scan_signed_long },
    .{ .specifier = 'i', .length = .ll, .printf = .signed_long_long, .scanf = .scan_signed_long_long },
    .{ .specifier = 'i', .length = .j, .printf = .signed_max, .scanf = .scan_signed_max },
    .{ .specifier = 'i', .length = .z, .printf = .signed_size, .scanf = .scan_signed_size },
    .{ .specifier = 'i', .length = .t, .printf = .signed_size, .scanf = .scan_signed_size },
    .{ .specifier = 'u', .length = .none, .printf = .unsigned_int, .scanf = .scan_unsigned_int },
    .{ .specifier = 'u', .length = .hh, .printf = .unsigned_int, .scanf = .scan_unsigned_char },
    .{ .specifier = 'u', .length = .h, .printf = .unsigned_int, .scanf = .scan_unsigned_short },
    .{ .specifier = 'u', .length = .l, .printf = .unsigned_long, .scanf = .scan_unsigned_long },
    .{ .specifier = 'u', .length = .ll, .printf = .unsigned_long_long, .scanf = .scan_unsigned_long_long },
    .{ .specifier = 'u', .length = .j, .printf = .unsigned_max, .scanf = .scan_unsigned_max },
    .{ .specifier = 'u', .length = .z, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'u', .length = .t, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'o', .length = .none, .printf = .unsigned_int, .scanf = .scan_unsigned_int },
    .{ .specifier = 'o', .length = .hh, .printf = .unsigned_int, .scanf = .scan_unsigned_char },
    .{ .specifier = 'o', .length = .h, .printf = .unsigned_int, .scanf = .scan_unsigned_short },
    .{ .specifier = 'o', .length = .l, .printf = .unsigned_long, .scanf = .scan_unsigned_long },
    .{ .specifier = 'o', .length = .ll, .printf = .unsigned_long_long, .scanf = .scan_unsigned_long_long },
    .{ .specifier = 'o', .length = .j, .printf = .unsigned_max, .scanf = .scan_unsigned_max },
    .{ .specifier = 'o', .length = .z, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'o', .length = .t, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'x', .length = .none, .printf = .unsigned_int, .scanf = .scan_unsigned_int },
    .{ .specifier = 'x', .length = .hh, .printf = .unsigned_int, .scanf = .scan_unsigned_char },
    .{ .specifier = 'x', .length = .h, .printf = .unsigned_int, .scanf = .scan_unsigned_short },
    .{ .specifier = 'x', .length = .l, .printf = .unsigned_long, .scanf = .scan_unsigned_long },
    .{ .specifier = 'x', .length = .ll, .printf = .unsigned_long_long, .scanf = .scan_unsigned_long_long },
    .{ .specifier = 'x', .length = .j, .printf = .unsigned_max, .scanf = .scan_unsigned_max },
    .{ .specifier = 'x', .length = .z, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'x', .length = .t, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'X', .length = .none, .printf = .unsigned_int, .scanf = .scan_unsigned_int },
    .{ .specifier = 'X', .length = .hh, .printf = .unsigned_int, .scanf = .scan_unsigned_char },
    .{ .specifier = 'X', .length = .h, .printf = .unsigned_int, .scanf = .scan_unsigned_short },
    .{ .specifier = 'X', .length = .l, .printf = .unsigned_long, .scanf = .scan_unsigned_long },
    .{ .specifier = 'X', .length = .ll, .printf = .unsigned_long_long, .scanf = .scan_unsigned_long_long },
    .{ .specifier = 'X', .length = .j, .printf = .unsigned_max, .scanf = .scan_unsigned_max },
    .{ .specifier = 'X', .length = .z, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'X', .length = .t, .printf = .unsigned_size, .scanf = .scan_unsigned_size },
    .{ .specifier = 'f', .length = .none, .printf = .float, .scanf = .scan_float },
    // C printf treats l with floating conversions as the default-promoted
    // double (the modifier is significant for scanf only).
    .{ .specifier = 'f', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'f', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'e', .length = .none, .printf = .float, .scanf = .scan_float },
    .{ .specifier = 'e', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'e', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'E', .length = .none, .printf = .float, .scanf = .scan_float },
    .{ .specifier = 'E', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'E', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'g', .length = .none, .printf = .float, .scanf = .scan_float },
    .{ .specifier = 'g', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'g', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'G', .length = .none, .printf = .float, .scanf = .scan_float },
    .{ .specifier = 'G', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'G', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'a', .length = .none, .printf = .float, .scanf = .scan_float },
    .{ .specifier = 'a', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'a', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'A', .length = .none, .printf = .float, .scanf = .scan_float },
    .{ .specifier = 'A', .length = .l, .printf = .float, .scanf = .scan_double },
    .{ .specifier = 'A', .length = .long_double, .printf = .long_double, .scanf = .scan_long_double },
    .{ .specifier = 'c', .length = .none, .printf = .signed_int, .scanf = .scan_char },
    .{ .specifier = 's', .length = .none, .printf = .cstring, .scanf = .scan_cstring },
    .{ .specifier = 'p', .length = .none, .printf = .pointer, .scanf = .scan_pointer },
    .{ .specifier = 'n', .length = .none, .printf = .pointer, .scanf = .scan_signed_int },
    .{ .specifier = 'n', .length = .hh, .printf = null, .scanf = .scan_signed_char },
    .{ .specifier = 'n', .length = .h, .printf = null, .scanf = .scan_signed_short },
    .{ .specifier = 'n', .length = .l, .printf = null, .scanf = .scan_signed_long },
    .{ .specifier = 'n', .length = .ll, .printf = null, .scanf = .scan_signed_long_long },
    .{ .specifier = 'n', .length = .j, .printf = null, .scanf = .scan_signed_max },
    .{ .specifier = 'n', .length = .z, .printf = null, .scanf = .scan_signed_size },
    .{ .specifier = 'n', .length = .t, .printf = null, .scanf = .scan_signed_size },
    .{ .specifier = '[', .length = .none, .printf = null, .scanf = .scan_cstring },
};

const CVarargGrammar = struct {
    flags: []const u8,
    width_star: bool,
    precision: bool,
    scanf_suppression: bool,
    scanset: bool,
};

const cPrintfFlags = [_]u8{ '-', '+', '#', '0', ' ', '\'' };
const cScanfFlags = [_]u8{};
const cPrintfGrammar = CVarargGrammar{
    .flags = &cPrintfFlags,
    .width_star = true,
    .precision = true,
    .scanf_suppression = false,
    .scanset = false,
};
const cScanfGrammar = CVarargGrammar{
    .flags = &cScanfFlags,
    .width_star = false,
    .precision = false,
    .scanf_suppression = true,
    .scanset = true,
};

fn cVarargFlagAllowed(comptime grammar: CVarargGrammar, byte: u8) bool {
    inline for (grammar.flags) |flag| if (flag == byte) return true;
    return false;
}

fn cVarargRuleFor(comptime specifier: u8, comptime length: CVarargLength, comptime scan: bool) CVarargKind {
    inline for (cVarargRules) |rule| {
        if (rule.specifier == specifier and rule.length == length) {
            if (scan) {
                if (rule.scanf) |kind| return kind;
                @compileError("unsupported C scanf length for conversion");
            } else {
                if (rule.printf) |kind| return kind;
                @compileError("unsupported C printf length for conversion");
            }
        }
    }
    @compileError("unsupported C format conversion");
}

fn cVarargScansetEnd(comptime format: [:0]const u8, comptime start: usize) usize {
    comptime var index = start;
    comptime var has_member = false;
    if (index < format.len and format[index] == '^') index += 1;
    if (index < format.len and format[index] == ']') {
        has_member = true;
        index += 1;
    }
    inline while (index < format.len and format[index] != ']') {
        has_member = true;
        index += 1;
    }
    if (index >= format.len) @compileError("malformed C scanf scanset: missing ]");
    if (!has_member) @compileError("malformed C scanf scanset: empty set");
    return index + 1;
}

fn cVarargKinds(
    comptime format: [:0]const u8,
    comptime argument_count: usize,
    comptime scan: bool,
) [argument_count]CVarargKind {
    // The table-driven conversion lookup is deliberately exhaustive. Keep its compile-time
    // evaluation independent of Zig's small default branch quota; this changes no runtime code.
    @setEvalBranchQuota(10_000);
    comptime var kinds: [argument_count]CVarargKind = undefined;
    comptime var count: usize = 0;
    comptime var index: usize = 0;
    const grammar = if (scan) cScanfGrammar else cPrintfGrammar;
    inline while (index < format.len) {
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

        // Positional arguments are not portable across SDL's supported CRTs. Reject them
        // explicitly instead of accidentally treating the index as a field width.
        comptime var positional = index;
        inline while (positional < format.len and format[positional] >= '0' and format[positional] <= '9') positional += 1;
        if (positional < format.len and format[positional] == '$') {
            @compileError("positional C format arguments are unsupported");
        }

        comptime var suppressed = false;
        if (scan and grammar.scanf_suppression and format[index] == '*') {
            suppressed = true;
            index += 1;
        }
        inline while (index < format.len and cVarargFlagAllowed(grammar, format[index])) index += 1;
        if (!scan and grammar.width_star and index < format.len and format[index] == '*') {
            if (count >= argument_count) @compileError("C format has too few arguments");
            kinds[count] = .signed_int;
            count += 1;
            index += 1;
            comptime var star_position = index;
            inline while (star_position < format.len and format[star_position] >= '0' and format[star_position] <= '9') star_position += 1;
            if (star_position < format.len and format[star_position] == '$') {
                @compileError("positional C format arguments are unsupported");
            }
        } else {
            inline while (index < format.len and format[index] >= '0' and format[index] <= '9') index += 1;
        }
        if (index < format.len and format[index] == '.') {
            if (!grammar.precision) @compileError("scanf C formats do not support precision");
            index += 1;
            if (!scan and index < format.len and format[index] == '*') {
                if (count >= argument_count) @compileError("C format has too few arguments");
                kinds[count] = .signed_int;
                count += 1;
                index += 1;
            } else {
                const precision_start = comptime index;
                inline while (index < format.len and format[index] >= '0' and format[index] <= '9') index += 1;
                if (precision_start == index) @compileError("C format precision requires digits or *");
            }
        }

        comptime var length: CVarargLength = .none;
        if (index < format.len and format[index] == 'h') {
            length = .h;
            index += 1;
            if (index < format.len and format[index] == 'h') {
                length = .hh;
                index += 1;
            }
        } else if (index < format.len and format[index] == 'l') {
            length = .l;
            index += 1;
            if (index < format.len and format[index] == 'l') {
                length = .ll;
                index += 1;
            }
        } else if (index < format.len and format[index] == 'j') {
            length = .j;
            index += 1;
        } else if (index < format.len and format[index] == 'z') {
            length = .z;
            index += 1;
        } else if (index < format.len and format[index] == 't') {
            length = .t;
            index += 1;
        } else if (index < format.len and format[index] == 'L') {
            length = .long_double;
            index += 1;
        }
        if (index >= format.len) @compileError("unterminated C format specifier");
        const specifier = format[index];
        index += 1;
        if (specifier == '[') {
            if (!scan or !grammar.scanset) @compileError("scanf scansets are not valid in printf formats");
            index = cVarargScansetEnd(format, index);
        }
        if (suppressed) continue;
        if (count >= argument_count) @compileError("C format has too few arguments");
        kinds[count] = cVarargRuleFor(specifier, length, scan);
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
            .signed_max => std.c.intmax_t,
            .unsigned_max => std.c.uintmax_t,
            .signed_size => isize,
            .unsigned_size => usize,
            .float => f64,
            .long_double => c_longdouble,
            .cstring => [*:0]const u8,
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
        .pointer => |info| info.child == u8 and (info.sentinel_ptr != null or info.size == .c),
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
    return switch (@typeInfo(argument_type)) {
        .bool, .comptime_int => true,
        .int => |info| info.bits <= @bitSizeOf(c_int),
        .optional => |info| cVarargIsDefaultInt(info.child),
        else => argument_type == c_int or argument_type == c_uint,
    };
}

fn cVarargPromoteInt(comptime target: type, value: anytype) target {
    return if (@TypeOf(value) == bool) @as(target, @intFromBool(value)) else @as(target, value);
}

fn cVarargPromoteFloat(value: anytype) f64 {
    return @floatCast(value);
}

fn cVarargValidate(comptime kind: CVarargKind, comptime argument_type: type) void {
    switch (kind) {
        .signed_int => if (comptime !cVarargIsDefaultInt(argument_type))
            @compileError("C printf integer arguments must be default-promoted to c_int"),
        .unsigned_int => if (comptime !cVarargIsDefaultInt(argument_type))
            @compileError("C printf integer arguments must be default-promoted to c_uint"),
        .signed_long => if (comptime argument_type != c_long and argument_type != comptime_int)
            @compileError("C printf %ld requires c_long"),
        .unsigned_long => if (comptime argument_type != c_ulong and argument_type != comptime_int)
            @compileError("C printf %lu requires c_ulong"),
        .signed_long_long => if (comptime argument_type != c_longlong and argument_type != comptime_int)
            @compileError("C printf %lld requires c_longlong"),
        .unsigned_long_long => if (comptime argument_type != c_ulonglong and argument_type != comptime_int)
            @compileError("C printf %llu requires c_ulonglong"),
        .signed_max => if (comptime argument_type != std.c.intmax_t and argument_type != comptime_int)
            @compileError("C printf %jd requires intmax_t"),
        .unsigned_max => if (comptime argument_type != std.c.uintmax_t and argument_type != comptime_int)
            @compileError("C printf %ju requires uintmax_t"),
        .signed_size => if (comptime argument_type != isize and argument_type != comptime_int)
            @compileError("C printf %zd requires isize"),
        .unsigned_size => if (comptime argument_type != usize and argument_type != comptime_int)
            @compileError("C printf %zu requires usize"),
        .float => if (comptime argument_type != f32 and argument_type != f64 and argument_type != comptime_float)
            @compileError("C printf floating-point arguments must be default-promoted to f64"),
        .long_double => if (comptime argument_type != c_longdouble)
            @compileError("C printf %Lf requires c_longdouble"),
        .pointer => if (comptime !cVarargIsPointer(argument_type))
            @compileError("C printf pointer arguments must be pointers"),
        .cstring => if (comptime !cVarargIsCString(argument_type))
            @compileError("C printf %s arguments must be sentinel-terminated C strings"),
        .scan_signed_char => if (comptime argument_type != *i8)
            @compileError("C scanf %hhd requires *i8"),
        .scan_unsigned_char => if (comptime argument_type != *u8)
            @compileError("C scanf %hhu requires *u8"),
        .scan_signed_short => if (comptime argument_type != *c_short)
            @compileError("C scanf %hd requires *c_short"),
        .scan_unsigned_short => if (comptime argument_type != *c_ushort)
            @compileError("C scanf %hu requires *c_ushort"),
        .scan_signed_int => if (comptime argument_type != *c_int)
            @compileError("C scanf %d requires *c_int"),
        .scan_unsigned_int => if (comptime argument_type != *c_uint)
            @compileError("C scanf %u requires *c_uint"),
        .scan_signed_long => if (comptime argument_type != *c_long)
            @compileError("C scanf %ld requires *c_long"),
        .scan_unsigned_long => if (comptime argument_type != *c_ulong)
            @compileError("C scanf %lu requires *c_ulong"),
        .scan_signed_long_long => if (comptime argument_type != *c_longlong)
            @compileError("C scanf %lld requires *c_longlong"),
        .scan_unsigned_long_long => if (comptime argument_type != *c_ulonglong)
            @compileError("C scanf %llu requires *c_ulonglong"),
        .scan_signed_max => if (comptime argument_type != *std.c.intmax_t)
            @compileError("C scanf %jd requires *intmax_t"),
        .scan_unsigned_max => if (comptime argument_type != *std.c.uintmax_t)
            @compileError("C scanf %ju requires *uintmax_t"),
        .scan_signed_size => if (comptime argument_type != *isize)
            @compileError("C scanf %zd requires *isize"),
        .scan_unsigned_size => if (comptime argument_type != *usize)
            @compileError("C scanf %zu requires *usize"),
        .scan_float => if (comptime argument_type != *f32)
            @compileError("C scanf %f requires *f32"),
        .scan_double => if (comptime argument_type != *f64)
            @compileError("C scanf %lf requires *f64"),
        .scan_long_double => if (comptime argument_type != *c_longdouble)
            @compileError("C scanf %Lf requires *c_longdouble"),
        .scan_char => if (comptime argument_type != *u8)
            @compileError("C scanf %c requires *u8"),
        .scan_cstring => if (comptime !cVarargIsWritableCString(argument_type))
            @compileError("C scanf string arguments must be writable pointers"),
        .scan_pointer => if (comptime !cVarargIsPointerToPointer(argument_type))
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
    const kinds = comptime cVarargKinds(format, args.len, scan);
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
            .signed_max => @as(std.c.intmax_t, argument),
            .unsigned_max => @as(std.c.uintmax_t, argument),
            .signed_size => @as(isize, argument),
            .unsigned_size => @as(usize, argument),
            .float => cVarargPromoteFloat(argument),
            .long_double => @as(c_longdouble, argument),
            .cstring => argument.ptr,
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

/// SDL record `Crc32Context`.
pub const Crc32Context = extern struct {
    /// Field `crc32_table`.
    crc32_table: [256]c_uint,
};

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
pub const VerboseFlags = u32;

/// Assertion functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library.
pub const assert_fail = c.ASSERT_FAIL;
/// SDL constant `ASSERT_PASS`.
pub const assert_pass = c.ASSERT_PASS;
/// SDL constant `CRC32_POLY`.
pub const crc32_poly = c.CRC32_POLY;
/// SDL constant `DEFAULT_WINDOW_HEIGHT`.
pub const default_window_height = c.DEFAULT_WINDOW_HEIGHT;
/// Common functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library.
pub const default_window_width = c.DEFAULT_WINDOW_WIDTH;
/// Include file for SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library.
pub const max_log_message_length = c.SDLTEST_MAX_LOGMESSAGE_LENGTH;
/// SDL constant `TEST_ABORTED`.
pub const test_aborted = c.TEST_ABORTED;
/// SDL constant `TEST_COMPLETED`.
pub const test_completed = c.TEST_COMPLETED;
/// SDL constant `TEST_DISABLED`.
pub const test_disabled = c.TEST_DISABLED;
/// Test suite related functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library.
pub const test_enabled = c.TEST_ENABLED;
/// SDL constant `TEST_RESULT_FAILED`.
pub const test_result_failed = c.TEST_RESULT_FAILED;
/// SDL constant `TEST_RESULT_NO_ASSERT`.
pub const test_result_no_assert = c.TEST_RESULT_NO_ASSERT;
/// SDL constant `TEST_RESULT_PASSED`.
pub const test_result_passed = c.TEST_RESULT_PASSED;
/// SDL constant `TEST_RESULT_SETUP_FAILURE`.
pub const test_result_setup_failure = c.TEST_RESULT_SETUP_FAILURE;
/// SDL constant `TEST_RESULT_SKIPPED`.
pub const test_result_skipped = c.TEST_RESULT_SKIPPED;
/// SDL constant `TEST_SKIPPED`.
pub const test_skipped = c.TEST_SKIPPED;
/// SDL constant `TEST_STARTED`.
pub const test_started = c.TEST_STARTED;

/// CRC32 functions of SDL test framework.
///
/// This code is a part of the SDL test library, not the main SDL library.
pub const crc_uint32 = u32;

/// SDL type macro `CrcUint8`.
pub const crc_uint8 = u8;

/// SDL macro FONT_LINE_HEIGHT.
pub inline fn fontLineHeight() @TypeOf(c.FONT_CHARACTER_SIZE + 2) {
    return c.FONT_CHARACTER_SIZE + 2;
}

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
pub inline fn compareMemory(actual: ?*const anyopaque, size_actual: usize, reference: ?*const anyopaque, size_reference: usize) c_int {
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
pub inline fn textWindowAddTextWithLength(textwin: ?*TextWindow, text: ?[:0]const u8, len: usize) void {
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
