#!/bin/sh
# Clipboard bridge for tmux over MobaXterm X11 forwarding.
# MobaXterm's terminal ignores OSC 52, but its X server syncs the X CLIPBOARD
# with the Windows clipboard. DISPLAY changes on every SSH reconnect, so it
# must be resolved from the tmux session env at call time, not inherited.
eval "$(tmux showenv -s DISPLAY 2>/dev/null || tmux showenv -gs DISPLAY 2>/dev/null)"

case "$1" in
copy)
    # stdin = selection (from tmux-yank copy-pipe)
    exec timeout 2 xsel -i --clipboard
    ;;
paste)
    c=$(timeout 2 xsel -o --clipboard 2>/dev/null | tr -d '\r')
    if [ -n "$c" ]; then
        printf %s "$c" | tmux load-buffer -b rclick -
        tmux paste-buffer -p -d -b rclick
    else
        tmux paste-buffer -p
    fi
    ;;
esac
