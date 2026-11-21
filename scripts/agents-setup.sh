#!/bin/bash
# Agent workflow setup, shared by omarchy/install.sh and scripts/install.sh:
#   1. agent-sidebar  (~/forge/agent-sidebar, built from its repo)
#   2. pm-* tools      (~/dotfiles/bin, on PATH via shell/env.sh)
#   3. tmux agent layer (tmux/agents.conf) + tmux-resurrect + Claude Code hooks
# Safe to run again.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIDEBAR="$HOME/forge/agent-sidebar"

# 1. agent-sidebar
mkdir -p "$HOME/forge"
if [ -d "$SIDEBAR/.git" ]; then
  git -C "$SIDEBAR" pull -q --ff-only || echo "agent-sidebar: could not update, using the current checkout"
else
  git clone -q https://github.com/brokenlander/agent-sidebar.git "$SIDEBAR"
fi
make -s -C "$SIDEBAR"
mkdir -p "$HOME/.config/opencode/plugins"
ln -sfn "$SIDEBAR/producers/opencode/plugin.js" "$HOME/.config/opencode/plugins/agent-sidebar.js"

# tmux-resurrect (the only tmux plugin; loaded directly by .tmux.conf, no TPM)
[ -d "$HOME/.tmux/plugins/tmux-resurrect" ] || \
  git clone -q --depth 1 https://github.com/tmux-plugins/tmux-resurrect "$HOME/.tmux/plugins/tmux-resurrect"

# 3. Claude Code hooks: the board (notes between agents) and pane restore
#    (claude-pane-hook tags each pane with its conversation for tmux-resurrect).
mkdir -p "$HOME/.claude"
python3 -I - "$HOME" <<'PY'
import json, os, sys
h = sys.argv[1]
f = os.path.join(h, ".claude/settings.json")
try:
    s = json.load(open(f))
except (OSError, ValueError):
    s = {}
hooks = s.setdefault("hooks", {})
want = [
    ("SessionStart", h + "/dotfiles/bin/pm-board-hook"),
    ("SessionStart", h + "/dotfiles/tmux/claude-pane-hook.sh"),
    ("PostToolUse", h + "/dotfiles/bin/pm-board-hook"),
    ("UserPromptSubmit", h + "/dotfiles/bin/pm-board hook"),
]
for event, cmd in want:
    rows = hooks.setdefault(event, [])
    if not any(x.get("command") == cmd for r in rows for x in r.get("hooks", [])):
        rows.append({"hooks": [{"type": "command", "command": cmd, "timeout": 5}]})
tmp = f + ".tmp"
json.dump(s, open(tmp, "w"), indent=2)
os.replace(tmp, f)
PY

# The board briefing for Claude Code and opencode (same text herd installs)
for doc in "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"; do
  mkdir -p "$(dirname "$doc")"
  grep -qsF '<!-- herd -->' "$doc" || { [ -s "$doc" ] && printf '\n' >>"$doc"; cat "$DOTFILES/herd/briefing.md" >>"$doc"; }
done

# The Cyan persona, as a marked block at the top of the same file
"$DOTFILES/claude/persona.sh" install || echo "persona: not installed, see above"

echo "agent workflow ready: agent-sidebar, pm-* tools, tmux agent layer, Claude hooks, persona"
