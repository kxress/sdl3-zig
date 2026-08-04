# Apple mobile targets

The binding generator recognizes the six mobile slices shipped by the pinned SDL-family DMGs:

| Platform | Device         | Simulator                                         |
| -------- | -------------- | ------------------------------------------------- |
| iOS      | `aarch64-ios`  | `aarch64-ios-simulator`, `x86_64-ios-simulator`   |
| tvOS     | `aarch64-tvos` | `aarch64-tvos-simulator`, `x86_64-tvos-simulator` |

The analysis identities set SDL's Apple, iOS, and tvOS platform macros independently. Simulator
identities are retained separately so architecture and ABI-specific declarations cannot be hidden by
the macOS analysis. The public Zig conditions use `builtin.os.tag == .ios` or `.tvos`; the simulator
and device slices expose the same public SDL API.

`tests/build/apple-mobile.test.ts` is the pre-packaging gate. On macOS it extracts the verified
DMGs, compiles the Zig binding consumer for every retained slice, links every retained core and
companion framework with device/simulator SDKs, checks the framework rpaths, embeds and ad-hoc signs
an iOS simulator app, and exercises install/launch/terminate through `simctl`. It requires Xcode's
iOS and tvOS SDKs plus an available iPhone simulator. The test is ignored on non-macOS hosts.

The release archive remains macOS-only. visionOS is not included because no pinned verified visionOS
artifact or source path is available.
