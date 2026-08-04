// Generated from SDL3_ttf public headers by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
pub const c = @import("sdl3_ttf_c");
const sdl = @import("sdl");
const root = @This();

/// Direction flags
///
/// The values here are chosen to match [hb_direction_t](https://harfbuzz.github.io/harfbuzz-hb-common.html#hb-direction-t) **Since:** This enum is available since SDL_ttf 3.0.0.
///
/// - **See also:** Font.setDirection
pub const Direction = enum(c.TTF_Direction) {
    /// Enumeration value `Direction.invalid`.
    invalid = @intCast(c.TTF_DIRECTION_INVALID),
    /// Left to Right
    ltr = @intCast(c.TTF_DIRECTION_LTR),
    /// Right to Left
    rtl = @intCast(c.TTF_DIRECTION_RTL),
    /// Top to Bottom
    ttb = @intCast(c.TTF_DIRECTION_TTB),
    /// Bottom to Top
    btt = @intCast(c.TTF_DIRECTION_BTT),
    _,
};
comptime {
    if (@sizeOf(Direction) != @sizeOf(c.TTF_Direction)) @compileError("ABI size mismatch for Direction");
    if (@alignOf(Direction) != @alignOf(c.TTF_Direction)) @compileError("ABI alignment mismatch for Direction");
}

/// A font atlas draw command.
///
/// - **Since:** This enum is available since SDL_ttf 3.0.0.
const DrawCommand = enum(c.TTF_DrawCommand) {
    /// Enumeration value `textengine.DrawCommand.noop`.
    noop = @intCast(c.TTF_DRAW_COMMAND_NOOP),
    /// Enumeration value `textengine.DrawCommand.fill`.
    fill = @intCast(c.TTF_DRAW_COMMAND_FILL),
    /// Enumeration value `textengine.DrawCommand.copy`.
    copy = @intCast(c.TTF_DRAW_COMMAND_COPY),
    _,
};
comptime {
    if (@sizeOf(DrawCommand) != @sizeOf(c.TTF_DrawCommand)) @compileError("ABI size mismatch for DrawCommand");
    if (@alignOf(DrawCommand) != @alignOf(c.TTF_DrawCommand)) @compileError("ABI alignment mismatch for DrawCommand");
}

/// The winding order of the vertices returned by getGpuTextDrawData
///
/// - **Since:** This enum is available since SDL_ttf 3.0.0.
pub const GpuTextEngineWinding = enum(c.TTF_GPUTextEngineWinding) {
    /// Enumeration value `GpuTextEngineWinding.invalid`.
    invalid = @intCast(c.TTF_GPU_TEXTENGINE_WINDING_INVALID),
    /// Enumeration value `GpuTextEngineWinding.clockwise`.
    clockwise = @intCast(c.TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE),
    /// Enumeration value `GpuTextEngineWinding.counter_clockwise`.
    counter_clockwise = @intCast(c.TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE),
    _,
};
comptime {
    if (@sizeOf(GpuTextEngineWinding) != @sizeOf(c.TTF_GPUTextEngineWinding)) @compileError("ABI size mismatch for GpuTextEngineWinding");
    if (@alignOf(GpuTextEngineWinding) != @alignOf(c.TTF_GPUTextEngineWinding)) @compileError("ABI alignment mismatch for GpuTextEngineWinding");
}

/// Hinting flags for TTF (TrueType Fonts)
///
/// This enum specifies the level of hinting to be applied to the font rendering. The hinting level determines how much the font's outlines are adjusted for better alignment on the pixel grid.
///
/// - **Since:** This enum is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setHinting
/// - **See also:** Font.getHinting
pub const HintingFlags = enum(c.TTF_HintingFlags) {
    /// Enumeration value `HintingFlags.invalid`.
    invalid = @intCast(c.TTF_HINTING_INVALID),
    /// Normal hinting applies standard grid-fitting.
    normal = @intCast(c.TTF_HINTING_NORMAL),
    /// Light hinting applies subtle adjustments to improve rendering.
    light = @intCast(c.TTF_HINTING_LIGHT),
    /// Monochrome hinting adjusts the font for better rendering at lower resolutions.
    mono = @intCast(c.TTF_HINTING_MONO),
    /// No hinting, the font is rendered without any grid-fitting.
    none = @intCast(c.TTF_HINTING_NONE),
    /// Light hinting with subpixel rendering for more precise font edges.
    light_sub_pixel = @intCast(c.TTF_HINTING_LIGHT_SUBPIXEL),
    _,
};
comptime {
    if (@sizeOf(HintingFlags) != @sizeOf(c.TTF_HintingFlags)) @compileError("ABI size mismatch for HintingFlags");
    if (@alignOf(HintingFlags) != @alignOf(c.TTF_HintingFlags)) @compileError("ABI alignment mismatch for HintingFlags");
}

/// The horizontal alignment used when rendering wrapped text.
///
/// - **Since:** This enum is available since SDL_ttf 3.0.0.
pub const HorizontalAlignment = enum(c.TTF_HorizontalAlignment) {
    /// Enumeration value `HorizontalAlignment.invalid`.
    invalid = @intCast(c.TTF_HORIZONTAL_ALIGN_INVALID),
    /// Enumeration value `HorizontalAlignment.left`.
    left = @intCast(c.TTF_HORIZONTAL_ALIGN_LEFT),
    /// Enumeration value `HorizontalAlignment.center`.
    center = @intCast(c.TTF_HORIZONTAL_ALIGN_CENTER),
    /// Enumeration value `HorizontalAlignment.right`.
    right = @intCast(c.TTF_HORIZONTAL_ALIGN_RIGHT),
    _,
};
comptime {
    if (@sizeOf(HorizontalAlignment) != @sizeOf(c.TTF_HorizontalAlignment)) @compileError("ABI size mismatch for HorizontalAlignment");
    if (@alignOf(HorizontalAlignment) != @alignOf(c.TTF_HorizontalAlignment)) @compileError("ABI alignment mismatch for HorizontalAlignment");
}

/// The type of data in a glyph image
///
/// - **Since:** This enum is available since SDL_ttf 3.0.0.
pub const ImageType = enum(c.TTF_ImageType) {
    /// Enumeration value `ImageType.invalid`.
    invalid = @intCast(c.TTF_IMAGE_INVALID),
    /// The color channels are white
    alpha = @intCast(c.TTF_IMAGE_ALPHA),
    /// The color channels have image data
    color = @intCast(c.TTF_IMAGE_COLOR),
    /// The alpha channel has signed distance field information
    sdf = @intCast(c.TTF_IMAGE_SDF),
    _,
};
comptime {
    if (@sizeOf(ImageType) != @sizeOf(c.TTF_ImageType)) @compileError("ABI size mismatch for ImageType");
    if (@alignOf(ImageType) != @alignOf(c.TTF_ImageType)) @compileError("ABI alignment mismatch for ImageType");
}

/// A texture copy draw operation.
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
/// - **See also:** textengine.DrawOperation
const CopyOperation = extern struct {
    /// Field `cmd`.
    cmd: DrawCommand,
    /// Field `text_offset`.
    text_offset: c_int,
    /// Field `glyph_font`.
    glyph_font: ?*anyopaque,
    /// Field `glyph_index`.
    glyph_index: u32,
    /// Field `src`.
    src: sdl.rect.Rect,
    /// Field `dst`.
    dst: sdl.rect.Rect,
    /// Field `reserved`.
    reserved: ?*anyopaque,
};
comptime {
    if (@sizeOf(CopyOperation) != @sizeOf(c.TTF_CopyOperation)) @compileError("ABI size mismatch for CopyOperation");
    if (@alignOf(CopyOperation) != @alignOf(c.TTF_CopyOperation)) @compileError("ABI alignment mismatch for CopyOperation");
    if (@offsetOf(CopyOperation, "cmd") != @offsetOf(c.TTF_CopyOperation, "cmd")) @compileError("ABI field mismatch for CopyOperation.cmd");
    if (@offsetOf(CopyOperation, "text_offset") != @offsetOf(c.TTF_CopyOperation, "text_offset")) @compileError("ABI field mismatch for CopyOperation.text_offset");
    if (@offsetOf(CopyOperation, "glyph_font") != @offsetOf(c.TTF_CopyOperation, "glyph_font")) @compileError("ABI field mismatch for CopyOperation.glyph_font");
    if (@offsetOf(CopyOperation, "glyph_index") != @offsetOf(c.TTF_CopyOperation, "glyph_index")) @compileError("ABI field mismatch for CopyOperation.glyph_index");
    if (@offsetOf(CopyOperation, "src") != @offsetOf(c.TTF_CopyOperation, "src")) @compileError("ABI field mismatch for CopyOperation.src");
    if (@offsetOf(CopyOperation, "dst") != @offsetOf(c.TTF_CopyOperation, "dst")) @compileError("ABI field mismatch for CopyOperation.dst");
    if (@offsetOf(CopyOperation, "reserved") != @offsetOf(c.TTF_CopyOperation, "reserved")) @compileError("ABI field mismatch for CopyOperation.reserved");
}

/// A filled rectangle draw operation.
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
/// - **See also:** textengine.DrawOperation
const FillOperation = extern struct {
    /// Field `cmd`.
    cmd: DrawCommand,
    /// Field `rect`.
    rect: sdl.rect.Rect,
};
comptime {
    if (@sizeOf(FillOperation) != @sizeOf(c.TTF_FillOperation)) @compileError("ABI size mismatch for FillOperation");
    if (@alignOf(FillOperation) != @alignOf(c.TTF_FillOperation)) @compileError("ABI alignment mismatch for FillOperation");
    if (@offsetOf(FillOperation, "cmd") != @offsetOf(c.TTF_FillOperation, "cmd")) @compileError("ABI field mismatch for FillOperation.cmd");
    if (@offsetOf(FillOperation, "rect") != @offsetOf(c.TTF_FillOperation, "rect")) @compileError("ABI field mismatch for FillOperation.rect");
}

/// SDL handle `Font`.
pub const Font = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Dispose of a previously-created font.
    ///
    /// Call this when done with a font. This function will free any resources associated with it. It is safe to call this function on NULL, for example on the result of a failed call to openFont().
    /// The font is not valid after being passed to this function. String pointers from functions that return information on this font, such as Font.getFamilyName() and Font.getStyleName(), are no longer valid after this call, as well.
    ///
    /// - **Thread safety:** This function should not be called while any other thread is using the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** openFont
    /// - **See also:** openFontIo
    /// This method invalidates the handle after SDL_ttf consumes it.
    pub inline fn close(self: *@This()) void {
        c.TTF_CloseFont(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Add a fallback font.
    ///
    /// Add a font that will be used for glyphs that are not in the current font. The fallback font should have the same size and style as the current font.
    /// If there are multiple fallback fonts, they are used in the order added.
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `fallback`: the font to add as a fallback.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created both fonts.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.clearFallbackFonts
    /// - **See also:** Font.removeFallback
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn addFallback(self: @This(), fallback: ?Font) sdl.Error!void {
        if (!c.TTF_AddFallbackFont(@ptrCast(self.value), if (fallback) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
    }

    /// Remove all fallback fonts.
    ///
    /// This updates any Text objects using this font.
    ///
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.addFallback
    /// - **See also:** Font.removeFallback
    pub inline fn clearFallbackFonts(self: @This()) void {
        c.TTF_ClearFallbackFonts(@ptrCast(self.value));
    }

    /// Create a copy of an existing font.
    ///
    /// The copy will be distinct from the original, but will share the font file and have the same size and style as the original.
    /// When done with the returned Font, use Font.close() to dispose of it.
    ///
    /// - **Returns:** a valid Font, or NULL on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the original font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.close
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn copy(self: @This()) sdl.Error!Font {
        const result = c.TTF_CopyFont(@ptrCast(self.value));
        if (result == null) return error.SdlFailure;
        return Font{ .value = @ptrCast(result.?) };
    }

    /// Check whether a glyph is provided by the font for a UNICODE codepoint.
    ///
    /// - **Parameters:**
    ///   - `ch`: the codepoint to check.
    ///
    /// - **Returns:** true if font provides a glyph for this character, false if not.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn hasGlyph(self: @This(), ch: u32) bool {
        return c.TTF_FontHasGlyph(@ptrCast(self.value), ch);
    }

    /// Query whether a font is fixed-width.
    ///
    /// A "fixed-width" font means all glyphs are the same width across; a lowercase 'i' will be the same size across as a capital 'W', for example. This is common for terminals and text editors, and other apps that treat text as a grid. Most other things (WYSIWYG word processors, web pages, etc) are more likely to not be fixed-width in most cases.
    ///
    /// - **Returns:** true if the font is fixed-width, false otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn isFixedWidth(self: @This()) bool {
        return c.TTF_FontIsFixedWidth(@ptrCast(self.value));
    }

    /// Query whether a font is scalable or not.
    ///
    /// Scalability lets us distinguish between outline and bitmap fonts.
    ///
    /// - **Returns:** true if the font is scalable, false otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setSdf
    pub inline fn isScalable(self: @This()) bool {
        return c.TTF_FontIsScalable(@ptrCast(self.value));
    }

    /// Query the offset from the baseline to the top of a font.
    ///
    /// This is a positive value, relative to the baseline.
    ///
    /// - **Returns:** the font's ascent.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getAscent(self: @This()) c_int {
        return c.TTF_GetFontAscent(@ptrCast(self.value));
    }

    /// Query the offset from the baseline to the bottom of a font.
    ///
    /// This is a negative value, relative to the baseline.
    ///
    /// - **Returns:** the font's descent.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getDescent(self: @This()) c_int {
        return c.TTF_GetFontDescent(@ptrCast(self.value));
    }

    /// Get the direction to be used for text shaping by a font.
    ///
    /// This defaults to Direction.invalid if it hasn't been set.
    ///
    /// - **Returns:** the direction to be used for text shaping.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getDirection(self: @This()) Direction {
        const result = c.TTF_GetFontDirection(@ptrCast(self.value));
        return @enumFromInt(result);
    }

    /// Get font target resolutions, in dots per inch.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setSizeDpi
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getDpi(self: @This()) sdl.Error!root.GetFontDpiResult {
        var hdpi_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFontDPI)).@"fn".params[1].type.?).pointer.child = undefined;
        var vdpi_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFontDPI)).@"fn".params[2].type.?).pointer.child = undefined;
        if (!c.TTF_GetFontDPI(@ptrCast(self.value), &hdpi_raw, &vdpi_raw)) return error.SdlFailure;
        return root.GetFontDpiResult{
            .hdpi = hdpi_raw,
            .vdpi = vdpi_raw,
        };
    }

    /// Query a font's family name.
    ///
    /// This string is dictated by the contents of the font file.
    /// Note that the returned string is to internal storage, and should not be modified or free'd by the caller. The string becomes invalid, with the rest of the font, when `font` is handed to Font.close().
    ///
    /// - **Returns:** the font's family name.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getFamilyName(self: @This()) ?[:0]const u8 {
        const result = c.TTF_GetFontFamilyName(@ptrCast(self.value));
        return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
    }

    /// Get the font generation.
    ///
    /// The generation is incremented each time font properties change that require rebuilding glyphs, such as style, size, etc.
    ///
    /// - **Returns:** the font generation or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getGeneration(self: @This()) u32 {
        return c.TTF_GetFontGeneration(@ptrCast(self.value));
    }

    /// Query the total height of a font.
    ///
    /// This is usually equal to point size.
    ///
    /// - **Returns:** the font's height.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getHeight(self: @This()) c_int {
        return c.TTF_GetFontHeight(@ptrCast(self.value));
    }

    /// Query a font's current FreeType hinter setting.
    ///
    /// The hinter setting is a single value:
    /// - `HintingFlags.normal`
    /// - `HintingFlags.light`
    /// - `HintingFlags.mono`
    /// - `HintingFlags.none`
    /// - `HintingFlags.light_sub_pixel` (available in SDL_ttf 3.0.0 and later)
    ///
    /// - **Returns:** the font's current hinter value, or HintingFlags.invalid if the font is invalid.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setHinting
    pub inline fn getHinting(self: @This()) HintingFlags {
        const result = c.TTF_GetFontHinting(@ptrCast(self.value));
        return @enumFromInt(result);
    }

    /// Query whether or not kerning is enabled for a font.
    ///
    /// - **Returns:** true if kerning is enabled, false otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setKerning
    pub inline fn getKerning(self: @This()) bool {
        return c.TTF_GetFontKerning(@ptrCast(self.value));
    }

    /// Query the spacing between lines of text for a font.
    ///
    /// - **Returns:** the font's recommended spacing.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setLineSkip
    pub inline fn getLineSkip(self: @This()) c_int {
        return c.TTF_GetFontLineSkip(@ptrCast(self.value));
    }

    /// Query a font's current outline.
    ///
    /// - **Returns:** the font's current outline value.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setOutline
    pub inline fn getOutline(self: @This()) c_int {
        return c.TTF_GetFontOutline(@ptrCast(self.value));
    }

    /// Get the properties associated with a font.
    ///
    /// The following read-write properties are provided by SDL:
    /// - `prop_font_outline_line_cap_number`: The FT_Stroker_LineCap value used when setting the font outline, defaults to `FT_STROKER_LINECAP_ROUND`.
    /// - `prop_font_outline_line_join_number`: The FT_Stroker_LineJoin value used when setting the font outline, defaults to `FT_STROKER_LINEJOIN_ROUND`.
    /// - `prop_font_outline_miter_limit_number`: The FT_Fixed miter limit used when setting the font outline, defaults to 0.
    ///
    /// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getProperties(self: @This()) sdl.Error!sdl.properties.Id {
        const result = c.TTF_GetFontProperties(@ptrCast(self.value));
        if (result == 0) return error.SdlFailure;
        return result;
    }

    /// Get the script used for text shaping a font.
    ///
    /// - **Returns:** an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html) or 0 if a script hasn't been set.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** tagToString
    pub inline fn getScript(self: @This()) u32 {
        return c.TTF_GetFontScript(@ptrCast(self.value));
    }

    /// Query whether Signed Distance Field rendering is enabled for a font.
    ///
    /// - **Returns:** true if enabled, false otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setSdf
    pub inline fn getSdf(self: @This()) bool {
        return c.TTF_GetFontSDF(@ptrCast(self.value));
    }

    /// Get the size of a font.
    ///
    /// - **Returns:** the size of the font, or 0.0f on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setSize
    /// - **See also:** Font.setSizeDpi
    pub inline fn getSize(self: @This()) f32 {
        return c.TTF_GetFontSize(@ptrCast(self.value));
    }

    /// Query a font's current style.
    ///
    /// The font styles are a set of bit flags, OR'd together:
    /// - `FontStyleFlags.normal` (is zero)
    /// - `FontStyleFlags.bold`
    /// - `FontStyleFlags.italic`
    /// - `FontStyleFlags.underline`
    /// - `FontStyleFlags.strikethrough`
    ///
    /// - **Returns:** the current font style, as a set of bit flags.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setStyle
    pub inline fn getStyle(self: @This()) FontStyleFlags {
        const result = c.TTF_GetFontStyle(@ptrCast(self.value));
        return @bitCast(result);
    }

    /// Query a font's style name.
    ///
    /// This string is dictated by the contents of the font file.
    /// Note that the returned string is to internal storage, and should not be modified or free'd by the caller. The string becomes invalid, with the rest of the font, when `font` is handed to Font.close().
    ///
    /// - **Returns:** the font's style name.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getStyleName(self: @This()) ?[:0]const u8 {
        const result = c.TTF_GetFontStyleName(@ptrCast(self.value));
        return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
    }

    /// Query a font's weight, in terms of the lightness/heaviness of the strokes.
    ///
    /// - **Returns:** the font's current weight.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.4.0.
    pub inline fn getWeight(self: @This()) c_int {
        return c.TTF_GetFontWeight(@ptrCast(self.value));
    }

    /// Query a font's current wrap alignment option.
    ///
    /// - **Returns:** the font's current wrap alignment option.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.setWrapAlignment
    pub inline fn getWrapAlignment(self: @This()) HorizontalAlignment {
        const result = c.TTF_GetFontWrapAlignment(@ptrCast(self.value));
        return @enumFromInt(result);
    }

    /// Get the pixel image for a UNICODE codepoint.
    ///
    /// - **Parameters:**
    ///   - `ch`: the codepoint to check.
    ///   - `image_type`: a pointer filled in with the glyph image type, may be NULL.
    ///
    /// - **Returns:** an sdl.surface.Surface containing the glyph, or NULL on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getGlyphImage(self: @This(), ch: u32, image_type: ?*ImageType) sdl.Error!*sdl.surface.Surface {
        const result = c.TTF_GetGlyphImage(@ptrCast(self.value), ch, @ptrCast(image_type));
        if (result == null) return error.SdlFailure;
        return @ptrCast(result.?);
    }

    /// Get the pixel image for a character index.
    ///
    /// This is useful for text engine implementations, which can call this with the `glyph_index` in a textengine.CopyOperation
    ///
    /// - **Parameters:**
    ///   - `glyph_index`: the index of the glyph to return.
    ///   - `image_type`: a pointer filled in with the glyph image type, may be NULL.
    ///
    /// - **Returns:** an sdl.surface.Surface containing the glyph, or NULL on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getGlyphImageForIndex(self: @This(), glyph_index: u32, image_type: ?*ImageType) sdl.Error!*sdl.surface.Surface {
        const result = c.TTF_GetGlyphImageForIndex(@ptrCast(self.value), glyph_index, @ptrCast(image_type));
        if (result == null) return error.SdlFailure;
        return @ptrCast(result.?);
    }

    /// Query the kerning size between the glyphs of two UNICODE codepoints.
    ///
    /// - **Parameters:**
    ///   - `previous_ch`: the previous codepoint.
    ///   - `ch`: the current codepoint.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getGlyphKerning(self: @This(), previous_ch: u32, ch: u32) sdl.Error!root.GetGlyphKerningResult {
        var kerning_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphKerning)).@"fn".params[3].type.?).pointer.child = undefined;
        if (!c.TTF_GetGlyphKerning(@ptrCast(self.value), previous_ch, ch, &kerning_raw)) return error.SdlFailure;
        return root.GetGlyphKerningResult{
            .kerning = kerning_raw,
        };
    }

    /// Query the metrics (dimensions) of a font's glyph for a UNICODE codepoint.
    ///
    /// To understand what these metrics mean, here is a useful link:
    /// [https://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html](https://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html)
    ///
    /// - **Parameters:**
    ///   - `ch`: the codepoint to check.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getGlyphMetrics(self: @This(), ch: u32) sdl.Error!root.GetGlyphMetricsResult {
        var minx_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[2].type.?).pointer.child = undefined;
        var maxx_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[3].type.?).pointer.child = undefined;
        var miny_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[4].type.?).pointer.child = undefined;
        var maxy_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[5].type.?).pointer.child = undefined;
        var advance_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[6].type.?).pointer.child = undefined;
        if (!c.TTF_GetGlyphMetrics(@ptrCast(self.value), ch, &minx_raw, &maxx_raw, &miny_raw, &maxy_raw, &advance_raw)) return error.SdlFailure;
        return root.GetGlyphMetricsResult{
            .minx = minx_raw,
            .maxx = maxx_raw,
            .miny = miny_raw,
            .maxy = maxy_raw,
            .advance = advance_raw,
        };
    }

    /// Query the number of faces of a font.
    ///
    /// - **Returns:** the number of FreeType font faces.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    pub inline fn getNumFaces(self: @This()) c_int {
        return c.TTF_GetNumFontFaces(@ptrCast(self.value));
    }

    /// Calculate the dimensions of a rendered string of UTF-8 text.
    ///
    /// This will report the width and height, in pixels, of the space that the specified string will take to fully render.
    ///
    /// - **Parameters:**
    ///   - `text`: text to calculate, in UTF-8 encoding.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getStringSize(self: @This(), text: []const u8) sdl.Error!root.GetStringSizeResult {
        var w_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSize)).@"fn".params[3].type.?).pointer.child = undefined;
        var h_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSize)).@"fn".params[4].type.?).pointer.child = undefined;
        if (!c.TTF_GetStringSize(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), &w_raw, &h_raw)) return error.SdlFailure;
        return root.GetStringSizeResult{
            .w = w_raw,
            .h = h_raw,
        };
    }

    /// Calculate the dimensions of a rendered string of UTF-8 text.
    ///
    /// This will report the width and height, in pixels, of the space that the specified string will take to fully render.
    /// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
    /// If wrap_width is 0, this function will only wrap on newline characters.
    ///
    /// - **Parameters:**
    ///   - `text`: text to calculate, in UTF-8 encoding.
    ///   - `wrap_width`: the maximum width or 0 to wrap on newline characters.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn getStringSizeWrapped(self: @This(), text: []const u8, wrap_width: c_int) sdl.Error!root.GetStringSizeWrappedResult {
        var w_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSizeWrapped)).@"fn".params[4].type.?).pointer.child = undefined;
        var h_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSizeWrapped)).@"fn".params[5].type.?).pointer.child = undefined;
        if (!c.TTF_GetStringSizeWrapped(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), wrap_width, &w_raw, &h_raw)) return error.SdlFailure;
        return root.GetStringSizeWrappedResult{
            .w = w_raw,
            .h = h_raw,
        };
    }

    /// Calculate how much of a UTF-8 string will fit in a given width.
    ///
    /// This reports the number of characters that can be rendered before reaching `max_width`.
    /// This does not need to render the string to do this calculation.
    ///
    /// - **Parameters:**
    ///   - `text`: text to calculate, in UTF-8 encoding.
    ///   - `max_width`: maximum width, in pixels, available for the string, or 0 for unbounded width.
    ///   - `measured_length`: a pointer filled in with the length, in bytes, of the string that will fit, may be NULL.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn measureString(self: @This(), text: []const u8, max_width: c_int, measured_length: []c_ulong) sdl.Error!root.MeasureStringResult {
        var measured_width_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_MeasureString)).@"fn".params[4].type.?).pointer.child = undefined;
        if (!c.TTF_MeasureString(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(if (measured_length.len == text.len) text.len else @panic("related slices must have equal lengths")), max_width, &measured_width_raw, @ptrCast(measured_length.ptr))) return error.SdlFailure;
        return root.MeasureStringResult{
            .measured_width = measured_width_raw,
        };
    }

    /// Remove a fallback font.
    ///
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `fallback`: the font to remove as a fallback.
    ///
    /// - **Thread safety:** This function should be called on the thread that created both fonts.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.addFallback
    /// - **See also:** Font.clearFallbackFonts
    pub inline fn removeFallback(self: @This(), fallback: ?Font) void {
        c.TTF_RemoveFallbackFont(@ptrCast(self.value), if (fallback) |resource| @ptrCast(resource.value) else null);
    }

    /// Render a single UNICODE codepoint at high quality to a new ARGB surface.
    ///
    /// This function will allocate a new 32-bit, ARGB surface, using alpha blending to dither the font with the given color. This function returns the new surface, or NULL if there was an error.
    /// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
    /// You can render at other quality levels with Font.renderGlyphSolid, Font.renderGlyphShaded, and Font.renderGlyphLcd.
    ///
    /// - **Parameters:**
    ///   - `ch`: the codepoint to render.
    ///   - `fg`: the foreground color for the text.
    ///
    /// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderGlyphLcd
    /// - **See also:** Font.renderGlyphShaded
    /// - **See also:** Font.renderGlyphSolid
    pub inline fn renderGlyphBlended(self: @This(), ch: u32, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderGlyph_Blended(@ptrCast(self.value), ch, @bitCast(fg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render a single UNICODE codepoint at LCD subpixel quality to a new ARGB surface.
    ///
    /// This function will allocate a new 32-bit, ARGB surface, and render alpha-blended text using FreeType's LCD subpixel rendering. This function returns the new surface, or NULL if there was an error.
    /// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
    /// You can render at other quality levels with Font.renderGlyphSolid, Font.renderGlyphShaded, and Font.renderGlyphBlended.
    ///
    /// - **Parameters:**
    ///   - `ch`: the codepoint to render.
    ///   - `fg`: the foreground color for the text.
    ///   - `bg`: the background color for the text.
    ///
    /// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderGlyphBlended
    /// - **See also:** Font.renderGlyphShaded
    /// - **See also:** Font.renderGlyphSolid
    pub inline fn renderGlyphLcd(self: @This(), ch: u32, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderGlyph_LCD(@ptrCast(self.value), ch, @bitCast(fg), @bitCast(bg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render a single UNICODE codepoint at high quality to a new 8-bit surface.
    ///
    /// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the specified background color, while other pixels have varying degrees of the foreground color. This function returns the new surface, or NULL if there was an error.
    /// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
    /// You can render at other quality levels with Font.renderGlyphSolid, Font.renderGlyphBlended, and Font.renderGlyphLcd.
    ///
    /// - **Parameters:**
    ///   - `ch`: the codepoint to render.
    ///   - `fg`: the foreground color for the text.
    ///   - `bg`: the background color for the text.
    ///
    /// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderGlyphBlended
    /// - **See also:** Font.renderGlyphLcd
    /// - **See also:** Font.renderGlyphSolid
    pub inline fn renderGlyphShaded(self: @This(), ch: u32, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderGlyph_Shaded(@ptrCast(self.value), ch, @bitCast(fg), @bitCast(bg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render a single 32-bit glyph at fast quality to a new 8-bit surface.
    ///
    /// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the colorkey, giving a transparent background. The 1 pixel will be set to the text color.
    /// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
    /// You can render at other quality levels with Font.renderGlyphShaded, Font.renderGlyphBlended, and Font.renderGlyphLcd.
    ///
    /// - **Parameters:**
    ///   - `ch`: the character to render.
    ///   - `fg`: the foreground color for the text.
    ///
    /// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderGlyphBlended
    /// - **See also:** Font.renderGlyphLcd
    /// - **See also:** Font.renderGlyphShaded
    pub inline fn renderGlyphSolid(self: @This(), ch: u32, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderGlyph_Solid(@ptrCast(self.value), ch, @bitCast(fg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render UTF-8 text at high quality to a new ARGB surface.
    ///
    /// This function will allocate a new 32-bit, ARGB surface, using alpha blending to dither the font with the given color. This function returns the new surface, or NULL if there was an error.
    /// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextBlendedWrapped() instead if you need to wrap the output to multiple lines.
    /// This will not wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextSolid, Font.renderTextShaded, and Font.renderTextLcd.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///
    /// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlendedWrapped
    /// - **See also:** Font.renderTextLcd
    /// - **See also:** Font.renderTextShaded
    /// - **See also:** Font.renderTextSolid
    pub inline fn renderTextBlended(self: @This(), text: []const u8, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_Blended(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render word-wrapped UTF-8 text at high quality to a new ARGB surface.
    ///
    /// This function will allocate a new 32-bit, ARGB surface, using alpha blending to dither the font with the given color. This function returns the new surface, or NULL if there was an error.
    /// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
    /// If wrap_width is 0, this function will only wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextSolidWrapped, Font.renderTextShadedWrapped, and Font.renderTextLcdWrapped.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///   - `wrap_width`: the maximum width of the text surface or 0 to wrap on newline characters.
    ///
    /// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlended
    /// - **See also:** Font.renderTextLcdWrapped
    /// - **See also:** Font.renderTextShadedWrapped
    /// - **See also:** Font.renderTextSolidWrapped
    pub inline fn renderTextBlendedWrapped(self: @This(), text: []const u8, fg: sdl.pixels.Color, wrap_width: c_int) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_Blended_Wrapped(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), wrap_width);
        return if (result == null) null else @ptrCast(result);
    }

    /// Render UTF-8 text at LCD subpixel quality to a new ARGB surface.
    ///
    /// This function will allocate a new 32-bit, ARGB surface, and render alpha-blended text using FreeType's LCD subpixel rendering. This function returns the new surface, or NULL if there was an error.
    /// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextLcdWrapped() instead if you need to wrap the output to multiple lines.
    /// This will not wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextSolid, Font.renderTextShaded, and Font.renderTextBlended.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///   - `bg`: the background color for the text.
    ///
    /// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlended
    /// - **See also:** Font.renderTextLcdWrapped
    /// - **See also:** Font.renderTextShaded
    /// - **See also:** Font.renderTextSolid
    pub inline fn renderTextLcd(self: @This(), text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_LCD(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render word-wrapped UTF-8 text at LCD subpixel quality to a new ARGB surface.
    ///
    /// This function will allocate a new 32-bit, ARGB surface, and render alpha-blended text using FreeType's LCD subpixel rendering. This function returns the new surface, or NULL if there was an error.
    /// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
    /// If wrap_width is 0, this function will only wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextSolidWrapped, Font.renderTextShadedWrapped, and Font.renderTextBlendedWrapped.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///   - `bg`: the background color for the text.
    ///   - `wrap_width`: the maximum width of the text surface or 0 to wrap on newline characters.
    ///
    /// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlendedWrapped
    /// - **See also:** Font.renderTextLcd
    /// - **See also:** Font.renderTextShadedWrapped
    /// - **See also:** Font.renderTextSolidWrapped
    pub inline fn renderTextLcdWrapped(self: @This(), text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color, wrap_width: c_int) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_LCD_Wrapped(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg), wrap_width);
        return if (result == null) null else @ptrCast(result);
    }

    /// Render UTF-8 text at high quality to a new 8-bit surface.
    ///
    /// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the specified background color, while other pixels have varying degrees of the foreground color. This function returns the new surface, or NULL if there was an error.
    /// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextShadedWrapped() instead if you need to wrap the output to multiple lines.
    /// This will not wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextSolid, Font.renderTextBlended, and Font.renderTextLcd.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///   - `bg`: the background color for the text.
    ///
    /// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlended
    /// - **See also:** Font.renderTextLcd
    /// - **See also:** Font.renderTextShadedWrapped
    /// - **See also:** Font.renderTextSolid
    pub inline fn renderTextShaded(self: @This(), text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_Shaded(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render word-wrapped UTF-8 text at high quality to a new 8-bit surface.
    ///
    /// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the specified background color, while other pixels have varying degrees of the foreground color. This function returns the new surface, or NULL if there was an error.
    /// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
    /// If wrap_width is 0, this function will only wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextSolidWrapped, Font.renderTextBlendedWrapped, and Font.renderTextLcdWrapped.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///   - `bg`: the background color for the text.
    ///   - `wrap_width`: the maximum width of the text surface or 0 to wrap on newline characters.
    ///
    /// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlendedWrapped
    /// - **See also:** Font.renderTextLcdWrapped
    /// - **See also:** Font.renderTextShaded
    /// - **See also:** Font.renderTextSolidWrapped
    pub inline fn renderTextShadedWrapped(self: @This(), text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color, wrap_width: c_int) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_Shaded_Wrapped(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg), wrap_width);
        return if (result == null) null else @ptrCast(result);
    }

    /// Render UTF-8 text at fast quality to a new 8-bit surface.
    ///
    /// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the colorkey, giving a transparent background. The 1 pixel will be set to the text color.
    /// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextSolidWrapped() instead if you need to wrap the output to multiple lines.
    /// This will not wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextShaded, Font.renderTextBlended, and Font.renderTextLcd.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `fg`: the foreground color for the text.
    ///
    /// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlended
    /// - **See also:** Font.renderTextLcd
    /// - **See also:** Font.renderTextShaded
    /// - **See also:** Font.renderTextSolid
    /// - **See also:** Font.renderTextSolidWrapped
    pub inline fn renderTextSolid(self: @This(), text: []const u8, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_Solid(@ptrCast(self.value), @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg));
        return if (result == null) null else @ptrCast(result);
    }

    /// Render word-wrapped UTF-8 text at fast quality to a new 8-bit surface.
    ///
    /// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the colorkey, giving a transparent background. The 1 pixel will be set to the text color.
    /// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_length` in pixels.
    /// If wrapLength is 0, this function will only wrap on newline characters.
    /// You can render at other quality levels with Font.renderTextShadedWrapped, Font.renderTextBlendedWrapped, and Font.renderTextLcdWrapped.
    ///
    /// - **Parameters:**
    ///   - `text`: text to render, in UTF-8 encoding.
    ///   - `length`: the length of the text, in bytes, or 0 for null terminated text.
    ///   - `fg`: the foreground color for the text.
    ///   - `wrap_length`: the maximum width of the text surface or 0 to wrap on newline characters.
    ///
    /// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.renderTextBlendedWrapped
    /// - **See also:** Font.renderTextLcdWrapped
    /// - **See also:** Font.renderTextShadedWrapped
    /// - **See also:** Font.renderTextSolid
    pub inline fn renderTextSolidWrapped(self: @This(), text: ?[:0]const u8, length: c_ulong, fg: sdl.pixels.Color, wrap_length: c_int) ?*sdl.surface.Surface {
        const result = c.TTF_RenderText_Solid_Wrapped(@ptrCast(self.value), if (text != null) @ptrCast(text.?.ptr) else null, length, @bitCast(fg), wrap_length);
        return if (result == null) null else @ptrCast(result);
    }

    /// Set the direction to be used for text shaping by a font.
    ///
    /// This function only supports left-to-right text shaping if SDL_ttf was not built with HarfBuzz support.
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `direction`: the new direction for text to flow.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setDirection(self: @This(), direction: Direction) sdl.Error!void {
        if (!c.TTF_SetFontDirection(@ptrCast(self.value), @intCast(@intFromEnum(direction)))) return error.SdlFailure;
    }

    /// Set a font's current hinter setting.
    ///
    /// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
    /// The hinter setting is a single value:
    /// - `HintingFlags.normal`
    /// - `HintingFlags.light`
    /// - `HintingFlags.mono`
    /// - `HintingFlags.none`
    /// - `HintingFlags.light_sub_pixel` (available in SDL_ttf 3.0.0 and later)
    ///
    /// - **Parameters:**
    ///   - `hinting`: the new hinter setting.
    ///
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getHinting
    pub inline fn setHinting(self: @This(), hinting: HintingFlags) void {
        c.TTF_SetFontHinting(@ptrCast(self.value), @intCast(@intFromEnum(hinting)));
    }

    /// Set if kerning is enabled for a font.
    ///
    /// Newly-opened fonts default to allowing kerning. This is generally a good policy unless you have a strong reason to disable it, as it tends to produce better rendering (with kerning disabled, some fonts might render the word `kerning` as something that looks like `keming` for example).
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `enabled`: true to enable kerning, false to disable.
    ///
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getKerning
    pub inline fn setKerning(self: @This(), enabled: bool) void {
        c.TTF_SetFontKerning(@ptrCast(self.value), enabled);
    }

    /// Set language to be used for text shaping by a font.
    ///
    /// If SDL_ttf was not built with HarfBuzz support, this function returns false.
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `language_bcp47`: a null-terminated string containing the desired language's BCP47 code. Or null to reset the value.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setLanguage(self: @This(), language_bcp47: ?[:0]const u8) sdl.Error!void {
        if (!c.TTF_SetFontLanguage(@ptrCast(self.value), if (language_bcp47 != null) @ptrCast(language_bcp47.?.ptr) else null)) return error.SdlFailure;
    }

    /// Set the spacing between lines of text for a font.
    ///
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `lineskip`: the new line spacing for the font.
    ///
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getLineSkip
    pub inline fn setLineSkip(self: @This(), lineskip: c_int) void {
        c.TTF_SetFontLineSkip(@ptrCast(self.value), lineskip);
    }

    /// Set a font's current outline.
    ///
    /// This uses the font properties `prop_font_outline_line_cap_number`, `prop_font_outline_line_join_number`, and `prop_font_outline_miter_limit_number` when setting the font outline.
    /// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
    ///
    /// - **Parameters:**
    ///   - `outline`: positive outline value, 0 to default.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getOutline
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setOutline(self: @This(), outline: c_int) sdl.Error!void {
        if (!c.TTF_SetFontOutline(@ptrCast(self.value), outline)) return error.SdlFailure;
    }

    /// Set the script to be used for text shaping by a font.
    ///
    /// This returns false if SDL_ttf isn't built with HarfBuzz support.
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `script`: an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** stringToTag
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setScript(self: @This(), script: u32) sdl.Error!void {
        if (!c.TTF_SetFontScript(@ptrCast(self.value), script)) return error.SdlFailure;
    }

    /// Enable Signed Distance Field rendering for a font.
    ///
    /// SDF is a technique that helps fonts look sharp even when scaling and rotating, and requires special shader support for display.
    /// This works with Blended APIs, and generates the raw signed distance values in the alpha channel of the resulting texture.
    /// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
    ///
    /// - **Parameters:**
    ///   - `enabled`: true to enable SDF, false to disable.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getSdf
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setSdf(self: @This(), enabled: bool) sdl.Error!void {
        if (!c.TTF_SetFontSDF(@ptrCast(self.value), enabled)) return error.SdlFailure;
    }

    /// Set a font's size dynamically.
    ///
    /// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
    ///
    /// - **Parameters:**
    ///   - `ptsize`: the new point size.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getSize
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setSize(self: @This(), ptsize: f32) sdl.Error!void {
        if (!c.TTF_SetFontSize(@ptrCast(self.value), ptsize)) return error.SdlFailure;
    }

    /// Set font size dynamically with target resolutions, in dots per inch.
    ///
    /// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
    ///
    /// - **Parameters:**
    ///   - `ptsize`: the new point size.
    ///   - `hdpi`: the target horizontal DPI.
    ///   - `vdpi`: the target vertical DPI.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getSize
    /// - **See also:** TTF_GetFontSizeDPI (C API outside this module)
    /// Returns `error.SdlFailure` when SDL_ttf reports failure.
    pub inline fn setSizeDpi(self: @This(), ptsize: f32, hdpi: c_int, vdpi: c_int) sdl.Error!void {
        if (!c.TTF_SetFontSizeDPI(@ptrCast(self.value), ptsize, hdpi, vdpi)) return error.SdlFailure;
    }

    /// Set a font's current style.
    ///
    /// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
    /// The font styles are a set of bit flags, OR'd together:
    /// - `FontStyleFlags.normal` (is zero)
    /// - `FontStyleFlags.bold`
    /// - `FontStyleFlags.italic`
    /// - `FontStyleFlags.underline`
    /// - `FontStyleFlags.strikethrough`
    ///
    /// - **Parameters:**
    ///   - `style`: the new style values to set, OR'd together.
    ///
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getStyle
    pub inline fn setStyle(self: @This(), style: FontStyleFlags) void {
        c.TTF_SetFontStyle(@ptrCast(self.value), @bitCast(style));
    }

    /// Set a font's current wrap alignment option.
    ///
    /// This updates any Text objects using this font.
    ///
    /// - **Parameters:**
    ///   - `align_`: the new wrap alignment option.
    ///
    /// - **Thread safety:** This function should be called on the thread that created the font.
    /// - **Since:** This function is available since SDL_ttf 3.0.0.
    /// - **See also:** Font.getWrapAlignment
    pub inline fn setWrapAlignment(self: @This(), align_: HorizontalAlignment) void {
        c.TTF_SetFontWrapAlignment(@ptrCast(self.value), @intCast(@intFromEnum(align_)));
    }
};

/// Draw sequence returned by getGpuTextDrawData
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
/// - **See also:** getGpuTextDrawData
pub const GpuAtlasDrawSequence = extern struct {
    /// Field `atlas_texture`.
    atlas_texture: ?*sdl.gpu.Texture,
    /// Field `xy`.
    xy: ?*sdl.rect.FPoint,
    /// Field `uv`.
    uv: ?*sdl.rect.FPoint,
    /// Field `num_vertices`.
    num_vertices: c_int,
    /// Field `indices`.
    indices: ?*c_int,
    /// Field `num_indices`.
    num_indices: c_int,
    /// Field `image_type`.
    image_type: ImageType,
    /// Field `next`.
    next: ?*GpuAtlasDrawSequence,
};
comptime {
    if (@sizeOf(GpuAtlasDrawSequence) != @sizeOf(c.TTF_GPUAtlasDrawSequence)) @compileError("ABI size mismatch for GpuAtlasDrawSequence");
    if (@alignOf(GpuAtlasDrawSequence) != @alignOf(c.TTF_GPUAtlasDrawSequence)) @compileError("ABI alignment mismatch for GpuAtlasDrawSequence");
    if (@offsetOf(GpuAtlasDrawSequence, "atlas_texture") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "atlas_texture")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.atlas_texture");
    if (@offsetOf(GpuAtlasDrawSequence, "xy") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "xy")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.xy");
    if (@offsetOf(GpuAtlasDrawSequence, "uv") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "uv")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.uv");
    if (@offsetOf(GpuAtlasDrawSequence, "num_vertices") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "num_vertices")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.num_vertices");
    if (@offsetOf(GpuAtlasDrawSequence, "indices") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "indices")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.indices");
    if (@offsetOf(GpuAtlasDrawSequence, "num_indices") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "num_indices")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.num_indices");
    if (@offsetOf(GpuAtlasDrawSequence, "image_type") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "image_type")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.image_type");
    if (@offsetOf(GpuAtlasDrawSequence, "next") != @offsetOf(c.TTF_GPUAtlasDrawSequence, "next")) @compileError("ABI field mismatch for GpuAtlasDrawSequence.next");
}

/// The representation of a substring within text.
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
/// - **See also:** getNextTextSubString
/// - **See also:** getPreviousTextSubString
/// - **See also:** getTextSubString
/// - **See also:** getTextSubStringForLine
/// - **See also:** getTextSubStringForPoint
/// - **See also:** getTextSubStringsForRange
pub const SubString = extern struct {
    /// Field `flags`.
    flags: SubStringFlags,
    /// Field `offset`.
    offset: c_int,
    /// Field `length`.
    length: c_int,
    /// Field `line_index`.
    line_index: c_int,
    /// Field `cluster_index`.
    cluster_index: c_int,
    /// Field `rect`.
    rect: sdl.rect.Rect,
};
comptime {
    if (@sizeOf(SubString) != @sizeOf(c.TTF_SubString)) @compileError("ABI size mismatch for SubString");
    if (@alignOf(SubString) != @alignOf(c.TTF_SubString)) @compileError("ABI alignment mismatch for SubString");
    if (@offsetOf(SubString, "flags") != @offsetOf(c.TTF_SubString, "flags")) @compileError("ABI field mismatch for SubString.flags");
    if (@offsetOf(SubString, "offset") != @offsetOf(c.TTF_SubString, "offset")) @compileError("ABI field mismatch for SubString.offset");
    if (@offsetOf(SubString, "length") != @offsetOf(c.TTF_SubString, "length")) @compileError("ABI field mismatch for SubString.length");
    if (@offsetOf(SubString, "line_index") != @offsetOf(c.TTF_SubString, "line_index")) @compileError("ABI field mismatch for SubString.line_index");
    if (@offsetOf(SubString, "cluster_index") != @offsetOf(c.TTF_SubString, "cluster_index")) @compileError("ABI field mismatch for SubString.cluster_index");
    if (@offsetOf(SubString, "rect") != @offsetOf(c.TTF_SubString, "rect")) @compileError("ABI field mismatch for SubString.rect");
}

/// Text created with createText()
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
/// - **See also:** createText
/// - **See also:** getTextProperties
/// - **See also:** destroyText
pub const Text = extern struct {
    /// Field `text`.
    text: ?*u8,
    /// Field `num_lines`.
    num_lines: c_int,
    /// Field `refcount`.
    refcount: c_int,
    /// Field `internal`.
    internal: ?*TextData,
};
comptime {
    if (@sizeOf(Text) != @sizeOf(c.TTF_Text)) @compileError("ABI size mismatch for Text");
    if (@alignOf(Text) != @alignOf(c.TTF_Text)) @compileError("ABI alignment mismatch for Text");
    if (@offsetOf(Text, "text") != @offsetOf(c.TTF_Text, "text")) @compileError("ABI field mismatch for Text.text");
    if (@offsetOf(Text, "num_lines") != @offsetOf(c.TTF_Text, "num_lines")) @compileError("ABI field mismatch for Text.num_lines");
    if (@offsetOf(Text, "refcount") != @offsetOf(c.TTF_Text, "refcount")) @compileError("ABI field mismatch for Text.refcount");
    if (@offsetOf(Text, "internal") != @offsetOf(c.TTF_Text, "internal")) @compileError("ABI field mismatch for Text.internal");
}

/// SDL record `textengine.TextData`.
const TextData = extern struct {
    /// Field `font`.
    font: ?*anyopaque,
    /// Field `color`.
    color: sdl.pixels.FColor,
    /// Field `needs_layout_update`.
    needs_layout_update: bool,
    /// Field `layout`.
    layout: ?*TextLayout,
    /// Field `x`.
    x: c_int,
    /// Field `y`.
    y: c_int,
    /// Field `w`.
    w: c_int,
    /// Field `h`.
    h: c_int,
    /// Field `num_ops`.
    num_ops: c_int,
    /// Field `ops`.
    ops: ?*DrawOperation,
    /// Field `num_clusters`.
    num_clusters: c_int,
    /// Field `clusters`.
    clusters: ?*SubString,
    /// Field `props`.
    props: sdl.properties.Id,
    /// Field `needs_engine_update`.
    needs_engine_update: bool,
    /// Field `engine`.
    engine: ?*TextEngine,
    /// Field `engine_text`.
    engine_text: ?*anyopaque,
};
comptime {
    if (@sizeOf(TextData) != @sizeOf(c.TTF_TextData)) @compileError("ABI size mismatch for TextData");
    if (@alignOf(TextData) != @alignOf(c.TTF_TextData)) @compileError("ABI alignment mismatch for TextData");
    if (@offsetOf(TextData, "font") != @offsetOf(c.TTF_TextData, "font")) @compileError("ABI field mismatch for TextData.font");
    if (@offsetOf(TextData, "color") != @offsetOf(c.TTF_TextData, "color")) @compileError("ABI field mismatch for TextData.color");
    if (@offsetOf(TextData, "needs_layout_update") != @offsetOf(c.TTF_TextData, "needs_layout_update")) @compileError("ABI field mismatch for TextData.needs_layout_update");
    if (@offsetOf(TextData, "layout") != @offsetOf(c.TTF_TextData, "layout")) @compileError("ABI field mismatch for TextData.layout");
    if (@offsetOf(TextData, "x") != @offsetOf(c.TTF_TextData, "x")) @compileError("ABI field mismatch for TextData.x");
    if (@offsetOf(TextData, "y") != @offsetOf(c.TTF_TextData, "y")) @compileError("ABI field mismatch for TextData.y");
    if (@offsetOf(TextData, "w") != @offsetOf(c.TTF_TextData, "w")) @compileError("ABI field mismatch for TextData.w");
    if (@offsetOf(TextData, "h") != @offsetOf(c.TTF_TextData, "h")) @compileError("ABI field mismatch for TextData.h");
    if (@offsetOf(TextData, "num_ops") != @offsetOf(c.TTF_TextData, "num_ops")) @compileError("ABI field mismatch for TextData.num_ops");
    if (@offsetOf(TextData, "ops") != @offsetOf(c.TTF_TextData, "ops")) @compileError("ABI field mismatch for TextData.ops");
    if (@offsetOf(TextData, "num_clusters") != @offsetOf(c.TTF_TextData, "num_clusters")) @compileError("ABI field mismatch for TextData.num_clusters");
    if (@offsetOf(TextData, "clusters") != @offsetOf(c.TTF_TextData, "clusters")) @compileError("ABI field mismatch for TextData.clusters");
    if (@offsetOf(TextData, "props") != @offsetOf(c.TTF_TextData, "props")) @compileError("ABI field mismatch for TextData.props");
    if (@offsetOf(TextData, "needs_engine_update") != @offsetOf(c.TTF_TextData, "needs_engine_update")) @compileError("ABI field mismatch for TextData.needs_engine_update");
    if (@offsetOf(TextData, "engine") != @offsetOf(c.TTF_TextData, "engine")) @compileError("ABI field mismatch for TextData.engine");
    if (@offsetOf(TextData, "engine_text") != @offsetOf(c.TTF_TextData, "engine_text")) @compileError("ABI field mismatch for TextData.engine_text");
}

/// A text engine interface.
///
/// This structure should be initialized using SDL_INIT_INTERFACE (C macro outside this module)()
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
/// - **See also:** SDL_INIT_INTERFACE (C macro outside this module)
const TextEngine = extern struct {
    /// Field `version`.
    version: u32,
    /// Field `userdata`.
    userdata: ?*anyopaque,
    /// Field `CreateText`.
    create_text: ?*const fn (arg0: ?*anyopaque, arg1: ?*Text) callconv(.c) bool,
    /// Field `DestroyText`.
    destroy_text: ?*const fn (arg0: ?*anyopaque, arg1: ?*Text) callconv(.c) void,

    /// Return a zero-initialized interface with its ABI version set for this build.
    pub inline fn init() @This() {
        var value: @This() = std.mem.zeroes(@This());
        value.version = @sizeOf(@This());
        return value;
    }

    /// A zero-initialized interface with its ABI version set for this build.
    pub const default: @This() = @This().init();
};
comptime {
    if (@sizeOf(TextEngine) != @sizeOf(c.TTF_TextEngine)) @compileError("ABI size mismatch for TextEngine");
    if (@alignOf(TextEngine) != @alignOf(c.TTF_TextEngine)) @compileError("ABI alignment mismatch for TextEngine");
    if (@offsetOf(TextEngine, "version") != @offsetOf(c.TTF_TextEngine, "version")) @compileError("ABI field mismatch for TextEngine.version");
    if (@offsetOf(TextEngine, "userdata") != @offsetOf(c.TTF_TextEngine, "userdata")) @compileError("ABI field mismatch for TextEngine.userdata");
    if (@offsetOf(TextEngine, "create_text") != @offsetOf(c.TTF_TextEngine, "CreateText")) @compileError("ABI field mismatch for TextEngine.create_text");
    if (@offsetOf(TextEngine, "destroy_text") != @offsetOf(c.TTF_TextEngine, "DestroyText")) @compileError("ABI field mismatch for TextEngine.destroy_text");
}

/// SDL handle `textengine.TextLayout`.
const TextLayout = opaque {};

/// Font style flags for Font
///
/// These are the flags which can be used to set the style of a font in SDL_ttf. A combination of these flags can be used with functions that set or query font style, such as Font.setStyle or Font.getStyle.
///
/// - **Since:** This datatype is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setStyle
/// - **See also:** Font.getStyle
pub const FontStyleFlags = packed struct(u32) {
    /// Bold style
    bold: bool = false,
    /// Italic style
    italic: bool = false,
    /// Underlined text
    underline: bool = false,
    /// Strikethrough text
    strikethrough: bool = false,
    /// Unknown or currently unused bits preserved during integer round trips.
    reserved_0: u28 = 0,

    /// Preserve every known and unknown flag bit.
    pub inline fn fromInt(value: u32) @This() {
        return @bitCast(value);
    }

    /// Convert this flag set to its integer representation.
    pub inline fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }

    /// Composite flag value `TTF_STYLE_NORMAL`.
    pub const normal: @This() = fromInt(@intCast(c.TTF_STYLE_NORMAL));
};

/// Flags for SubString
///
/// - **Since:** This datatype is available since SDL_ttf 3.0.0.
/// - **See also:** SubString
pub const SubStringFlags = packed struct(u32) {
    /// Unknown or currently unused bits preserved during integer round trips.
    reserved_0: u8 = 0,
    /// This substring contains the beginning of the text
    text_start: bool = false,
    /// This substring contains the beginning of line `line_index`
    line_start: bool = false,
    /// This substring contains the end of line `line_index`
    line_end: bool = false,
    /// This substring contains the end of the text
    text_end: bool = false,
    /// Unknown or currently unused bits preserved during integer round trips.
    reserved_1: u20 = 0,

    /// Preserve every known and unknown flag bit.
    pub inline fn fromInt(value: u32) @This() {
        return @bitCast(value);
    }

    /// Convert this flag set to its integer representation.
    pub inline fn toInt(self: @This()) u32 {
        return @bitCast(self);
    }

    /// Composite flag value `TTF_SUBSTRING_DIRECTION_MASK`.
    pub const direction_mask: @This() = fromInt(@intCast(c.TTF_SUBSTRING_DIRECTION_MASK));
};

/// A text engine draw operation.
///
/// - **Since:** This struct is available since SDL_ttf 3.0.0.
const DrawOperation = extern union {
    /// Field `cmd`.
    cmd: DrawCommand,
    /// Field `fill`.
    fill: FillOperation,
    /// Field `copy`.
    copy: CopyOperation,
};
comptime {
    if (@sizeOf(DrawOperation) != @sizeOf(c.TTF_DrawOperation)) @compileError("ABI size mismatch for DrawOperation");
    if (@alignOf(DrawOperation) != @alignOf(c.TTF_DrawOperation)) @compileError("ABI alignment mismatch for DrawOperation");
}

/// Black (900) named font weight value
pub const font_weight_black = c.TTF_FONT_WEIGHT_BLACK;
/// Bold (700) named font weight value
pub const font_weight_bold = c.TTF_FONT_WEIGHT_BOLD;
/// ExtraBlack (950) named font weight value
pub const font_weight_extra_black = c.TTF_FONT_WEIGHT_EXTRA_BLACK;
/// ExtraBold (800) named font weight value
pub const font_weight_extra_bold = c.TTF_FONT_WEIGHT_EXTRA_BOLD;
/// ExtraLight (200) named font weight value
pub const font_weight_extra_light = c.TTF_FONT_WEIGHT_EXTRA_LIGHT;
/// Light (300) named font weight value
pub const font_weight_light = c.TTF_FONT_WEIGHT_LIGHT;
/// Medium (500) named font weight value
pub const font_weight_medium = c.TTF_FONT_WEIGHT_MEDIUM;
/// Normal (400) named font weight value
pub const font_weight_normal = c.TTF_FONT_WEIGHT_NORMAL;
/// SemiBold (600) named font weight value
pub const font_weight_semi_bold = c.TTF_FONT_WEIGHT_SEMI_BOLD;
/// Thin (100) named font weight value
pub const font_weight_thin = c.TTF_FONT_WEIGHT_THIN;
/// SDL constant `prop_font_create_existing_font`.
pub const prop_font_create_existing_font = c.TTF_PROP_FONT_CREATE_EXISTING_FONT;
/// SDL constant `prop_font_create_face_number`.
pub const prop_font_create_face_number = c.TTF_PROP_FONT_CREATE_FACE_NUMBER;
/// SDL constant `prop_font_create_filename_string`.
pub const prop_font_create_filename_string = c.TTF_PROP_FONT_CREATE_FILENAME_STRING;
/// SDL constant `prop_font_create_horizontal_dpi_number`.
pub const prop_font_create_horizontal_dpi_number = c.TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER;
/// SDL constant `prop_font_create_io_stream_autoclose_boolean`.
pub const prop_font_create_io_stream_autoclose_boolean = c.TTF_PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN;
/// SDL constant `prop_font_create_io_stream_offset_number`.
pub const prop_font_create_io_stream_offset_number = c.TTF_PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER;
/// SDL constant `prop_font_create_io_stream_pointer`.
pub const prop_font_create_io_stream_pointer = c.TTF_PROP_FONT_CREATE_IOSTREAM_POINTER;
/// SDL constant `prop_font_create_size_float`.
pub const prop_font_create_size_float = c.TTF_PROP_FONT_CREATE_SIZE_FLOAT;
/// SDL constant `prop_font_create_vertical_dpi_number`.
pub const prop_font_create_vertical_dpi_number = c.TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER;
/// SDL constant `prop_font_outline_line_cap_number`.
pub const prop_font_outline_line_cap_number = c.TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER;
/// SDL constant `prop_font_outline_line_join_number`.
pub const prop_font_outline_line_join_number = c.TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER;
/// SDL constant `prop_font_outline_miter_limit_number`.
pub const prop_font_outline_miter_limit_number = c.TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER;
/// SDL constant `prop_gpu_text_engine_atlas_texture_size`.
pub const prop_gpu_text_engine_atlas_texture_size = c.TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE;
/// SDL constant `prop_gpu_text_engine_device`.
pub const prop_gpu_text_engine_device = c.TTF_PROP_GPU_TEXT_ENGINE_DEVICE;
/// SDL constant `prop_renderer_text_engine_atlas_texture_size`.
pub const prop_renderer_text_engine_atlas_texture_size = c.TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE;
/// SDL constant `prop_renderer_text_engine_renderer`.
pub const prop_renderer_text_engine_renderer = c.TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER;
/// Bold style
pub const style_bold = c.TTF_STYLE_BOLD;
/// Italic style
pub const style_italic = c.TTF_STYLE_ITALIC;
/// No special style
pub const style_normal = c.TTF_STYLE_NORMAL;
/// Strikethrough text
pub const style_strikethrough = c.TTF_STYLE_STRIKETHROUGH;
/// Underlined text
pub const style_underline = c.TTF_STYLE_UNDERLINE;
/// The mask for the flow direction for this substring
pub const sub_string_flags_direction_mask = c.TTF_SUBSTRING_DIRECTION_MASK;
/// This substring contains the end of line `line_index`
pub const sub_string_flags_line_end = c.TTF_SUBSTRING_LINE_END;
/// This substring contains the beginning of line `line_index`
pub const sub_string_flags_line_start = c.TTF_SUBSTRING_LINE_START;
/// This substring contains the end of the text
pub const sub_string_flags_text_end = c.TTF_SUBSTRING_TEXT_END;
/// This substring contains the beginning of the text
pub const sub_string_flags_text_start = c.TTF_SUBSTRING_TEXT_START;

/// Add a fallback font.
///
/// Add a font that will be used for glyphs that are not in the current font. The fallback font should have the same size and style as the current font.
/// If there are multiple fallback fonts, they are used in the order added.
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to modify.
///   - `fallback`: the font to add as a fallback.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created both fonts.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.clearFallbackFonts
/// - **See also:** Font.removeFallback
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn addFallbackFont(font: ?Font, fallback: ?Font) sdl.Error!void {
    if (!c.TTF_AddFallbackFont(if (font) |resource| @ptrCast(resource.value) else null, if (fallback) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Append UTF-8 text to a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `string`: the UTF-8 text to insert.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** deleteTextString
/// - **See also:** insertTextString
/// - **See also:** setTextString
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn appendTextString(text: []Text, string: ?[:0]const u8) sdl.Error!void {
    if (!c.TTF_AppendTextString(@ptrCast(text.ptr), if (string != null) @ptrCast(string.?.ptr) else null, @intCast(text.len))) return error.SdlFailure;
}

/// Remove all fallback fonts.
///
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to modify.
///
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.addFallback
/// - **See also:** Font.removeFallback
pub inline fn clearFallbackFonts(font: ?Font) void {
    c.TTF_ClearFallbackFonts(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Create a copy of an existing font.
///
/// The copy will be distinct from the original, but will share the font file and have the same size and style as the original.
/// When done with the returned Font, use Font.close() to dispose of it.
///
/// - **Parameters:**
///   - `existing_font`: the font to copy.
///
/// - **Returns:** a valid Font, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the original font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.close
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn copyFont(existing_font: ?Font) sdl.Error!Font {
    const result = c.TTF_CopyFont(if (existing_font) |resource| @ptrCast(resource.value) else null);
    if (result == null) return error.SdlFailure;
    return Font{ .value = @ptrCast(result.?) };
}

/// Create a text engine for drawing text with the SDL GPU API.
///
/// - **Parameters:**
///   - `device`: the sdl.gpu.Device to use for creating textures and drawing text.
///
/// - **Returns:** a textengine.TextEngine object or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the device.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createGpuTextEngineWithProperties
/// - **See also:** destroyGpuTextEngine
/// - **See also:** getGpuTextDrawData
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn createGpuTextEngine(device: ?*sdl.gpu.Device) sdl.Error!*TextEngine {
    const result = c.TTF_CreateGPUTextEngine(@ptrCast(device));
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Create a text engine for drawing text with the SDL GPU API, with the specified properties.
///
/// These are the supported properties:
/// - `prop_gpu_text_engine_device`: the sdl.gpu.Device to use for creating textures and drawing text.
/// - `prop_gpu_text_engine_atlas_texture_size`: the size of the texture atlas
///
/// - **Parameters:**
///   - `props`: the properties to use.
///
/// - **Returns:** a textengine.TextEngine object or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the device.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createGpuTextEngine
/// - **See also:** destroyGpuTextEngine
/// - **See also:** getGpuTextDrawData
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn createGpuTextEngineWithProperties(props: sdl.properties.Id) sdl.Error!*TextEngine {
    const result = c.TTF_CreateGPUTextEngineWithProperties(props);
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Create a text engine for drawing text on an SDL renderer.
///
/// - **Parameters:**
///   - `renderer`: the renderer to use for creating textures and drawing text.
///
/// - **Returns:** a textengine.TextEngine object or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the renderer.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** destroyRendererTextEngine
/// - **See also:** drawRendererText
/// - **See also:** createRendererTextEngineWithProperties
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn createRendererTextEngine(renderer: ?*sdl.render.Renderer) sdl.Error!*TextEngine {
    const result = c.TTF_CreateRendererTextEngine(@ptrCast(renderer));
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Create a text engine for drawing text on an SDL renderer, with the specified properties.
///
/// These are the supported properties:
/// - `prop_renderer_text_engine_renderer`: the renderer to use for creating textures and drawing text
/// - `prop_renderer_text_engine_atlas_texture_size`: the size of the texture atlas
///
/// - **Parameters:**
///   - `props`: the properties to use.
///
/// - **Returns:** a textengine.TextEngine object or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the renderer.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createRendererTextEngine
/// - **See also:** destroyRendererTextEngine
/// - **See also:** drawRendererText
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn createRendererTextEngineWithProperties(props: sdl.properties.Id) sdl.Error!*TextEngine {
    const result = c.TTF_CreateRendererTextEngineWithProperties(props);
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Create a text engine for drawing text on SDL surfaces.
///
/// - **Returns:** a textengine.TextEngine object or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** destroySurfaceTextEngine
/// - **See also:** drawSurfaceText
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn createSurfaceTextEngine() sdl.Error!*TextEngine {
    const result = c.TTF_CreateSurfaceTextEngine();
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Create a text object from UTF-8 text and a text engine.
///
/// - **Parameters:**
///   - `engine`: the text engine to use when creating the text object, may be NULL.
///   - `font`: the font to render with.
///   - `text`: the text to use, in UTF-8 encoding.
///
/// - **Returns:** a Text object or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font and text engine.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** destroyText
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn createText(engine: ?*TextEngine, font: ?Font, text: []const u8) sdl.Error!*Text {
    const result = c.TTF_CreateText(@ptrCast(engine), if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len));
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Delete UTF-8 text from a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `offset`: the offset, in bytes, from the beginning of the string if >= 0, the offset from the end of the string if < 0. Note that this does not do UTF-8 validation, so you should only delete at UTF-8 sequence boundaries.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** appendTextString
/// - **See also:** insertTextString
/// - **See also:** setTextString
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn deleteTextString(text: []Text, offset: c_int) sdl.Error!void {
    if (!c.TTF_DeleteTextString(@ptrCast(text.ptr), offset, @intCast(text.len))) return error.SdlFailure;
}

/// Destroy a text engine created for drawing text with the SDL GPU API.
///
/// All text created by this engine should be destroyed before calling this function.
///
/// - **Parameters:**
///   - `engine`: a textengine.TextEngine object created with createGpuTextEngine().
///
/// - **Thread safety:** This function should be called on the thread that created the engine.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createGpuTextEngine
pub inline fn destroyGpuTextEngine(engine: ?*TextEngine) void {
    c.TTF_DestroyGPUTextEngine(@ptrCast(engine));
}

/// Destroy a text engine created for drawing text on an SDL renderer.
///
/// All text created by this engine should be destroyed before calling this function.
///
/// - **Parameters:**
///   - `engine`: a textengine.TextEngine object created with createRendererTextEngine().
///
/// - **Thread safety:** This function should be called on the thread that created the engine.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createRendererTextEngine
pub inline fn destroyRendererTextEngine(engine: ?*TextEngine) void {
    c.TTF_DestroyRendererTextEngine(@ptrCast(engine));
}

/// Destroy a text engine created for drawing text on SDL surfaces.
///
/// All text created by this engine should be destroyed before calling this function.
///
/// - **Parameters:**
///   - `engine`: a textengine.TextEngine object created with createSurfaceTextEngine().
///
/// - **Thread safety:** This function should be called on the thread that created the engine.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createSurfaceTextEngine
pub inline fn destroySurfaceTextEngine(engine: ?*TextEngine) void {
    c.TTF_DestroySurfaceTextEngine(@ptrCast(engine));
}

/// Destroy a text object created by a text engine.
///
/// - **Parameters:**
///   - `text`: the text to destroy.
///
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createText
pub inline fn destroyText(text: ?*Text) void {
    c.TTF_DestroyText(@ptrCast(text));
}

/// Draw text to an SDL renderer.
///
/// `text` must have been created using a textengine.TextEngine from createRendererTextEngine(), and will draw using the renderer passed to that function.
///
/// - **Parameters:**
///   - `text`: the text to draw.
///   - `x`: the x coordinate in pixels, positive from the left edge towards the right.
///   - `y`: the y coordinate in pixels, positive from the top edge towards the bottom.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createRendererTextEngine
/// - **See also:** createText
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn drawRendererText(text: ?*Text, x: f32, y: f32) sdl.Error!void {
    if (!c.TTF_DrawRendererText(@ptrCast(text), x, y)) return error.SdlFailure;
}

/// Draw text to an SDL surface.
///
/// `text` must have been created using a textengine.TextEngine from createSurfaceTextEngine().
///
/// - **Parameters:**
///   - `text`: the text to draw.
///   - `x`: the x coordinate in pixels, positive from the left edge towards the right.
///   - `y`: the y coordinate in pixels, positive from the top edge towards the bottom.
///   - `surface`: the surface to draw on.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createSurfaceTextEngine
/// - **See also:** createText
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn drawSurfaceText(text: ?*Text, x: c_int, y: c_int, surface: ?*sdl.surface.Surface) sdl.Error!void {
    if (!c.TTF_DrawSurfaceText(@ptrCast(text), x, y, @ptrCast(surface))) return error.SdlFailure;
}

/// Check whether a glyph is provided by the font for a UNICODE codepoint.
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `ch`: the codepoint to check.
///
/// - **Returns:** true if font provides a glyph for this character, false if not.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn fontHasGlyph(font: ?Font, ch: u32) bool {
    return c.TTF_FontHasGlyph(if (font) |resource| @ptrCast(resource.value) else null, ch);
}

/// Query whether a font is fixed-width.
///
/// A "fixed-width" font means all glyphs are the same width across; a lowercase 'i' will be the same size across as a capital 'W', for example. This is common for terminals and text editors, and other apps that treat text as a grid. Most other things (WYSIWYG word processors, web pages, etc) are more likely to not be fixed-width in most cases.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** true if the font is fixed-width, false otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn fontIsFixedWidth(font: ?Font) bool {
    return c.TTF_FontIsFixedWidth(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query whether a font is scalable or not.
///
/// Scalability lets us distinguish between outline and bitmap fonts.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** true if the font is scalable, false otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setSdf
pub inline fn fontIsScalable(font: ?Font) bool {
    return c.TTF_FontIsScalable(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query the offset from the baseline to the top of a font.
///
/// This is a positive value, relative to the baseline.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's ascent.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontAscent(font: ?Font) c_int {
    return c.TTF_GetFontAscent(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query the offset from the baseline to the bottom of a font.
///
/// This is a negative value, relative to the baseline.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's descent.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontDescent(font: ?Font) c_int {
    return c.TTF_GetFontDescent(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Get the direction to be used for text shaping by a font.
///
/// This defaults to Direction.invalid if it hasn't been set.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the direction to be used for text shaping.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontDirection(font: ?Font) Direction {
    const result = c.TTF_GetFontDirection(if (font) |resource| @ptrCast(resource.value) else null);
    return @enumFromInt(result);
}

/// Named output values.
pub const GetFontDpiResult = struct {
    /// Output `hdpi`.
    hdpi: c_int,
    /// Output `vdpi`.
    vdpi: c_int,
};

/// Get font target resolutions, in dots per inch.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setSizeDpi
/// Returns named output values.
pub inline fn getFontDpi(font: ?Font) sdl.Error!GetFontDpiResult {
    var hdpi_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFontDPI)).@"fn".params[1].type.?).pointer.child = undefined;
    var vdpi_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFontDPI)).@"fn".params[2].type.?).pointer.child = undefined;
    if (!c.TTF_GetFontDPI(if (font) |resource| @ptrCast(resource.value) else null, &hdpi_raw, &vdpi_raw)) return error.SdlFailure;
    return GetFontDpiResult{
        .hdpi = hdpi_raw,
        .vdpi = vdpi_raw,
    };
}

/// Query a font's family name.
///
/// This string is dictated by the contents of the font file.
/// Note that the returned string is to internal storage, and should not be modified or free'd by the caller. The string becomes invalid, with the rest of the font, when `font` is handed to Font.close().
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's family name.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontFamilyName(font: ?Font) ?[:0]const u8 {
    const result = c.TTF_GetFontFamilyName(if (font) |resource| @ptrCast(resource.value) else null);
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Get the font generation.
///
/// The generation is incremented each time font properties change that require rebuilding glyphs, such as style, size, etc.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font generation or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontGeneration(font: ?Font) u32 {
    return c.TTF_GetFontGeneration(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query the total height of a font.
///
/// This is usually equal to point size.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's height.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontHeight(font: ?Font) c_int {
    return c.TTF_GetFontHeight(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query a font's current FreeType hinter setting.
///
/// The hinter setting is a single value:
/// - `HintingFlags.normal`
/// - `HintingFlags.light`
/// - `HintingFlags.mono`
/// - `HintingFlags.none`
/// - `HintingFlags.light_sub_pixel` (available in SDL_ttf 3.0.0 and later)
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's current hinter value, or HintingFlags.invalid if the font is invalid.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setHinting
pub inline fn getFontHinting(font: ?Font) HintingFlags {
    const result = c.TTF_GetFontHinting(if (font) |resource| @ptrCast(resource.value) else null);
    return @enumFromInt(result);
}

/// Query whether or not kerning is enabled for a font.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** true if kerning is enabled, false otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setKerning
pub inline fn getFontKerning(font: ?Font) bool {
    return c.TTF_GetFontKerning(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query the spacing between lines of text for a font.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's recommended spacing.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setLineSkip
pub inline fn getFontLineSkip(font: ?Font) c_int {
    return c.TTF_GetFontLineSkip(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query a font's current outline.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's current outline value.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setOutline
pub inline fn getFontOutline(font: ?Font) c_int {
    return c.TTF_GetFontOutline(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Get the properties associated with a font.
///
/// The following read-write properties are provided by SDL:
/// - `prop_font_outline_line_cap_number`: The FT_Stroker_LineCap value used when setting the font outline, defaults to `FT_STROKER_LINECAP_ROUND`.
/// - `prop_font_outline_line_join_number`: The FT_Stroker_LineJoin value used when setting the font outline, defaults to `FT_STROKER_LINEJOIN_ROUND`.
/// - `prop_font_outline_miter_limit_number`: The FT_Fixed miter limit used when setting the font outline, defaults to 0.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getFontProperties(font: ?Font) sdl.Error!sdl.properties.Id {
    const result = c.TTF_GetFontProperties(if (font) |resource| @ptrCast(resource.value) else null);
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Get the script used for text shaping a font.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html) or 0 if a script hasn't been set.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** tagToString
pub inline fn getFontScript(font: ?Font) u32 {
    return c.TTF_GetFontScript(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query whether Signed Distance Field rendering is enabled for a font.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** true if enabled, false otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setSdf
pub inline fn getFontSdf(font: ?Font) bool {
    return c.TTF_GetFontSDF(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Get the size of a font.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the size of the font, or 0.0f on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setSize
/// - **See also:** Font.setSizeDpi
pub inline fn getFontSize(font: ?Font) f32 {
    return c.TTF_GetFontSize(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query a font's current style.
///
/// The font styles are a set of bit flags, OR'd together:
/// - `FontStyleFlags.normal` (is zero)
/// - `FontStyleFlags.bold`
/// - `FontStyleFlags.italic`
/// - `FontStyleFlags.underline`
/// - `FontStyleFlags.strikethrough`
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the current font style, as a set of bit flags.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setStyle
pub inline fn getFontStyle(font: ?Font) FontStyleFlags {
    const result = c.TTF_GetFontStyle(if (font) |resource| @ptrCast(resource.value) else null);
    return @bitCast(result);
}

/// Query a font's style name.
///
/// This string is dictated by the contents of the font file.
/// Note that the returned string is to internal storage, and should not be modified or free'd by the caller. The string becomes invalid, with the rest of the font, when `font` is handed to Font.close().
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's style name.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getFontStyleName(font: ?Font) ?[:0]const u8 {
    const result = c.TTF_GetFontStyleName(if (font) |resource| @ptrCast(resource.value) else null);
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Query a font's weight, in terms of the lightness/heaviness of the strokes.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's current weight.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.4.0.
pub inline fn getFontWeight(font: ?Font) c_int {
    return c.TTF_GetFontWeight(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Query a font's current wrap alignment option.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the font's current wrap alignment option.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.setWrapAlignment
pub inline fn getFontWrapAlignment(font: ?Font) HorizontalAlignment {
    const result = c.TTF_GetFontWrapAlignment(if (font) |resource| @ptrCast(resource.value) else null);
    return @enumFromInt(result);
}

/// Named output values.
pub const GetFreeTypeVersionResult = struct {
    /// Output `major`.
    major: c_int,
    /// Output `minor`.
    minor: c_int,
    /// Output `patch`.
    patch: c_int,
};

/// Query the version of the FreeType library in use.
///
/// init() should be called before calling this function.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** init
/// Returns named output values.
pub inline fn getFreeTypeVersion() GetFreeTypeVersionResult {
    var major_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFreeTypeVersion)).@"fn".params[0].type.?).pointer.child = undefined;
    var minor_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFreeTypeVersion)).@"fn".params[1].type.?).pointer.child = undefined;
    var patch_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetFreeTypeVersion)).@"fn".params[2].type.?).pointer.child = undefined;
    c.TTF_GetFreeTypeVersion(&major_raw, &minor_raw, &patch_raw);
    return GetFreeTypeVersionResult{
        .major = major_raw,
        .minor = minor_raw,
        .patch = patch_raw,
    };
}

/// Get the pixel image for a UNICODE codepoint.
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `ch`: the codepoint to check.
///   - `image_type`: a pointer filled in with the glyph image type, may be NULL.
///
/// - **Returns:** an sdl.surface.Surface containing the glyph, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getGlyphImage(font: ?Font, ch: u32, image_type: ?*ImageType) sdl.Error!*sdl.surface.Surface {
    const result = c.TTF_GetGlyphImage(if (font) |resource| @ptrCast(resource.value) else null, ch, @ptrCast(image_type));
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Get the pixel image for a character index.
///
/// This is useful for text engine implementations, which can call this with the `glyph_index` in a textengine.CopyOperation
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `glyph_index`: the index of the glyph to return.
///   - `image_type`: a pointer filled in with the glyph image type, may be NULL.
///
/// - **Returns:** an sdl.surface.Surface containing the glyph, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getGlyphImageForIndex(font: ?Font, glyph_index: u32, image_type: ?*ImageType) sdl.Error!*sdl.surface.Surface {
    const result = c.TTF_GetGlyphImageForIndex(if (font) |resource| @ptrCast(resource.value) else null, glyph_index, @ptrCast(image_type));
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Named output values.
pub const GetGlyphKerningResult = struct {
    /// Output `kerning`.
    kerning: c_int,
};

/// Query the kerning size between the glyphs of two UNICODE codepoints.
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `previous_ch`: the previous codepoint.
///   - `ch`: the current codepoint.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getGlyphKerning(font: ?Font, previous_ch: u32, ch: u32) sdl.Error!GetGlyphKerningResult {
    var kerning_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphKerning)).@"fn".params[3].type.?).pointer.child = undefined;
    if (!c.TTF_GetGlyphKerning(if (font) |resource| @ptrCast(resource.value) else null, previous_ch, ch, &kerning_raw)) return error.SdlFailure;
    return GetGlyphKerningResult{
        .kerning = kerning_raw,
    };
}

/// Named output values.
pub const GetGlyphMetricsResult = struct {
    /// Output `minx`.
    minx: c_int,
    /// Output `maxx`.
    maxx: c_int,
    /// Output `miny`.
    miny: c_int,
    /// Output `maxy`.
    maxy: c_int,
    /// Output `advance`.
    advance: c_int,
};

/// Query the metrics (dimensions) of a font's glyph for a UNICODE codepoint.
///
/// To understand what these metrics mean, here is a useful link:
/// [https://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html](https://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html)
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `ch`: the codepoint to check.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getGlyphMetrics(font: ?Font, ch: u32) sdl.Error!GetGlyphMetricsResult {
    var minx_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[2].type.?).pointer.child = undefined;
    var maxx_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[3].type.?).pointer.child = undefined;
    var miny_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[4].type.?).pointer.child = undefined;
    var maxy_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[5].type.?).pointer.child = undefined;
    var advance_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetGlyphMetrics)).@"fn".params[6].type.?).pointer.child = undefined;
    if (!c.TTF_GetGlyphMetrics(if (font) |resource| @ptrCast(resource.value) else null, ch, &minx_raw, &maxx_raw, &miny_raw, &maxy_raw, &advance_raw)) return error.SdlFailure;
    return GetGlyphMetricsResult{
        .minx = minx_raw,
        .maxx = maxx_raw,
        .miny = miny_raw,
        .maxy = maxy_raw,
        .advance = advance_raw,
    };
}

/// Get the script used by a 32-bit codepoint.
///
/// - **Parameters:**
///   - `ch`: the character code to check.
///
/// - **Returns:** an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html) on success, or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function is thread-safe.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** tagToString
pub inline fn getGlyphScript(ch: u32) u32 {
    return c.TTF_GetGlyphScript(ch);
}

/// Get the geometry data needed for drawing the text.
///
/// `text` must have been created using a textengine.TextEngine from createGpuTextEngine().
/// The positive X-axis is taken towards the right and the positive Y-axis is taken upwards for both the vertex and the texture coordinates, i.e, it follows the same convention used by the SDL_GPU (C macro outside this module) API. If you want to use a different coordinate system you will need to transform the vertices yourself.
/// If the text looks blocky use linear filtering.
///
/// - **Parameters:**
///   - `text`: the text to draw.
///
/// - **Returns:** a NULL terminated linked list of GpuAtlasDrawSequence objects or NULL if the passed text is empty or in case of failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** createGpuTextEngine
/// - **See also:** createText
pub inline fn getGpuTextDrawData(text: ?*Text) ?*GpuAtlasDrawSequence {
    const result = c.TTF_GetGPUTextDrawData(@ptrCast(text));
    return if (result == null) null else @ptrCast(result);
}

/// Get the winding order of the vertices returned by getGpuTextDrawData for a particular GPU text engine
///
/// - **Parameters:**
///   - `engine`: a textengine.TextEngine object created with createGpuTextEngine().
///
/// - **Returns:** the winding order used by the GPU text engine or GpuTextEngineWinding.invalid in case of error.
/// - **Thread safety:** This function should be called on the thread that created the engine.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** setGpuTextEngineWinding
pub inline fn getGpuTextEngineWinding(engine: ?*const TextEngine) GpuTextEngineWinding {
    const result = c.TTF_GetGPUTextEngineWinding(@ptrCast(engine));
    return @enumFromInt(result);
}

/// Named output values.
pub const GetHarfBuzzVersionResult = struct {
    /// Output `major`.
    major: c_int,
    /// Output `minor`.
    minor: c_int,
    /// Output `patch`.
    patch: c_int,
};

/// Query the version of the HarfBuzz library in use.
///
/// If HarfBuzz is not available, the version reported is 0.0.0.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getHarfBuzzVersion() GetHarfBuzzVersionResult {
    var major_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetHarfBuzzVersion)).@"fn".params[0].type.?).pointer.child = undefined;
    var minor_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetHarfBuzzVersion)).@"fn".params[1].type.?).pointer.child = undefined;
    var patch_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetHarfBuzzVersion)).@"fn".params[2].type.?).pointer.child = undefined;
    c.TTF_GetHarfBuzzVersion(&major_raw, &minor_raw, &patch_raw);
    return GetHarfBuzzVersionResult{
        .major = major_raw,
        .minor = minor_raw,
        .patch = patch_raw,
    };
}

/// Named output values.
pub const GetNextTextSubStringResult = struct {
    /// Output `next`.
    next: SubString,
};

/// Get the next substring in a text object
///
/// If called at the end of the text, this will return a zero length substring with the SubStringFlags.text_end flag set.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///   - `substring`: the SubString to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getNextTextSubString(text: ?*Text, substring: ?*const SubString) sdl.Error!GetNextTextSubStringResult {
    var next_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetNextTextSubString)).@"fn".params[2].type.?).pointer.child = undefined;
    if (!c.TTF_GetNextTextSubString(@ptrCast(text), @ptrCast(substring), &next_raw)) return error.SdlFailure;
    return GetNextTextSubStringResult{
        .next = @bitCast(next_raw),
    };
}

/// Query the number of faces of a font.
///
/// - **Parameters:**
///   - `font`: the font to query.
///
/// - **Returns:** the number of FreeType font faces.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getNumFontFaces(font: ?Font) c_int {
    return c.TTF_GetNumFontFaces(if (font) |resource| @ptrCast(resource.value) else null);
}

/// Get the previous substring in a text object
///
/// If called at the start of the text, this will return a zero length substring with the SubStringFlags.text_start flag set.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///   - `substring`: the SubString to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getPreviousTextSubString(text: ?*Text, substring: ?*const SubString, previous: ?*SubString) sdl.Error!void {
    if (!c.TTF_GetPreviousTextSubString(@ptrCast(text), @ptrCast(substring), @ptrCast(previous))) return error.SdlFailure;
}

/// Named output values.
pub const GetStringSizeResult = struct {
    /// Output `w`.
    w: c_int,
    /// Output `h`.
    h: c_int,
};

/// Calculate the dimensions of a rendered string of UTF-8 text.
///
/// This will report the width and height, in pixels, of the space that the specified string will take to fully render.
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `text`: text to calculate, in UTF-8 encoding.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getStringSize(font: ?Font, text: []const u8) sdl.Error!GetStringSizeResult {
    var w_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSize)).@"fn".params[3].type.?).pointer.child = undefined;
    var h_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSize)).@"fn".params[4].type.?).pointer.child = undefined;
    if (!c.TTF_GetStringSize(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), &w_raw, &h_raw)) return error.SdlFailure;
    return GetStringSizeResult{
        .w = w_raw,
        .h = h_raw,
    };
}

/// Named output values.
pub const GetStringSizeWrappedResult = struct {
    /// Output `w`.
    w: c_int,
    /// Output `h`.
    h: c_int,
};

/// Calculate the dimensions of a rendered string of UTF-8 text.
///
/// This will report the width and height, in pixels, of the space that the specified string will take to fully render.
/// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
/// If wrap_width is 0, this function will only wrap on newline characters.
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `text`: text to calculate, in UTF-8 encoding.
///   - `wrap_width`: the maximum width or 0 to wrap on newline characters.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getStringSizeWrapped(font: ?Font, text: []const u8, wrap_width: c_int) sdl.Error!GetStringSizeWrappedResult {
    var w_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSizeWrapped)).@"fn".params[4].type.?).pointer.child = undefined;
    var h_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetStringSizeWrapped)).@"fn".params[5].type.?).pointer.child = undefined;
    if (!c.TTF_GetStringSizeWrapped(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), wrap_width, &w_raw, &h_raw)) return error.SdlFailure;
    return GetStringSizeWrappedResult{
        .w = w_raw,
        .h = h_raw,
    };
}

/// Named output values.
pub const GetTextColorResult = struct {
    /// Output `r`.
    r: u8,
    /// Output `g`.
    g: u8,
    /// Output `b`.
    b: u8,
    /// Output `a`.
    a: u8,
};

/// Get the color of a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextColorFloat
/// - **See also:** setTextColor
/// Returns named output values.
pub inline fn getTextColor(text: ?*Text) sdl.Error!GetTextColorResult {
    var r_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColor)).@"fn".params[1].type.?).pointer.child = undefined;
    var g_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColor)).@"fn".params[2].type.?).pointer.child = undefined;
    var b_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColor)).@"fn".params[3].type.?).pointer.child = undefined;
    var a_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColor)).@"fn".params[4].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextColor(@ptrCast(text), &r_raw, &g_raw, &b_raw, &a_raw)) return error.SdlFailure;
    return GetTextColorResult{
        .r = r_raw,
        .g = g_raw,
        .b = b_raw,
        .a = a_raw,
    };
}

/// Named output values.
pub const GetTextColorFloatResult = struct {
    /// Output `r`.
    r: f32,
    /// Output `g`.
    g: f32,
    /// Output `b`.
    b: f32,
    /// Output `a`.
    a: f32,
};

/// Get the color of a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextColor
/// - **See also:** setTextColorFloat
/// Returns named output values.
pub inline fn getTextColorFloat(text: ?*Text) sdl.Error!GetTextColorFloatResult {
    var r_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColorFloat)).@"fn".params[1].type.?).pointer.child = undefined;
    var g_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColorFloat)).@"fn".params[2].type.?).pointer.child = undefined;
    var b_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColorFloat)).@"fn".params[3].type.?).pointer.child = undefined;
    var a_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextColorFloat)).@"fn".params[4].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextColorFloat(@ptrCast(text), &r_raw, &g_raw, &b_raw, &a_raw)) return error.SdlFailure;
    return GetTextColorFloatResult{
        .r = r_raw,
        .g = g_raw,
        .b = b_raw,
        .a = a_raw,
    };
}

/// Get the direction to be used for text shaping a text object.
///
/// This defaults to the direction of the font used by the text object.
///
/// - **Parameters:**
///   - `text`: the text to query.
///
/// - **Returns:** the direction to be used for text shaping.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getTextDirection(text: ?*Text) Direction {
    const result = c.TTF_GetTextDirection(@ptrCast(text));
    return @enumFromInt(result);
}

/// Get the text engine used by a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** the textengine.TextEngine used by the text on success or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** setTextEngine
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getTextEngine(text: ?*Text) sdl.Error!*TextEngine {
    const result = c.TTF_GetTextEngine(@ptrCast(text));
    if (result == null) return error.SdlFailure;
    return @ptrCast(result.?);
}

/// Get the font used by a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** the Font used by the text on success or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** setTextFont
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getTextFont(text: ?*Text) sdl.Error!Font {
    const result = c.TTF_GetTextFont(@ptrCast(text));
    if (result == null) return error.SdlFailure;
    return Font{ .value = @ptrCast(result.?) };
}

/// Named output values.
pub const GetTextPositionResult = struct {
    /// Output `x`.
    x: c_int,
    /// Output `y`.
    y: c_int,
};

/// Get the position of a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** setTextPosition
/// Returns named output values.
pub inline fn getTextPosition(text: ?*Text) ?GetTextPositionResult {
    var x_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextPosition)).@"fn".params[1].type.?).pointer.child = undefined;
    var y_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextPosition)).@"fn".params[2].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextPosition(@ptrCast(text), &x_raw, &y_raw)) return null;
    return GetTextPositionResult{
        .x = x_raw,
        .y = y_raw,
    };
}

/// Get the properties associated with a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn getTextProperties(text: ?*Text) sdl.Error!sdl.properties.Id {
    const result = c.TTF_GetTextProperties(@ptrCast(text));
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Get the script used for text shaping a text object.
///
/// This defaults to the script of the font used by the text object.
///
/// - **Parameters:**
///   - `text`: the text to query.
///
/// - **Returns:** an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html) or 0 if a script hasn't been set on either the text object or the font.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** tagToString
pub inline fn getTextScript(text: ?*Text) u32 {
    return c.TTF_GetTextScript(@ptrCast(text));
}

/// Named output values.
pub const GetTextSizeResult = struct {
    /// Output `w`.
    w: c_int,
    /// Output `h`.
    h: c_int,
};

/// Get the size of a text object.
///
/// The size of the text may change when the font or font style and size change.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getTextSize(text: ?*Text) sdl.Error!GetTextSizeResult {
    var w_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextSize)).@"fn".params[1].type.?).pointer.child = undefined;
    var h_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextSize)).@"fn".params[2].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextSize(@ptrCast(text), &w_raw, &h_raw)) return error.SdlFailure;
    return GetTextSizeResult{
        .w = w_raw,
        .h = h_raw,
    };
}

/// Named output values.
pub const GetTextSubStringResult = struct {
    /// Output `substring`.
    substring: SubString,
};

/// Get the substring of a text object that surrounds a text offset.
///
/// If `offset` is less than 0, this will return a zero length substring at the beginning of the text with the SubStringFlags.text_start flag set. If `offset` is greater than or equal to the length of the text string, this will return a zero length substring at the end of the text with the SubStringFlags.text_end flag set.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///   - `offset`: a byte offset into the text string.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getTextSubString(text: ?*Text, offset: c_int) sdl.Error!GetTextSubStringResult {
    var substring_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextSubString)).@"fn".params[2].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextSubString(@ptrCast(text), offset, &substring_raw)) return error.SdlFailure;
    return GetTextSubStringResult{
        .substring = @bitCast(substring_raw),
    };
}

/// Named output values.
pub const GetTextSubStringForLineResult = struct {
    /// Output `substring`.
    substring: SubString,
};

/// Get the substring of a text object that contains the given line.
///
/// If `line` is less than 0, this will return a zero length substring at the beginning of the text with the SubStringFlags.text_start flag set. If `line` is greater than or equal to `text->num_lines` this will return a zero length substring at the end of the text with the SubStringFlags.text_end flag set.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///   - `line`: a zero-based line index, in the range [0 .. text->num_lines-1].
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getTextSubStringForLine(text: ?*Text, line: c_int) sdl.Error!GetTextSubStringForLineResult {
    var substring_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextSubStringForLine)).@"fn".params[2].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextSubStringForLine(@ptrCast(text), line, &substring_raw)) return error.SdlFailure;
    return GetTextSubStringForLineResult{
        .substring = @bitCast(substring_raw),
    };
}

/// Named output values.
pub const GetTextSubStringForPointResult = struct {
    /// Output `substring`.
    substring: SubString,
};

/// Get the portion of a text string that is closest to a point.
///
/// This will return the closest substring of text to the given point.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///   - `x`: the x coordinate relative to the left side of the text, may be outside the bounds of the text area.
///   - `y`: the y coordinate relative to the top side of the text, may be outside the bounds of the text area.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn getTextSubStringForPoint(text: ?*Text, x: c_int, y: c_int) sdl.Error!GetTextSubStringForPointResult {
    var substring_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextSubStringForPoint)).@"fn".params[3].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextSubStringForPoint(@ptrCast(text), x, y, &substring_raw)) return error.SdlFailure;
    return GetTextSubStringForPointResult{
        .substring = @bitCast(substring_raw),
    };
}

/// Get the substrings of a text object that contain a range of text.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///   - `offset`: a byte offset into the text string.
///   - `length`: the length of the range being queried, in bytes, or -1 for the remainder of the string.
///
/// - **Returns:** a NULL terminated array of substring pointers or NULL on failure; call sdl.error_.get() for more information. The returned slice is allocated with the caller-provided allocator.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn getTextSubStringsForRange(allocator_: std.mem.Allocator, text: ?*Text, offset: c_int, length: c_int) sdl.Error![]SubString {
    const Count = @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextSubStringsForRange)).@"fn".params[3].type.?).pointer.child;
    var count: Count = 0;
    const result = c.TTF_GetTextSubStringsForRange(@ptrCast(text), offset, length, &count);
    if (result == null) return error.SdlFailure;
    defer c.SDL_free(@ptrCast(result));
    const length_2 = std.math.cast(usize, count) orelse return error.SdlFailure;
    const copy = allocator_.alloc(SubString, length_2) catch return error.OutOfMemory;
    errdefer allocator_.free(copy);
    for (copy, 0..) |*item, index| {
        const source = result[index];
        if (source == null) return error.SdlFailure;
        item.* = @bitCast(source.*);
    }
    return copy;
}

/// Named output values.
pub const GetTextWrapWidthResult = struct {
    /// Output `wrap_width`.
    wrap_width: c_int,
};

/// Get whether wrapping is enabled on a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** setTextWrapWidth
/// Returns named output values.
pub inline fn getTextWrapWidth(text: ?*Text) sdl.Error!GetTextWrapWidthResult {
    var wrap_width_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_GetTextWrapWidth)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.TTF_GetTextWrapWidth(@ptrCast(text), &wrap_width_raw)) return error.SdlFailure;
    return GetTextWrapWidthResult{
        .wrap_width = wrap_width_raw,
    };
}

/// Initialize SDL_ttf.
///
/// You must successfully call this function before it is safe to call any other function in this library.
/// It is safe to call this more than once, and each successful init() call should be paired with a matching quit() call.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** quit
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn init() sdl.Error!void {
    if (!c.TTF_Init()) return error.SdlFailure;
}

/// Insert UTF-8 text into a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `offset`: the offset, in bytes, from the beginning of the string if >= 0, the offset from the end of the string if < 0. Note that this does not do UTF-8 validation, so you should only insert at UTF-8 sequence boundaries.
///   - `string`: the UTF-8 text to insert.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** appendTextString
/// - **See also:** deleteTextString
/// - **See also:** setTextString
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn insertTextString(text: []Text, offset: c_int, string: ?[:0]const u8) sdl.Error!void {
    if (!c.TTF_InsertTextString(@ptrCast(text.ptr), offset, if (string != null) @ptrCast(string.?.ptr) else null, @intCast(text.len))) return error.SdlFailure;
}

/// Named output values.
pub const MeasureStringResult = struct {
    /// Output `measured_width`.
    measured_width: c_int,
};

/// Calculate how much of a UTF-8 string will fit in a given width.
///
/// This reports the number of characters that can be rendered before reaching `max_width`.
/// This does not need to render the string to do this calculation.
///
/// - **Parameters:**
///   - `font`: the font to query.
///   - `text`: text to calculate, in UTF-8 encoding.
///   - `max_width`: maximum width, in pixels, available for the string, or 0 for unbounded width.
///   - `measured_length`: a pointer filled in with the length, in bytes, of the string that will fit, may be NULL.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// Returns named output values.
pub inline fn measureString(font: ?Font, text: []const u8, max_width: c_int, measured_length: []c_ulong) sdl.Error!MeasureStringResult {
    var measured_width_raw: @typeInfo(@typeInfo(@TypeOf(c.TTF_MeasureString)).@"fn".params[4].type.?).pointer.child = undefined;
    if (!c.TTF_MeasureString(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(if (measured_length.len == text.len) text.len else @panic("related slices must have equal lengths")), max_width, &measured_width_raw, @ptrCast(measured_length.ptr))) return error.SdlFailure;
    return MeasureStringResult{
        .measured_width = measured_width_raw,
    };
}

/// Create a font from a file, using a specified point size.
///
/// Some .fon fonts will have several sizes embedded in the file, so the point size becomes the index of choosing which size. If the value is too high, the last indexed size will be the default.
/// When done with the returned Font, use Font.close() to dispose of it.
///
/// - **Parameters:**
///   - `file`: path to font file.
///   - `ptsize`: point size to use for the newly-opened font.
///
/// - **Returns:** a valid Font, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.close
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn openFont(file: ?[:0]const u8, ptsize: f32) sdl.Error!Font {
    const result = c.TTF_OpenFont(if (file != null) @ptrCast(file.?.ptr) else null, ptsize);
    if (result == null) return error.SdlFailure;
    return Font{ .value = @ptrCast(result.?) };
}

/// Create a font from an sdl.ioStream.IoStream, using a specified point size.
///
/// Some .fon fonts will have several sizes embedded in the file, so the point size becomes the index of choosing which size. If the value is too high, the last indexed size will be the default.
/// If `closeio` is true, `src` will be automatically closed once the font is closed. Otherwise you should close `src` yourself after closing the font.
/// When done with the returned Font, use Font.close() to dispose of it.
///
/// - **Parameters:**
///   - `src`: an sdl.ioStream.IoStream to provide a font file's data.
///   - `closeio`: true to close `src` when the font is closed, false to leave it open.
///   - `ptsize`: point size to use for the newly-opened font.
///
/// - **Returns:** a valid Font, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.close
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn openFontIo(src: ?*sdl.ioStream.IoStream, closeio: bool, ptsize: f32) sdl.Error!Font {
    const result = c.TTF_OpenFontIO(@ptrCast(src), closeio, ptsize);
    if (result == null) return error.SdlFailure;
    return Font{ .value = @ptrCast(result.?) };
}

/// Create a font with the specified properties.
///
/// These are the supported properties:
/// - `prop_font_create_filename_string`: the font file to open, if an sdl.ioStream.IoStream isn't being used. This is required if `prop_font_create_io_stream_pointer` and `prop_font_create_existing_font` aren't set.
/// - `prop_font_create_io_stream_pointer`: an sdl.ioStream.IoStream containing the font to be opened. This should not be closed until the font is closed. This is required if `prop_font_create_filename_string` and `prop_font_create_existing_font` aren't set.
/// - `prop_font_create_io_stream_offset_number`: the offset in the iostream for the beginning of the font, defaults to 0.
/// - `prop_font_create_io_stream_autoclose_boolean`: true if closing the font should also close the associated sdl.ioStream.IoStream.
/// - `prop_font_create_size_float`: the point size of the font. Some .fon fonts will have several sizes embedded in the file, so the point size becomes the index of choosing which size. If the value is too high, the last indexed size will be the default.
/// - `prop_font_create_face_number`: the face index of the font, if the font contains multiple font faces.
/// - `prop_font_create_horizontal_dpi_number`: the horizontal DPI to use for font rendering, defaults to `prop_font_create_vertical_dpi_number` if set, or 72 otherwise.
/// - `prop_font_create_vertical_dpi_number`: the vertical DPI to use for font rendering, defaults to `prop_font_create_horizontal_dpi_number` if set, or 72 otherwise.
/// - `prop_font_create_existing_font`: an optional Font that, if set, will be used as the font data source and the initial size and style of the new font.
///
/// - **Parameters:**
///   - `props`: the properties to use.
///
/// - **Returns:** a valid Font, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.close
///
/// Returned handles are borrowed; do not call their destructive lifecycle methods.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn openFontWithProperties(props: sdl.properties.Id) sdl.Error!Font {
    const result = c.TTF_OpenFontWithProperties(props);
    if (result == null) return error.SdlFailure;
    return Font{ .value = @ptrCast(result.?) };
}

/// Deinitialize SDL_ttf.
///
/// You must call this when done with the library, to free internal resources. It is safe to call this when the library isn't initialized, as it will just return immediately.
/// Once you have as many quit calls as you have had successful calls to init, the library will actually deinitialize.
/// Please note that this does not automatically close any fonts that are still open at the time of deinitialization, and it is possibly not safe to close them afterwards, as parts of the library will no longer be initialized to deal with it. A well-written program should call Font.close() on any open fonts before calling this function!
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn quit() void {
    c.TTF_Quit();
}

/// Remove a fallback font.
///
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to modify.
///   - `fallback`: the font to remove as a fallback.
///
/// - **Thread safety:** This function should be called on the thread that created both fonts.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.addFallback
/// - **See also:** Font.clearFallbackFonts
pub inline fn removeFallbackFont(font: ?Font, fallback: ?Font) void {
    c.TTF_RemoveFallbackFont(if (font) |resource| @ptrCast(resource.value) else null, if (fallback) |resource| @ptrCast(resource.value) else null);
}

/// Render a single UNICODE codepoint at high quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, using alpha blending to dither the font with the given color. This function returns the new surface, or NULL if there was an error.
/// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
/// You can render at other quality levels with Font.renderGlyphSolid, Font.renderGlyphShaded, and Font.renderGlyphLcd.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `ch`: the codepoint to render.
///   - `fg`: the foreground color for the text.
///
/// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderGlyphLcd
/// - **See also:** Font.renderGlyphShaded
/// - **See also:** Font.renderGlyphSolid
pub inline fn renderGlyphBlended(font: ?Font, ch: u32, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderGlyph_Blended(if (font) |resource| @ptrCast(resource.value) else null, ch, @bitCast(fg));
    return if (result == null) null else @ptrCast(result);
}

/// Render a single UNICODE codepoint at LCD subpixel quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, and render alpha-blended text using FreeType's LCD subpixel rendering. This function returns the new surface, or NULL if there was an error.
/// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
/// You can render at other quality levels with Font.renderGlyphSolid, Font.renderGlyphShaded, and Font.renderGlyphBlended.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `ch`: the codepoint to render.
///   - `fg`: the foreground color for the text.
///   - `bg`: the background color for the text.
///
/// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderGlyphBlended
/// - **See also:** Font.renderGlyphShaded
/// - **See also:** Font.renderGlyphSolid
pub inline fn renderGlyphLcd(font: ?Font, ch: u32, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderGlyph_LCD(if (font) |resource| @ptrCast(resource.value) else null, ch, @bitCast(fg), @bitCast(bg));
    return if (result == null) null else @ptrCast(result);
}

/// Render a single UNICODE codepoint at high quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the specified background color, while other pixels have varying degrees of the foreground color. This function returns the new surface, or NULL if there was an error.
/// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
/// You can render at other quality levels with Font.renderGlyphSolid, Font.renderGlyphBlended, and Font.renderGlyphLcd.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `ch`: the codepoint to render.
///   - `fg`: the foreground color for the text.
///   - `bg`: the background color for the text.
///
/// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderGlyphBlended
/// - **See also:** Font.renderGlyphLcd
/// - **See also:** Font.renderGlyphSolid
pub inline fn renderGlyphShaded(font: ?Font, ch: u32, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderGlyph_Shaded(if (font) |resource| @ptrCast(resource.value) else null, ch, @bitCast(fg), @bitCast(bg));
    return if (result == null) null else @ptrCast(result);
}

/// Render a single 32-bit glyph at fast quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the colorkey, giving a transparent background. The 1 pixel will be set to the text color.
/// The glyph is rendered without any padding or centering in the X direction, and aligned normally in the Y direction.
/// You can render at other quality levels with Font.renderGlyphShaded, Font.renderGlyphBlended, and Font.renderGlyphLcd.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `ch`: the character to render.
///   - `fg`: the foreground color for the text.
///
/// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderGlyphBlended
/// - **See also:** Font.renderGlyphLcd
/// - **See also:** Font.renderGlyphShaded
pub inline fn renderGlyphSolid(font: ?Font, ch: u32, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderGlyph_Solid(if (font) |resource| @ptrCast(resource.value) else null, ch, @bitCast(fg));
    return if (result == null) null else @ptrCast(result);
}

/// Render UTF-8 text at high quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, using alpha blending to dither the font with the given color. This function returns the new surface, or NULL if there was an error.
/// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextBlendedWrapped() instead if you need to wrap the output to multiple lines.
/// This will not wrap on newline characters.
/// You can render at other quality levels with Font.renderTextSolid, Font.renderTextShaded, and Font.renderTextLcd.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///
/// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlendedWrapped
/// - **See also:** Font.renderTextLcd
/// - **See also:** Font.renderTextShaded
/// - **See also:** Font.renderTextSolid
pub inline fn renderTextBlended(font: ?Font, text: []const u8, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_Blended(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg));
    return if (result == null) null else @ptrCast(result);
}

/// Render word-wrapped UTF-8 text at high quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, using alpha blending to dither the font with the given color. This function returns the new surface, or NULL if there was an error.
/// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
/// If wrap_width is 0, this function will only wrap on newline characters.
/// You can render at other quality levels with Font.renderTextSolidWrapped, Font.renderTextShadedWrapped, and Font.renderTextLcdWrapped.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///   - `wrap_width`: the maximum width of the text surface or 0 to wrap on newline characters.
///
/// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlended
/// - **See also:** Font.renderTextLcdWrapped
/// - **See also:** Font.renderTextShadedWrapped
/// - **See also:** Font.renderTextSolidWrapped
pub inline fn renderTextBlendedWrapped(font: ?Font, text: []const u8, fg: sdl.pixels.Color, wrap_width: c_int) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_Blended_Wrapped(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), wrap_width);
    return if (result == null) null else @ptrCast(result);
}

/// Render UTF-8 text at LCD subpixel quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, and render alpha-blended text using FreeType's LCD subpixel rendering. This function returns the new surface, or NULL if there was an error.
/// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextLcdWrapped() instead if you need to wrap the output to multiple lines.
/// This will not wrap on newline characters.
/// You can render at other quality levels with Font.renderTextSolid, Font.renderTextShaded, and Font.renderTextBlended.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///   - `bg`: the background color for the text.
///
/// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlended
/// - **See also:** Font.renderTextLcdWrapped
/// - **See also:** Font.renderTextShaded
/// - **See also:** Font.renderTextSolid
pub inline fn renderTextLcd(font: ?Font, text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_LCD(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg));
    return if (result == null) null else @ptrCast(result);
}

/// Render word-wrapped UTF-8 text at LCD subpixel quality to a new ARGB surface.
///
/// This function will allocate a new 32-bit, ARGB surface, and render alpha-blended text using FreeType's LCD subpixel rendering. This function returns the new surface, or NULL if there was an error.
/// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
/// If wrap_width is 0, this function will only wrap on newline characters.
/// You can render at other quality levels with Font.renderTextSolidWrapped, Font.renderTextShadedWrapped, and Font.renderTextBlendedWrapped.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///   - `bg`: the background color for the text.
///   - `wrap_width`: the maximum width of the text surface or 0 to wrap on newline characters.
///
/// - **Returns:** a new 32-bit, ARGB surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlendedWrapped
/// - **See also:** Font.renderTextLcd
/// - **See also:** Font.renderTextShadedWrapped
/// - **See also:** Font.renderTextSolidWrapped
pub inline fn renderTextLcdWrapped(font: ?Font, text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color, wrap_width: c_int) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_LCD_Wrapped(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg), wrap_width);
    return if (result == null) null else @ptrCast(result);
}

/// Render UTF-8 text at high quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the specified background color, while other pixels have varying degrees of the foreground color. This function returns the new surface, or NULL if there was an error.
/// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextShadedWrapped() instead if you need to wrap the output to multiple lines.
/// This will not wrap on newline characters.
/// You can render at other quality levels with Font.renderTextSolid, Font.renderTextBlended, and Font.renderTextLcd.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///   - `bg`: the background color for the text.
///
/// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlended
/// - **See also:** Font.renderTextLcd
/// - **See also:** Font.renderTextShadedWrapped
/// - **See also:** Font.renderTextSolid
pub inline fn renderTextShaded(font: ?Font, text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_Shaded(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg));
    return if (result == null) null else @ptrCast(result);
}

/// Render word-wrapped UTF-8 text at high quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the specified background color, while other pixels have varying degrees of the foreground color. This function returns the new surface, or NULL if there was an error.
/// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_width` in pixels.
/// If wrap_width is 0, this function will only wrap on newline characters.
/// You can render at other quality levels with Font.renderTextSolidWrapped, Font.renderTextBlendedWrapped, and Font.renderTextLcdWrapped.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///   - `bg`: the background color for the text.
///   - `wrap_width`: the maximum width of the text surface or 0 to wrap on newline characters.
///
/// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlendedWrapped
/// - **See also:** Font.renderTextLcdWrapped
/// - **See also:** Font.renderTextShaded
/// - **See also:** Font.renderTextSolidWrapped
pub inline fn renderTextShadedWrapped(font: ?Font, text: []const u8, fg: sdl.pixels.Color, bg: sdl.pixels.Color, wrap_width: c_int) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_Shaded_Wrapped(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg), @bitCast(bg), wrap_width);
    return if (result == null) null else @ptrCast(result);
}

/// Render UTF-8 text at fast quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the colorkey, giving a transparent background. The 1 pixel will be set to the text color.
/// This will not word-wrap the string; you'll get a surface with a single line of text, as long as the string requires. You can use Font.renderTextSolidWrapped() instead if you need to wrap the output to multiple lines.
/// This will not wrap on newline characters.
/// You can render at other quality levels with Font.renderTextShaded, Font.renderTextBlended, and Font.renderTextLcd.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `fg`: the foreground color for the text.
///
/// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlended
/// - **See also:** Font.renderTextLcd
/// - **See also:** Font.renderTextShaded
/// - **See also:** Font.renderTextSolid
/// - **See also:** Font.renderTextSolidWrapped
pub inline fn renderTextSolid(font: ?Font, text: []const u8, fg: sdl.pixels.Color) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_Solid(if (font) |resource| @ptrCast(resource.value) else null, @ptrCast(text.ptr), @intCast(text.len), @bitCast(fg));
    return if (result == null) null else @ptrCast(result);
}

/// Render word-wrapped UTF-8 text at fast quality to a new 8-bit surface.
///
/// This function will allocate a new 8-bit, palettized surface. The surface's 0 pixel will be the colorkey, giving a transparent background. The 1 pixel will be set to the text color.
/// Text is wrapped to multiple lines on line endings and on word boundaries if it extends beyond `wrap_length` in pixels.
/// If wrapLength is 0, this function will only wrap on newline characters.
/// You can render at other quality levels with Font.renderTextShadedWrapped, Font.renderTextBlendedWrapped, and Font.renderTextLcdWrapped.
///
/// - **Parameters:**
///   - `font`: the font to render with.
///   - `text`: text to render, in UTF-8 encoding.
///   - `length`: the length of the text, in bytes, or 0 for null terminated text.
///   - `fg`: the foreground color for the text.
///   - `wrap_length`: the maximum width of the text surface or 0 to wrap on newline characters.
///
/// - **Returns:** a new 8-bit, palettized surface, or NULL if there was an error.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.renderTextBlendedWrapped
/// - **See also:** Font.renderTextLcdWrapped
/// - **See also:** Font.renderTextShadedWrapped
/// - **See also:** Font.renderTextSolid
pub inline fn renderTextSolidWrapped(font: ?Font, text: ?[:0]const u8, length: c_ulong, fg: sdl.pixels.Color, wrap_length: c_int) ?*sdl.surface.Surface {
    const result = c.TTF_RenderText_Solid_Wrapped(if (font) |resource| @ptrCast(resource.value) else null, if (text != null) @ptrCast(text.?.ptr) else null, length, @bitCast(fg), wrap_length);
    return if (result == null) null else @ptrCast(result);
}

/// Set the direction to be used for text shaping by a font.
///
/// This function only supports left-to-right text shaping if SDL_ttf was not built with HarfBuzz support.
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to modify.
///   - `direction`: the new direction for text to flow.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontDirection(font: ?Font, direction: Direction) sdl.Error!void {
    if (!c.TTF_SetFontDirection(if (font) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(direction)))) return error.SdlFailure;
}

/// Set a font's current hinter setting.
///
/// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
/// The hinter setting is a single value:
/// - `HintingFlags.normal`
/// - `HintingFlags.light`
/// - `HintingFlags.mono`
/// - `HintingFlags.none`
/// - `HintingFlags.light_sub_pixel` (available in SDL_ttf 3.0.0 and later)
///
/// - **Parameters:**
///   - `font`: the font to set a new hinter setting on.
///   - `hinting`: the new hinter setting.
///
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getHinting
pub inline fn setFontHinting(font: ?Font, hinting: HintingFlags) void {
    c.TTF_SetFontHinting(if (font) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(hinting)));
}

/// Set if kerning is enabled for a font.
///
/// Newly-opened fonts default to allowing kerning. This is generally a good policy unless you have a strong reason to disable it, as it tends to produce better rendering (with kerning disabled, some fonts might render the word `kerning` as something that looks like `keming` for example).
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to set kerning on.
///   - `enabled`: true to enable kerning, false to disable.
///
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getKerning
pub inline fn setFontKerning(font: ?Font, enabled: bool) void {
    c.TTF_SetFontKerning(if (font) |resource| @ptrCast(resource.value) else null, enabled);
}

/// Set language to be used for text shaping by a font.
///
/// If SDL_ttf was not built with HarfBuzz support, this function returns false.
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to specify a language for.
///   - `language_bcp47`: a null-terminated string containing the desired language's BCP47 code. Or null to reset the value.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontLanguage(font: ?Font, language_bcp47: ?[:0]const u8) sdl.Error!void {
    if (!c.TTF_SetFontLanguage(if (font) |resource| @ptrCast(resource.value) else null, if (language_bcp47 != null) @ptrCast(language_bcp47.?.ptr) else null)) return error.SdlFailure;
}

/// Set the spacing between lines of text for a font.
///
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to modify.
///   - `lineskip`: the new line spacing for the font.
///
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getLineSkip
pub inline fn setFontLineSkip(font: ?Font, lineskip: c_int) void {
    c.TTF_SetFontLineSkip(if (font) |resource| @ptrCast(resource.value) else null, lineskip);
}

/// Set a font's current outline.
///
/// This uses the font properties `prop_font_outline_line_cap_number`, `prop_font_outline_line_join_number`, and `prop_font_outline_miter_limit_number` when setting the font outline.
/// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
///
/// - **Parameters:**
///   - `font`: the font to set a new outline on.
///   - `outline`: positive outline value, 0 to default.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getOutline
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontOutline(font: ?Font, outline: c_int) sdl.Error!void {
    if (!c.TTF_SetFontOutline(if (font) |resource| @ptrCast(resource.value) else null, outline)) return error.SdlFailure;
}

/// Set the script to be used for text shaping by a font.
///
/// This returns false if SDL_ttf isn't built with HarfBuzz support.
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to modify.
///   - `script`: an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** stringToTag
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontScript(font: ?Font, script: u32) sdl.Error!void {
    if (!c.TTF_SetFontScript(if (font) |resource| @ptrCast(resource.value) else null, script)) return error.SdlFailure;
}

/// Enable Signed Distance Field rendering for a font.
///
/// SDF is a technique that helps fonts look sharp even when scaling and rotating, and requires special shader support for display.
/// This works with Blended APIs, and generates the raw signed distance values in the alpha channel of the resulting texture.
/// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
///
/// - **Parameters:**
///   - `font`: the font to set SDF support on.
///   - `enabled`: true to enable SDF, false to disable.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getSdf
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontSdf(font: ?Font, enabled: bool) sdl.Error!void {
    if (!c.TTF_SetFontSDF(if (font) |resource| @ptrCast(resource.value) else null, enabled)) return error.SdlFailure;
}

/// Set a font's size dynamically.
///
/// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
///
/// - **Parameters:**
///   - `font`: the font to resize.
///   - `ptsize`: the new point size.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getSize
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontSize(font: ?Font, ptsize: f32) sdl.Error!void {
    if (!c.TTF_SetFontSize(if (font) |resource| @ptrCast(resource.value) else null, ptsize)) return error.SdlFailure;
}

/// Set font size dynamically with target resolutions, in dots per inch.
///
/// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
///
/// - **Parameters:**
///   - `font`: the font to resize.
///   - `ptsize`: the new point size.
///   - `hdpi`: the target horizontal DPI.
///   - `vdpi`: the target vertical DPI.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getSize
/// - **See also:** TTF_GetFontSizeDPI (C API outside this module)
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setFontSizeDpi(font: ?Font, ptsize: f32, hdpi: c_int, vdpi: c_int) sdl.Error!void {
    if (!c.TTF_SetFontSizeDPI(if (font) |resource| @ptrCast(resource.value) else null, ptsize, hdpi, vdpi)) return error.SdlFailure;
}

/// Set a font's current style.
///
/// This updates any Text objects using this font, and clears already-generated glyphs, if any, from the cache.
/// The font styles are a set of bit flags, OR'd together:
/// - `FontStyleFlags.normal` (is zero)
/// - `FontStyleFlags.bold`
/// - `FontStyleFlags.italic`
/// - `FontStyleFlags.underline`
/// - `FontStyleFlags.strikethrough`
///
/// - **Parameters:**
///   - `font`: the font to set a new style on.
///   - `style`: the new style values to set, OR'd together.
///
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getStyle
pub inline fn setFontStyle(font: ?Font, style: FontStyleFlags) void {
    c.TTF_SetFontStyle(if (font) |resource| @ptrCast(resource.value) else null, @bitCast(style));
}

/// Set a font's current wrap alignment option.
///
/// This updates any Text objects using this font.
///
/// - **Parameters:**
///   - `font`: the font to set a new wrap alignment option on.
///   - `align_`: the new wrap alignment option.
///
/// - **Thread safety:** This function should be called on the thread that created the font.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** Font.getWrapAlignment
pub inline fn setFontWrapAlignment(font: ?Font, align_: HorizontalAlignment) void {
    c.TTF_SetFontWrapAlignment(if (font) |resource| @ptrCast(resource.value) else null, @intCast(@intFromEnum(align_)));
}

/// Sets the winding order of the vertices returned by getGpuTextDrawData for a particular GPU text engine.
///
/// - **Parameters:**
///   - `engine`: a textengine.TextEngine object created with createGpuTextEngine().
///   - `winding`: the new winding order option.
///
/// - **Thread safety:** This function should be called on the thread that created the engine.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getGpuTextEngineWinding
pub inline fn setGpuTextEngineWinding(engine: ?*TextEngine, winding: GpuTextEngineWinding) void {
    c.TTF_SetGPUTextEngineWinding(@ptrCast(engine), @intCast(@intFromEnum(winding)));
}

/// Set the color of a text object.
///
/// The default text color is white (255, 255, 255, 255).
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `r`: the red color value in the range of 0-255.
///   - `g`: the green color value in the range of 0-255.
///   - `b`: the blue color value in the range of 0-255.
///   - `a`: the alpha value in the range of 0-255.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextColor
/// - **See also:** setTextColorFloat
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextColor(text: ?*Text, r: u8, g: u8, b: u8, a: u8) sdl.Error!void {
    if (!c.TTF_SetTextColor(@ptrCast(text), r, g, b, a)) return error.SdlFailure;
}

/// Set the color of a text object.
///
/// The default text color is white (1.0f, 1.0f, 1.0f, 1.0f).
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `r`: the red color value, normally in the range of 0-1.
///   - `g`: the green color value, normally in the range of 0-1.
///   - `b`: the blue color value, normally in the range of 0-1.
///   - `a`: the alpha value in the range of 0-1.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextColorFloat
/// - **See also:** setTextColor
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextColorFloat(text: ?*Text, r: f32, g: f32, b: f32, a: f32) sdl.Error!void {
    if (!c.TTF_SetTextColorFloat(@ptrCast(text), r, g, b, a)) return error.SdlFailure;
}

/// Set the direction to be used for text shaping a text object.
///
/// This function only supports left-to-right text shaping if SDL_ttf was not built with HarfBuzz support.
///
/// - **Parameters:**
///   - `text`: the text to modify.
///   - `direction`: the new direction for text to flow.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextDirection(text: ?*Text, direction: Direction) sdl.Error!void {
    if (!c.TTF_SetTextDirection(@ptrCast(text), @intCast(@intFromEnum(direction)))) return error.SdlFailure;
}

/// Set the text engine used by a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `engine`: the text engine to use for drawing.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextEngine
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextEngine(text: ?*Text, engine: ?*TextEngine) sdl.Error!void {
    if (!c.TTF_SetTextEngine(@ptrCast(text), @ptrCast(engine))) return error.SdlFailure;
}

/// Set the font used by a text object.
///
/// When a text object has a font, any changes to the font will automatically regenerate the text. If you set the font to NULL, the text will continue to render but changes to the font will no longer affect the text.
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `font`: the font to use, may be NULL.
///
/// - **Returns:** false if the text pointer is null; otherwise, true. call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextFont
pub inline fn setTextFont(text: ?*Text, font: ?Font) bool {
    return c.TTF_SetTextFont(@ptrCast(text), if (font) |resource| @ptrCast(resource.value) else null);
}

/// Set the position of a text object.
///
/// This can be used to position multiple text objects within a single wrapping text area.
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `x`: the x offset of the upper left corner of this text in pixels.
///   - `y`: the y offset of the upper left corner of this text in pixels.
///
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextPosition
pub inline fn setTextPosition(text: ?*Text, x: c_int, y: c_int) bool {
    return c.TTF_SetTextPosition(@ptrCast(text), x, y);
}

/// Set the script to be used for text shaping a text object.
///
/// This returns false if SDL_ttf isn't built with HarfBuzz support.
///
/// - **Parameters:**
///   - `text`: the text to modify.
///   - `script`: an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html)
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** stringToTag
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextScript(text: ?*Text, script: u32) sdl.Error!void {
    if (!c.TTF_SetTextScript(@ptrCast(text), script)) return error.SdlFailure;
}

/// Set the UTF-8 text used by a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `string`: the UTF-8 text to use, may be NULL.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** appendTextString
/// - **See also:** deleteTextString
/// - **See also:** insertTextString
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextString(text: []Text, string: ?[:0]const u8) sdl.Error!void {
    if (!c.TTF_SetTextString(@ptrCast(text.ptr), if (string != null) @ptrCast(string.?.ptr) else null, @intCast(text.len))) return error.SdlFailure;
}

/// Set whether whitespace should be visible when wrapping a text object.
///
/// If the whitespace is visible, it will take up space for purposes of alignment and wrapping. This is good for editing, but looks better when centered or aligned if whitespace around line wrapping is hidden. This defaults false.
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `visible`: true to show whitespace when wrapping text, false to hide it.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** textWrapWhitespaceVisible
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextWrapWhitespaceVisible(text: ?*Text, visible: bool) sdl.Error!void {
    if (!c.TTF_SetTextWrapWhitespaceVisible(@ptrCast(text), visible)) return error.SdlFailure;
}

/// Set whether wrapping is enabled on a text object.
///
/// This function may cause the internal text representation to be rebuilt.
///
/// - **Parameters:**
///   - `text`: the Text to modify.
///   - `wrap_width`: the maximum width in pixels, 0 to wrap on newline characters.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** getTextWrapWidth
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn setTextWrapWidth(text: ?*Text, wrap_width: c_int) sdl.Error!void {
    if (!c.TTF_SetTextWrapWidth(@ptrCast(text), wrap_width)) return error.SdlFailure;
}

/// Convert from a 4 character string to a 32-bit tag.
///
/// - **Parameters:**
///   - `string`: the 4 character string to convert.
///
/// - **Returns:** the 32-bit representation of the string.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** tagToString
pub inline fn stringToTag(string: ?[:0]const u8) u32 {
    return c.TTF_StringToTag(if (string != null) @ptrCast(string.?.ptr) else null);
}

/// Convert from a 32-bit tag to a 4 character string.
///
/// - **Parameters:**
///   - `tag`: the 32-bit tag to convert.
///   - `string`: a pointer filled in with the 4 character representation of the tag.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** tagToString
pub inline fn tagToString(tag: u32, string: []u8) void {
    c.TTF_TagToString(tag, @ptrCast(string.ptr), @intCast(string.len));
}

/// Return whether whitespace is shown when wrapping a text object.
///
/// - **Parameters:**
///   - `text`: the Text to query.
///
/// - **Returns:** true if whitespace is shown when wrapping text, or false otherwise.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** setTextWrapWhitespaceVisible
pub inline fn textWrapWhitespaceVisible(text: ?*Text) bool {
    return c.TTF_TextWrapWhitespaceVisible(@ptrCast(text));
}

/// Update the layout of a text object.
///
/// This is automatically done when the layout is requested or the text is rendered, but you can call this if you need more control over the timing of when the layout and text engine representation are updated.
///
/// - **Parameters:**
///   - `text`: the Text to update.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should be called on the thread that created the text.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_ttf reports failure.
pub inline fn updateText(text: ?*Text) sdl.Error!void {
    if (!c.TTF_UpdateText(@ptrCast(text))) return error.SdlFailure;
}

/// This function gets the version of the dynamically linked SDL_ttf library.
///
/// - **Returns:** SDL_ttf version.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
pub inline fn version() c_int {
    return c.TTF_Version();
}

/// Check if SDL_ttf is initialized.
///
/// This reports the number of times the library has been initialized by a call to init(), without a paired deinitialization request from quit().
/// In short: if it's greater than zero, the library is currently initialized and ready to work. If zero, it is not initialized.
/// Despite the return value being a signed integer, this function should not return a negative number.
///
/// - **Returns:** the current number of initialization calls, that need to eventually be paired with this many calls to quit().
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_ttf 3.0.0.
/// - **See also:** init
/// - **See also:** quit
pub inline fn wasInit() c_int {
    return c.TTF_WasInit();
}

/// SDL_ttf APIs for the textengine subsystem.
pub const textengine = struct {
    pub const CopyOperation = root.CopyOperation;
    pub const DrawCommand = root.DrawCommand;
    pub const DrawOperation = root.DrawOperation;
    pub const FillOperation = root.FillOperation;
    pub const TextData = root.TextData;
    pub const TextEngine = root.TextEngine;
    pub const TextLayout = root.TextLayout;
};

// Force target-specific public declarations through Zig's lazy analysis.
comptime {
    if (builtin.abi == .android or builtin.abi == .androideabi) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
    if (builtin.os.tag == .emscripten) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
    if (builtin.os.tag == .ios) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
    if (builtin.os.tag == .linux) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
    if (builtin.os.tag == .macos) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
    if (builtin.os.tag == .tvos) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
    if (builtin.os.tag == .windows) {
        _ = root.CopyOperation;
        _ = root.Direction;
        _ = root.DrawCommand;
        _ = root.DrawOperation;
        _ = root.FillOperation;
        _ = root.Font;
        _ = root.FontStyleFlags;
        _ = root.GpuAtlasDrawSequence;
        _ = root.GpuTextEngineWinding;
        _ = root.HintingFlags;
        _ = root.HorizontalAlignment;
        _ = root.ImageType;
        _ = root.SubString;
        _ = root.SubStringFlags;
        _ = root.Text;
        _ = root.TextData;
        _ = root.TextEngine;
        _ = root.TextLayout;
        _ = root.addFallbackFont;
        _ = root.appendTextString;
        _ = root.clearFallbackFonts;
        _ = root.copyFont;
        _ = root.createGpuTextEngine;
        _ = root.createGpuTextEngineWithProperties;
        _ = root.createRendererTextEngine;
        _ = root.createRendererTextEngineWithProperties;
        _ = root.createSurfaceTextEngine;
        _ = root.createText;
        _ = root.deleteTextString;
        _ = root.destroyGpuTextEngine;
        _ = root.destroyRendererTextEngine;
        _ = root.destroySurfaceTextEngine;
        _ = root.destroyText;
        _ = root.drawRendererText;
        _ = root.drawSurfaceText;
        _ = root.fontHasGlyph;
        _ = root.fontIsFixedWidth;
        _ = root.fontIsScalable;
        _ = root.font_weight_black;
        _ = root.font_weight_bold;
        _ = root.font_weight_extra_black;
        _ = root.font_weight_extra_bold;
        _ = root.font_weight_extra_light;
        _ = root.font_weight_light;
        _ = root.font_weight_medium;
        _ = root.font_weight_normal;
        _ = root.font_weight_semi_bold;
        _ = root.font_weight_thin;
        _ = root.getFontAscent;
        _ = root.getFontDescent;
        _ = root.getFontDirection;
        _ = root.getFontDpi;
        _ = root.getFontFamilyName;
        _ = root.getFontGeneration;
        _ = root.getFontHeight;
        _ = root.getFontHinting;
        _ = root.getFontKerning;
        _ = root.getFontLineSkip;
        _ = root.getFontOutline;
        _ = root.getFontProperties;
        _ = root.getFontScript;
        _ = root.getFontSdf;
        _ = root.getFontSize;
        _ = root.getFontStyle;
        _ = root.getFontStyleName;
        _ = root.getFontWeight;
        _ = root.getFontWrapAlignment;
        _ = root.getFreeTypeVersion;
        _ = root.getGlyphImage;
        _ = root.getGlyphImageForIndex;
        _ = root.getGlyphKerning;
        _ = root.getGlyphMetrics;
        _ = root.getGlyphScript;
        _ = root.getGpuTextDrawData;
        _ = root.getGpuTextEngineWinding;
        _ = root.getHarfBuzzVersion;
        _ = root.getNextTextSubString;
        _ = root.getNumFontFaces;
        _ = root.getPreviousTextSubString;
        _ = root.getStringSize;
        _ = root.getStringSizeWrapped;
        _ = root.getTextColor;
        _ = root.getTextColorFloat;
        _ = root.getTextDirection;
        _ = root.getTextEngine;
        _ = root.getTextFont;
        _ = root.getTextPosition;
        _ = root.getTextProperties;
        _ = root.getTextScript;
        _ = root.getTextSize;
        _ = root.getTextSubString;
        _ = root.getTextSubStringForLine;
        _ = root.getTextSubStringForPoint;
        _ = root.getTextSubStringsForRange;
        _ = root.getTextWrapWidth;
        _ = root.init;
        _ = root.insertTextString;
        _ = root.measureString;
        _ = root.openFont;
        _ = root.openFontIo;
        _ = root.openFontWithProperties;
        _ = root.prop_font_create_existing_font;
        _ = root.prop_font_create_face_number;
        _ = root.prop_font_create_filename_string;
        _ = root.prop_font_create_horizontal_dpi_number;
        _ = root.prop_font_create_io_stream_autoclose_boolean;
        _ = root.prop_font_create_io_stream_offset_number;
        _ = root.prop_font_create_io_stream_pointer;
        _ = root.prop_font_create_size_float;
        _ = root.prop_font_create_vertical_dpi_number;
        _ = root.prop_font_outline_line_cap_number;
        _ = root.prop_font_outline_line_join_number;
        _ = root.prop_font_outline_miter_limit_number;
        _ = root.prop_gpu_text_engine_atlas_texture_size;
        _ = root.prop_gpu_text_engine_device;
        _ = root.prop_renderer_text_engine_atlas_texture_size;
        _ = root.prop_renderer_text_engine_renderer;
        _ = root.quit;
        _ = root.removeFallbackFont;
        _ = root.renderGlyphBlended;
        _ = root.renderGlyphLcd;
        _ = root.renderGlyphShaded;
        _ = root.renderGlyphSolid;
        _ = root.renderTextBlended;
        _ = root.renderTextBlendedWrapped;
        _ = root.renderTextLcd;
        _ = root.renderTextLcdWrapped;
        _ = root.renderTextShaded;
        _ = root.renderTextShadedWrapped;
        _ = root.renderTextSolid;
        _ = root.renderTextSolidWrapped;
        _ = root.setFontDirection;
        _ = root.setFontHinting;
        _ = root.setFontKerning;
        _ = root.setFontLanguage;
        _ = root.setFontLineSkip;
        _ = root.setFontOutline;
        _ = root.setFontScript;
        _ = root.setFontSdf;
        _ = root.setFontSize;
        _ = root.setFontSizeDpi;
        _ = root.setFontStyle;
        _ = root.setFontWrapAlignment;
        _ = root.setGpuTextEngineWinding;
        _ = root.setTextColor;
        _ = root.setTextColorFloat;
        _ = root.setTextDirection;
        _ = root.setTextEngine;
        _ = root.setTextFont;
        _ = root.setTextPosition;
        _ = root.setTextScript;
        _ = root.setTextString;
        _ = root.setTextWrapWhitespaceVisible;
        _ = root.setTextWrapWidth;
        _ = root.stringToTag;
        _ = root.style_bold;
        _ = root.style_italic;
        _ = root.style_normal;
        _ = root.style_strikethrough;
        _ = root.style_underline;
        _ = root.sub_string_flags_direction_mask;
        _ = root.sub_string_flags_line_end;
        _ = root.sub_string_flags_line_start;
        _ = root.sub_string_flags_text_end;
        _ = root.sub_string_flags_text_start;
        _ = root.tagToString;
        _ = root.textWrapWhitespaceVisible;
        _ = root.updateText;
        _ = root.version;
        _ = root.wasInit;
    }
}
