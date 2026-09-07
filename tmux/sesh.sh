#!/usr/bin/env sh
# sesh session picker, run inside a tmux popup: fuzzy-jump to or create a
# session from any live tmux session, zoxide directory, or configured project.
# Filters: ^a all, ^t tmux only, ^x zoxide dirs, ^g configs, ^f find, ^d kill.
. "$HOME/dotfiles/tmux/fzf-theme.sh"
SESH="$(command -v sesh 2>/dev/null || echo "$HOME/go/bin/sesh")"
FIND="$(command -v fd 2>/dev/null || command -v fdfind 2>/dev/null || echo find)"
[ -x "$SESH" ] || { printf 'sesh not installed: go install github.com/joshmedeski/sesh/v2@latest\n'; sleep 2; exit 0; }

sel="$("$SESH" list --icons | fzf \
	--border-label ' ⚡ jump ' \
	--prompt '  session › ' \
	--header '^a all   ^t tmux   ^x dirs   ^g configs   ^f find   ^d kill' \
	--preview 'p=$(echo {} | sed "s/^[^[:alnum:]~/]* *//"); if [ -d "$p" ]; then git -C "$p" -c color.ui=always status -sb 2>/dev/null || ls -la "$p" 2>/dev/null | head -40; else tmux list-windows -t "$p" 2>/dev/null; fi' \
	--preview-window 'right,55%,border-rounded' \
	--bind 'tab:down,btab:up' \
	--bind "ctrl-a:change-prompt(  all › )+reload($SESH list --icons)" \
	--bind "ctrl-t:change-prompt(  tmux › )+reload($SESH list -t --icons)" \
	--bind "ctrl-x:change-prompt(  dirs › )+reload($SESH list -z --icons)" \
	--bind "ctrl-g:change-prompt(  config › )+reload($SESH list -c --icons)" \
	--bind "ctrl-f:change-prompt(  find › )+reload($FIND -H -d 2 -t d . $HOME)" \
	--bind "ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(  all › )+reload($SESH list --icons)")"
[ -z "$sel" ] && exit 0
exec "$SESH" connect "$sel"
