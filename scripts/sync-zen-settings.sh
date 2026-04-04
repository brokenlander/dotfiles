#!/usr/bin/env bash
set -euo pipefail

# Sync Zen Browser settings from Windows NTFS partition to Linux
# Only copies Zen-specific settings that don't sync via Firefox Sync

WIN_MOUNT="/run/media/brokenlander/System"
WIN_PROFILE="$WIN_MOUNT/Users/marut/AppData/Roaming/zen/Profiles/70g0psfv.Default (release)"
LIN_PROFILE="$HOME/.config/zen/ct0ucsp3.Default (release)"

# Zen-specific files to sync
ZEN_FILES=(
    "zen-keyboard-shortcuts.json"
    "zen-themes.json"
    "zen-sessions.jsonlz4"
    "zen-live-folders.jsonlz4"
)

# Preflight checks
if ! mountpoint -q "$WIN_MOUNT" 2>/dev/null; then
    echo "ERROR: Windows partition not mounted at $WIN_MOUNT"
    echo "Mount it first, e.g.: udisksctl mount -b /dev/nvme0n1p3"
    exit 1
fi

if [ ! -d "$WIN_PROFILE" ]; then
    echo "ERROR: Windows Zen profile not found at: $WIN_PROFILE"
    exit 1
fi

if [ ! -d "$LIN_PROFILE" ]; then
    echo "ERROR: Linux Zen profile not found at: $LIN_PROFILE"
    exit 1
fi

if pgrep -x zen >/dev/null 2>&1; then
    echo "ERROR: Zen is running — close it first"
    exit 1
fi

# Copy Zen-specific files
for f in "${ZEN_FILES[@]}"; do
    if [ -f "$WIN_PROFILE/$f" ]; then
        cp "$WIN_PROFILE/$f" "$LIN_PROFILE/$f"
        echo "Copied $f"
    else
        echo "Skipped $f (not found on Windows)"
    fi
done

# Copy zen-themes.css
mkdir -p "$LIN_PROFILE/chrome"
if [ -f "$WIN_PROFILE/chrome/zen-themes.css" ]; then
    cp "$WIN_PROFILE/chrome/zen-themes.css" "$LIN_PROFILE/chrome/"
    echo "Copied chrome/zen-themes.css"
fi

# Extract zen.* prefs into user.js
ZEN_PREFS=$(grep 'user_pref("zen\.' "$WIN_PROFILE/prefs.js" 2>/dev/null || true)
if [ -n "$ZEN_PREFS" ]; then
    if [ -f "$LIN_PROFILE/user.js" ]; then
        # Preserve non-zen prefs already in user.js
        grep -v 'user_pref("zen\.' "$LIN_PROFILE/user.js" > /tmp/zen_sync_user_js.tmp || true
        echo "$ZEN_PREFS" >> /tmp/zen_sync_user_js.tmp
        mv /tmp/zen_sync_user_js.tmp "$LIN_PROFILE/user.js"
    else
        echo "$ZEN_PREFS" > "$LIN_PROFILE/user.js"
    fi
    echo "Synced $(echo "$ZEN_PREFS" | wc -l) zen.* prefs to user.js"
fi

echo "Done!"
