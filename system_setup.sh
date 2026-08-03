#!/usr/bin/env bash

set -euo pipefail

readonly debian_packages=(
    build-essential
    cmake
    pkg-config
    libsdl3-dev
    libsdl3-image-dev
    libsdl3-ttf-dev
    libsdl3-mixer-dev
    libsdl3-net-dev
)

readonly arch_packages=(
    base-devel
    cmake
    pkgconf
    sdl3
    sdl3_image
    sdl3_ttf
    sdl3_mixer
    sdl3_net
)

fail() {
    printf '%s\n' "$*" >&2
    exit 1
}

run_as_root() {
    if [[ $(id -u) -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null; then
        sudo "$@"
    else
        fail "This setup requires root privileges; install sudo or run as root."
    fi
}

setup_msys2() {
    [[ -n ${MINGW_PACKAGE_PREFIX:-} ]] || fail \
        "Run this from an MSYS2 MinGW, UCRT64, or Clang shell, not the MSYS shell."

    local -r -a msys_packages=(
        "${MINGW_PACKAGE_PREFIX}-cmake"
        "${MINGW_PACKAGE_PREFIX}-pkgconf"
        "${MINGW_PACKAGE_PREFIX}-sdl3"
        "${MINGW_PACKAGE_PREFIX}-sdl3-image"
        "${MINGW_PACKAGE_PREFIX}-sdl3-ttf"
        "${MINGW_PACKAGE_PREFIX}-sdl3-mixer"
        "${MINGW_PACKAGE_PREFIX}-sdl3-net"
    )
    pacman -S --needed --noconfirm "${msys_packages[@]}"
}

if [[ -n ${MSYSTEM:-} ]] && command -v pacman >/dev/null; then
    setup_msys2
else
    [[ -r /etc/os-release ]] || fail \
        "Unsupported environment. Supported environments: Debian/Ubuntu, Arch, Artix, CachyOS, and MSYS2."
    # shellcheck disable=SC1091
    source /etc/os-release

    case ${ID:-} in
        debian | ubuntu)
            command -v apt-get >/dev/null || fail "${ID} requires apt-get."
            run_as_root apt-get update
            run_as_root apt-get install --yes "${debian_packages[@]}"
            ;;
        arch | artix | cachyos)
            command -v pacman >/dev/null || fail "${ID} requires pacman."
            run_as_root pacman -S --needed --noconfirm "${arch_packages[@]}"
            ;;
        *)
            fail "Unsupported environment: ${PRETTY_NAME:-${ID:-unknown}}. Supported environments: Debian/Ubuntu, Arch, Artix, CachyOS, and MSYS2."
            ;;
    esac
fi

cat <<'EOF'

Installed the system SDL3 packages. SDL3_test is provided by the SDL3 development package.
ControllerImage and SDL_shadercross are intentionally not installed here because these package
indexes do not provide them consistently; select their source distribution in build.zig instead.
EOF
