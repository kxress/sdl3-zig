// Generated from controllerimage.h by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
const c = @import("sdl3_controller_image_c");
const sdl = @import("sdl");
const root = @This();

/// SDL handle `Device`.
pub const Device = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Dispose of a previously-created Device object.
    ///
    /// Call this once done with a device. Resources are freed and the pointer passed in here becomes invalid immediately.
    ///
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** createGamepadDevice
    /// This method invalidates the handle after ControllerImage consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.ControllerImage_DestroyDevice(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Render one of a controller's axis images to an sdl.surface.Surface.
    ///
    /// This creates a new surface with the art for a single axis. The artwork is stored as scalable vector graphics, so it can be generated at any desired size and look sharp.
    /// All artwork is generated as a square, so the requested size represents both the width and height in pixels.
    /// Since this has to allocate and rasterize an image, it's not a fast call, and should probably be done once, not every frame.
    /// This returns NULL on error, but also if there is no artwork available. For a controller missing an axis, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForAxis().
    /// The returned sdl.surface.Surface is owned by the caller, who should call sdl.surface.destroy() to dispose of it when done with it.
    ///
    /// - **Parameters:**
    ///   - `axis`: the axis on the device for which to generate an image.
    ///   - `size`: the size, in pixels, that the generated sdl.surface.Surface should be, This size is used for both the width and height.
    ///
    /// - **Returns:** a new surface on success, or NULL on error; call sdl.error_.get() for details.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** Device.getSvgForAxis
    pub inline fn createSurfaceForAxis(self: @This(), axis: sdl.gamepad.Axis, size: c_int) ?*sdl.surface.Surface {
        const result = c.ControllerImage_CreateSurfaceForAxis(@ptrCast(self.value), @intCast(@intFromEnum(axis)), size);
        return if (result == null) null else @ptrCast(result);
    }

    /// Render one of a controller's button images to an sdl.surface.Surface.
    ///
    /// This creates a new surface with the art for a single button. The artwork is stored as scalable vector graphics, so it can be generated at any desired size and look sharp.
    /// All artwork is generated as a square, so the requested size represents both the width and height in pixels.
    /// Since this has to allocate and rasterize an image, it's not a fast call, and should probably be done once, not every frame.
    /// This returns NULL on error, but also if there is no artwork available. For a controller missing a button, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForButton().
    /// The returned sdl.surface.Surface is owned by the caller, who should call sdl.surface.destroy() to dispose of it when done with it.
    ///
    /// - **Parameters:**
    ///   - `button`: the button on the device for which to generate an image.
    ///   - `size`: the size, in pixels, that the generated sdl.surface.Surface should be, This size is used for both the width and height.
    ///
    /// - **Returns:** a new surface on success, or NULL on error; call sdl.error_.get() for details.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** Device.getSvgForButton
    pub inline fn createSurfaceForButton(self: @This(), button: sdl.gamepad.Button, size: c_int) ?*sdl.surface.Surface {
        const result = c.ControllerImage_CreateSurfaceForButton(@ptrCast(self.value), @intCast(@intFromEnum(button)), size);
        return if (result == null) null else @ptrCast(result);
    }

    /// Check if artwork is available for a given axis on a specific device.
    ///
    /// Not all devices have all axes, or perhaps an artset is incomplete. This function reports if artwork for a specific axis is available.
    /// A NULL device or a bogus axis value will return false; make sure your parameters are good to get useful information!
    ///
    /// - **Parameters:**
    ///   - `axis`: the axis on the device to check for available artwork.
    ///
    /// - **Returns:** true if artwork is available, false otherwise.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** Device.hasArtworkForButton
    pub inline fn hasArtworkForAxis(self: @This(), axis: sdl.gamepad.Axis) bool {
        return c.ControllerImage_DeviceHasArtworkForAxis(@ptrCast(self.value), @intCast(@intFromEnum(axis)));
    }

    /// Check if artwork is available for a given button on a specific device.
    ///
    /// Not all devices have all buttons, or perhaps an artset is incomplete. This function reports if artwork for a specific button is available.
    /// A NULL device or a bogus button value will return false; make sure your parameters are good to get useful information!
    ///
    /// - **Parameters:**
    ///   - `button`: the button on the device to check for available artwork.
    ///
    /// - **Returns:** true if artwork is available, false otherwise.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** Device.hasArtworkForAxis
    pub inline fn hasArtworkForButton(self: @This(), button: sdl.gamepad.Button) bool {
        return c.ControllerImage_DeviceHasArtworkForButton(@ptrCast(self.value), @intCast(@intFromEnum(button)));
    }

    /// Get the device type for a Device object.
    ///
    /// Device types are short, ASCII strings that describe the controller. The strings are derived from the artset name, not anything that SDL produces.
    /// Some examples strings this function might return are "xbox360", "ps5", "joyconpair", "ouya".
    /// Generally speaking, this is *not* intended to be used to identify controllers; SDL3 has more robust facilities for this task, and this might be giving a best guess to controller type anyhow. All this tells you is what artset was chosen.
    ///
    /// - **Returns:** a NULL-terminated ASCII string, or NULL on error; call sdl.error_.get() for details.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    pub inline fn getType(self: @This()) ?[:0]const u8 {
        const result = c.ControllerImage_GetDeviceType(@ptrCast(self.value));
        return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
    }

    /// Get the raw SVG data for one axis on a controller.
    ///
    /// This can be used if the caller intends to render its own images from SVG-format data. Most apps will use Device.createSurfaceForAxis(), instead, which will handle generating the pixels internally.
    /// This returns NULL on error, but also if there is no artwork available. For a controller missing a button, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForButton().
    /// The returned string (SVG files are text-based XML files) is owned by ControllerImage, not the caller, and should not be free'd. The pointer remains valid until `device` is destroyed.
    ///
    /// - **Parameters:**
    ///   - `axis`: the axis on the device for which to obtain SVG data.
    ///
    /// - **Returns:** the raw SVG data for the image on success, or NULL on error; call sdl.error_.get() for details.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** Device.createSurfaceForAxis
    pub inline fn getSvgForAxis(self: @This(), axis: sdl.gamepad.Axis) ?[:0]const u8 {
        const result = c.ControllerImage_GetSVGForAxis(@ptrCast(self.value), @intCast(@intFromEnum(axis)));
        return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
    }

    /// Get the raw SVG data for one button on a controller.
    ///
    /// This can be used if the caller intends to render its own images from SVG-format data. Most apps will use Device.createSurfaceForButton(), instead, which will handle generating the pixels internally.
    /// This returns NULL on error, but also if there is no artwork available. For a controller missing a button, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForButton().
    /// The returned string (SVG files are text-based XML files) is owned by ControllerImage, not the caller, and should not be free'd. The pointer remains valid until `device` is destroyed.
    ///
    /// - **Parameters:**
    ///   - `button`: the button on the device for which to obtain SVG data.
    ///
    /// - **Returns:** the raw SVG data for the image on success, or NULL on error; call sdl.error_.get() for details.
    /// - **Thread safety:** This function is not thread safe.
    /// - **Since:** This function is available since ControllerImage 1.0.0.
    /// - **See also:** Device.createSurfaceForButton
    pub inline fn getSvgForButton(self: @This(), button: sdl.gamepad.Button) ?[:0]const u8 {
        const result = c.ControllerImage_GetSVGForButton(@ptrCast(self.value), @intCast(@intFromEnum(button)));
        return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
    }
};

/// Add data to the ControllerImage database.
///
/// The library needs a database of controller information to be useful. This data is external to the library and must be provided by the app. See the library's documentation on how to build the needed data file from the provided public domain assets.
/// This should be called successfully at least once before attempting to create a Device, as doing so will fail without data.
/// It is legal to call this function multiple times. If data for the same gamepad is added twice, the newer call replaces a previous call's data. This allows an app to add a "standard" database with ControllerImage's dataset for wide converage, and override the most popular controllers with a second, custom dataset to match a game's style more closely.
/// This function takes the data from a memory buffer. It must be in the format that the make-controllerimage-data.c program produces. There are also equivalent functions to load from a filename or an sdl.ioStream.IoStream.
///
/// - **Parameters:**
///   - `buf`: a pointer to a buffer that holds database data.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** addDataFromFile
/// - **See also:** addDataFromIoStream
///
/// Returns `error.SdlFailure` when ControllerImage reports failure.
pub inline fn addData(buf: []const u8) sdl.Error!void {
    if (!c.ControllerImage_AddData(@ptrCast(buf.ptr), @intCast(buf.len))) return error.SdlFailure;
}

/// Add data to the ControllerImage database from a filesystem path.
///
/// The library needs a database of controller information to be useful. This data is external to the library and must be provided by the app. See the library's documentation on how to build the needed data file from the provided public domain assets.
/// This should be called successfully at least once before attempting to create a Device, as doing so will fail without data.
/// It is legal to call this function multiple times. If data for the same gamepad is added twice, the newer call replaces a previous call's data. This allows an app to add a "standard" database with ControllerImage's dataset for wide converage, and override the most popular controllers with a second, custom dataset to match a game's style more closely.
/// This function takes the data from a filesystem path. It must be in the format that the make-controllerimage-data.c program produces. There are also equivalent functions to load from a memory buffer or an sdl.ioStream.IoStream.
///
/// - **Parameters:**
///   - `fname`: a filesystem path from which to load database data.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** addData
/// - **See also:** addDataFromIoStream
///
/// Returns `error.SdlFailure` when ControllerImage reports failure.
pub inline fn addDataFromFile(fname: ?[:0]const u8) sdl.Error!void {
    if (!c.ControllerImage_AddDataFromFile(if (fname != null) @ptrCast(fname.?.ptr) else null)) return error.SdlFailure;
}

/// Add data to the ControllerImage database from an sdl.ioStream.IoStream.
///
/// The library needs a database of controller information to be useful. This data is external to the library and must be provided by the app. See the library's documentation on how to build the needed data file from the provided public domain assets.
/// This should be called successfully at least once before attempting to create a Device, as doing so will fail without data.
/// It is legal to call this function multiple times. If data for the same gamepad is added twice, the newer call replaces a previous call's data. This allows an app to add a "standard" database with ControllerImage's dataset for wide converage, and override the most popular controllers with a second, custom dataset to match a game's style more closely.
/// This function takes the data from an sdl.ioStream.IoStream. It must be in the format that the make-controllerimage-data.c program produces. There are also equivalent functions to load from a memory buffer or a filesystem path.
/// If `closeio` is true, this function will call `sdl.ioStream.IoStream.close(io)` before returning, whether the function succeeded or not.
///
/// - **Parameters:**
///   - `io`: a stream to provide database data.
///   - `closeio`: if true, automatically close the stream when done.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** addData
/// - **See also:** addDataFromFile
///
/// Returns `error.SdlFailure` when ControllerImage reports failure.
pub inline fn addDataFromIoStream(io: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.ControllerImage_AddDataFromIOStream(@ptrCast(io), closeio)) return error.SdlFailure;
}

/// Create an device object to obtain image data for a specific gamepad.
///
/// Once a device object is created, it can be used to obtain image data, either as sdl.surface.Surface objects, or raw SVG image format strings.
/// This function uses an sdl.gamepad.Gamepad to look up data, which is convenient for preparing image data for a controller that was just opened. One can also use createGamepadDeviceByInstance() for gamepads that are not yet opened (or joysticks instead of gamepads), and createGamepadDeviceByIdString() for looking up by GUID or a standard name string.
/// When done with the returned device object, dispose of it with Device.deinit().
///
/// - **Parameters:**
///   - `gamepad`: an opened gamepad to look up.
///
/// - **Returns:** a new device object on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** createGamepadDeviceByIdString
/// - **See also:** createGamepadDeviceByInstance
/// - **See also:** Device.deinit
pub inline fn createGamepadDevice(gamepad: ?*sdl.gamepad.Gamepad) ?Device {
    const result = c.ControllerImage_CreateGamepadDevice(@ptrCast(gamepad));
    return if (result) |value| Device{ .value = @ptrCast(value) } else null;
}

/// Create an device object to obtain image data from an ID string.
///
/// Once a device object is created, it can be used to obtain image data, either as sdl.surface.Surface objects, or raw SVG image format strings.
/// This function uses a string to look up data. It can be a specific joystick's GUID or an artset name (see the directory names in art/standard/gamepad for a list). The standard strings can be useful if you always want, generically, the "xbox360" image set or whatnot. One can also use createGamepadDevice() for gamepads that are opened, and createGamepadDeviceByInstance() for gamepads that are not yet opened (or joysticks instead of gamepads).
/// When done with the returned device object, dispose of it with Device.deinit().
///
/// - **Parameters:**
///   - `str`: an SDL joystick GUID or a artset name to look up.
///
/// - **Returns:** a new device object on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** createGamepadDevice
/// - **See also:** createGamepadDeviceByInstance
/// - **See also:** Device.deinit
pub inline fn createGamepadDeviceByIdString(str: ?[:0]const u8) ?Device {
    const result = c.ControllerImage_CreateGamepadDeviceByIdString(if (str != null) @ptrCast(str.?.ptr) else null);
    return if (result) |value| Device{ .value = @ptrCast(value) } else null;
}

/// Create an device object to obtain image data for a specific sdl.joystick.Id.
///
/// Once a device object is created, it can be used to obtain image data, either as sdl.surface.Surface objects, or raw SVG image format strings.
/// This function uses an sdl.joystick.Id to look up data, which is convenient for preparing image data for a controller that hasn't yet been opened, or perhaps an SDL joystick that doesn't have a real gamepad mapping. One can also use createGamepadDevice() for gamepads that are opened, and createGamepadDeviceByIdString() for looking up by GUID or a standard name string.
/// When done with the returned device object, dispose of it with Device.deinit().
///
/// - **Parameters:**
///   - `jsid`: an SDL joystick instance to look up.
///
/// - **Returns:** a new device object on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** createGamepadDevice
/// - **See also:** createGamepadDeviceByIdString
/// - **See also:** Device.deinit
pub inline fn createGamepadDeviceByInstance(jsid: sdl.joystick.Id) ?Device {
    const result = c.ControllerImage_CreateGamepadDeviceByInstance(jsid);
    return if (result) |value| Device{ .value = @ptrCast(value) } else null;
}

/// Render one of a controller's axis images to an sdl.surface.Surface.
///
/// This creates a new surface with the art for a single axis. The artwork is stored as scalable vector graphics, so it can be generated at any desired size and look sharp.
/// All artwork is generated as a square, so the requested size represents both the width and height in pixels.
/// Since this has to allocate and rasterize an image, it's not a fast call, and should probably be done once, not every frame.
/// This returns NULL on error, but also if there is no artwork available. For a controller missing an axis, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForAxis().
/// The returned sdl.surface.Surface is owned by the caller, who should call sdl.surface.destroy() to dispose of it when done with it.
///
/// - **Parameters:**
///   - `device`: the device object for which to generate an image.
///   - `axis`: the axis on the device for which to generate an image.
///   - `size`: the size, in pixels, that the generated sdl.surface.Surface should be, This size is used for both the width and height.
///
/// - **Returns:** a new surface on success, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** Device.getSvgForAxis
pub inline fn createSurfaceForAxis(device: ?Device, axis: sdl.gamepad.Axis, size: c_int) ?*sdl.surface.Surface {
    const result = c.ControllerImage_CreateSurfaceForAxis(if (device) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(axis)), size);
    return if (result == null) null else @ptrCast(result);
}

/// Render one of a controller's button images to an sdl.surface.Surface.
///
/// This creates a new surface with the art for a single button. The artwork is stored as scalable vector graphics, so it can be generated at any desired size and look sharp.
/// All artwork is generated as a square, so the requested size represents both the width and height in pixels.
/// Since this has to allocate and rasterize an image, it's not a fast call, and should probably be done once, not every frame.
/// This returns NULL on error, but also if there is no artwork available. For a controller missing a button, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForButton().
/// The returned sdl.surface.Surface is owned by the caller, who should call sdl.surface.destroy() to dispose of it when done with it.
///
/// - **Parameters:**
///   - `device`: the device object for which to generate an image.
///   - `button`: the button on the device for which to generate an image.
///   - `size`: the size, in pixels, that the generated sdl.surface.Surface should be, This size is used for both the width and height.
///
/// - **Returns:** a new surface on success, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** Device.getSvgForButton
pub inline fn createSurfaceForButton(device: ?Device, button: sdl.gamepad.Button, size: c_int) ?*sdl.surface.Surface {
    const result = c.ControllerImage_CreateSurfaceForButton(if (device) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(button)), size);
    return if (result == null) null else @ptrCast(result);
}

/// Check if artwork is available for a given axis on a specific device.
///
/// Not all devices have all axes, or perhaps an artset is incomplete. This function reports if artwork for a specific axis is available.
/// A NULL device or a bogus axis value will return false; make sure your parameters are good to get useful information!
///
/// - **Parameters:**
///   - `device`: the device object to query.
///   - `axis`: the axis on the device to check for available artwork.
///
/// - **Returns:** true if artwork is available, false otherwise.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** Device.hasArtworkForButton
pub inline fn deviceHasArtworkForAxis(device: ?Device, axis: sdl.gamepad.Axis) bool {
    return c.ControllerImage_DeviceHasArtworkForAxis(if (device) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(axis)));
}

/// Check if artwork is available for a given button on a specific device.
///
/// Not all devices have all buttons, or perhaps an artset is incomplete. This function reports if artwork for a specific button is available.
/// A NULL device or a bogus button value will return false; make sure your parameters are good to get useful information!
///
/// - **Parameters:**
///   - `device`: the device object to query.
///   - `button`: the button on the device to check for available artwork.
///
/// - **Returns:** true if artwork is available, false otherwise.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** Device.hasArtworkForAxis
pub inline fn deviceHasArtworkForButton(device: ?Device, button: sdl.gamepad.Button) bool {
    return c.ControllerImage_DeviceHasArtworkForButton(if (device) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(button)));
}

/// Get the device type for a Device object.
///
/// Device types are short, ASCII strings that describe the controller. The strings are derived from the artset name, not anything that SDL produces.
/// Some examples strings this function might return are "xbox360", "ps5", "joyconpair", "ouya".
/// Generally speaking, this is *not* intended to be used to identify controllers; SDL3 has more robust facilities for this task, and this might be giving a best guess to controller type anyhow. All this tells you is what artset was chosen.
///
/// - **Parameters:**
///   - `device`: the device object to query.
///
/// - **Returns:** a NULL-terminated ASCII string, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
pub inline fn getDeviceType(device: ?Device) ?[:0]const u8 {
    const result = c.ControllerImage_GetDeviceType(if (device) |resource| @ptrCast(resource.value) else null);
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Get the raw SVG data for one axis on a controller.
///
/// This can be used if the caller intends to render its own images from SVG-format data. Most apps will use Device.createSurfaceForAxis(), instead, which will handle generating the pixels internally.
/// This returns NULL on error, but also if there is no artwork available. For a controller missing a button, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForButton().
/// The returned string (SVG files are text-based XML files) is owned by ControllerImage, not the caller, and should not be free'd. The pointer remains valid until `device` is destroyed.
///
/// - **Parameters:**
///   - `device`: the device object for which to obtain SVG data.
///   - `axis`: the axis on the device for which to obtain SVG data.
///
/// - **Returns:** the raw SVG data for the image on success, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** Device.createSurfaceForAxis
pub inline fn getSvgForAxis(device: ?Device, axis: sdl.gamepad.Axis) ?[:0]const u8 {
    const result = c.ControllerImage_GetSVGForAxis(if (device) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(axis)));
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Get the raw SVG data for one button on a controller.
///
/// This can be used if the caller intends to render its own images from SVG-format data. Most apps will use Device.createSurfaceForButton(), instead, which will handle generating the pixels internally.
/// This returns NULL on error, but also if there is no artwork available. For a controller missing a button, this is not necessarily an error. If the distinction is important, consider calling Device.hasArtworkForButton().
/// The returned string (SVG files are text-based XML files) is owned by ControllerImage, not the caller, and should not be free'd. The pointer remains valid until `device` is destroyed.
///
/// - **Parameters:**
///   - `device`: the device object for which to obtain SVG data.
///   - `button`: the button on the device for which to obtain SVG data.
///
/// - **Returns:** the raw SVG data for the image on success, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** Device.createSurfaceForButton
pub inline fn getSvgForButton(device: ?Device, button: sdl.gamepad.Button) ?[:0]const u8 {
    const result = c.ControllerImage_GetSVGForButton(if (device) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(button)));
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Initialize the ControllerImage library.
///
/// This must be successfully called once before (almost) any other ControllerImage function can be used.
/// It is safe to call this multiple times; the library will only initialize once, and won't deinitialize until quit() has been called a matching number of times. Extra attempts to init report success.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** quit
///
/// Returns `error.SdlFailure` when ControllerImage reports failure.
pub inline fn init() sdl.Error!void {
    if (!c.ControllerImage_Init()) return error.SdlFailure;
}

/// Returns the current datafile format version this library understands.
///
/// As the datafile format changes, this number bumps. This is the latest version the library understands. The library will continue to understand prior versions, but can't understand versions newer than this.
/// Previous data versions:
/// - 1: first public version
/// - 2: Added GUIDs lists to devices
///
/// - **Since:** This function is available since ControllerImage 1.0.0.
pub inline fn maxDatafileVersion() c_int {
    return c.ControllerImage_MaxDatafileVersion();
}

/// Deinitialize the ControllerImage library.
///
/// This must be called when done with the library, probably at the end of your program.
/// It is safe to call this multiple times; the library will only deinitialize once, when this function is called the same number of times as init() was successfully called.
/// Once you have successfully deinitialized the library, it is safe to call init() to reinitialize it for further use.
/// Any data added to the library through addData() and related functions will be deallocated.
/// This function does not automatically destroy any created Device objects that have been created. Please destroy them before deinitializing the library. sdl.surface.Surface objects generated by the library are *also* not destroyed here.
/// Once the library deinitializes, constant strings returned by various functions, like Device.getType(), Device.getSvgForButton(), and Device.getSvgForAxis(), will be deallocated, and their pointers should not be referenced again.
///
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** init
pub inline fn quit() void {
    c.ControllerImage_Quit();
}

/// Get the version of ControllerImage that is linked against your program.
///
/// If you are linking to ControllerImage dynamically, then it is possible that the current version will be different than the version you compiled against. This function returns the current version, while CONTROLLERIMAGE_VERSION is the version you compiled with.
/// This function may be called safely at any time, even before init().
///
/// - **Returns:** the version of the linked library.
/// - **Since:** This function is available since ControllerImage 1.0.0.
/// - **See also:** CONTROLLERIMAGE_VERSION
pub inline fn version() c_int {
    return c.ControllerImage_Version();
}
