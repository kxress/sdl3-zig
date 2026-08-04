// Generated from SDL3_image/SDL_image.h by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
pub const c = @import("sdl3_image_c");
const sdl = @import("sdl");
const root = @This();

/// An enum representing the status of an animation decoder.
///
/// - **Since:** This enum is available since SDL_image 3.4.0.
pub const AnimationDecoderStatus = enum(c.IMG_AnimationDecoderStatus) {
    /// The decoder is invalid
    invalid = @intCast(c.IMG_DECODER_STATUS_INVALID),
    /// The decoder is ready to decode the next frame
    ok = @intCast(c.IMG_DECODER_STATUS_OK),
    /// The decoder failed to decode a frame, call sdl.error_.get() for more information.
    failed = @intCast(c.IMG_DECODER_STATUS_FAILED),
    /// No more frames available
    complete = @intCast(c.IMG_DECODER_STATUS_COMPLETE),
    _,
};
comptime {
    if (@sizeOf(AnimationDecoderStatus) != @sizeOf(c.IMG_AnimationDecoderStatus)) @compileError("ABI size mismatch for AnimationDecoderStatus");
    if (@alignOf(AnimationDecoderStatus) != @alignOf(c.IMG_AnimationDecoderStatus)) @compileError("ABI alignment mismatch for AnimationDecoderStatus");
}

/// Animated image support
pub const Animation = extern struct {
    /// Field `w`.
    w: c_int,
    /// Field `h`.
    h: c_int,
    /// Field `count`.
    count: c_int,
    /// Field `frames`.
    frames: ?*?*sdl.surface.Surface,
    /// Field `delays`.
    delays: ?*c_int,
};
comptime {
    if (@sizeOf(Animation) != @sizeOf(c.IMG_Animation)) @compileError("ABI size mismatch for Animation");
    if (@alignOf(Animation) != @alignOf(c.IMG_Animation)) @compileError("ABI alignment mismatch for Animation");
    if (@offsetOf(Animation, "w") != @offsetOf(c.IMG_Animation, "w")) @compileError("ABI field mismatch for Animation.w");
    if (@offsetOf(Animation, "h") != @offsetOf(c.IMG_Animation, "h")) @compileError("ABI field mismatch for Animation.h");
    if (@offsetOf(Animation, "count") != @offsetOf(c.IMG_Animation, "count")) @compileError("ABI field mismatch for Animation.count");
    if (@offsetOf(Animation, "frames") != @offsetOf(c.IMG_Animation, "frames")) @compileError("ABI field mismatch for Animation.frames");
    if (@offsetOf(Animation, "delays") != @offsetOf(c.IMG_Animation, "delays")) @compileError("ABI field mismatch for Animation.delays");
}

/// SDL handle `AnimationDecoder`.
pub const AnimationDecoder = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Close an animation decoder, finishing any decoding.
    ///
    /// Calling this function frees the animation decoder, and returns the final status of the decoding process.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_image 3.4.0.
    /// - **See also:** createAnimationDecoder
    /// - **See also:** createAnimationDecoderIo
    /// - **See also:** createAnimationDecoderWithProperties
    /// This method invalidates the handle after SDL_image consumes it.
    /// Returns `error.SdlFailure` when SDL_image reports failure.
    pub inline fn close(self: *@This()) sdl.Error!void {
        const success = c.IMG_CloseAnimationDecoder(@ptrCast(self.value));
        if (!success) return error.SdlFailure;
        self.* = undefined;
    }

    /// Get the properties of an animation decoder.
    ///
    /// This function returns the properties of the animation decoder, which holds information about the underlying image such as description, copyright text and loop count.
    /// `prop_metadata_loop_count_number`, if present, specifies the number of times to play the animation, with 0 meaning loop continuously.
    ///
    /// - **Returns:** the properties ID of the animation decoder, or 0 if there are no properties; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_image 3.4.0.
    /// - **See also:** createAnimationDecoder
    /// - **See also:** createAnimationDecoderIo
    /// - **See also:** createAnimationDecoderWithProperties
    pub inline fn getProperties(self: @This()) sdl.properties.Id {
        return c.IMG_GetAnimationDecoderProperties(@ptrCast(self.value));
    }

    /// Get the decoder status indicating the current state of the decoder.
    ///
    /// - **Returns:** the status of the underlying decoder, or AnimationDecoderStatus.invalid if the given decoder is invalid.
    /// - **Since:** This function is available since SDL_image 3.4.0.
    /// - **See also:** getAnimationDecoderFrame
    pub inline fn getStatus(self: @This()) AnimationDecoderStatus {
        const result = c.IMG_GetAnimationDecoderStatus(@ptrCast(self.value));
        return @enumFromInt(result);
    }

    /// Reset an animation decoder.
    ///
    /// Calling this function resets the animation decoder, allowing it to start from the beginning again. This is useful if you want to decode the frame sequence again without creating a new decoder.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_image 3.4.0.
    /// - **See also:** createAnimationDecoder
    /// - **See also:** createAnimationDecoderIo
    /// - **See also:** createAnimationDecoderWithProperties
    /// - **See also:** getAnimationDecoderFrame
    /// - **See also:** AnimationDecoder.close
    /// Returns `error.SdlFailure` when SDL_image reports failure.
    pub inline fn reset(self: @This()) sdl.Error!void {
        if (!c.IMG_ResetAnimationDecoder(@ptrCast(self.value))) return error.SdlFailure;
    }
};

/// SDL handle `AnimationEncoder`.
pub const AnimationEncoder = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Close an animation encoder, finishing any encoding.
    ///
    /// Calling this function frees the animation encoder, and returns the final status of the encoding process.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_image 3.4.0.
    /// - **See also:** createAnimationEncoder
    /// - **See also:** createAnimationEncoderIo
    /// - **See also:** createAnimationEncoderWithProperties
    /// This method invalidates the handle after SDL_image consumes it.
    /// Returns `error.SdlFailure` when SDL_image reports failure.
    pub inline fn close(self: *@This()) sdl.Error!void {
        const success = c.IMG_CloseAnimationEncoder(@ptrCast(self.value));
        if (!success) return error.SdlFailure;
        self.* = undefined;
    }

    /// Add a frame to an animation encoder.
    ///
    /// - **Parameters:**
    ///   - `surface`: the surface to add as the next frame in the animation.
    ///   - `duration`: the duration of the frame, usually in milliseconds but can be other units if the `prop_animation_encoder_create_time_base_denominator_number` property is set when creating the encoder.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_image 3.4.0.
    /// - **See also:** createAnimationEncoder
    /// - **See also:** createAnimationEncoderIo
    /// - **See also:** createAnimationEncoderWithProperties
    /// - **See also:** AnimationEncoder.close
    /// Returns `error.SdlFailure` when SDL_image reports failure.
    pub inline fn addFrame(self: @This(), surface: ?*sdl.surface.Surface, duration: u64) sdl.Error!void {
        if (!c.IMG_AddAnimationEncoderFrame(@ptrCast(self.value), @ptrCast(surface), duration)) return error.SdlFailure;
    }
};

/// SDL constant `prop_animation_decoder_create_avif_allow_incremental_boolean`.
pub const prop_animation_decoder_create_avif_allow_incremental_boolean = c.IMG_PROP_ANIMATION_DECODER_CREATE_AVIF_ALLOW_INCREMENTAL_BOOLEAN;
/// SDL constant `prop_animation_decoder_create_avif_allow_progressive_boolean`.
pub const prop_animation_decoder_create_avif_allow_progressive_boolean = c.IMG_PROP_ANIMATION_DECODER_CREATE_AVIF_ALLOW_PROGRESSIVE_BOOLEAN;
/// SDL constant `prop_animation_decoder_create_avif_max_threads_number`.
pub const prop_animation_decoder_create_avif_max_threads_number = c.IMG_PROP_ANIMATION_DECODER_CREATE_AVIF_MAX_THREADS_NUMBER;
/// SDL constant `prop_animation_decoder_create_filename_string`.
pub const prop_animation_decoder_create_filename_string = c.IMG_PROP_ANIMATION_DECODER_CREATE_FILENAME_STRING;
/// SDL constant `prop_animation_decoder_create_gif_num_colors_number`.
pub const prop_animation_decoder_create_gif_num_colors_number = c.IMG_PROP_ANIMATION_DECODER_CREATE_GIF_NUM_COLORS_NUMBER;
/// SDL constant `prop_animation_decoder_create_gif_transparent_color_index_number`.
pub const prop_animation_decoder_create_gif_transparent_color_index_number = c.IMG_PROP_ANIMATION_DECODER_CREATE_GIF_TRANSPARENT_COLOR_INDEX_NUMBER;
/// SDL constant `prop_animation_decoder_create_io_stream_autoclose_boolean`.
pub const prop_animation_decoder_create_io_stream_autoclose_boolean = c.IMG_PROP_ANIMATION_DECODER_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN;
/// SDL constant `prop_animation_decoder_create_io_stream_pointer`.
pub const prop_animation_decoder_create_io_stream_pointer = c.IMG_PROP_ANIMATION_DECODER_CREATE_IOSTREAM_POINTER;
/// SDL constant `prop_animation_decoder_create_time_base_denominator_number`.
pub const prop_animation_decoder_create_time_base_denominator_number = c.IMG_PROP_ANIMATION_DECODER_CREATE_TIMEBASE_DENOMINATOR_NUMBER;
/// SDL constant `prop_animation_decoder_create_time_base_numerator_number`.
pub const prop_animation_decoder_create_time_base_numerator_number = c.IMG_PROP_ANIMATION_DECODER_CREATE_TIMEBASE_NUMERATOR_NUMBER;
/// SDL constant `prop_animation_decoder_create_type_string`.
pub const prop_animation_decoder_create_type_string = c.IMG_PROP_ANIMATION_DECODER_CREATE_TYPE_STRING;
/// SDL constant `prop_animation_encoder_create_avif_key_frame_interval_number`.
pub const prop_animation_encoder_create_avif_key_frame_interval_number = c.IMG_PROP_ANIMATION_ENCODER_CREATE_AVIF_KEYFRAME_INTERVAL_NUMBER;
/// SDL constant `prop_animation_encoder_create_avif_max_threads_number`.
pub const prop_animation_encoder_create_avif_max_threads_number = c.IMG_PROP_ANIMATION_ENCODER_CREATE_AVIF_MAX_THREADS_NUMBER;
/// SDL constant `prop_animation_encoder_create_filename_string`.
pub const prop_animation_encoder_create_filename_string = c.IMG_PROP_ANIMATION_ENCODER_CREATE_FILENAME_STRING;
/// SDL constant `prop_animation_encoder_create_gif_use_lut_boolean`.
pub const prop_animation_encoder_create_gif_use_lut_boolean = c.IMG_PROP_ANIMATION_ENCODER_CREATE_GIF_USE_LUT_BOOLEAN;
/// SDL constant `prop_animation_encoder_create_io_stream_autoclose_boolean`.
pub const prop_animation_encoder_create_io_stream_autoclose_boolean = c.IMG_PROP_ANIMATION_ENCODER_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN;
/// SDL constant `prop_animation_encoder_create_io_stream_pointer`.
pub const prop_animation_encoder_create_io_stream_pointer = c.IMG_PROP_ANIMATION_ENCODER_CREATE_IOSTREAM_POINTER;
/// SDL constant `prop_animation_encoder_create_quality_number`.
pub const prop_animation_encoder_create_quality_number = c.IMG_PROP_ANIMATION_ENCODER_CREATE_QUALITY_NUMBER;
/// SDL constant `prop_animation_encoder_create_time_base_denominator_number`.
pub const prop_animation_encoder_create_time_base_denominator_number = c.IMG_PROP_ANIMATION_ENCODER_CREATE_TIMEBASE_DENOMINATOR_NUMBER;
/// SDL constant `prop_animation_encoder_create_time_base_numerator_number`.
pub const prop_animation_encoder_create_time_base_numerator_number = c.IMG_PROP_ANIMATION_ENCODER_CREATE_TIMEBASE_NUMERATOR_NUMBER;
/// SDL constant `prop_animation_encoder_create_type_string`.
pub const prop_animation_encoder_create_type_string = c.IMG_PROP_ANIMATION_ENCODER_CREATE_TYPE_STRING;
/// SDL constant `prop_metadata_author_string`.
pub const prop_metadata_author_string = c.IMG_PROP_METADATA_AUTHOR_STRING;
/// SDL constant `prop_metadata_copy_right_string`.
pub const prop_metadata_copy_right_string = c.IMG_PROP_METADATA_COPYRIGHT_STRING;
/// SDL constant `prop_metadata_creation_time_string`.
pub const prop_metadata_creation_time_string = c.IMG_PROP_METADATA_CREATION_TIME_STRING;
/// SDL constant `prop_metadata_description_string`.
pub const prop_metadata_description_string = c.IMG_PROP_METADATA_DESCRIPTION_STRING;
/// SDL constant `prop_metadata_frame_count_number`.
pub const prop_metadata_frame_count_number = c.IMG_PROP_METADATA_FRAME_COUNT_NUMBER;
/// SDL constant `prop_metadata_ignore_props_boolean`.
pub const prop_metadata_ignore_props_boolean = c.IMG_PROP_METADATA_IGNORE_PROPS_BOOLEAN;
/// SDL constant `prop_metadata_loop_count_number`.
pub const prop_metadata_loop_count_number = c.IMG_PROP_METADATA_LOOP_COUNT_NUMBER;
/// SDL constant `prop_metadata_title_string`.
pub const prop_metadata_title_string = c.IMG_PROP_METADATA_TITLE_STRING;

/// Add a frame to an animation encoder.
///
/// - **Parameters:**
///   - `encoder`: the receiving images.
///   - `surface`: the surface to add as the next frame in the animation.
///   - `duration`: the duration of the frame, usually in milliseconds but can be other units if the `prop_animation_encoder_create_time_base_denominator_number` property is set when creating the encoder.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationEncoder
/// - **See also:** createAnimationEncoderIo
/// - **See also:** createAnimationEncoderWithProperties
/// - **See also:** AnimationEncoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn addAnimationEncoderFrame(encoder: ?AnimationEncoder, surface: ?*sdl.surface.Surface, duration: u64) sdl.Error!void {
    if (!c.IMG_AddAnimationEncoderFrame(if (encoder) |resource| @ptrCast(resource.value) else null, @ptrCast(surface), duration)) return error.SdlFailure;
}

/// Create an animated cursor from an animation.
///
/// - **Parameters:**
///   - `anim`: an animation to use to create an animated cursor.
///   - `hot_x`: the x position of the cursor hot spot.
///   - `hot_y`: the y position of the cursor hot spot.
///
/// - **Returns:** the new cursor on success or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimatedCursor(anim: ?*Animation, hot_x: c_int, hot_y: c_int) sdl.Error!*sdl.mouse.Cursor {
    const result = c.IMG_CreateAnimatedCursor(@ptrCast(anim), hot_x, hot_y);
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Create a decoder to read a series of images from a file.
///
/// These animation types are currently supported:
/// - ANI
/// - APNG
/// - AVIFS
/// - GIF
/// - WEBP
/// The file type is determined from the file extension, e.g. "file.webp" will be decoded using WEBP.
///
/// - **Parameters:**
///   - `file`: the file containing a series of images.
///
/// - **Returns:** a new AnimationDecoder, or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationDecoderIo
/// - **See also:** createAnimationDecoderWithProperties
/// - **See also:** getAnimationDecoderFrame
/// - **See also:** AnimationDecoder.reset
/// - **See also:** AnimationDecoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimationDecoder(file: ?[:0]const u8) sdl.Error!AnimationDecoder {
    const result = c.IMG_CreateAnimationDecoder(if (file != null) @ptrCast(file.?.ptr) else null);
    if (result == null) return error.SdlFailure;
    return AnimationDecoder{ .value = @ptrCast(result.?) };
}

/// Create a decoder to read a series of images from an IOStream.
///
/// These animation types are currently supported:
/// - ANI
/// - APNG
/// - AVIFS
/// - GIF
/// - WEBP
/// If `closeio` is true, `src` will be closed before returning if this function fails, or when the animation decoder is closed if this function succeeds.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream containing a series of images.
///   - `closeio`: true to close the sdl.ioStream.IoStream when done, false to leave it open.
///   - `type_`: a filename extension that represent this data ("WEBP", etc).
///
/// - **Returns:** a new AnimationDecoder, or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationDecoder
/// - **See also:** createAnimationDecoderWithProperties
/// - **See also:** getAnimationDecoderFrame
/// - **See also:** AnimationDecoder.reset
/// - **See also:** AnimationDecoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimationDecoderIo(src: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8) sdl.Error!AnimationDecoder {
    const result = c.IMG_CreateAnimationDecoder_IO(@ptrCast(src), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null);
    if (result == null) return error.SdlFailure;
    return AnimationDecoder{ .value = @ptrCast(result.?) };
}

/// Create an animation decoder with the specified properties.
///
/// These animation types are currently supported:
/// - ANI
/// - APNG
/// - AVIFS
/// - GIF
/// - WEBP
/// These are the supported properties:
/// - `prop_animation_decoder_create_filename_string`: the file to load, if an sdl.ioStream.IoStream isn't being used. This is required if `prop_animation_decoder_create_io_stream_pointer` isn't set.
/// - `prop_animation_decoder_create_io_stream_pointer`: an sdl.ioStream.IoStream containing a series of images. This should not be closed until the animation decoder is closed. This is required if `prop_animation_decoder_create_filename_string` isn't set.
/// - `prop_animation_decoder_create_io_stream_autoclose_boolean`: true if closing the animation decoder should also close the associated sdl.ioStream.IoStream.
/// - `prop_animation_decoder_create_type_string`: the input file type, e.g. "webp", defaults to the file extension if `prop_animation_decoder_create_filename_string` is set.
///
/// - **Parameters:**
///   - `props`: the properties of the animation decoder.
///
/// - **Returns:** a new AnimationDecoder, or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationDecoder
/// - **See also:** createAnimationDecoderIo
/// - **See also:** getAnimationDecoderFrame
/// - **See also:** AnimationDecoder.reset
/// - **See also:** AnimationDecoder.close
///
/// Returned handles are borrowed; do not call their destructive lifecycle methods.
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimationDecoderWithProperties(props: sdl.properties.Id) sdl.Error!AnimationDecoder {
    const result = c.IMG_CreateAnimationDecoderWithProperties(props);
    if (result == null) return error.SdlFailure;
    return AnimationDecoder{ .value = @ptrCast(result.?) };
}

/// Create an encoder to save a series of images to a file.
///
/// These animation types are currently supported:
/// - ANI
/// - APNG
/// - AVIFS
/// - GIF
/// - WEBP
/// The file type is determined from the file extension, e.g. "file.webp" will be encoded using WEBP.
///
/// - **Parameters:**
///   - `file`: the file where the animation will be saved.
///
/// - **Returns:** a new AnimationEncoder, or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationEncoderIo
/// - **See also:** createAnimationEncoderWithProperties
/// - **See also:** AnimationEncoder.addFrame
/// - **See also:** AnimationEncoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimationEncoder(file: ?[:0]const u8) sdl.Error!AnimationEncoder {
    const result = c.IMG_CreateAnimationEncoder(if (file != null) @ptrCast(file.?.ptr) else null);
    if (result == null) return error.SdlFailure;
    return AnimationEncoder{ .value = @ptrCast(result.?) };
}

/// Create an encoder to save a series of images to an IOStream.
///
/// These animation types are currently supported:
/// - ANI
/// - APNG
/// - AVIFS
/// - GIF
/// - WEBP
/// If `closeio` is true, `dst` will be closed before returning if this function fails, or when the animation encoder is closed if this function succeeds.
///
/// - **Parameters:**
///   - `dst`: an sdl.ioStream.IoStream that will be used to save the stream.
///   - `closeio`: true to close the sdl.ioStream.IoStream when done, false to leave it open.
///   - `type_`: a filename extension that represent this data ("WEBP", etc).
///
/// - **Returns:** a new AnimationEncoder, or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationEncoder
/// - **See also:** createAnimationEncoderWithProperties
/// - **See also:** AnimationEncoder.addFrame
/// - **See also:** AnimationEncoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimationEncoderIo(dst: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8) sdl.Error!AnimationEncoder {
    const result = c.IMG_CreateAnimationEncoder_IO(@ptrCast(dst), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null);
    if (result == null) return error.SdlFailure;
    return AnimationEncoder{ .value = @ptrCast(result.?) };
}

/// Create an animation encoder with the specified properties.
///
/// These animation types are currently supported:
/// - ANI
/// - APNG
/// - AVIFS
/// - GIF
/// - WEBP
/// These are the supported properties:
/// - `prop_animation_encoder_create_filename_string`: the file to save, if an sdl.ioStream.IoStream isn't being used. This is required if `prop_animation_encoder_create_io_stream_pointer` isn't set.
/// - `prop_animation_encoder_create_io_stream_pointer`: an sdl.ioStream.IoStream that will be used to save the stream. This should not be closed until the animation encoder is closed. This is required if `prop_animation_encoder_create_filename_string` isn't set.
/// - `prop_animation_encoder_create_io_stream_autoclose_boolean`: true if closing the animation encoder should also close the associated sdl.ioStream.IoStream.
/// - `prop_animation_encoder_create_type_string`: the output file type, e.g. "webp", defaults to the file extension if `prop_animation_encoder_create_filename_string` is set.
/// - `prop_animation_encoder_create_quality_number`: the compression quality, in the range of 0 to 100. The higher the number, the higher the quality and file size. This defaults to a balanced value for compression and quality.
/// - `prop_animation_encoder_create_time_base_numerator_number`: the numerator of the fraction used to multiply the pts to convert it to seconds. This defaults to 1.
/// - `prop_animation_encoder_create_time_base_denominator_number`: the denominator of the fraction used to multiply the pts to convert it to seconds. This defaults to 1000.
///
/// - **Parameters:**
///   - `props`: the properties of the animation encoder.
///
/// - **Returns:** a new AnimationEncoder, or NULL on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationEncoder
/// - **See also:** createAnimationEncoderIo
/// - **See also:** AnimationEncoder.addFrame
/// - **See also:** AnimationEncoder.close
///
/// Returned handles are borrowed; do not call their destructive lifecycle methods.
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn createAnimationEncoderWithProperties(props: sdl.properties.Id) sdl.Error!AnimationEncoder {
    const result = c.IMG_CreateAnimationEncoderWithProperties(props);
    if (result == null) return error.SdlFailure;
    return AnimationEncoder{ .value = @ptrCast(result.?) };
}

/// Dispose of an Animation and free its resources.
///
/// The provided `anim` pointer is not valid once this call returns.
///
/// - **Parameters:**
///   - `anim`: Animation to dispose of.
///
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
pub inline fn freeAnimation(anim: ?*Animation) void {
    c.IMG_FreeAnimation(@ptrCast(anim));
}

/// Get the next frame in an animation decoder.
///
/// This function decodes the next frame in the animation decoder, returning it as an sdl.surface.Surface. The returned surface should be freed with SDL_FreeSurface (C API outside this module)() when no longer needed.
/// If the animation decoder has no more frames or an error occurred while decoding the frame, this function returns false. In that case, please call sdl.error_.get() for more information. If sdl.error_.get() returns an empty string, that means there are no more available frames. If sdl.error_.get() returns a valid string, that means the decoding failed.
///
/// - **Parameters:**
///   - `decoder`: the animation decoder.
///   - `frame`: a pointer filled in with the sdl.surface.Surface for the next frame in the animation.
///   - `duration`: the duration of the frame, usually in milliseconds but can be other units if the `prop_animation_decoder_create_time_base_denominator_number` property is set when creating the decoder.
///
/// - **Returns:** true on success or false on failure and when no more frames are available; call AnimationDecoder.getStatus() or sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationDecoder
/// - **See also:** createAnimationDecoderIo
/// - **See also:** createAnimationDecoderWithProperties
/// - **See also:** AnimationDecoder.getStatus
/// - **See also:** AnimationDecoder.reset
/// - **See also:** AnimationDecoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn getAnimationDecoderFrame(decoder: ?AnimationDecoder, frame: ?*?*sdl.surface.Surface, duration: ?*u64) sdl.Error!void {
    if (!c.IMG_GetAnimationDecoderFrame(if (decoder) |resource| @ptrCast(resource.value) else null, @ptrCast(frame), @ptrCast(duration))) return error.SdlFailure;
}

/// Get the properties of an animation decoder.
///
/// This function returns the properties of the animation decoder, which holds information about the underlying image such as description, copyright text and loop count.
/// `prop_metadata_loop_count_number`, if present, specifies the number of times to play the animation, with 0 meaning loop continuously.
///
/// - **Parameters:**
///   - `decoder`: the animation decoder.
///
/// - **Returns:** the properties ID of the animation decoder, or 0 if there are no properties; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationDecoder
/// - **See also:** createAnimationDecoderIo
/// - **See also:** createAnimationDecoderWithProperties
pub inline fn getAnimationDecoderProperties(decoder: ?AnimationDecoder) sdl.properties.Id {
    return c.IMG_GetAnimationDecoderProperties(if (decoder) |resource| @ptrCast(resource.value) else null);
}

/// Get the decoder status indicating the current state of the decoder.
///
/// - **Parameters:**
///   - `decoder`: the decoder to get the status of.
///
/// - **Returns:** the status of the underlying decoder, or AnimationDecoderStatus.invalid if the given decoder is invalid.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** getAnimationDecoderFrame
pub inline fn getAnimationDecoderStatus(decoder: ?AnimationDecoder) AnimationDecoderStatus {
    const result = c.IMG_GetAnimationDecoderStatus(if (decoder) |resource| @ptrCast(resource.value) else null);
    return @enumFromInt(result);
}

/// Get the image currently in the clipboard.
///
/// When done with the returned surface, the app should dispose of it with a
/// call to sdl.surface.destroy().
///
/// - **Returns:** a new SDL surface, or NULL if no supported image is available.
/// - **Since:** This function is available since SDL_image 3.4.0.
pub inline fn getClipboardImage() ?*sdl.surface.Surface {
    const result = c.IMG_GetClipboardImage();
    return if (result == null) null else @ptrCast(result);
}

/// Detect ANI animated cursor data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is ANI animated cursor data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isAni(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isANI(@ptrCast(src));
}

/// Detect AVIF image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is AVIF data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isAvif(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isAVIF(@ptrCast(src));
}

/// Detect BMP image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is BMP data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isBmp(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isBMP(@ptrCast(src));
}

/// Detect CUR image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is CUR data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isCur(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isCUR(@ptrCast(src));
}

/// Detect GIF image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is GIF data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isGif(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isGIF(@ptrCast(src));
}

/// Detect ICO image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is ICO data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isIco(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isICO(@ptrCast(src));
}

/// Detect JPG image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is JPG data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isJpg(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isJPG(@ptrCast(src));
}

/// Detect JXL image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is JXL data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isJxl(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isJXL(@ptrCast(src));
}

/// Detect LBM image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is LBM data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isLbm(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isLBM(@ptrCast(src));
}

/// Detect PCX image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is PCX data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isPcx(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isPCX(@ptrCast(src));
}

/// Detect PNG image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is PNG data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isPng(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isPNG(@ptrCast(src));
}

/// Detect PNM image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is PNM data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isPnm(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isPNM(@ptrCast(src));
}

/// Detect QOI image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is QOI data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isQoi(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isQOI(@ptrCast(src));
}

/// Detect SVG image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is SVG data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isSvg(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isSVG(@ptrCast(src));
}

/// Detect TIFF image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is TIFF data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isTif(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isTIF(@ptrCast(src));
}

/// Detect WEBP image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is WEBP data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isXcf
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isWebp(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isWEBP(@ptrCast(src));
}

/// Detect XCF image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is XCF data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXpm
/// - **See also:** isXv
pub inline fn isXcf(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isXCF(@ptrCast(src));
}

/// Detect XPM image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is XPM data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXv
pub inline fn isXpm(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isXPM(@ptrCast(src));
}

/// Detect XV image data on a readable/seekable sdl.ioStream.IoStream.
///
/// This function attempts to determine if a file is a given filetype, reading the least amount possible from the sdl.ioStream.IoStream (usually a few bytes).
/// There is no distinction made between "not the filetype in question" and basic i/o errors.
/// This function will always attempt to seek `src` back to where it started when this function was called, but it will not report any errors in doing so, but assuming seeking works, this means you can immediately use this with a different IMG_isTYPE function, or load the image without further seeking.
/// You do not need to call this function to load data; SDL_image can work to determine file type in many cases in its standard load functions.
///
/// - **Parameters:**
///   - `src`: a seekable/readable sdl.ioStream.IoStream to provide image data.
///
/// - **Returns:** true if this is XV data, false otherwise.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isAni
/// - **See also:** isAvif
/// - **See also:** isBmp
/// - **See also:** isCur
/// - **See also:** isGif
/// - **See also:** isIco
/// - **See also:** isJpg
/// - **See also:** isJxl
/// - **See also:** isLbm
/// - **See also:** isPcx
/// - **See also:** isPng
/// - **See also:** isPnm
/// - **See also:** isQoi
/// - **See also:** isSvg
/// - **See also:** isTif
/// - **See also:** isWebp
/// - **See also:** isXcf
/// - **See also:** isXpm
pub inline fn isXv(src: ?*sdl.ioStream.IoStream) bool {
    return c.IMG_isXV(@ptrCast(src));
}

/// Load an image from a filesystem path into a software surface.
///
/// An sdl.surface.Surface is a buffer of pixels in memory accessible by the CPU. Use this if you plan to hand the data to something else or manipulate it further in code.
/// There are no guarantees about what format the new sdl.surface.Surface data will be; in many cases, SDL_image will attempt to supply a surface that exactly matches the provided image, but in others it might have to convert (either because the image is in a format that SDL doesn't directly support or because it's compressed data that could reasonably uncompress to various formats and SDL_image had to pick one). You can inspect an sdl.surface.Surface for its specifics, and use sdl.surface.convert to then migrate to any supported format.
/// If the image format supports a transparent pixel, SDL will set the colorkey for the surface. You can enable RLE acceleration on the surface afterwards by calling: sdl.surface.setColorKey(image, SDL_RLEACCEL (C macro outside this module), image->format->colorkey);
/// There is a separate function to read files from an sdl.ioStream.IoStream, if you need an i/o abstraction to provide data from anywhere instead of a simple filesystem read; that function is loadIo().
/// If you are using SDL's 2D rendering API, there is an equivalent call to load images directly into an sdl.render.Texture for use by the GPU without using a software surface: call loadTexture() instead.
/// When done with the returned surface, the app should dispose of it with a call to [sdl.surface.destroy](https://wiki.libsdl.org/SDL3/sdl.surface.destroy) ().
///
/// - **Parameters:**
///   - `file`: a path on the filesystem to load an image from.
///
/// - **Returns:** a new SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadTypedIo
/// - **See also:** loadIo
pub inline fn load(file: ?[:0]const u8) ?*sdl.surface.Surface {
    const result = c.IMG_Load(if (file != null) @ptrCast(file.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from an SDL data source into a software surface.
///
/// An sdl.surface.Surface is a buffer of pixels in memory accessible by the CPU. Use this if you plan to hand the data to something else or manipulate it further in code.
/// There are no guarantees about what format the new sdl.surface.Surface data will be; in many cases, SDL_image will attempt to supply a surface that exactly matches the provided image, but in others it might have to convert (either because the image is in a format that SDL doesn't directly support or because it's compressed data that could reasonably uncompress to various formats and SDL_image had to pick one). You can inspect an sdl.surface.Surface for its specifics, and use sdl.surface.convert to then migrate to any supported format.
/// If the image format supports a transparent pixel, SDL will set the colorkey for the surface. You can enable RLE acceleration on the surface afterwards by calling: sdl.surface.setColorKey(image, SDL_RLEACCEL (C macro outside this module), image->format->colorkey);
/// If `closeio` is true, `src` will be closed before returning, whether this function succeeds or not. SDL_image reads everything it needs from `src` during this call in any case.
/// There is a separate function to read files from disk without having to deal with sdl.ioStream.IoStream: `load("filename.jpg")` will call this function and manage those details for you, determining the file type from the filename's extension.
/// There is also loadTypedIo(), which is equivalent to this function except a file extension (like "BMP", "JPG", etc) can be specified, in case SDL_image cannot autodetect the file format.
/// If you are using SDL's 2D rendering API, there is an equivalent call to load images directly into an sdl.render.Texture for use by the GPU without using a software surface: call loadTextureIo() instead.
/// When done with the returned surface, the app should dispose of it with a call to sdl.surface.destroy().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** a new SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** load
/// - **See also:** loadTypedIo
pub inline fn loadIo(src: ?*sdl.ioStream.IoStream, closeio: bool) ?*sdl.surface.Surface {
    const result = c.IMG_Load_IO(@ptrCast(src), closeio);
    return if (result == null) null else @ptrCast(result);
}

/// Load an ANI animation directly from an sdl.ioStream.IoStream.
///
/// If you know you definitely have an ANI image, you can call this function, which will skip SDL_image's file format detection routines. Generally, it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
/// When done with the returned animation, the app should dispose of it with a call to freeAnimation().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream from which data will be read.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** isAni
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadAniAnimationIo(src: ?*sdl.ioStream.IoStream) ?*Animation {
    const result = c.IMG_LoadANIAnimation_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an animation from a file.
///
/// When done with the returned animation, the app should dispose of it with a call to freeAnimation().
///
/// - **Parameters:**
///   - `file`: path on the filesystem containing an animated image.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** createAnimatedCursor
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadAnimation(file: ?[:0]const u8) ?*Animation {
    const result = c.IMG_LoadAnimation(if (file != null) @ptrCast(file.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Load an animation from an sdl.ioStream.IoStream.
///
/// If `closeio` is true, `src` will be closed before returning, whether this function succeeds or not. SDL_image reads everything it needs from `src` during this call in any case.
/// When done with the returned animation, the app should dispose of it with a call to freeAnimation().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** createAnimatedCursor
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadAnimationIo(src: ?*sdl.ioStream.IoStream, closeio: bool) ?*Animation {
    const result = c.IMG_LoadAnimation_IO(@ptrCast(src), closeio);
    return if (result == null) null else @ptrCast(result);
}

/// Load an animation from an sdl.ioStream.IoStream.
///
/// Even though this function accepts a file type, SDL_image may still try other decoders that are capable of detecting file type from the contents of the image data, but may rely on the caller-provided type string for formats that it cannot autodetect. If `type_` is NULL, SDL_image will rely solely on its ability to guess the format.
/// If `closeio` is true, `src` will be closed before returning, whether this function succeeds or not. SDL_image reads everything it needs from `src` during this call in any case.
/// When done with the returned animation, the app should dispose of it with a call to freeAnimation().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `type_`: a filename extension that represent this data ("GIF", etc).
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** createAnimatedCursor
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadAnimationTypedIo(src: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8) ?*Animation {
    const result = c.IMG_LoadAnimationTyped_IO(@ptrCast(src), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Load an APNG animation directly from an sdl.ioStream.IoStream.
///
/// If you know you definitely have an APNG image, you can call this function, which will skip SDL_image's file format detection routines. Generally, it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
/// When done with the returned animation, the app should dispose of it with a call to freeAnimation().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream from which data will be read.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** isPng
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadApngAnimationIo(src: ?*sdl.ioStream.IoStream) ?*Animation {
    const result = c.IMG_LoadAPNGAnimation_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a AVIF image directly.
///
/// If you know you definitely have a AVIF image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadAvifIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadAVIF_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an AVIF animation directly from an sdl.ioStream.IoStream.
///
/// If you know you definitely have an AVIF animation, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
/// When done with the returned animation, the app should dispose of it with a call to freeAnimation().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** isAvif
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadAvifAnimationIo(src: ?*sdl.ioStream.IoStream) ?*Animation {
    const result = c.IMG_LoadAVIFAnimation_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a BMP image directly.
///
/// If you know you definitely have a BMP image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadBmpIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadBMP_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a CUR image directly.
///
/// If you know you definitely have a CUR image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadCurIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadCUR_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a GIF image directly.
///
/// If you know you definitely have a GIF image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadGifIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadGIF_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a GIF animation directly.
///
/// If you know you definitely have a GIF image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isGif
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadWebpAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadGifAnimationIo(src: ?*sdl.ioStream.IoStream) ?*Animation {
    const result = c.IMG_LoadGIFAnimation_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from a filesystem path into a GPU texture.
///
/// An sdl.gpu.Texture represents an image in GPU memory, usable by SDL's GPU API. Regardless of the source format of the image, this function will create a GPU texture with the format sdl.gpu.TextureFormat.r8g8b8a8_unorm with no mip levels. It can be bound as a sampled texture from a graphics or compute pipeline and as a a readonly storage texture in a compute pipeline.
/// There is a separate function to read files from an sdl.ioStream.IoStream, if you need an i/o abstraction to provide data from anywhere instead of a simple filesystem read; that function is loadGpuTextureIo().
/// When done with the returned texture, the app should dispose of it with a call to sdl.gpu.Texture.deinit().
///
/// - **Parameters:**
///   - `device`: the sdl.gpu.Device to use to create the GPU texture.
///   - `copy_pass`: the sdl.gpu.CopyPass to use to upload the loaded image to the GPU texture.
///   - `file`: a path on the filesystem to load an image from.
///   - `width`: a pointer filled in with the width of the GPU texture. may be NULL.
///   - `height`: a pointer filled in with the width of the GPU texture. may be NULL.
///
/// - **Returns:** a new GPU texture, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** loadGpuTextureTypedIo
/// - **See also:** loadGpuTextureIo
pub inline fn loadGpuTexture(device: ?*sdl.gpu.Device, copy_pass: ?*sdl.gpu.CopyPass, file: ?[:0]const u8, width: ?*c_int, height: ?*c_int) ?*sdl.gpu.Texture {
    const result = c.IMG_LoadGPUTexture(@ptrCast(device), @ptrCast(copy_pass), if (file != null) @ptrCast(file.?.ptr) else null, @ptrCast(width), @ptrCast(height));
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from an SDL data source into a GPU texture.
///
/// An sdl.gpu.Texture represents an image in GPU memory, usable by SDL's GPU
/// API. Regardless of the source format of the image, this function will
/// create a GPU texture with the format sdl.gpu.TextureFormat.r8g8b8a8_unorm
/// with no mip levels. It can be bound as a sampled texture from a graphics or
/// compute pipeline and as a a readonly storage texture in a compute pipeline.
///
/// If `closeio` is true, `src` will be closed before returning, whether this
/// function succeeds or not. SDL_image reads everything it needs from `src`
/// during this call in any case.
///
/// There is a separate function to read files from disk without having to deal
/// with sdl.ioStream.IoStream: `loadGpuTexture(device, copy_pass, "filename.jpg",
/// width, height) will call this function and manage those details for you,
/// determining the file type from the filename's extension.
///
/// There is also loadGpuTextureTypedIo(), which is equivalent to this
/// function except a file extension (like "BMP", "JPG", etc) can be specified,
/// in case SDL_image cannot autodetect the file format.
///
/// When done with the returned texture, the app should dispose of it with a
/// call to sdl.gpu.Texture.deinit().
///
/// - **Returns:** a new GPU texture, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** loadGpuTexture
/// - **See also:** loadGpuTextureTypedIo
/// - **Parameters:**
///
/// - `device`: the sdl.gpu.Device to use to create the GPU texture.
/// - `copy_pass`: the sdl.gpu.CopyPass to use to upload the loaded image to the GPU texture.
/// - `src`: an sdl.ioStream.IoStream that data will be read from.
/// - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
/// - `width`: a pointer filled in with the width of the GPU texture. may be NULL.
/// - `height`: a pointer filled in with the width of the GPU texture. may be NULL.
pub inline fn loadGpuTextureIo(device: ?*sdl.gpu.Device, copy_pass: ?*sdl.gpu.CopyPass, src: ?*sdl.ioStream.IoStream, closeio: bool, width: ?*c_int, height: ?*c_int) ?*sdl.gpu.Texture {
    const result = c.IMG_LoadGPUTexture_IO(@ptrCast(device), @ptrCast(copy_pass), @ptrCast(src), closeio, @ptrCast(width), @ptrCast(height));
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from an SDL data source into a GPU texture.
///
/// An sdl.gpu.Texture represents an image in GPU memory, usable by SDL's GPU
/// API. Regardless of the source format of the image, this function will
/// create a GPU texture with the format sdl.gpu.TextureFormat.r8g8b8a8_unorm
/// with no mip levels. It can be bound as a sampled texture from a graphics or
/// compute pipeline and as a a readonly storage texture in a compute pipeline.
///
/// If `closeio` is true, `src` will be closed before returning, whether this
/// function succeeds or not. SDL_image reads everything it needs from `src`
/// during this call in any case.
///
/// Even though this function accepts a file type, SDL_image may still try
/// other decoders that are capable of detecting file type from the contents of
/// the image data, but may rely on the caller-provided type string for formats
/// that it cannot autodetect. If `type_` is NULL, SDL_image will rely solely on
/// its ability to guess the format.
///
/// There is a separate function to read files from disk without having to deal
/// with sdl.ioStream.IoStream: `loadGpuTexture(device, copy_pass, "filename.jpg",
/// width, height) will call this function and manage those details for you,
/// determining the file type from the filename's extension.
///
/// There is also loadGpuTextureIo(), which is equivalent to this function
/// except that it will rely on SDL_image to determine what type of data it is
/// loading, much like passing a NULL for type.
///
/// When done with the returned texture, the app should dispose of it with a
/// call to sdl.gpu.Texture.deinit().
///
/// - **Returns:** a new GPU texture, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** loadGpuTexture
/// - **See also:** loadGpuTextureIo
/// - **Parameters:**
///
/// - `device`: the sdl.gpu.Device to use to create the GPU texture.
/// - `copy_pass`: the sdl.gpu.CopyPass to use to upload the loaded image to the GPU texture.
/// - `src`: an sdl.ioStream.IoStream that data will be read from.
/// - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
/// - `type_`: a filename extension that represent this data ("BMP", "GIF", "PNG", etc).
/// - `width`: a pointer filled in with the width of the GPU texture. may be NULL.
/// - `height`: a pointer filled in with the width of the GPU texture. may be NULL.
pub inline fn loadGpuTextureTypedIo(device: ?*sdl.gpu.Device, copy_pass: ?*sdl.gpu.CopyPass, src: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8, width: ?*c_int, height: ?*c_int) ?*sdl.gpu.Texture {
    const result = c.IMG_LoadGPUTextureTyped_IO(@ptrCast(device), @ptrCast(copy_pass), @ptrCast(src), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null, @ptrCast(width), @ptrCast(height));
    return if (result == null) null else @ptrCast(result);
}

/// Load a ICO image directly.
///
/// If you know you definitely have a ICO image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadIcoIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadICO_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a JPG image directly.
///
/// If you know you definitely have a JPG image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadJpgIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadJPG_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a JXL image directly.
///
/// If you know you definitely have a JXL image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadJxlIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadJXL_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a LBM image directly.
///
/// If you know you definitely have a LBM image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadLbmIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadLBM_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a PCX image directly.
///
/// If you know you definitely have a PCX image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadPcxIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadPCX_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a PNG image directly.
///
/// If you know you definitely have a PNG image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadPngIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadPNG_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a PNM image directly.
///
/// If you know you definitely have a PNM image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadPnmIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadPNM_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a QOI image directly.
///
/// If you know you definitely have a QOI image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadQoiIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadQOI_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an SVG image, scaled to a specific size.
///
/// Since SVG files are resolution-independent, you specify the size you would like the output image to be and it will be generated at those dimensions.
/// Either width or height may be 0 and the image will be auto-sized to preserve aspect ratio.
/// When done with the returned surface, the app should dispose of it with a call to sdl.surface.destroy().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load SVG data from.
///   - `width`: desired width of the generated surface, in pixels.
///   - `height`: desired height of the generated surface, in pixels.
///
/// - **Returns:** a new SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadSvgIo
pub inline fn loadSizedSvgIo(src: ?*sdl.ioStream.IoStream, width: c_int, height: c_int) ?*sdl.surface.Surface {
    const result = c.IMG_LoadSizedSVG_IO(@ptrCast(src), width, height);
    return if (result == null) null else @ptrCast(result);
}

/// Load a SVG image directly.
///
/// If you know you definitely have a SVG image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSizedSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadSvgIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadSVG_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from a filesystem path into a texture.
///
/// An sdl.render.Texture represents an image in GPU memory, usable by SDL's 2D Render API. This can be significantly more efficient than using a CPU-bound sdl.surface.Surface if you don't need to manipulate the image directly after loading it.
/// If the loaded image has transparency or a colorkey, a texture with an alpha channel will be created. Otherwise, SDL_image will attempt to create an sdl.render.Texture in the most format that most reasonably represents the image data (but in many cases, this will just end up being 32-bit RGB or 32-bit RGBA).
/// There is a separate function to read files from an sdl.ioStream.IoStream, if you need an i/o abstraction to provide data from anywhere instead of a simple filesystem read; that function is loadTextureIo().
/// If you would rather decode an image to an sdl.surface.Surface (a buffer of pixels in CPU memory), call load() instead.
/// When done with the returned texture, the app should dispose of it with a call to sdl.render.destroyTexture().
///
/// - **Parameters:**
///   - `renderer`: the sdl.render.Renderer to use to create the texture.
///   - `file`: a path on the filesystem to load an image from.
///
/// - **Returns:** a new texture, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadTextureTypedIo
/// - **See also:** loadTextureIo
pub inline fn loadTexture(renderer: ?*sdl.render.Renderer, file: ?[:0]const u8) ?*sdl.render.Texture {
    const result = c.IMG_LoadTexture(@ptrCast(renderer), if (file != null) @ptrCast(file.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from an SDL data source into a texture.
///
/// An sdl.render.Texture represents an image in GPU memory, usable by SDL's 2D Render API. This can be significantly more efficient than using a CPU-bound sdl.surface.Surface if you don't need to manipulate the image directly after loading it.
/// If the loaded image has transparency or a colorkey, a texture with an alpha channel will be created. Otherwise, SDL_image will attempt to create an sdl.render.Texture in the most format that most reasonably represents the image data (but in many cases, this will just end up being 32-bit RGB or 32-bit RGBA).
/// If `closeio` is true, `src` will be closed before returning, whether this function succeeds or not. SDL_image reads everything it needs from `src` during this call in any case.
/// There is a separate function to read files from disk without having to deal with sdl.ioStream.IoStream: `loadTexture(renderer, "filename.jpg")` will call this function and manage those details for you, determining the file type from the filename's extension.
/// There is also loadTextureTypedIo(), which is equivalent to this function except a file extension (like "BMP", "JPG", etc) can be specified, in case SDL_image cannot autodetect the file format.
/// If you would rather decode an image to an sdl.surface.Surface (a buffer of pixels in CPU memory), call load() instead.
/// When done with the returned texture, the app should dispose of it with a call to sdl.render.destroyTexture().
///
/// - **Parameters:**
///   - `renderer`: the sdl.render.Renderer to use to create the texture.
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** a new texture, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadTexture
/// - **See also:** loadTextureTypedIo
pub inline fn loadTextureIo(renderer: ?*sdl.render.Renderer, src: ?*sdl.ioStream.IoStream, closeio: bool) ?*sdl.render.Texture {
    const result = c.IMG_LoadTexture_IO(@ptrCast(renderer), @ptrCast(src), closeio);
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from an SDL data source into a texture.
///
/// An sdl.render.Texture represents an image in GPU memory, usable by SDL's 2D Render API. This can be significantly more efficient than using a CPU-bound sdl.surface.Surface if you don't need to manipulate the image directly after loading it.
/// If the loaded image has transparency or a colorkey, a texture with an alpha channel will be created. Otherwise, SDL_image will attempt to create an sdl.render.Texture in the most format that most reasonably represents the image data (but in many cases, this will just end up being 32-bit RGB or 32-bit RGBA).
/// If `closeio` is true, `src` will be closed before returning, whether this function succeeds or not. SDL_image reads everything it needs from `src` during this call in any case.
/// Even though this function accepts a file type, SDL_image may still try other decoders that are capable of detecting file type from the contents of the image data, but may rely on the caller-provided type string for formats that it cannot autodetect. If `type_` is NULL, SDL_image will rely solely on its ability to guess the format.
/// There is a separate function to read files from disk without having to deal with sdl.ioStream.IoStream: `loadTexture("filename.jpg")` will call this function and manage those details for you, determining the file type from the filename's extension.
/// There is also loadTextureIo(), which is equivalent to this function except that it will rely on SDL_image to determine what type of data it is loading, much like passing a NULL for type.
/// If you would rather decode an image to an sdl.surface.Surface (a buffer of pixels in CPU memory), call loadTypedIo() instead.
/// When done with the returned texture, the app should dispose of it with a call to sdl.render.destroyTexture().
///
/// - **Parameters:**
///   - `renderer`: the sdl.render.Renderer to use to create the texture.
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `type_`: a filename extension that represent this data ("BMP", "GIF", "PNG", etc).
///
/// - **Returns:** a new texture, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadTexture
/// - **See also:** loadTextureIo
pub inline fn loadTextureTypedIo(renderer: ?*sdl.render.Renderer, src: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8) ?*sdl.render.Texture {
    const result = c.IMG_LoadTextureTyped_IO(@ptrCast(renderer), @ptrCast(src), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Load a TGA image directly.
///
/// If you know you definitely have a TGA image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadTgaIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadTGA_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a TIFF image directly.
///
/// If you know you definitely have a TIFF image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadTifIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadTIF_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an image from an SDL data source into a software surface.
///
/// An sdl.surface.Surface is a buffer of pixels in memory accessible by the CPU. Use this if you plan to hand the data to something else or manipulate it further in code.
/// There are no guarantees about what format the new sdl.surface.Surface data will be; in many cases, SDL_image will attempt to supply a surface that exactly matches the provided image, but in others it might have to convert (either because the image is in a format that SDL doesn't directly support or because it's compressed data that could reasonably uncompress to various formats and SDL_image had to pick one). You can inspect an sdl.surface.Surface for its specifics, and use sdl.surface.convert to then migrate to any supported format.
/// If the image format supports a transparent pixel, SDL will set the colorkey for the surface. You can enable RLE acceleration on the surface afterwards by calling: sdl.surface.setColorKey(image, SDL_RLEACCEL (C macro outside this module), image->format->colorkey);
/// If `closeio` is true, `src` will be closed before returning, whether this function succeeds or not. SDL_image reads everything it needs from `src` during this call in any case.
/// Even though this function accepts a file type, SDL_image may still try other decoders that are capable of detecting file type from the contents of the image data, but may rely on the caller-provided type string for formats that it cannot autodetect. If `type_` is NULL, SDL_image will rely solely on its ability to guess the format.
/// There is a separate function to read files from disk without having to deal with sdl.ioStream.IoStream: `load("filename.jpg")` will call this function and manage those details for you, determining the file type from the filename's extension.
/// There is also loadIo(), which is equivalent to this function except that it will rely on SDL_image to determine what type of data it is loading, much like passing a NULL for type.
/// If you are using SDL's 2D rendering API, there is an equivalent call to load images directly into an sdl.render.Texture for use by the GPU without using a software surface: call loadTextureTypedIo() instead.
/// When done with the returned surface, the app should dispose of it with a call to sdl.surface.destroy().
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `type_`: a filename extension that represent this data ("BMP", "GIF", "PNG", etc).
///
/// - **Returns:** a new SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** load
/// - **See also:** loadIo
pub inline fn loadTypedIo(src: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8) ?*sdl.surface.Surface {
    const result = c.IMG_LoadTyped_IO(@ptrCast(src), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Load a WEBP image directly.
///
/// If you know you definitely have a WEBP image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadWebpIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadWEBP_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a WEBP animation directly.
///
/// If you know you definitely have a WEBP image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream that data will be read from.
///
/// - **Returns:** a new Animation, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** isWebp
/// - **See also:** loadAnimation
/// - **See also:** loadAnimationIo
/// - **See also:** loadAnimationTypedIo
/// - **See also:** loadAniAnimationIo
/// - **See also:** loadApngAnimationIo
/// - **See also:** loadAvifAnimationIo
/// - **See also:** loadGifAnimationIo
/// - **See also:** freeAnimation
pub inline fn loadWebpAnimationIo(src: ?*sdl.ioStream.IoStream) ?*Animation {
    const result = c.IMG_LoadWEBPAnimation_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a XCF image directly.
///
/// If you know you definitely have a XCF image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXpmIo
/// - **See also:** loadXvIo
pub inline fn loadXcfIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadXCF_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a XPM image directly.
///
/// If you know you definitely have a XPM image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXvIo
pub inline fn loadXpmIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadXPM_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load a XV image directly.
///
/// If you know you definitely have a XV image, you can call this function, which will skip SDL_image's file format detection routines. Generally it's better to use the abstract interfaces; also, there is only an sdl.ioStream.IoStream interface available here.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to load image data from.
///
/// - **Returns:** SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** loadAvifIo
/// - **See also:** loadBmpIo
/// - **See also:** loadCurIo
/// - **See also:** loadGifIo
/// - **See also:** loadIcoIo
/// - **See also:** loadJpgIo
/// - **See also:** loadJxlIo
/// - **See also:** loadLbmIo
/// - **See also:** loadPcxIo
/// - **See also:** loadPngIo
/// - **See also:** loadPnmIo
/// - **See also:** loadQoiIo
/// - **See also:** loadSvgIo
/// - **See also:** loadTgaIo
/// - **See also:** loadTifIo
/// - **See also:** loadWebpIo
/// - **See also:** loadXcfIo
/// - **See also:** loadXpmIo
pub inline fn loadXvIo(src: ?*sdl.ioStream.IoStream) ?*sdl.surface.Surface {
    const result = c.IMG_LoadXV_IO(@ptrCast(src));
    return if (result == null) null else @ptrCast(result);
}

/// Load an XPM image from a memory array.
///
/// The returned surface will be an 8bpp indexed surface, if possible, otherwise it will be 32bpp. If you always want 32-bit data, use readXpmFromArrayToRgb888() instead.
/// When done with the returned surface, the app should dispose of it with a call to sdl.surface.destroy().
///
/// - **Parameters:**
///   - `xpm`: a null-terminated array of strings that comprise XPM data.
///
/// - **Returns:** a new SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** readXpmFromArrayToRgb888
pub inline fn readXpmFromArray(xpm: ?*?[*]u8) ?*sdl.surface.Surface {
    const result = c.IMG_ReadXPMFromArray(@ptrCast(xpm));
    return if (result == null) null else @ptrCast(result);
}

/// Load an XPM image from a memory array.
///
/// The returned surface will always be a 32-bit RGB surface. If you want 8-bit indexed colors (and the XPM data allows it), use readXpmFromArray() instead.
/// When done with the returned surface, the app should dispose of it with a call to sdl.surface.destroy().
///
/// - **Parameters:**
///   - `xpm`: a null-terminated array of strings that comprise XPM data.
///
/// - **Returns:** a new SDL surface, or NULL on error.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** readXpmFromArray
pub inline fn readXpmFromArrayToRgb888(xpm: ?*?[*]u8) ?*sdl.surface.Surface {
    const result = c.IMG_ReadXPMFromArrayToRGB888(@ptrCast(xpm));
    return if (result == null) null else @ptrCast(result);
}

/// Reset an animation decoder.
///
/// Calling this function resets the animation decoder, allowing it to start from the beginning again. This is useful if you want to decode the frame sequence again without creating a new decoder.
///
/// - **Parameters:**
///   - `decoder`: the decoder to reset.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** createAnimationDecoder
/// - **See also:** createAnimationDecoderIo
/// - **See also:** createAnimationDecoderWithProperties
/// - **See also:** getAnimationDecoderFrame
/// - **See also:** AnimationDecoder.close
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn resetAnimationDecoder(decoder: ?AnimationDecoder) sdl.Error!void {
    if (!c.IMG_ResetAnimationDecoder(if (decoder) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into an image file.
///
/// If the file already exists, it will be overwritten.
/// For formats that accept a quality, a default quality of 90 will be used.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveTypedIo
/// - **See also:** saveAvif
/// - **See also:** saveBmp
/// - **See also:** saveCur
/// - **See also:** saveGif
/// - **See also:** saveIco
/// - **See also:** saveJpg
/// - **See also:** savePng
/// - **See also:** saveTga
/// - **See also:** saveWebp
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn save(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_Save(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Named output values.
pub const SaveAniAnimationIoResult = struct {
    /// Output `dst`.
    dst: sdl.ioStream.IoStream,
};

/// Save an animation in ANI format to an sdl.ioStream.IoStream.
///
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimation
/// - **See also:** saveAnimationTypedIo
/// - **See also:** saveApngAnimationIo
/// - **See also:** saveAvifAnimationIo
/// - **See also:** saveGifAnimationIo
/// - **See also:** saveWebpAnimationIo
/// Returns named output values.
pub inline fn saveAniAnimationIo(anim: ?*Animation, closeio: bool) sdl.Error!SaveAniAnimationIoResult {
    var dst_raw: @typeInfo(@typeInfo(@TypeOf(c.IMG_SaveANIAnimation_IO)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.IMG_SaveANIAnimation_IO(@ptrCast(anim), &dst_raw, closeio)) return error.SdlFailure;
    return SaveAniAnimationIoResult{
        .dst = @bitCast(dst_raw),
    };
}

/// Save an animation to a file.
///
/// For formats that accept a quality, a default quality of 90 will be used.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `file`: path on the filesystem containing an animated image.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimationTypedIo
/// - **See also:** saveAniAnimationIo
/// - **See also:** saveApngAnimationIo
/// - **See also:** saveAvifAnimationIo
/// - **See also:** saveGifAnimationIo
/// - **See also:** saveWebpAnimationIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveAnimation(anim: ?*Animation, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveAnimation(@ptrCast(anim), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Named output values.
pub const SaveAnimationTypedIoResult = struct {
    /// Output `dst`.
    dst: sdl.ioStream.IoStream,
};

/// Save an animation to an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveAnimation() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
/// For formats that accept a quality, a default quality of 90 will be used.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `type_`: a filename extension that represent this data ("GIF", etc).
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimation
/// - **See also:** saveAniAnimationIo
/// - **See also:** saveApngAnimationIo
/// - **See also:** saveAvifAnimationIo
/// - **See also:** saveGifAnimationIo
/// - **See also:** saveWebpAnimationIo
/// Returns named output values.
pub inline fn saveAnimationTypedIo(anim: ?*Animation, closeio: bool, type_: ?[:0]const u8) sdl.Error!SaveAnimationTypedIoResult {
    var dst_raw: @typeInfo(@typeInfo(@TypeOf(c.IMG_SaveAnimationTyped_IO)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.IMG_SaveAnimationTyped_IO(@ptrCast(anim), &dst_raw, closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null)) return error.SdlFailure;
    return SaveAnimationTypedIoResult{
        .dst = @bitCast(dst_raw),
    };
}

/// Named output values.
pub const SaveApngAnimationIoResult = struct {
    /// Output `dst`.
    dst: sdl.ioStream.IoStream,
};

/// Save an animation in APNG format to an sdl.ioStream.IoStream.
///
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimation
/// - **See also:** saveAnimationTypedIo
/// - **See also:** saveAniAnimationIo
/// - **See also:** saveAvifAnimationIo
/// - **See also:** saveGifAnimationIo
/// - **See also:** saveWebpAnimationIo
/// Returns named output values.
pub inline fn saveApngAnimationIo(anim: ?*Animation, closeio: bool) sdl.Error!SaveApngAnimationIoResult {
    var dst_raw: @typeInfo(@typeInfo(@TypeOf(c.IMG_SaveAPNGAnimation_IO)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.IMG_SaveAPNGAnimation_IO(@ptrCast(anim), &dst_raw, closeio)) return error.SdlFailure;
    return SaveApngAnimationIoResult{
        .dst = @bitCast(dst_raw),
    };
}

/// Save an sdl.surface.Surface into a AVIF image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///   - `quality`: the desired quality, ranging between 0 (lowest) and 100 (highest).
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** saveAvifIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveAvif(surface: ?*sdl.surface.Surface, file: ?[:0]const u8, quality: c_int) sdl.Error!void {
    if (!c.IMG_SaveAVIF(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null, quality)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into AVIF image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveAvif() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `quality`: the desired quality, ranging between 0 (lowest) and 100 (highest).
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** saveAvif
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveAvifIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool, quality: c_int) sdl.Error!void {
    if (!c.IMG_SaveAVIF_IO(@ptrCast(surface), @ptrCast(dst), closeio, quality)) return error.SdlFailure;
}

/// Named output values.
pub const SaveAvifAnimationIoResult = struct {
    /// Output `dst`.
    dst: sdl.ioStream.IoStream,
};

/// Save an animation in AVIF format to an sdl.ioStream.IoStream.
///
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `quality`: the desired quality, ranging between 0 (lowest) and 100 (highest).
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimation
/// - **See also:** saveAnimationTypedIo
/// - **See also:** saveAniAnimationIo
/// - **See also:** saveApngAnimationIo
/// - **See also:** saveGifAnimationIo
/// - **See also:** saveWebpAnimationIo
/// Returns named output values.
pub inline fn saveAvifAnimationIo(anim: ?*Animation, closeio: bool, quality: c_int) sdl.Error!SaveAvifAnimationIoResult {
    var dst_raw: @typeInfo(@typeInfo(@TypeOf(c.IMG_SaveAVIFAnimation_IO)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.IMG_SaveAVIFAnimation_IO(@ptrCast(anim), &dst_raw, closeio, quality)) return error.SdlFailure;
    return SaveAvifAnimationIoResult{
        .dst = @bitCast(dst_raw),
    };
}

/// Save an sdl.surface.Surface into a BMP image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveBmpIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveBmp(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveBMP(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into BMP image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveBmp() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveBmp
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveBmpIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.IMG_SaveBMP_IO(@ptrCast(surface), @ptrCast(dst), closeio)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into a CUR image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveCurIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveCur(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveCUR(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into CUR image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveCur() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveCur
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveCurIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.IMG_SaveCUR_IO(@ptrCast(surface), @ptrCast(dst), closeio)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into a GIF image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveGifIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveGif(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveGIF(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into GIF image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveGif() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveGif
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveGifIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.IMG_SaveGIF_IO(@ptrCast(surface), @ptrCast(dst), closeio)) return error.SdlFailure;
}

/// Named output values.
pub const SaveGifAnimationIoResult = struct {
    /// Output `dst`.
    dst: sdl.ioStream.IoStream,
};

/// Save an animation in GIF format to an sdl.ioStream.IoStream.
///
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimation
/// - **See also:** saveAnimationTypedIo
/// - **See also:** saveAniAnimationIo
/// - **See also:** saveApngAnimationIo
/// - **See also:** saveAvifAnimationIo
/// - **See also:** saveWebpAnimationIo
/// Returns named output values.
pub inline fn saveGifAnimationIo(anim: ?*Animation, closeio: bool) sdl.Error!SaveGifAnimationIoResult {
    var dst_raw: @typeInfo(@typeInfo(@TypeOf(c.IMG_SaveGIFAnimation_IO)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.IMG_SaveGIFAnimation_IO(@ptrCast(anim), &dst_raw, closeio)) return error.SdlFailure;
    return SaveGifAnimationIoResult{
        .dst = @bitCast(dst_raw),
    };
}

/// Save an sdl.surface.Surface into a ICO image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveIcoIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveIco(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveICO(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into ICO image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveIco() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveIco
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveIcoIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.IMG_SaveICO_IO(@ptrCast(surface), @ptrCast(dst), closeio)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into a JPEG image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///   - `quality`: [0; 33] is Lowest quality, [34; 66] is Middle quality, [67; 100] is Highest quality.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** saveJpgIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveJpg(surface: ?*sdl.surface.Surface, file: ?[:0]const u8, quality: c_int) sdl.Error!void {
    if (!c.IMG_SaveJPG(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null, quality)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into JPEG image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveJpg() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `quality`: [0; 33] is Lowest quality, [34; 66] is Middle quality, [67; 100] is Highest quality.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** saveJpg
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveJpgIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool, quality: c_int) sdl.Error!void {
    if (!c.IMG_SaveJPG_IO(@ptrCast(surface), @ptrCast(dst), closeio, quality)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into a PNG image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** savePngIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn savePng(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SavePNG(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into PNG image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use savePng() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.0.0.
/// - **See also:** savePng
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn savePngIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.IMG_SavePNG_IO(@ptrCast(surface), @ptrCast(dst), closeio)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into a TGA image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write new file to.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveTgaIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveTga(surface: ?*sdl.surface.Surface, file: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveTGA(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into TGA image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveTga() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveTga
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveTgaIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.IMG_SaveTGA_IO(@ptrCast(surface), @ptrCast(dst), closeio)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into formatted image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use save() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
/// For formats that accept a quality, a default quality of 90 will be used.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `type_`: a filename extension that represent this data ("BMP", "GIF", "PNG", etc).
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** save
/// - **See also:** saveAvifIo
/// - **See also:** saveBmpIo
/// - **See also:** saveCurIo
/// - **See also:** saveGifIo
/// - **See also:** saveIcoIo
/// - **See also:** saveJpgIo
/// - **See also:** savePngIo
/// - **See also:** saveTgaIo
/// - **See also:** saveWebpIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveTypedIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool, type_: ?[:0]const u8) sdl.Error!void {
    if (!c.IMG_SaveTyped_IO(@ptrCast(surface), @ptrCast(dst), closeio, if (type_ != null) @ptrCast(type_.?.ptr) else null)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into a WEBP image file.
///
/// If the file already exists, it will be overwritten.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `file`: path on the filesystem to write the new file to.
///   - `quality`: between 0 and 100. For lossy, 0 gives the smallest size and 100 the largest. For lossless, this parameter is the amount of effort put into the compression: 0 is the fastest but gives larger files compared to the slowest, but best, 100.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveWebpIo
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveWebp(surface: ?*sdl.surface.Surface, file: ?[:0]const u8, quality: f32) sdl.Error!void {
    if (!c.IMG_SaveWEBP(@ptrCast(surface), if (file != null) @ptrCast(file.?.ptr) else null, quality)) return error.SdlFailure;
}

/// Save an sdl.surface.Surface into WEBP image data, via an sdl.ioStream.IoStream.
///
/// If you just want to save to a filename, you can use saveWebp() instead.
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `surface`: the SDL surface to save.
///   - `dst`: the sdl.ioStream.IoStream to save the image data to.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `quality`: between 0 and 100. For lossy, 0 gives the smallest size and 100 the largest. For lossless, this parameter is the amount of effort put into the compression: 0 is the fastest but gives larger files compared to the slowest, but best, 100.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveWebp
///
/// Returns `error.SdlFailure` when SDL_image reports failure.
pub inline fn saveWebpIo(surface: ?*sdl.surface.Surface, dst: ?*sdl.ioStream.IoStream, closeio: bool, quality: f32) sdl.Error!void {
    if (!c.IMG_SaveWEBP_IO(@ptrCast(surface), @ptrCast(dst), closeio, quality)) return error.SdlFailure;
}

/// Named output values.
pub const SaveWebpAnimationIoResult = struct {
    /// Output `dst`.
    dst: sdl.ioStream.IoStream,
};

/// Save an animation in WEBP format to an sdl.ioStream.IoStream.
///
/// If `closeio` is true, `dst` will be closed before returning, whether this function succeeds or not.
///
/// - **Parameters:**
///   - `anim`: the animation to save.
///   - `closeio`: true to close/free the sdl.ioStream.IoStream before returning, false to leave it open.
///   - `quality`: between 0 and 100. For lossy, 0 gives the smallest size and 100 the largest. For lossless, this parameter is the amount of effort put into the compression: 0 is the fastest but gives larger files compared to the slowest, but best, 100.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_image 3.4.0.
/// - **See also:** saveAnimation
/// - **See also:** saveAnimationTypedIo
/// - **See also:** saveAniAnimationIo
/// - **See also:** saveApngAnimationIo
/// - **See also:** saveAvifAnimationIo
/// - **See also:** saveGifAnimationIo
/// Returns named output values.
pub inline fn saveWebpAnimationIo(anim: ?*Animation, closeio: bool, quality: c_int) sdl.Error!SaveWebpAnimationIoResult {
    var dst_raw: @typeInfo(@typeInfo(@TypeOf(c.IMG_SaveWEBPAnimation_IO)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.IMG_SaveWEBPAnimation_IO(@ptrCast(anim), &dst_raw, closeio, quality)) return error.SdlFailure;
    return SaveWebpAnimationIoResult{
        .dst = @bitCast(dst_raw),
    };
}

/// This function gets the version of the dynamically linked SDL_image library.
///
/// - **Returns:** SDL_image version.
/// - **Since:** This function is available since SDL_image 3.0.0.
pub inline fn version() c_int {
    return c.IMG_Version();
}

// Force target-specific public declarations through Zig's lazy analysis.
comptime {
    if (builtin.abi == .android or builtin.abi == .androideabi) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
    if (builtin.os.tag == .emscripten) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
    if (builtin.os.tag == .ios) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
    if (builtin.os.tag == .linux) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
    if (builtin.os.tag == .macos) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
    if (builtin.os.tag == .tvos) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
    if (builtin.os.tag == .windows) {
        _ = root.Animation;
        _ = root.AnimationDecoder;
        _ = root.AnimationDecoderStatus;
        _ = root.AnimationEncoder;
        _ = root.addAnimationEncoderFrame;
        _ = root.createAnimatedCursor;
        _ = root.createAnimationDecoder;
        _ = root.createAnimationDecoderIo;
        _ = root.createAnimationDecoderWithProperties;
        _ = root.createAnimationEncoder;
        _ = root.createAnimationEncoderIo;
        _ = root.createAnimationEncoderWithProperties;
        _ = root.freeAnimation;
        _ = root.getAnimationDecoderFrame;
        _ = root.getAnimationDecoderProperties;
        _ = root.getAnimationDecoderStatus;
        _ = root.getClipboardImage;
        _ = root.isAni;
        _ = root.isAvif;
        _ = root.isBmp;
        _ = root.isCur;
        _ = root.isGif;
        _ = root.isIco;
        _ = root.isJpg;
        _ = root.isJxl;
        _ = root.isLbm;
        _ = root.isPcx;
        _ = root.isPng;
        _ = root.isPnm;
        _ = root.isQoi;
        _ = root.isSvg;
        _ = root.isTif;
        _ = root.isWebp;
        _ = root.isXcf;
        _ = root.isXpm;
        _ = root.isXv;
        _ = root.load;
        _ = root.loadAniAnimationIo;
        _ = root.loadAnimation;
        _ = root.loadAnimationIo;
        _ = root.loadAnimationTypedIo;
        _ = root.loadApngAnimationIo;
        _ = root.loadAvifAnimationIo;
        _ = root.loadAvifIo;
        _ = root.loadBmpIo;
        _ = root.loadCurIo;
        _ = root.loadGifAnimationIo;
        _ = root.loadGifIo;
        _ = root.loadGpuTexture;
        _ = root.loadGpuTextureIo;
        _ = root.loadGpuTextureTypedIo;
        _ = root.loadIcoIo;
        _ = root.loadIo;
        _ = root.loadJpgIo;
        _ = root.loadJxlIo;
        _ = root.loadLbmIo;
        _ = root.loadPcxIo;
        _ = root.loadPngIo;
        _ = root.loadPnmIo;
        _ = root.loadQoiIo;
        _ = root.loadSizedSvgIo;
        _ = root.loadSvgIo;
        _ = root.loadTexture;
        _ = root.loadTextureIo;
        _ = root.loadTextureTypedIo;
        _ = root.loadTgaIo;
        _ = root.loadTifIo;
        _ = root.loadTypedIo;
        _ = root.loadWebpAnimationIo;
        _ = root.loadWebpIo;
        _ = root.loadXcfIo;
        _ = root.loadXpmIo;
        _ = root.loadXvIo;
        _ = root.prop_animation_decoder_create_avif_allow_incremental_boolean;
        _ = root.prop_animation_decoder_create_avif_allow_progressive_boolean;
        _ = root.prop_animation_decoder_create_avif_max_threads_number;
        _ = root.prop_animation_decoder_create_filename_string;
        _ = root.prop_animation_decoder_create_gif_num_colors_number;
        _ = root.prop_animation_decoder_create_gif_transparent_color_index_number;
        _ = root.prop_animation_decoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_decoder_create_io_stream_pointer;
        _ = root.prop_animation_decoder_create_time_base_denominator_number;
        _ = root.prop_animation_decoder_create_time_base_numerator_number;
        _ = root.prop_animation_decoder_create_type_string;
        _ = root.prop_animation_encoder_create_avif_key_frame_interval_number;
        _ = root.prop_animation_encoder_create_avif_max_threads_number;
        _ = root.prop_animation_encoder_create_filename_string;
        _ = root.prop_animation_encoder_create_gif_use_lut_boolean;
        _ = root.prop_animation_encoder_create_io_stream_autoclose_boolean;
        _ = root.prop_animation_encoder_create_io_stream_pointer;
        _ = root.prop_animation_encoder_create_quality_number;
        _ = root.prop_animation_encoder_create_time_base_denominator_number;
        _ = root.prop_animation_encoder_create_time_base_numerator_number;
        _ = root.prop_animation_encoder_create_type_string;
        _ = root.prop_metadata_author_string;
        _ = root.prop_metadata_copy_right_string;
        _ = root.prop_metadata_creation_time_string;
        _ = root.prop_metadata_description_string;
        _ = root.prop_metadata_frame_count_number;
        _ = root.prop_metadata_ignore_props_boolean;
        _ = root.prop_metadata_loop_count_number;
        _ = root.prop_metadata_title_string;
        _ = root.readXpmFromArray;
        _ = root.readXpmFromArrayToRgb888;
        _ = root.resetAnimationDecoder;
        _ = root.save;
        _ = root.saveAniAnimationIo;
        _ = root.saveAnimation;
        _ = root.saveAnimationTypedIo;
        _ = root.saveApngAnimationIo;
        _ = root.saveAvif;
        _ = root.saveAvifAnimationIo;
        _ = root.saveAvifIo;
        _ = root.saveBmp;
        _ = root.saveBmpIo;
        _ = root.saveCur;
        _ = root.saveCurIo;
        _ = root.saveGif;
        _ = root.saveGifAnimationIo;
        _ = root.saveGifIo;
        _ = root.saveIco;
        _ = root.saveIcoIo;
        _ = root.saveJpg;
        _ = root.saveJpgIo;
        _ = root.savePng;
        _ = root.savePngIo;
        _ = root.saveTga;
        _ = root.saveTgaIo;
        _ = root.saveTypedIo;
        _ = root.saveWebp;
        _ = root.saveWebpAnimationIo;
        _ = root.saveWebpIo;
        _ = root.version;
    }
}
