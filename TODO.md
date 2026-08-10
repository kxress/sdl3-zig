# Generated facade-pattern migration checklist

This checklist preserves the detailed API inventory while changing its implementation strategy:
detect recurring SDL declaration patterns, plan a typed facade replacement, and render that replacement
in the generated module that owns the declaration. Work in dependency order and complete one unchecked
box at a time. A completed item must be reproducible from pinned SDL inputs and generator configuration;
generated bindings are never hand-edited.

## Generator-emission and removal policy

Generate each improved API directly in the existing module that owns the SDL declaration. Do not create
handwritten or generated `*_facade.zig` files, forwarding facade modules, overlays, or a parallel public
API. When a facade pattern matches safely, it replaces the generated public C-shaped wrapper for that
declaration with the typed facade; the raw C import remains an implementation detail for the generated
facade body. Keep a public C-shaped wrapper only when the pattern explicitly documents why no faithful
facade replacement is possible.

When porting an existing facade, first encode its candidate detection, semantic analysis, naming,
replacement rendering, availability, and ownership rules in a reusable pattern. Regenerate the affected
module and verify its package-boundary API. Then remove the superseded implementation and its
facade-only imports, re-exports, configuration branches, and duplicate tests. A compatibility alias is
allowed only when it is part of the intended public API and is emitted by the same replacement plan;
it must not retain a second public implementation of the operation.

Items beginning “Refactor” identify existing implementations to port into a generated replacement and
remove. Items beginning “Writing” identify behavior with no existing facade implementation that must be
added through the generic mechanism. Every implementation item must prove that the matched declaration
caused the generated replacement and that no parallel `*_facade` module or public C-shaped wrapper
remains. Verification and documentation items retain their action-oriented wording.

## Generic pattern framework

- [ ] Writing the declarative pattern registry with explicit candidate matching, replacement naming,
      in-module rendering, availability, conflict-resolution, and data-driven override rules.
- [ ] Writing a common analysis model for matched declarations, related types, ownership, error
      conventions, target availability, and renderer inputs.
- [ ] Writing diagnostics for unmatched, ambiguous, and conflicting candidates that identify the
      source declaration and the accepting or rejecting rule.
- [ ] Writing stable companion-library extension points so SDL_image, SDL_ttf, SDL_mixer, SDL_net,
      and SDL_shadercross reuse core patterns without copied logic.
- [ ] Writing deterministic rendering and collision handling that preserve stable ordering and the
      generated-file header.
- [ ] Writing pattern-level fixtures for positive matches, deliberate non-matches, ambiguities,
      target-gated declarations, and companion-library declarations.

## 1. Public facade foundation

- [ ] Refactor the existing implementation to use generic pattern detection: Add and validate direct root exports (including feature-gated companion exports where
      applicable) for `assert`, `async_io`, `atomic`, `audio`, `camera`, `events`, `filesystem`,
      `gamepad`, `gpu`, `image`, `joystick`, `mixer`, `mutex`, `net`, `pixels`, `properties`,
      `render`, `surface`, `thread`, `ttf`, `timer`, `tray`, `video`, and `vulkan` while retaining
      `core`; verify that `gamepad` and `joystick` are declared only once and that a
      source-distribution consumer compiles.
- [ ] Writing generic generator support for: Add canonical `async_io`, `io_stream`, `blend_mode`, `hid_api`, and `message_box` aliases.
- [ ] Refactor the existing implementation to use generic pattern detection: Add direct typed facade aliases for `blend_mode`, `keycode`, `scancode`, `guid`, `version`,
      `time`, `power`, `pen`, `touch`, `keyboard`, `gamepad`, `mouse`, and `sensor`.
- [ ] Refactor the existing implementation to use generic pattern detection: Expose the `extras` runtime helper namespace from the package root.
- [ ] Refactor the existing implementation to use generic pattern detection: Add a facade error module with one public error set.
- [ ] Refactor the existing implementation to use generic pattern detection: Implement `errors.wrapCall` for scalar failure returns.
- [ ] Refactor the existing implementation to use generic pattern detection: Implement `errors.wrapCallBool` for boolean failures.
- [ ] Refactor the existing implementation to use generic pattern detection: Implement `errors.wrapCallPtr` for nullable pointers.
- [ ] Refactor the existing implementation to use generic pattern detection: Implement `errors.wrapCallCString` for nullable C strings.
- [ ] Refactor the existing implementation to use generic pattern detection: Implement negative-count validation in the error facade.
- [ ] Writing generic generator support for: Add standardized SDL error helpers and thread-local callback-error dispatch.
- [ ] Writing generic generator support for: Add compile-time tests for each error wrapper shape; runtime tests alone are insufficient.
- [ ] Writing generic generator support for: Add a facade test importing every direct and conditional root alias, including companion
      aliases, and compile the source-distribution consumer.
- [ ] Refactor the existing implementation to use generic pattern detection: Add a public `fromSdl`/`toSdl` policy helper convention.
- [ ] Refactor the existing implementation to use generic pattern detection: Add unknown-enum-to-optional conversion helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add checked enum-to-SDL conversion helpers.
- [ ] Writing generic generator support for: Apply the shared optional-safe and checked `fromSdl`/`toSdl` policy to every remaining enum,
      packed-flag, and descriptor facade.
- [ ] Writing generic generator support for: Add uniform `contains`/`with` helpers to remaining packed flag wrappers, including
      `surface.Flags`, `pen.InputFlags`, and message-box flags.
- [ ] Refactor the existing implementation to use generic pattern detection: Add allocator ownership conventions for copied slices and sentinel strings.
- [ ] Writing generic generator support for: Add a facade test for borrowed versus copied return documentation contracts and add the
      required `docs/callback-lifetimes.md` contract document.

## 2. Core value types and conversions

- [ ] Refactor the existing implementation to use generic pattern detection: Implement generic `Point(T)` with `asOther`, `empty`, and `equal` helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Implement generic `Rect(T)` with `asOther`, `empty`, `equal`, containment, and geometry
      helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `FPoint`, `IPoint`, `FRect`, and `IRect` aliases.
- [ ] Refactor the existing implementation to use generic pattern detection: Add rectangle intersection receiver methods.
- [ ] Writing generic generator support for: Add rectangle enclosing receiver methods.
- [ ] Refactor the existing implementation to use generic pattern detection: Add pixel `Format.fromSdl` and `Format.toSdl`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add pixel format predicates and `details` helpers.
- [ ] Writing generic generator support for: Add typed pixel format mask helpers and checked invalid-format handling.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed pixel order, range, primaries, matrix, and transfer conversions.
- [ ] Writing generic generator support for: Make pixel order, range, primaries, matrix, and transfer conversions optional-safe for unknown
      SDL values.
- [ ] Writing generic generator support for: Add optional-safe pixel component and `Colorspace` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add owned `pixels.Palette.init`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add owned `pixels.Palette.deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add blend `Factor.fromSdl`/`toSdl`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add blend `Operation.fromSdl`/`toSdl`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add blend `Mode.fromSdl`/`toSdl` and validity predicates.
- [ ] Writing generic generator support for: Add optional-safe unknown-value handling for blend `Mode` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `keycode.Keycode` optional-safe conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `keycode.fromScancode` plus scancode and extended predicates.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `keycode.KeyModifier` named modifier predicates.
- [ ] Refactor the existing implementation to use generic pattern detection: Add optional-safe `scancode.Scancode` conversion and name accessors.
- [ ] Writing generic generator support for: Add scancode name-to-value lookup helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `guid.Guid.fromString`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add checked `guid.Guid.toString` with ownership semantics.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `version.Version.make` and packed component accessors.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `version.Version.get` and `atLeast`.
- [ ] Writing generic generator support for: Add optional-safe version revision-string conversion and ownership documentation.
- [ ] Refactor the existing implementation to use generic pattern detection: Add time `DateTime.fromSdl`/`toSdl`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add time `Time.fromSdl`/`toSdl` and `Time.getCurrent`.
- [ ] Writing generic generator support for: Add `DateTime.getCurrent` and `Time.fromDateTime` helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add Windows time conversion helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed date and format conversions.
- [ ] Writing generic generator support for: Add `time.Month` `fromSdl`/`toSdl` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add optional-safe power-state conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add packed pen `Axis`, `Id`, and `InputFlags` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add optional-safe pen `DeviceType` conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add packed touch `Id`/`FingerId` conversions and `Finger.fromSdl`.
- [ ] Writing generic generator support for: Add `touch.Finger.toSdl` conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add packed joystick `Id` conversion.
- [ ] Writing generic generator support for: Add `joystick.AxisMask` and `ButtonMask` `fromSdl`/`toSdl` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add packed mouse `Id` and `ButtonFlags` conversions/predicates.
- [ ] Refactor the existing implementation to use generic pattern detection: Add packed keyboard `Id` and the `TextInputProperties` value type.
- [ ] Writing generic generator support for: Add grouped keyboard text-input state values.
- [ ] Writing generic generator support for: Return optional-safe typed `keyboard.Id` values from keyboard enumeration helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed gamepad `Axis`, `Button`, `BindingType`, `ButtonLabel`, and `Type`.
- [ ] Writing generic generator support for: Add a typed gamepad `Binding` mapping record and conversion helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add optional-safe gamepad `Type` conversion.
- [ ] Writing generic generator support for: Add optional-safe unknown-value handling for remaining gamepad enum conversions.
- [ ] Writing generic generator support for: Add gamepad typed `Properties` and `BindingIterator` APIs.
- [ ] Writing generic generator support for: Add typed joystick properties and receiver property access.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed sensor `Id` and optional-safe `Type` conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add net `Timeout.toSdl`, `Status` conversions, and `Version` value accessors.
- [ ] Writing generic generator support for: Add complete net `Timeout`/`Version` `fromSdl`/`toSdl` conversions.
- [ ] Writing generic generator support for: Normalize net receiver naming and conversion methods across address, socket, server, and
      local-address result types.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed GPU descriptor defaults and conversions.
- [ ] Writing generic generator support for: Add complete GPU buffer/texture create-info `fromSdl`/`toSdl` round-trip conversions.
- [ ] Writing generic generator support for: Add fallible GPU descriptor `toSdl` conversions where nested values can be invalid.
- [ ] Refactor the existing implementation to use generic pattern detection: Add GPU buffer/texture usage conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add GPU buffer/texture location conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add GPU buffer/texture region conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add GPU texture and buffer format conversions.
- [ ] Writing generic generator support for: Add GPU buffer/texture create-info defaults.
- [ ] Refactor the existing implementation to use generic pattern detection: Add GPU pipeline, rasterizer, depth, and sampler state conversion/default wrappers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add message-box `BoxData` value and conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add message-box `BoxFlags`, `Button.Flags`, and `ColorScheme` values.
- [ ] Writing generic generator support for: Add message-box `ColorScheme.fromSdl` conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `message_box.Color.fromHex`.
- [ ] Writing generic generator support for: Add usable defaults for message-box and remaining public descriptor values.
- [ ] Refactor the existing implementation to use generic pattern detection: Add TTF text records, colors, and flags conversions/defaults.
- [ ] Writing generic generator support for: Add TTF GPU-atlas facade values and conversions/defaults.
- [ ] Refactor the existing implementation to use generic pattern detection: Add mixer duration, loop, and `PlayOptions` value/default types.
- [ ] Writing generic generator support for: Add complete mixer duration/loop and `PlayOptions` `fromSdl`/`toSdl` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add haptic `Direction` and `Features` conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add haptic `Effect` conversion/default.
- [ ] Refactor the existing implementation to use generic pattern detection: Add haptic constant, periodic, condition, ramp, left-right, and custom effect variant
      conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add video `VSync` value conversion.
- [ ] Writing generic generator support for: Add audio `Spec.fromSdl`/`toSdl` conversions and typed audio configuration defaults.
- [ ] Writing generic generator support for: Add audio `Format.define`, size/name/silence helpers, and signedness/endian/integer/floating
      predicates.
- [ ] Writing generic generator support for: Add receiver-oriented audio device format, channel-map, gain, pause, classification, binding,
      and postmix methods.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `audio.Device.deinit`/`close` ownership cleanup.
- [ ] Writing generic generator support for: Return typed physical/logical audio devices from playback and recording enumeration helpers.
- [ ] Writing generic generator support for: Add camera `Id.getName`, `getPosition`, and `getSupportedFormats` methods.
- [ ] Writing generic generator support for: Add typed video display name, bounds, orientation, scale, and mode query methods.
- [ ] Writing generic generator support for: Add video `Display.Mode` and `Display.Orientation` conversions.
- [ ] Writing generic generator support for: Add typed video `Display`/`WindowId` enumeration and checked result values.
- [ ] Writing generic generator support for: Add typed video window create properties, flags, position, and properties values.
- [ ] Writing generic generator support for: Add owned `video.gl.Context.init`/`deinit` facade.
- [ ] Refactor the existing implementation to use generic pattern detection: Add dialog `FileFilter` values and conversion.
- [ ] Writing generic generator support for: Add `dialog.Properties.toSdl`/`fromSdl` conversion helpers.
- [ ] Writing generic generator support for: Use typed dialog properties in a dialog operation and verify the resulting native property
      record.
- [ ] Writing generic generator support for: Add explicit borrowed/copied or allocator-aware ownership for dialog file/folder callback
      paths and results.
- [ ] Writing generic generator support for: Add typed dialog `Type` values and checked dialog result helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed process property values.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed process `Io` values.
- [ ] Writing generic generator support for: Add `process.CreateProperties.toProperties` and `process.Properties.fromSdl`/`toSdl`
      conversion helpers.

## 3. Lifecycle and ownership facade

- [ ] Refactor the existing implementation to use generic pattern detection: Add `video.Window.Options` and `Window.init`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `video.Window.initWithProperties` and `deinit` naming alias.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `render.Renderer.Options` and `Renderer.init`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `Renderer.initGpu`, `initSoftwareRenderer`, and `initWithWindow`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add renderer receiver texture creation methods.
- [ ] Writing generic generator support for: Add receiver aliases for remaining common operations such as `Window.setTitle`,
      `Texture.setScaleMode`, and bulk `Stream.read`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `render.Texture.Options` and renderer-owned texture creation.
- [ ] Writing generic generator support for: Add explicit renderer-parent ownership and lifetime tracking for `render.Texture`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `surface.Surface.init`, `initFrom`, `initFromFile`, and `initFromIo`.
- [ ] Writing generic generator support for: Add `surface.Surface.Options` and typed source/configuration conversions.
- [ ] Refactor the existing implementation to use generic pattern detection: Add surface `Flags`, `FlipMode`, and `ScaleMode` facade values.
- [ ] Writing generic generator support for: Add typed surface BMP and PNG IO loaders.
- [ ] Writing generic generator support for: Add typed surface BMP and PNG file/path loader overloads.
- [ ] Writing generic generator support for: Add typed surface BMP/PNG save helpers and explicit output/IO ownership modes.
- [ ] Writing generic generator support for: Add typed surface properties/configuration conversion helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `audio.Device` physical/logical type and `Device.open`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add raw `audio.Device.openStream` receiver bridge.
- [ ] Writing generic generator support for: Return the facade `audio.Stream` from `Device.openStream` with explicit ownership semantics.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `audio.Stream.Options`, `Stream.init`, and `deinit`.
- [ ] Writing generic generator support for: Add typed video hit-test callback userdata.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `camera.Camera.init` and `deinit` alias for `close`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `camera.Specification` conversion.
- [ ] Writing generic generator support for: Add typed `camera.Id` conversion and return typed IDs from camera enumeration results.
- [ ] Writing generic generator support for: Add camera specification defaults and checked validation for descriptor values.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `gpu.Device.Options` and `Device.init`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Stream.initFromFile` with `FileMode`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Stream.initFromConstMem`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Stream.initFromMem`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Stream.initFromDynamicMem`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Stream.initFromFsFile`.
- [ ] Writing generic generator support for: Add `io_stream.Stream.initFromReaderWriter` for native Zig reader/writer pairs.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Stream.deinit` and ownership mode names.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `async_io.File.init` with `IoMode`.
- [ ] Writing generic generator support for: Add the complete four-value `async_io.IoMode` set and explicit mode-string mappings.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `async_io.File.getSize`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `async_io.Queue.init`, `deinit`, and `closeFile`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `async_io.Queue.loadFile`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `filesystem.Path.init`, `get`, and `deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `filesystem.Path.baseName`, `join`, and `parent`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add filesystem `PathType`, `PathInfo`, and `GlobFlags` value APIs.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed filesystem path-info and glob results.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed filesystem directory enumeration results.
- [ ] Refactor the existing implementation to use generic pattern detection: Add filesystem item-list ownership and `freeAllDirectoryItems`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `properties.Group.init`, `deinit`, and `fromSdl`/`toSdl`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed `properties.Property` values and get/set operations.
- [ ] Writing generic generator support for: Add `properties.Group.getAll` and `clear` value APIs.
- [ ] Refactor the existing implementation to use generic pattern detection: Add properties locking and copying.
- [ ] Writing generic generator support for: Add the `properties.Group.enumerateProperties` receiver API.
- [ ] Refactor the existing implementation to use generic pattern detection: Add properties pointer cleanup callback ownership.
- [ ] Writing generic generator support for: Add typed properties cleanup and enumeration callback factories.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `storage.Path` ownership and path operations.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `storage.Storage.init`, `initFile`, `initTitle`, and `initUser`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `storage.Storage.deinit` and explicit path ownership.
- [ ] Writing generic generator support for: Add `storage.Storage.getFileSize` and receiver filesystem operations.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `timer.Timer.initMilliseconds` and `initNanoseconds`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `timer.Timer.deinit`.
- [ ] Writing generic generator support for: Add timer millisecond/nanosecond delay and conversion helpers.
- [ ] Writing generic generator support for: Add optional-safe `timer.Timer.fromSdl`/`toSdl` conversion.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `tray.Tray.init` and `deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Expose tray `Menu`/`Entry` handles and the `Tray` menu relationship.
- [ ] Writing generic generator support for: Add tray `EntryFlags.toSdl` conversion and typed menu insertion/submenu operations.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `process.Process.init` and `initWithProperties`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add process receiver `getInput`/`getOutput`, wait, and kill methods.
- [ ] Writing generic generator support for: Add `Process.read` and complete receiver I/O result/stream ownership methods.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `joystick.Joystick.init`, `deinit`, and `initVirtual`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `joystick.deinitVirtual`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `gamepad.Gamepad.init` and `deinit` naming aliases.
- [ ] Refactor the existing implementation to use generic pattern detection: Add gamepad opened-device versus identifier types.
- [ ] Writing generic generator support for: Add gamepad receiver button/axis, mapping, sensor, rumble, LED, and player-index methods.
- [ ] Writing generic generator support for: Return typed gamepad and joystick identifiers from enumeration helpers.
- [ ] Writing generic generator support for: Add joystick receiver axis/button/hat/ball, mapping, sensor, and rumble methods.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `haptic.Haptic.init`, `initFromJoystick`, and `initFromMouse`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `haptic.Haptic.initRumble` and `deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add HID subsystem `init` and `deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `hid_api.Device.init`, `initPath`, and `deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add owned HID enumeration.
- [ ] Writing generic generator support for: Add typed HID `DeviceInfo` conversion/record helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `sensor.Sensor.init`, `deinit`, and receiver data access.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `thread.Thread.init` and `initWithProperties`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add thread receiver `wait` and `detach`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `thread.TlsId.init`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `mutex.Mutex.init`/`deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `mutex.Condition.init`/`deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `mutex.RwLock.init`/`deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `mutex.Semaphore.init`/`deinit`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `mouse.Cursor.init`, `initAnimated`, `initColor`, and `initSystem`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `image.Animation.init` and `deinit`.
- [ ] Writing generic generator support for: Add `image.Animation.initFromFile` and file-owned animation construction.
- [ ] Refactor the existing implementation to use generic pattern detection: Add image generic, typed, GIF, and WEBP IO constructors.
- [ ] Writing generic generator support for: Add explicit owned/borrowed image IO constructor names and ownership modes.
- [ ] Refactor the existing implementation to use generic pattern detection: Add image format-specific IO load/save helpers.
- [ ] Writing generic generator support for: Add image format-specific file/path load/save helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add mixer `Mixer` and `Audio` constructor coverage.
- [ ] Writing generic generator support for: Add mixer `Track`/`Group` constructor and resource matrix coverage.
- [ ] Refactor the existing implementation to use generic pattern detection: Add mixer `Audio` IO, raw, and no-copy constructors.
- [ ] Writing generic generator support for: Add explicit raw-no-copy/borrowed naming for mixer `Audio` construction.
- [ ] Writing generic generator support for: Add remaining mixer resource IO, raw, no-copy, and borrowed constructors.
- [ ] Refactor the existing implementation to use generic pattern detection: Add mixer receiver creation and cleanup methods.
- [ ] Writing generic generator support for: Add explicit Mixer-parent ownership and lifetime tracking for mixer Track, Group, and Audio
      resources.
- [ ] Writing generic generator support for: Add generic mixer callback factories and typed playback callback userdata.
- [ ] Refactor the existing implementation to use generic pattern detection: Add TTF `Font` and text-engine constructor/deinit aliases.
- [ ] Refactor the existing implementation to use generic pattern detection: Add Metal `View.init`/`deinit`.
- [ ] Writing generic generator support for: Make `metal.View.init` checked or optional-safe for failed native view creation.
- [ ] Refactor the existing implementation to use generic pattern detection: Add Vulkan `Surface.init`/`deinit`.
- [ ] Writing generic generator support for: Add checked Vulkan library/proc-address helpers around the generated functions.

## 4. IO, callbacks, and result shapes

- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Interface(UserData)` typed callback table.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Reader` buffered adapter.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.Writer` buffered adapter.
- [ ] Refactor the existing implementation to use generic pattern detection: Add checked scalar IO read/write methods.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `io_stream.loadFile` and `saveFile`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic audio callback factories with typed userdata.
- [ ] Writing generic generator support for: Add typed audio postmix, stream-data-complete, and device-binding callback factories.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic assertion callback handler.
- [ ] Writing generic generator support for: Add typed assertion report/state values and reset/report operations.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic clipboard `DataCallback(UserData)`.
- [ ] Writing generic generator support for: Add generic clipboard `CleanupCallback(UserData)`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic event `Filter(UserData)`.
- [ ] Writing generic generator support for: Add `events.Iterator`, `iterator`, `eventIn`, `minMax`, event groups, `flushGroup`, and
      `hasGroup` helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic filesystem enumeration callback.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic hints callback.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic log output callback.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic system/X11 event hook callback.
- [ ] Writing generic generator support for: Add generic system lifecycle callback adapters beyond the X11 event hook.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic thread function callback.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic millisecond and nanosecond timer callbacks.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic tray callback.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic storage directory-enumeration callback adapter.
- [ ] Writing generic generator support for: Expose the canonical `storage.Interface(UserData)` callback factory.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic virtual joystick callback descriptor.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic dialog file callback.
- [ ] Refactor the existing implementation to use generic pattern detection: Add generic typed SDL main `App(UserData)` callbacks.
- [ ] Writing generic generator support for: Document callback userdata lifetime and trampoline storage requirements in
      `docs/callback-lifetimes.md`, including stable trampoline storage, temporary userdata, and
      unregister/teardown rules.
- [ ] Refactor the existing implementation to use generic pattern detection: Add selected callback compile-time instantiation and invocation tests; keep this explicitly
      narrower than the complete callback matrix below.
- [ ] Writing generic generator support for: Add callback matrix tests for audio postmix/completion, clipboard cleanup, mouse motion,
      properties cleanup/enumeration, and platform lifecycle hooks.
- [ ] Refactor the existing implementation to use generic pattern detection: Add allocator-aware copied audio device enumeration.
- [ ] Refactor the existing implementation to use generic pattern detection: Add allocator-aware copied camera enumeration.
- [ ] Refactor the existing implementation to use generic pattern detection: Add allocator-aware clipboard sentinel string result.
- [ ] Refactor the existing implementation to use generic pattern detection: Add allocator-aware filesystem and storage path results.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed net `getLocalAddresses` ownership result.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `net.Pollable` union and `waitUntilInputAvailable` slice API.
- [ ] Refactor the existing implementation to use generic pattern detection: Add tagged `events.Event` union.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed event payloads for window, display, keyboard, mouse, touch, camera, controller, pen,
      sensor, and drop-file events.
- [ ] Writing generic generator support for: Add `fromSdl`/`toSdl` round-trip methods to every tagged event payload while retaining
      raw-event access.
- [ ] Refactor the existing implementation to use generic pattern detection: Add event `poll() ?Event` facade.
- [ ] Refactor the existing implementation to use generic pattern detection: Add event `waitAndPop() !Event` facade.
- [ ] Refactor the existing implementation to use generic pattern detection: Define borrowed versus copied drop-file string ownership.
- [ ] Writing generic generator support for: Add event payload round-trip conversion tests after `fromSdl`/`toSdl` implementation.

## 5. Platform, utility, and adjunct coverage

- [ ] Refactor the existing implementation to use generic pattern detection: Add focused `atomic.Int`, `atomic.U32`, and `atomic.Spinlock` receiver methods.
- [ ] Refactor the existing implementation to use generic pattern detection: Add discoverable `bits`, `cpu_info`, `endian`, and `intrin` root modules.
- [ ] Refactor the existing implementation to use generic pattern detection: Add named SIMD capability constants where target policy permits.
- [ ] Refactor the existing implementation to use generic pattern detection: Add focused `platform_api`, `loadso_api`, `system_api`, and `version_api` aliases.
- [ ] Writing generic generator support for: Add direct root aliases for the remaining focused utility and integration modules
      (`clipboard`, `dialog`, `haptic`, `hints`, `io_stream`, `locale`, `loadso`, `log`, `main`,
      `metal`, `misc`, `platform`, `process`, `storage`, and `system`) while retaining their
      explicit `*_api` facade names where present.
- [ ] Refactor the existing implementation to use generic pattern detection: Add owned `loadso.SharedObject` init/symbol/deinit facade.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed keyboard text-input properties conversion.
- [ ] Writing generic generator support for: Add `cpu_info` SIMD feature predicates, typed system-size results, and normalized return
      shapes.
- [ ] Writing generic generator support for: Add focused `endian.ByteOrder` values and conversion helpers.
- [ ] Writing generic generator support for: Add typed hint priority/type values and checked priority-setting helpers.
- [ ] Writing generic generator support for: Add typed log priority/category values and checked callback-installation helpers.
- [ ] Writing generic generator support for: Add typed thread state and priority values.
- [ ] Writing generic generator support for: Add typed `misc.openUrl` error/result facade.
- [ ] Writing generic generator support for: Add a checked `platform.get` result facade alongside the direct platform alias.
- [ ] Refactor the existing implementation to use generic pattern detection: Add grouped mouse global/relative state result values.
- [ ] Writing generic generator support for: Add the grouped mouse local `getState` result value.
- [ ] Writing generic generator support for: Add the mouse `MotionTransformCallback(UserData)` adapter.
- [ ] Refactor the existing implementation to use generic pattern detection: Add owned grouped touch and sensor enumeration result wrappers.
- [ ] Writing generic generator support for: Return typed `touch.Id` and `sensor.Id` values from enumeration results.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed joystick `ConnectionState` conversion.
- [ ] Writing generic generator support for: Add filesystem `getSeparator` and typed path-separator helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add focused `Init.init`/`deinit` subsystem facade.
- [ ] Writing generic generator support for: Add direct root `init`/`quit` aliases alongside the focused `Init` facade.
- [ ] Refactor the existing implementation to use generic pattern detection: Add typed main `runApp`/`enterAppMainCallbacks` facade.
- [ ] Writing generic generator support for: Export the typed app-main facade under a canonical root `main` module.
- [ ] Writing generic generator support for: Add root main helpers for memory/environment operations and UTF-8 iterators.
- [ ] Refactor the existing implementation to use generic pattern detection: Add runtime shader metadata loading and compatibility validation.
- [ ] Refactor the existing implementation to use generic pattern detection: Add embedded and directory shader loaders.
- [ ] Refactor the existing implementation to use generic pattern detection: Add shader metadata field lookup helpers.
- [ ] Refactor the existing implementation to use generic pattern detection: Add `extras.FramerateCapper`.
- [ ] Refactor the existing implementation to use generic pattern detection: Add reusable error handlers and loggers under `extras`.
- [ ] Writing generic generator support for: Expose shader metadata loading, compatibility validation, and asset loaders through the root
      `extras` helper namespace.
- [ ] Refactor the existing implementation to use generic pattern detection: Add examples for callbacks and userdata ownership.
- [ ] Refactor the existing implementation to use generic pattern detection: Add examples for custom IO and allocators.
- [ ] Refactor the existing implementation to use generic pattern detection: Add examples for filesystem, properties, storage, and dialogs.
- [ ] Refactor the existing implementation to use generic pattern detection: Add examples for GPU, renderer, TTF, mixer, networking, tray, and shadercross.
- [ ] Writing generic generator support for: Add examples for message boxes, logging, app-main callbacks, and runtime shader compatibility.

## 6. Verification and migration

- [ ] Writing generic generator support for: Add black-box compile tests for every implemented facade type at the package/source
      distribution boundary; source-text checks and a general build are insufficient.
- [ ] Writing generic generator support for: Add lifecycle success/failure tests for every implemented constructor family.
- [ ] Writing generic generator support for: Add ownership tests for copied, borrowed, dynamic, and no-copy inputs.
- [ ] Writing generic generator support for: Add enum/flag unknown-value and round-trip tests for implemented value facades.
- [ ] Writing generic generator support for: Add callback userdata and teardown tests for implemented callback adapters.
- [ ] Refactor the existing implementation to use generic pattern detection: Add allocator leak/double-free regression tests.
- [ ] Refactor the existing implementation to use generic pattern detection: Add only documented compatibility aliases while removing the superseded generated C-shaped wrappers.
- [ ] Updating the generated public API pattern-coverage inventory after implementation; generated
      SDL declaration coverage in `COVERAGE.md` does not satisfy this item.
- [ ] Re-running the full API comparison when the upstream tip or pinned SDL family changes; do not
      treat upstream source changes as documentation-only changes.
- [ ] Running formatter and formatter check, including `TODO.md`.
- [ ] Running lint and typecheck.
- [ ] Running metadata, source, binding, build, and shader tests.
  - Blocked on this Windows host: pinned `.mise-bins` clang/CastXML are unusable; direct library
    binaries run, but clang omits expected FormatAttr fields and CastXML lacks `vcruntime.h`.
    Metadata/source/shader sub-gates pass.
- [ ] Running the complete repository check pipeline.
  - Blocked by the binding and build prerequisites above; do not mark complete until both pass.
- [ ] Running release-check and recording any unavailable cross-target gates.
  - Release check ran: release archive requires GNU tar under Linux, macOS, or WSL; WSL is not
    enabled on this host. Binding prerequisites also fail as recorded above.
