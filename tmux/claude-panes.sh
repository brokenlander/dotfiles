#!/bin/sh
# Bring agent conversations back after a tmux-resurrect restore.
#   save     record every pane tagged by claude-pane-hook.sh (post-save-all hook)
#   restore  relaunch each recorded conversation in its pane (post-restore-all hook)
dir=${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect
f=$dir/claude-panes.tsv
tab=$(printf '\t')

case "$1" in
save)
    mkdir -p "$dir"
    tmux list-panes -a -F "#{session_name}${tab}#{window_index}${tab}#{pane_index}${tab}#{pane_current_path}${tab}#{pane_current_command}${tab}#{@claude_session}${tab}#{@claude_args}" |
        awk -F'\t' -v OFS='\t' '$5=="claude" && $6!="" {print $1,$2,$3,$4,$6,$7}' > "$f.tmp" &&
        mv "$f.tmp" "$f"
    ;;
restore)
    [ -s "$f" ] || exit 0
    sleep 2
    while IFS="$tab" read -r s w p path id args; do
        t="=$s:$w.$p"
        tmux display -p -t "$t" '' >/dev/null 2>&1 || continue
        [ "$(tmux display -p -t "$t" '#{pane_current_command}')" = claude ] && continue
        tmux send-keys -t "$t" "cd '$path' && claude $args --resume $id" Enter
    done < "$f"
    ;;
*)
    echo "usage: $0 save|restore" >&2; exit 2 ;;
esac
