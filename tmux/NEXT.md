# tmux / dotfiles — state & what's next

Handoff after the 2026-09-06/07 sessions. Everything below is committed and
pushed to `brokenlander/dotfiles` and `brokenlander/agent-sidebar`.

## Shipped & working (keepers)

- tmux on **3.7c**; the old 3.4 is gone (binary + package removed).
- **agent-sidebar** upgrades: holds width on resize; one control (open/close in
  every session at once); alt-screen fresh redraw; middle-click menu (`-M -O`,
  tmux 3.5+); **sessions** section (`@agent_sidebar_sessions on`, clickable:
  left = jump, middle = jump/kill); **key legend** (`@agent_sidebar_legend`,
  `;`-separated so `|`/`-` can be shown); `@agent_sidebar_exclude 'scratch'`.
  Removed the craftzdog claude-session-manager plugin.
- **Legend:** `e sidebar · o agents · y sesh · s tree · d scratch · a new agent ·
  q end agent · r reset · g diff · | split · - split · x close`.
  (config-reload moved from `prefix r` to **`prefix R`**.)
- Nav keys: sidebar `prefix e`, agent picker `prefix o`, sesh `prefix y`,
  choose-tree `prefix s`, scratch `prefix d` (detach `prefix D`). Split: `|`
  (left/right), `-` (top/bottom). "Merge"/un-split = `prefix x` (close a pane).

### The agent workflow (all new this session)

- **`prefix a` = fuzzy-pick where to open an agent** → `bin/pm-agent-pick`
  (privatemind pinned first, then zoxide dirs, `ctrl-f` finds any dir under
  `$HOME`; sleek Tokyo-Night fzf via `tmux/fzf-theme.sh`).
  - Pick **privatemind** → an isolated **AgentN slot** (below).
  - Pick **any other dir** → `pm-agent <dir>`: a plain agent in that repo (its own
    cwd/memory, session named after the repo, a `wstat` diff window). No slot.
- **PrivateMind agent → `bin/pm-agent`:** claim a **free** slot (or make the next
  N) → fetch + reset/create its 5 sub-repo worktrees to origin/main → launch
  `claude` from the privatemind ROOT (keeps the global memory) with a brief that
  pins the slot → open the live `diff` window = `wstat AgentN`. Stamps
  `@pm_slot <N>` on the session (rename-proof; targets tmux by session-id).
  - **Free-slot rule:** *busy* only while a tmux session holds it (session
    `privatemind-a<N>` via `@pm_slot`, or a pane parked inside it) — pure
    session-based. **48h staleness guard:** uncommitted work blocks reuse only
    while fresh (<48h by newest changed-file mtime); older uncommitted is reset on
    reuse. Committed branches always survive (reuse only detaches).
  - `pm-agent --slots` (`-l`) tracker: FREE / busy (held by …) / uncommitted
    <48h / stale >48h + which slot is next. `--dry-run` (`-n`) shows the pick.
- **`prefix q` = end agent → `bin/pm-agent-end`:** kills the session and, if it's
  an AgentN slot, resets it to origin/main (clean, reusable). **No prompt**
  (`run-shell -b`, backgrounded). Committed branches survive; uncommitted in the
  slot is discarded. A generic (non-slot) agent is just closed, repo untouched.
- **`prefix r` = reset agent → `pm-agent --reset`:** kill + relaunch a fresh agent
  with the **same name in the same slot**, repos freshly pulled off main. Runs in
  a progress popup (needs a client for switch-client). A generic agent restarts in
  its own repo (no destructive reset). The conversation restarts fresh (new session).
- **`bin/wstat`** — the live `diff` window: every repo in the slot + its footprint
  **vs the fork point from origin/main** (committed + staged/unstaged + untracked),
  **+/- per file**, every 2s. So each agent's window shows *only that agent's
  work*. `wstat --list DIR` is the machine feed (repo, base, status, +, -, path).
- **Click-to-diff:** left-click a **file row** in a `diff` window → that file's
  full diff opens full-screen (delta), `q` closes it. `bin/wclick` + the
  `MouseDown1Pane` binding (scoped to `diff` windows / the wstat pane; everything
  else — sidebar, copy, right-click paste — unchanged).
- **`prefix g` = `bin/wdiff`** — the same drill-in as a full-screen popup you can
  invoke anywhere: fzf list (+/- per file) + live delta preview, Enter = full
  diff, `q` back, ctrl-r refresh. Replaced lazygit. (`--watch` mode exists, unused.)

**Why the AgentN slot and not `cld --worktree`:** privatemind is a *workspace*
repo + **5 separate gitignored sub-repos**; one worktree can't span them. And
Claude memory is keyed to the **exact cwd** (proven: separate
`~/.claude/projects/-…-AgentN-app` dirs per subdir an agent ran in), so Claude
must launch from `~/forge/privatemind` itself to keep the global memory — hence
the slot is passed in a brief, not by running inside `AgentN/`.

## Done this session (2026-09-06/07)

- **Estate cleanup:** every AgentN slot wiped back to the 5 basics at
  origin/main; ~150 ad-hoc + non-Agent worktrees removed; **all branches
  survived** (679 app / 134 gw / 76 app-db / 45 gw-db / 992 helm). Agent1/app's
  recent work parked in `git -C Agent1/app stash@{0}`.
- **Committed + pushed** both repos. dotfiles identity was wrongly
  `Andrea Moccia <gmail>`; fixed repo config + my commits to
  **`brokenlander <94259413+brokenlander@users.noreply.github.com>`** (the noreply
  — gmail leaks the real name on a public repo).

## Done 2026-09-10

Reference for all of it is `tmux-agent.md`; this is just the list.

- **Sessions are named.** `claude --name` at launch from the tmux session name,
  re-applied on resume, and `pm-agent --rename` to fix up ones that predate it.
  Peers, tmux and the sidebar finally agree what a session is called.
- **`pm-agent --prune`.** Reclaims ad-hoc worktrees, stale free slots and local
  branches already merged into origin/main (163 of them were sitting there).
  Prints a plan; `--yes` applies it.
- **Orphaned slots.** A dead agent left its session standing and the slot
  claimed forever. `--slots` reports it, `--prune` ends it. Inferred, not
  hooked — a crash or a kill fires no SessionEnd.
- **The diff dashboards come back.** tmux-resurrect only restores a pane's
  program when `@resurrect-processes` is set, which it never was, so seven of
  nine `diff` windows were bare shells. `claude-panes.sh` restores them now and
  `revive` repairs live ones. Saved lists also expire (7 days) instead of piling
  up — 136 had accumulated in six days.
- **Amber means something.** Claude never reports a `waiting` status, so the
  sidebar's "needs you" state was dead. Idle past
  `@agent_sidebar_idle_wait` (10 min) now promotes to it.
- **`pm-roster`** — the phonebook: who is live, where, doing what, and the name
  a peer addresses. `--what` adds each agent's last line read off its
  transcript, which costs nothing. Both are cross-provider; `pm-lastsaid` holds
  one adapter per format.
- **Deleted** `wdiff --watch` (no caller — it served the rejected fzf-diff-window
  idea).

## Work left

1. **102 older `~/dotfiles` commits still `Andrea Moccia <gmail>`** — offered a
   full-history scrub to `brokenlander` (backup ref + verify tree identical +
   force-push). **Awaiting explicit "go"** — do NOT run off a casual reply.
2. **`pm-agent --prune --yes` has never been run on the real estate.** The plan
   is 163 merged branches and 5 stray worktrees; that is Andrea's call, not an
   automatic one.
3. **A codex producer** for the sidebar — opencode's is installed and verified,
   codex has none, so a codex agent shows no state. Blocked behind codex being
   usable at all: it dropped `wire_api = "chat"` and the gateway 404s on
   `/v1/responses`.
4. **Cross-provider messaging is not possible** and probably should not be
   attempted. The transport is Claude's own UDS socket; the other two neither
   listen on it nor speak it. Reading state and transcripts already works for
   all three, and that is the half that costs nothing.
5. **Review remaining keys** you dislike; remap as they come up.

## Gotchas for whoever picks this up

- **`wstat --once DIR`** — `--once`/`--list` must be the **first** arg
  (`wstat --once Agent4`, not `wstat Agent4 --once`, which hangs in the live loop).
- Sidebar reads `@agent_sidebar_*` options **once at startup**. After changing the
  legend, `touch ~/forge/agent-sidebar/agent-sidebar` to re-exec live sidebars.
- **Claude memory keys off the exact cwd, NOT the git toplevel.** Running in
  `AgentN/` gives a fresh empty memory; only `~/forge/privatemind` gives the
  global one.
- **brokenlander repos = the noreply identity**, not gmail. Don't trust a repo's
  configured `user.email` — verify. Use `--no-verify` when content legitimately
  contains `claude` (the CLI) — the guard is a blunt word match. Never put vendor
  words or AI co-author trailers in commit *messages*.
- `tmux -t '=name'` (exact-match prefix) is flaky in the Bash tool's tmux; target
  by session-id or plain name.
- Lighter touch: doubt signals are STOP signals — confirm value before stacking.
