#!/bin/sh
# Claude Code SessionStart hook. Tags the tmux pane with the conversation id and
# the flags the agent was started with, so claude-panes.sh can bring it back
# after a tmux-resurrect restore. Silent, never fails the session.
[ -n "$TMUX_PANE" ] || exit 0
id=$(jq -r '.session_id // empty' 2>/dev/null)
[ -n "$id" ] || exit 0

# walk up to the process that spawned the hook chain
p=$PPID
while [ "$p" -gt 1 ] 2>/dev/null; do
    a0=$(tr '\0' '\n' < "/proc/$p/cmdline" 2>/dev/null | head -n 1)
    case "${a0##*/}" in claude) break ;; esac
    p=$(sed 's/.*) //' "/proc/$p/stat" 2>/dev/null | cut -d' ' -f2)
done

# its argv without the binary, an interpreter script, or resume/continue flags
args=
if [ "$p" -gt 1 ] 2>/dev/null; then
    args=$(tr '\0' '\n' < "/proc/$p/cmdline" | tail -n +2 | awk '
        NR==1 && system("[ -f \"" $0 "\" ]")==0 { next }
        skip && !/^-/ { skip=0; next } { skip=0 }
        $0=="-c" || $0=="--continue" { next }
        $0=="-r" || $0=="--resume" { skip=1; next }
        /^--resume=/ { next }
        { printf "%s%s", (n++ ? " " : ""), $0 }')
fi

tmux set -p -t "$TMUX_PANE" @claude_session "$id" 2>/dev/null
tmux set -p -t "$TMUX_PANE" @claude_args "$args" 2>/dev/null
exit 0
