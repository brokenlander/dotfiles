#!/bin/sh
# The tmux theme keeps its rounded pills and takes every colour from the
# terminal palette. Run from anywhere: sh ~/dotfiles/tests/tmux-theme.sh
conf="${1:-$(dirname "$0")/../tmux/.tmux.conf}"
sock="theme-test-$$"
fails=0
ok() { printf '  OK    %s\n' "$1"; }
bad() { printf '  FAIL  %s\n' "$1"; fails=$((fails + 1)); }

theme="$(sed -n '/^# --- theme/,/^# --- plugins/p' "$conf")"
[ -n "$theme" ] && ok "the theme section is there" || bad "the theme section is there"

for opt in status-left status-right window-status-current-format pane-border-format; do
	line="$(printf '%s\n' "$theme" | grep "^set -g $opt ")"
	case "$line" in
	*\\uE0B6*\\uE0B4*) ok "$opt keeps its rounded pill" ;;
	*) bad "$opt keeps its rounded pill (\\uE0B6 ... \\uE0B4)" ;;
	esac
done

if printf '%s\n' "$theme" | grep -v '^#' | grep -qiE '#[0-9a-f]{6}([^0-9a-f]|$)'; then
	bad "no fixed RGB colours in the theme: $(printf '%s\n' "$theme" | grep -v '^#' | grep -oiE '#[0-9a-f]{6}' | sort -u | tr '\n' ' ')"
else
	ok "no fixed RGB colours in the theme"
fi

if LC_ALL=C grep -v '^\s*#' "$conf" | grep -qP '[\x{E000}-\x{F8FF}]|[\x{F0000}-\x{10FFFF}]' 2>/dev/null ||
	python3 -c "import sys; s=open(sys.argv[1],encoding='utf-8').read(); sys.exit(0 if any(0xE000<=ord(c)<=0xF8FF or ord(c)>=0xF0000 for c in s) else 1)" "$conf"; then
	bad "glyphs are written as \\u escapes, not raw characters"
else
	ok "glyphs are written as \\u escapes, not raw characters"
fi

printf '%s\n' "$theme" | grep '^set -g ' > "/tmp/$sock.conf"
tmux -L "$sock" -f /dev/null new-session -d -s t 2>/dev/null
if tmux -L "$sock" source-file "/tmp/$sock.conf" 2>"/tmp/$sock.err"; then
	ok "the theme loads on a clean tmux"
else
	bad "the theme loads on a clean tmux: $(head -1 "/tmp/$sock.err")"
fi
case "$(tmux -L "$sock" show -gv status-left 2>/dev/null)" in
*"$(printf '\356\202\266')"*) ok "tmux draws the pill caps from the escapes" ;;
*) bad "tmux draws the pill caps from the escapes" ;;
esac
tmux -L "$sock" kill-server 2>/dev/null
rm -f "/tmp/$sock.conf" "/tmp/$sock.err" "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/$sock"

[ "$fails" = 0 ] && printf '\n  OK    tmux theme intact\n' || { printf '\n  %s check(s) failed\n' "$fails"; exit 1; }
