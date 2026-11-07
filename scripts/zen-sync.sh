#!/usr/bin/env bash
# zen-sync.sh — sync Zen settings across machines through this dotfiles repo.
#
# WHAT SYNCS HOW (two layers):
#   Layer 1 — Firefox Sync (your Mozilla account): favorites, spaces, folders,
#     pinned tabs, bookmarks, history, passwords, AND the appearance/behavior
#     prefs opted in by zen/user.js. Sign in on each machine; nothing to copy.
#   Layer 2 — this script: the files Firefox Sync can't carry —
#     keyboard shortcuts (customKeys.json), mods (zen-themes.json + the mod
#     folders under chrome/zen-themes/). Those live in zen/profile/ in this repo.
#
# USAGE:
#   zen-sync.sh pull     deploy repo -> profile (new machine, or after `git pull`)
#   zen-sync.sh push     capture profile -> repo (after you change shortcuts/mods)
#   zen-sync.sh status   show what differs
#
# Typical flow: change a shortcut on machine A -> `zen-sync.sh push` -> commit +
# push the repo -> on machine B: `git pull` -> `zen-sync.sh pull`.

set -uo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(dirname "$SCRIPT_DIR")"
REPO_ZEN="$DOTFILES/zen"
REPO_PROFILE="$REPO_ZEN/profile"

# Files/dirs Firefox Sync can't carry, mirrored in the repo (Layer 2).
SYNC_FILES=(customKeys.json zen-themes.json)
SYNC_DIRS=(chrome/zen-themes)   # mod source folders; NOT chrome/zen-themes.css (derived)

die() { echo -e "${RED}error:${NC} $*" >&2; exit 1; }

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
  # Fallback: most recently used *.Default* profile.
  p=$(ls -dt "$base"/*.Default* 2>/dev/null | head -1)
  [ -n "$p" ] && [ -d "$p" ] && { echo "$p"; return 0; }
  return 1
}

guard_not_running() {
  if pgrep -x zen >/dev/null 2>&1; then
    die "Zen is running — close it first (it writes these files on the fly)."
  fi
}

deploy_userjs() {
  local profile="$1" src="$REPO_ZEN/user.js" dst="$profile/user.js"
  [ -f "$src" ] || return 0
  touch "$dst"
  # Strip any previous managed block, keep everything else the user has.
  awk '
    /=== zen-sync managed block/ {skip=1}
    skip==0 {print}
    /=== end zen-sync managed block ===/ {skip=0}
  ' "$dst" > "$dst.zntmp"
  { cat "$dst.zntmp"; echo; cat "$src"; } > "$dst"
  rm -f "$dst.zntmp"
  echo -e "  ${GREEN}user.js${NC} managed block deployed"
}

copy_item() { # copy_item <src-root> <dst-root> <relpath>
  local s="$1/$3" d="$2/$3"
  if [ -d "$s" ]; then
    mkdir -p "$(dirname "$d")"; rm -rf "$d"; cp -a "$s" "$d"
    echo -e "  ${GREEN}$3/${NC}"
  elif [ -f "$s" ]; then
    mkdir -p "$(dirname "$d")"; cp -a "$s" "$d"
    echo -e "  ${GREEN}$3${NC}"
  fi
}

cmd_pull() {
  local profile; profile=$(find_profile) || die "no Zen profile found under ~/.config/zen"
  guard_not_running
  echo "Deploying repo -> $profile"
  deploy_userjs "$profile"
  for f in "${SYNC_FILES[@]}"; do copy_item "$REPO_PROFILE" "$profile" "$f"; done
  for d in "${SYNC_DIRS[@]}";  do copy_item "$REPO_PROFILE" "$profile" "$d"; done
  echo -e "${GREEN}Done.${NC} Sign this machine into your Mozilla account for Layer 1."
}

cmd_push() {
  local profile; profile=$(find_profile) || die "no Zen profile found under ~/.config/zen"
  guard_not_running
  echo "Capturing $profile -> repo"
  mkdir -p "$REPO_PROFILE"
  for f in "${SYNC_FILES[@]}"; do copy_item "$profile" "$REPO_PROFILE" "$f"; done
  for d in "${SYNC_DIRS[@]}";  do copy_item "$profile" "$REPO_PROFILE" "$d"; done
  echo -e "${GREEN}Done.${NC} Now: git add -A zen/ && git commit && git push"
}

cmd_status() {
  local profile; profile=$(find_profile) || die "no Zen profile found under ~/.config/zen"
  echo "Profile: $profile"
  for f in "${SYNC_FILES[@]}"; do
    if diff -q "$REPO_PROFILE/$f" "$profile/$f" >/dev/null 2>&1; then
      echo -e "  ${GREEN}=${NC} $f"
    else
      echo -e "  ${YELLOW}≠${NC} $f (repo and profile differ — push or pull)"
    fi
  done
}

case "${1:-}" in
  pull)   cmd_pull ;;
  push)   cmd_push ;;
  status) cmd_status ;;
  *) echo "usage: $0 {pull|push|status}"; exit 1 ;;
esac
