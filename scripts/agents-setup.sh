#!/bin/bash
# Agent workflow setup, shared by omarchy/install.sh and scripts/install.sh:
#   1. agent-sidebar  (~/forge/agent-sidebar, built from its repo)
#   2. agent tools     (~/forge/agent-sidebar/bin, on PATH via shell/env.sh)
#   3. tmux agent layer (agent-sidebar tmux/agents.conf) + tmux-resurrect + Claude Code hooks
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
A = h + "/forge/agent-sidebar"
want = [
    ("SessionStart", A + "/bin/agent-board-hook"),
    ("SessionStart", A + "/tmux/claude-pane-hook.sh"),
    ("PostToolUse", A + "/bin/agent-board-hook"),
    ("UserPromptSubmit", A + "/bin/agent-board hook"),
]
# Hooks from before the tools moved out of dotfiles
old = {h + "/dotfiles/bin/pm-board-hook", h + "/dotfiles/tmux/claude-pane-hook.sh", h + "/dotfiles/bin/pm-board hook"}
for event, rows in list(hooks.items()):
    for r in rows:
        r["hooks"] = [x for x in r.get("hooks", []) if x.get("command") not in old]
    hooks[event] = [r for r in rows if r.get("hooks")]
for event, cmd in want:
    rows = hooks.setdefault(event, [])
    if not any(x.get("command") == cmd for r in rows for x in r.get("hooks", [])):
        rows.append({"hooks": [{"type": "command", "command": cmd, "timeout": 5}]})
tmp = f + ".tmp"
json.dump(s, open(tmp, "w"), indent=2)
os.replace(tmp, f)
PY

# The board briefing for Claude Code and opencode (agent-sidebar/briefing.md);
# an older copy (it named the pm-* tools) is replaced
for doc in "$HOME/.claude/CLAUDE.md" "$HOME/.config/opencode/AGENTS.md"; do
  mkdir -p "$(dirname "$doc")"
  if grep -qsF 'pm-board' "$doc"; then
    python3 -I - "$doc" "$SIDEBAR/briefing.md" <<'PYB'
import sys, re
doc, new = open(sys.argv[1]).read(), open(sys.argv[2]).read()
i = doc.find("## Other agents")
if i >= 0:
    j = doc.find("\n## ", i + 3)
    doc = doc[:i] + new.rstrip("\n") + "\n" + (doc[j:] if j >= 0 else "")
    open(sys.argv[1], "w").write(doc)
PYB
  fi
  grep -qsF '<!-- herd -->' "$doc" || { [ -s "$doc" ] && printf '\n' >>"$doc"; cat "$SIDEBAR/briefing.md" >>"$doc"; }
done

# The Cyan persona, as a marked block at the top of the same file
"$DOTFILES/claude/persona.sh" install || echo "persona: not installed, see above"

echo "agent workflow ready: agent-sidebar, agent tools, tmux agent layer, Claude hooks, persona"
