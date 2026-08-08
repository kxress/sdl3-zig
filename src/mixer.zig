// Generated from SDL3_mixer/SDL_mixer.h by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
pub const c = @import("sdl3_mixer_c");
const support = @import("sdl3_support");
const sdl = @import("sdl");
const root = @This();

/// Allocator-backed copies of SDL_mixer strings.
pub const OwnedStrings = struct {
    /// Allocator that owns `items` and every string in it.
    allocator: std.mem.Allocator,
    /// Independently allocated, sentinel-terminated strings.
    items: [][:0]u8,

    /// Release every string and the outer slice, then invalidate this collection.
    pub inline fn deinit(self: *@This()) void {
        support.deinitOwnedStrings(self.allocator, self.items);
        self.* = undefined;
    }
};

/// SDL handle `Audio`.
pub const Audio = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Destroy the specified audio.
    ///
    /// Audio is reference-counted internally, so this function only unrefs it. If doing so causes the reference count to drop to zero, the Audio will be deallocated. This allows the system to safely operate if the audio is still assigned to a Track at the time of destruction. The actual destroying will happen when the track stops using it.
    /// But from the caller's perspective, once this function is called, it should assume the `audio` pointer has become invalid.
    /// Destroying a NULL Audio is a legal no-op.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// This method invalidates the handle after SDL_mixer consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.MIX_DestroyAudio(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Convert sample frames for a MIX_Audio's format to milliseconds.
    ///
    /// This calculates time based on the audio's initial format, even if the format would change mid-stream.
    /// Sample frames are more precise than milliseconds, so out of necessity, this function will approximate by rounding down to the closest full millisecond.
    /// If `frames` is < 0, this returns -1.
    ///
    /// - **Parameters:**
    ///   - `frames`: the audio-specific sample frames to convert to milliseconds.
    ///
    /// - **Returns:** Converted number of milliseconds, or -1 for errors/no input; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Audio.msToFrames
    pub inline fn framesToMs(self: @This(), frames: i64) i64 {
        return c.MIX_AudioFramesToMS(@ptrCast(self.value), frames);
    }

    /// Convert milliseconds to sample frames for a MIX_Audio's format.
    ///
    /// This calculates time based on the audio's initial format, even if the format would change mid-stream.
    /// If `ms` is < 0, this returns -1.
    ///
    /// - **Parameters:**
    ///   - `ms`: the milliseconds to convert to audio-specific sample frames.
    ///
    /// - **Returns:** Converted number of sample frames, or -1 for errors/no input; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Audio.framesToMs
    pub inline fn msToFrames(self: @This(), ms: i64) i64 {
        return c.MIX_AudioMSToFrames(@ptrCast(self.value), ms);
    }

    /// Get the length of a MIX_Audio's playback in sample frames.
    ///
    /// This information is also available via the prop_metadata_duration_frames_number property, but it's common enough to provide a simple accessor function.
    /// This reports the length of the data in *sample frames*, so sample-perfect mixing can be possible. Sample frames are only meaningful as a measure of time if the sample rate (frequency) is also known. To convert from sample frames to milliseconds, use Audio.framesToMs().
    /// Not all audio file formats can report the complete length of the data they will produce through decoding: some can't calculate it, some might produce infinite audio.
    /// Also, some file formats can only report duration as a unit of time, which means SDL_mixer might have to estimate sample frames from that information. With less precision, the reported duration might be off by a few sample frames in either direction.
    /// This will return a value >= 0 if a duration is known. It might also return duration_unknown or duration_infinite.
    ///
    /// - **Returns:** the length of the audio in sample frames, or duration_unknown or duration_infinite.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    pub inline fn getDuration(self: @This()) i64 {
        return c.MIX_GetAudioDuration(@ptrCast(self.value));
    }

    /// Query the initial audio format of a Audio.
    ///
    /// Note that some audio files can change format in the middle; some explicitly support this, but a more common example is two MP3 files concatenated together. In many cases, SDL_mixer will correctly handle these sort of files, but this function will only report the initial format a file uses.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getFormat(self: @This()) sdl.Error!root.GetAudioFormatResult {
        var spec_raw: @typeInfo(@typeInfo(@TypeOf(c.MIX_GetAudioFormat)).@"fn".params[1].type.?).pointer.child = undefined;
        if (!c.MIX_GetAudioFormat(@ptrCast(self.value), &spec_raw)) return error.SdlFailure;
        return root.GetAudioFormatResult{
            .spec = @bitCast(spec_raw),
        };
    }

    /// Get the properties associated with a Audio.
    ///
    /// SDL_mixer offers some properties of its own, but this can also be a convenient place to store app-specific data.
    /// A sdl.properties.Id is created the first time this function is called for a given Audio, if necessary.
    /// The following read-only properties are provided by SDL_mixer:
    /// - `prop_metadata_title_string`: the audio's title ("Smells Like Teen
    /// Spirit").
    /// - `prop_metadata_artist_string`: the audio's artist name ("Nirvana").
    /// - `prop_metadata_album_string`: the audio's album name ("Nevermind").
    /// - `prop_metadata_copy_right_string`: the audio's copyright info ("Copyright (c) 1991")
    /// - `prop_metadata_track_number`: the audio's track number on the album (1)
    /// - `prop_metadata_total_tracks_number`: the total tracks on the album (13)
    /// - `prop_metadata_year_number`: the year the audio was released (1991)
    /// - `prop_metadata_duration_frames_number`: The sample frames worth of PCM data that comprise this audio. It might be off by a little if the decoder only knows the duration as a unit of time.
    /// - `prop_metadata_duration_infinite_boolean`: if true, audio never runs out of sound to generate. This isn't necessarily always known to SDL_mixer, though.
    /// Other properties, documented with loadAudioWithProperties(), may also be present.
    /// Note that the metadata properties are whatever SDL_mixer finds in things like ID3 tags, and they often have very little standardized formatting, may be missing, and can be completely wrong if the original data is untrustworthy (like an MP3 from a P2P file sharing service).
    ///
    /// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getProperties(self: @This()) sdl.Error!sdl.properties.Id {
        const result = c.MIX_GetAudioProperties(@ptrCast(self.value));
        if (result == 0) return error.SdlFailure;
        return result;
    }
};

/// SDL handle `AudioDecoder`.
pub const AudioDecoder = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Destroy the specified audio decoder.
    ///
    /// Destroying a NULL AudioDecoder is a legal no-op.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// This method invalidates the handle after SDL_mixer consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.MIX_DestroyAudioDecoder(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Decode more audio from a AudioDecoder.
    ///
    /// Data is decoded on demand in whatever format is requested. The format is permitted to change between calls.
    /// This function will return the number of bytes decoded, which may be less than requested if there was an error or end-of-file. A return value of zero means the entire file was decoded, -1 means an unrecoverable error happened.
    ///
    /// - **Parameters:**
    ///   - `buffer`: the memory buffer to store decoded audio.
    ///   - `spec`: the format that audio data will be stored to `buffer`.
    ///
    /// - **Returns:** number of bytes decoded, or -1 on error; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn decode(self: @This(), buffer: []u8, spec: ?*const sdl.audio.Spec) sdl.Error!c_int {
        const result = c.MIX_DecodeAudio(@ptrCast(self.value), @ptrCast(buffer.ptr), @intCast(buffer.len), @ptrCast(spec));
        if (result < 0) return error.SdlFailure;
        return result;
    }

    /// Query the initial audio format of a AudioDecoder.
    ///
    /// Note that some audio files can change format in the middle; some explicitly support this, but a more common example is two MP3 files concatenated together. In many cases, SDL_mixer will correctly handle these sort of files, but this function will only report the initial format a file uses.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getFormat(self: @This()) sdl.Error!root.GetAudioDecoderFormatResult {
        var spec_raw: @typeInfo(@typeInfo(@TypeOf(c.MIX_GetAudioDecoderFormat)).@"fn".params[1].type.?).pointer.child = undefined;
        if (!c.MIX_GetAudioDecoderFormat(@ptrCast(self.value), &spec_raw)) return error.SdlFailure;
        return root.GetAudioDecoderFormatResult{
            .spec = @bitCast(spec_raw),
        };
    }

    /// Get the properties associated with a AudioDecoder.
    ///
    /// SDL_mixer offers some properties of its own, but this can also be a convenient place to store app-specific data.
    /// A sdl.properties.Id is created the first time this function is called for a given AudioDecoder, if necessary.
    /// The file-specific metadata exposed through this function is identical to those available through Audio.getProperties(). Please refer to that function's documentation for details.
    ///
    /// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Audio.getProperties
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getProperties(self: @This()) sdl.Error!sdl.properties.Id {
        const result = c.MIX_GetAudioDecoderProperties(@ptrCast(self.value));
        if (result == 0) return error.SdlFailure;
        return result;
    }
};

/// SDL handle `Group`.
pub const Group = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Destroy a mixing group.
    ///
    /// Any tracks currently assigned to this group will be reassigned to the mixer's internal default group.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** createGroup
    /// This method invalidates the handle after SDL_mixer consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.MIX_DestroyGroup(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Get the Mixer that owns a Group.
    ///
    /// This is the mixer pointer that was passed to createGroup().
    ///
    /// - **Returns:** the mixer associated with the group, or NULL on error; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    pub inline fn getMixer(self: @This()) ?Mixer {
        const result = c.MIX_GetGroupMixer(@ptrCast(self.value));
        return if (result) |value| Mixer{ .value = @ptrCast(value) } else null;
    }

    /// Get the properties associated with a group.
    ///
    /// Currently SDL_mixer assigns no properties of its own to a group, but this can be a convenient place to store app-specific data.
    /// A sdl.properties.Id is created the first time this function is called for a given group.
    ///
    /// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getProperties(self: @This()) sdl.Error!sdl.properties.Id {
        const result = c.MIX_GetGroupProperties(@ptrCast(self.value));
        if (result == 0) return error.SdlFailure;
        return result;
    }

    /// Set a callback that fires when a mixer group has completed mixing.
    ///
    /// After all playing tracks in a mixer group have pulled in more data from their inputs, transformed it, and mixed together into a single buffer, a callback can be fired. This lets an app view the data at the last moment that it is still a part of this group. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data came directly from the group's mix buffer.
    /// Each group has its own unique callback. Tracks that aren't in an explicit Group are mixed in an internal grouping that is not available to the app.
    /// Passing a NULL callback here is legal; it disables this group's callback.
    ///
    /// - **Parameters:**
    ///   - `cb`: the function to call when the group mixes. May be NULL.
    ///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** GroupMixCallback
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setPostMixCallback(self: @This(), cb: GroupMixCallback, userdata: ?*anyopaque) sdl.Error!void {
        if (!c.MIX_SetGroupPostMixCallback(@ptrCast(self.value), @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
    }
};

/// SDL handle `Mixer`.
pub const Mixer = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Free a mixer.
    ///
    /// If this mixer was created with createMixerDevice(), this function will also close the audio device and call sdl.init.quitSubSystem(sdl.init.Flags.audio).
    /// Any Group or Track created for this mixer will also be destroyed. Do not access them again or attempt to destroy them after the device is destroyed. Audio objects will not be destroyed, since they can be shared between mixers (but those will all be destroyed during quit()).
    ///
    /// - **Thread safety:** If this is used with a Mixer from createMixerDevice, then this function should only be called on the main thread. If this is used with a Mixer from createMixer, then it is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** createMixerDevice
    /// - **See also:** createMixer
    /// This method invalidates the handle after SDL_mixer consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.MIX_DestroyMixer(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Generate mixer output when not driving an audio device.
    ///
    /// SDL_mixer allows the creation of Mixer objects that are not connected to an audio device, by calling createMixer() instead of createMixerDevice(). Such mixers will not generate output until explicitly requested through this function.
    /// The caller may request as much audio as desired, so long as `buflen` is a multiple of the sample frame size specified when creating the mixer (for example, if requesting stereo Sint16 audio, buflen must be a multiple of 4: 2 bytes-per-channel times 2 channels).
    /// The mixer will mix as quickly as possible; since it works in sample frames instead of time, it can potentially generate enormous amounts of audio in a small amount of time.
    /// On success, this always fills `buffer` with `buflen` bytes of audio; if all playing tracks finish mixing, it will fill the remaining buffer with silence.
    /// Each call to this function will pick up where it left off, playing tracks will continue to mix from the point the previous call completed, etc. The mixer state can be changed between each call in any way desired: tracks can be added, played, stopped, changed, removed, etc. Effectively this function does the same thing SDL_mixer does internally when the audio device needs more audio to play.
    /// This function can not be used with mixers from createMixerDevice(); those generate audio as needed internally.
    /// This function returns the number of *bytes* of real audio mixed, which might be less than `buflen`. While all `buflen` bytes of `buffer` will be initialized, if available tracks to mix run out, the end of the buffer will be initialized with silence; this silence will not be counted in the return value, so the caller has the option to identify how much of the buffer has legimitate contents vs appended silence. As such, any value >= 0 signifies success. A return value of -1 means failure (out of memory, invalid parameters, etc).
    ///
    /// - **Parameters:**
    ///   - `buffer`: a pointer to a buffer to store audio in.
    ///
    /// - **Returns:** The number of bytes of mixed audio, discounting appended silence, on success, or -1 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** createMixer
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn generate(self: @This(), buffer: []u8) sdl.Error!c_int {
        const result = c.MIX_Generate(@ptrCast(self.value), @ptrCast(buffer.ptr), @intCast(buffer.len));
        if (result < 0) return error.SdlFailure;
        return result;
    }

    /// Get the audio format a mixer is generating.
    ///
    /// Generally you don't need this information, as SDL_mixer will convert data as necessary between inputs you provide and its output format, but it might be useful if trying to match your inputs to reduce conversion and resampling costs.
    /// For mixers created with createMixerDevice(), this is the format of the audio device (and may change later if the device itself changes; SDL_mixer will seamlessly handle this change internally, though).
    /// For mixers created with createMixer(), this is the format that Mixer.generate() will produce, as requested at create time, and does not change.
    /// Note that internally, SDL_mixer will work in sdl.audio.Format.f32_ format before outputting the format specified here, so it would be more efficient to match input data to that, not the final output format.
    ///
    /// - **Parameters:**
    ///   - `spec`: where to store the mixer audio format.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getFormat(self: @This(), spec: ?*sdl.audio.Spec) sdl.Error!void {
        if (!c.MIX_GetMixerFormat(@ptrCast(self.value), @ptrCast(spec))) return error.SdlFailure;
    }

    /// Get a mixer's master frequency ratio.
    ///
    /// This returns the last value set through Mixer.setFrequencyRatio(), or 1.0f if no value has ever been explicitly set.
    ///
    /// - **Returns:** the mixer's current master frequency ratio.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.setFrequencyRatio
    /// - **See also:** Track.getFrequencyRatio
    pub inline fn getFrequencyRatio(self: @This()) f32 {
        return c.MIX_GetMixerFrequencyRatio(@ptrCast(self.value));
    }

    /// Get a mixer's master gain control.
    ///
    /// This returns the last value set through Mixer.setGain(), or 1.0f if no value has ever been explicitly set.
    ///
    /// - **Returns:** the mixer's current master gain.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.setGain
    /// - **See also:** Track.getGain
    pub inline fn getGain(self: @This()) f32 {
        return c.MIX_GetMixerGain(@ptrCast(self.value));
    }

    /// Get the properties associated with a mixer.
    ///
    /// The following read-only properties are provided by SDL_mixer:
    /// - `prop_mixer_device_number`: the sdl.audio.DeviceId that this mixer has opened for playback. This will be zero (no device) if the mixer was created with Mix_CreateMixer() instead of Mix_CreateMixerDevice().
    ///
    /// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getProperties(self: @This()) sdl.Error!sdl.properties.Id {
        const result = c.MIX_GetMixerProperties(@ptrCast(self.value));
        if (result == 0) return error.SdlFailure;
        return result;
    }

    /// Lock a mixer by obtaining its internal mutex.
    ///
    /// While locked, the mixer will not be able to mix more audio or change its internal state in another thread. Those other threads will block until the mixer is unlocked again.
    /// Under the hood, this function calls sdl.mutex.Mutex.lock(), so all the same rules apply: the lock can be recursive, it must be unlocked the same number of times from the same thread that locked it, etc.
    /// Just about every SDL_mixer API *also* locks the mixer while doing its work, as does the SDL audio device thread while actual mixing is in progress, so basic use of this library never requires the app to explicitly lock the device to be thread safe. There are two scenarios where this can be useful, however:
    /// - The app has a provided a callback that the mixing thread might call, and there is some app state that needs to be protected against race conditions as changes are made and mixing progresses simultaneously. Any lock can be used for this, but this is a conveniently-available lock.
    /// - The app wants to make multiple, atomic changes to the mix. For example, to start several tracks at the exact same moment, one would lock the mixer, call Track.play multiple times, and then unlock again; all the tracks will start mixing on the same sample frame.
    /// Each call to this function must be paired with a call to Mixer.unlock from the same thread. It is safe to lock a mixer multiple times; it remains locked until the final matching unlock call.
    /// Do not lock the mixer for significant amounts of time, or it can cause audio dropouts. Just do simple things quickly and unlock again.
    /// Locking a NULL mixer is a safe no-op.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.unlock
    pub inline fn lock(self: @This()) void {
        c.MIX_LockMixer(@ptrCast(self.value));
    }

    /// Pause all currently-playing tracks.
    ///
    /// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
    /// This function makes all tracks on the specified mixer that are currently playing move to a paused state. They can later be resumed.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.resume_
    /// - **See also:** Mixer.resumeAllTracks
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn pauseAllTracks(self: @This()) sdl.Error!void {
        if (!c.MIX_PauseAllTracks(@ptrCast(self.value))) return error.SdlFailure;
    }

    /// Pause all tracks with a specific tag.
    ///
    /// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
    /// This function makes all currently-playing tracks on the specified mixer, with a specific tag, move to a paused state. They can later be resumed.
    /// Tracks that match the specified tag that aren't currently playing are ignored.
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to use when searching for tracks.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.pause
    /// - **See also:** Track.resume_
    /// - **See also:** Mixer.resumeTag
    /// - **See also:** Track.tag
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn pauseTag(self: @This(), tag: ?[:0]const u8) sdl.Error!void {
        if (!c.MIX_PauseTag(@ptrCast(self.value), if (tag != null) @ptrCast(tag.?.ptr) else null)) return error.SdlFailure;
    }

    /// Play a Audio from start to finish without any management.
    ///
    /// This is what we term a "fire-and-forget" sound. Internally, SDL_mixer will manage a temporary track to mix the specified Audio, cleaning it up when complete. No options can be provided for how to do the mixing, like Track.play() offers, and since the track is not available to the caller, no adjustments can be made to mixing over time.
    /// This is not the function to build an entire game of any complexity around, but it can be convenient to play simple, one-off sounds that can't be stopped early. An example would be a voice saying "GAME OVER" during an unpausable endgame sequence.
    /// There are no limits to the number of fire-and-forget sounds that can mix at once (short of running out of memory), and SDL_mixer keeps an internal pool of temporary tracks it creates as needed and reuses when available.
    ///
    /// - **Parameters:**
    ///   - `audio`: the audio input to play.
    ///
    /// - **Returns:** true if the track has begun mixing, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.play
    /// - **See also:** loadAudio
    pub inline fn playAudio(self: @This(), audio: ?Audio) bool {
        return c.MIX_PlayAudio(@ptrCast(self.value), if (audio) |resource| @ptrCast(resource.value) else null);
    }

    /// Start (or restart) mixing all tracks with a specific tag for playback.
    ///
    /// This function follows all the same rules as Track.play(); please refer to its documentation for the details. Unlike that function, Mixer.playTag() operates on multiple tracks at once that have the specified tag applied, via Track.tag().
    /// If all of your tagged tracks have different sample rates, it would make sense to use the `*_MILLISECONDS_NUMBER` properties in your `options`, instead of `*_FRAMES_NUMBER`, and let SDL_mixer figure out how to apply it to each track.
    /// This function returns true if all tagged tracks are started (or restarted). If any track fails, this function returns false, but all tracks that could start will still be started even when this function reports failure.
    /// From the point of view of the mixing process, all tracks that successfully (re)start will do so at the exact same moment.
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to use when searching for tracks.
    ///   - `options`: the set of options that will be applied to each track.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.play
    /// - **See also:** Track.tag
    /// - **See also:** Track.stop
    /// - **See also:** Track.pause
    /// - **See also:** Track.playing
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn playTag(self: @This(), tag: ?[:0]const u8, options: sdl.properties.Id) sdl.Error!void {
        if (!c.MIX_PlayTag(@ptrCast(self.value), if (tag != null) @ptrCast(tag.?.ptr) else null, options)) return error.SdlFailure;
    }

    /// Resume all currently-paused tracks.
    ///
    /// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
    /// This function makes all tracks on the specified mixer that are currently paused move to a playing state.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.pause
    /// - **See also:** Mixer.pauseAllTracks
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn resumeAllTracks(self: @This()) sdl.Error!void {
        if (!c.MIX_ResumeAllTracks(@ptrCast(self.value))) return error.SdlFailure;
    }

    /// Resume all tracks with a specific tag.
    ///
    /// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
    /// This function makes all currently-paused tracks on the specified mixer, with a specific tag, move to a playing state.
    /// Tracks that match the specified tag that aren't currently paused are ignored.
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to use when searching for tracks.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.resume_
    /// - **See also:** Track.pause
    /// - **See also:** Mixer.pauseTag
    /// - **See also:** Track.tag
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn resumeTag(self: @This(), tag: ?[:0]const u8) sdl.Error!void {
        if (!c.MIX_ResumeTag(@ptrCast(self.value), if (tag != null) @ptrCast(tag.?.ptr) else null)) return error.SdlFailure;
    }

    /// Set a mixer's master frequency ratio.
    ///
    /// Each mixer has a master frequency ratio, that affects the entire mix. This can cause the final output to change speed and pitch. A value greater than 1.0f will play the audio faster, and at a higher pitch. A value less than 1.0f will play the audio slower, and at a lower pitch. 1.0f is normal speed.
    /// Each track *also* has a frequency ratio; it will be applied when mixing that track's audio regardless of the master setting. The master setting affects the final output after all mixing has been completed.
    /// A mixer's master frequency ratio defaults to 1.0f.
    /// This value can be changed at any time to adjust the future mix.
    ///
    /// - **Parameters:**
    ///   - `ratio`: the frequency ratio. Must be between 0.01f and 100.0f.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.getFrequencyRatio
    /// - **See also:** Track.setFrequencyRatio
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setFrequencyRatio(self: @This(), ratio: f32) sdl.Error!void {
        if (!c.MIX_SetMixerFrequencyRatio(@ptrCast(self.value), ratio)) return error.SdlFailure;
    }

    /// Set a mixer's master gain control.
    ///
    /// Each mixer has a master gain, to adjust the volume of the entire mix. Each sample passing through the pipeline is modulated by this gain value. A gain of zero will generate silence, 1.0f will not change the mixed volume, and larger than 1.0f will increase the volume. Negative values are illegal. There is no maximum gain specified, but this can quickly get extremely loud, so please be careful with this setting.
    /// A mixer's master gain defaults to 1.0f.
    /// This value can be changed at any time to adjust the future mix.
    ///
    /// - **Parameters:**
    ///   - `gain`: the new gain value.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.getGain
    /// - **See also:** Track.setGain
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setGain(self: @This(), gain: f32) sdl.Error!void {
        if (!c.MIX_SetMixerGain(@ptrCast(self.value), gain)) return error.SdlFailure;
    }

    /// Set a callback that fires when all mixing has completed.
    ///
    /// After all mixer groups have processed, their buffers are mixed together into a single buffer for the final output, at which point a callback can be fired. This lets an app view the data at the last moment before mixing completes. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data is the final output.
    /// Each mixer has its own unique callback.
    /// Passing a NULL callback here is legal; it disables this mixer's callback.
    ///
    /// - **Parameters:**
    ///   - `cb`: the function to call when the mixer mixes. May be NULL.
    ///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** PostMixCallback
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setPostMixCallback(self: @This(), cb: PostMixCallback, userdata: ?*anyopaque) sdl.Error!void {
        if (!c.MIX_SetPostMixCallback(@ptrCast(self.value), @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
    }

    /// Set the gain control of all tracks with a specific tag.
    ///
    /// Each track has its own gain, to adjust its overall volume. Each sample from this track is modulated by this gain value. A gain of zero will generate silence, 1.0f will not change the mixed volume, and larger than 1.0f will increase the volume. Negative values are illegal. There is no maximum gain specified, but this can quickly get extremely loud, so please be careful with this setting.
    /// A track's gain defaults to 1.0f.
    /// This will change the gain control on tracks on the specified mixer that have the specified tag.
    /// From the point of view of the mixing process, all tracks that successfully change gain values will do so at the exact same moment.
    /// This value can be changed at any time to adjust the future mix.
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to use when searching for tracks.
    ///   - `gain`: the new gain value.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getGain
    /// - **See also:** Track.setGain
    /// - **See also:** Mixer.setGain
    /// - **See also:** Track.tag
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setTagGain(self: @This(), tag: ?[:0]const u8, gain: f32) sdl.Error!void {
        if (!c.MIX_SetTagGain(@ptrCast(self.value), if (tag != null) @ptrCast(tag.?.ptr) else null, gain)) return error.SdlFailure;
    }

    /// Halt all currently-playing tracks, possibly fading out over time.
    ///
    /// If `fade_out_ms` is > 0, the tracks do not stop mixing immediately, but rather fades to silence over that many milliseconds before stopping. Note that this is different than Track.stop(), which wants sample frames; this function takes milliseconds because different tracks might have different sample rates.
    /// If a track ends normally while the fade-out is still in progress, the audio stops there; the fade is not adjusted to be shorter if it will last longer than the audio remaining.
    /// Once a track has completed any fadeout and come to a stop, it will call its TrackStoppedCallback, if any. It is legal to assign the track a new input and/or restart it during this callback.
    /// This function does not prevent new play requests from being made; it’s legal to use this function to begin fading all playing tracks but then start other tracks playing normally while those fade-outs are still in progress.
    ///
    /// - **Parameters:**
    ///   - `fade_out_ms`: the number of milliseconds to spend fading out to silence before halting. 0 to stop immediately.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.stop
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn stopAllTracks(self: @This(), fade_out_ms: i64) sdl.Error!void {
        if (!c.MIX_StopAllTracks(@ptrCast(self.value), fade_out_ms)) return error.SdlFailure;
    }

    /// Halt all tracks with a specific tag, possibly fading out over time.
    ///
    /// If `fade_out_ms` is > 0, the tracks do not stop mixing immediately, but rather fades to silence over that many milliseconds before stopping. Note that this is different than Track.stop(), which wants sample frames; this function takes milliseconds because different tracks might have different sample rates.
    /// If a track ends normally while the fade-out is still in progress, the audio stops there; the fade is not adjusted to be shorter if it will last longer than the audio remaining.
    /// Once a track has completed any fadeout and come to a stop, it will call its TrackStoppedCallback, if any. It is legal to assign the track a new input and/or restart it during this callback. This function does not prevent new play requests from being made.
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to use when searching for tracks.
    ///   - `fade_out_ms`: the number of milliseconds to spend fading out to silence before halting. 0 to stop immediately.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.stop
    /// - **See also:** Track.tag
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn stopTag(self: @This(), tag: ?[:0]const u8, fade_out_ms: i64) sdl.Error!void {
        if (!c.MIX_StopTag(@ptrCast(self.value), if (tag != null) @ptrCast(tag.?.ptr) else null, fade_out_ms)) return error.SdlFailure;
    }

    /// Unlock a mixer previously locked by a call to Mixer.lock().
    ///
    /// While locked, the mixer will not be able to mix more audio or change its internal state another thread. Those other threads will block until the mixer is unlocked again.
    /// Under the hood, this function calls sdl.mutex.Mutex.lock(), so all the same rules apply: the lock can be recursive, it must be unlocked the same number of times from the same thread that locked it, etc.
    /// Unlocking a NULL mixer is a safe no-op.
    ///
    /// - **Thread safety:** This call must be paired with a previous Mixer.lock call on the same thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.lock
    pub inline fn unlock(self: @This()) void {
        c.MIX_UnlockMixer(@ptrCast(self.value));
    }
};

/// 3D coordinates for Track.setTrack3dPosition.
///
/// The coordinates use a "right-handed" coordinate system, like OpenGL and OpenAL.
///
/// - **Since:** This struct is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setTrack3dPosition
pub const Point3d = extern struct {
    /// Field `x`.
    x: f32,
    /// Field `y`.
    y: f32,
    /// Field `z`.
    z: f32,
};

/// A set of per-channel gains for tracks using Track.setStereo().
///
/// When forcing a track to stereo, the app can specify a per-channel gain, to further adjust the left or right outputs.
/// When mixing audio that has been forced to stereo, each channel is modulated by these values. A value of 1.0f produces no change, 0.0f produces silence.
/// A simple panning effect would be to set `left` to the desired value and `right` to `1.0f - left`.
///
/// - **Since:** This struct is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setStereo
pub const StereoGains = extern struct {
    /// Field `left`.
    left: f32,
    /// Field `right`.
    right: f32,
};

/// SDL handle `Track`.
pub const Track = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Destroy the specified track.
    ///
    /// If the track is currently playing, it will be stopped immediately, without any fadeout. If there is a callback set through Track.setStoppedCallback(), it will *not* be called.
    /// If the mixer is currently mixing in another thread, this will block until it finishes. Destroying a track from the mixer thread itself (during a callback) will cause it to be destroyed as soon as this iteration of the mixer thread is not using it; in this scenario, destroying a track and then making futher changes to it is considered undefined behavior.
    /// Destroying a NULL Track is a legal no-op.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// This method invalidates the handle after SDL_mixer consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.MIX_DestroyTrack(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Get a track's current position in 3D space.
    ///
    /// If 3D positioning isn't enabled for this track, through a call to Track.setTrack3dPosition(), this will return (0,0,0).
    ///
    /// - **Parameters:**
    ///   - `position`: on successful return, will contain the track's position.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.setTrack3dPosition
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getTrack3dPosition(self: @This(), position: ?*Point3d) sdl.Error!void {
        if (!c.MIX_GetTrack3DPosition(@ptrCast(self.value), @ptrCast(position))) return error.SdlFailure;
    }

    /// Query the Audio assigned to a track.
    ///
    /// This returns the Audio object currently assigned to `track` through a call to Track.setAudio(). If there is none assigned, or the track has an input that isn't a Audio (such as an sdl.audio.Stream or sdl.ioStream.IoStream), this will return NULL.
    /// On various errors (init() was not called, the track is NULL), this returns NULL, but there is no mechanism to distinguish errors from tracks without a valid input.
    ///
    /// - **Returns:** a Audio if available, NULL if not.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getAudioStream
    pub inline fn getAudio(self: @This()) ?Audio {
        const result = c.MIX_GetTrackAudio(@ptrCast(self.value));
        return if (result) |value| Audio{ .value = @ptrCast(value) } else null;
    }

    /// Query the sdl.audio.Stream assigned to a track.
    ///
    /// This returns the sdl.audio.Stream object currently assigned to `track` through a call to Track.setAudioStream(). If there is none assigned, or the track has an input that isn't an sdl.audio.Stream (such as a Audio or sdl.ioStream.IoStream), this will return NULL.
    /// On various errors (init() was not called, the track is NULL), this returns NULL, but there is no mechanism to distinguish errors from tracks without a valid input.
    ///
    /// - **Returns:** an sdl.audio.Stream if available, NULL if not.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getAudio
    pub inline fn getAudioStream(self: @This()) ?*sdl.audio.Stream {
        const result = c.MIX_GetTrackAudioStream(@ptrCast(self.value));
        return if (result == null) null else @ptrCast(result);
    }

    /// Query whether a given track is fading.
    ///
    /// This specifically checks if the track is *not stopped* (paused or playing), and it is fading in or out, and returns the number of frames remaining in the fade.
    /// If fading out, the returned value will be negative. When fading in, the returned value will be positive. If not fading, this function returns zero.
    /// On various errors (init() was not called, the track is NULL), this returns 0, but there is no mechanism to distinguish errors from tracks that aren't fading.
    ///
    /// - **Returns:** less than 0 if the track is fading out, greater than 0 if fading in, zero otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    pub inline fn getFadeFrames(self: @This()) i64 {
        return c.MIX_GetTrackFadeFrames(@ptrCast(self.value));
    }

    /// Query the frequency ratio of a track.
    ///
    /// The frequency ratio is used to adjust the rate at which audio data is consumed. Changing this effectively modifies the speed and pitch of the track's audio. A value greater than 1.0f will play the audio faster, and at a higher pitch. A value less than 1.0f will play the audio slower, and at a lower pitch. 1.0f is normal speed.
    /// The default value is 1.0f.
    /// On various errors (init() was not called, the track is NULL), this returns 0.0f. Since this is not a valid value to set, this can be seen as an error state.
    ///
    /// - **Returns:** the current frequency ratio, or 0.0f on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getFrequencyRatio
    pub inline fn getFrequencyRatio(self: @This()) f32 {
        return c.MIX_GetTrackFrequencyRatio(@ptrCast(self.value));
    }

    /// Get a track's gain control.
    ///
    /// This returns the last value set through Track.setGain(), or 1.0f if no value has ever been explicitly set.
    ///
    /// - **Returns:** the track's current gain.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.setGain
    /// - **See also:** Mixer.getGain
    pub inline fn getGain(self: @This()) f32 {
        return c.MIX_GetTrackGain(@ptrCast(self.value));
    }

    /// Query how many loops remain for a given track.
    ///
    /// This returns the number of loops still pending; if a track will eventually complete and loop to play again one more time, this will return 1. If a track *was* looping but is on its final iteration of the loop (will stop when this iteration completes), this will return zero.
    /// A track that is looping infinitely will return -1. This value does not report an error in this case.
    /// A track that is stopped (not playing and not paused) will have zero loops remaining.
    /// On various errors (init() was not called, the track is NULL), this returns zero, but there is no mechanism to distinguish errors from non-looping tracks.
    ///
    /// - **Returns:** the number of pending loops, zero if not looping, and -1 if looping infinitely.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    pub inline fn getLoops(self: @This()) c_int {
        return c.MIX_GetTrackLoops(@ptrCast(self.value));
    }

    /// Get the Mixer that owns a Track.
    ///
    /// This is the mixer pointer that was passed to createTrack().
    ///
    /// - **Returns:** the mixer associated with the track, or NULL on error; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    pub inline fn getMixer(self: @This()) ?Mixer {
        const result = c.MIX_GetTrackMixer(@ptrCast(self.value));
        return if (result) |value| Mixer{ .value = @ptrCast(value) } else null;
    }

    /// Get the current input position of a playing track.
    ///
    /// (Not to be confused with Track.getTrack3dPosition(), which is positioning of the track in 3D space, not the playback position of its audio data.)
    /// Position is defined in *sample frames* of decoded audio, not units of time, so that sample-perfect mixing can be achieved. To instead operate in units of time, use Track.framesToMs() to convert the return value to milliseconds.
    /// Stopped and paused tracks will report the position when they halted. Playing tracks will report the current position, which will change over time.
    ///
    /// - **Returns:** the track's current sample frame position, or -1 on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.setPlaybackPosition
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getPlaybackPosition(self: @This()) sdl.Error!i64 {
        const result = c.MIX_GetTrackPlaybackPosition(@ptrCast(self.value));
        if (result < 0) return error.SdlFailure;
        return result;
    }

    /// Get the properties associated with a track.
    ///
    /// Currently SDL_mixer assigns no properties of its own to a track, but this can be a convenient place to store app-specific data.
    /// A sdl.properties.Id is created the first time this function is called for a given track.
    ///
    /// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn getProperties(self: @This()) sdl.Error!sdl.properties.Id {
        const result = c.MIX_GetTrackProperties(@ptrCast(self.value));
        if (result == 0) return error.SdlFailure;
        return result;
    }

    /// Return the number of sample frames remaining to be mixed in a track.
    ///
    /// If the track is playing or paused, and its total duration is known, this will report how much audio is left to mix. If the track is playing, future calls to this function will report different values.
    /// Remaining audio is defined in *sample frames* of decoded audio, not units of time, so that sample-perfect mixing can be achieved. To instead operate in units of time, use Track.framesToMs() to convert the return value to milliseconds.
    /// This function does not take into account fade-outs or looping, just the current mixing position vs the duration of the track.
    /// If the duration of the track isn't known, or `track` is NULL, this function returns -1. A stopped track reports 0.
    ///
    /// - **Returns:** the total sample frames still to be mixed, or -1 if unknown.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    pub inline fn getRemaining(self: @This()) i64 {
        return c.MIX_GetTrackRemaining(@ptrCast(self.value));
    }

    /// Pause a currently-playing track.
    ///
    /// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
    /// It is legal to pause a track that's in any state (playing, already paused, or stopped). Unless the track is currently playing, pausing does nothing, and returns true. A false return is only used to signal errors here (such as init not being called or `track` being NULL).
    ///
    /// - **Returns:** true if the track has paused, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.resume_
    pub inline fn pause(self: @This()) bool {
        return c.MIX_PauseTrack(@ptrCast(self.value));
    }

    /// Start (or restart) mixing a track for playback.
    ///
    /// The track will use whatever input was last assigned to it when playing; an input must be assigned to this track or this function will fail. Inputs are assigned with calls to Track.setAudio(), Track.setAudioStream(), or Track.setIoStream().
    /// If the track is already playing, or paused, this will restart the track with the newly-specified parameters.
    /// As there are several parameters, and more may be added in the future, they are specified with an sdl.properties.Id. The parameters have reasonable defaults, and specifying a 0 for `options` will choose defaults for everything.
    /// sdl.properties.Id are discussed in [SDL's documentation](https://wiki.libsdl.org/SDL3/CategoryProperties) These are the supported properties:
    /// - `prop_play_loops_number`: The number of times to loop the track when it reaches the end. A value of 1 will loop to the start one time. Zero will not loop at all. A value of -1 requests infinite loops. If the input is not seekable and this value isn't zero, this function will report success but the track will stop at the point it should loop. Default 0.
    /// - `prop_play_max_frame_number`: Mix at most to this sample frame position in the track. This will be treated as if the input reach EOF at this point in the audio file. If -1, mix all available audio without a limit. Default -1.
    /// - `prop_play_max_milliseconds_number`: The same as using the prop_play_max_frame_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default -1.
    /// - `prop_play_start_frame_number`: Start mixing from this sample frame position in the track's input. A value <= 0 will begin from the start of the track's input. If the input is not seekable and this value is > 0, this function will report failure. Default 0.
    /// - `prop_play_start_millisecond_number`: The same as using the prop_play_start_frame_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
    /// - `prop_play_loop_start_frame_number`: If the track is looping, this is the sample frame position that the track will loop back to; this lets one play an intro at the start of a track on the first iteration, but have a loop point somewhere in the middle thereafter. A value <= 0 will begin the loop from the start of the track's input. Default 0.
    /// - `prop_play_loop_start_millisecond_number`: The same as using the prop_play_loop_start_frame_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
    /// - `prop_play_fade_in_frames_number`: The number of sample frames over which to fade in the newly-started track. The track will begin mixing silence and reach full volume smoothly over this many sample frames. If the track loops before the fade-in is complete, it will continue to fade correctly from the loop point. A value <= 0 will disable fade-in, so the track starts mixing at full volume. Default 0.
    /// - `prop_play_fade_in_milliseconds_number`: The same as using the prop_play_fade_in_frames_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
    /// - `prop_play_fade_in_start_gain_float`: If fading in, start fading from this volume level. 0.0f is silence and 1.0f is full volume, every in between is a linear change in gain. The specified value will be clamped between 0.0f and 1.0f. Default 0.0f.
    /// - `prop_play_app_end_silence_frames_number`: At the end of mixing this track, after all loops are complete, append this many sample frames of silence as if it were part of the audio file. This allows for apps to implement effects in callbacks, like reverb, that need to generate samples past the end of the stream's audio, or perhaps introduce a delay before starting a new sound on the track without having to manage it directly. A value <= 0 generates no silence before stopping the track. Default 0.
    /// - `prop_play_app_end_silence_milliseconds_number`: The same as using the prop_play_app_end_silence_frames_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
    /// - `prop_play_halt_when_exhausted_boolean`: If true, when input is completely consumed for the track, the mixer will mark the track as stopped (and call any appropriate TrackStoppedCallback, etc); to play more, the track will need to be restarted. If false, the track will just not contribute to the mix, but it will not be marked as stopped. There may be clever logic tricks this exposes generally, but this property is specifically useful when the track's input is an sdl.audio.Stream assigned via Track.setAudioStream(). Setting this property to true can be useful when pushing a complete piece of audio to the stream that has a definite ending, as the track will operate like any other audio was applied. Setting to false means as new data is added to the stream, the mixer will start using it as soon as possible, which is useful when audio should play immediately as it drips in: new VoIP packets, etc. Note that in this situation, if the audio runs out when needed, there *will* be gaps in the mixed output, so try to buffer enough data to avoid this when possible. Note that a track is not consider exhausted until all its loops and appended silence have been mixed (and also, that loops don't mean anything when the input is an AudioStream). Default true.
    /// - `prop_play_start_order_number`: This is a special-case property that most apps can ignore. For mod file formats, start mixing from a specific "order" index instead of the start of the file. A value < 0 will cause this property to be ignored. If the decoder doesn't support this property, it will also be ignored. If this property is *not* ignored, the prop_play_start_frame_number and prop_play_start_millisecond_number properties will be ignored instead. Default -1. Since SDL_mixer 3.2.2.
    /// If this function fails, mixing of this track will not start (or restart, if it was already started).
    ///
    /// - **Parameters:**
    ///   - `options`: a set of properties that control playback. May be zero.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Mixer.playTag
    /// - **See also:** Mixer.playAudio
    /// - **See also:** Track.stop
    /// - **See also:** Track.pause
    /// - **See also:** Track.playing
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn play(self: @This(), options: sdl.properties.Id) sdl.Error!void {
        if (!c.MIX_PlayTrack(@ptrCast(self.value), options)) return error.SdlFailure;
    }

    /// Resume a currently-paused track.
    ///
    /// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
    /// It is legal to resume a track that's in any state (playing, paused, or stopped). Unless the track is currently paused, resuming does nothing, and returns true. A false return is only used to signal errors here (such as init not being called or `track` being NULL).
    ///
    /// - **Returns:** true if the track has resumed, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.pause
    pub inline fn resume_(self: @This()) bool {
        return c.MIX_ResumeTrack(@ptrCast(self.value));
    }

    /// Set a track's position in 3D space.
    ///
    /// (Please note that SDL_mixer is not intended to be a extremely powerful 3D API. It lacks 3D features that other APIs like OpenAL offer: there's no doppler effect, distance models, rolloff, etc. This is meant to be Good Enough for games that can use some positional sounds and can even take advantage of surround-sound configurations.)
    /// If `position` is not NULL, this track will be switched into 3D positional mode. If `position` is NULL, this will disable positional mixing (both the full 3D spatialization of this function and forced-stereo mode of Track.setStereo()).
    /// In 3D positional mode, SDL_mixer will mix this track as if it were positioned in 3D space, including distance attenuation (quieter as it gets further from the listener) and spatialization (positioned on the correct speakers to suggest direction, either with stereo outputs or full surround sound).
    /// For a mono speaker output, spatialization is effectively disabled but distance attenuation will still work, which is all you can really do with a single speaker.
    /// The coordinate system operates like OpenGL or OpenAL: a "right-handed" coordinate system. See Point3d for the details.
    /// The listener is always at coordinate (0,0,0) and can't be changed.
    /// The track's input will be converted to mono (1 channel) so it can be rendered across the correct speakers.
    ///
    /// - **Parameters:**
    ///   - `position`: the new 3D position for the track. May be NULL.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getTrack3dPosition
    /// - **See also:** Track.setStereo
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setTrack3dPosition(self: @This(), position: ?*const Point3d) sdl.Error!void {
        if (!c.MIX_SetTrack3DPosition(@ptrCast(self.value), @ptrCast(position))) return error.SdlFailure;
    }

    /// Set a MIX_Track's input to a Audio.
    ///
    /// A Audio is audio data stored in RAM (possibly still in a compressed form). One Audio can be assigned to multiple tracks at once.
    /// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
    /// Calling this function with a NULL audio input is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
    /// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
    /// The track will hold a reference to the provided Audio, so it is safe to call Audio.deinit() on it while the track is still using it. The track will drop its reference (and possibly free the resources) once it is no longer using the Audio.
    ///
    /// - **Parameters:**
    ///   - `audio`: the new audio input to set. May be NULL.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setAudio(self: @This(), audio: ?Audio) sdl.Error!void {
        if (!c.MIX_SetTrackAudio(@ptrCast(self.value), if (audio) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
    }

    /// Set a MIX_Track's input to an sdl.audio.Stream.
    ///
    /// Using an audio stream allows the application to generate any type of audio, in any format, possibly procedurally or on-demand, and mix in with all other tracks.
    /// When a track uses an audio stream, it will call sdl.audio.Stream.getData as it needs more audio to mix. The app can either buffer data to the stream ahead of time, or set a callback on the stream to provide data as needed. Please refer to SDL's documentation for details.
    /// A given audio stream may only be assigned to a single track at a time; duplicate assignments won't return an error, but assigning a stream to multiple tracks will cause each track to read from the stream arbitrarily, causing confusion and incorrect mixing.
    /// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
    /// Calling this function with a NULL audio stream is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
    /// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
    /// The provided audio stream must remain valid until the track no longer needs it (either by changing the track's input or destroying the track).
    ///
    /// - **Parameters:**
    ///   - `stream`: the audio stream to use as the track's input.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setAudioStream(self: @This(), stream: ?*sdl.audio.Stream) sdl.Error!void {
        if (!c.MIX_SetTrackAudioStream(@ptrCast(self.value), if (stream) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
    }

    /// Set a callback that fires when the mixer has transformed a track's audio.
    ///
    /// As a track needs to mix more data, it pulls from its input (a Audio, an sdl.audio.Stream, etc). This input might be a compressed file format, like MP3, so a little more data is uncompressed from it.
    /// Once the track has PCM data to start operating on, and its raw callback has completed, it will begin to transform the audio: gain, fading, frequency ratio, 3D positioning, etc.
    /// A callback can be fired after all these transformations, but before the transformed data is mixed into other tracks. This lets an app view the data at the last moment that it is still a part of this track. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data came directly from the input.
    /// Each track has its own unique cooked callback.
    /// Passing a NULL callback here is legal; it disables this track's callback.
    ///
    /// - **Parameters:**
    ///   - `cb`: the function to call when the track mixes. May be NULL.
    ///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** TrackMixCallback
    /// - **See also:** Track.setRawCallback
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setCookedCallback(self: @This(), cb: TrackMixCallback, userdata: ?*anyopaque) sdl.Error!void {
        if (!c.MIX_SetTrackCookedCallback(@ptrCast(self.value), @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
    }

    /// Change the frequency ratio of a track.
    ///
    /// The frequency ratio is used to adjust the rate at which audio data is consumed. Changing this effectively modifies the speed and pitch of the track's audio. A value greater than 1.0f will play the audio faster, and at a higher pitch. A value less than 1.0f will play the audio slower, and at a lower pitch. 1.0f is normal speed.
    /// The default value is 1.0f.
    /// This value can be changed at any time to adjust the future mix.
    ///
    /// - **Parameters:**
    ///   - `ratio`: the frequency ratio. Must be between 0.01f and 100.0f.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getFrequencyRatio
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setFrequencyRatio(self: @This(), ratio: f32) sdl.Error!void {
        if (!c.MIX_SetTrackFrequencyRatio(@ptrCast(self.value), ratio)) return error.SdlFailure;
    }

    /// Set a track's gain control.
    ///
    /// Each track has its own gain, to adjust its overall volume. Each sample from this track is modulated by this gain value. A gain of zero will generate silence, 1.0f will not change the mixed volume, and larger than 1.0f will increase the volume. Negative values are illegal. There is no maximum gain specified, but this can quickly get extremely loud, so please be careful with this setting.
    /// A track's gain defaults to 1.0f.
    /// This value can be changed at any time to adjust the future mix.
    ///
    /// - **Parameters:**
    ///   - `gain`: the new gain value.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getGain
    /// - **See also:** Mixer.setGain
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setGain(self: @This(), gain: f32) sdl.Error!void {
        if (!c.MIX_SetTrackGain(@ptrCast(self.value), gain)) return error.SdlFailure;
    }

    /// Assign a track to a mixing group.
    ///
    /// All tracks in a group are mixed together, and that output is made available to the app before it is mixed into the final output.
    /// Tracks can only be in one group at a time, and the track and group must have been created on the same Mixer.
    /// Setting a track to a NULL group will remove it from any app-created groups, and reassign it to the mixer's internal default group.
    ///
    /// - **Parameters:**
    ///   - `group`: the new mixing group to assign to. May be NULL.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** createGroup
    /// - **See also:** Group.setPostMixCallback
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setGroup(self: @This(), group: ?Group) sdl.Error!void {
        if (!c.MIX_SetTrackGroup(@ptrCast(self.value), if (group) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
    }

    /// Set a MIX_Track's input to an sdl.ioStream.IoStream.
    ///
    /// This is not the recommended way to set a track's input, but this can be useful for a very specific scenario: a large file, to be played once, that must be read from disk in small chunks as needed. In most cases, however, it is preferable to create a Audio ahead of time and use Track.setAudio() instead.
    /// The stream supplied here should provide an audio file in a supported format. SDL_mixer will parse it during this call to make sure it's valid, and then will read file data from the stream as it needs to decode more during mixing.
    /// The stream must be able to seek through the complete set of data, or this function will fail.
    /// A given IOStream may only be assigned to a single track at a time; duplicate assignments won't return an error, but assigning a stream to multiple tracks will cause each track to read from the stream arbitrarily, causing confusion, incorrect mixing, or failure to decode.
    /// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
    /// Calling this function with a NULL stream is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
    /// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
    /// The provided stream must remain valid until the track no longer needs it (either by changing the track's input or destroying the track).
    ///
    /// - **Parameters:**
    ///   - `io`: the new i/o stream to use as the track's input.
    ///   - `closeio`: if true, close the stream when done with it.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.setRawIoStream
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setIoStream(self: @This(), io: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
        if (!c.MIX_SetTrackIOStream(@ptrCast(self.value), if (io) |resource| @ptrCast(resource.value) else null, closeio)) return error.SdlFailure;
    }

    /// Change the number of times a currently-playing track will loop.
    ///
    /// This replaces any previously-set remaining loops. A value of 1 will loop to the start of playback one time. Zero will not loop at all. A value of -1 requests infinite loops. If the input is not seekable and `num_loops` isn't zero, this function will report success but the track will stop at the point it should loop.
    /// The new loop count replaces any previous state, even if the track has already looped.
    /// This has no effect on a track that is stopped, or rather, starting a stopped track later will set a new loop count, replacing this value. Stopped tracks can specify a loop count while starting via prop_play_loops_number. This function is intended to alter that count in the middle of playback.
    ///
    /// - **Parameters:**
    ///   - `num_loops`: new number of times to loop. Zero to disable looping, -1 to loop infinitely.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getLoops
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setLoops(self: @This(), num_loops: c_int) sdl.Error!void {
        if (!c.MIX_SetTrackLoops(@ptrCast(self.value), num_loops)) return error.SdlFailure;
    }

    /// Set the current output channel map of a track.
    ///
    /// Channel maps are optional; most things do not need them, instead passing data in the order that SDL expects.
    /// The output channel map reorders track data after transformations and before it is mixed into a mixer group. This can be useful for reversing stereo channels, for example.
    /// Each item in the array represents an input channel, and its value is the channel that it should be remapped to. To reverse a stereo signal's left and right values, you'd have an array of `{ 1, 0 }`. It is legal to remap multiple channels to the same thing, so `{ 1, 1 }` would duplicate the right channel to both channels of a stereo signal. An element in the channel map set to -1 instead of a valid channel will mute that channel, setting it to a silence value.
    /// You cannot change the number of channels through a channel map, just reorder/mute them.
    /// Tracks default to no remapping applied. Passing a NULL channel map is legal, and turns off remapping.
    /// SDL_mixer will copy the channel map; the caller does not have to save this array after this call.
    ///
    /// - **Parameters:**
    ///   - `chmap`: the new channel map, NULL to reset to default.
    ///   - `count`: The number of channels in the map.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setOutputChannelMap(self: @This(), chmap: ?*const c_int, count: c_int) sdl.Error!void {
        if (!c.MIX_SetTrackOutputChannelMap(@ptrCast(self.value), @ptrCast(chmap), count)) return error.SdlFailure;
    }

    /// Seek a playing track to a new position in its input.
    ///
    /// (Not to be confused with Track.setTrack3dPosition(), which is positioning of the track in 3D space, not the playback position of its audio data.)
    /// On a playing track, the next time the mixer runs, it will start mixing from the new position.
    /// Position is defined in *sample frames* of decoded audio, not units of time, so that sample-perfect mixing can be achieved. To instead operate in units of time, use Track.msToFrames() to get the approximate sample frames for a given tick.
    /// This function requires an input that can seek (so it can not be used if the input was set with Track.setAudioStream()), and a audio file format that allows seeking. SDL_mixer's decoders for some file formats do not offer seeking, or can only seek to times, not exact sample frames, in which case the final position may be off by some amount of sample frames. Please check your audio data and file bug reports if appropriate.
    /// It's legal to call this function on a track that is stopped, but a future call to Track.play() will reset the start position anyhow. Paused tracks will resume at the new input position.
    ///
    /// - **Parameters:**
    ///   - `frames`: the sample frame position to seek to.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.getPlaybackPosition
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setPlaybackPosition(self: @This(), frames: i64) sdl.Error!void {
        if (!c.MIX_SetTrackPlaybackPosition(@ptrCast(self.value), frames)) return error.SdlFailure;
    }

    /// Set a callback that fires when a Track has initial decoded audio.
    ///
    /// As a track needs to mix more data, it pulls from its input (a Audio, an sdl.audio.Stream, etc). This input might be a compressed file format, like MP3, so a little more data is uncompressed from it.
    /// Once the track has PCM data to start operating on, it can fire a callback before *any* changes to the raw PCM input have happened. This lets an app view the data before it has gone through transformations such as gain, 3D positioning, fading, etc. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data came directly from the input.
    /// Each track has its own unique raw callback.
    /// Passing a NULL callback here is legal; it disables this track's callback.
    ///
    /// - **Parameters:**
    ///   - `cb`: the function to call when the track mixes. May be NULL.
    ///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** TrackMixCallback
    /// - **See also:** Track.setCookedCallback
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setRawCallback(self: @This(), cb: TrackMixCallback, userdata: ?*anyopaque) sdl.Error!void {
        if (!c.MIX_SetTrackRawCallback(@ptrCast(self.value), @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
    }

    /// Set a MIX_Track's input to an sdl.ioStream.IoStream providing raw PCM data.
    ///
    /// This is not the recommended way to set a track's input, but this can be useful for a very specific scenario: a large file, to be played once, that must be read from disk in small chunks as needed. In most cases, however, it is preferable to create a Audio ahead of time and use Track.setAudio() instead.
    /// Also, an Track.setAudioStream() can *also* provide raw PCM audio to a track, via an sdl.audio.Stream, which might be preferable unless the data is already coming directly from an sdl.ioStream.IoStream.
    /// The stream supplied here should provide an audio in raw PCM format.
    /// A given IOStream may only be assigned to a single track at a time; duplicate assignments won't return an error, but assigning a stream to multiple tracks will cause each track to read from the stream arbitrarily, causing confusion and incorrect mixing.
    /// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
    /// Calling this function with a NULL stream is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
    /// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
    /// The provided stream must remain valid until the track no longer needs it (either by changing the track's input or destroying the track).
    ///
    /// - **Parameters:**
    ///   - `io`: the new i/o stream to use as the track's input.
    ///   - `spec`: the format of the PCM data that the sdl.ioStream.IoStream will provide.
    ///   - `closeio`: if true, close the stream when done with it.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.setAudioStream
    /// - **See also:** Track.setIoStream
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setRawIoStream(self: @This(), io: ?*sdl.ioStream.IoStream, spec: ?*const sdl.audio.Spec, closeio: bool) sdl.Error!void {
        if (!c.MIX_SetTrackRawIOStream(@ptrCast(self.value), if (io) |resource| @ptrCast(resource.value) else null, @ptrCast(spec), closeio)) return error.SdlFailure;
    }

    /// Force a track to stereo output, with optionally left/right panning.
    ///
    /// This will cause the output of the track to convert to stereo, and then mix it only onto the Front Left and Front Right speakers, regardless of the speaker configuration. The left and right channels are modulated by `gains`, which can be used to produce panning effects. This function may be called to adjust the gains at any time.
    /// If `gains` is not NULL, this track will be switched into forced-stereo mode. If `gains` is NULL, this will disable spatialization (both the forced-stereo mode of this function and full 3D spatialization of Track.setTrack3dPosition()).
    /// Negative gains are clamped to zero; there is no clamp for maximum, so one could set the value > 1.0f to make a channel louder.
    /// The track's 3D position, reported by Track.getTrack3dPosition(), will be reset to (0, 0, 0).
    ///
    /// - **Parameters:**
    ///   - `gains`: the per-channel gains, or NULL to disable spatialization.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.setTrack3dPosition
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setStereo(self: @This(), gains: ?*const StereoGains) sdl.Error!void {
        if (!c.MIX_SetTrackStereo(@ptrCast(self.value), @ptrCast(gains))) return error.SdlFailure;
    }

    /// Set a callback that fires when a Track is stopped.
    ///
    /// When a track completes playback, either because it ran out of data to mix (and all loops were completed as well), or it was explicitly stopped by the app, it will fire the callback specified here.
    /// Each track has its own unique callback.
    /// Passing a NULL callback here is legal; it disables this track's callback.
    /// Pausing a track will not fire the callback, nor will the callback fire on a playing track that is being destroyed.
    /// It is legal to adjust the track, including changing its input and restarting it. If this is done because it ran out of data in the middle of mixing, the mixer will start mixing the new track state in its current run without any gap in the audio.
    ///
    /// - **Parameters:**
    ///   - `cb`: the function to call when the track stops. May be NULL.
    ///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
    ///
    /// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** TrackStoppedCallback
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn setStoppedCallback(self: @This(), cb: TrackStoppedCallback, userdata: ?*anyopaque) sdl.Error!void {
        if (!c.MIX_SetTrackStoppedCallback(@ptrCast(self.value), @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
    }

    /// Halt a currently-playing track, possibly fading out over time.
    ///
    /// If `fade_out_frames` is > 0, the track does not stop mixing immediately, but rather fades to silence over that many sample frames before stopping. Sample frames are specific to the input assigned to the track, to allow for sample-perfect mixing. Track.msToFrames() can be used to convert milliseconds to an appropriate value here.
    /// If the track ends normally while the fade-out is still in progress, the audio stops there; the fade is not adjusted to be shorter if it will last longer than the audio remaining.
    /// Once a track has completed any fadeout and come to a stop, it will call its TrackStoppedCallback, if any. It is legal to assign the track a new input and/or restart it during this callback.
    /// It is legal to halt a track that's already stopped. It does nothing, and returns true.
    ///
    /// - **Parameters:**
    ///   - `fade_out_frames`: the number of sample frames to spend fading out to silence before halting. 0 to stop immediately.
    ///
    /// - **Returns:** true if the track has stopped, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.play
    pub inline fn stop(self: @This(), fade_out_frames: i64) bool {
        return c.MIX_StopTrack(@ptrCast(self.value), fade_out_frames);
    }

    /// Assign an arbitrary tag to a track.
    ///
    /// A tag can be any valid C string in UTF-8 encoding. It can be useful to group tracks in various ways. For example, everything in-game might be marked as "game", so when the user brings up the settings menu, the app can pause all tracks involved in gameplay at once, but keep background music and menu sound effects running.
    /// A track can have as many tags as desired, until the machine runs out of memory.
    /// It's legal to add the same tag to a track more than once; the extra attempts will report success but not change anything.
    /// Tags can later be removed with Track.untag().
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to add.
    ///
    /// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.untag
    /// Returns `error.SdlFailure` when SDL_mixer reports failure.
    pub inline fn tag(self: @This(), tag_2: ?[:0]const u8) sdl.Error!void {
        if (!c.MIX_TagTrack(@ptrCast(self.value), if (tag_2 != null) @ptrCast(tag_2.?.ptr) else null)) return error.SdlFailure;
    }

    /// Convert sample frames for a track's current format to milliseconds.
    ///
    /// This calculates time based on the track's current input format, which can change when its input does, and also if that input changes formats mid-stream (for example, if decoding a file that is two MP3s concatenated together).
    /// Sample frames are more precise than milliseconds, so out of necessity, this function will approximate by rounding down to the closest full millisecond.
    /// On various errors (init() was not called, the track is NULL), this returns -1. If the track has no input, this returns -1. If `frames` is < 0, this returns -1.
    ///
    /// - **Parameters:**
    ///   - `frames`: the track-specific sample frames to convert to milliseconds.
    ///
    /// - **Returns:** Converted number of milliseconds, or -1 for errors/no input; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.msToFrames
    pub inline fn framesToMs(self: @This(), frames: i64) i64 {
        return c.MIX_TrackFramesToMS(@ptrCast(self.value), frames);
    }

    /// Convert milliseconds to sample frames for a track's current format.
    ///
    /// This calculates time based on the track's current input format, which can change when its input does, and also if that input changes formats mid-stream (for example, if decoding a file that is two MP3s concatenated together).
    /// On various errors (init() was not called, the track is NULL), this returns -1. If the track has no input, this returns -1. If `ms` is < 0, this returns -1.
    ///
    /// - **Parameters:**
    ///   - `ms`: the milliseconds to convert to track-specific sample frames.
    ///
    /// - **Returns:** Converted number of sample frames, or -1 for errors/no input; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.framesToMs
    pub inline fn msToFrames(self: @This(), ms: i64) i64 {
        return c.MIX_TrackMSToFrames(@ptrCast(self.value), ms);
    }

    /// Query if a track is currently paused.
    ///
    /// If this returns true, the track is not currently contributing to the mixer's output but will when resumed (it's "paused"). It is not playing nor stopped.
    /// On various errors (init() was not called, the track is NULL), this returns false, but there is no mechanism to distinguish errors from non-playing tracks.
    ///
    /// - **Returns:** true if paused, false otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.play
    /// - **See also:** Track.pause
    /// - **See also:** Track.resume_
    /// - **See also:** Track.stop
    /// - **See also:** Track.playing
    pub inline fn paused(self: @This()) bool {
        return c.MIX_TrackPaused(@ptrCast(self.value));
    }

    /// Query if a track is currently playing.
    ///
    /// If this returns true, the track is currently contributing to the mixer's output (it's "playing"). It is not stopped nor paused.
    /// On various errors (init() was not called, the track is NULL), this returns false, but there is no mechanism to distinguish errors from non-playing tracks.
    ///
    /// - **Returns:** true if playing, false otherwise.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.play
    /// - **See also:** Track.pause
    /// - **See also:** Track.resume_
    /// - **See also:** Track.stop
    /// - **See also:** Track.paused
    pub inline fn playing(self: @This()) bool {
        return c.MIX_TrackPlaying(@ptrCast(self.value));
    }

    /// Remove an arbitrary tag from a track.
    ///
    /// A tag can be any valid C string in UTF-8 encoding. It can be useful to group tracks in various ways. For example, everything in-game might be marked as "game", so when the user brings up the settings menu, the app can pause all tracks involved in gameplay at once, but keep background music and menu sound effects running.
    /// It's legal to remove a tag that the track doesn't have; this function doesn't report errors, so this simply does nothing.
    /// Specifying a NULL tag will remove all tags on a track.
    ///
    /// - **Parameters:**
    ///   - `tag`: the tag to remove, or NULL to remove all current tags.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_mixer 3.0.0.
    /// - **See also:** Track.tag
    pub inline fn untag(self: @This(), tag_2: ?[:0]const u8) void {
        c.MIX_UntagTrack(@ptrCast(self.value), if (tag_2 != null) @ptrCast(tag_2.?.ptr) else null);
    }
};

/// A callback that fires when a Group has completed mixing.
///
/// This callback is fired when a mixing group has finished mixing: all tracks in the group have mixed into a single buffer and are prepared to be mixed into all other groups for the final mix output.
/// The audio data passed through here is *not* const data; the app is permitted to change it in any way it likes, and those changes will propagate through the mixing pipeline.
/// An audiospec is provided. Different groups might be in different formats, and an app needs to be able to handle that, but SDL_mixer always does its mixing work in 32-bit float samples, even if the inputs or final output are not floating point. As such, `spec->format` will always be `sdl.audio.Format.f32_` and `pcm` hardcoded to be a float pointer.
/// `samples` is the number of float values pointed to by `pcm`: samples, not sample frames! There are no promises how many samples will be provided per-callback, and this number can vary wildly from call to call, depending on many factors.
///
/// - **Parameters:**
///   - `userdata`: an opaque pointer provided by the app for its personal use.
///   - `group`: the group that is being mixed.
///   - `spec`: the format of the data in `pcm`.
///   - `pcm`: the raw PCM data in float32 format.
///   - `samples`: the number of float values pointed to by `pcm`.
///
/// - **Since:** This datatype is available since SDL_mixer 3.0.0.
/// - **See also:** Group.setPostMixCallback
pub const GroupMixCallback = ?*const fn (arg0: ?*anyopaque, arg1: ?Group, arg2: ?*const sdl.audio.Spec, arg3: ?*f32, arg4: c_int) callconv(.c) void;

/// A callback that fires when all mixing has completed.
///
/// This callback is fired when the mixer has completed all its work. If this mixer was created with createMixerDevice(), the data provided by this callback is what is being sent to the audio hardware, minus last conversions for format requirements. If this mixer was created with createMixer(), this is what is being output from Mixer.generate(), after final conversions.
/// The audio data passed through here is *not* const data; the app is permitted to change it in any way it likes, and those changes will replace the final mixer pipeline output.
/// An audiospec is provided. SDL_mixer always does its mixing work in 32-bit float samples, even if the inputs or final output are not floating point. As such, `spec->format` will always be `sdl.audio.Format.f32_` and `pcm` hardcoded to be a float pointer.
/// `samples` is the number of float values pointed to by `pcm`: samples, not sample frames! There are no promises how many samples will be provided per-callback, and this number can vary wildly from call to call, depending on many factors.
///
/// - **Parameters:**
///   - `userdata`: an opaque pointer provided by the app for its personal use.
///   - `mixer`: the mixer that is generating audio.
///   - `spec`: the format of the data in `pcm`.
///   - `pcm`: the raw PCM data in float32 format.
///   - `samples`: the number of float values pointed to by `pcm`.
///
/// - **Since:** This datatype is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.setPostMixCallback
pub const PostMixCallback = ?*const fn (arg0: ?*anyopaque, arg1: ?Mixer, arg2: ?*const sdl.audio.Spec, arg3: ?*f32, arg4: c_int) callconv(.c) void;

/// A callback that fires when a Track is mixing at various stages.
///
/// This callback is fired for different parts of the mixing pipeline, and gives the app visbility into the audio data that is being generated at various stages.
/// The audio data passed through here is *not* const data; the app is permitted to change it in any way it likes, and those changes will propagate through the mixing pipeline.
/// An audiospec is provided. Different tracks might be in different formats, and an app needs to be able to handle that, but SDL_mixer always does its mixing work in 32-bit float samples, even if the inputs or final output are not floating point. As such, `spec->format` will always be `sdl.audio.Format.f32_` and `pcm` hardcoded to be a float pointer.
/// `samples` is the number of float values pointed to by `pcm`: samples, not sample frames! There are no promises how many samples will be provided per-callback, and this number can vary wildly from call to call, depending on many factors.
/// Making changes to the track during this callback is undefined behavior. Change the data in `pcm` but not the track itself.
///
/// - **Parameters:**
///   - `userdata`: an opaque pointer provided by the app for its personal use.
///   - `track`: the track that is being mixed.
///   - `spec`: the format of the data in `pcm`.
///   - `pcm`: the raw PCM data in float32 format.
///   - `samples`: the number of float values pointed to by `pcm`.
///
/// - **Since:** This datatype is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setRawCallback
/// - **See also:** Track.setCookedCallback
pub const TrackMixCallback = ?*const fn (arg0: ?*anyopaque, arg1: ?Track, arg2: ?*const sdl.audio.Spec, arg3: ?*f32, arg4: c_int) callconv(.c) void;

/// A callback that fires when a Track is stopped.
///
/// This callback is fired when a track completes playback, either because it ran out of data to mix (and all loops were completed as well), or it was explicitly stopped by the app. Pausing a track will not fire this callback.
/// It is legal to adjust the track, including changing its input and restarting it. If this is done because it ran out of data in the middle of mixing, the mixer will start mixing the new track state in its current run without any gap in the audio.
/// This callback will not fire when a playing track is destroyed.
///
/// - **Parameters:**
///   - `userdata`: an opaque pointer provided by the app for its personal use.
///   - `track`: the track that has stopped.
///
/// - **Since:** This datatype is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setStoppedCallback
pub const TrackStoppedCallback = ?*const fn (arg0: ?*anyopaque, arg1: ?Track) callconv(.c) void;

/// SDL constant `duration_infinite`.
pub const duration_infinite = c.MIX_DURATION_INFINITE;
/// SDL constant `duration_unknown`.
pub const duration_unknown = c.MIX_DURATION_UNKNOWN;
/// SDL constant `prop_audio_decoder_string`.
pub const prop_audio_decoder_string = c.MIX_PROP_AUDIO_DECODER_STRING;
/// SDL constant `prop_audio_load_closeio_boolean`.
pub const prop_audio_load_closeio_boolean = c.MIX_PROP_AUDIO_LOAD_CLOSEIO_BOOLEAN;
/// SDL constant `prop_audio_load_ignore_loops_boolean`.
pub const prop_audio_load_ignore_loops_boolean = c.MIX_PROP_AUDIO_LOAD_IGNORE_LOOPS_BOOLEAN;
/// SDL constant `prop_audio_load_io_stream_pointer`.
pub const prop_audio_load_io_stream_pointer = c.MIX_PROP_AUDIO_LOAD_IOSTREAM_POINTER;
/// SDL constant `prop_audio_load_predecode_boolean`.
pub const prop_audio_load_predecode_boolean = c.MIX_PROP_AUDIO_LOAD_PREDECODE_BOOLEAN;
/// SDL constant `prop_audio_load_preferred_mixer_pointer`.
pub const prop_audio_load_preferred_mixer_pointer = c.MIX_PROP_AUDIO_LOAD_PREFERRED_MIXER_POINTER;
/// SDL constant `prop_audio_load_skip_metadata_tags_boolean`.
pub const prop_audio_load_skip_metadata_tags_boolean = c.MIX_PROP_AUDIO_LOAD_SKIP_METADATA_TAGS_BOOLEAN;
/// SDL constant `prop_metadata_album_string`.
pub const prop_metadata_album_string = c.MIX_PROP_METADATA_ALBUM_STRING;
/// SDL constant `prop_metadata_artist_string`.
pub const prop_metadata_artist_string = c.MIX_PROP_METADATA_ARTIST_STRING;
/// SDL constant `prop_metadata_copy_right_string`.
pub const prop_metadata_copy_right_string = c.MIX_PROP_METADATA_COPYRIGHT_STRING;
/// SDL constant `prop_metadata_duration_frames_number`.
pub const prop_metadata_duration_frames_number = c.MIX_PROP_METADATA_DURATION_FRAMES_NUMBER;
/// SDL constant `prop_metadata_duration_infinite_boolean`.
pub const prop_metadata_duration_infinite_boolean = c.MIX_PROP_METADATA_DURATION_INFINITE_BOOLEAN;
/// SDL constant `prop_metadata_title_string`.
pub const prop_metadata_title_string = c.MIX_PROP_METADATA_TITLE_STRING;
/// SDL constant `prop_metadata_total_tracks_number`.
pub const prop_metadata_total_tracks_number = c.MIX_PROP_METADATA_TOTAL_TRACKS_NUMBER;
/// SDL constant `prop_metadata_track_number`.
pub const prop_metadata_track_number = c.MIX_PROP_METADATA_TRACK_NUMBER;
/// SDL constant `prop_metadata_year_number`.
pub const prop_metadata_year_number = c.MIX_PROP_METADATA_YEAR_NUMBER;
/// SDL constant `prop_mixer_device_number`.
pub const prop_mixer_device_number = c.MIX_PROP_MIXER_DEVICE_NUMBER;
/// SDL constant `prop_play_app_end_silence_frames_number`.
pub const prop_play_app_end_silence_frames_number = c.MIX_PROP_PLAY_APPEND_SILENCE_FRAMES_NUMBER;
/// SDL constant `prop_play_app_end_silence_milliseconds_number`.
pub const prop_play_app_end_silence_milliseconds_number = c.MIX_PROP_PLAY_APPEND_SILENCE_MILLISECONDS_NUMBER;
/// SDL constant `prop_play_fade_in_frames_number`.
pub const prop_play_fade_in_frames_number = c.MIX_PROP_PLAY_FADE_IN_FRAMES_NUMBER;
/// SDL constant `prop_play_fade_in_milliseconds_number`.
pub const prop_play_fade_in_milliseconds_number = c.MIX_PROP_PLAY_FADE_IN_MILLISECONDS_NUMBER;
/// SDL constant `prop_play_fade_in_start_gain_float`.
pub const prop_play_fade_in_start_gain_float = c.MIX_PROP_PLAY_FADE_IN_START_GAIN_FLOAT;
/// SDL constant `prop_play_halt_when_exhausted_boolean`.
pub const prop_play_halt_when_exhausted_boolean = c.MIX_PROP_PLAY_HALT_WHEN_EXHAUSTED_BOOLEAN;
/// SDL constant `prop_play_loop_start_frame_number`.
pub const prop_play_loop_start_frame_number = c.MIX_PROP_PLAY_LOOP_START_FRAME_NUMBER;
/// SDL constant `prop_play_loop_start_millisecond_number`.
pub const prop_play_loop_start_millisecond_number = c.MIX_PROP_PLAY_LOOP_START_MILLISECOND_NUMBER;
/// SDL constant `prop_play_loops_number`.
pub const prop_play_loops_number = c.MIX_PROP_PLAY_LOOPS_NUMBER;
/// SDL constant `prop_play_max_frame_number`.
pub const prop_play_max_frame_number = c.MIX_PROP_PLAY_MAX_FRAME_NUMBER;
/// SDL constant `prop_play_max_milliseconds_number`.
pub const prop_play_max_milliseconds_number = c.MIX_PROP_PLAY_MAX_MILLISECONDS_NUMBER;
/// SDL constant `prop_play_start_frame_number`.
pub const prop_play_start_frame_number = c.MIX_PROP_PLAY_START_FRAME_NUMBER;
/// SDL constant `prop_play_start_millisecond_number`.
pub const prop_play_start_millisecond_number = c.MIX_PROP_PLAY_START_MILLISECOND_NUMBER;
/// SDL constant `prop_play_start_order_number`.
pub const prop_play_start_order_number = c.MIX_PROP_PLAY_START_ORDER_NUMBER;
/// The current major version of SDL_mixer headers.
///
/// If this were SDL_mixer version 3.2.1, this value would be 3.
///
/// - **Since:** This macro is available since SDL_mixer 3.0.0.
pub const major_version = c.SDL_MIXER_MAJOR_VERSION;
/// The current micro (or patchlevel) version of the SDL_mixer headers.
///
/// If this were SDL_mixer version 3.2.1, this value would be 1.
///
/// - **Since:** This macro is available since SDL_mixer 3.0.0.
pub const micro_version = c.SDL_MIXER_MICRO_VERSION;
/// The current minor version of the SDL_mixer headers.
///
/// If this were SDL_mixer version 3.2.1, this value would be 2.
///
/// - **Since:** This macro is available since SDL_mixer 3.0.0.
pub const minor_version = c.SDL_MIXER_MINOR_VERSION;
/// This is the current version number macro of the SDL_mixer headers.
///
/// - **Since:** This macro is available since SDL_mixer 3.0.0.
/// - **See also:** versionDefault
pub const version = c.SDL_MIXER_VERSION;

/// This macro will evaluate to true if compiled with SDL_mixer at least X.Y.Z.
///
/// - **Since:** This macro is available since SDL_mixer 3.0.0.
pub inline fn versionAtleast(x: c_uint, y: c_uint, z: c_uint) bool {
    return c.SDL_MIXER_MAJOR_VERSION >= x and c.SDL_MIXER_MAJOR_VERSION > x or c.SDL_MIXER_MINOR_VERSION >= y and c.SDL_MIXER_MAJOR_VERSION > x or c.SDL_MIXER_MINOR_VERSION > y or c.SDL_MIXER_MICRO_VERSION >= z;
}

/// Convert sample frames for a MIX_Audio's format to milliseconds.
///
/// This calculates time based on the audio's initial format, even if the format would change mid-stream.
/// Sample frames are more precise than milliseconds, so out of necessity, this function will approximate by rounding down to the closest full millisecond.
/// If `frames` is < 0, this returns -1.
///
/// - **Parameters:**
///   - `audio`: the audio to query.
///   - `frames`: the audio-specific sample frames to convert to milliseconds.
///
/// - **Returns:** Converted number of milliseconds, or -1 for errors/no input; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.msToFrames
pub inline fn audioFramesToMs(audio: ?Audio, frames: i64) i64 {
    return c.MIX_AudioFramesToMS(if (audio) |resource| @ptrCast(resource.value) else null, frames);
}

/// Convert milliseconds to sample frames for a MIX_Audio's format.
///
/// This calculates time based on the audio's initial format, even if the format would change mid-stream.
/// If `ms` is < 0, this returns -1.
///
/// - **Parameters:**
///   - `audio`: the audio to query.
///   - `ms`: the milliseconds to convert to audio-specific sample frames.
///
/// - **Returns:** Converted number of sample frames, or -1 for errors/no input; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.framesToMs
pub inline fn audioMsToFrames(audio: ?Audio, ms: i64) i64 {
    return c.MIX_AudioMSToFrames(if (audio) |resource| @ptrCast(resource.value) else null, ms);
}

/// Create a AudioDecoder from a path on the filesystem.
///
/// Most apps won't need this, as SDL_mixer's usual interfaces will decode audio as needed. However, if one wants to decode an audio file into a memory buffer without playing it, this interface offers that.
/// This function allows properties to be specified. This is intended to supply file-specific settings, such as where to find SoundFonts for a MIDI file, etc. In most cases, the caller should pass a zero to specify no extra properties.
/// sdl.properties.Id are discussed in [SDL's documentation](https://wiki.libsdl.org/SDL3/CategoryProperties) When done with the audio decoder, it can be destroyed with AudioDecoder.deinit().
/// This function requires SDL_mixer to have been initialized with a successful call to init(), but does not need an actual Mixer to have been created.
///
/// - **Parameters:**
///   - `path`: the path on the filesystem from which to load data.
///   - `props`: decoder-specific properties. May be zero.
///
/// - **Returns:** an audio decoder, ready to decode.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** createAudioDecoderIo
/// - **See also:** AudioDecoder.decode
/// - **See also:** AudioDecoder.deinit
pub inline fn createAudioDecoder(path: ?[:0]const u8, props: sdl.properties.Id) ?AudioDecoder {
    const result = c.MIX_CreateAudioDecoder(if (path != null) @ptrCast(path.?.ptr) else null, props);
    return if (result) |value| AudioDecoder{ .value = @ptrCast(value) } else null;
}

/// Create a AudioDecoder from an sdl.ioStream.IoStream.
///
/// Most apps won't need this, as SDL_mixer's usual interfaces will decode audio as needed. However, if one wants to decode an audio file into a memory buffer without playing it, this interface offers that.
/// This function allows properties to be specified. This is intended to supply file-specific settings, such as where to find SoundFonts for a MIDI file, etc. Most of the properties available to loadAudioWithProperties() apply here, too. In most cases, the caller should pass a zero to specify no extra properties.
/// If `closeio` is true, then `io` will be closed when this decoder is done with it. If this function fails and `closeio` is true, then `io` will be closed before this function returns.
/// When done with the audio decoder, it can be destroyed with AudioDecoder.deinit().
/// This function requires SDL_mixer to have been initialized with a successful call to init(), but does not need an actual Mixer to have been created.
///
/// - **Parameters:**
///   - `io`: the i/o stream from which to load data.
///   - `closeio`: if true, close the i/o stream when done with it.
///   - `props`: decoder-specific properties. May be zero.
///
/// - **Returns:** an audio decoder, ready to decode.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** createAudioDecoderIo
/// - **See also:** AudioDecoder.decode
/// - **See also:** AudioDecoder.deinit
pub inline fn createAudioDecoderIo(io: ?*sdl.ioStream.IoStream, closeio: bool, props: sdl.properties.Id) ?AudioDecoder {
    const result = c.MIX_CreateAudioDecoder_IO(if (io) |resource| @ptrCast(resource.value) else null, closeio, props);
    return if (result) |value| AudioDecoder{ .value = @ptrCast(value) } else null;
}

/// Create a mixing group.
///
/// Tracks are assigned to a mixing group (or if unassigned, they live in a mixer's internal default group). All tracks in a group are mixed together and the app can access this mixed data before it is mixed with all other groups to produce the final output.
/// This can be a useful feature, but is completely optional; apps can ignore mixing groups entirely and still have a full experience with SDL_mixer.
/// After creating a group, assign tracks to it with Track.setGroup(). Use Group.setPostMixCallback() to access the group's mixed data.
/// A mixing group can be destroyed with Group.deinit() when no longer needed. Destroying the mixer will also destroy all its still-existing mixing groups.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to create a mixing group.
///
/// - **Returns:** a newly-created mixing group, or NULL on error; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Group.deinit
/// - **See also:** Track.setGroup
/// - **See also:** Group.setPostMixCallback
pub inline fn createGroup(mixer: ?Mixer) ?Group {
    const result = c.MIX_CreateGroup(if (mixer) |resource| @ptrCast(resource.value) else null);
    return if (result) |value| Group{ .value = @ptrCast(value) } else null;
}

/// Create a mixer that generates audio to a memory buffer.
///
/// Usually you want createMixerDevice() instead of this function. The mixer created here can be used with Mixer.generate() to produce more data on demand, as fast as desired.
/// An audio format must be specified. This is the format it will output in. This cannot be NULL.
/// Once a mixer is created, next steps are usually to load audio (through loadAudio() and friends), create a track (createTrack()), and play that audio through that track.
/// When done with the mixer, it can be destroyed with Mixer.deinit().
///
/// - **Parameters:**
///   - `spec`: the audio format that mixer will generate.
///
/// - **Returns:** a mixer that can be used to generate audio, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** createMixerDevice
/// - **See also:** Mixer.deinit
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn createMixer(spec: ?*const sdl.audio.Spec) sdl.Error!Mixer {
    const result = c.MIX_CreateMixer(@ptrCast(spec));
    if (result == null) return error.SdlFailure;
    return Mixer{ .value = @ptrCast(result.?) };
}

/// Create a mixer that plays sound directly to an audio device.
///
/// This is usually the function you want, vs createMixer().
/// You can choose a specific device ID to open, following SDL's usual rules, but often the correct choice is to specify sdl.audio.deviceDefaultPlayback and let SDL figure out what device to use (and seamlessly transition you to new hardware if the default changes).
/// Only playback devices make sense here. Attempting to open a recording device will fail.
/// This will call sdl.init.default(sdl.init.Flags.audio) internally; it's safe to call sdl.init.default() before this call, too, if you intend to enumerate audio devices to choose one to open here.
/// An audio format can be requested, and the system will try to set the hardware to those specifications, or as close as possible, but this is just a hint. SDL_mixer will handle all data conversion behind the scenes in any case, and specifying a NULL spec is a reasonable choice. The best reason to specify a format is because you know all your data is in that format and it might save some unnecessary CPU time on conversion.
/// The actual device format chosen is available through Mixer.getFormat().
/// Once a mixer is created, next steps are usually to load audio (through loadAudio() and friends), create a track (createTrack()), and play that audio through that track.
/// When done with the mixer, it can be destroyed with Mixer.deinit().
///
/// - **Parameters:**
///   - `devid`: the device to open for playback, or sdl.audio.deviceDefaultPlayback for the default.
///   - `spec`: the audio format to request from the device. May be NULL.
///
/// - **Returns:** a mixer that can be used to play audio, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** This function should only be called on the main thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** createMixer
/// - **See also:** Mixer.deinit
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn createMixerDevice(devid: sdl.audio.DeviceId, spec: ?*const sdl.audio.Spec) sdl.Error!Mixer {
    const result = c.MIX_CreateMixerDevice(devid, @ptrCast(spec));
    if (result == null) return error.SdlFailure;
    return Mixer{ .value = @ptrCast(result.?) };
}

/// Create a Audio that generates a sinewave.
///
/// This is useful just to have *something* to play, perhaps for testing or debugging purposes.
/// You specify its frequency in Hz (determines the pitch of the sinewave's audio) and amplitude (determines the volume of the sinewave: 1.0f is very loud, 0.0f is silent).
/// A number of milliseconds of audio to generate can be specified. Specifying a value less than zero will generate infinite audio (when assigned to a Track, the sinewave will play forever).
/// Audio objects can be shared between multiple mixers. The `mixer` parameter just suggests the most likely mixer to use this audio, in case some optimization might be applied, but this is not required, and a NULL mixer may be specified.
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `hz`: the sinewave's frequency in Hz.
///   - `amplitude`: the sinewave's amplitude from 0.0f to 1.0f.
///   - `ms`: the maximum number of milliseconds of audio to generate, or less than zero to generate infinite audio.
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadAudioIo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn createSineWaveAudio(mixer: ?Mixer, hz: c_int, amplitude: f32, ms: i64) sdl.Error!Audio {
    const result = c.MIX_CreateSineWaveAudio(if (mixer) |resource| @ptrCast(resource.value) else null, hz, amplitude, ms);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Create a new track on a mixer.
///
/// A track provides a single source of audio. All currently-playing tracks will be processed and mixed together to form the final output from the mixer.
/// There are no limits to the number of tracks one may create, beyond running out of memory, but in normal practice there are a small number of tracks that are reused between all loaded audio as appropriate.
/// Tracks are unique to a specific Mixer and can't be transferred between them.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to create this track.
///
/// - **Returns:** a new Track on success, NULL on error; call sdl.error_.get() for more informations.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.deinit
pub inline fn createTrack(mixer: ?Mixer) ?Track {
    const result = c.MIX_CreateTrack(if (mixer) |resource| @ptrCast(resource.value) else null);
    return if (result) |value| Track{ .value = @ptrCast(value) } else null;
}

/// Decode more audio from a AudioDecoder.
///
/// Data is decoded on demand in whatever format is requested. The format is permitted to change between calls.
/// This function will return the number of bytes decoded, which may be less than requested if there was an error or end-of-file. A return value of zero means the entire file was decoded, -1 means an unrecoverable error happened.
///
/// - **Parameters:**
///   - `audiodecoder`: the decoder from which to retrieve more data.
///   - `buffer`: the memory buffer to store decoded audio.
///   - `spec`: the format that audio data will be stored to `buffer`.
///
/// - **Returns:** number of bytes decoded, or -1 on error; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn decodeAudio(audiodecoder: ?AudioDecoder, buffer: []u8, spec: ?*const sdl.audio.Spec) sdl.Error!c_int {
    const result = c.MIX_DecodeAudio(if (audiodecoder) |resource| @ptrCast(resource.value) else null, @ptrCast(buffer.ptr), @intCast(buffer.len), @ptrCast(spec));
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Convert sample frames, at a specific sample rate, to milliseconds.
///
/// Sample frames are more precise than milliseconds, so out of necessity, this function will approximate by rounding down to the closest full millisecond.
/// If `sample_rate` is <= 0, this returns -1. If `frames` is < 0, this returns -1.
///
/// - **Parameters:**
///   - `sample_rate`: the sample rate to use for conversion.
///   - `frames`: the rate-specific sample frames to convert to milliseconds.
///
/// - **Returns:** Converted number of milliseconds, or -1 for errors; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** msToFrames
pub inline fn framesToMs(sample_rate: c_int, frames: i64) i64 {
    return c.MIX_FramesToMS(sample_rate, frames);
}

/// Generate mixer output when not driving an audio device.
///
/// SDL_mixer allows the creation of Mixer objects that are not connected to an audio device, by calling createMixer() instead of createMixerDevice(). Such mixers will not generate output until explicitly requested through this function.
/// The caller may request as much audio as desired, so long as `buflen` is a multiple of the sample frame size specified when creating the mixer (for example, if requesting stereo Sint16 audio, buflen must be a multiple of 4: 2 bytes-per-channel times 2 channels).
/// The mixer will mix as quickly as possible; since it works in sample frames instead of time, it can potentially generate enormous amounts of audio in a small amount of time.
/// On success, this always fills `buffer` with `buflen` bytes of audio; if all playing tracks finish mixing, it will fill the remaining buffer with silence.
/// Each call to this function will pick up where it left off, playing tracks will continue to mix from the point the previous call completed, etc. The mixer state can be changed between each call in any way desired: tracks can be added, played, stopped, changed, removed, etc. Effectively this function does the same thing SDL_mixer does internally when the audio device needs more audio to play.
/// This function can not be used with mixers from createMixerDevice(); those generate audio as needed internally.
/// This function returns the number of *bytes* of real audio mixed, which might be less than `buflen`. While all `buflen` bytes of `buffer` will be initialized, if available tracks to mix run out, the end of the buffer will be initialized with silence; this silence will not be counted in the return value, so the caller has the option to identify how much of the buffer has legimitate contents vs appended silence. As such, any value >= 0 signifies success. A return value of -1 means failure (out of memory, invalid parameters, etc).
///
/// - **Parameters:**
///   - `mixer`: the mixer for which to generate more audio.
///   - `buffer`: a pointer to a buffer to store audio in.
///
/// - **Returns:** The number of bytes of mixed audio, discounting appended silence, on success, or -1 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** createMixer
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn generate(mixer: ?Mixer, buffer: []u8) sdl.Error!c_int {
    const result = c.MIX_Generate(if (mixer) |resource| @ptrCast(resource.value) else null, @ptrCast(buffer.ptr), @intCast(buffer.len));
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Report the name of a specific audio decoders.
///
/// An audio decoder is what turns specific audio file formats into usable PCM data. For example, there might be an MP3 decoder, or a WAV decoder, etc. SDL_mixer probably has several decoders built in.
/// The names are capital English letters and numbers, low-ASCII. They don't necessarily map to a specific file format; Some decoders, like "XMP" operate on multiple file types, and more than one decoder might handle the same file type, like "DRMP3" vs "MPG123". Note that in that last example, neither decoder is called "MP3".
/// The index of a specific decoder is decided during init() and does not change until the library is deinitialized. Valid indices are between zero and the return value of getNumAudioDecoders().
/// The returned pointer is const memory owned by SDL_mixer; do not free it.
///
/// - **Parameters:**
///   - `index`: the index of the decoder to query.
///
/// - **Returns:** a UTF-8 (really, ASCII) string of the decoder's name, or NULL if `index` is invalid.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** getNumAudioDecoders
pub inline fn getAudioDecoder(index: c_int) ?[:0]const u8 {
    const result = c.MIX_GetAudioDecoder(index);
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Named output values.
pub const GetAudioDecoderFormatResult = struct {
    /// Output `spec`.
    spec: sdl.audio.Spec,
};

/// Query the initial audio format of a AudioDecoder.
///
/// Note that some audio files can change format in the middle; some explicitly support this, but a more common example is two MP3 files concatenated together. In many cases, SDL_mixer will correctly handle these sort of files, but this function will only report the initial format a file uses.
///
/// - **Parameters:**
///   - `audiodecoder`: the audio decoder to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// Returns named output values.
pub inline fn getAudioDecoderFormat(audiodecoder: ?AudioDecoder) sdl.Error!GetAudioDecoderFormatResult {
    var spec_raw: @typeInfo(@typeInfo(@TypeOf(c.MIX_GetAudioDecoderFormat)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.MIX_GetAudioDecoderFormat(if (audiodecoder) |resource| @ptrCast(resource.value) else null, &spec_raw)) return error.SdlFailure;
    return GetAudioDecoderFormatResult{
        .spec = @bitCast(spec_raw),
    };
}

/// Get the properties associated with a AudioDecoder.
///
/// SDL_mixer offers some properties of its own, but this can also be a convenient place to store app-specific data.
/// A sdl.properties.Id is created the first time this function is called for a given AudioDecoder, if necessary.
/// The file-specific metadata exposed through this function is identical to those available through Audio.getProperties(). Please refer to that function's documentation for details.
///
/// - **Parameters:**
///   - `audiodecoder`: the audio decoder to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.getProperties
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getAudioDecoderProperties(audiodecoder: ?AudioDecoder) sdl.Error!sdl.properties.Id {
    const result = c.MIX_GetAudioDecoderProperties(if (audiodecoder) |resource| @ptrCast(resource.value) else null);
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Get the length of a MIX_Audio's playback in sample frames.
///
/// This information is also available via the prop_metadata_duration_frames_number property, but it's common enough to provide a simple accessor function.
/// This reports the length of the data in *sample frames*, so sample-perfect mixing can be possible. Sample frames are only meaningful as a measure of time if the sample rate (frequency) is also known. To convert from sample frames to milliseconds, use Audio.framesToMs().
/// Not all audio file formats can report the complete length of the data they will produce through decoding: some can't calculate it, some might produce infinite audio.
/// Also, some file formats can only report duration as a unit of time, which means SDL_mixer might have to estimate sample frames from that information. With less precision, the reported duration might be off by a few sample frames in either direction.
/// This will return a value >= 0 if a duration is known. It might also return duration_unknown or duration_infinite.
///
/// - **Parameters:**
///   - `audio`: the audio to query.
///
/// - **Returns:** the length of the audio in sample frames, or duration_unknown or duration_infinite.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getAudioDuration(audio: ?Audio) i64 {
    return c.MIX_GetAudioDuration(if (audio) |resource| @ptrCast(resource.value) else null);
}

/// Named output values.
pub const GetAudioFormatResult = struct {
    /// Output `spec`.
    spec: sdl.audio.Spec,
};

/// Query the initial audio format of a Audio.
///
/// Note that some audio files can change format in the middle; some explicitly support this, but a more common example is two MP3 files concatenated together. In many cases, SDL_mixer will correctly handle these sort of files, but this function will only report the initial format a file uses.
///
/// - **Parameters:**
///   - `audio`: the audio to query.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// Returns named output values.
pub inline fn getAudioFormat(audio: ?Audio) sdl.Error!GetAudioFormatResult {
    var spec_raw: @typeInfo(@typeInfo(@TypeOf(c.MIX_GetAudioFormat)).@"fn".params[1].type.?).pointer.child = undefined;
    if (!c.MIX_GetAudioFormat(if (audio) |resource| @ptrCast(resource.value) else null, &spec_raw)) return error.SdlFailure;
    return GetAudioFormatResult{
        .spec = @bitCast(spec_raw),
    };
}

/// Get the properties associated with a Audio.
///
/// SDL_mixer offers some properties of its own, but this can also be a convenient place to store app-specific data.
/// A sdl.properties.Id is created the first time this function is called for a given Audio, if necessary.
/// The following read-only properties are provided by SDL_mixer:
/// - `prop_metadata_title_string`: the audio's title ("Smells Like Teen
/// Spirit").
/// - `prop_metadata_artist_string`: the audio's artist name ("Nirvana").
/// - `prop_metadata_album_string`: the audio's album name ("Nevermind").
/// - `prop_metadata_copy_right_string`: the audio's copyright info ("Copyright (c) 1991")
/// - `prop_metadata_track_number`: the audio's track number on the album (1)
/// - `prop_metadata_total_tracks_number`: the total tracks on the album (13)
/// - `prop_metadata_year_number`: the year the audio was released (1991)
/// - `prop_metadata_duration_frames_number`: The sample frames worth of PCM data that comprise this audio. It might be off by a little if the decoder only knows the duration as a unit of time.
/// - `prop_metadata_duration_infinite_boolean`: if true, audio never runs out of sound to generate. This isn't necessarily always known to SDL_mixer, though.
/// Other properties, documented with loadAudioWithProperties(), may also be present.
/// Note that the metadata properties are whatever SDL_mixer finds in things like ID3 tags, and they often have very little standardized formatting, may be missing, and can be completely wrong if the original data is untrustworthy (like an MP3 from a P2P file sharing service).
///
/// - **Parameters:**
///   - `audio`: the audio to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getAudioProperties(audio: ?Audio) sdl.Error!sdl.properties.Id {
    const result = c.MIX_GetAudioProperties(if (audio) |resource| @ptrCast(resource.value) else null);
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Get the Mixer that owns a Group.
///
/// This is the mixer pointer that was passed to createGroup().
///
/// - **Parameters:**
///   - `group`: the group to query.
///
/// - **Returns:** the mixer associated with the group, or NULL on error; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getGroupMixer(group: ?Group) ?Mixer {
    const result = c.MIX_GetGroupMixer(if (group) |resource| @ptrCast(resource.value) else null);
    return if (result) |value| Mixer{ .value = @ptrCast(value) } else null;
}

/// Get the properties associated with a group.
///
/// Currently SDL_mixer assigns no properties of its own to a group, but this can be a convenient place to store app-specific data.
/// A sdl.properties.Id is created the first time this function is called for a given group.
///
/// - **Parameters:**
///   - `group`: the group to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getGroupProperties(group: ?Group) sdl.Error!sdl.properties.Id {
    const result = c.MIX_GetGroupProperties(if (group) |resource| @ptrCast(resource.value) else null);
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Get the audio format a mixer is generating.
///
/// Generally you don't need this information, as SDL_mixer will convert data as necessary between inputs you provide and its output format, but it might be useful if trying to match your inputs to reduce conversion and resampling costs.
/// For mixers created with createMixerDevice(), this is the format of the audio device (and may change later if the device itself changes; SDL_mixer will seamlessly handle this change internally, though).
/// For mixers created with createMixer(), this is the format that Mixer.generate() will produce, as requested at create time, and does not change.
/// Note that internally, SDL_mixer will work in sdl.audio.Format.f32_ format before outputting the format specified here, so it would be more efficient to match input data to that, not the final output format.
///
/// - **Parameters:**
///   - `mixer`: the mixer to query.
///   - `spec`: where to store the mixer audio format.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getMixerFormat(mixer: ?Mixer, spec: ?*sdl.audio.Spec) sdl.Error!void {
    if (!c.MIX_GetMixerFormat(if (mixer) |resource| @ptrCast(resource.value) else null, @ptrCast(spec))) return error.SdlFailure;
}

/// Get a mixer's master frequency ratio.
///
/// This returns the last value set through Mixer.setFrequencyRatio(), or 1.0f if no value has ever been explicitly set.
///
/// - **Parameters:**
///   - `mixer`: the mixer to query.
///
/// - **Returns:** the mixer's current master frequency ratio.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.setFrequencyRatio
/// - **See also:** Track.getFrequencyRatio
pub inline fn getMixerFrequencyRatio(mixer: ?Mixer) f32 {
    return c.MIX_GetMixerFrequencyRatio(if (mixer) |resource| @ptrCast(resource.value) else null);
}

/// Get a mixer's master gain control.
///
/// This returns the last value set through Mixer.setGain(), or 1.0f if no value has ever been explicitly set.
///
/// - **Parameters:**
///   - `mixer`: the mixer to query.
///
/// - **Returns:** the mixer's current master gain.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.setGain
/// - **See also:** Track.getGain
pub inline fn getMixerGain(mixer: ?Mixer) f32 {
    return c.MIX_GetMixerGain(if (mixer) |resource| @ptrCast(resource.value) else null);
}

/// Get the properties associated with a mixer.
///
/// The following read-only properties are provided by SDL_mixer:
/// - `prop_mixer_device_number`: the sdl.audio.DeviceId that this mixer has opened for playback. This will be zero (no device) if the mixer was created with Mix_CreateMixer() instead of Mix_CreateMixerDevice().
///
/// - **Parameters:**
///   - `mixer`: the mixer to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getMixerProperties(mixer: ?Mixer) sdl.Error!sdl.properties.Id {
    const result = c.MIX_GetMixerProperties(if (mixer) |resource| @ptrCast(resource.value) else null);
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Report the number of audio decoders available for use.
///
/// An audio decoder is what turns specific audio file formats into usable PCM data. For example, there might be an MP3 decoder, or a WAV decoder, etc. SDL_mixer probably has several decoders built in.
/// The return value can be used to call getAudioDecoder() in a loop.
/// The number of decoders available is decided during init() and does not change until the library is deinitialized.
///
/// - **Returns:** the number of decoders available.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** getAudioDecoder
pub inline fn getNumAudioDecoders() c_int {
    return c.MIX_GetNumAudioDecoders();
}

/// Get all tracks with a specific tag.
///
/// Tracks are not provided in any guaranteed order.
///
/// - **Parameters:**
///   - `mixer`: the mixer to query.
///   - `tag`: the tag to search.
///
/// - **Returns:** an array of the tracks, NULL-terminated, or NULL on failure; call sdl.error_.get() for more information. The returned pointer should be freed with sdl.stdinc.free() when it is no longer needed.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getTaggedTracks(allocator_: std.mem.Allocator, mixer: ?Mixer, tag: ?[:0]const u8) sdl.Error![]Track {
    const Count = @typeInfo(@typeInfo(@TypeOf(c.MIX_GetTaggedTracks)).@"fn".params[2].type.?).pointer.child;
    var count: Count = 0;
    const result = c.MIX_GetTaggedTracks(if (mixer) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null, &count);
    if (result == null) return error.SdlFailure;
    defer c.SDL_free(@ptrCast(result));
    const length = std.math.cast(usize, count) orelse return error.SdlFailure;
    const copy = allocator_.alloc(Track, length) catch return error.OutOfMemory;
    errdefer allocator_.free(copy);
    for (copy, 0..) |*item, index| {
        const source = result[index];
        if (source == null) return error.SdlFailure;
        item.* = .{ .value = @ptrCast(source) };
    }
    return copy;
}

/// Get a track's current position in 3D space.
///
/// If 3D positioning isn't enabled for this track, through a call to Track.setTrack3dPosition(), this will return (0,0,0).
///
/// - **Parameters:**
///   - `track`: the track to query.
///   - `position`: on successful return, will contain the track's position.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setTrack3dPosition
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getTrack3dPosition(track: ?Track, position: ?*Point3d) sdl.Error!void {
    if (!c.MIX_GetTrack3DPosition(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(position))) return error.SdlFailure;
}

/// Query the Audio assigned to a track.
///
/// This returns the Audio object currently assigned to `track` through a call to Track.setAudio(). If there is none assigned, or the track has an input that isn't a Audio (such as an sdl.audio.Stream or sdl.ioStream.IoStream), this will return NULL.
/// On various errors (init() was not called, the track is NULL), this returns NULL, but there is no mechanism to distinguish errors from tracks without a valid input.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** a Audio if available, NULL if not.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getAudioStream
pub inline fn getTrackAudio(track: ?Track) ?Audio {
    const result = c.MIX_GetTrackAudio(if (track) |resource| @ptrCast(resource.value) else null);
    return if (result) |value| Audio{ .value = @ptrCast(value) } else null;
}

/// Query the sdl.audio.Stream assigned to a track.
///
/// This returns the sdl.audio.Stream object currently assigned to `track` through a call to Track.setAudioStream(). If there is none assigned, or the track has an input that isn't an sdl.audio.Stream (such as a Audio or sdl.ioStream.IoStream), this will return NULL.
/// On various errors (init() was not called, the track is NULL), this returns NULL, but there is no mechanism to distinguish errors from tracks without a valid input.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** an sdl.audio.Stream if available, NULL if not.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getAudio
pub inline fn getTrackAudioStream(track: ?Track) ?*sdl.audio.Stream {
    const result = c.MIX_GetTrackAudioStream(if (track) |resource| @ptrCast(resource.value) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Query whether a given track is fading.
///
/// This specifically checks if the track is *not stopped* (paused or playing), and it is fading in or out, and returns the number of frames remaining in the fade.
/// If fading out, the returned value will be negative. When fading in, the returned value will be positive. If not fading, this function returns zero.
/// On various errors (init() was not called, the track is NULL), this returns 0, but there is no mechanism to distinguish errors from tracks that aren't fading.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** less than 0 if the track is fading out, greater than 0 if fading in, zero otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getTrackFadeFrames(track: ?Track) i64 {
    return c.MIX_GetTrackFadeFrames(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Query the frequency ratio of a track.
///
/// The frequency ratio is used to adjust the rate at which audio data is consumed. Changing this effectively modifies the speed and pitch of the track's audio. A value greater than 1.0f will play the audio faster, and at a higher pitch. A value less than 1.0f will play the audio slower, and at a lower pitch. 1.0f is normal speed.
/// The default value is 1.0f.
/// On various errors (init() was not called, the track is NULL), this returns 0.0f. Since this is not a valid value to set, this can be seen as an error state.
///
/// - **Parameters:**
///   - `track`: the track on which to query the frequency ratio.
///
/// - **Returns:** the current frequency ratio, or 0.0f on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getFrequencyRatio
pub inline fn getTrackFrequencyRatio(track: ?Track) f32 {
    return c.MIX_GetTrackFrequencyRatio(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Get a track's gain control.
///
/// This returns the last value set through Track.setGain(), or 1.0f if no value has ever been explicitly set.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** the track's current gain.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setGain
/// - **See also:** Mixer.getGain
pub inline fn getTrackGain(track: ?Track) f32 {
    return c.MIX_GetTrackGain(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Query how many loops remain for a given track.
///
/// This returns the number of loops still pending; if a track will eventually complete and loop to play again one more time, this will return 1. If a track *was* looping but is on its final iteration of the loop (will stop when this iteration completes), this will return zero.
/// A track that is looping infinitely will return -1. This value does not report an error in this case.
/// A track that is stopped (not playing and not paused) will have zero loops remaining.
/// On various errors (init() was not called, the track is NULL), this returns zero, but there is no mechanism to distinguish errors from non-looping tracks.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** the number of pending loops, zero if not looping, and -1 if looping infinitely.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getTrackLoops(track: ?Track) c_int {
    return c.MIX_GetTrackLoops(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Get the Mixer that owns a Track.
///
/// This is the mixer pointer that was passed to createTrack().
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** the mixer associated with the track, or NULL on error; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getTrackMixer(track: ?Track) ?Mixer {
    const result = c.MIX_GetTrackMixer(if (track) |resource| @ptrCast(resource.value) else null);
    return if (result) |value| Mixer{ .value = @ptrCast(value) } else null;
}

/// Get the current input position of a playing track.
///
/// (Not to be confused with Track.getTrack3dPosition(), which is positioning of the track in 3D space, not the playback position of its audio data.)
/// Position is defined in *sample frames* of decoded audio, not units of time, so that sample-perfect mixing can be achieved. To instead operate in units of time, use Track.framesToMs() to convert the return value to milliseconds.
/// Stopped and paused tracks will report the position when they halted. Playing tracks will report the current position, which will change over time.
///
/// - **Parameters:**
///   - `track`: the track to change.
///
/// - **Returns:** the track's current sample frame position, or -1 on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setPlaybackPosition
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getTrackPlaybackPosition(track: ?Track) sdl.Error!i64 {
    const result = c.MIX_GetTrackPlaybackPosition(if (track) |resource| @ptrCast(resource.value) else null);
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Get the properties associated with a track.
///
/// Currently SDL_mixer assigns no properties of its own to a track, but this can be a convenient place to store app-specific data.
/// A sdl.properties.Id is created the first time this function is called for a given track.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** a valid property ID on success or 0 on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn getTrackProperties(track: ?Track) sdl.Error!sdl.properties.Id {
    const result = c.MIX_GetTrackProperties(if (track) |resource| @ptrCast(resource.value) else null);
    if (result == 0) return error.SdlFailure;
    return result;
}

/// Return the number of sample frames remaining to be mixed in a track.
///
/// If the track is playing or paused, and its total duration is known, this will report how much audio is left to mix. If the track is playing, future calls to this function will report different values.
/// Remaining audio is defined in *sample frames* of decoded audio, not units of time, so that sample-perfect mixing can be achieved. To instead operate in units of time, use Track.framesToMs() to convert the return value to milliseconds.
/// This function does not take into account fade-outs or looping, just the current mixing position vs the duration of the track.
/// If the duration of the track isn't known, or `track` is NULL, this function returns -1. A stopped track reports 0.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** the total sample frames still to be mixed, or -1 if unknown.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getTrackRemaining(track: ?Track) i64 {
    return c.MIX_GetTrackRemaining(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Get the tags currently associated with a track.
///
/// Tags are not provided in any guaranteed order.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** an array of the tags, NULL-terminated, or NULL on failure; call sdl.error_.get() for more information. The returned collection owns allocator-backed copies of every string; call `deinit` when finished.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
pub inline fn getTrackTags(allocator_: std.mem.Allocator, track: ?Track) sdl.Error!OwnedStrings {
    const Count = @typeInfo(@typeInfo(@TypeOf(c.MIX_GetTrackTags)).@"fn".params[1].type.?).pointer.child;
    var count: Count = 0;
    const result = c.MIX_GetTrackTags(if (track) |resource| @ptrCast(resource.value) else null, &count);
    if (result == null) return error.SdlFailure;
    defer c.SDL_free(@ptrCast(result));
    const length = std.math.cast(usize, count) orelse return error.SdlFailure;
    const items = allocator_.alloc([:0]u8, length) catch return error.OutOfMemory;
    var initialized: usize = 0;
    errdefer {
        for (items[0..initialized]) |item| allocator_.free(item);
        allocator_.free(items);
    }
    for (items, 0..) |*item, index| {
        const source = result[index];
        if (source == null) return error.SdlFailure;
        item.* = support.copyOwnedZString(allocator_, @ptrCast(source)) catch return error.OutOfMemory;
        initialized += 1;
    }
    return .{ .allocator = allocator_, .items = items };
}

/// Initialize the SDL_mixer library.
///
/// This must be successfully called once before (almost) any other SDL_mixer function can be used.
/// It is safe to call this multiple times; the library will only initialize once, and won't deinitialize until quit() has been called a matching number of times. Extra attempts to init report success.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** quit
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn init() sdl.Error!void {
    if (!c.MIX_Init()) return error.SdlFailure;
}

/// Load audio for playback from a file.
///
/// This is equivalent to calling:
/// ```c
/// MIX_LoadAudio_IO(mixer,SDL_IOFromFile(path,"rb"),predecode,true);
/// ```
///
/// This function loads data from a path on the filesystem. There is also a version that loads from an sdl.ioStream.IoStream (loadAudioIo()), and one that accepts properties for ultimate control (loadAudioWithProperties()).
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `path`: the path on the filesystem to load data from.
///   - `predecode`: if true, data will be fully uncompressed before returning.
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadAudioIo
/// - **See also:** loadAudioWithProperties
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadAudio(mixer: ?Mixer, path: ?[:0]const u8, predecode: bool) sdl.Error!Audio {
    const result = c.MIX_LoadAudio(if (mixer) |resource| @ptrCast(resource.value) else null, if (path != null) @ptrCast(path.?.ptr) else null, predecode);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Load audio for playback from an sdl.ioStream.IoStream.
///
/// In normal usage, apps should load audio once, maybe at startup, then play it multiple times.
/// When loading audio, it will be cached fully in RAM in its original data format. Each time it plays, the data will be decoded. For example, an MP3 will be stored in memory in MP3 format and be decompressed on the fly during playback. This is a tradeoff between i/o overhead and memory usage.
/// If `predecode` is true, the data will be decompressed during load and stored as raw PCM data. This might dramatically increase loading time and memory usage, but there will be no need to decompress data during playback.
/// (One could also use Track.setIoStream() to bypass loading the data into RAM upfront at all, but this offers still different tradeoffs. The correct approach depends on the app's needs and employing different approaches in different situations can make sense.)
/// Audio objects can be shared between mixers. This function takes a Mixer, to imply this is the most likely place it will be used and loading should try to match its audio format, but the resulting audio can be used elsewhere. If `mixer` is NULL, SDL_mixer will set reasonable defaults.
/// Once a Audio is created, it can be assigned to a Track with Track.setAudio(), or played without any management with Mixer.playAudio().
/// When done with a Audio, it can be freed with Audio.deinit().
/// This function loads data from an sdl.ioStream.IoStream. There is also a version that loads from a path on the filesystem (loadAudio()), and one that accepts properties for ultimate control (loadAudioWithProperties()).
/// The sdl.ioStream.IoStream provided must be able to seek, or loading will fail. If the stream can't seek (data is coming from an HTTP connection, etc), consider caching the data to memory or disk first and creating a new stream to read from there.
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `io`: the sdl.ioStream.IoStream to load data from.
///   - `predecode`: if true, data will be fully uncompressed before returning.
///   - `closeio`: true if SDL_mixer should close `io` before returning (success or failure).
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadAudio
/// - **See also:** loadAudioWithProperties
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadAudioIo(mixer: ?Mixer, io: ?*sdl.ioStream.IoStream, predecode: bool, closeio: bool) sdl.Error!Audio {
    const result = c.MIX_LoadAudio_IO(if (mixer) |resource| @ptrCast(resource.value) else null, if (io) |resource| @ptrCast(resource.value) else null, predecode, closeio);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Load audio for playback from a memory buffer without making a copy.
///
/// When loading audio through most other LoadAudio functions, the data will be cached fully in RAM in its original data format, for decoding on-demand. This function does most of the same work as those functions, but instead uses a buffer of memory provided by the app that it does not make a copy of.
/// This buffer must live for the entire time the returned Audio lives, as the mixer will access the buffer whenever it needs to mix more data.
/// This function is meant to maximize efficiency: if the data is already in memory and can remain there, don't copy it. This data can be in any supported audio file format (WAV, MP3, etc); it will be decoded on the fly while mixing. Unlike loadAudio(), there is no `predecode` option offered here, as this is meant to optimize for data that's already in memory and intends to exist there for significant time; since predecoding would only need the file format data once, upfront, one could simply wrap it in SDL_CreateIOFromConstMem (C API outside this module)() and pass that to loadAudioIo().
/// Audio objects can be shared between multiple mixers. The `mixer` parameter just suggests the most likely mixer to use this audio, in case some optimization might be applied, but this is not required, and a NULL mixer may be specified.
/// If `free_when_done` is true, SDL_mixer will call `sdl.stdinc.free(data)` when the returned Audio is eventually destroyed. This can be useful when the data is not static, but rather loaded elsewhere for this specific Audio and simply wants to avoid the extra copy.
/// As audio format information is obtained from the file format metadata, this isn't useful for raw PCM data; in that case, use loadRawAudioNoCopy() instead, which offers an sdl.audio.Spec.
/// Once a Audio is created, it can be assigned to a Track with Track.setAudio(), or played without any management with Mixer.playAudio().
/// When done with a Audio, it can be freed with Audio.deinit().
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `data`: the buffer where the audio data lives.
///   - `free_when_done`: if true, `data` will be given to sdl.stdinc.free() when the Audio is destroyed.
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadRawAudioNoCopy
/// - **See also:** loadAudioIo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadAudioNoCopy(mixer: ?Mixer, data: []const u8, free_when_done: bool) sdl.Error!Audio {
    const result = c.MIX_LoadAudioNoCopy(if (mixer) |resource| @ptrCast(resource.value) else null, @ptrCast(data.ptr), @intCast(data.len), free_when_done);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Load audio for playback through a collection of properties.
///
/// Please see loadAudioIo() for a description of what the various LoadAudio functions do. This function uses properties to dictate how it operates, and exposes functionality the other functions don't provide.
/// sdl.properties.Id are discussed in [SDL's documentation](https://wiki.libsdl.org/SDL3/CategoryProperties)These are the supported properties:
/// - `prop_audio_load_io_stream_pointer`: a pointer to an sdl.ioStream.IoStream to be used to load audio data. Required. This stream must be able to seek!
/// - `prop_audio_load_closeio_boolean`: true if SDL_mixer should close the sdl.ioStream.IoStream before returning (success or failure).
/// - `prop_audio_load_predecode_boolean`: true if SDL_mixer should fully decode and decompress the data before returning. Otherwise it will be stored in its original state and decompressed on demand.
/// - `prop_audio_load_preferred_mixer_pointer`: a pointer to a Mixer, in case steps can be made to match its format when decoding. Optional.
/// - `prop_audio_load_skip_metadata_tags_boolean`: true to skip parsing metadata tags, like ID3 and APE tags. This can be used to speed up loading *if the data definitely doesn't have these tags*. Some decoders will fail if these tags are present when this property is true.
/// - `prop_audio_load_ignore_loops_boolean`: true to ignore metadata in the audio data specifying loop points. This will make a file decode from start to finish without looping, even if the file specified it should have. This audio can still be looped at playback time via Track loop settings, regardless of this setting. Default false.
/// - `prop_audio_decoder_string`: the name of the decoder to use for this data. Optional. If not specified, SDL_mixer will examine the data and choose the best decoder. These names are the same returned from getAudioDecoder().
/// Specific decoders might accept additional custom properties, such as where to find soundfonts for MIDI playback, etc.
///
/// - **Parameters:**
///   - `props`: a set of properties on how to load audio.
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadAudio
/// - **See also:** loadAudioIo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadAudioWithProperties(props: sdl.properties.Id) sdl.Error!Audio {
    const result = c.MIX_LoadAudioWithProperties(props);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Load raw PCM data from a memory buffer.
///
/// There are other options for *streaming* raw PCM: an sdl.audio.Stream can be connected to a track, as can an sdl.ioStream.IoStream, and will read from those sources on-demand when it is time to mix the audio. This function is useful for loading static audio data that is meant to be played multiple times.
/// This function will load the raw data in its entirety and cache it in RAM, allocating a copy. If the original data will outlive the created Audio, you can use loadRawAudioNoCopy() to avoid extra allocations and copies.
/// Audio objects can be shared between multiple mixers. The `mixer` parameter just suggests the most likely mixer to use this audio, in case some optimization might be applied, but this is not required, and a NULL mixer may be specified.
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `data`: the raw PCM data to load.
///   - `spec`: what format the raw data is in.
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadRawAudioIo
/// - **See also:** loadRawAudioNoCopy
/// - **See also:** loadAudioIo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadRawAudio(mixer: ?Mixer, data: []const u8, spec: ?*const sdl.audio.Spec) sdl.Error!Audio {
    const result = c.MIX_LoadRawAudio(if (mixer) |resource| @ptrCast(resource.value) else null, @ptrCast(data.ptr), @intCast(data.len), @ptrCast(spec));
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Load raw PCM data from an sdl.ioStream.IoStream.
///
/// There are other options for *streaming* raw PCM: an sdl.audio.Stream can be connected to a track, as can an sdl.ioStream.IoStream, and will read from those sources on-demand when it is time to mix the audio. This function is useful for loading static audio data that is meant to be played multiple times.
/// This function will load the raw data in its entirety and cache it in RAM.
/// Audio objects can be shared between multiple mixers. The `mixer` parameter just suggests the most likely mixer to use this audio, in case some optimization might be applied, but this is not required, and a NULL mixer may be specified.
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `io`: the sdl.ioStream.IoStream to load data from.
///   - `spec`: what format the raw data is in.
///   - `closeio`: true if SDL_mixer should close `io` before returning (success or failure).
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadRawAudio
/// - **See also:** loadRawAudioNoCopy
/// - **See also:** loadAudioIo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadRawAudioIo(mixer: ?Mixer, io: ?*sdl.ioStream.IoStream, spec: ?*const sdl.audio.Spec, closeio: bool) sdl.Error!Audio {
    const result = c.MIX_LoadRawAudio_IO(if (mixer) |resource| @ptrCast(resource.value) else null, if (io) |resource| @ptrCast(resource.value) else null, @ptrCast(spec), closeio);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Load raw PCM data from a memory buffer without making a copy.
///
/// This buffer must live for the entire time the returned Audio lives, as the mixer will access the buffer whenever it needs to mix more data.
/// This function is meant to maximize efficiency: if the data is already in memory and can remain there, don't copy it. But it can also lead to some interesting tricks, like changing the buffer's contents to alter multiple playing tracks at once. (But, of course, be careful when being too clever.)
/// Audio objects can be shared between multiple mixers. The `mixer` parameter just suggests the most likely mixer to use this audio, in case some optimization might be applied, but this is not required, and a NULL mixer may be specified.
/// If `free_when_done` is true, SDL_mixer will call `sdl.stdinc.free(data)` when the returned Audio is eventually destroyed. This can be useful when the data is not static, but rather composed dynamically for this specific Audio and simply wants to avoid the extra copy.
///
/// - **Parameters:**
///   - `mixer`: a mixer this audio is intended to be used with. May be NULL.
///   - `data`: the buffer where the raw PCM data lives.
///   - `spec`: what format the raw data is in.
///   - `free_when_done`: if true, `data` will be given to sdl.stdinc.free() when the Audio is destroyed.
///
/// - **Returns:** an audio object that can be used to make sound on a mixer, or NULL on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Audio.deinit
/// - **See also:** Track.setAudio
/// - **See also:** loadRawAudio
/// - **See also:** loadRawAudioIo
/// - **See also:** loadAudioIo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn loadRawAudioNoCopy(mixer: ?Mixer, data: []const u8, spec: ?*const sdl.audio.Spec, free_when_done: bool) sdl.Error!Audio {
    const result = c.MIX_LoadRawAudioNoCopy(if (mixer) |resource| @ptrCast(resource.value) else null, @ptrCast(data.ptr), @intCast(data.len), @ptrCast(spec), free_when_done);
    if (result == null) return error.SdlFailure;
    return Audio{ .value = @ptrCast(result.?) };
}

/// Lock a mixer by obtaining its internal mutex.
///
/// While locked, the mixer will not be able to mix more audio or change its internal state in another thread. Those other threads will block until the mixer is unlocked again.
/// Under the hood, this function calls sdl.mutex.Mutex.lock(), so all the same rules apply: the lock can be recursive, it must be unlocked the same number of times from the same thread that locked it, etc.
/// Just about every SDL_mixer API *also* locks the mixer while doing its work, as does the SDL audio device thread while actual mixing is in progress, so basic use of this library never requires the app to explicitly lock the device to be thread safe. There are two scenarios where this can be useful, however:
/// - The app has a provided a callback that the mixing thread might call, and there is some app state that needs to be protected against race conditions as changes are made and mixing progresses simultaneously. Any lock can be used for this, but this is a conveniently-available lock.
/// - The app wants to make multiple, atomic changes to the mix. For example, to start several tracks at the exact same moment, one would lock the mixer, call Track.play multiple times, and then unlock again; all the tracks will start mixing on the same sample frame.
/// Each call to this function must be paired with a call to Mixer.unlock from the same thread. It is safe to lock a mixer multiple times; it remains locked until the final matching unlock call.
/// Do not lock the mixer for significant amounts of time, or it can cause audio dropouts. Just do simple things quickly and unlock again.
/// Locking a NULL mixer is a safe no-op.
///
/// - **Parameters:**
///   - `mixer`: the mixer to lock. May be NULL.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.unlock
pub inline fn lockMixer(mixer: ?Mixer) void {
    c.MIX_LockMixer(if (mixer) |resource| @ptrCast(resource.value) else null);
}

/// Convert milliseconds to sample frames at a specific sample rate.
///
/// If `sample_rate` is <= 0, this returns -1. If `ms` is < 0, this returns -1.
///
/// - **Parameters:**
///   - `sample_rate`: the sample rate to use for conversion.
///   - `ms`: the milliseconds to convert to rate-specific sample frames.
///
/// - **Returns:** Converted number of sample frames, or -1 for errors; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** framesToMs
pub inline fn msToFrames(sample_rate: c_int, ms: i64) i64 {
    return c.MIX_MSToFrames(sample_rate, ms);
}

/// Pause all currently-playing tracks.
///
/// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
/// This function makes all tracks on the specified mixer that are currently playing move to a paused state. They can later be resumed.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to pause all tracks.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.resume_
/// - **See also:** Mixer.resumeAllTracks
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn pauseAllTracks(mixer: ?Mixer) sdl.Error!void {
    if (!c.MIX_PauseAllTracks(if (mixer) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Pause all tracks with a specific tag.
///
/// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
/// This function makes all currently-playing tracks on the specified mixer, with a specific tag, move to a paused state. They can later be resumed.
/// Tracks that match the specified tag that aren't currently playing are ignored.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to pause tracks.
///   - `tag`: the tag to use when searching for tracks.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.pause
/// - **See also:** Track.resume_
/// - **See also:** Mixer.resumeTag
/// - **See also:** Track.tag
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn pauseTag(mixer: ?Mixer, tag: ?[:0]const u8) sdl.Error!void {
    if (!c.MIX_PauseTag(if (mixer) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null)) return error.SdlFailure;
}

/// Pause a currently-playing track.
///
/// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
/// It is legal to pause a track that's in any state (playing, already paused, or stopped). Unless the track is currently playing, pausing does nothing, and returns true. A false return is only used to signal errors here (such as init not being called or `track` being NULL).
///
/// - **Parameters:**
///   - `track`: the track to pause.
///
/// - **Returns:** true if the track has paused, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.resume_
pub inline fn pauseTrack(track: ?Track) bool {
    return c.MIX_PauseTrack(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Play a Audio from start to finish without any management.
///
/// This is what we term a "fire-and-forget" sound. Internally, SDL_mixer will manage a temporary track to mix the specified Audio, cleaning it up when complete. No options can be provided for how to do the mixing, like Track.play() offers, and since the track is not available to the caller, no adjustments can be made to mixing over time.
/// This is not the function to build an entire game of any complexity around, but it can be convenient to play simple, one-off sounds that can't be stopped early. An example would be a voice saying "GAME OVER" during an unpausable endgame sequence.
/// There are no limits to the number of fire-and-forget sounds that can mix at once (short of running out of memory), and SDL_mixer keeps an internal pool of temporary tracks it creates as needed and reuses when available.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to play this audio.
///   - `audio`: the audio input to play.
///
/// - **Returns:** true if the track has begun mixing, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.play
/// - **See also:** loadAudio
pub inline fn playAudio(mixer: ?Mixer, audio: ?Audio) bool {
    return c.MIX_PlayAudio(if (mixer) |resource| @ptrCast(resource.value) else null, if (audio) |resource| @ptrCast(resource.value) else null);
}

/// Start (or restart) mixing all tracks with a specific tag for playback.
///
/// This function follows all the same rules as Track.play(); please refer to its documentation for the details. Unlike that function, Mixer.playTag() operates on multiple tracks at once that have the specified tag applied, via Track.tag().
/// If all of your tagged tracks have different sample rates, it would make sense to use the `*_MILLISECONDS_NUMBER` properties in your `options`, instead of `*_FRAMES_NUMBER`, and let SDL_mixer figure out how to apply it to each track.
/// This function returns true if all tagged tracks are started (or restarted). If any track fails, this function returns false, but all tracks that could start will still be started even when this function reports failure.
/// From the point of view of the mixing process, all tracks that successfully (re)start will do so at the exact same moment.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to look for tagged tracks.
///   - `tag`: the tag to use when searching for tracks.
///   - `options`: the set of options that will be applied to each track.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.play
/// - **See also:** Track.tag
/// - **See also:** Track.stop
/// - **See also:** Track.pause
/// - **See also:** Track.playing
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn playTag(mixer: ?Mixer, tag: ?[:0]const u8, options: sdl.properties.Id) sdl.Error!void {
    if (!c.MIX_PlayTag(if (mixer) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null, options)) return error.SdlFailure;
}

/// Start (or restart) mixing a track for playback.
///
/// The track will use whatever input was last assigned to it when playing; an input must be assigned to this track or this function will fail. Inputs are assigned with calls to Track.setAudio(), Track.setAudioStream(), or Track.setIoStream().
/// If the track is already playing, or paused, this will restart the track with the newly-specified parameters.
/// As there are several parameters, and more may be added in the future, they are specified with an sdl.properties.Id. The parameters have reasonable defaults, and specifying a 0 for `options` will choose defaults for everything.
/// sdl.properties.Id are discussed in [SDL's documentation](https://wiki.libsdl.org/SDL3/CategoryProperties) These are the supported properties:
/// - `prop_play_loops_number`: The number of times to loop the track when it reaches the end. A value of 1 will loop to the start one time. Zero will not loop at all. A value of -1 requests infinite loops. If the input is not seekable and this value isn't zero, this function will report success but the track will stop at the point it should loop. Default 0.
/// - `prop_play_max_frame_number`: Mix at most to this sample frame position in the track. This will be treated as if the input reach EOF at this point in the audio file. If -1, mix all available audio without a limit. Default -1.
/// - `prop_play_max_milliseconds_number`: The same as using the prop_play_max_frame_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default -1.
/// - `prop_play_start_frame_number`: Start mixing from this sample frame position in the track's input. A value <= 0 will begin from the start of the track's input. If the input is not seekable and this value is > 0, this function will report failure. Default 0.
/// - `prop_play_start_millisecond_number`: The same as using the prop_play_start_frame_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
/// - `prop_play_loop_start_frame_number`: If the track is looping, this is the sample frame position that the track will loop back to; this lets one play an intro at the start of a track on the first iteration, but have a loop point somewhere in the middle thereafter. A value <= 0 will begin the loop from the start of the track's input. Default 0.
/// - `prop_play_loop_start_millisecond_number`: The same as using the prop_play_loop_start_frame_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
/// - `prop_play_fade_in_frames_number`: The number of sample frames over which to fade in the newly-started track. The track will begin mixing silence and reach full volume smoothly over this many sample frames. If the track loops before the fade-in is complete, it will continue to fade correctly from the loop point. A value <= 0 will disable fade-in, so the track starts mixing at full volume. Default 0.
/// - `prop_play_fade_in_milliseconds_number`: The same as using the prop_play_fade_in_frames_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
/// - `prop_play_fade_in_start_gain_float`: If fading in, start fading from this volume level. 0.0f is silence and 1.0f is full volume, every in between is a linear change in gain. The specified value will be clamped between 0.0f and 1.0f. Default 0.0f.
/// - `prop_play_app_end_silence_frames_number`: At the end of mixing this track, after all loops are complete, append this many sample frames of silence as if it were part of the audio file. This allows for apps to implement effects in callbacks, like reverb, that need to generate samples past the end of the stream's audio, or perhaps introduce a delay before starting a new sound on the track without having to manage it directly. A value <= 0 generates no silence before stopping the track. Default 0.
/// - `prop_play_app_end_silence_milliseconds_number`: The same as using the prop_play_app_end_silence_frames_number property, but the value is specified in milliseconds instead of sample frames. If both properties are specified, the sample frames value is favored. Default 0.
/// - `prop_play_halt_when_exhausted_boolean`: If true, when input is completely consumed for the track, the mixer will mark the track as stopped (and call any appropriate TrackStoppedCallback, etc); to play more, the track will need to be restarted. If false, the track will just not contribute to the mix, but it will not be marked as stopped. There may be clever logic tricks this exposes generally, but this property is specifically useful when the track's input is an sdl.audio.Stream assigned via Track.setAudioStream(). Setting this property to true can be useful when pushing a complete piece of audio to the stream that has a definite ending, as the track will operate like any other audio was applied. Setting to false means as new data is added to the stream, the mixer will start using it as soon as possible, which is useful when audio should play immediately as it drips in: new VoIP packets, etc. Note that in this situation, if the audio runs out when needed, there *will* be gaps in the mixed output, so try to buffer enough data to avoid this when possible. Note that a track is not consider exhausted until all its loops and appended silence have been mixed (and also, that loops don't mean anything when the input is an AudioStream). Default true.
/// - `prop_play_start_order_number`: This is a special-case property that most apps can ignore. For mod file formats, start mixing from a specific "order" index instead of the start of the file. A value < 0 will cause this property to be ignored. If the decoder doesn't support this property, it will also be ignored. If this property is *not* ignored, the prop_play_start_frame_number and prop_play_start_millisecond_number properties will be ignored instead. Default -1. Since SDL_mixer 3.2.2.
/// If this function fails, mixing of this track will not start (or restart, if it was already started).
///
/// - **Parameters:**
///   - `track`: the track to start (or restart) mixing.
///   - `options`: a set of properties that control playback. May be zero.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.playTag
/// - **See also:** Mixer.playAudio
/// - **See also:** Track.stop
/// - **See also:** Track.pause
/// - **See also:** Track.playing
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn playTrack(track: ?Track, options: sdl.properties.Id) sdl.Error!void {
    if (!c.MIX_PlayTrack(if (track) |resource| @ptrCast(resource.value) else null, options)) return error.SdlFailure;
}

/// Deinitialize the SDL_mixer library.
///
/// This must be called when done with the library, probably at the end of your program.
/// It is safe to call this multiple times; the library will only deinitialize once, when this function is called the same number of times as init was successfully called.
/// Once you have successfully deinitialized the library, it is safe to call init to reinitialize it for further use.
/// On successful deinitialization, SDL_mixer will destroy almost all created objects, including objects of type:
/// - Mixer
/// - Track
/// - Audio
/// - Group
/// - AudioDecoder
/// ...which is to say: it's possible a single call to this function will clean up anything it allocated, stop all audio output, close audio devices, etc. Don't attempt to destroy objects after this call. The app is still encouraged to manage their resources carefully and clean up first, treating this function as a safety net against memory leaks.
///
/// - **Thread safety:** This function is not thread safe.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** init
pub inline fn quit() void {
    c.MIX_Quit();
}

/// Resume all currently-paused tracks.
///
/// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
/// This function makes all tracks on the specified mixer that are currently paused move to a playing state.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to resume all tracks.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.pause
/// - **See also:** Mixer.pauseAllTracks
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn resumeAllTracks(mixer: ?Mixer) sdl.Error!void {
    if (!c.MIX_ResumeAllTracks(if (mixer) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Resume all tracks with a specific tag.
///
/// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
/// This function makes all currently-paused tracks on the specified mixer, with a specific tag, move to a playing state.
/// Tracks that match the specified tag that aren't currently paused are ignored.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to resume tracks.
///   - `tag`: the tag to use when searching for tracks.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.resume_
/// - **See also:** Track.pause
/// - **See also:** Mixer.pauseTag
/// - **See also:** Track.tag
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn resumeTag(mixer: ?Mixer, tag: ?[:0]const u8) sdl.Error!void {
    if (!c.MIX_ResumeTag(if (mixer) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null)) return error.SdlFailure;
}

/// Resume a currently-paused track.
///
/// A paused track is not considered "stopped," so its TrackStoppedCallback will not fire if paused, but it won't change state by default, generate audio, or generally make progress, until it is resumed.
/// It is legal to resume a track that's in any state (playing, paused, or stopped). Unless the track is currently paused, resuming does nothing, and returns true. A false return is only used to signal errors here (such as init not being called or `track` being NULL).
///
/// - **Parameters:**
///   - `track`: the track to resume.
///
/// - **Returns:** true if the track has resumed, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.pause
pub inline fn resumeTrack(track: ?Track) bool {
    return c.MIX_ResumeTrack(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Set a callback that fires when a mixer group has completed mixing.
///
/// After all playing tracks in a mixer group have pulled in more data from their inputs, transformed it, and mixed together into a single buffer, a callback can be fired. This lets an app view the data at the last moment that it is still a part of this group. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data came directly from the group's mix buffer.
/// Each group has its own unique callback. Tracks that aren't in an explicit Group are mixed in an internal grouping that is not available to the app.
/// Passing a NULL callback here is legal; it disables this group's callback.
///
/// - **Parameters:**
///   - `group`: the mixing group to assign this callback to.
///   - `cb`: the function to call when the group mixes. May be NULL.
///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** GroupMixCallback
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setGroupPostMixCallback(group: ?Group, cb: GroupMixCallback, userdata: ?*anyopaque) sdl.Error!void {
    if (!c.MIX_SetGroupPostMixCallback(if (group) |resource| @ptrCast(resource.value) else null, @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
}

/// Set a mixer's master frequency ratio.
///
/// Each mixer has a master frequency ratio, that affects the entire mix. This can cause the final output to change speed and pitch. A value greater than 1.0f will play the audio faster, and at a higher pitch. A value less than 1.0f will play the audio slower, and at a lower pitch. 1.0f is normal speed.
/// Each track *also* has a frequency ratio; it will be applied when mixing that track's audio regardless of the master setting. The master setting affects the final output after all mixing has been completed.
/// A mixer's master frequency ratio defaults to 1.0f.
/// This value can be changed at any time to adjust the future mix.
///
/// - **Parameters:**
///   - `mixer`: the mixer to adjust.
///   - `ratio`: the frequency ratio. Must be between 0.01f and 100.0f.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.getFrequencyRatio
/// - **See also:** Track.setFrequencyRatio
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setMixerFrequencyRatio(mixer: ?Mixer, ratio: f32) sdl.Error!void {
    if (!c.MIX_SetMixerFrequencyRatio(if (mixer) |resource| @ptrCast(resource.value) else null, ratio)) return error.SdlFailure;
}

/// Set a mixer's master gain control.
///
/// Each mixer has a master gain, to adjust the volume of the entire mix. Each sample passing through the pipeline is modulated by this gain value. A gain of zero will generate silence, 1.0f will not change the mixed volume, and larger than 1.0f will increase the volume. Negative values are illegal. There is no maximum gain specified, but this can quickly get extremely loud, so please be careful with this setting.
/// A mixer's master gain defaults to 1.0f.
/// This value can be changed at any time to adjust the future mix.
///
/// - **Parameters:**
///   - `mixer`: the mixer to adjust.
///   - `gain`: the new gain value.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.getGain
/// - **See also:** Track.setGain
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setMixerGain(mixer: ?Mixer, gain: f32) sdl.Error!void {
    if (!c.MIX_SetMixerGain(if (mixer) |resource| @ptrCast(resource.value) else null, gain)) return error.SdlFailure;
}

/// Set a callback that fires when all mixing has completed.
///
/// After all mixer groups have processed, their buffers are mixed together into a single buffer for the final output, at which point a callback can be fired. This lets an app view the data at the last moment before mixing completes. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data is the final output.
/// Each mixer has its own unique callback.
/// Passing a NULL callback here is legal; it disables this mixer's callback.
///
/// - **Parameters:**
///   - `mixer`: the mixer to assign this callback to.
///   - `cb`: the function to call when the mixer mixes. May be NULL.
///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** PostMixCallback
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setPostMixCallback(mixer: ?Mixer, cb: PostMixCallback, userdata: ?*anyopaque) sdl.Error!void {
    if (!c.MIX_SetPostMixCallback(if (mixer) |resource| @ptrCast(resource.value) else null, @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
}

/// Set the gain control of all tracks with a specific tag.
///
/// Each track has its own gain, to adjust its overall volume. Each sample from this track is modulated by this gain value. A gain of zero will generate silence, 1.0f will not change the mixed volume, and larger than 1.0f will increase the volume. Negative values are illegal. There is no maximum gain specified, but this can quickly get extremely loud, so please be careful with this setting.
/// A track's gain defaults to 1.0f.
/// This will change the gain control on tracks on the specified mixer that have the specified tag.
/// From the point of view of the mixing process, all tracks that successfully change gain values will do so at the exact same moment.
/// This value can be changed at any time to adjust the future mix.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to look for tagged tracks.
///   - `tag`: the tag to use when searching for tracks.
///   - `gain`: the new gain value.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getGain
/// - **See also:** Track.setGain
/// - **See also:** Mixer.setGain
/// - **See also:** Track.tag
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTagGain(mixer: ?Mixer, tag: ?[:0]const u8, gain: f32) sdl.Error!void {
    if (!c.MIX_SetTagGain(if (mixer) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null, gain)) return error.SdlFailure;
}

/// Set a track's position in 3D space.
///
/// (Please note that SDL_mixer is not intended to be a extremely powerful 3D API. It lacks 3D features that other APIs like OpenAL offer: there's no doppler effect, distance models, rolloff, etc. This is meant to be Good Enough for games that can use some positional sounds and can even take advantage of surround-sound configurations.)
/// If `position` is not NULL, this track will be switched into 3D positional mode. If `position` is NULL, this will disable positional mixing (both the full 3D spatialization of this function and forced-stereo mode of Track.setStereo()).
/// In 3D positional mode, SDL_mixer will mix this track as if it were positioned in 3D space, including distance attenuation (quieter as it gets further from the listener) and spatialization (positioned on the correct speakers to suggest direction, either with stereo outputs or full surround sound).
/// For a mono speaker output, spatialization is effectively disabled but distance attenuation will still work, which is all you can really do with a single speaker.
/// The coordinate system operates like OpenGL or OpenAL: a "right-handed" coordinate system. See Point3d for the details.
/// The listener is always at coordinate (0,0,0) and can't be changed.
/// The track's input will be converted to mono (1 channel) so it can be rendered across the correct speakers.
///
/// - **Parameters:**
///   - `track`: the track for which to set 3D position.
///   - `position`: the new 3D position for the track. May be NULL.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getTrack3dPosition
/// - **See also:** Track.setStereo
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrack3dPosition(track: ?Track, position: ?*const Point3d) sdl.Error!void {
    if (!c.MIX_SetTrack3DPosition(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(position))) return error.SdlFailure;
}

/// Set a MIX_Track's input to a Audio.
///
/// A Audio is audio data stored in RAM (possibly still in a compressed form). One Audio can be assigned to multiple tracks at once.
/// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
/// Calling this function with a NULL audio input is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
/// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
/// The track will hold a reference to the provided Audio, so it is safe to call Audio.deinit() on it while the track is still using it. The track will drop its reference (and possibly free the resources) once it is no longer using the Audio.
///
/// - **Parameters:**
///   - `track`: the track on which to set a new audio input.
///   - `audio`: the new audio input to set. May be NULL.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackAudio(track: ?Track, audio: ?Audio) sdl.Error!void {
    if (!c.MIX_SetTrackAudio(if (track) |resource| @ptrCast(resource.value) else null, if (audio) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Set a MIX_Track's input to an sdl.audio.Stream.
///
/// Using an audio stream allows the application to generate any type of audio, in any format, possibly procedurally or on-demand, and mix in with all other tracks.
/// When a track uses an audio stream, it will call sdl.audio.Stream.getData as it needs more audio to mix. The app can either buffer data to the stream ahead of time, or set a callback on the stream to provide data as needed. Please refer to SDL's documentation for details.
/// A given audio stream may only be assigned to a single track at a time; duplicate assignments won't return an error, but assigning a stream to multiple tracks will cause each track to read from the stream arbitrarily, causing confusion and incorrect mixing.
/// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
/// Calling this function with a NULL audio stream is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
/// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
/// The provided audio stream must remain valid until the track no longer needs it (either by changing the track's input or destroying the track).
///
/// - **Parameters:**
///   - `track`: the track on which to set a new audio input.
///   - `stream`: the audio stream to use as the track's input.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackAudioStream(track: ?Track, stream: ?*sdl.audio.Stream) sdl.Error!void {
    if (!c.MIX_SetTrackAudioStream(if (track) |resource| @ptrCast(resource.value) else null, if (stream) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Set a callback that fires when the mixer has transformed a track's audio.
///
/// As a track needs to mix more data, it pulls from its input (a Audio, an sdl.audio.Stream, etc). This input might be a compressed file format, like MP3, so a little more data is uncompressed from it.
/// Once the track has PCM data to start operating on, and its raw callback has completed, it will begin to transform the audio: gain, fading, frequency ratio, 3D positioning, etc.
/// A callback can be fired after all these transformations, but before the transformed data is mixed into other tracks. This lets an app view the data at the last moment that it is still a part of this track. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data came directly from the input.
/// Each track has its own unique cooked callback.
/// Passing a NULL callback here is legal; it disables this track's callback.
///
/// - **Parameters:**
///   - `track`: the track to assign this callback to.
///   - `cb`: the function to call when the track mixes. May be NULL.
///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** TrackMixCallback
/// - **See also:** Track.setRawCallback
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackCookedCallback(track: ?Track, cb: TrackMixCallback, userdata: ?*anyopaque) sdl.Error!void {
    if (!c.MIX_SetTrackCookedCallback(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
}

/// Change the frequency ratio of a track.
///
/// The frequency ratio is used to adjust the rate at which audio data is consumed. Changing this effectively modifies the speed and pitch of the track's audio. A value greater than 1.0f will play the audio faster, and at a higher pitch. A value less than 1.0f will play the audio slower, and at a lower pitch. 1.0f is normal speed.
/// The default value is 1.0f.
/// This value can be changed at any time to adjust the future mix.
///
/// - **Parameters:**
///   - `track`: the track on which to change the frequency ratio.
///   - `ratio`: the frequency ratio. Must be between 0.01f and 100.0f.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getFrequencyRatio
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackFrequencyRatio(track: ?Track, ratio: f32) sdl.Error!void {
    if (!c.MIX_SetTrackFrequencyRatio(if (track) |resource| @ptrCast(resource.value) else null, ratio)) return error.SdlFailure;
}

/// Set a track's gain control.
///
/// Each track has its own gain, to adjust its overall volume. Each sample from this track is modulated by this gain value. A gain of zero will generate silence, 1.0f will not change the mixed volume, and larger than 1.0f will increase the volume. Negative values are illegal. There is no maximum gain specified, but this can quickly get extremely loud, so please be careful with this setting.
/// A track's gain defaults to 1.0f.
/// This value can be changed at any time to adjust the future mix.
///
/// - **Parameters:**
///   - `track`: the track to adjust.
///   - `gain`: the new gain value.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getGain
/// - **See also:** Mixer.setGain
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackGain(track: ?Track, gain: f32) sdl.Error!void {
    if (!c.MIX_SetTrackGain(if (track) |resource| @ptrCast(resource.value) else null, gain)) return error.SdlFailure;
}

/// Assign a track to a mixing group.
///
/// All tracks in a group are mixed together, and that output is made available to the app before it is mixed into the final output.
/// Tracks can only be in one group at a time, and the track and group must have been created on the same Mixer.
/// Setting a track to a NULL group will remove it from any app-created groups, and reassign it to the mixer's internal default group.
///
/// - **Parameters:**
///   - `track`: the track to set mixing group assignment.
///   - `group`: the new mixing group to assign to. May be NULL.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** createGroup
/// - **See also:** Group.setPostMixCallback
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackGroup(track: ?Track, group: ?Group) sdl.Error!void {
    if (!c.MIX_SetTrackGroup(if (track) |resource| @ptrCast(resource.value) else null, if (group) |resource| @ptrCast(resource.value) else null)) return error.SdlFailure;
}

/// Set a MIX_Track's input to an sdl.ioStream.IoStream.
///
/// This is not the recommended way to set a track's input, but this can be useful for a very specific scenario: a large file, to be played once, that must be read from disk in small chunks as needed. In most cases, however, it is preferable to create a Audio ahead of time and use Track.setAudio() instead.
/// The stream supplied here should provide an audio file in a supported format. SDL_mixer will parse it during this call to make sure it's valid, and then will read file data from the stream as it needs to decode more during mixing.
/// The stream must be able to seek through the complete set of data, or this function will fail.
/// A given IOStream may only be assigned to a single track at a time; duplicate assignments won't return an error, but assigning a stream to multiple tracks will cause each track to read from the stream arbitrarily, causing confusion, incorrect mixing, or failure to decode.
/// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
/// Calling this function with a NULL stream is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
/// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
/// The provided stream must remain valid until the track no longer needs it (either by changing the track's input or destroying the track).
///
/// - **Parameters:**
///   - `track`: the track on which to set a new audio input.
///   - `io`: the new i/o stream to use as the track's input.
///   - `closeio`: if true, close the stream when done with it.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setRawIoStream
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackIoStream(track: ?Track, io: ?*sdl.ioStream.IoStream, closeio: bool) sdl.Error!void {
    if (!c.MIX_SetTrackIOStream(if (track) |resource| @ptrCast(resource.value) else null, if (io) |resource| @ptrCast(resource.value) else null, closeio)) return error.SdlFailure;
}

/// Change the number of times a currently-playing track will loop.
///
/// This replaces any previously-set remaining loops. A value of 1 will loop to the start of playback one time. Zero will not loop at all. A value of -1 requests infinite loops. If the input is not seekable and `num_loops` isn't zero, this function will report success but the track will stop at the point it should loop.
/// The new loop count replaces any previous state, even if the track has already looped.
/// This has no effect on a track that is stopped, or rather, starting a stopped track later will set a new loop count, replacing this value. Stopped tracks can specify a loop count while starting via prop_play_loops_number. This function is intended to alter that count in the middle of playback.
///
/// - **Parameters:**
///   - `track`: the track to configure.
///   - `num_loops`: new number of times to loop. Zero to disable looping, -1 to loop infinitely.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getLoops
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackLoops(track: ?Track, num_loops: c_int) sdl.Error!void {
    if (!c.MIX_SetTrackLoops(if (track) |resource| @ptrCast(resource.value) else null, num_loops)) return error.SdlFailure;
}

/// Set the current output channel map of a track.
///
/// Channel maps are optional; most things do not need them, instead passing data in the order that SDL expects.
/// The output channel map reorders track data after transformations and before it is mixed into a mixer group. This can be useful for reversing stereo channels, for example.
/// Each item in the array represents an input channel, and its value is the channel that it should be remapped to. To reverse a stereo signal's left and right values, you'd have an array of `{ 1, 0 }`. It is legal to remap multiple channels to the same thing, so `{ 1, 1 }` would duplicate the right channel to both channels of a stereo signal. An element in the channel map set to -1 instead of a valid channel will mute that channel, setting it to a silence value.
/// You cannot change the number of channels through a channel map, just reorder/mute them.
/// Tracks default to no remapping applied. Passing a NULL channel map is legal, and turns off remapping.
/// SDL_mixer will copy the channel map; the caller does not have to save this array after this call.
///
/// - **Parameters:**
///   - `track`: the track to change.
///   - `chmap`: the new channel map, NULL to reset to default.
///   - `count`: The number of channels in the map.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackOutputChannelMap(track: ?Track, chmap: ?*const c_int, count: c_int) sdl.Error!void {
    if (!c.MIX_SetTrackOutputChannelMap(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(chmap), count)) return error.SdlFailure;
}

/// Seek a playing track to a new position in its input.
///
/// (Not to be confused with Track.setTrack3dPosition(), which is positioning of the track in 3D space, not the playback position of its audio data.)
/// On a playing track, the next time the mixer runs, it will start mixing from the new position.
/// Position is defined in *sample frames* of decoded audio, not units of time, so that sample-perfect mixing can be achieved. To instead operate in units of time, use Track.msToFrames() to get the approximate sample frames for a given tick.
/// This function requires an input that can seek (so it can not be used if the input was set with Track.setAudioStream()), and a audio file format that allows seeking. SDL_mixer's decoders for some file formats do not offer seeking, or can only seek to times, not exact sample frames, in which case the final position may be off by some amount of sample frames. Please check your audio data and file bug reports if appropriate.
/// It's legal to call this function on a track that is stopped, but a future call to Track.play() will reset the start position anyhow. Paused tracks will resume at the new input position.
///
/// - **Parameters:**
///   - `track`: the track to change.
///   - `frames`: the sample frame position to seek to.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.getPlaybackPosition
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackPlaybackPosition(track: ?Track, frames: i64) sdl.Error!void {
    if (!c.MIX_SetTrackPlaybackPosition(if (track) |resource| @ptrCast(resource.value) else null, frames)) return error.SdlFailure;
}

/// Set a callback that fires when a Track has initial decoded audio.
///
/// As a track needs to mix more data, it pulls from its input (a Audio, an sdl.audio.Stream, etc). This input might be a compressed file format, like MP3, so a little more data is uncompressed from it.
/// Once the track has PCM data to start operating on, it can fire a callback before *any* changes to the raw PCM input have happened. This lets an app view the data before it has gone through transformations such as gain, 3D positioning, fading, etc. It can also change the data in any way it pleases during this callback, and the mixer will continue as if this data came directly from the input.
/// Each track has its own unique raw callback.
/// Passing a NULL callback here is legal; it disables this track's callback.
///
/// - **Parameters:**
///   - `track`: the track to assign this callback to.
///   - `cb`: the function to call when the track mixes. May be NULL.
///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** TrackMixCallback
/// - **See also:** Track.setCookedCallback
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackRawCallback(track: ?Track, cb: TrackMixCallback, userdata: ?*anyopaque) sdl.Error!void {
    if (!c.MIX_SetTrackRawCallback(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
}

/// Set a MIX_Track's input to an sdl.ioStream.IoStream providing raw PCM data.
///
/// This is not the recommended way to set a track's input, but this can be useful for a very specific scenario: a large file, to be played once, that must be read from disk in small chunks as needed. In most cases, however, it is preferable to create a Audio ahead of time and use Track.setAudio() instead.
/// Also, an Track.setAudioStream() can *also* provide raw PCM audio to a track, via an sdl.audio.Stream, which might be preferable unless the data is already coming directly from an sdl.ioStream.IoStream.
/// The stream supplied here should provide an audio in raw PCM format.
/// A given IOStream may only be assigned to a single track at a time; duplicate assignments won't return an error, but assigning a stream to multiple tracks will cause each track to read from the stream arbitrarily, causing confusion and incorrect mixing.
/// Once a track has a valid input, it can start mixing sound by calling Track.play(), or possibly Mixer.playTag().
/// Calling this function with a NULL stream is legal, and removes any input from the track. If the track was currently playing, the next time the mixer runs, it'll notice this and mark the track as stopped, calling any assigned TrackStoppedCallback.
/// It is legal to change the input of a track while it's playing, however some states, like loop points, may cease to make sense with the new audio. In such a case, one can call Track.play again to adjust parameters.
/// The provided stream must remain valid until the track no longer needs it (either by changing the track's input or destroying the track).
///
/// - **Parameters:**
///   - `track`: the track on which to set a new audio input.
///   - `io`: the new i/o stream to use as the track's input.
///   - `spec`: the format of the PCM data that the sdl.ioStream.IoStream will provide.
///   - `closeio`: if true, close the stream when done with it.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setAudioStream
/// - **See also:** Track.setIoStream
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackRawIoStream(track: ?Track, io: ?*sdl.ioStream.IoStream, spec: ?*const sdl.audio.Spec, closeio: bool) sdl.Error!void {
    if (!c.MIX_SetTrackRawIOStream(if (track) |resource| @ptrCast(resource.value) else null, if (io) |resource| @ptrCast(resource.value) else null, @ptrCast(spec), closeio)) return error.SdlFailure;
}

/// Force a track to stereo output, with optionally left/right panning.
///
/// This will cause the output of the track to convert to stereo, and then mix it only onto the Front Left and Front Right speakers, regardless of the speaker configuration. The left and right channels are modulated by `gains`, which can be used to produce panning effects. This function may be called to adjust the gains at any time.
/// If `gains` is not NULL, this track will be switched into forced-stereo mode. If `gains` is NULL, this will disable spatialization (both the forced-stereo mode of this function and full 3D spatialization of Track.setTrack3dPosition()).
/// Negative gains are clamped to zero; there is no clamp for maximum, so one could set the value > 1.0f to make a channel louder.
/// The track's 3D position, reported by Track.getTrack3dPosition(), will be reset to (0, 0, 0).
///
/// - **Parameters:**
///   - `track`: the track to adjust.
///   - `gains`: the per-channel gains, or NULL to disable spatialization.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.setTrack3dPosition
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackStereo(track: ?Track, gains: ?*const StereoGains) sdl.Error!void {
    if (!c.MIX_SetTrackStereo(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(gains))) return error.SdlFailure;
}

/// Set a callback that fires when a Track is stopped.
///
/// When a track completes playback, either because it ran out of data to mix (and all loops were completed as well), or it was explicitly stopped by the app, it will fire the callback specified here.
/// Each track has its own unique callback.
/// Passing a NULL callback here is legal; it disables this track's callback.
/// Pausing a track will not fire the callback, nor will the callback fire on a playing track that is being destroyed.
/// It is legal to adjust the track, including changing its input and restarting it. If this is done because it ran out of data in the middle of mixing, the mixer will start mixing the new track state in its current run without any gap in the audio.
///
/// - **Parameters:**
///   - `track`: the track to assign this callback to.
///   - `cb`: the function to call when the track stops. May be NULL.
///   - `userdata`: an opaque pointer provided to the callback for its own personal use.
///
/// - **Returns:** true on success or false on failure; call sdl.error_.get() for more information.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** TrackStoppedCallback
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn setTrackStoppedCallback(track: ?Track, cb: TrackStoppedCallback, userdata: ?*anyopaque) sdl.Error!void {
    if (!c.MIX_SetTrackStoppedCallback(if (track) |resource| @ptrCast(resource.value) else null, @ptrCast(cb), @ptrCast(userdata))) return error.SdlFailure;
}

/// Halt all currently-playing tracks, possibly fading out over time.
///
/// If `fade_out_ms` is > 0, the tracks do not stop mixing immediately, but rather fades to silence over that many milliseconds before stopping. Note that this is different than Track.stop(), which wants sample frames; this function takes milliseconds because different tracks might have different sample rates.
/// If a track ends normally while the fade-out is still in progress, the audio stops there; the fade is not adjusted to be shorter if it will last longer than the audio remaining.
/// Once a track has completed any fadeout and come to a stop, it will call its TrackStoppedCallback, if any. It is legal to assign the track a new input and/or restart it during this callback.
/// This function does not prevent new play requests from being made; it’s legal to use this function to begin fading all playing tracks but then start other tracks playing normally while those fade-outs are still in progress.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to stop all tracks.
///   - `fade_out_ms`: the number of milliseconds to spend fading out to silence before halting. 0 to stop immediately.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.stop
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn stopAllTracks(mixer: ?Mixer, fade_out_ms: i64) sdl.Error!void {
    if (!c.MIX_StopAllTracks(if (mixer) |resource| @ptrCast(resource.value) else null, fade_out_ms)) return error.SdlFailure;
}

/// Halt all tracks with a specific tag, possibly fading out over time.
///
/// If `fade_out_ms` is > 0, the tracks do not stop mixing immediately, but rather fades to silence over that many milliseconds before stopping. Note that this is different than Track.stop(), which wants sample frames; this function takes milliseconds because different tracks might have different sample rates.
/// If a track ends normally while the fade-out is still in progress, the audio stops there; the fade is not adjusted to be shorter if it will last longer than the audio remaining.
/// Once a track has completed any fadeout and come to a stop, it will call its TrackStoppedCallback, if any. It is legal to assign the track a new input and/or restart it during this callback. This function does not prevent new play requests from being made.
///
/// - **Parameters:**
///   - `mixer`: the mixer on which to stop tracks.
///   - `tag`: the tag to use when searching for tracks.
///   - `fade_out_ms`: the number of milliseconds to spend fading out to silence before halting. 0 to stop immediately.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.stop
/// - **See also:** Track.tag
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn stopTag(mixer: ?Mixer, tag: ?[:0]const u8, fade_out_ms: i64) sdl.Error!void {
    if (!c.MIX_StopTag(if (mixer) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null, fade_out_ms)) return error.SdlFailure;
}

/// Halt a currently-playing track, possibly fading out over time.
///
/// If `fade_out_frames` is > 0, the track does not stop mixing immediately, but rather fades to silence over that many sample frames before stopping. Sample frames are specific to the input assigned to the track, to allow for sample-perfect mixing. Track.msToFrames() can be used to convert milliseconds to an appropriate value here.
/// If the track ends normally while the fade-out is still in progress, the audio stops there; the fade is not adjusted to be shorter if it will last longer than the audio remaining.
/// Once a track has completed any fadeout and come to a stop, it will call its TrackStoppedCallback, if any. It is legal to assign the track a new input and/or restart it during this callback.
/// It is legal to halt a track that's already stopped. It does nothing, and returns true.
///
/// - **Parameters:**
///   - `track`: the track to halt.
///   - `fade_out_frames`: the number of sample frames to spend fading out to silence before halting. 0 to stop immediately.
///
/// - **Returns:** true if the track has stopped, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.play
pub inline fn stopTrack(track: ?Track, fade_out_frames: i64) bool {
    return c.MIX_StopTrack(if (track) |resource| @ptrCast(resource.value) else null, fade_out_frames);
}

/// Assign an arbitrary tag to a track.
///
/// A tag can be any valid C string in UTF-8 encoding. It can be useful to group tracks in various ways. For example, everything in-game might be marked as "game", so when the user brings up the settings menu, the app can pause all tracks involved in gameplay at once, but keep background music and menu sound effects running.
/// A track can have as many tags as desired, until the machine runs out of memory.
/// It's legal to add the same tag to a track more than once; the extra attempts will report success but not change anything.
/// Tags can later be removed with Track.untag().
///
/// - **Parameters:**
///   - `track`: the track to add a tag to.
///   - `tag`: the tag to add.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.untag
///
/// Returns `error.SdlFailure` when SDL_mixer reports failure.
pub inline fn tagTrack(track: ?Track, tag: ?[:0]const u8) sdl.Error!void {
    if (!c.MIX_TagTrack(if (track) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null)) return error.SdlFailure;
}

/// Convert sample frames for a track's current format to milliseconds.
///
/// This calculates time based on the track's current input format, which can change when its input does, and also if that input changes formats mid-stream (for example, if decoding a file that is two MP3s concatenated together).
/// Sample frames are more precise than milliseconds, so out of necessity, this function will approximate by rounding down to the closest full millisecond.
/// On various errors (init() was not called, the track is NULL), this returns -1. If the track has no input, this returns -1. If `frames` is < 0, this returns -1.
///
/// - **Parameters:**
///   - `track`: the track to query.
///   - `frames`: the track-specific sample frames to convert to milliseconds.
///
/// - **Returns:** Converted number of milliseconds, or -1 for errors/no input; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.msToFrames
pub inline fn trackFramesToMs(track: ?Track, frames: i64) i64 {
    return c.MIX_TrackFramesToMS(if (track) |resource| @ptrCast(resource.value) else null, frames);
}

/// Convert milliseconds to sample frames for a track's current format.
///
/// This calculates time based on the track's current input format, which can change when its input does, and also if that input changes formats mid-stream (for example, if decoding a file that is two MP3s concatenated together).
/// On various errors (init() was not called, the track is NULL), this returns -1. If the track has no input, this returns -1. If `ms` is < 0, this returns -1.
///
/// - **Parameters:**
///   - `track`: the track to query.
///   - `ms`: the milliseconds to convert to track-specific sample frames.
///
/// - **Returns:** Converted number of sample frames, or -1 for errors/no input; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.framesToMs
pub inline fn trackMsToFrames(track: ?Track, ms: i64) i64 {
    return c.MIX_TrackMSToFrames(if (track) |resource| @ptrCast(resource.value) else null, ms);
}

/// Query if a track is currently paused.
///
/// If this returns true, the track is not currently contributing to the mixer's output but will when resumed (it's "paused"). It is not playing nor stopped.
/// On various errors (init() was not called, the track is NULL), this returns false, but there is no mechanism to distinguish errors from non-playing tracks.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** true if paused, false otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.play
/// - **See also:** Track.pause
/// - **See also:** Track.resume_
/// - **See also:** Track.stop
/// - **See also:** Track.playing
pub inline fn trackPaused(track: ?Track) bool {
    return c.MIX_TrackPaused(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Query if a track is currently playing.
///
/// If this returns true, the track is currently contributing to the mixer's output (it's "playing"). It is not stopped nor paused.
/// On various errors (init() was not called, the track is NULL), this returns false, but there is no mechanism to distinguish errors from non-playing tracks.
///
/// - **Parameters:**
///   - `track`: the track to query.
///
/// - **Returns:** true if playing, false otherwise.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.play
/// - **See also:** Track.pause
/// - **See also:** Track.resume_
/// - **See also:** Track.stop
/// - **See also:** Track.paused
pub inline fn trackPlaying(track: ?Track) bool {
    return c.MIX_TrackPlaying(if (track) |resource| @ptrCast(resource.value) else null);
}

/// Unlock a mixer previously locked by a call to Mixer.lock().
///
/// While locked, the mixer will not be able to mix more audio or change its internal state another thread. Those other threads will block until the mixer is unlocked again.
/// Under the hood, this function calls sdl.mutex.Mutex.lock(), so all the same rules apply: the lock can be recursive, it must be unlocked the same number of times from the same thread that locked it, etc.
/// Unlocking a NULL mixer is a safe no-op.
///
/// - **Parameters:**
///   - `mixer`: the mixer to unlock. May be NULL.
///
/// - **Thread safety:** This call must be paired with a previous Mixer.lock call on the same thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Mixer.lock
pub inline fn unlockMixer(mixer: ?Mixer) void {
    c.MIX_UnlockMixer(if (mixer) |resource| @ptrCast(resource.value) else null);
}

/// Remove an arbitrary tag from a track.
///
/// A tag can be any valid C string in UTF-8 encoding. It can be useful to group tracks in various ways. For example, everything in-game might be marked as "game", so when the user brings up the settings menu, the app can pause all tracks involved in gameplay at once, but keep background music and menu sound effects running.
/// It's legal to remove a tag that the track doesn't have; this function doesn't report errors, so this simply does nothing.
/// Specifying a NULL tag will remove all tags on a track.
///
/// - **Parameters:**
///   - `track`: the track from which to remove a tag.
///   - `tag`: the tag to remove, or NULL to remove all current tags.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** Track.tag
pub inline fn untagTrack(track: ?Track, tag: ?[:0]const u8) void {
    c.MIX_UntagTrack(if (track) |resource| @ptrCast(resource.value) else null, if (tag != null) @ptrCast(tag.?.ptr) else null);
}

/// Get the version of SDL_mixer that is linked against your program.
///
/// If you are linking to SDL_mixer dynamically, then it is possible that the current version will be different than the version you compiled against. This function returns the current version, while version is the version you compiled with.
/// This function may be called safely at any time, even before init().
///
/// - **Returns:** the version of the linked library.
/// - **Since:** This function is available since SDL_mixer 3.0.0.
/// - **See also:** version
pub inline fn versionDefault() c_int {
    return c.MIX_Version();
}
