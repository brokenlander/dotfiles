#!/bin/sh
# Clipboard bridge for tmux over MobaXterm X11 forwarding.
# MobaXterm ignores OSC 52; its X server syncs the X CLIPBOARD with Windows.
# The forwarded DISPLAY rotates on every SSH reconnect and every stored copy
# (shell env, tmux global, tmux session) goes stale, so probe for one that
# answers instead of trusting any of them.
#   copy [pane]   stdin -> clipboard     paste [pane]   clipboard -> pane     probe   print the DISPLAY it would use
# The pane id comes from the binding (#{pane_id}); TMUX_PANE in a job is the
# server's first pane, not the job's. Without it, fall back to the job's session.

showenv_value() {
    # only a real DISPLAY=... line; "-DISPLAY" unset markers are ignored
    tmux showenv "$@" DISPLAY 2>/dev/null | sed -n 's/^DISPLAY=//p'
}

candidates() {
    [ -n "$DISPLAY" ] && printf '%s\n' "$DISPLAY"
    showenv_value -g
    [ -n "$T" ] && showenv_value -t "$T"
    ss -ltn 2>/dev/null | awk '$4 ~ /:60[0-9][0-9]$/ { sub(/.*:/, "", $4); printf "localhost:%d.0\n", $4 - 6000 }'
}

resolve_display() {
    candidates | awk 'NF && !seen[$0]++' | while read -r d; do
        timeout 1 xdpyinfo -display "$d" >/dev/null 2>&1 && { printf '%s\n' "$d"; exit 0; }
    done
}

# Export a live DISPLAY. With "cache", also store it globally in tmux and drop
# a session-level entry (stale value or "-DISPLAY" marker) that would shadow
# it for new panes. setenv -u deletes the entry; -r would CREATE the marker.
use_display() {
    d=$(resolve_display)
    [ -n "$d" ] || return 1
    DISPLAY=$d; export DISPLAY
    [ "$1" = cache ] || return 0
    tmux setenv -g DISPLAY "$d" 2>/dev/null
    [ -n "$T" ] || return 0
    e=$(tmux showenv -t "$T" DISPLAY 2>/dev/null)
    if [ -n "$e" ] && [ "$e" != "DISPLAY=$d" ]; then
        tmux setenv -t "$T" -u DISPLAY 2>/dev/null
    fi
}

T=${2:-}
if [ -z "$T" ]; then
    case "$TMUX" in *,*,*) T="\$${TMUX##*,}" ;; esac
fi

case "$1" in
copy)
    # Silent on every path: run-shell shows any output as a tmux message, and
    # the selection is already in the tmux buffer if the clipboard is unreachable.
    if use_display cache; then
        timeout 2 xsel -i --clipboard >/dev/null 2>&1
    else
        cat >/dev/null
    fi
    exit 0
    ;;
paste)
    c=
    use_display cache && c=$(timeout 2 xsel -o --clipboard 2>/dev/null | tr -d '\r')
    if [ -n "$c" ]; then
        printf %s "$c" | tmux load-buffer -b rclick -
        tmux paste-buffer -p -d -b rclick ${T:+-t "$T"}
    else
        tmux paste-buffer -p ${T:+-t "$T"}
    fi
    ;;
probe)
    d=$(resolve_display)
    [ -n "$d" ] && printf '%s\n' "$d"
    ;;
esac
