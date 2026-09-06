#!/usr/bin/env sh
# sesh session picker, run inside a tmux popup: fuzzy-jump to or create a
# session from any live tmux session, zoxide directory, or configured project.
# Filters: ^a all, ^t tmux only, ^x zoxide dirs, ^g configs, ^f find, ^d kill.
SESH="$(command -v sesh 2>/dev/null || echo "$HOME/go/bin/sesh")"
FIND="$(command -v fd 2>/dev/null || command -v fdfind 2>/dev/null || echo find)"
[ -x "$SESH" ] || { printf 'sesh not installed: go install github.com/joshmedeski/sesh/v2@latest\n'; sleep 2; exit 0; }

sel="$("$SESH" list --icons | fzf --ansi --no-sort \
	--prompt '⚡ ' \
	--header '^a all   ^t tmux   ^x zoxide   ^g configs   ^f find   ^d kill' \
	--bind 'tab:down,btab:up' \
	--bind "ctrl-a:change-prompt(⚡ )+reload($SESH list --icons)" \
	--bind "ctrl-t:change-prompt(🪟 )+reload($SESH list -t --icons)" \
	--bind "ctrl-x:change-prompt(📁 )+reload($SESH list -z --icons)" \
	--bind "ctrl-g:change-prompt(⚙ )+reload($SESH list -c --icons)" \
	--bind "ctrl-f:change-prompt(🔎 )+reload($FIND -H -d 2 -t d . $HOME)" \
	--bind "ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡ )+reload($SESH list --icons)")"
[ -z "$sel" ] && exit 0
exec "$SESH" connect "$sel"
