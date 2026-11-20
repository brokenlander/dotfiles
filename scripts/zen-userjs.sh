#!/bin/bash
# Install zen/user.js into the active Zen profile (both machines; run by the installers).
# user.js opts Zen's appearance/behaviour prefs into Firefox Sync, so the Mozilla
# account carries them between machines, and sets two local fixes (no default-
# browser prompt, no password saving: Bitwarden does that). Everything else
# (bookmarks, passwords, tabs, workspaces) is plain Firefox Sync.
# Only the managed block in the profile's user.js is replaced; other lines stay.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$DOTFILES/zen/user.js"

find_profile() {
  local base="$HOME/.config/zen" ini="$HOME/.config/zen/profiles.ini" p=""
  if [ -f "$ini" ]; then
    # The install-locked default is the profile Zen actually launches.
    p=$(awk -F= '
      /^\[Install/ {inI=1; next}
      /^\[/        {inI=0}
      inI && /^Default=/ {sub(/^Default=/,""); print; exit}
    ' "$ini")
  fi
  if [ -n "$p" ] && [ -d "$base/$p" ]; then echo "$base/$p"; return 0; fi
  p=$(ls -dt "$base"/*.Default* 2>/dev/null | head -1)
  [ -n "$p" ] && [ -d "$p" ] && { echo "$p"; return 0; }
  return 1
}

profile=$(find_profile) || { echo "zen-userjs: no Zen profile yet (start Zen once, then re-run)"; exit 0; }
dst="$profile/user.js"
touch "$dst"
awk '
  /=== zen-sync managed block/ {skip=1}
  skip==0 {print}
  /=== end zen-sync managed block ===/ {skip=0}
' "$dst" > "$dst.tmp"
{ cat "$dst.tmp"; echo; cat "$SRC"; } > "$dst"
rm -f "$dst.tmp"
echo "zen-userjs: user.js installed in $profile (takes effect next time Zen starts)"
