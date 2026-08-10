# API improvement implementation checklist

This checklist is derived from every concrete item in `IMPROVEMENTS.md`. It is dependency ordered.
Execute exactly one unchecked box at a time; mark it complete only after that exact change and its
listed verification are complete. Generated bindings remain inputs, not hand-edited targets.

## Generator-first facade policy

Every facade and public API item below must be implemented in the binding generator and its
configuration first. Generated output is the source of truth and must remain reproducible from the
pinned SDL inputs. A handwritten `src/*_facade.zig` adapter is allowed only when the behavior has
been explicitly reviewed and proven impossible or unsound to express in the generator; such an
exception must document the reason and retain the raw generated surface. Tests for each item must
verify generated output and a package-boundary consumer, not only a handwritten facade module.

Completed items are provisional until their generator-first implementation is reviewed. The queue
below duplicates every completed item for that audit; leave those review boxes unchecked until the
implementation and its generation path have both been verified.

## Generator-first review queue for completed items

- [ ] Review generator-first implementation: Add and validate direct root aliases (including feature-gated companion aliases where
      applicable) for `assert`, `async_io`, `atomic`, `audio`, `camera`, `events`, `filesystem`,
      `gamepad`, `gpu`, `image`, `joystick`, `mixer`, `mutex`, `net`, `pixels`, `properties`,
      `render`, `surface`, `thread`, `ttf`, `timer`, `tray`, `video`, and `vulkan` while retaining
      `core`; verify that `gamepad` and `joystick` are declared only once and that a
      source-distribution consumer compiles.

- [ ] Review generator-first implementation: Add direct typed facade aliases for `blend_mode`, `keycode`, `scancode`, `guid`, `version`,
      `time`, `power`, `pen`, `touch`, `keyboard`, `gamepad`, `mouse`, and `sensor`.

- [ ] Review generator-first implementation: Expose the `extras` runtime helper namespace from the package root.

- [ ] Review generator-first implementation: Add a facade error module with one public error set.

- [ ] Review generator-first implementation: Implement `errors.wrapCall` for scalar failure returns.

- [ ] Review generator-first implementation: Implement `errors.wrapCallBool` for boolean failures.

- [ ] Review generator-first implementation: Implement `errors.wrapCallPtr` for nullable pointers.

- [ ] Review generator-first implementation: Implement `errors.wrapCallCString` for nullable C strings.

- [ ] Review generator-first implementation: Implement negative-count validation in the error facade.

- [ ] Review generator-first implementation: Add a public `fromSdl`/`toSdl` policy helper convention.

- [ ] Review generator-first implementation: Add unknown-enum-to-optional conversion helpers.

- [ ] Review generator-first implementation: Add checked enum-to-SDL conversion helpers.

- [ ] Review generator-first implementation: Add allocator ownership conventions for copied slices and sentinel strings.

- [ ] Review generator-first implementation: Implement generic `Point(T)` with `asOther`, `empty`, and `equal` helpers.

- [ ] Review generator-first implementation: Implement generic `Rect(T)` with `asOther`, `empty`, `equal`, containment, and geometry
      helpers.

- [ ] Review generator-first implementation: Add `FPoint`, `IPoint`, `FRect`, and `IRect` aliases.

- [ ] Review generator-first implementation: Add rectangle intersection receiver methods.

- [ ] Review generator-first implementation: Add pixel `Format.fromSdl` and `Format.toSdl`.

- [ ] Review generator-first implementation: Add pixel format predicates and `details` helpers.

- [ ] Review generator-first implementation: Add typed pixel order, range, primaries, matrix, and transfer conversions.

- [ ] Review generator-first implementation: Add owned `pixels.Palette.init`.

- [ ] Review generator-first implementation: Add owned `pixels.Palette.deinit`.

- [ ] Review generator-first implementation: Add blend `Factor.fromSdl`/`toSdl`.

- [ ] Review generator-first implementation: Add blend `Operation.fromSdl`/`toSdl`.

- [ ] Review generator-first implementation: Add blend `Mode.fromSdl`/`toSdl` and validity predicates.

- [ ] Review generator-first implementation: Add `keycode.Keycode` optional-safe conversion.

- [ ] Review generator-first implementation: Add `keycode.fromScancode` plus scancode and extended predicates.

- [ ] Review generator-first implementation: Add `keycode.KeyModifier` named modifier predicates.

- [ ] Review generator-first implementation: Add optional-safe `scancode.Scancode` conversion and name accessors.

- [ ] Review generator-first implementation: Add `guid.Guid.fromString`.

- [ ] Review generator-first implementation: Add checked `guid.Guid.toString` with ownership semantics.

- [ ] Review generator-first implementation: Add `version.Version.make` and packed component accessors.

- [ ] Review generator-first implementation: Add `version.Version.get` and `atLeast`.

- [ ] Review generator-first implementation: Add time `DateTime.fromSdl`/`toSdl`.

- [ ] Review generator-first implementation: Add time `Time.fromSdl`/`toSdl` and `Time.getCurrent`.

- [ ] Review generator-first implementation: Add Windows time conversion helpers.

- [ ] Review generator-first implementation: Add typed date and format conversions.

- [ ] Review generator-first implementation: Add optional-safe power-state conversion.

- [ ] Review generator-first implementation: Add packed pen `Axis`, `Id`, and `InputFlags` conversions.

- [ ] Review generator-first implementation: Add optional-safe pen `DeviceType` conversion.

- [ ] Review generator-first implementation: Add packed touch `Id`/`FingerId` conversions and `Finger.fromSdl`.

- [ ] Review generator-first implementation: Add packed joystick `Id` conversion.

- [ ] Review generator-first implementation: Add packed mouse `Id` and `ButtonFlags` conversions/predicates.

- [ ] Review generator-first implementation: Add packed keyboard `Id` and the `TextInputProperties` value type.

- [ ] Review generator-first implementation: Add typed gamepad `Axis`, `Button`, `BindingType`, `ButtonLabel`, and `Type`.

- [ ] Review generator-first implementation: Add optional-safe gamepad `Type` conversion.

- [ ] Review generator-first implementation: Add typed sensor `Id` and optional-safe `Type` conversion.

- [ ] Review generator-first implementation: Add net `Timeout.toSdl`, `Status` conversions, and `Version` value accessors.

- [ ] Review generator-first implementation: Add typed GPU descriptor defaults and conversions.

- [ ] Review generator-first implementation: Add GPU buffer/texture usage conversions.

- [ ] Review generator-first implementation: Add GPU buffer/texture location conversions.

- [ ] Review generator-first implementation: Add GPU buffer/texture region conversions.

- [ ] Review generator-first implementation: Add GPU texture and buffer format conversions.

- [ ] Review generator-first implementation: Add GPU pipeline, rasterizer, depth, and sampler state conversion/default wrappers.

- [ ] Review generator-first implementation: Add message-box `BoxData` value and conversion.

- [ ] Review generator-first implementation: Add message-box `BoxFlags`, `Button.Flags`, and `ColorScheme` values.

- [ ] Review generator-first implementation: Add `message_box.Color.fromHex`.

- [ ] Review generator-first implementation: Add TTF text records, colors, and flags conversions/defaults.

- [ ] Review generator-first implementation: Add mixer duration, loop, and `PlayOptions` value/default types.

- [ ] Review generator-first implementation: Add haptic `Direction` and `Features` conversions.

- [ ] Review generator-first implementation: Add haptic `Effect` conversion/default.

- [ ] Review generator-first implementation: Add haptic constant, periodic, condition, ramp, left-right, and custom effect variant
      conversions.

- [ ] Review generator-first implementation: Add video `VSync` value conversion.

- [ ] Review generator-first implementation: Add `audio.Device.deinit`/`close` ownership cleanup.

- [ ] Review generator-first implementation: Add dialog `FileFilter` values and conversion.

- [ ] Review generator-first implementation: Add typed process property values.

- [ ] Review generator-first implementation: Add typed process `Io` values.

- [ ] Review generator-first implementation: Add `video.Window.Options` and `Window.init`.

- [ ] Review generator-first implementation: Add `video.Window.initWithProperties` and `deinit` naming alias.

- [ ] Review generator-first implementation: Add `render.Renderer.Options` and `Renderer.init`.

- [ ] Review generator-first implementation: Add `Renderer.initGpu`, `initSoftwareRenderer`, and `initWithWindow`.

- [ ] Review generator-first implementation: Add renderer receiver texture creation methods.

- [ ] Review generator-first implementation: Add `render.Texture.Options` and renderer-owned texture creation.

- [ ] Review generator-first implementation: Add `surface.Surface.init`, `initFrom`, `initFromFile`, and `initFromIo`.

- [ ] Review generator-first implementation: Add surface `Flags`, `FlipMode`, and `ScaleMode` facade values.

- [ ] Review generator-first implementation: Add `audio.Device` physical/logical type and `Device.open`.

- [ ] Review generator-first implementation: Add raw `audio.Device.openStream` receiver bridge.

- [ ] Review generator-first implementation: Add `audio.Stream.Options`, `Stream.init`, and `deinit`.

- [ ] Review generator-first implementation: Add `camera.Camera.init` and `deinit` alias for `close`.

- [ ] Review generator-first implementation: Add `camera.Specification` conversion.

- [ ] Review generator-first implementation: Add `gpu.Device.Options` and `Device.init`.

- [ ] Review generator-first implementation: Add `io_stream.Stream.initFromFile` with `FileMode`.

- [ ] Review generator-first implementation: Add `io_stream.Stream.initFromConstMem`.

- [ ] Review generator-first implementation: Add `io_stream.Stream.initFromMem`.

- [ ] Review generator-first implementation: Add `io_stream.Stream.initFromDynamicMem`.

- [ ] Review generator-first implementation: Add `io_stream.Stream.initFromFsFile`.

- [ ] Review generator-first implementation: Add `io_stream.Stream.deinit` and ownership mode names.

- [ ] Review generator-first implementation: Add `async_io.File.init` with `IoMode`.

- [ ] Review generator-first implementation: Add `async_io.File.getSize`.

- [ ] Review generator-first implementation: Add `async_io.Queue.init`, `deinit`, and `closeFile`.

- [ ] Review generator-first implementation: Add `async_io.Queue.loadFile`.

- [ ] Review generator-first implementation: Add `filesystem.Path.init`, `get`, and `deinit`.

- [ ] Review generator-first implementation: Add `filesystem.Path.baseName`, `join`, and `parent`.

- [ ] Review generator-first implementation: Add filesystem `PathType`, `PathInfo`, and `GlobFlags` value APIs.

- [ ] Review generator-first implementation: Add typed filesystem path-info and glob results.

- [ ] Review generator-first implementation: Add typed filesystem directory enumeration results.

- [ ] Review generator-first implementation: Add filesystem item-list ownership and `freeAllDirectoryItems`.

- [ ] Review generator-first implementation: Add `properties.Group.init`, `deinit`, and `fromSdl`/`toSdl`.

- [ ] Review generator-first implementation: Add typed `properties.Property` values and get/set operations.

- [ ] Review generator-first implementation: Add properties locking and copying.

- [ ] Review generator-first implementation: Add properties pointer cleanup callback ownership.

- [ ] Review generator-first implementation: Add `storage.Path` ownership and path operations.

- [ ] Review generator-first implementation: Add `storage.Storage.init`, `initFile`, `initTitle`, and `initUser`.

- [ ] Review generator-first implementation: Add `storage.Storage.deinit` and explicit path ownership.

- [ ] Review generator-first implementation: Add `timer.Timer.initMilliseconds` and `initNanoseconds`.

- [ ] Review generator-first implementation: Add `timer.Timer.deinit`.

- [ ] Review generator-first implementation: Add `tray.Tray.init` and `deinit`.

- [ ] Review generator-first implementation: Expose tray `Menu`/`Entry` handles and the `Tray` menu relationship.

- [ ] Review generator-first implementation: Add `process.Process.init` and `initWithProperties`.

- [ ] Review generator-first implementation: Add process receiver `getInput`/`getOutput`, wait, and kill methods.

- [ ] Review generator-first implementation: Add `joystick.Joystick.init`, `deinit`, and `initVirtual`.

- [ ] Review generator-first implementation: Add `joystick.deinitVirtual`.

- [ ] Review generator-first implementation: Add `gamepad.Gamepad.init` and `deinit` naming aliases.

- [ ] Review generator-first implementation: Add gamepad opened-device versus identifier types.

- [ ] Review generator-first implementation: Add `haptic.Haptic.init`, `initFromJoystick`, and `initFromMouse`.

- [ ] Review generator-first implementation: Add `haptic.Haptic.initRumble` and `deinit`.

- [ ] Review generator-first implementation: Add HID subsystem `init` and `deinit`.

- [ ] Review generator-first implementation: Add `hid_api.Device.init`, `initPath`, and `deinit`.

- [ ] Review generator-first implementation: Add owned HID enumeration.

- [ ] Review generator-first implementation: Add `sensor.Sensor.init`, `deinit`, and receiver data access.

- [ ] Review generator-first implementation: Add `thread.Thread.init` and `initWithProperties`.

- [ ] Review generator-first implementation: Add thread receiver `wait` and `detach`.

- [ ] Review generator-first implementation: Add `thread.TlsId.init`.

- [ ] Review generator-first implementation: Add `mutex.Mutex.init`/`deinit`.

- [ ] Review generator-first implementation: Add `mutex.Condition.init`/`deinit`.

- [ ] Review generator-first implementation: Add `mutex.RwLock.init`/`deinit`.

- [ ] Review generator-first implementation: Add `mutex.Semaphore.init`/`deinit`.

- [ ] Review generator-first implementation: Add `mouse.Cursor.init`, `initAnimated`, `initColor`, and `initSystem`.

- [ ] Review generator-first implementation: Add `image.Animation.init` and `deinit`.

- [ ] Review generator-first implementation: Add image generic, typed, GIF, and WEBP IO constructors.

- [ ] Review generator-first implementation: Add image format-specific IO load/save helpers.

- [ ] Review generator-first implementation: Add mixer `Mixer` and `Audio` constructor coverage.

- [ ] Review generator-first implementation: Add mixer `Audio` IO, raw, and no-copy constructors.

- [ ] Review generator-first implementation: Add mixer receiver creation and cleanup methods.

- [ ] Review generator-first implementation: Add TTF `Font` and text-engine constructor/deinit aliases.

- [ ] Review generator-first implementation: Add Metal `View.init`/`deinit`.

- [ ] Review generator-first implementation: Add Vulkan `Surface.init`/`deinit`.

- [ ] Review generator-first implementation: Add `io_stream.Interface(UserData)` typed callback table.

- [ ] Review generator-first implementation: Add `io_stream.Reader` buffered adapter.

- [ ] Review generator-first implementation: Add `io_stream.Writer` buffered adapter.

- [ ] Review generator-first implementation: Add checked scalar IO read/write methods.

- [ ] Review generator-first implementation: Add `io_stream.loadFile` and `saveFile`.

- [ ] Review generator-first implementation: Add generic audio callback factories with typed userdata.

- [ ] Review generator-first implementation: Add generic assertion callback handler.

- [ ] Review generator-first implementation: Add generic clipboard `DataCallback(UserData)`.

- [ ] Review generator-first implementation: Add generic event `Filter(UserData)`.

- [ ] Review generator-first implementation: Add generic filesystem enumeration callback.

- [ ] Review generator-first implementation: Add generic hints callback.

- [ ] Review generator-first implementation: Add generic log output callback.

- [ ] Review generator-first implementation: Add generic system/X11 event hook callback.

- [ ] Review generator-first implementation: Add generic thread function callback.

- [ ] Review generator-first implementation: Add generic millisecond and nanosecond timer callbacks.

- [ ] Review generator-first implementation: Add generic tray callback.

- [ ] Review generator-first implementation: Add generic storage directory-enumeration callback adapter.

- [ ] Review generator-first implementation: Add generic virtual joystick callback descriptor.

- [ ] Review generator-first implementation: Add generic dialog file callback.

- [ ] Review generator-first implementation: Add generic typed SDL main `App(UserData)` callbacks.

- [ ] Review generator-first implementation: Add selected callback compile-time instantiation and invocation tests; keep this explicitly
      narrower than the complete callback matrix below.

- [ ] Review generator-first implementation: Add allocator-aware copied audio device enumeration.

- [ ] Review generator-first implementation: Add allocator-aware copied camera enumeration.

- [ ] Review generator-first implementation: Add allocator-aware clipboard sentinel string result.

- [ ] Review generator-first implementation: Add allocator-aware filesystem and storage path results.

- [ ] Review generator-first implementation: Add typed net `getLocalAddresses` ownership result.

- [ ] Review generator-first implementation: Add `net.Pollable` union and `waitUntilInputAvailable` slice API.

- [ ] Review generator-first implementation: Add tagged `events.Event` union.

- [ ] Review generator-first implementation: Add typed event payloads for window, display, keyboard, mouse, touch, camera, controller, pen,
      sensor, and drop-file events.

- [ ] Review generator-first implementation: Add event `poll() ?Event` facade.

- [ ] Review generator-first implementation: Add event `waitAndPop() !Event` facade.

- [ ] Review generator-first implementation: Define borrowed versus copied drop-file string ownership.

- [ ] Review generator-first implementation: Add focused `atomic.Int`, `atomic.U32`, and `atomic.Spinlock` receiver methods.

- [ ] Review generator-first implementation: Add discoverable `bits`, `cpu_info`, `endian`, and `intrin` root modules.

- [ ] Review generator-first implementation: Add named SIMD capability constants where target policy permits.

- [ ] Review generator-first implementation: Add focused `platform_api`, `loadso_api`, `system_api`, and `version_api` aliases.

- [ ] Review generator-first implementation: Add owned `loadso.SharedObject` init/symbol/deinit facade.

- [ ] Review generator-first implementation: Add typed keyboard text-input properties conversion.

- [ ] Review generator-first implementation: Add grouped mouse global/relative state result values.

- [ ] Review generator-first implementation: Add owned grouped touch and sensor enumeration result wrappers.

- [ ] Review generator-first implementation: Add typed joystick `ConnectionState` conversion.

- [ ] Review generator-first implementation: Add focused `Init.init`/`deinit` subsystem facade.

- [ ] Review generator-first implementation: Add typed main `runApp`/`enterAppMainCallbacks` facade.

- [ ] Review generator-first implementation: Add runtime shader metadata loading and compatibility validation.

- [ ] Review generator-first implementation: Add embedded and directory shader loaders.

- [ ] Review generator-first implementation: Add shader metadata field lookup helpers.

- [ ] Review generator-first implementation: Add `extras.FramerateCapper`.

- [ ] Review generator-first implementation: Add reusable error handlers and loggers under `extras`.

- [ ] Review generator-first implementation: Add examples for callbacks and userdata ownership.

- [ ] Review generator-first implementation: Add examples for custom IO and allocators.

- [ ] Review generator-first implementation: Add examples for filesystem, properties, storage, and dialogs.

- [ ] Review generator-first implementation: Add examples for GPU, renderer, TTF, mixer, networking, tray, and shadercross.

- [ ] Review generator-first implementation: Add allocator leak/double-free regression tests.

- [ ] Review generator-first implementation: Add migration aliases without removing generated C-shaped functions.

- [ ] Review generator-first implementation: Run lint and typecheck.

## 1. Public facade foundation

- [x] Generator-first: Add and validate direct root aliases (including feature-gated companion aliases where
      applicable) for `assert`, `async_io`, `atomic`, `audio`, `camera`, `events`, `filesystem`,
      `gamepad`, `gpu`, `image`, `joystick`, `mixer`, `mutex`, `net`, `pixels`, `properties`,
      `render`, `surface`, `thread`, `ttf`, `timer`, `tray`, `video`, and `vulkan` while retaining
      `core`; verify that `gamepad` and `joystick` are declared only once and that a
      source-distribution consumer compiles.
- [ ] Generator-first: Add canonical `async_io`, `io_stream`, `blend_mode`, `hid_api`, and `message_box` aliases.
- [x] Generator-first: Add direct typed facade aliases for `blend_mode`, `keycode`, `scancode`, `guid`, `version`,
      `time`, `power`, `pen`, `touch`, `keyboard`, `gamepad`, `mouse`, and `sensor`.
- [x] Generator-first: Expose the `extras` runtime helper namespace from the package root.
- [x] Generator-first: Add a facade error module with one public error set.
- [x] Generator-first: Implement `errors.wrapCall` for scalar failure returns.
- [x] Generator-first: Implement `errors.wrapCallBool` for boolean failures.
- [x] Generator-first: Implement `errors.wrapCallPtr` for nullable pointers.
- [x] Generator-first: Implement `errors.wrapCallCString` for nullable C strings.
- [x] Generator-first: Implement negative-count validation in the error facade.
- [ ] Generator-first: Add standardized SDL error helpers and thread-local callback-error dispatch.
- [ ] Generator-first: Add compile-time tests for each error wrapper shape; runtime tests alone are insufficient.
- [ ] Generator-first: Add a facade test importing every direct and conditional root alias, including companion
      aliases, and compile the source-distribution consumer.
- [x] Generator-first: Add a public `fromSdl`/`toSdl` policy helper convention.
- [x] Generator-first: Add unknown-enum-to-optional conversion helpers.
- [x] Generator-first: Add checked enum-to-SDL conversion helpers.
- [ ] Generator-first: Apply the shared optional-safe and checked `fromSdl`/`toSdl` policy to every remaining enum,
      packed-flag, and descriptor facade.
- [ ] Generator-first: Add uniform `contains`/`with` helpers to remaining packed flag wrappers, including
      `surface.Flags`, `pen.InputFlags`, and message-box flags.
- [x] Generator-first: Add allocator ownership conventions for copied slices and sentinel strings.
- [ ] Generator-first: Add a facade test for borrowed versus copied return documentation contracts and add the
      required `docs/callback-lifetimes.md` contract document.

## 2. Core value types and conversions

- [x] Generator-first: Implement generic `Point(T)` with `asOther`, `empty`, and `equal` helpers.
- [x] Generator-first: Implement generic `Rect(T)` with `asOther`, `empty`, `equal`, containment, and geometry
      helpers.
- [x] Generator-first: Add `FPoint`, `IPoint`, `FRect`, and `IRect` aliases.
- [x] Generator-first: Add rectangle intersection receiver methods.
- [ ] Generator-first: Add rectangle enclosing receiver methods.
- [x] Generator-first: Add pixel `Format.fromSdl` and `Format.toSdl`.
- [x] Generator-first: Add pixel format predicates and `details` helpers.
- [ ] Generator-first: Add typed pixel format mask helpers and checked invalid-format handling.
- [x] Generator-first: Add typed pixel order, range, primaries, matrix, and transfer conversions.
- [ ] Generator-first: Make pixel order, range, primaries, matrix, and transfer conversions optional-safe for unknown
      SDL values.
- [ ] Generator-first: Add optional-safe pixel component and `Colorspace` conversions.
- [x] Generator-first: Add owned `pixels.Palette.init`.
- [x] Generator-first: Add owned `pixels.Palette.deinit`.
- [x] Generator-first: Add blend `Factor.fromSdl`/`toSdl`.
- [x] Generator-first: Add blend `Operation.fromSdl`/`toSdl`.
- [x] Generator-first: Add blend `Mode.fromSdl`/`toSdl` and validity predicates.
- [ ] Generator-first: Add optional-safe unknown-value handling for blend `Mode` conversions.
- [x] Generator-first: Add `keycode.Keycode` optional-safe conversion.
- [x] Generator-first: Add `keycode.fromScancode` plus scancode and extended predicates.
- [x] Generator-first: Add `keycode.KeyModifier` named modifier predicates.
- [x] Generator-first: Add optional-safe `scancode.Scancode` conversion and name accessors.
- [ ] Generator-first: Add scancode name-to-value lookup helpers.
- [x] Generator-first: Add `guid.Guid.fromString`.
- [x] Generator-first: Add checked `guid.Guid.toString` with ownership semantics.
- [x] Generator-first: Add `version.Version.make` and packed component accessors.
- [x] Generator-first: Add `version.Version.get` and `atLeast`.
- [ ] Generator-first: Add optional-safe version revision-string conversion and ownership documentation.
- [x] Generator-first: Add time `DateTime.fromSdl`/`toSdl`.
- [x] Generator-first: Add time `Time.fromSdl`/`toSdl` and `Time.getCurrent`.
- [ ] Generator-first: Add `DateTime.getCurrent` and `Time.fromDateTime` helpers.
- [x] Generator-first: Add Windows time conversion helpers.
- [x] Generator-first: Add typed date and format conversions.
- [ ] Generator-first: Add `time.Month` `fromSdl`/`toSdl` conversions.
- [x] Generator-first: Add optional-safe power-state conversion.
- [x] Generator-first: Add packed pen `Axis`, `Id`, and `InputFlags` conversions.
- [x] Generator-first: Add optional-safe pen `DeviceType` conversion.
- [x] Generator-first: Add packed touch `Id`/`FingerId` conversions and `Finger.fromSdl`.
- [ ] Generator-first: Add `touch.Finger.toSdl` conversion.
- [x] Generator-first: Add packed joystick `Id` conversion.
- [ ] Generator-first: Add `joystick.AxisMask` and `ButtonMask` `fromSdl`/`toSdl` conversions.
- [x] Generator-first: Add packed mouse `Id` and `ButtonFlags` conversions/predicates.
- [x] Generator-first: Add packed keyboard `Id` and the `TextInputProperties` value type.
- [ ] Generator-first: Add grouped keyboard text-input state values.
- [ ] Generator-first: Return optional-safe typed `keyboard.Id` values from keyboard enumeration helpers.
- [x] Generator-first: Add typed gamepad `Axis`, `Button`, `BindingType`, `ButtonLabel`, and `Type`.
- [ ] Generator-first: Add a typed gamepad `Binding` mapping record and conversion helpers.
- [x] Generator-first: Add optional-safe gamepad `Type` conversion.
- [ ] Generator-first: Add optional-safe unknown-value handling for remaining gamepad enum conversions.
- [ ] Generator-first: Add gamepad typed `Properties` and `BindingIterator` APIs.
- [ ] Generator-first: Add typed joystick properties and receiver property access.
- [x] Generator-first: Add typed sensor `Id` and optional-safe `Type` conversion.
- [x] Generator-first: Add net `Timeout.toSdl`, `Status` conversions, and `Version` value accessors.
- [ ] Generator-first: Add complete net `Timeout`/`Version` `fromSdl`/`toSdl` conversions.
- [ ] Generator-first: Normalize net receiver naming and conversion methods across address, socket, server, and
      local-address result types.
- [x] Generator-first: Add typed GPU descriptor defaults and conversions.
- [ ] Generator-first: Add complete GPU buffer/texture create-info `fromSdl`/`toSdl` round-trip conversions.
- [ ] Generator-first: Add fallible GPU descriptor `toSdl` conversions where nested values can be invalid.
- [x] Generator-first: Add GPU buffer/texture usage conversions.
- [x] Generator-first: Add GPU buffer/texture location conversions.
- [x] Generator-first: Add GPU buffer/texture region conversions.
- [x] Generator-first: Add GPU texture and buffer format conversions.
- [ ] Generator-first: Add GPU buffer/texture create-info defaults.
- [x] Generator-first: Add GPU pipeline, rasterizer, depth, and sampler state conversion/default wrappers.
- [x] Generator-first: Add message-box `BoxData` value and conversion.
- [x] Generator-first: Add message-box `BoxFlags`, `Button.Flags`, and `ColorScheme` values.
- [ ] Generator-first: Add message-box `ColorScheme.fromSdl` conversion.
- [x] Generator-first: Add `message_box.Color.fromHex`.
- [ ] Generator-first: Add usable defaults for message-box and remaining public descriptor values.
- [x] Generator-first: Add TTF text records, colors, and flags conversions/defaults.
- [ ] Generator-first: Add TTF GPU-atlas facade values and conversions/defaults.
- [x] Generator-first: Add mixer duration, loop, and `PlayOptions` value/default types.
- [ ] Generator-first: Add complete mixer duration/loop and `PlayOptions` `fromSdl`/`toSdl` conversions.
- [x] Generator-first: Add haptic `Direction` and `Features` conversions.
- [x] Generator-first: Add haptic `Effect` conversion/default.
- [x] Generator-first: Add haptic constant, periodic, condition, ramp, left-right, and custom effect variant
      conversions.
- [x] Generator-first: Add video `VSync` value conversion.
- [ ] Generator-first: Add audio `Spec.fromSdl`/`toSdl` conversions and typed audio configuration defaults.
- [ ] Generator-first: Add audio `Format.define`, size/name/silence helpers, and signedness/endian/integer/floating
      predicates.
- [ ] Generator-first: Add receiver-oriented audio device format, channel-map, gain, pause, classification, binding,
      and postmix methods.
- [x] Generator-first: Add `audio.Device.deinit`/`close` ownership cleanup.
- [ ] Generator-first: Return typed physical/logical audio devices from playback and recording enumeration helpers.
- [ ] Generator-first: Add camera `Id.getName`, `getPosition`, and `getSupportedFormats` methods.
- [ ] Generator-first: Add typed video display name, bounds, orientation, scale, and mode query methods.
- [ ] Generator-first: Add video `Display.Mode` and `Display.Orientation` conversions.
- [ ] Generator-first: Add typed video `Display`/`WindowId` enumeration and checked result values.
- [ ] Generator-first: Add typed video window create properties, flags, position, and properties values.
- [ ] Generator-first: Add owned `video.gl.Context.init`/`deinit` facade.
- [x] Generator-first: Add dialog `FileFilter` values and conversion.
- [ ] Generator-first: Add `dialog.Properties.toSdl`/`fromSdl` conversion helpers.
- [ ] Generator-first: Use typed dialog properties in a dialog operation and verify the resulting native property
      record.
- [ ] Generator-first: Add explicit borrowed/copied or allocator-aware ownership for dialog file/folder callback
      paths and results.
- [ ] Generator-first: Add typed dialog `Type` values and checked dialog result helpers.
- [x] Generator-first: Add typed process property values.
- [x] Generator-first: Add typed process `Io` values.
- [ ] Generator-first: Add `process.CreateProperties.toProperties` and `process.Properties.fromSdl`/`toSdl`
      conversion helpers.

## 3. Lifecycle and ownership facade

- [x] Generator-first: Add `video.Window.Options` and `Window.init`.
- [x] Generator-first: Add `video.Window.initWithProperties` and `deinit` naming alias.
- [x] Generator-first: Add `render.Renderer.Options` and `Renderer.init`.
- [x] Generator-first: Add `Renderer.initGpu`, `initSoftwareRenderer`, and `initWithWindow`.
- [x] Generator-first: Add renderer receiver texture creation methods.
- [ ] Generator-first: Add receiver aliases for remaining common operations such as `Window.setTitle`,
      `Texture.setScaleMode`, and bulk `Stream.read`.
- [x] Generator-first: Add `render.Texture.Options` and renderer-owned texture creation.
- [ ] Generator-first: Add explicit renderer-parent ownership and lifetime tracking for `render.Texture`.
- [x] Generator-first: Add `surface.Surface.init`, `initFrom`, `initFromFile`, and `initFromIo`.
- [ ] Generator-first: Add `surface.Surface.Options` and typed source/configuration conversions.
- [x] Generator-first: Add surface `Flags`, `FlipMode`, and `ScaleMode` facade values.
- [ ] Generator-first: Add typed surface BMP and PNG IO loaders.
- [ ] Generator-first: Add typed surface BMP and PNG file/path loader overloads.
- [ ] Generator-first: Add typed surface BMP/PNG save helpers and explicit output/IO ownership modes.
- [ ] Generator-first: Add typed surface properties/configuration conversion helpers.
- [x] Generator-first: Add `audio.Device` physical/logical type and `Device.open`.
- [x] Generator-first: Add raw `audio.Device.openStream` receiver bridge.
- [ ] Generator-first: Return the facade `audio.Stream` from `Device.openStream` with explicit ownership semantics.
- [x] Generator-first: Add `audio.Stream.Options`, `Stream.init`, and `deinit`.
- [ ] Generator-first: Add typed video hit-test callback userdata.
- [x] Generator-first: Add `camera.Camera.init` and `deinit` alias for `close`.
- [x] Generator-first: Add `camera.Specification` conversion.
- [ ] Generator-first: Add typed `camera.Id` conversion and return typed IDs from camera enumeration results.
- [ ] Generator-first: Add camera specification defaults and checked validation for descriptor values.
- [x] Generator-first: Add `gpu.Device.Options` and `Device.init`.
- [x] Generator-first: Add `io_stream.Stream.initFromFile` with `FileMode`.
- [x] Generator-first: Add `io_stream.Stream.initFromConstMem`.
- [x] Generator-first: Add `io_stream.Stream.initFromMem`.
- [x] Generator-first: Add `io_stream.Stream.initFromDynamicMem`.
- [x] Generator-first: Add `io_stream.Stream.initFromFsFile`.
- [ ] Generator-first: Add `io_stream.Stream.initFromReaderWriter` for native Zig reader/writer pairs.
- [x] Generator-first: Add `io_stream.Stream.deinit` and ownership mode names.
- [x] Generator-first: Add `async_io.File.init` with `IoMode`.
- [ ] Generator-first: Add the complete four-value `async_io.IoMode` set and explicit mode-string mappings.
- [x] Generator-first: Add `async_io.File.getSize`.
- [x] Generator-first: Add `async_io.Queue.init`, `deinit`, and `closeFile`.
- [x] Generator-first: Add `async_io.Queue.loadFile`.
- [x] Generator-first: Add `filesystem.Path.init`, `get`, and `deinit`.
- [x] Generator-first: Add `filesystem.Path.baseName`, `join`, and `parent`.
- [x] Generator-first: Add filesystem `PathType`, `PathInfo`, and `GlobFlags` value APIs.
- [x] Generator-first: Add typed filesystem path-info and glob results.
- [x] Generator-first: Add typed filesystem directory enumeration results.
- [x] Generator-first: Add filesystem item-list ownership and `freeAllDirectoryItems`.
- [x] Generator-first: Add `properties.Group.init`, `deinit`, and `fromSdl`/`toSdl`.
- [x] Generator-first: Add typed `properties.Property` values and get/set operations.
- [ ] Generator-first: Add `properties.Group.getAll` and `clear` value APIs.
- [x] Generator-first: Add properties locking and copying.
- [ ] Generator-first: Add the `properties.Group.enumerateProperties` receiver API.
- [x] Generator-first: Add properties pointer cleanup callback ownership.
- [ ] Generator-first: Add typed properties cleanup and enumeration callback factories.
- [x] Generator-first: Add `storage.Path` ownership and path operations.
- [x] Generator-first: Add `storage.Storage.init`, `initFile`, `initTitle`, and `initUser`.
- [x] Generator-first: Add `storage.Storage.deinit` and explicit path ownership.
- [ ] Generator-first: Add `storage.Storage.getFileSize` and receiver filesystem operations.
- [x] Generator-first: Add `timer.Timer.initMilliseconds` and `initNanoseconds`.
- [x] Generator-first: Add `timer.Timer.deinit`.
- [ ] Generator-first: Add timer millisecond/nanosecond delay and conversion helpers.
- [ ] Generator-first: Add optional-safe `timer.Timer.fromSdl`/`toSdl` conversion.
- [x] Generator-first: Add `tray.Tray.init` and `deinit`.
- [x] Generator-first: Expose tray `Menu`/`Entry` handles and the `Tray` menu relationship.
- [ ] Generator-first: Add tray `EntryFlags.toSdl` conversion and typed menu insertion/submenu operations.
- [x] Generator-first: Add `process.Process.init` and `initWithProperties`.
- [x] Generator-first: Add process receiver `getInput`/`getOutput`, wait, and kill methods.
- [ ] Generator-first: Add `Process.read` and complete receiver I/O result/stream ownership methods.
- [x] Generator-first: Add `joystick.Joystick.init`, `deinit`, and `initVirtual`.
- [x] Generator-first: Add `joystick.deinitVirtual`.
- [x] Generator-first: Add `gamepad.Gamepad.init` and `deinit` naming aliases.
- [x] Generator-first: Add gamepad opened-device versus identifier types.
- [ ] Generator-first: Add gamepad receiver button/axis, mapping, sensor, rumble, LED, and player-index methods.
- [ ] Generator-first: Return typed gamepad and joystick identifiers from enumeration helpers.
- [ ] Generator-first: Add joystick receiver axis/button/hat/ball, mapping, sensor, and rumble methods.
- [x] Generator-first: Add `haptic.Haptic.init`, `initFromJoystick`, and `initFromMouse`.
- [x] Generator-first: Add `haptic.Haptic.initRumble` and `deinit`.
- [x] Generator-first: Add HID subsystem `init` and `deinit`.
- [x] Generator-first: Add `hid_api.Device.init`, `initPath`, and `deinit`.
- [x] Generator-first: Add owned HID enumeration.
- [ ] Generator-first: Add typed HID `DeviceInfo` conversion/record helpers.
- [x] Generator-first: Add `sensor.Sensor.init`, `deinit`, and receiver data access.
- [x] Generator-first: Add `thread.Thread.init` and `initWithProperties`.
- [x] Generator-first: Add thread receiver `wait` and `detach`.
- [x] Generator-first: Add `thread.TlsId.init`.
- [x] Generator-first: Add `mutex.Mutex.init`/`deinit`.
- [x] Generator-first: Add `mutex.Condition.init`/`deinit`.
- [x] Generator-first: Add `mutex.RwLock.init`/`deinit`.
- [x] Generator-first: Add `mutex.Semaphore.init`/`deinit`.
- [x] Generator-first: Add `mouse.Cursor.init`, `initAnimated`, `initColor`, and `initSystem`.
- [x] Generator-first: Add `image.Animation.init` and `deinit`.
- [ ] Generator-first: Add `image.Animation.initFromFile` and file-owned animation construction.
- [x] Generator-first: Add image generic, typed, GIF, and WEBP IO constructors.
- [ ] Generator-first: Add explicit owned/borrowed image IO constructor names and ownership modes.
- [x] Generator-first: Add image format-specific IO load/save helpers.
- [ ] Generator-first: Add image format-specific file/path load/save helpers.
- [x] Generator-first: Add mixer `Mixer` and `Audio` constructor coverage.
- [ ] Generator-first: Add mixer `Track`/`Group` constructor and resource matrix coverage.
- [x] Generator-first: Add mixer `Audio` IO, raw, and no-copy constructors.
- [ ] Generator-first: Add explicit raw-no-copy/borrowed naming for mixer `Audio` construction.
- [ ] Generator-first: Add remaining mixer resource IO, raw, no-copy, and borrowed constructors.
- [x] Generator-first: Add mixer receiver creation and cleanup methods.
- [ ] Generator-first: Add explicit Mixer-parent ownership and lifetime tracking for mixer Track, Group, and Audio
      resources.
- [ ] Generator-first: Add generic mixer callback factories and typed playback callback userdata.
- [x] Generator-first: Add TTF `Font` and text-engine constructor/deinit aliases.
- [x] Generator-first: Add Metal `View.init`/`deinit`.
- [ ] Generator-first: Make `metal.View.init` checked or optional-safe for failed native view creation.
- [x] Generator-first: Add Vulkan `Surface.init`/`deinit`.
- [ ] Generator-first: Add checked Vulkan library/proc-address helpers around the generated functions.

## 4. IO, callbacks, and result shapes

- [x] Generator-first: Add `io_stream.Interface(UserData)` typed callback table.
- [x] Generator-first: Add `io_stream.Reader` buffered adapter.
- [x] Generator-first: Add `io_stream.Writer` buffered adapter.
- [x] Generator-first: Add checked scalar IO read/write methods.
- [x] Generator-first: Add `io_stream.loadFile` and `saveFile`.
- [x] Generator-first: Add generic audio callback factories with typed userdata.
- [ ] Generator-first: Add typed audio postmix, stream-data-complete, and device-binding callback factories.
- [x] Generator-first: Add generic assertion callback handler.
- [ ] Generator-first: Add typed assertion report/state values and reset/report operations.
- [x] Generator-first: Add generic clipboard `DataCallback(UserData)`.
- [ ] Generator-first: Add generic clipboard `CleanupCallback(UserData)`.
- [x] Generator-first: Add generic event `Filter(UserData)`.
- [ ] Generator-first: Add `events.Iterator`, `iterator`, `eventIn`, `minMax`, event groups, `flushGroup`, and
      `hasGroup` helpers.
- [x] Generator-first: Add generic filesystem enumeration callback.
- [x] Generator-first: Add generic hints callback.
- [x] Generator-first: Add generic log output callback.
- [x] Generator-first: Add generic system/X11 event hook callback.
- [ ] Generator-first: Add generic system lifecycle callback adapters beyond the X11 event hook.
- [x] Generator-first: Add generic thread function callback.
- [x] Generator-first: Add generic millisecond and nanosecond timer callbacks.
- [x] Generator-first: Add generic tray callback.
- [x] Generator-first: Add generic storage directory-enumeration callback adapter.
- [ ] Generator-first: Expose the canonical `storage.Interface(UserData)` callback factory.
- [x] Generator-first: Add generic virtual joystick callback descriptor.
- [x] Generator-first: Add generic dialog file callback.
- [x] Generator-first: Add generic typed SDL main `App(UserData)` callbacks.
- [ ] Generator-first: Document callback userdata lifetime and trampoline storage requirements in
      `docs/callback-lifetimes.md`, including stable trampoline storage, temporary userdata, and
      unregister/teardown rules.
- [x] Generator-first: Add selected callback compile-time instantiation and invocation tests; keep this explicitly
      narrower than the complete callback matrix below.
- [ ] Generator-first: Add callback matrix tests for audio postmix/completion, clipboard cleanup, mouse motion,
      properties cleanup/enumeration, and platform lifecycle hooks.
- [x] Generator-first: Add allocator-aware copied audio device enumeration.
- [x] Generator-first: Add allocator-aware copied camera enumeration.
- [x] Generator-first: Add allocator-aware clipboard sentinel string result.
- [x] Generator-first: Add allocator-aware filesystem and storage path results.
- [x] Generator-first: Add typed net `getLocalAddresses` ownership result.
- [x] Generator-first: Add `net.Pollable` union and `waitUntilInputAvailable` slice API.
- [x] Generator-first: Add tagged `events.Event` union.
- [x] Generator-first: Add typed event payloads for window, display, keyboard, mouse, touch, camera, controller, pen,
      sensor, and drop-file events.
- [ ] Generator-first: Add `fromSdl`/`toSdl` round-trip methods to every tagged event payload while retaining
      raw-event access.
- [x] Generator-first: Add event `poll() ?Event` facade.
- [x] Generator-first: Add event `waitAndPop() !Event` facade.
- [x] Generator-first: Define borrowed versus copied drop-file string ownership.
- [ ] Generator-first: Add event payload round-trip conversion tests after `fromSdl`/`toSdl` implementation.

## 5. Platform, utility, and adjunct coverage

- [x] Generator-first: Add focused `atomic.Int`, `atomic.U32`, and `atomic.Spinlock` receiver methods.
- [x] Generator-first: Add discoverable `bits`, `cpu_info`, `endian`, and `intrin` root modules.
- [x] Generator-first: Add named SIMD capability constants where target policy permits.
- [x] Generator-first: Add focused `platform_api`, `loadso_api`, `system_api`, and `version_api` aliases.
- [ ] Generator-first: Add direct root aliases for the remaining focused utility and integration modules
      (`clipboard`, `dialog`, `haptic`, `hints`, `io_stream`, `locale`, `loadso`, `log`, `main`,
      `metal`, `misc`, `platform`, `process`, `storage`, and `system`) while retaining their
      explicit `*_api` facade names where present.
- [x] Generator-first: Add owned `loadso.SharedObject` init/symbol/deinit facade.
- [x] Generator-first: Add typed keyboard text-input properties conversion.
- [ ] Generator-first: Add `cpu_info` SIMD feature predicates, typed system-size results, and normalized return
      shapes.
- [ ] Generator-first: Add focused `endian.ByteOrder` values and conversion helpers.
- [ ] Generator-first: Add typed hint priority/type values and checked priority-setting helpers.
- [ ] Generator-first: Add typed log priority/category values and checked callback-installation helpers.
- [ ] Generator-first: Add typed thread state and priority values.
- [ ] Generator-first: Add typed `misc.openUrl` error/result facade.
- [ ] Generator-first: Add a checked `platform.get` result facade alongside the direct platform alias.
- [x] Generator-first: Add grouped mouse global/relative state result values.
- [ ] Generator-first: Add the grouped mouse local `getState` result value.
- [ ] Generator-first: Add the mouse `MotionTransformCallback(UserData)` adapter.
- [x] Generator-first: Add owned grouped touch and sensor enumeration result wrappers.
- [ ] Generator-first: Return typed `touch.Id` and `sensor.Id` values from enumeration results.
- [x] Generator-first: Add typed joystick `ConnectionState` conversion.
- [ ] Generator-first: Add filesystem `getSeparator` and typed path-separator helpers.
- [x] Generator-first: Add focused `Init.init`/`deinit` subsystem facade.
- [ ] Generator-first: Add direct root `init`/`quit` aliases alongside the focused `Init` facade.
- [x] Generator-first: Add typed main `runApp`/`enterAppMainCallbacks` facade.
- [ ] Generator-first: Export the typed app-main facade under a canonical root `main` module.
- [ ] Generator-first: Add root main helpers for memory/environment operations and UTF-8 iterators.
- [x] Generator-first: Add runtime shader metadata loading and compatibility validation.
- [x] Generator-first: Add embedded and directory shader loaders.
- [x] Generator-first: Add shader metadata field lookup helpers.
- [x] Generator-first: Add `extras.FramerateCapper`.
- [x] Generator-first: Add reusable error handlers and loggers under `extras`.
- [ ] Generator-first: Expose shader metadata loading, compatibility validation, and asset loaders through the root
      `extras` helper namespace.
- [x] Generator-first: Add examples for callbacks and userdata ownership.
- [x] Generator-first: Add examples for custom IO and allocators.
- [x] Generator-first: Add examples for filesystem, properties, storage, and dialogs.
- [x] Generator-first: Add examples for GPU, renderer, TTF, mixer, networking, tray, and shadercross.
- [ ] Generator-first: Add examples for message boxes, logging, app-main callbacks, and runtime shader compatibility.

## 6. Verification and migration

- [ ] Generator-first: Add black-box compile tests for every implemented facade type at the package/source
      distribution boundary; source-text checks and a general build are insufficient.
- [ ] Generator-first: Add lifecycle success/failure tests for every implemented constructor family.
- [ ] Generator-first: Add ownership tests for copied, borrowed, dynamic, and no-copy inputs.
- [ ] Generator-first: Add enum/flag unknown-value and round-trip tests for implemented value facades.
- [ ] Generator-first: Add callback userdata and teardown tests for implemented callback adapters.
- [x] Generator-first: Add allocator leak/double-free regression tests.
- [x] Generator-first: Add migration aliases without removing generated C-shaped functions.
- [ ] Generator-first: Update a hand-written public facade API coverage inventory after implementation; generated SDL
      declaration coverage in `COVERAGE.md` does not satisfy this item.
- [ ] Generator-first: Re-run the full API comparison when the upstream tip or pinned SDL family changes; do not
      treat upstream source changes as documentation-only changes.
- [ ] Generator-first: Run formatter and formatter check, including `TODO.md`.
- [x] Generator-first: Run lint and typecheck.
- [ ] Generator-first: Run metadata, source, binding, build, and shader tests.
  - Blocked on this Windows host: pinned `.mise-bins` clang/CastXML are unusable; direct library
    binaries run, but clang omits expected FormatAttr fields and CastXML lacks `vcruntime.h`.
    Metadata/source/shader sub-gates pass.
- [ ] Generator-first: Run the complete repository check pipeline.
  - Blocked by the binding and build prerequisites above; do not mark complete until both pass.
- [ ] Generator-first: Run release-check and record any unavailable cross-target gates.
  - Release check ran: release archive requires GNU tar under Linux, macOS, or WSL; WSL is not
    enabled on this host. Binding prerequisites also fail as recorded above.
