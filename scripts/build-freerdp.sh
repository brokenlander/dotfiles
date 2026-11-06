#!/bin/bash
# Build FreeRDP 3 from source with H.264, SDL3 client only, into /opt/freerdp.
#
# Why (note for future me / future agents):
#   - FreeRDP is the most complete open-source RDP client on Linux. Remmina,
#     KRDC and GNOME Connections all sit on top of it; IronRDP's own client is
#     still closer to a demo.
#   - Of FreeRDP 3's clients, the SDL3 one is the maintained one. wlfreerdp
#     prints "deprecated, use the SDL3 based client"; xfreerdp runs through
#     XWayland on a Wayland desktop. SDL3 picks native Wayland on its own.
#   - Ubuntu's packages are built WITHOUT H.264 (sdl-freerdp /buildconfig shows
#     WITH_GFX_H264=OFF, WITH_FFMPEG=OFF), so the GFX pipeline falls back to
#     RemoteFX/progressive: more bandwidth, softer picture. This build turns
#     H.264 on through FFmpeg, which enables /gfx:AVC444 (full-colour H.264,
#     sharp text).
#   - Installed under /opt/freerdp (own rpath) so it never clashes with the
#     system libfreerdp3 that Remmina and friends link against. A symlink in
#     /usr/local/bin puts sdl-freerdp on PATH.
#
# Used by: ~/teams-av/start.sh (brokenlander/teams-av-setup), any RDP use.
#
# Idempotent: skips the build when the installed version matches and has H.264.
# Usage: scripts/build-freerdp.sh            # pinned version below
#        FREERDP_VERSION=3.34.0 scripts/build-freerdp.sh
#        FORCE=1 scripts/build-freerdp.sh    # rebuild anyway

FREERDP_VERSION="${FREERDP_VERSION:-3.33.0}"
PREFIX=/opt/freerdp
SRC="$HOME/.cache/freerdp-build/FreeRDP-$FREERDP_VERSION"
export DEBIAN_FRONTEND=noninteractive

installed_ok() {
    local bin="$PREFIX/bin/sdl-freerdp"
    [ -x "$bin" ] || return 1
    "$bin" /version 2>/dev/null | grep -q "version $FREERDP_VERSION " || return 1
    local cfg; cfg=$("$bin" /buildconfig 2>/dev/null)
    grep -q 'WITH_GFX_H264=ON' <<<"$cfg" && grep -q 'WITH_VERBOSE_WINPR_ASSERT=OFF' <<<"$cfg"
}

if [ "${FORCE:-0}" != 1 ] && installed_ok; then
    echo "FreeRDP $FREERDP_VERSION with H.264 already in $PREFIX, skipping."
    exit 0
fi

set -e
echo "=== Building FreeRDP $FREERDP_VERSION (SDL3 client, H.264 via FFmpeg) ==="

sudo apt-get install -y \
    build-essential cmake ninja-build pkg-config git \
    libssl-dev zlib1g-dev libicu-dev libcjson-dev liburiparser-dev libkrb5-dev \
    libsdl3-dev libsdl3-ttf-dev libsdl3-image-dev \
    libavcodec-dev libavutil-dev libswscale-dev libswresample-dev \
    libpulse-dev libopus-dev libusb-1.0-0-dev libxkbcommon-dev \
    libx11-dev libxkbfile-dev

mkdir -p "$(dirname "$SRC")"
if [ ! -d "$SRC" ]; then
    git clone --depth 1 --branch "$FREERDP_VERSION" https://github.com/FreeRDP/FreeRDP.git "$SRC"
fi

cmake -S "$SRC" -B "$SRC/build" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_INSTALL_RPATH="$PREFIX/lib" \
    -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON \
    -DWITH_CLIENT_SDL=ON -DWITH_CLIENT_SDL2=OFF -DWITH_CLIENT_SDL3=ON \
    -DWITH_X11=OFF -DWITH_WAYLAND=OFF \
    -DWITH_SERVER=OFF -DWITH_SHADOW=OFF -DWITH_PROXY=OFF -DWITH_SAMPLE=OFF \
    -DWITH_PLATFORM_SERVER=OFF \
    -DWITH_FFMPEG=ON -DWITH_DSP_FFMPEG=ON -DWITH_SWSCALE=ON \
    -DWITH_OPENH264=OFF -DWITH_VAAPI=OFF \
    -DWITH_PULSE=ON -DWITH_OPUS=ON \
    -DWITH_WEBVIEW=OFF -DWITH_FUSE=OFF -DWITH_CUPS=OFF -DWITH_PCSC=OFF \
    -DWITH_VERBOSE_WINPR_ASSERT=OFF \
    -DWITH_MANPAGES=OFF -DBUILD_TESTING=OFF -DWITH_KRB5=ON

cmake --build "$SRC/build"
sudo cmake --install "$SRC/build"

# The SDL3 client binary is sdl-freerdp (older trees: sdl3-freerdp). Normalise.
if [ ! -x "$PREFIX/bin/sdl-freerdp" ] && [ -x "$PREFIX/bin/sdl3-freerdp" ]; then
    sudo ln -sf "$PREFIX/bin/sdl3-freerdp" "$PREFIX/bin/sdl-freerdp"
fi
sudo ln -sf "$PREFIX/bin/sdl-freerdp" /usr/local/bin/sdl-freerdp

installed_ok && echo "FreeRDP $FREERDP_VERSION installed in $PREFIX with H.264." || {
    echo "Build finished but the H.264 check failed: $PREFIX/bin/sdl-freerdp /buildconfig" >&2
    exit 1
}
