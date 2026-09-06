#!/usr/bin/env sh
# Pick a project (from your zoxide dirs, via sesh) and spin a fresh worktree
# agent there. Run inside a tmux popup.
set -u
SESH="$(command -v sesh 2>/dev/null || echo "$HOME/go/bin/sesh")"
AGENT="$HOME/dotfiles/bin/agent"
[ -x "$SESH" ] || { printf 'sesh not installed\n'; sleep 2; exit 0; }

pick="$("$SESH" list -z --icons 2>/dev/null | fzf --ansi --no-sort \
	--prompt '⚡ new agent in: ' \
	--header 'a fresh worktree agent in the chosen repo')"
[ -z "$pick" ] && exit 0
dir="$(printf '%s' "$pick" | sed 's/^[^ ]* //')"   # drop the leading icon
exec "$AGENT" "$dir"
