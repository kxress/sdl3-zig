# API improvement implementation checklist

This checklist is derived from every concrete item in `IMPROVEMENTS.md`. It is dependency ordered.
Execute exactly one unchecked box at a time; mark it complete only after that exact change and its
listed verification are complete. Generated bindings remain inputs, not hand-edited targets.

## 1. Public facade foundation

- [x] Add direct root aliases for `assert`, `async_io`, `atomic`, `audio`, `camera`, `events`,
      `filesystem`, `gamepad`, `gpu`, `image`, `io_stream`, `joystick`, `mixer`, `mutex`, `net`,
      `pixels`, `properties`, `render`, `surface`, `thread`, `ttf`, `timer`, `tray`, `video`, and
      `vulkan` while retaining `core`.
- [x] Add canonical `async_io`, `io_stream`, `blend_mode`, `hid_api`, and `message_box` aliases.
- [x] Add a facade error module with one public error set.
- [x] Implement `errors.wrapCall` for scalar failure returns.
- [x] Implement `errors.wrapCallBool` for boolean failures.
- [x] Implement `errors.wrapCallPtr` for nullable pointers.
- [x] Implement `errors.wrapCallCString` for nullable C strings.
- [x] Implement negative-count validation in the error facade.
- [x] Add compile-time tests for each error wrapper shape.
- [x] Add a facade test importing every direct root alias.
- [x] Add a public `fromSdl`/`toSdl` policy helper convention.
- [x] Add unknown-enum-to-optional conversion helpers.
- [x] Add checked enum-to-SDL conversion helpers.
- [x] Add allocator ownership conventions for copied slices and sentinel strings.
- [x] Add a facade test for borrowed versus copied return documentation contracts.

## 2. Core value types and conversions

- [x] Implement generic `Point(T)` with `asOther`, `empty`, `equal`, and containment helpers.
- [x] Implement generic `Rect(T)` with `asOther`, `empty`, `equal`, and geometry helpers.
- [x] Add `FPoint`, `IPoint`, `FRect`, and `IRect` aliases.
- [x] Add enclosing and intersection receiver methods for rectangles.
- [x] Add pixel `Format.fromSdl` and `Format.toSdl`.
- [x] Add pixel format predicates and `details` helpers.
- [x] Add typed pixel order, range, primaries, matrix, and transfer conversions.
- [x] Add owned `pixels.Palette.init`.
- [x] Add owned `pixels.Palette.deinit`.
- [x] Add blend `Factor.fromSdl`/`toSdl`.
- [x] Add blend `Operation.fromSdl`/`toSdl`.
- [x] Add blend `Mode.fromSdl`/`toSdl` and predicates.
- [x] Add `keycode.Keycode` optional-safe conversion.
- [x] Add keycode scancode and extended predicates.
- [x] Add `keycode.KeyModifier` named modifier predicates.
- [x] Add optional-safe `scancode.Scancode` conversion and name/value helpers.
- [x] Add `guid.Guid.fromString`.
- [x] Add checked `guid.Guid.toString` with ownership semantics.
- [x] Add `version.Version.make` and packed component accessors.
- [x] Add `version.Version.get` and `atLeast`.
- [x] Add time `DateTime.fromSdl`/`toSdl`.
- [x] Add time `Time.fromSdl`/`toSdl` and current-time helpers.
- [x] Add Windows time conversion helpers.
- [x] Add typed date, month, and format conversions.
- [x] Add optional-safe power-state conversion.
- [x] Add packed pen `Axis`, `Id`, and `InputFlags` conversions.
- [x] Add optional-safe pen `DeviceType` conversion.
- [x] Add packed touch `Id`, `FingerId`, and `Finger` conversions.
- [x] Add packed joystick `Id`, `AxisMask`, and `ButtonMask` conversions.
- [x] Add packed mouse `Id` and `ButtonFlags` conversions/predicates.
- [x] Add packed keyboard `Id` and grouped text-input state.
- [x] Add typed gamepad `Axis`, `Button`, `Binding`, `BindingType`, `ButtonLabel`, and `Type`.
- [x] Add optional-safe gamepad enum conversions.
- [x] Add typed sensor `Id` and optional-safe `Type` conversion.
- [x] Add net `Timeout`, `Status`, and `Version` conversions.
- [x] Add typed GPU descriptor defaults and conversions.
- [x] Add GPU buffer/texture usage conversions.
- [x] Add GPU buffer/texture location conversions.
- [x] Add GPU buffer/texture region conversions.
- [x] Add GPU texture and buffer format conversions.
- [x] Add GPU create-info defaults.
- [x] Add GPU pipeline, rasterizer, depth, and sampler state conversion/default wrappers.
- [x] Add message-box `BoxData` value and conversion.
- [x] Add message-box `BoxFlags`, `Button.Flags`, and `ColorScheme` values.
- [x] Add `message_box.Color.fromHex`.
- [x] Add TTF text records, colors, flags, and GPU atlas conversions/defaults.
- [x] Add mixer duration, loop, and `PlayOptions` conversions/defaults.
- [x] Add haptic `Direction` and `Features` conversions.
- [x] Add haptic `Effect` conversion/default.
- [x] Add haptic constant, periodic, condition, ramp, left-right, and custom effect variant
      conversions.
- [x] Add video `VSync` value conversion.
- [x] Add dialog `FileFilter` and typed properties.
- [x] Add process properties conversion.

## 3. Lifecycle and ownership facade

- [x] Add `video.Window.Options` and `Window.init`.
- [x] Add `video.Window.initWithProperties` and `deinit` naming alias.
- [x] Add `render.Renderer.Options` and `Renderer.init`.
- [x] Add `Renderer.initGpu`, `initSoftwareRenderer`, and `initWithWindow`.
- [x] Add renderer receiver texture creation methods.
- [x] Add `render.Texture.Options` and explicit parent ownership.
- [x] Add `surface.Surface.init`, `initFrom`, `initFromFile`, and `initFromIo`.
- [x] Add typed surface BMP and PNG loaders.
- [x] Add surface `Flags`, `FlipMode`, and `ScaleMode` facade values.
- [x] Add `audio.Device` physical/logical type and `Device.open`.
- [x] Add `audio.Device.openStream`.
- [x] Add `audio.Stream.Options`, `Stream.init`, and `deinit`.
- [x] Add `camera.Camera.init` and `deinit` alias for `close`.
- [x] Add `camera.Specification` conversion and typed camera enumeration.
- [x] Add `gpu.Device.Options` and `Device.init`.
- [x] Add `io_stream.Stream.initFromFile` with `FileMode`.
- [x] Add `io_stream.Stream.initFromConstMem`.
- [x] Add `io_stream.Stream.initFromMem`.
- [x] Add `io_stream.Stream.initFromDynamicMem`.
- [x] Add `io_stream.Stream.initFromFsFile`.
- [x] Add `io_stream.Stream.deinit` and ownership mode names.
- [x] Add `async_io.File.init` with `IoMode`.
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
- [x] Add properties enumeration, locking, and copying.
- [x] Add properties pointer cleanup callback ownership.
- [x] Add `storage.Path` ownership and path operations.
- [x] Add `storage.Storage.init`, `initFile`, `initTitle`, and `initUser`.
- [x] Add `storage.Storage.deinit` and explicit path ownership.
- [x] Add `timer.Timer.initMilliseconds` and `initNanoseconds`.
- [x] Add `timer.Timer.deinit`.
- [x] Add `tray.Tray.init` and `deinit`.
- [x] Add `tray.Menu` and `tray.Entry` receiver object graph.
- [x] Add `process.Process.init` and `initWithProperties`.
- [x] Add process receiver I/O, wait, kill, and stream ownership.
- [x] Add `joystick.Joystick.init`, `deinit`, and `initVirtual`.
- [x] Add `joystick.deinitVirtual`.
- [x] Add `gamepad.Gamepad.init` and `deinit` naming aliases.
- [x] Add gamepad opened-device versus identifier types.
- [x] Add `haptic.Haptic.init`, `initFromJoystick`, and `initFromMouse`.
- [x] Add `haptic.Haptic.initRumble` and `deinit`.
- [x] Add HID subsystem `init` and `deinit`.
- [x] Add `hid_api.Device.init`, `initPath`, and `deinit`.
- [x] Add owned HID enumeration and typed `DeviceInfo`.
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
- [x] Add image generic, typed, GIF, and WEBP IO constructors.
- [x] Add image format-specific load/save helpers.
- [x] Add mixer `Mixer`, `Track`, `Group`, and `Audio` constructor matrices.
- [x] Add mixer IO, raw, no-copy, and explicit borrowed constructors.
- [x] Add mixer receiver ownership and callback cleanup.
- [x] Add TTF `Font` and text-engine constructor/deinit aliases.
- [x] Add Metal `View.init`/`deinit`.
- [x] Add Vulkan `Surface.init`/`deinit`.
- [x] Add checked Vulkan library/proc-address helpers.

## 4. IO, callbacks, and result shapes

- [x] Add `io_stream.Interface(UserData)` typed callback table.
- [x] Add `io_stream.Reader` buffered adapter.
- [x] Add `io_stream.Writer` buffered adapter.
- [x] Add checked scalar IO read/write methods.
- [x] Add `io_stream.loadFile` and `saveFile`.
- [x] Add generic audio callback factories with typed userdata.
- [x] Add generic assertion callback handler.
- [x] Add generic clipboard `DataCallback(UserData)`.
- [x] Add generic event `Filter(UserData)`.
- [x] Add generic filesystem enumeration callback.
- [x] Add generic hints callback.
- [x] Add generic log output callback.
- [x] Add generic system/X11 event hook callback.
- [x] Add generic thread function callback.
- [x] Add generic millisecond and nanosecond timer callbacks.
- [x] Add generic tray callback.
- [x] Add generic storage callback interface.
- [x] Add generic virtual joystick callback descriptor.
- [x] Add generic dialog file callback.
- [x] Add generic typed SDL main `App(UserData)` callbacks.
- [x] Document callback userdata lifetime and trampoline storage requirements.
- [x] Add callback compile-time type and invocation tests.
- [x] Add allocator-aware copied audio device enumeration.
- [x] Add allocator-aware copied camera enumeration.
- [x] Add allocator-aware clipboard sentinel string result.
- [x] Add allocator-aware filesystem and storage path results.
- [x] Add typed net `getLocalAddresses` ownership result.
- [x] Add `net.Pollable` union and `waitUntilInputAvailable` slice API.
- [x] Add tagged `events.Event` union.
- [x] Add typed event payloads for window, display, keyboard, mouse, touch, camera, controller, pen,
      sensor, and drop-file events.
- [x] Add event `poll() ?Event` facade.
- [x] Add event `waitAndPop() !Event` facade.
- [x] Define borrowed versus copied drop-file string ownership.
- [x] Add event round-trip conversion tests.

## 5. Platform, utility, and adjunct coverage

- [x] Add focused `atomic.Int`, `atomic.U32`, and `atomic.Spinlock` receiver methods.
- [x] Add discoverable `bits`, `cpu_info`, `endian`, and `intrin` root modules.
- [x] Add named SIMD capability constants where target policy permits.
- [x] Add focused `platform`, `loadso`, `system`, and `version` root aliases.
- [x] Add owned `loadso.SharedObject` init/symbol/deinit facade.
- [x] Add typed keyboard text-input properties conversion.
- [x] Add grouped mouse global/relative state result values.
- [x] Add grouped touch and sensor enumeration results.
- [x] Add focused `Init.init`/`deinit` subsystem facade.
- [x] Add typed main `runApp`/`enterAppMainCallbacks` facade.
- [x] Add runtime shader metadata loading and compatibility validation.
- [x] Add embedded and directory shader loaders.
- [x] Add shader metadata field lookup helpers.
- [x] Add `extras.FramerateCapper`.
- [x] Add reusable error handlers and loggers under `extras`.
- [x] Add examples for callbacks and userdata ownership.
- [x] Add examples for custom IO and allocators.
- [x] Add examples for filesystem, properties, storage, and dialogs.
- [x] Add examples for GPU, renderer, TTF, mixer, networking, tray, and shadercross.

## 6. Verification and migration

- [x] Add black-box compile tests for every new facade type.
- [x] Add lifecycle success/failure tests for every constructor family.
- [x] Add ownership tests for copied, borrowed, dynamic, and no-copy inputs.
- [x] Add enum/flag unknown-value and round-trip tests.
- [x] Add callback userdata and teardown tests.
- [x] Add allocator leak/double-free regression tests.
- [x] Add migration aliases without removing generated C-shaped functions.
- [x] Update public API coverage inventory after implementation.
- [x] Run formatter and formatter check.
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
