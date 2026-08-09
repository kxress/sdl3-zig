const std = @import("std");
const sdl = @import("sdl");

/// Common failure set for hand-written facade APIs.
pub const Error = sdl.Error;

/// Wrap a scalar SDL result using an explicit failure sentinel.
pub fn wrapCall(comptime T: type, result: T, failure: T) Error!T {
    if (result == failure) return error.SdlFailure;
    return result;
}

/// Wrap an SDL boolean success result.
pub fn wrapCallBool(result: bool) Error!void {
    if (!result) return error.SdlFailure;
}

/// Wrap an optional pointer-like result and reject null.
pub fn wrapCallPtr(comptime T: type, result: ?T) Error!T {
    return result orelse error.SdlFailure;
}

/// Wrap a nullable sentinel C string and reject null.
pub fn wrapCallCString(result: ?[*:0]const u8) Error![*:0]const u8 {
    return result orelse error.SdlFailure;
}

/// Reject SDL's negative-count failure convention.
pub fn wrapCallCount(comptime T: type, result: T) Error!T {
    if (result < 0) return error.SdlFailure;
    return result;
}

test "error wrappers preserve successful values" {
    try std.testing.expectEqual(@as(i32, 4), try wrapCall(i32, 4, -1));
    try wrapCallBool(true);
    try std.testing.expectEqual(@as(i32, 2), try wrapCallCount(i32, 2));
}

test "error wrappers reject each failure shape" {
    try std.testing.expectError(error.SdlFailure, wrapCall(i32, -1, -1));
    try std.testing.expectError(error.SdlFailure, wrapCallBool(false));
    try std.testing.expectError(error.SdlFailure, wrapCallPtr(*anyopaque, null));
    try std.testing.expectError(error.SdlFailure, wrapCallCString(null));
    try std.testing.expectError(error.SdlFailure, wrapCallCount(i32, -1));
}
