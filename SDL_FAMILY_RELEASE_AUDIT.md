# SDL-family stable-release audit — 2026-08-03

This is an evidence-only audit. The pinned tree, `mise.sdl.toml`, generated bindings, and package
metadata were not changed.

## Stable release selection

Only published, non-prerelease GitHub releases were considered:

| Component                                                                       | Pinned | Latest stable | Published  |
| ------------------------------------------------------------------------------- | ------ | ------------- | ---------- |
| [SDL](https://github.com/libsdl-org/SDL/releases/tag/release-3.4.14)            | 3.4.12 | 3.4.14        | 2026-08-03 |
| [SDL_image](https://github.com/libsdl-org/SDL_image/releases/tag/release-3.4.4) | 3.4.4  | 3.4.4         | 2026-05-01 |
| [SDL_ttf](https://github.com/libsdl-org/SDL_ttf/releases/tag/release-3.2.2)     | 3.2.2  | 3.2.2         | 2025-03-31 |
| [SDL_mixer](https://github.com/libsdl-org/SDL_mixer/releases/tag/release-3.2.4) | 3.2.4  | 3.2.4         | 2026-06-03 |
| [SDL_net](https://github.com/libsdl-org/SDL_net/releases/tag/release-3.2.0)     | 3.2.0  | 3.2.0         | 2026-05-31 |

The complete candidate family was staged together in the isolated cache
`/tmp/sdl-family-release-audit.nWDB4c`. It contained SDL 3.4.14 and all four currently pinned
companion releases; it did not modify `vendor/`.

## Declarations and translation review

The SDL 3.4.12 and 3.4.14 public include trees were compared directly. There are no added or removed
public function, typedef, enum, or `SDL_DECLSPEC` declarations. The semantic changes are:

- `SDL_disabled_assert` now uses `(condition) ? 1 : 0` inside `sizeof`.
- `SDL_CPUPauseInstruction` excludes `__arm64ec__` from the x86 inline-assembly branch.
- A trailing comma was removed from `SDL_CAMERA_PERMISSION_STATE_APPROVED`.
- GPU documentation describes multiple read usages; revision and version macros advance to 3.4.14.

The first and second changes are existing macro/target-conditional patterns rather than new Zig
declarations. The `__arm64ec__` branch is recorded for a future target-aware test; it is outside the
repository's current `x86_64-linux-gnu`, `x86_64-windows-gnu`, and `aarch64-macos` analysis
identities. No unsupported generator translation pattern was found in the declaration delta.

The four companion tags are unchanged, so they have no declaration delta in this candidate family.

## Compatibility and closure

The companion CMake declarations report these minimum SDL versions, all satisfied by 3.4.14:

| Component       | Declared `SDL_REQUIRED_VERSION` |
| --------------- | ------------------------------- |
| SDL_image 3.4.4 | 3.4.0                           |
| SDL_ttf 3.2.2   | 3.2.6                           |
| SDL_mixer 3.2.4 | 3.4.0                           |
| SDL_net 3.2.0   | 3.0.0                           |

The staged source archives and detached signatures had these SHA-256 values:

| Component       | Source archive                                                     | Signature                                                          |
| --------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------ |
| SDL 3.4.14      | `30d4aa2b3037718142b32dffd4e72f917ebb6cc5227150e7bb9c45efb2153aeb` | `09d6bdb9fb4f50e0348e3ea1bdd5f0435c27969222128f8661dcf5518853156d` |
| SDL_image 3.4.4 | `29751304a13d25ac513f24305fa25b06a6edd9607718c90129b8350d35fc5573` | `c398715f41a44b209f06ae73e96063f31a74e6987052c8eecd798c6587fa84bb` |
| SDL_ttf 3.2.2   | `63547d58d0185c833213885b635a2c0548201cc8f301e6587c0be1a67e1e045d` | `e174066104891b533fc7ba4c39694cb6000ff336f42d6416c435a6e6e4bd1cdb` |
| SDL_mixer 3.2.4 | `182a07c745375e113dc740d43964ff21b0be29f29f59876c4dbc4db3d32f6901` | `c83a421f6f7ad2471a66fc55bde28444250f15fd6c3dcb8e57cc774de70d6470` |
| SDL_net 3.2.0   | `098522fc26d4e302ef9348aee6e76e67fe504dfefd7f596236568f8330570c41` | `beecc16fc302bceacbd1d54e005a2c5fa2872e5beba0e58f74766985f92e9518` |

All five staged signatures verified with the repository's two pinned SDL release-key fingerprints.
Every source archive contains a top-level `LICENSE.txt`; SDL_image and SDL_mixer also retain their
optional codec license files. The SDL 3.4.14 license hash is unchanged from 3.4.12 and matches
`vendor/SDL3/LICENSE.txt`.

SDL 3.4.14 publishes the currently declared core source, signature, MinGW, MSVC, and macOS artifact
families, with additional x86, x64, and arm64 runtime archives. Companion artifact URLs and
checksums remain the existing pins, including SDL_image and SDL_mixer x86/x64 runtime archives. The
candidate therefore has source, signature, artifact, and notice closure for a coordinated baseline
review.

## Decision

The audit is complete, but no baseline update is applied here. The next release change should be a
single coordinated update that advances SDL core to 3.4.14, keeps the unchanged companion pins in
the same reviewed manifest, refreshes the verified vendor cache, regenerates bindings and metadata,
and rebuilds the package artifacts. Existing binding, documentation, source, and release checks
remain the gates for that follow-up change.
