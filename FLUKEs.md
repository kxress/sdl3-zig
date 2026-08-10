# TODO items marked complete but not actually complete

This file records checked items from `TODO.md` that failed direct source inspection or the
repository's own verification. Unchecked TODO items are intentionally not listed.

## Public facade foundation

- `Add direct root aliases for ... io_stream ...` is false. `src/root.zig` has no direct `io_stream`
  alias, and it declares `gamepad` and `joystick` twice (at the generated-alias block and again at
  the facade-alias block). A source-distribution consumer therefore fails to compile with duplicate
  struct-member errors.
- `Add canonical async_io, io_stream, blend_mode, hid_api, and message_box aliases` is false because
  the canonical `io_stream` alias is missing.
- `Add compile-time tests for each error wrapper shape` is false. `src/errors.zig` has ordinary
  runtime tests, not compile-time tests for the wrapper shapes.
- `Add a facade test importing every direct root alias` is false. The root test omits several
  claimed aliases, including `io_stream` and companion aliases, and the source-all build catches the
  duplicate root declarations.
- `Add a facade test for borrowed versus copied return documentation contracts` is false:
  `deno test --frozen --allow-read --allow-write tests/facade-contracts.test.ts` fails because
  `docs/callback-lifetimes.md` does not exist.

## Core value types and conversions

- `Add enclosing and intersection receiver methods for rectangles` is false. `src/geometry.zig`
  defines `intersection` but no enclosing receiver method.
- `Add typed date, month, and format conversions` is incomplete. `src/time_facade.zig` wraps date
  and format enums, but `Month` is only a bare enum with no `fromSdl`/`toSdl` conversion.
- `Add packed joystick Id, AxisMask, and ButtonMask conversions` is incomplete. `AxisMask` and
  `ButtonMask` provide predicates and `with`, but no `fromSdl`/`toSdl` methods.
- `Add typed gamepad Axis, Button, Binding, BindingType, ButtonLabel, and Type` is incomplete:
  `Binding` is only an alias to the generated raw type.
- `Add optional-safe gamepad enum conversions` is incomplete. Only `Type` maps unknown values to an
  optional; the other enum wrappers are raw-preserving `EnumValue` wrappers.
- `Add net Timeout, Status, and Version conversions` is incomplete. `Timeout` only has `toSdl`, and
  `Version` has component accessors but no `fromSdl`/`toSdl` pair.
- `Add TTF text records, colors, flags, and GPU atlas conversions/defaults` is incomplete.
  `src/ttf_facade.zig` has no GPU-atlas facade value or conversion.
- `Add mixer duration, loop, and PlayOptions conversions/defaults` is incomplete. `Duration` only
  has `fromSdl`, `LoopCount` only has `toSdl`, and `PlayOptions` has no conversion/default methods.

## Lifecycle and ownership facade

- `Add typed surface BMP and PNG loaders` is false for the surface facade. `src/surface_facade.zig`
  exposes generic/file/IO constructors but no BMP or PNG loader methods.
- `Add dialog FileFilter and typed properties` is incomplete. `FileFilter` converts to SDL, but
  `dialog.Properties` has no conversion method and is not used by a dialog operation.
- `Add process properties conversion` is incomplete. `src/process_facade.zig` defines a `Properties`
  struct but no `toProperties` conversion.
- `Add properties enumeration, locking, and copying` is incomplete. `Group` has lock/unlock and
  copy, but no enumeration operation.
- `Add mixer receiver ownership and callback cleanup` is false. `src/mixer_facade.zig` contains no
  callback adapter or callback cleanup operation.
- `Add checked Vulkan library/proc-address helpers` is false for the facade. `src/vulkan_facade.zig`
  only re-exports the generated library/proc functions and adds no checked helper layer.

## IO, callbacks, and result shapes

- `Document callback userdata lifetime and trampoline storage requirements` is false as checked by
  the repository. Both callback-contract tests require the missing `docs/callback-lifetimes.md`; the
  guidance currently lives only in example snippets.
- `Add callback compile-time type and invocation tests` is overstated. The available facade test
  invokes the audio callback, while the other callback families are only structurally inspected or
  instantiated; there is no complete compile-time/invocation matrix.
- `Add event round-trip conversion tests` is false as a round-trip claim. The event test only
  exercises `TaggedEvent.fromRaw`; there is no tagged-event `toSdl`/raw reverse conversion.

## Platform, utility, and adjunct coverage

- `Add focused platform, loadso, system, and version root aliases` is false. The root exports
  `platform_api`, `loadso_api`, and `system_api`, not direct `platform`, `loadso`, and `system`
  aliases; only `version` is direct.

## Verification and migration

- `Add black-box compile tests for every new facade type` is false. The facade compile test checks
  root-source text and runs a general build; it does not compile every listed facade type as a
  consumer boundary.
- `Add lifecycle success/failure tests for every constructor family` is false. The facade contract
  test checks that source files contain `init` and `deinit`, not constructor success and failure
  behavior.
- `Add ownership tests for copied, borrowed, dynamic, and no-copy inputs` is not proven by the
  checked tests. The allocator fixture exercises generated SDL ownership functions, not all of the
  facade constructors listed in this item.
- `Add enum/flag unknown-value and round-trip tests` is not proven for the whole facade surface;
  only a small subset of value modules has direct tests.
- `Add callback userdata and teardown tests` is not proven. There are callback invocation examples,
  but no complete teardown test for all checked callback families.
- `Update public API coverage inventory after implementation` is not proven by `COVERAGE.md`, which
  is the generated SDL declaration-coverage report and does not inventory the hand-written facade
  API.
- `Run formatter and formatter check` is false in the current worktree. `deno task fmt:check`
  reports `TODO.md` as unformatted.
