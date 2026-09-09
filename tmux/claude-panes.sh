#!/bin/sh
# Bring agent conversations back after a tmux-resurrect restore. Handles every
# agent in bin/pm-agent-defs (claude, opencode, codex) — the name is historical,
# the tmux hooks reference it.
#   save      tag agent panes, then record every one of them (post-save-all hook)
#   restore   relaunch each recorded conversation in its pane (post-restore-all hook)
#   tag       tag agent panes the SessionStart hook missed
#   args PID  that process's argv without the binary or any resume/continue flags
. "$HOME/dotfiles/bin/pm-agent-defs"
dir=${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect
f=$dir/claude-panes.tsv
tab=$(printf '\t')

args_of() {
    tr '\0' '\n' < "/proc/$1/cmdline" 2>/dev/null | tail -n +2 | awk '
        NR==1 && system("[ -f \"" $0 "\" ]")==0 { next }
        skip && !/^-/ { skip=0; next } { skip=0 }
        $0=="-c" || $0=="--continue" { next }
        $0=="-r" || $0=="--resume" { skip=1; next }
        /^--resume=/ { next }
        # keep only flags; drop positional args (e.g. a slot bootstrap prompt),
        # which must NOT be replayed ahead of --resume on restore
        /^-/ { printf "%s%s", (n++ ? " " : ""), $0 }'
}

tag_panes() {
    # EVERY agent pane, not just untagged ones: the @claude_session tag goes
    # stale (or crossed) on resume/compact, but the live process's session file
    # — keyed by pid — is ground truth. Always refresh from it. Only claude
    # exposes a per-pane session id; the others resume their newest session.
    tmux list-panes -a -F "#{pane_id}${tab}#{pane_pid}${tab}#{pane_current_command}" |
    awk -F'\t' -v ags="$PM_AGENTS" 'BEGIN{n=split(ags,a," ")}
        {for(i=1;i<=n;i++) if($3==a[i]) {print $1, $2, $3; next}}' |
    while read -r pane ppid cmd; do
        tmux set -p -t "$pane" @pm_agent_id "$cmd"
        [ "$cmd" = claude ] || continue
        c=$(pgrep -x claude -P "$ppid" | head -n 1); [ -n "$c" ] || continue
        id=$(jq -r '.sessionId // .session_id // empty' "$HOME/.claude/sessions/$c.json" 2>/dev/null); [ -n "$id" ] || continue
        tmux set -p -t "$pane" @claude_session "$id"
        tmux set -p -t "$pane" @claude_args "$(args_of "$c")"
    done
}

case "$1" in
args) args_of "$2" ;;
tag) tag_panes ;;
save)
    mkdir -p "$dir"
    tag_panes
    # one list per resurrect save, named like it, so a restore reads the one
    # that matches the layout it brings back
    ts=$(readlink "$dir/last" 2>/dev/null | sed -n 's/^tmux_resurrect_\(.*\)\.txt$/\1/p')
    out=$f; [ -n "$ts" ] && out="$dir/claude-panes_$ts.tsv"
    tmux list-panes -a -F "#{session_name}${tab}#{window_index}${tab}#{pane_index}${tab}#{pane_current_path}${tab}#{pane_current_command}${tab}#{@claude_session}${tab}#{@claude_args}" |
        awk -F'\t' -v OFS='\t' -v ags="$PM_AGENTS" '
            BEGIN{n=split(ags,a," ")}
            { ok=0; for(i=1;i<=n;i++) if($5==a[i]) ok=1
              if(!ok) next
              if($5=="claude" && $6=="") next   # claude needs its session id
              print $1,$2,$3,$4,$5,$6,$7 }' > "$out.tmp" &&
        mv "$out.tmp" "$out" && { [ "$out" = "$f" ] || ln -sfn "$(basename "$out")" "$f"; }
    ;;
restore)
    [ -s "$f" ] || exit 0
    sleep 2
    # resolve every target to a pane id first: killing a pane renumbers the rest
    launch=$(while IFS="$tab" read -r s w p path agent id args; do
        pid=$(tmux display -p -t "=$s:$w.$p" '#{pane_id}' 2>/dev/null) || continue
        printf '%s\t%s\t%s\t%s\t%s\n' "$pid" "$path" "$agent" "$id" "$args"
    done < "$f")
    # resurrect brings the sidebar panes back as bare shells next to the ones
    # the sidebar plugin reopens; drop them
    [ -r "$dir/last" ] && awk -F'\t' '$1=="pane" && $10=="agent-sidebar" {print $2 "\t" $3 "\t" $6}' "$dir/last" |
    while IFS="$tab" read -r s w p; do
        pid=$(tmux display -p -t "=$s:$w.$p" '#{pane_id}' 2>/dev/null) || continue
        case "$(tmux display -p -t "$pid" '#{pane_current_command}')" in *sh) tmux kill-pane -t "$pid" ;; esac
    done
    printf '%s\n' "$launch" | while IFS="$tab" read -r pid path agent id args; do
        [ -n "$pid" ] || continue
        tmux display -p -t "$pid" '' >/dev/null 2>&1 || continue
        # already running an agent? leave it alone
        agent_of_command "$(tmux display -p -t "$pid" '#{pane_current_command}')" >/dev/null && continue
        cmd=$(agent_resume_cmd "$agent" "$id" "$args") || continue
        tmux send-keys -t "$pid" "cd '$path' && $cmd" Enter
        sleep 1
    done
    ;;
*)
    echo "usage: $0 save|restore|tag|args PID" >&2; exit 2 ;;
esac
