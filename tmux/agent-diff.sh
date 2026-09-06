#!/usr/bin/env sh
# Live diff of an agent's own worktree. Waits for its claude pane to enter the
# worktree (claude creates it a moment after launch), then opens lazygit there.
set -u
sess="${1:-}"
[ -n "$sess" ] || exit 0

wt=""
i=0
while [ "$i" -lt 120 ]; do
	wt=$(tmux list-panes -t "=$sess" \
		-F '#{pane_current_command} #{pane_current_path}' 2>/dev/null |
		awk '$1=="claude"{print $2; exit}')
	case "$wt" in
	*/.claude/worktrees/*|*/.worktrees/*) [ -d "$wt" ] && break ;;
	esac
	wt=""; i=$((i + 1)); sleep 0.5
done

if [ -z "$wt" ]; then
	printf 'no worktree found for %s yet\n' "$sess"; sleep 3; exit 0
fi
cd "$wt" && exec lazygit
