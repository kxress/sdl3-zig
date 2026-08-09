# API improvements to consider

Compared with the current tip of [7Games/zig-sdl3](https://codeberg.org/7Games/zig-sdl3) (commit
`69cf1fba30b39fe0a140fc2139d403692e650d16`, 2026-07-14), our package already has broad generated SDL
coverage, typed handle aliases, many `deinit`/`close` methods, checked result wrappers, named output
structs, and several companion-library wrappers. The Codeberg project is ahead mainly in the
consistency and breadth of its hand-written ergonomic layer. The list below records concrete public
API differences, not general style suggestions. “Add” means add an ergonomic facade while retaining
our generated ABI layer.

The comparison scope is the complete public source surface at that commit: 64 top-level `src/*.zig`
modules plus the 6 public files under `src/extras/`, compared with the 58 generated core namespaces
in our `src/sdl.zig` and our separately exported companion modules. Every Codeberg module is listed
in the declaration audit below, including modules where no material advantage was found. The audit
compares exported types, methods, constructors, conversions, callback factories, ownership, and
return shapes; it does not compare documentation or function bodies.

## High-value API gaps

- **Resource structs with lifecycle constructors.** `video.Window`, `render.Renderer`,
  `render.Texture`, `surface.Surface`, `audio.Stream`, `camera.Camera`, `gpu.Device`,
  `io_stream.Stream`, `async_io.Queue`, `hid_api.Device`, and `ttf.Font` are public types with
  methods such as `init`/`open` and `deinit`/`close`. We already expose many corresponding handle
  types and cleanup methods, but construction is generally a module-level `create*`/`open*` function
  and the naming is inconsistent (`close` versus `deinit`). Add receiver-oriented constructors and
  normalize lifecycle names; include the additional public types `async_io.File`, `audio.Device`,
  `filesystem.Path`, `properties.Group`, `storage.Path`, `timer.Timer`, and `tray.Menu`.

- **Typed construction options.** Their `render.Renderer`, `render.Texture`, `video.Window`,
  `surface.Surface`, `audio.Stream`, and `gpu.Device` APIs accept Zig config structs and translate
  them to SDL properties/specs. This avoids passing raw property IDs and nullable C pointers at
  every call site. We should provide `Window.Options`, `Renderer.Options`, `Texture.Options`,
  `Audio.Stream.Options`, and similar `toSdl` conversions.

- **Properties as a safe value API.** `properties.Group` is an owned wrapper with typed
  getters/setters; property-bearing config structs throughout `gpu`, `video`, `render`, `audio`,
  `mixer`, `ttf`, `gamepad`, and `joystick`. Our generated API exposes the raw `SDL_PropertiesID`
  operations. Add a `Properties` wrapper with typed `set/get`, ownership, and `deinit` semantics.

- **More uniform result-oriented error handling.** The competitor consistently turns SDL failure
  returns into Zig errors (`!T`) and centralizes conversion in `errors.wrapCall*` helpers (for
  example, `audio.getPlaybackDevices() ![]Device`, `camera.getCameras() ![]Id`, and
  `clipboard.getText() ![:0]u8`). Our generator already adds many `Error!` wrappers, so this is a
  consistency gap: add a public central conversion layer, use one error set, and cover nullable
  pointers, C strings, negative counts, and boolean failures uniformly. Keep raw generated functions
  available.

- **Owned slice/string results.** Functions such as `audio.getPlaybackDevices()` and
  `camera.getCameras()` return Zig slices, and text APIs return sentinel slices with documented
  ownership. We should provide allocator-aware variants that copy SDL-owned arrays/strings and make
  the required release operation impossible to overlook.

- **Root-level API organization.** Their `src/` splits domains into `video`, `render`, `surface`,
  `audio`, `camera`, `gpu`, `io_stream`, `async_io`, `properties`, `events`, etc., with a small
  `sdl3.zig` root. Our `src/sdl.zig` does expose most of the same domains, but the package root
  places them under `core` and uses inconsistent spellings such as `asyncIo`, `ioStream`,
  `blendmode`, `hidApi`, and `messagebox`. Add stable root-level re-exports and canonical snake-case
  module names so the facade is searchable without knowing generator names.

- **Value types with conversion/utility methods.** `audio.Spec`, `camera.Specification`, blend-mode
  types, GPU descriptors, and event records implement `fromSdl`/`toSdl`; formats and flags also
  expose named constants and predicates. Many of our records are still ABI mirrors. Generate
  conversion methods and small value-level helpers for descriptors, flags, and enums.

- **Callback adapters.** Their callback APIs use `Handler(comptime UserData: type)` and generate
  trampoline functions that recover typed user data (for assertions, clipboard, audio, and dialogs).
  Our callbacks remain raw C function pointers. Add typed callback adapters with compile-time
  user-data types and a clearly documented lifetime rule.

These should be implemented as an opt-in hand-written facade over generated bindings. Keeping the
generated layer intact preserves ABI fidelity and reproducibility while allowing the facade to
evolve independently.

## Additional concrete advantages

- **First-class `SDL_IOStream` adapters.** `io_stream.Stream` has constructors for files, constant
  memory, dynamic memory, arbitrary memory, and Zig reader/writer pairs (`initFromFile`,
  `initFromMem`, `initFromReaderWriter`, etc.). It also supplies buffered `Reader` and `Writer`
  structs plus `loadFile`/`saveFile`. This is a substantial improvement over exposing only SDL's
  callback table and raw stream pointer.

- **Zig synchronization objects.** `mutex.Condition`, `mutex.Mutex`, `mutex.RwLock`, and
  `mutex.Semaphore` are value types with fallible `init`, `deinit`, and idiomatic methods. Add
  equivalent wrappers so users do not manipulate opaque SDL mutex handles manually.

- **Networking is modeled as owned objects.** The `net` module has typed `Address`,
  `DatagramSocket`, `StreamSocket`, `Server`, `LocalAddressList`, and timeout/status values. Sockets
  and address lists expose lifecycle methods, and `Status`/`Timeout` have conversion helpers. Our
  net bindings already have the main socket resource structs and allocator-aware local-address
  copying; add the missing value conversions and normalize the object graph rather than duplicating
  the raw SDL_net surface.

- **Image and surface loading is object-oriented.** `image.Animation` and `surface.Surface` expose
  `init`, `initFromIo`, typed format loaders, `save*`, and `deinit`; the image API includes
  GIF/WEBP-specific constructors. Add typed image/surface ownership and IO overloads rather than
  making callers compose raw `IMG_Load*` calls and destroy functions.

- **Mixer has an actual object graph.** Their `mixer` module models `Mixer`, `Track`, `Group`, and
  `Audio` as structs with constructors/destructors, IO/no-copy/raw initialization variants,
  `PlayOptions`, and `fromSdl`/`toSdl` conversions. Our mixer surface is function-oriented and does
  not express which object owns a track or group.

- **Typed flags instead of integer masks.** `mouse.ButtonFlags`, `surface.Flags`,
  `surface.FlipMode`, `pen.InputFlags`, `message_box.BoxFlags`, `message_box.Button.Flags`, and
  `keycode.KeyModifier` provide named fields/constants and `fromSdl`/`toSdl`. We should generate
  packed flag wrappers with `contains`, `with`, and conversion methods for SDL bitfields.

- **Events are decoded into typed records.** Their `events` module defines separate Zig structs for
  window, display, keyboard, mouse, touch, camera, and controller event payloads, rather than
  requiring users to inspect a large ABI union and reinterpret fields themselves. Add typed event
  decoding while preserving access to the raw event union.

- **Typed SDL main callbacks.** `main.zig` provides a generic `App`/callback trampoline with a
  compile-time application-state type and lifecycle hooks. This gives Zig applications a safe way to
  use SDL's callback-based entry point without global state or hand-written C calling convention
  trampolines.

- **Virtual-device and platform adapters.** `joystick.VirtualJoystickDescription(UserData)` converts
  Zig callbacks to SDL's virtual joystick descriptor; `io_stream.Interface(UserData)` does the same
  for custom IO streams. `metal.View` and `vulkan.Surface` wrap native surface creation and
  destruction. These are reusable typed adapters missing from our raw declarations.

- **More complete SDL adjunct coverage.** Their public module set includes `async_io`, `camera`,
  `clipboard`, `dialog`, `hid_api`, `haptic`, `keyboard`, `loadso`, `locale`, `log`, `message_box`,
  `pen`, `power`, `process`, `sensor`, `storage`, `thread`, `time`, `timer`, `touch`, and `tray`,
  each with Zig-level names and errors. We should track these as explicit facade modules and make
  availability/ownership clear, rather than treating the monolithic generated file as the only
  discoverable API.

- **Examples exercise the ergonomic layer.** The repository includes runnable examples for
  callbacks, custom allocators, dialogs, filesystem, GPU, message boxes, networking, properties,
  storage, TTF, and tray APIs, plus renderer/GPU templates. Add small black-box examples for each
  new facade type so lifecycle and error contracts remain tested and documented.

## Lifecycle inventory

The breadth of their public `init`/`deinit` design is substantial:

| Module      | Public type                                 | Constructors                                                | Cleanup  |
| ----------- | ------------------------------------------- | ----------------------------------------------------------- | -------- |
| `video`     | `Window`                                    | `init`, `initWithProperties`                                | `deinit` |
| `render`    | `Renderer`                                  | `init`, `initGpu`, `initSoftwareRenderer`, `initWithWindow` | `deinit` |
| `render`    | `Texture`                                   | renderer `createTexture*` methods                           | `deinit` |
| `surface`   | `Surface`                                   | `init`, `initFrom`, `initFromFile`, `initFromIo`            | `deinit` |
| `audio`     | `Stream`                                    | `init`                                                      | `deinit` |
| `camera`    | `Camera`                                    | `init`                                                      | `deinit` |
| `gpu`       | `Device`                                    | `init`                                                      | `deinit` |
| `io_stream` | `Stream`                                    | file, memory, and reader/writer constructors                | `deinit` |
| `async_io`  | `Queue`                                     | `init`                                                      | `deinit` |
| `image`     | `Animation`                                 | file, IO, GIF, and WEBP constructors                        | `deinit` |
| `mixer`     | `Mixer`, `Track`, `Group`                   | normal, IO, raw, and no-copy constructors                   | `deinit` |
| `process`   | `Process`                                   | `init`, `initWithProperties`                                | `deinit` |
| `joystick`  | `Joystick`                                  | `init`, `initVirtual`                                       | `deinit` |
| `mutex`     | `Mutex`, `Condition`, `RwLock`, `Semaphore` | fallible `init`                                             | `deinit` |
| `mouse`     | `Cursor`                                    | `init`, `initAnimated`, `initColor`, `initSystem`           | `deinit` |

## Smaller but important API advantages

- **Receiver-oriented methods.** Operations such as `renderer.createTexture`,
  `texture.setScaleMode`, `stream.read`, and `window.setTitle` make ownership visible. Add method
  aliases alongside generated C-shaped functions.
- **Explicit ownership modes.** Names such as `initFromMem`, `initFromConstMem`,
  `initFromDynamicMem`, `initNoCopy`, and `initRawNoCopy` distinguish borrowed, copied, and raw
  inputs. Our API should encode those lifetime choices instead of hiding them in pointer params.
- **Native Zig callback interfaces.** `io_stream.Interface(UserData)` and
  `joystick.VirtualJoystickDescription(UserData)` generate typed callback tables and trampolines.
  Generalize this pattern to every callback-bearing API.
- **Optional C values become optionals/errors.** Their conversions map unknown enum values to
  `?Enum` or an error and nullable IDs to `?Id`, instead of exposing invalid integer values.
- **Usable descriptor defaults.** GPU, renderer, audio, camera, message-box, and mixer descriptors
  provide defaults and `toSdl` conversions, including improved GPU texture defaults in the latest
  commit. Add default constructors so callers specify only non-default options.
- **Release-aware helpers.** `loadFile`, device enumeration, local address lists, and text helpers
  pair allocation with a documented release/deinit path. Our raw pointers should gain allocator-
  aware, ownership-explicit variants.

## Further verified API advantages

The following are easy to miss when comparing only the main rendering path. They are also public
APIs in the referenced commit and should be included in the backlog:

- **Typed event polling is a real discriminated union.** `events.Event` is a Zig tagged union with
  payload structs such as `WindowMoved`, `Keyboard`, `MouseMotion`, `GamepadButton`, `DropFile`,
  `PenTouch`, `Sensor`, and `TouchFinger`. `events.poll()` returns `?Event`, while `waitAndPop()`
  returns `!Event`. Our `SDL_Event` mirror leaves this decoding and the lifetime of drop-file
  strings to every caller.

- **Filesystem has a path value type.** `filesystem.Path` owns a sentinel path and offers `init`,
  `get`, `baseName`, `join`, `parent`, and `deinit`; `PathInfo` and `GlobFlags` model metadata and
  search options. The module also provides typed `getPathInfo`, `globDirectory`,
  `enumerateDirectory`, `getAllDirectoryItems`, and `freeAllDirectoryItems` helpers. Our filesystem
  bindings expose C strings and raw structs with no path ownership or composition API.

- **Gamepads and joysticks are receiver-oriented objects.** Their `Gamepad` and `Joystick` types
  provide open/close, button/axis queries, mappings, sensors, rumble, LEDs, player index, and
  properties as methods; enumeration returns typed IDs. Add the same distinction between a device
  identifier and an opened device, plus typed mapping/binding records, to our facade.

- **SDL's low-level utilities are wrapped instead of omitted.** Public modules include `atomic`
  (`Int`, `U32`, `Spinlock` and compare/swap operations), `bits` (single-bit and most-significant
  bit helpers), `cpu_info` (feature predicates such as `hasAvx2` and `hasNeon`), `endian`, and
  `intrin`. These are small but useful portability APIs that our generated package does not make
  discoverable as Zig functions.

- **Callbacks are generalized across the whole surface.** In addition to audio and assertions,
  `events.Filter(UserData)`, `clipboard.DataCallback(UserData)`,
  `filesystem.EnumerateDirectoryCallback(UserData)`, `dialog.FileCallback`, and the virtual
  joystick/IO interfaces all provide typed trampolines. We should establish one consistent
  `Handler(UserData)` convention rather than adding one-off adapters.

- **Dialog and platform integrations have typed configuration objects.** `dialog.Properties` and
  `FileFilter` model file dialogs; `metal.View` and `vulkan.Surface` wrap native surface creation;
  `platform`, `loadso`, `system`, and `version` expose named Zig-level operations. Our API mostly
  requires manually assembling SDL property keys and platform-specific C arguments.

- **Reusable non-SDL helpers ship as part of the package.** The `extras` namespace includes typed
  error/log handlers, a `FramerateCapper`, and GPU shader metadata loaders that validate graphics
  and compute shader interfaces (`ensureCompatibleGraphicsShaders`, metadata field lookup, and
  embedded/from-directory loaders). Our shader support currently stops at build-time generation and
  does not provide equivalent runtime validation or frame pacing helpers.

- **Enum and bitfield conversions are systematic.** The competitor's public value types commonly
  implement `fromSdl`/`toSdl`, `format`, and defaults, including pixels, rectangles, blend modes,
  key codes, GUIDs, and GPU descriptors. Unknown C values are handled as optional/invalid cases
  instead of silently becoming an arbitrary Zig enum. We should make this a generator policy for
  every enum, flags type, and descriptor rather than applying it only to selected modules.

- **The root module exposes a deliberate module graph.** `sdl3.zig` re-exports focused modules
  (`assert`, `async_io`, `atomic`, `audio`, `camera`, `events`, `filesystem`, `gamepad`, `gpu`,
  `image`, `io_stream`, `joystick`, `mixer`, `mutex`, `net`, `pixels`, `properties`, `render`,
  `surface`, `thread`, `ttf`, and others), plus `extras`. This makes the ergonomic API searchable
  and lets consumers import only what they use; our public surface remains centered on generated
  monoliths and supplemental modules.

- **Examples cover the facade contracts.** Besides renderer/GPU examples, their examples exercise
  callbacks, custom allocators, filesystem, properties, networking, mixer, dialogs, logging,
  storage, tray, TTF, and shadercross. We need consumer-level examples for ownership, error
  propagation, callback userdata, and each major wrapper so those contracts are tested rather than
  merely documented.

## Whole-module API comparison

This is the module-by-module inventory of the Codeberg public `src/` tree. It is intentionally about
exported types, constructors, methods, conversions, and result shapes; it does not claim that its
function bodies or documentation are better. Modules marked “parity” are included so the backlog
does not mistake organization or naming for missing SDL functionality.

### Core lifecycle and ownership modules

- **`async_io`:** Codeberg has `File.init`/`getSize`; `Queue.closeFile` closes a `File`, and
  fallible `Queue.init`/`deinit` plus `Queue.loadFile` make queue/task ownership explicit. Ours has
  `AsyncIo`, `Queue`, and free `asyncIoFromFile`/`read`/`write`/`loadFileAsync` operations, but no
  `File` facade or receiver constructor. Add `async_io.File` and preserve the queue-owned close
  operation rather than inventing a `File.closeFile` method.
- **`audio`:** Codeberg separates a typed physical/logical `Device` from `Stream`, gives both
  receiver-oriented operations, and adds `Stream.init`, `Device.open`, `Device.openStream`,
  `Spec.fromSdl`/`toSdl`, generic callback factories, and `![]Device` enumeration. Ours has
  `audio.Stream` cleanup and many checked methods, but uses `DeviceId`, module-level open/create
  functions, raw `Spec`, and raw callback userdata. Add the typed device relationship and
  conversions.
- **`camera`:** Codeberg uses `Camera.init`/`deinit`, typed `Specification` conversion, and `![]Id`
  enumeration. Ours has `Camera.close`, `open`, and `Spec`; normalize the names and make the
  specification and device list typed values.
- **`filesystem`:** Codeberg's allocator-backed `Path` supports `init`, `get`, `baseName`, `join`,
  `parent`, and `deinit`; `getSeparator`, `PathInfo`, `PathType`, `GlobFlags`, `EnumerationResult`,
  callback userdata, and list-freeing APIs complete the value layer. Ours exposes `PathInfo` and
  C-string-based directory functions, but no owned `Path` or generic enumeration callback.
- **`gamepad`:** Codeberg's `Gamepad` has `init`/`deinit`, while `Axis`, `Button`, `Binding`,
  `BindingType`, `ButtonLabel`, and `Type` provide typed mapping/value APIs. Ours has a `Gamepad`
  handle with `close` and the raw `GamepadBinding`; add the constructor naming, mapping records,
  optional enum conversion, and explicit opened-device versus ID distinction.
- **`haptic`:** Codeberg has `Haptic.init`, `initFromJoystick`, `initFromMouse`, `initRumble`,
  `deinit`, plus conversion-enabled `Direction`, `Effect`, and `Features`. Ours has `Haptic.close`,
  `initRumble`, and ABI effect records; add the missing constructors and typed effect/flag layer.
- **`hid_api`:** Codeberg has subsystem `init`/`deinit`, `Device.init`/`initPath`/`deinit`, typed
  `DeviceInfo`, and enumeration ownership helpers. Ours has the device handle and close operation
  but not the same facade-level initialization, path constructor, and owned enumeration.
- **`io_stream`:** Codeberg's `Stream.initFromFile`, `initFromConstMem`, `initFromMem`,
  `initFromDynamicMem`, `initFromFsFile`, and `initFromReaderWriter` distinguish ownership;
  `Interface(UserData)`, `Reader`, `Writer`, `loadFile`, and `saveFile` bridge to Zig IO. Ours has
  `IoStream` and raw callback-table operations, but lacks this constructor matrix and Zig stream
  adapters.
- **`joystick`:** Codeberg has packed `Id`, `AxisMask`, `ButtonMask`, `Joystick.init`/`deinit`,
  `initVirtual`, `deinitVirtual`, and `VirtualJoystickDescription(UserData)`. Ours has the joystick
  handle and virtual descriptor records, but not typed IDs/masks or generic callback trampolines.
- **`mutex`:** Codeberg gives `Condition`, `Mutex`, `RwLock`, and `Semaphore` fallible `init`,
  `deinit`, and receiver methods. Ours already has all four handle types and cleanup methods, but
  creation is module-level and the facade lacks the uniform `!Type` constructor contract.
- **`process`:** Codeberg's `Process.init`/`initWithProperties` returns an owned process with
  `read`, `getInput`, `getOutput`, `wait`, `kill`, and typed property conversion. Ours has a
  `Process` handle and cleanup but should add the constructor/property facade and explicit stream
  ownership.
- **`render`:** Codeberg's `Renderer.init`, `initGpu`, `initSoftwareRenderer`, `initWithWindow`, and
  `Texture` creation methods keep the renderer relationship on the object; renderer, texture, and
  GPU-state cleanup are receiver methods. Ours has `Renderer`/`Texture` methods and `deinit`, but
  creation remains free `create*`/property calls and descriptors are raw C-shaped structs. Add
  constructors, options, and parent ownership in the public facade.
- **`sensor`:** Codeberg has typed `Id`, `Sensor.init`/`deinit`, `getData`, and optional enum
  conversions. Ours has a sensor handle and close, but uses raw IDs/enums and module-level open.
- **`storage`:** Codeberg adds an owned `Path`, `Storage.init`, `initFile`, `initTitle`, `initUser`,
  `deinit`, and `Interface(UserData)` callbacks. Ours has `Storage` operations but no path object or
  generic storage callback interface.
- **`surface`:** Codeberg's `Surface.init`, `initFrom`, `initFromFile`, `initFromIo`, typed BMP/ PNG
  loaders, `deinit`, `Flags`, `FlipMode`, and `ScaleMode` make allocation and pixel ownership
  explicit. Ours has `Surface.deinit` and raw loader functions; add the constructor family and typed
  flags/conversions.
- **`thread`:** Codeberg has `Thread.init`, `initWithProperties`, `wait`, `detach`, typed
  `ThreadFunction`, `Id`, `Priority`, `State`, and a `TlsId.init` wrapper. Ours has `Thread` cleanup
  and free creation functions; add receiver constructors and typed callback adapters.
- **`timer`:** Codeberg has a real `Timer` value with `initMilliseconds`, `initNanoseconds`,
  `deinit`, and generic millisecond/nanosecond callbacks. Ours mainly exposes timer IDs and raw
  callback pointers; add the owned timer object and callback userdata adapter.
- **`tray`:** Codeberg models `Tray`, `Menu`, and `Entry` as related objects, with `Tray.init`,
  `deinit`, menu insertion/submenu operations, `EntryFlags.toSdl`, and `Callback(UserData)`. Ours
  has tray handles and menu creation but leaves menu/entry behavior closer to raw handles.
- **`video`:** Codeberg has `Window.init`, `initWithProperties`, `deinit`, typed `VSync` union,
  `Display`, `WindowId`, `HitTest(UserData)`, and checked display/window enumeration. Ours has a
  `Window` cleanup method and broad declarations, but module-level creation, raw properties, and raw
  hit-test userdata remain.
- **`metal`/`vulkan`:** Codeberg wraps native surface/view lifetime with `Surface.init`/`deinit` and
  provides checked extension/proc-address helpers. Ours exposes native handles and low-level
  functions, but not equivalent typed surface ownership in the public facade.

### Value, conversion, callback, and result-shape modules

- **`events`:** Codeberg converts `SDL_Event` into the tagged `events.Event` union; `poll()` is
  `?Event`, `waitAndPop()` is `!Event`, and every payload (`WindowMoved`, `Keyboard`, `MouseMotion`,
  `GamepadButton`, `DropFile`, `PenTouch`, `TouchFinger`, and the rest) has `fromSdl`/`toSdl`. Ours
  exposes the ABI event union and separate payload mirrors through `pollEvent`/`waitEvent`; add the
  discriminated decode layer and a documented borrowed/owned policy for drop strings.
- **`blend_mode`:** Codeberg separates `Factor`, `Operation`, and `Mode` value types and makes
  unknown modes optional-safe through `fromSdl`/`toSdl`. Ours exposes generated blend enums and
  composition helpers; add the typed conversion layer and predicates.
- **`properties`:** Codeberg's owned `Group` has `init`, `deinit`, `get`, `getAll`, `set`, typed
  `Property` values, pointer cleanup callbacks, locking, and `fromSdl`/`toSdl`. Ours exposes
  `PropertiesId` and raw get/set functions; add the owned group and typed property union.
- **`rect`:** Codeberg defines generic `Point(T)` and `Rect(T)` with `FPoint`/`IPoint`,
  `FRect`/`IRect`, `asOtherPoint`, `asOtherRect`, `empty`, `equal`, `pointIn`, and enclosing/
  intersection helpers. Ours has ABI `Point`/`Rect` records and free functions; add generic value
  methods and safe numeric conversion.
- **`pixels`:** Codeberg makes formats, colorspaces, orders, ranges, primaries, matrices, and
  transfer characteristics optional-safe enums with `fromSdl`/`toSdl`; `Format` has predicates,
  details, masks, and typed order helpers, and `Palette` has `init`/`deinit`. Ours has generated
  enums/records and free pixel functions but no systematic conversion/default/predicate layer.
- **`gpu`:** Codeberg applies `fromSdl`/`toSdl` and defaults to buffer/texture locations and
  regions, create-info records, pipeline/rasterizer/depth/sampler states, usage flags, formats, and
  other descriptors; checked conversions return `!c_struct` where needed. Ours already has
  parent-aware GPU resource handles and `deinit`, which is parity or better for lifetime safety, but
  its descriptors and flags remain ABI mirrors without the value conversion/default layer.
- **`message_box`:** Codeberg has `BoxData`, `BoxFlags`, `Button.Flags`, `ColorScheme`, and
  `Color.fromHex`, all with conversion helpers. Ours has the C-shaped records and flags but not
  these typed constructors/conversions.
- **`keycode`/`scancode`:** Codeberg's `Keycode` handles unknown values as `?Keycode` and offers
  `fromScancode`, `isExtended`, `isScancode`, and conversion helpers; `KeyModifier` exposes
  `controlDown`, `shiftDown`, `altDown`, and `guiDown`. Ours exposes generated enums and masks; add
  optional-safe conversion and modifier predicates.
- **`guid`:** Codeberg's `Guid.fromString` and `toString` are methods on a value type. Ours has the
  ABI GUID and free C-shaped conversion operations; add checked Zig string conversions.
- **`time`:** Codeberg's `DateTime` and `Time` have conversion methods (`fromSdl`, `toSdl`,
  `fromDateTime`, `fromWindows`, `toWindows`, `getCurrent`) and typed date/month/format enums. Ours
  has generated records/functions but no cohesive value API.
- **`version`:** Codeberg's packed `Version` provides `make`, `get`, component accessors, and
  `atLeast`. Add the value methods and optional revision string conversion around our generated
  version constants.
- **`audio.Spec`, `camera.Specification`, `dialog.Properties`, `process.Properties`, and
  `storage.Interface`:** These are all examples of Codeberg translating Zig option structs into SDL
  structs/property groups. Add a consistent `toSdl`/`fromSdl` policy instead of hand-writing one-off
  property IDs at every call site.
- **Callbacks throughout:** Codeberg supplies typed factories such as `assert.Handler(UserData)`,
  `clipboard.DataCallback(UserData)`, `events.Filter(UserData)`,
  `filesystem.EnumerateDirectoryCallback(UserData)`, `hints.Callback(UserData)`,
  `log.LogOutputFunction(UserData)`, `system.X11EventHook(UserData)`,
  `thread.ThreadFunction(UserData)`, `timer.*TimerCallback(UserData)`, `tray.Callback(UserData)`,
  `io_stream.Interface(UserData)`, `storage.Interface(UserData)`, and
  `joystick.VirtualJoystickDescription(UserData)`. Ours mostly exposes C callback signatures;
  establish one trampoline/lifetime convention and apply it consistently.

### Utility, platform, and companion modules

- **`assert`, `hints`, and `log`:** Codeberg adds typed callback userdata, priority/category
  conversion, optional-safe enum conversion, and thread-local error/log callback helpers. Ours has
  the underlying functions and callback types but not the generic adapters and conversion
  consistency.
- **`errors`:** Codeberg has a dedicated `Error` module with `wrapCall`, `wrapCallBool`, pointer and
  C-string wrappers, thread-local callback dispatch, and standardized SDL error helpers. Ours has a
  package error set and checked generated calls, but no equivalent public, reusable wrapper module;
  expose one so companion facades share the same failure policy.
- **`atomic`:** Both projects expose integer/32-bit atomics, spinlocks, pointer operations, and
  memory barriers. Codeberg's `Int`, `U32`, and `Spinlock` receiver methods are a cleaner value API;
  this is a naming/method facade improvement, not missing SDL coverage.
- **`cpu_info`, `bits`, `endian`, `platform`, `power`, `misc`, and `loadso`:** The raw capability
  coverage is substantially equivalent. Codeberg is easier to discover because each is a root module
  and uses typed returns (`PowerState`, `SharedObject`, `ByteOrder`) rather than requiring consumers
  to navigate `core` aliases. Do not prioritize new bindings here; prioritize the module graph and
  method naming.
- **`intrin`:** Codeberg exposes named SIMD capability constants (`sse`, `avx2`, `neon`, and others)
  in a dedicated module. Add an equivalent discoverable namespace if these declarations are not
  intentionally omitted from our target policy.
- **`keyboard`:** Codeberg adds `TextInputProperties.toSdl`, packed keyboard IDs, optional-safe
  keyboard enumeration, and typed text-input methods. Ours has the raw keyboard namespace and
  text-input operations; add the value/configuration layer.
- **`mouse`:** Codeberg has packed `Id`, `ButtonFlags` conversion/predicates, typed `Cursor`
  constructors (`init`, `initAnimated`, `initColor`, `initSystem`), and result structs for global/
  relative state. Ours has `Cursor.deinit` and raw state/create functions; add typed IDs, flags,
  constructors, and grouped results.
- **`shadercross` and `extras`:** Codeberg's `extras.gpu` validates graphics/compute shader
  metadata, loads embedded or directory-based shaders, reports compatibility errors, and exposes a
  `FramerateCapper`; `extras.error_handlers` and `loggers` provide reusable integrations. Ours
  exposes shadercross bindings and generated shader metadata but lacks these runtime validation,
  loading, logging, and frame-pacing helpers.
- **`image`:** Codeberg's `Animation` has `init`, `initFromIo`, `initFromTypedIo`, GIF/WEBP
  constructors, `deinit`, and format-specific load/save convenience functions. Ours has a wider
  generated SDL_image surface, including animation decoder/encoder types, but construction and
  format helpers are module-level C-shaped calls; add the receiver constructors where they do not
  duplicate our newer decoder/encoder API.
- **`mixer`:** Codeberg models `Mixer`, `Track`, `Group`, and `Audio` with `init`, `initIo`,
  `initNoCopy`, raw/no-copy variants, `PlayOptions`, duration/loop unions, and generic callbacks.
  Ours already has these four resource structs and cleanup methods, so the concrete advantage is the
  richer constructor naming, explicit copy/borrow modes, typed options, and callback adapters, not
  basic object existence.
- **`ttf`:** Codeberg gives `Font`, `TextEngine`, `SurfaceTextEngine`, `RendererTextEngine`, and
  `GpuTextEngine` constructors/destructors, typed text value records, and enum/flag conversions.
  Ours already has `Font` and text-engine wrappers; add the conversion/default and
  receiver-constructor consistency where generated APIs still require raw properties.
- **`net`:** Both projects expose SDL_net's `Address`, datagram/server/stream sockets, status,
  local-address enumeration, and cleanup. Codeberg adds typed `Timeout`/`Version` values and
  allocator-aware `getLocalAddresses`; ours already copies local addresses into a caller allocator
  and has receiver cleanup, so the remaining advantage is conversion/naming consistency rather than
  wholesale network coverage.
- **`test`:** Codeberg's root exports its test support alongside the facade. Ours has a separately
  feature-gated generated `test` module; no clear API advantage was found beyond root
  discoverability.
- **`main`:** Codeberg's generic `runApp`/`enterAppMainCallbacks` trampoline carries a compile-time
  application state through `init`, `iterate`, `event`, and `quit` callbacks. Ours exposes SDL's
  callback declarations in `core.init`; add a typed `App(UserData)`/lifecycle facade.
- **`Init` and `main_callbacks`:** Codeberg separates subsystem initialization helpers into
  `Init.init`/`deinit` and keeps the application-main callback entry point discoverable at the root.
  Ours has `core.init` and raw callback declarations; add the same scoped init/deinit and typed
  app-main organization. `main_callbacks.zig` itself contributes no separate public declarations at
  this revision.
- **`locale`:** Both projects expose the SDL locale record with no meaningful ergonomic advantage
  found in the Codeberg API. Keep it in the module graph, but do not treat it as a facade priority.

### `sdl3` root exports and API surface conclusion

Codeberg's root exports `assert`, `async_io`, `atomic`, `audio`, `camera`, `events`, `filesystem`,
`gamepad`, `gpu`, `image`, `io_stream`, `joystick`, `mixer`, `mutex`, `net`, `pixels`, `properties`,
`render`, `surface`, `thread`, `ttf`, `timer`, `tray`, `video`, `vulkan`, and its other utility
modules directly, plus `extras`. Our package has nearly all SDL core domains under `core`, and
companion libraries as separate root modules. Therefore the accurate overall finding is not
“Codeberg binds more SDL functions.” It provides a more uniform second API layer: more receiver
constructors, more owned value types, more `fromSdl`/`toSdl` conversions, more typed callbacks, more
tagged/result-oriented returns, and more runtime convenience helpers. Those are the improvements to
prioritize over duplicating raw declarations.

## Verified API details to preserve in the backlog

The following details were checked against the Codeberg tree at
`69cf1fba30b39fe0a140fc2139d403692e650d16` (the repository's 2026-07-14 tip). They make the work
items above concrete enough to turn into black-box API tests:

- **The lifecycle layer is broader than the major renderer objects.** `haptic.Haptic` has `init`,
  `initFromJoystick`, `initFromMouse`, `initRumble`, and `deinit`; `hid_api.Device` has `init`,
  `initPath`, and `deinit`; and `async_io.Queue` has fallible `init`, `deinit`, and `loadFile`. Add
  these to the wrapper inventory instead of limiting the first pass to video, render, and GPU.
- **IO streams bridge native Zig streams.** `io_stream.Interface(UserData)` creates an SDL callback
  table, while `Stream.initFromReaderWriter` adapts Zig readers/writers. `Stream.Reader` and
  `Stream.Writer` then expose buffered Zig-style operations. This is a concrete adapter API, not
  merely a nicer name for `SDL_IOStream`.
- **GPU conversion is systematic and checked.** `gpu` has `fromSdl`/`toSdl` on create-info,
  location, region, state, usage-flag, and descriptor types; several `toSdl` functions return
  `!c_struct` when conversion can fail. Our generator should support fallible conversion and
  defaults for nested descriptors, not only top-level handle wrappers.
- **Events have round-trip conversions per payload.** The `events` module gives payload structs such
  as `WindowMoved`, `Keyboard`, `MouseMotion`, `GamepadButton`, `DropFile`, `PenTouch`, and
  `TouchFinger` their own `fromSdl` and `toSdl`. Preserve a raw-event escape hatch, but make the
  typed decode path the normal API and explicitly handle borrowed drop-file pointers.
- **Haptic effects are typed value objects.** `haptic.Direction`, `Condition`, `Constant`, `Custom`,
  `Periodic`, `Ramp`, `Effect`, and `Features` each provide conversion helpers. This is a useful
  model for other SDL unions and bitfields currently exposed as anonymous C records.
- **The competitor separates raw and owned forms by name.** `io_stream` distinguishes
  `initFromConstMem`, `initFromMem`, `initFromDynamicMem`, and `initFromReaderWriter`; `image`
  distinguishes generic, typed, GIF, and WEBP IO constructors. We should retain this naming
  distinction in any facade so copying and borrowing are visible at the call site.

## Additional declaration-level findings

These are smaller public API wins from the same exhaustive pass. They are listed separately so they
do not disappear behind the larger lifecycle and conversion themes:

- **Audio format values are useful objects.** Codeberg's `audio.Format` has `define`,
  `getBitwidth`, `getByteSize`, `getName`, `getSilenceValue`, and signedness, endian, integer, and
  floating-point predicates. Its `Device` also has receiver methods for format, channel map, gain,
  pause state, physical/playback classification, binding, and postmix callbacks. Add these as
  methods on our generated format/device facade rather than leaving them as unrelated C-shaped
  calls.
- **Camera IDs carry their own queries.** `camera.Id` exposes `getName`, `getPosition`, and
  `getSupportedFormats`, while `camera.Specification` round-trips through `fromSdl`/`toSdl`.
  Enumeration returning `![]Id` and the ID methods should be one typed camera-discovery API.
- **Video configuration is composed of typed values.** Codeberg adds `Display.Mode` and
  `Display.Orientation` conversions, `Window.CreateProperties`, `Window.Flags`, `Window.Position`,
  `Window.Properties`, `VSync`, and an owned `gl.Context` with `init`/`deinit`. Our generated
  window/display/GL declarations cover the SDL calls but not this configuration and ownership
  layer.
- **Properties callbacks are typed too.** In addition to `properties.Group`'s `get`, `getAll`,
  `set`, `clear`, `copyTo`, `lock`, `unlock`, and `enumerateProperties`, Codeberg exposes generic
  `CleanupCallback(UserData, ValueType)` and `EnumerateCallback(UserData)` factories. Include these
  in the callback audit; the advantage is not only the property union.
- **Events include utilities around the tagged union.** `events` also provides `Iterator`,
  `iterator`, `eventIn`, `minMax`, event groups, `flushGroup`, `hasGroup`, and a generic `Filter`
  trampoline. Add the decode union and these typed helpers as one event facade, rather than only
  changing `pollEvent`'s return type.
- **Haptic effects are a typed union family.** `Direction`, `Condition`, `Constant`, `Custom`,
  `Periodic`, `Ramp`, `Effect`, and `Features` each have explicit conversion behavior, alongside
  `Haptic.init`, `initFromJoystick`, `initFromMouse`, `initRumble`, and `deinit`. This is a model
  for all SDL APIs whose C surface is a tagged or nested union.
- **Mouse state and callbacks are grouped.** `getState`, `getGlobalState`, and `getRelativeState`
  return grouped typed values containing `ButtonFlags` and coordinates, and
  `MotionTransformCallback` is a typed callback factory. Our individual output fields and raw
  callback signature should gain equivalent grouped/adapted forms.
- **Process and storage expose complete value/configuration contracts.** Codeberg's
  `process.Process` includes `Io`, `CreateProperties.toProperties`, `Properties.fromSdl`, and
  receiver `getInput`/`getOutput`/`read`/`wait`/`kill`; `storage.Storage` adds `Path`,
  `Interface(UserData)`, `initFile`/`initTitle`/`initUser`, `getFileSize`, and receiver filesystem
  operations. These are distinct improvements beyond merely adding `init` and `deinit`.
- **Time and timers include conversion utilities.** Codeberg's `timer` has millisecond and
  nanosecond delay/conversion helpers plus generic millisecond/nanosecond timer callbacks, and its
  `Timer` value has optional-safe `fromSdl`/`toSdl`, `initMilliseconds`, `initNanoseconds`, and
  `deinit`. Codeberg's `time` similarly gives `DateTime`/`Time` conversion and Windows conversion
  methods. Add both the resource wrapper and the value-level utility methods.
- **Callback coverage is broader than the common examples suggest.** The complete list includes
  `audio.PostmixCallback(UserData)`, `audio.StreamCallback(UserData)`,
  `audio.StreamDataCompleteCallback(UserData)`, `mouse.MotionTransformCallback(UserData)`,
  `properties.CleanupCallback(UserData, ValueType)`, `properties.EnumerateCallback(UserData)`,
  and the assertion, clipboard, event, filesystem, hints, IO, joystick, log, storage, system,
  thread, timer, tray, dialog, and main factories listed above. This should become a matrix of
  black-box callback tests with explicit userdata and lifetime assertions.

## Complete per-module declaration audit

The following is the exhaustive public-module checklist for the compared revision. It is based on
the declarations in Codeberg's `src/` directory and the corresponding namespaces in this
repository's generated `src/sdl.zig` plus its companion modules. It deliberately compares API
shape—exported types, methods, constructors, conversions, callback factories, ownership, and return
shapes—not documentation or function bodies. “No material advantage” is intentional: those modules
were checked and should not be turned into speculative work merely because Codeberg has a separate
file.

| Codeberg module  | Concrete API advantage in that module                                                                                                                                        | Our current surface and precise improvement                                                                                                                             |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `assert`         | `Handler(UserData)`, `AssertData`, `State`, and typed report/reset operations.                                                                                               | We have assertion functions and raw callback declarations; add the generic userdata trampoline and typed report value.                                                  |
| `async_io`       | Adds `File` with `init`/`getSize`; `Queue.closeFile`, `Queue.init`/`deinit`, and `Queue.loadFile` are receiver APIs.                                                       | We have `AsyncIo`, `Queue`, and free task functions; add the file object and receiver construction/load methods.                                                        |
| `atomic`         | `Int`, `U32`, and `Spinlock` expose value-oriented operations alongside pointer helpers.                                                                                     | We already bind the operations and `Int`/`SpinLock`; add the consistent receiver names and `U32` value wrapper.                                                         |
| `audio`          | Distinguishes `Device` from `Stream`, with `Device.open`, `close`, `openStream`, `Stream.init`, and `Spec.fromSdl`/`toSdl`.                                                  | We have `DeviceId`, `Stream`, and checked free opens; add the physical-device object, typed spec conversion, and typed callback factories.                              |
| `bits`           | Small named helpers `hasExactlyOneBitSet` and `mostSignificantBitIndex`.                                                                                                     | Equivalent generated 32-bit helpers exist; no material API gap.                                                                                                         |
| `blend_mode`     | Separate `Factor`, `Operation`, and `Mode` value types with optional-safe conversions.                                                                                       | We expose generated blend enums and composition; add conversion/predicate methods and unknown-value handling.                                                           |
| `camera`         | `Camera.init`/`deinit`, packed `Id`, and `Specification.fromSdl`/`toSdl`; enumeration returns `![]Id`.                                                                       | We have `Camera`, `Id`, `Spec`, and checked enumeration, but the spec conversion and typed result policy are missing.                                                   |
| `clipboard`      | Generic `DataCallback(UserData)` and `CleanupCallback(UserData)` cover arbitrary MIME data safely.                                                                           | Text/data operations exist, but callbacks remain C-shaped; add typed userdata and explicit ownership of callback data.                                                  |
| `cpu_info`       | A discoverable module with named SIMD predicates (`hasAvx2`, `hasNeon`, etc.) and typed system-size results.                                                                 | Raw capability coverage is substantially present under `core.cpuInfo`; improve root naming and return normalization only.                                               |
| `dialog`         | `FileFilter`, `Properties`, `Type`, and generic `FileCallback`, used by checked open/save/folder helpers.                                                                    | We bind dialog properties and calls; add typed filters, callback userdata, and an owned/allocator-aware result contract.                                                |
| `endian`         | `ByteOrder` is a named value type.                                                                                                                                           | Endian constants are available through generated core; add the focused type and conversion helpers for discoverability.                                                 |
| `errors`         | Dedicated reusable `wrapCall`, `wrapCallBool`, pointer, null, C-string, and callback-error helpers.                                                                          | We have `core.Error` and many generated checked calls, but no public shared wrapper module; centralize companion-facade conversion here.                                |
| `events`         | Separate payload records for all event families plus tagged `Event`; `poll` returns `?Event`, `waitAndPop` returns `!Event`, and payloads round-trip with `fromSdl`/`toSdl`. | We generate `SDL_Event` and named payload mirrors with `pollEvent`/`waitEvent`; add discriminated decoding and an explicit drop-string lifetime policy.                 |
| `extras`         | `FramerateCapper`, error handlers/loggers, and GPU shader metadata loaders/compatibility validation.                                                                         | We have shadercross bindings and generated shader metadata, but no equivalent runtime helper namespace.                                                                 |
| `filesystem`     | Owned sentinel `Path` (`init`, `get`, `baseName`, `join`, `parent`, `deinit`), `getSeparator`, typed `PathInfo`, `GlobFlags`, and generic enumeration callback.             | We have C-shaped path functions and allocator-owned arrays; add the path value, typed metadata, callback adapter, and path composition.                                 |
| `gamepad`        | `Gamepad` owns an opened handle and has typed `Properties` and `BindingIterator`; enum values are optional-safe conversions.                                                 | We already have a receiver-oriented `Gamepad` and binding records; add optional-safe enum conversions, iterator ergonomics, and a uniform open/init naming policy.      |
| `gpu`            | Descriptors, usage flags, regions, locations, pipeline states, and create-info values systematically implement defaults plus checked `fromSdl`/`toSdl`.                      | We already have parent-aware resource structs and `deinit`; the gap is the descriptor conversion/default layer, not GPU handle coverage.                                |
| `guid`           | `Guid.fromString` and `Guid.toString` are value methods with checked string conversion.                                                                                      | We expose the ABI GUID and C-shaped conversion operations; add the value methods and ownership of returned text.                                                        |
| `haptic`         | `Direction`, all effect variants, `Features`, and `Effect` are typed round-trippable values; `Haptic` has four named constructors and `deinit`.                              | We have `Haptic` receiver operations and cleanup, but effects are ABI records and construction is less typed; add the union conversions and constructor family.         |
| `hid_api`        | Subsystem `init`/`deinit`, `Device.init`/`initPath`/`deinit`, typed `DeviceInfo`, and an owned enumeration lifecycle.                                                        | Device operations and enumeration exist; add subsystem lifecycle, typed info conversion, and a clearer owned enumeration object.                                        |
| `hints`          | `Callback(UserData)`, typed `Priority`/`Type`, and checked `setWithPriority`.                                                                                                | Raw hint functions and callback types exist; add generic callback userdata and optional-safe enum conversions.                                                          |
| `image`          | `Animation` has generic, typed, GIF, and WEBP IO constructors plus `deinit`; format-specific load/save helpers are concise.                                                  | Our generated image surface is broader and already has decoder/encoder resource types; add receiver constructor aliases and explicit IO ownership where not duplicated. |
| `Init`           | A dedicated `Init.init`/`deinit` pair makes subsystem ownership scoped and discoverable.                                                                                     | `core.init`/`quit`/`shutdown` cover the operations; add the focused lifecycle facade without removing the generated API.                                                |
| `intrin`         | Named compile-time SIMD capability constants (`sse`, `avx2`, `neon`, and peers).                                                                                             | The declarations are not a comparably discoverable root module; add the namespace if target policy permits it.                                                          |
| `io_stream`      | `Interface(UserData)`, file/memory/reader-writer constructors, `Reader`/`Writer` buffered adapters, and checked scalar read/write methods.                                   | We have `IoStream`, callback `Interface`, scalar operations, and close/deinit; add Zig reader/writer adapters and explicit const/owned/no-copy constructor names.       |
| `joystick`       | Packed `Id`, `AxisMask`, `ButtonMask`, typed `ConnectionState`, `Joystick.init`/`deinit`, and `VirtualJoystickDescription(UserData)`.                                        | We have joystick handles and virtual-joystick declarations; add packed mask/value conversions and typed virtual callback trampolines.                                   |
| `keyboard`       | Packed keyboard `Id`, `TextInputProperties.toSdl`, optional-safe key/scancode conversion, and grouped text-input state.                                                      | Raw keyboard/text-input functions and records exist; add the property conversion and grouped typed state.                                                               |
| `keycode`        | `Keycode` handles unknown values as optional and provides scancode/extended predicates; `KeyModifier` has named down predicates.                                             | Generated keycode/masks expose integer-backed values; add optional conversion, predicates, and modifier helpers.                                                        |
| `loadso`         | `SharedObject` owns the library handle and exposes checked init, symbol lookup, and `deinit`.                                                                                | We have the corresponding `sharedObject` core namespace and raw calls; add receiver naming and a typed owned handle.                                                    |
| `locale`         | No meaningful ergonomic advantage beyond the focused module name.                                                                                                            | Locale records and enumeration are already generated; keep root discoverability but do not prioritize a wrapper.                                                        |
| `log`            | `LogOutputFunction(UserData)`, typed priority/category values, and checked callback installation.                                                                            | Logging and `stdLogFn` exist, but callback userdata and value conversions are not uniform.                                                                              |
| `main`           | Generic `runApp`/`enterAppMainCallbacks` carries compile-time application state through init/iterate/event/quit.                                                             | SDL main callback declarations exist under core; add the typed `App(UserData)` trampoline and lifecycle contract.                                                       |
| `main_callbacks` | No separate public declarations at this revision; it is a support file for the main layer.                                                                                   | No gap to implement.                                                                                                                                                    |
| `message_box`    | `BoxData`, `BoxFlags`, nested `Button.Flags`, `ColorScheme`, and `Color.fromHex` are typed config values.                                                                    | C-shaped message-box records and flags exist; add constructors, flags conversion, and color helpers.                                                                    |
| `metal`          | Owned `View.init`/`deinit` around the native Metal view.                                                                                                                     | Native Metal handles are exposed; add the owned view wrapper and checked creation.                                                                                      |
| `misc`           | `openURL` is a small checked, idiomatic function.                                                                                                                            | Equivalent generated operation exists; normalize its naming/error wrapper if needed.                                                                                    |
| `mixer`          | `Mixer`, `Track`, `Group`, and `Audio` have normal/IO/raw/no-copy constructors, typed `PlayOptions`, duration/loop unions, and conversions.                                  | We already have the four resource structs and cleanup; add the richer constructor matrix, explicit copy modes, and generic callback factories.                          |
| `mouse`          | Packed `Id`, `ButtonFlags`, typed cursor constructors, and grouped state results.                                                                                            | `Cursor.deinit` and state/create calls exist; add flag conversion, typed IDs, constructor overloads, and grouped return values.                                         |
| `mutex`          | `Condition`, `Mutex`, `RwLock`, and `Semaphore` are fallible value objects with uniform `init`/`deinit` and methods.                                                         | We expose SDL synchronization objects and cleanup, but the constructors/status methods are not a single value-oriented policy.                                          |
| `net`            | Typed `Timeout`/`Version` values and allocator-aware `getLocalAddresses`; sockets are receiver-owned objects.                                                                | Socket/resource ownership and allocator copying already exist; add the missing value conversions and naming consistency.                                                |
| `pen`            | `Axis`, `DeviceType`, `Id`, and `InputFlags` are packed/optional-safe value types with conversions.                                                                          | Pen declarations are generated, but remain raw enums/masks; add the value layer.                                                                                        |
| `pixels`         | Format internals are modeled by typed order/range/primaries/matrix/transfer values; `Format` has predicates/details and `Palette` owns init/deinit.                          | Pixel records/enums and free functions exist; add systematic conversions, format predicates, and palette ownership.                                                     |
| `platform`       | Named platform constants plus a checked `get` operation are directly importable.                                                                                             | Platform constants/functions exist under core; the improvement is root module and return-shape discoverability.                                                         |
| `power`          | `PowerState` is an optional-safe typed result.                                                                                                                               | Generated power state exists; add conversion helpers and preserve unknown-state handling.                                                                               |
| `process`        | Owned `Process.init`/`initWithProperties`, `Properties` conversion, receiver I/O, kill, wait, and deinit.                                                                    | We have `Process`, creation, I/O, and cleanup; add typed process properties and receiver constructors.                                                                  |
| `properties`     | Owned `Group` with `init`, `deinit`, `copyTo`, lock/unlock, enumeration, typed `Property` union, and `getAll`.                                                               | We expose `PropertiesId` and raw typed get/set functions; add the owned group/property value API.                                                                       |
| `rect`           | Generic `Point(T)`/`Rect(T)` with `FPoint`/`IPoint`, conversions, empty/equality/containment, enclosing and intersection methods.                                            | ABI point/rect records and free functions exist; add generic numeric value methods.                                                                                     |
| `render`         | `Renderer.init*`, receiver methods, `Texture` ownership, typed properties, and descriptor conversions.                                                                       | We have renderer/texture handles, many methods, checked results, and cleanup; add receiver constructors/options and conversion helpers.                                 |
| `scancode`       | Optional-safe `Scancode` conversion and name/value helpers on a focused value type.                                                                                          | Generated scancodes are available; add unknown-value handling and value methods.                                                                                        |
| `sensor`         | Packed `Id`, optional-safe `Type`, `Sensor.init`/`deinit`, and receiver data access.                                                                                         | Sensor handles/cleanup and raw types exist; add conversion and receiver-constructor consistency.                                                                        |
| `shadercross`    | Same general binding surface, with typed metadata records and checked compiler results.                                                                                      | Our generated shadercross surface is comparable; the real gap is Codeberg's separate `extras.gpu` runtime validation/helpers.                                           |
| `storage`        | Owned `Path`, `Storage.init`/`initFile`/`initTitle`/`initUser`/`deinit`, and `Interface(UserData)` callbacks.                                                                | Storage functions and handle exist; add path ownership, storage constructors, and typed callback interface.                                                             |
| `surface`        | `Flags`, `FlipMode`, `ScaleMode`, `Surface` constructors for raw/file/IO/BMP/PNG sources, properties conversion, and `deinit`.                                               | Surface cleanup and raw loaders exist; add the constructor family, typed flags, and IO ownership.                                                                       |
| `system`         | Typed platform hooks including `X11EventHook(UserData)` and lifecycle callbacks.                                                                                             | Platform/system declarations exist but callback userdata is C-shaped; add generic adapters and target-gated availability.                                               |
| `thread`         | `Thread.init`/`initWithProperties`, typed `ThreadFunction(UserData)`, receiver wait/detach, typed state/priority, and `TlsId.init`.                                          | Thread creation/cleanup and raw callbacks exist; add generic callback and receiver constructor/wait policy.                                                             |
| `time`           | `DateTime`/`Time` conversion methods, Windows conversions, current-time helpers, and typed date/month/format values.                                                         | Generated date/time records/functions exist; add cohesive value methods and checked conversions.                                                                        |
| `timer`          | Owned `Timer` with millisecond/nanosecond constructors and deinit; generic timer callback factories.                                                                         | Timer IDs and raw callbacks exist; add owned timer value and callback userdata.                                                                                         |
| `touch`          | Packed `Id`, `FingerId`, `Finger`, and typed device enumeration.                                                                                                             | Touch records/functions exist; add packed conversion and grouped enumeration results.                                                                                   |
| `tray`           | Related `Tray`, `Menu`, and `Entry` objects with init/deinit, insertion/submenu methods, flags conversion, and generic callback.                                             | Tray handles/menu creation exist; add the object graph, entry flags, receiver methods, and callback adapter.                                                            |
| `ttf`            | Font/text-engine constructors/destructors, typed text records, color/flag conversions, and GPU atlas value conversions.                                                      | Our `Font` and text-engine wrappers are already substantial; add missing conversion/default/receiver consistency rather than duplicate coverage.                        |
| `version`        | Packed `Version.make`, `get`, component accessors, and `atLeast`.                                                                                                            | Version constants/functions exist; add the value object and comparison helpers.                                                                                         |
| `video`          | Owned `Window.init`/`initWithProperties`/`deinit`, `Display` value methods, typed `VSync`, and generic `HitTest(UserData)`.                                                  | Window/display functions, cleanup, and GL/EGL wrappers exist; add options/property conversion, VSync value, and hit-test trampoline.                                    |
| `vulkan`         | Owned native `Surface.init`/`deinit`, checked library loading, and proc-address helpers.                                                                                     | Vulkan declarations and native handles exist; add surface ownership and checked helper grouping.                                                                        |
| `sdl3` root      | Re-exports every focused module plus root `init`/`quit`, memory/environment helpers, UTF-8 iterators, and `App*` callback types.                                             | We expose nearly all SDL domains under `core` and companions at package root; add direct focused re-exports and make public root memory/environment APIs consistent.    |

### Cross-cutting conclusions from the audit

- Codeberg does not generally win by binding an SDL function that is absent here. Our generated
  namespaces contain most of the same SDL declarations, and in several companion areas our generated
  revision is broader (notably SDL_image animation decoder/encoder records and newer checked result
  structs). The repeatable difference is a second, hand-written API layer.
- The largest countable advantage is not “more `deinit` methods”: this repository already has many
  receiver cleanup methods. The missing half is constructor symmetry—`Type.init*`—plus typed
  options, `fromSdl`/`toSdl`, and explicit borrowed/copied/no-copy names.
- The second largest advantage is callback adaptation. The compared tree has generic factories in
  `assert`, `clipboard`, `events`, `filesystem`, `hints`, `io_stream`, `joystick`, `log`, `storage`,
  `system`, `thread`, `timer`, `tray`, and `main`; our raw C callback types should be audited
  against this complete list.
- The third is result shape: tagged event decoding, optional-safe enum conversion, owned paths and
  strings, typed property groups, and allocator-aware slices. These should be implemented as
  explicit facade contracts and black-box tests, while retaining the generated ABI surface.

The Codeberg source used for this audit is
[`7Games/zig-sdl3` at `69cf1fba`](https://codeberg.org/7Games/zig-sdl3/src/commit/69cf1fba30b39fe0a140fc2139d403692e650d16/),
whose tip is dated 2026-07-14 and whose last commit is “Improve GPU Texture Defaults”. The local
counterpart is the generated namespace block in [`src/sdl.zig`](src/sdl.zig) and the committed
companion modules under [`src/`](src/). Re-run this audit when either upstream tip or the pinned SDL
family changes; do not silently treat an upstream source change as a documentation-only diff.

## Fresh comparison verification

- **2026-08-09 pass 1:** A fresh luna-medium comparison of the complete public API found no concrete
  improvement missing from this document. It revalidated the upstream tip as `69cf1fba` and made no
  source changes.
- **2026-08-09 pass 2:** A second independent fresh luna-medium comparison covered all 64 upstream
  modules plus 6 `extras` files and found no concrete improvement missing from this document. It
  revalidated the same upstream tip and made no source changes.
- **2026-08-09 pass 3:** A fresh exhaustive luna-medium comparison covered the complete public API
  surface and found no concrete improvement missing from this document. It revalidated upstream
  commit `69cf1fba` (including the already-recorded GPU texture-default change) and made no source
  changes.
- **2026-08-09 pass 4:** A second fresh exhaustive luna-medium comparison covered all upstream
  public modules and declarations and found zero new concrete improvements. It revalidated commit
  `69cf1fba`, including the already-recorded `TextureCreateInfo` defaults, and made no source
  changes.
