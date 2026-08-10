# API improvement implementation checklist

This checklist is derived from every concrete item in `IMPROVEMENTS.md`. It is dependency ordered.
Execute exactly one unchecked box at a time; mark it complete only after that exact change and its
listed verification are complete. Generated bindings remain inputs, not hand-edited targets.

## 1. Public facade foundation

- [ ] Add and validate direct root aliases (including feature-gated companion aliases where
      applicable) for `assert`, `async_io`, `atomic`, `audio`, `camera`, `events`, `filesystem`,
      `gamepad`, `gpu`, `image`, `joystick`, `mixer`, `mutex`, `net`, `pixels`, `properties`,
      `render`, `surface`, `thread`, `ttf`, `timer`, `tray`, `video`, and `vulkan` while retaining
      `core`; verify that `gamepad` and `joystick` are declared only once and that a
      source-distribution consumer compiles.
- [ ] Add canonical `async_io`, `io_stream`, `blend_mode`, `hid_api`, and `message_box` aliases.
- [x] Add direct typed facade aliases for `blend_mode`, `keycode`, `scancode`, `guid`, `version`,
      `time`, `power`, `pen`, `touch`, `keyboard`, `gamepad`, `mouse`, and `sensor`.
- [x] Expose the `extras` runtime helper namespace from the package root.
- [x] Add a facade error module with one public error set.
- [x] Implement `errors.wrapCall` for scalar failure returns.
- [x] Implement `errors.wrapCallBool` for boolean failures.
- [x] Implement `errors.wrapCallPtr` for nullable pointers.
- [x] Implement `errors.wrapCallCString` for nullable C strings.
- [x] Implement negative-count validation in the error facade.
- [ ] Add standardized SDL error helpers and thread-local callback-error dispatch.
- [ ] Add compile-time tests for each error wrapper shape; runtime tests alone are insufficient.
- [ ] Add a facade test importing every direct and conditional root alias, including companion
      aliases, and compile the source-distribution consumer.
- [x] Add a public `fromSdl`/`toSdl` policy helper convention.
- [x] Add unknown-enum-to-optional conversion helpers.
- [x] Add checked enum-to-SDL conversion helpers.
- [ ] Apply the shared optional-safe and checked `fromSdl`/`toSdl` policy to every remaining enum,
      packed-flag, and descriptor facade.
- [ ] Add uniform `contains`/`with` helpers to remaining packed flag wrappers, including
      `surface.Flags`, `pen.InputFlags`, and message-box flags.
- [x] Add allocator ownership conventions for copied slices and sentinel strings.
- [ ] Add a facade test for borrowed versus copied return documentation contracts and add the
      required `docs/callback-lifetimes.md` contract document.

## 2. Core value types and conversions

- [x] Implement generic `Point(T)` with `asOther`, `empty`, and `equal` helpers.
- [x] Implement generic `Rect(T)` with `asOther`, `empty`, `equal`, containment, and geometry
      helpers.
- [x] Add `FPoint`, `IPoint`, `FRect`, and `IRect` aliases.
- [x] Add rectangle intersection receiver methods.
- [ ] Add rectangle enclosing receiver methods.
- [x] Add pixel `Format.fromSdl` and `Format.toSdl`.
- [x] Add pixel format predicates and `details` helpers.
- [ ] Add typed pixel format mask helpers and checked invalid-format handling.
- [x] Add typed pixel order, range, primaries, matrix, and transfer conversions.
- [ ] Make pixel order, range, primaries, matrix, and transfer conversions optional-safe for unknown
      SDL values.
- [ ] Add optional-safe pixel component and `Colorspace` conversions.
- [x] Add owned `pixels.Palette.init`.
- [x] Add owned `pixels.Palette.deinit`.
- [x] Add blend `Factor.fromSdl`/`toSdl`.
- [x] Add blend `Operation.fromSdl`/`toSdl`.
- [x] Add blend `Mode.fromSdl`/`toSdl` and validity predicates.
- [ ] Add optional-safe unknown-value handling for blend `Mode` conversions.
- [x] Add `keycode.Keycode` optional-safe conversion.
- [x] Add `keycode.fromScancode` plus scancode and extended predicates.
- [x] Add `keycode.KeyModifier` named modifier predicates.
- [x] Add optional-safe `scancode.Scancode` conversion and name accessors.
- [ ] Add scancode name-to-value lookup helpers.
- [x] Add `guid.Guid.fromString`.
- [x] Add checked `guid.Guid.toString` with ownership semantics.
- [x] Add `version.Version.make` and packed component accessors.
- [x] Add `version.Version.get` and `atLeast`.
- [ ] Add optional-safe version revision-string conversion and ownership documentation.
- [x] Add time `DateTime.fromSdl`/`toSdl`.
- [x] Add time `Time.fromSdl`/`toSdl` and `Time.getCurrent`.
- [ ] Add `DateTime.getCurrent` and `Time.fromDateTime` helpers.
- [x] Add Windows time conversion helpers.
- [x] Add typed date and format conversions.
- [ ] Add `time.Month` `fromSdl`/`toSdl` conversions.
- [x] Add optional-safe power-state conversion.
- [x] Add packed pen `Axis`, `Id`, and `InputFlags` conversions.
- [x] Add optional-safe pen `DeviceType` conversion.
- [x] Add packed touch `Id`/`FingerId` conversions and `Finger.fromSdl`.
- [ ] Add `touch.Finger.toSdl` conversion.
- [x] Add packed joystick `Id` conversion.
- [ ] Add `joystick.AxisMask` and `ButtonMask` `fromSdl`/`toSdl` conversions.
- [x] Add packed mouse `Id` and `ButtonFlags` conversions/predicates.
- [x] Add packed keyboard `Id` and the `TextInputProperties` value type.
- [ ] Add grouped keyboard text-input state values.
- [ ] Return optional-safe typed `keyboard.Id` values from keyboard enumeration helpers.
- [x] Add typed gamepad `Axis`, `Button`, `BindingType`, `ButtonLabel`, and `Type`.
- [ ] Add a typed gamepad `Binding` mapping record and conversion helpers.
- [x] Add optional-safe gamepad `Type` conversion.
- [ ] Add optional-safe unknown-value handling for remaining gamepad enum conversions.
- [ ] Add gamepad typed `Properties` and `BindingIterator` APIs.
- [ ] Add typed joystick properties and receiver property access.
- [x] Add typed sensor `Id` and optional-safe `Type` conversion.
- [x] Add net `Timeout.toSdl`, `Status` conversions, and `Version` value accessors.
- [ ] Add complete net `Timeout`/`Version` `fromSdl`/`toSdl` conversions.
- [ ] Normalize net receiver naming and conversion methods across address, socket, server, and
      local-address result types.
- [x] Add typed GPU descriptor defaults and conversions.
- [ ] Add complete GPU buffer/texture create-info `fromSdl`/`toSdl` round-trip conversions.
- [ ] Add fallible GPU descriptor `toSdl` conversions where nested values can be invalid.
- [x] Add GPU buffer/texture usage conversions.
- [x] Add GPU buffer/texture location conversions.
- [x] Add GPU buffer/texture region conversions.
- [x] Add GPU texture and buffer format conversions.
- [ ] Add GPU buffer/texture create-info defaults.
- [x] Add GPU pipeline, rasterizer, depth, and sampler state conversion/default wrappers.
- [x] Add message-box `BoxData` value and conversion.
- [x] Add message-box `BoxFlags`, `Button.Flags`, and `ColorScheme` values.
- [ ] Add message-box `ColorScheme.fromSdl` conversion.
- [x] Add `message_box.Color.fromHex`.
- [ ] Add usable defaults for message-box and remaining public descriptor values.
- [x] Add TTF text records, colors, and flags conversions/defaults.
- [ ] Add TTF GPU-atlas facade values and conversions/defaults.
- [x] Add mixer duration, loop, and `PlayOptions` value/default types.
- [ ] Add complete mixer duration/loop and `PlayOptions` `fromSdl`/`toSdl` conversions.
- [x] Add haptic `Direction` and `Features` conversions.
- [x] Add haptic `Effect` conversion/default.
- [x] Add haptic constant, periodic, condition, ramp, left-right, and custom effect variant
      conversions.
- [x] Add video `VSync` value conversion.
- [ ] Add audio `Spec.fromSdl`/`toSdl` conversions and typed audio configuration defaults.
- [ ] Add audio `Format.define`, size/name/silence helpers, and signedness/endian/integer/floating
      predicates.
- [ ] Add receiver-oriented audio device format, channel-map, gain, pause, classification, binding,
      and postmix methods.
- [x] Add `audio.Device.deinit`/`close` ownership cleanup.
- [ ] Return typed physical/logical audio devices from playback and recording enumeration helpers.
- [ ] Add camera `Id.getName`, `getPosition`, and `getSupportedFormats` methods.
- [ ] Add typed video display name, bounds, orientation, scale, and mode query methods.
- [ ] Add video `Display.Mode` and `Display.Orientation` conversions.
- [ ] Add typed video `Display`/`WindowId` enumeration and checked result values.
- [ ] Add typed video window create properties, flags, position, and properties values.
- [ ] Add owned `video.gl.Context.init`/`deinit` facade.
- [x] Add dialog `FileFilter` values and conversion.
- [ ] Add `dialog.Properties.toSdl`/`fromSdl` conversion helpers.
- [ ] Use typed dialog properties in a dialog operation and verify the resulting native property
      record.
- [ ] Add explicit borrowed/copied or allocator-aware ownership for dialog file/folder callback
      paths and results.
- [ ] Add typed dialog `Type` values and checked dialog result helpers.
- [x] Add typed process property values.
- [x] Add typed process `Io` values.
- [ ] Add `process.CreateProperties.toProperties` and `process.Properties.fromSdl`/`toSdl`
      conversion helpers.

## 3. Lifecycle and ownership facade

- [x] Add `video.Window.Options` and `Window.init`.
- [x] Add `video.Window.initWithProperties` and `deinit` naming alias.
- [x] Add `render.Renderer.Options` and `Renderer.init`.
- [x] Add `Renderer.initGpu`, `initSoftwareRenderer`, and `initWithWindow`.
- [x] Add renderer receiver texture creation methods.
- [ ] Add receiver aliases for remaining common operations such as `Window.setTitle`,
      `Texture.setScaleMode`, and bulk `Stream.read`.
- [x] Add `render.Texture.Options` and renderer-owned texture creation.
- [ ] Add explicit renderer-parent ownership and lifetime tracking for `render.Texture`.
- [x] Add `surface.Surface.init`, `initFrom`, `initFromFile`, and `initFromIo`.
- [ ] Add `surface.Surface.Options` and typed source/configuration conversions.
- [x] Add surface `Flags`, `FlipMode`, and `ScaleMode` facade values.
- [ ] Add typed surface BMP and PNG IO loaders.
- [ ] Add typed surface BMP and PNG file/path loader overloads.
- [ ] Add typed surface BMP/PNG save helpers and explicit output/IO ownership modes.
- [ ] Add typed surface properties/configuration conversion helpers.
- [x] Add `audio.Device` physical/logical type and `Device.open`.
- [x] Add raw `audio.Device.openStream` receiver bridge.
- [ ] Return the facade `audio.Stream` from `Device.openStream` with explicit ownership semantics.
- [x] Add `audio.Stream.Options`, `Stream.init`, and `deinit`.
- [ ] Add typed video hit-test callback userdata.
- [x] Add `camera.Camera.init` and `deinit` alias for `close`.
- [x] Add `camera.Specification` conversion.
- [ ] Add typed `camera.Id` conversion and return typed IDs from camera enumeration results.
- [ ] Add camera specification defaults and checked validation for descriptor values.
- [x] Add `gpu.Device.Options` and `Device.init`.
- [x] Add `io_stream.Stream.initFromFile` with `FileMode`.
- [x] Add `io_stream.Stream.initFromConstMem`.
- [x] Add `io_stream.Stream.initFromMem`.
- [x] Add `io_stream.Stream.initFromDynamicMem`.
- [x] Add `io_stream.Stream.initFromFsFile`.
- [ ] Add `io_stream.Stream.initFromReaderWriter` for native Zig reader/writer pairs.
- [x] Add `io_stream.Stream.deinit` and ownership mode names.
- [x] Add `async_io.File.init` with `IoMode`.
- [ ] Add the complete four-value `async_io.IoMode` set and explicit mode-string mappings.
- [x] Add `async_io.File.getSize`.
- [x] Add `async_io.Queue.init`, `deinit`, and `closeFile`.
- [x] Add `async_io.Queue.loadFile`.
- [x] Add `filesystem.Path.init`, `get`, and `deinit`.
- [x] Add `filesystem.Path.baseName`, `join`, and `parent`.
- [x] Add filesystem `PathType`, `PathInfo`, and `GlobFlags` value APIs.
- [x] Add typed filesystem path-info and glob results.
- [x] Add typed filesystem directory enumeration results.
- [x] Add filesystem item-list ownership and `freeAllDirectoryItems`.
- [x] Add `properties.Group.init`, `deinit`, and `fromSdl`/`toSdl`.
- [x] Add typed `properties.Property` values and get/set operations.
- [ ] Add `properties.Group.getAll` and `clear` value APIs.
- [x] Add properties locking and copying.
- [ ] Add the `properties.Group.enumerateProperties` receiver API.
- [x] Add properties pointer cleanup callback ownership.
- [ ] Add typed properties cleanup and enumeration callback factories.
- [x] Add `storage.Path` ownership and path operations.
- [x] Add `storage.Storage.init`, `initFile`, `initTitle`, and `initUser`.
- [x] Add `storage.Storage.deinit` and explicit path ownership.
- [ ] Add `storage.Storage.getFileSize` and receiver filesystem operations.
- [x] Add `timer.Timer.initMilliseconds` and `initNanoseconds`.
- [x] Add `timer.Timer.deinit`.
- [ ] Add timer millisecond/nanosecond delay and conversion helpers.
- [ ] Add optional-safe `timer.Timer.fromSdl`/`toSdl` conversion.
- [x] Add `tray.Tray.init` and `deinit`.
- [x] Expose tray `Menu`/`Entry` handles and the `Tray` menu relationship.
- [ ] Add tray `EntryFlags.toSdl` conversion and typed menu insertion/submenu operations.
- [x] Add `process.Process.init` and `initWithProperties`.
- [x] Add process receiver `getInput`/`getOutput`, wait, and kill methods.
- [ ] Add `Process.read` and complete receiver I/O result/stream ownership methods.
- [x] Add `joystick.Joystick.init`, `deinit`, and `initVirtual`.
- [x] Add `joystick.deinitVirtual`.
- [x] Add `gamepad.Gamepad.init` and `deinit` naming aliases.
- [x] Add gamepad opened-device versus identifier types.
- [ ] Add gamepad receiver button/axis, mapping, sensor, rumble, LED, and player-index methods.
- [ ] Return typed gamepad and joystick identifiers from enumeration helpers.
- [ ] Add joystick receiver axis/button/hat/ball, mapping, sensor, and rumble methods.
- [x] Add `haptic.Haptic.init`, `initFromJoystick`, and `initFromMouse`.
- [x] Add `haptic.Haptic.initRumble` and `deinit`.
- [x] Add HID subsystem `init` and `deinit`.
- [x] Add `hid_api.Device.init`, `initPath`, and `deinit`.
- [x] Add owned HID enumeration.
- [ ] Add typed HID `DeviceInfo` conversion/record helpers.
- [x] Add `sensor.Sensor.init`, `deinit`, and receiver data access.
- [x] Add `thread.Thread.init` and `initWithProperties`.
- [x] Add thread receiver `wait` and `detach`.
- [x] Add `thread.TlsId.init`.
- [x] Add `mutex.Mutex.init`/`deinit`.
- [x] Add `mutex.Condition.init`/`deinit`.
- [x] Add `mutex.RwLock.init`/`deinit`.
- [x] Add `mutex.Semaphore.init`/`deinit`.
- [x] Add `mouse.Cursor.init`, `initAnimated`, `initColor`, and `initSystem`.
- [x] Add `image.Animation.init` and `deinit`.
- [ ] Add `image.Animation.initFromFile` and file-owned animation construction.
- [x] Add image generic, typed, GIF, and WEBP IO constructors.
- [ ] Add explicit owned/borrowed image IO constructor names and ownership modes.
- [x] Add image format-specific IO load/save helpers.
- [ ] Add image format-specific file/path load/save helpers.
- [x] Add mixer `Mixer` and `Audio` constructor coverage.
- [ ] Add mixer `Track`/`Group` constructor and resource matrix coverage.
- [x] Add mixer `Audio` IO, raw, and no-copy constructors.
- [ ] Add explicit raw-no-copy/borrowed naming for mixer `Audio` construction.
- [ ] Add remaining mixer resource IO, raw, no-copy, and borrowed constructors.
- [x] Add mixer receiver creation and cleanup methods.
- [ ] Add explicit Mixer-parent ownership and lifetime tracking for mixer Track, Group, and Audio
      resources.
- [ ] Add generic mixer callback factories and typed playback callback userdata.
- [x] Add TTF `Font` and text-engine constructor/deinit aliases.
- [x] Add Metal `View.init`/`deinit`.
- [ ] Make `metal.View.init` checked or optional-safe for failed native view creation.
- [x] Add Vulkan `Surface.init`/`deinit`.
- [ ] Add checked Vulkan library/proc-address helpers around the generated functions.

## 4. IO, callbacks, and result shapes

- [x] Add `io_stream.Interface(UserData)` typed callback table.
- [x] Add `io_stream.Reader` buffered adapter.
- [x] Add `io_stream.Writer` buffered adapter.
- [x] Add checked scalar IO read/write methods.
- [x] Add `io_stream.loadFile` and `saveFile`.
- [x] Add generic audio callback factories with typed userdata.
- [ ] Add typed audio postmix, stream-data-complete, and device-binding callback factories.
- [x] Add generic assertion callback handler.
- [ ] Add typed assertion report/state values and reset/report operations.
- [x] Add generic clipboard `DataCallback(UserData)`.
- [ ] Add generic clipboard `CleanupCallback(UserData)`.
- [x] Add generic event `Filter(UserData)`.
- [ ] Add `events.Iterator`, `iterator`, `eventIn`, `minMax`, event groups, `flushGroup`, and
      `hasGroup` helpers.
- [x] Add generic filesystem enumeration callback.
- [x] Add generic hints callback.
- [x] Add generic log output callback.
- [x] Add generic system/X11 event hook callback.
- [ ] Add generic system lifecycle callback adapters beyond the X11 event hook.
- [x] Add generic thread function callback.
- [x] Add generic millisecond and nanosecond timer callbacks.
- [x] Add generic tray callback.
- [x] Add generic storage directory-enumeration callback adapter.
- [ ] Expose the canonical `storage.Interface(UserData)` callback factory.
- [x] Add generic virtual joystick callback descriptor.
- [x] Add generic dialog file callback.
- [x] Add generic typed SDL main `App(UserData)` callbacks.
- [ ] Document callback userdata lifetime and trampoline storage requirements in
      `docs/callback-lifetimes.md`, including stable trampoline storage, temporary userdata, and
      unregister/teardown rules.
- [x] Add selected callback compile-time instantiation and invocation tests; keep this explicitly
      narrower than the complete callback matrix below.
- [ ] Add callback matrix tests for audio postmix/completion, clipboard cleanup, mouse motion,
      properties cleanup/enumeration, and platform lifecycle hooks.
- [x] Add allocator-aware copied audio device enumeration.
- [x] Add allocator-aware copied camera enumeration.
- [x] Add allocator-aware clipboard sentinel string result.
- [x] Add allocator-aware filesystem and storage path results.
- [x] Add typed net `getLocalAddresses` ownership result.
- [x] Add `net.Pollable` union and `waitUntilInputAvailable` slice API.
- [x] Add tagged `events.Event` union.
- [x] Add typed event payloads for window, display, keyboard, mouse, touch, camera, controller, pen,
      sensor, and drop-file events.
- [ ] Add `fromSdl`/`toSdl` round-trip methods to every tagged event payload while retaining
      raw-event access.
- [x] Add event `poll() ?Event` facade.
- [x] Add event `waitAndPop() !Event` facade.
- [x] Define borrowed versus copied drop-file string ownership.
- [ ] Add event payload round-trip conversion tests after `fromSdl`/`toSdl` implementation.

## 5. Platform, utility, and adjunct coverage

- [x] Add focused `atomic.Int`, `atomic.U32`, and `atomic.Spinlock` receiver methods.
- [x] Add discoverable `bits`, `cpu_info`, `endian`, and `intrin` root modules.
- [x] Add named SIMD capability constants where target policy permits.
- [x] Add focused `platform_api`, `loadso_api`, `system_api`, and `version_api` aliases.
- [ ] Add direct root aliases for the remaining focused utility and integration modules
      (`clipboard`, `dialog`, `haptic`, `hints`, `io_stream`, `locale`, `loadso`, `log`, `main`,
      `metal`, `misc`, `platform`, `process`, `storage`, and `system`) while retaining their
      explicit `*_api` facade names where present.
- [x] Add owned `loadso.SharedObject` init/symbol/deinit facade.
- [x] Add typed keyboard text-input properties conversion.
- [ ] Add `cpu_info` SIMD feature predicates, typed system-size results, and normalized return
      shapes.
- [ ] Add focused `endian.ByteOrder` values and conversion helpers.
- [ ] Add typed hint priority/type values and checked priority-setting helpers.
- [ ] Add typed log priority/category values and checked callback-installation helpers.
- [ ] Add typed thread state and priority values.
- [ ] Add typed `misc.openUrl` error/result facade.
- [ ] Add a checked `platform.get` result facade alongside the direct platform alias.
- [x] Add grouped mouse global/relative state result values.
- [ ] Add the grouped mouse local `getState` result value.
- [ ] Add the mouse `MotionTransformCallback(UserData)` adapter.
- [x] Add owned grouped touch and sensor enumeration result wrappers.
- [ ] Return typed `touch.Id` and `sensor.Id` values from enumeration results.
- [x] Add typed joystick `ConnectionState` conversion.
- [ ] Add filesystem `getSeparator` and typed path-separator helpers.
- [x] Add focused `Init.init`/`deinit` subsystem facade.
- [ ] Add direct root `init`/`quit` aliases alongside the focused `Init` facade.
- [x] Add typed main `runApp`/`enterAppMainCallbacks` facade.
- [ ] Export the typed app-main facade under a canonical root `main` module.
- [ ] Add root main helpers for memory/environment operations and UTF-8 iterators.
- [x] Add runtime shader metadata loading and compatibility validation.
- [x] Add embedded and directory shader loaders.
- [x] Add shader metadata field lookup helpers.
- [x] Add `extras.FramerateCapper`.
- [x] Add reusable error handlers and loggers under `extras`.
- [ ] Expose shader metadata loading, compatibility validation, and asset loaders through the root
      `extras` helper namespace.
- [x] Add examples for callbacks and userdata ownership.
- [x] Add examples for custom IO and allocators.
- [x] Add examples for filesystem, properties, storage, and dialogs.
- [x] Add examples for GPU, renderer, TTF, mixer, networking, tray, and shadercross.
- [ ] Add examples for message boxes, logging, app-main callbacks, and runtime shader compatibility.

## 6. Verification and migration

- [ ] Add black-box compile tests for every implemented facade type at the package/source
      distribution boundary; source-text checks and a general build are insufficient.
- [ ] Add lifecycle success/failure tests for every implemented constructor family.
- [ ] Add ownership tests for copied, borrowed, dynamic, and no-copy inputs.
- [ ] Add enum/flag unknown-value and round-trip tests for implemented value facades.
- [ ] Add callback userdata and teardown tests for implemented callback adapters.
- [x] Add allocator leak/double-free regression tests.
- [x] Add migration aliases without removing generated C-shaped functions.
- [ ] Update a hand-written public facade API coverage inventory after implementation; generated SDL
      declaration coverage in `COVERAGE.md` does not satisfy this item.
- [ ] Re-run the full API comparison when the upstream tip or pinned SDL family changes; do not
      treat upstream source changes as documentation-only changes.
- [ ] Run formatter and formatter check, including `TODO.md`.
- [x] Run lint and typecheck.
- [ ] Run metadata, source, binding, build, and shader tests.
  - Blocked on this Windows host: pinned `.mise-bins` clang/CastXML are unusable; direct library
    binaries run, but clang omits expected FormatAttr fields and CastXML lacks `vcruntime.h`.
    Metadata/source/shader sub-gates pass.
- [ ] Run the complete repository check pipeline.
  - Blocked by the binding and build prerequisites above; do not mark complete until both pass.
- [ ] Run release-check and record any unavailable cross-target gates.
  - Release check ran: release archive requires GNU tar under Linux, macOS, or WSL; WSL is not
    enabled on this host. Binding prerequisites also fail as recorded above.
