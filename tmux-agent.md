# tmux-agent — Cyan's mission-control

Everything behind Andrea's tmux + Claude Code agent setup: the sidebar C program,
the tmux config and scripts, and the Claude settings/theme. tmux is the
orchestration surface — agents do the editing; this is how you launch, watch,
diff, kill, reset, and resurrect them.

**Where things live**
| Piece | Location | Repo |
|---|---|---|
| tmux config + scripts | `~/dotfiles/tmux/`, `~/dotfiles/bin/` | `brokenlander/dotfiles` (public) |
| sidebar C program | `~/forge/agent-sidebar/` | `brokenlander/agent-sidebar` (public) |
| Claude settings/theme/statusline | `~/.claude/` | not a repo — local only |
| persona | `~/.claude/CLAUDE.md` | local |

Commits go out as **`brokenlander <94259413+brokenlander@users.noreply.github.com>`**
(the noreply — gmail leaks the real name on a public repo). **Never** add an AI
co-author trailer (the commit-guard blocks it too). Use `git commit --no-verify`
when file content legitimately contains `claude` (the CLI name) — the guard is a
blunt word match.

---

## 1. The sidebar (C program) — `agent-sidebar`

A small inotify-driven C TUI shown as a tmux pane, listing the agents and giving
one-click nav. Built with `make` in `~/forge/agent-sidebar`; launched by the
`sidebar.tmux` hook. Re-exec live instances after editing options with
`touch ~/forge/agent-sidebar/agent-sidebar`.

- **Zones:** agents → non-agent sessions → key legend.
- **Options (`~/dotfiles/tmux/.tmux.conf`):** `@agent_sidebar_key 'e'`,
  `@agent_sidebar_width '28'`, `@agent_sidebar_sessions 'on'`,
  `@agent_sidebar_exclude 'scratch'`, `@agent_sidebar_picker_key 'o'`,
  `@agent_sidebar_legend '…'` (see below).
- **Legend separator is `;`** (not `|`) so the `|`/`-` split keys can be shown.
- Reads its options **once at startup** → re-exec after changing them.
- Width-hold on resize; one control (open/close every session at once via a
  window-linked hook); alt-screen fresh redraw (no stale rows); middle-click menu
  (`-M -O`, needs tmux 3.5+); clickable session rows (left = jump, middle =
  jump/kill menu).
- Removed the craftzdog claude-session-manager plugin.

---

## 2. tmux (`~/dotfiles/tmux/.tmux.conf`)

tmux **3.7c** (`/usr/local/bin`; the old apt 3.4 is gone). Key legend, exactly as
shown in the sidebar:

`e sidebar · o agents · y sesh · s tree · d scratch · a new agent · q end agent ·
r reset · g diff · | split · - split · x close`

| Key | Action |
|---|---|
| `prefix e` | toggle the sidebar (all sessions at once) |
| `prefix o` | agent picker (jump between agents) |
| `prefix y` | **sesh** session jumper (popup) |
| `prefix s` | choose-tree |
| `prefix d` | **scratch** floating popup (toggle); `prefix D` = detach |
| `prefix a` | **new agent** — fuzzy picker → `pm-agent` (see §3) |
| `prefix q` | **end agent** — kill session + reset its slot to main (no prompt) |
| `prefix r` | **reset agent** — kill + relaunch same name/slot, fresh off main |
| `prefix R` | reload tmux config (moved off `r`) |
| `prefix g` | **diff** — `wdiff` full-screen fzf+delta drill-in |
| `prefix \|` / `prefix -` | split left-right / top-bottom |
| `prefix x` | close a pane (the "un-split") |

- **The bar** (`status-right`): `@label` maps `pane_current_command` so a `claude`
  pane shows **`cyan`**, sitting between the path and the clock.
- **Click-to-diff:** left-click a file row in a `diff` window → `wclick` pops that
  file's full delta diff. Scoped to `diff` windows / the wstat pane; all other
  mouse behaviour (select, copy, right-click paste) unchanged.
- **Pickers** are styled by `~/dotfiles/tmux/fzf-theme.sh` (Tokyo Night, rounded
  border + label, `❯` pointer) and shown with `display-popup -B` (single frame).

---

## 3. The agent workflow (`~/dotfiles/bin/`)

**Why AgentN slots, not `cld --worktree`:** privatemind is a *workspace* repo +
**5 separate gitignored sub-repos** (app, gateway, app-db, gateway-db, helm); one
worktree can't span them. And Claude memory keys off the **exact cwd** (separate
`~/.claude/projects/…` dirs per subdir), so Claude must launch from
`~/forge/privatemind` itself to keep the global memory — the slot is passed in a
brief, not by running inside `AgentN/`.

- **`prefix a` → `pm-agent-pick`** — fuzzy dir picker (privatemind pinned, zoxide
  dirs, `ctrl-f` finds any dir under `$HOME`). privatemind → a slot; any other dir
  → a plain agent in that repo. **Enter launches whichever agent you used last**,
  so the common case costs no extra keystroke; **`^y` claude · `^o` opencode ·
  `^x` codex** pick a different one and that becomes the new default. (Built on
  fzf `--expect` — this fzf is 0.44 and has no `transform-border-label`, so the
  agent can't be cycled live inside the picker.)
- **`pm-agent [dir]`** — claim a FREE `AgentN` slot (or make next N) → reset its 5
  sub-repos to origin/main → launch the chosen agent from the privatemind ROOT
  with a brief pinning the slot → open a `diff` window (`wstat AgentN`); the
  agent's own window is named after it (**`Cyan`** for claude, else the agent
  name) via an explicit `-n`, so tmux won't auto-rename it. Stamps `@pm_slot <N>`
  and `@pm_agent <id>` (rename-proof; targets tmux by session-id).
  - Claude is launched with **`--name <tmux session name>`**, so tmux, the
    sidebar and Claude's own peer listing all call the session the same thing.
    Without it Claude derives one (`privatemind-07`) and the three disagree,
    which makes agent-to-agent messaging guesswork. opencode and codex have no
    equivalent flag.
  - `--agent <id>` (`-a`) picks the agent; without it, the last-used one.
  - **Free-slot rule:** busy only while a tmux session holds it (`privatemind-a<N>`
    via `@pm_slot`, or a pane inside the slot). **48h guard:** uncommitted work
    blocks reuse only while fresh (<48h); older is reset on reuse. Committed
    branches always survive (reuse only detaches).
  - `pm-agent --slots` (`-l`) tracker · `--dry-run` (`-n`) shows the pick.
- **`prefix q` → `pm-agent-end`** — kill the session; if it's a slot, reset it to
  origin/main (clean, reusable). No prompt (`run-shell -b`).
- **`prefix r` → `pm-agent --reset`** — kill + relaunch a fresh agent, **same
  name/slot**, repos pulled fresh off main. Generic agents restart in place.
- **`pm-agent --rename`** — sync the display name of every *live* Claude session
  to its tmux session name (for sessions started before `--name`, or after a
  `rename-session`). It types `/rename` — a local slash command, no model call —
  into each pane, and **skips** any pane that is busy or already has something
  in its prompt box (keys sent there would append to the draft and Enter would
  submit the mixture as that agent's next message). It reads the name back
  afterwards rather than assuming, and reports what it skipped. The session you
  run it *from* is always busy, so it never renames itself — run it from another
  session, or rename this one by hand with `/rename`.
- **`pm-agent-defs`** — the **agent registry**, sourced by the picker, the
  launcher and the resurrector so all three agree. One entry per agent gives its
  tmux window name, its launch command (each takes the slot brief as a first
  message: claude positionally, codex positionally, opencode via `--prompt`; and
  a display name where the agent supports one) and its resume command. Last-used agent is remembered in
  `${XDG_STATE_HOME:-~/.local/state}/pm-agent/last-agent`, written on every
  successful launch. **Add an agent here and the picker, reset and resurrection
  all pick it up.**
- **`wstat [dir]`** — the live `diff` dashboard: each repo's footprint vs its fork
  point from origin/main (committed + uncommitted + untracked), **+/- per file**.
  So each agent's window shows *only that agent's work*. `wstat --list DIR` is the
  machine feed. **`--once`/`--list` must be the FIRST arg** or it hangs.
- **`wdiff [--watch] [dir]` (`prefix g`)** — fzf list + live delta preview; Enter =
  full diff, `q` back, ctrl-r refresh. Full-screen popup. Replaced lazygit.
- **`wclick`** — the click-to-diff handler behind the `MouseDown1Pane` binding.

---

## 4. The resurrection system (survive a tmux restart)

`tmux kill-server` then `tmux` brings **every session back AND resumes each
Claude conversation**. Save the state first (`~/.tmux/plugins/tmux-resurrect/scripts/save.sh`,
or `prefix Ctrl-s`); the systemd `tmux-resurrect-save` timer also auto-saves ~every 30 min.

- **`tmux-resurrect`** restores the layout; auto-restores on a fresh server boot
  (an `if-shell` on server-start in the conf).
- **`~/dotfiles/tmux/claude-pane-hook.sh`** (SessionStart hook, wired in
  `settings.json`) tags each pane `@claude_session` = the session id.
- **`~/dotfiles/tmux/claude-panes.sh`** (resurrect save/restore hooks) — handles
  every agent in the registry; the filename is historical (the tmux hooks
  reference it).
  - **save** → records each agent pane's session/window/pane/path/**agent**/id/args.
  - **restore** → relaunches per agent: `claude <args> --name <session>
    --resume <id>`, `opencode --continue`, `codex … resume --last`. The name is
    re-applied from the saved tmux session name because a resumed session would
    otherwise derive a fresh one — and `args_of` **must** drop `--name`, since a
    kept-but-valueless `--name` swallows `--resume` as its argument.
  - **Fidelity caveat:** only claude exposes a per-pane session id, so only claude
    resumes the *exact* conversation. opencode continues the newest session for
    that project dir (usually right); codex's `--last` is global, so two codex
    panes restored together both land on the same conversation.

**Two bugs fixed 2026-09-07/08 (commit `b61ed2c`):**
1. `args_of` kept positional args, so a slot's bootstrap prompt was replayed ahead
   of `--resume` and the agent choked → now keeps **only flags**.
2. the `@claude_session` tag goes **stale/crossed** on resume/compact (proven:
   Herd's tag pointed at Iceland PO's id) → `tag_panes` now re-reads the id from
   the **live process's** `~/.claude/sessions/<pid>.json` for **every** pane, not
   just untagged ones. That file (keyed by pid) is ground truth.

**Gotcha:** a brand-new session doesn't write its `<id>.jsonl` transcript until the
first message — so a just-started, never-used pane won't `--resume` until you type
in it once (nothing to resume anyway).

---

## 5. Claude settings (`~/.claude/`)

**`settings.json`** keys: `model`, `statusLine`, `theme`, `hooks` (the SessionStart
tag hook), `skipDangerousModePermissionPrompt` (skips the bypass startup confirm),
`effortLevel`, `tui`, `enabledPlugins`.

**`statusline.sh`** — reads the session JSON on stdin, prints a one-line status.
Model tier **aliases** (edit the block at the top): Fable→**Prime**, Opus→**Swift**, Sonnet→**mini**,
Haiku→**nano**. Current format: `<model> · <dir> · <branch> · <ctx%>` (model in
cyan; the `🦋 Cyan` brand prefix was removed since the tmux bar already shows it —
the `EMOJI`/`BRAND` vars remain, unused, for an easy re-add).

**`themes/cyan.json`** — custom theme, activated via `settings.json`
`"theme": "custom:cyan"`. Tokyo Night palette (brand cyan `#7dcfff`), tuned diffs,
full subagent color set. The `⏵⏵ bypass permissions` footer is driven by the
**`error`** token (shared with error text and the don't-ask mode — there is no
bypass-only token); it's set to the agent-counter grey `#565f89` so it reads as
parked rather than shouting. `permission` was never the lever. **Gotcha:** the themes folder must exist when the CLI starts — created
mid-session it needs ONE restart to be watched; after that, edits hot-reload
(the statusline hot-reloads always).

**`CLAUDE.md`** — the **Cyan** persona (butterfly-in-the-wire; sharp, witty,
honest). This is the identity layer — in-conversation it's already "Cyan," not
"Claude."

---

## 6. TODO / open items

- **Startup banner rebrand → NOT achievable via config.** The `Claude Code`
  wordmark is hardcoded; no setting/env/plugin overrides it. Only patching would,
  which is the ToS line we won't cross.
- **Bypass-permissions indicator** (`⏵⏵ bypass permissions on`) — DONE 2026-09-08:
  it's the **`error`** token (pulled from the bundle's mode→color map), matched to
  the `← N agent` counter grey. Cost: error text shares the tone. It **cannot be
  hidden** while in bypass mode — only leaving bypass (shift+tab) removes it.
- **102 older `~/dotfiles` commits still `Andrea Moccia <gmail>`** — a full-history
  scrub to brokenlander is offered but **needs an explicit go** (rewrites every
  hash + force-push; back up a ref first).
- **memories / personality** — further Cyan customization to explore.
- `pm-agent --prune` — reset stale/merged slots back to main on demand.
