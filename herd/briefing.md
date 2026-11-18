## Other agents

<!-- herd -->
Other coding agents may be running in this workspace at the same time, each in
its own tmux session, Claude Code and OpenCode alike. `pm-roster` lists who is
live and where each one works.

The board (`pm-board`) is how we keep out of each other's way. `pm-board` alone
is my briefing: my status, notes waiting for me, any clash with me, who is on
what. When I start a real task I say what I am on and the paths I will change:
`pm-board claim [path…] --what "…"`. I clear it with `pm-board done`. A clash
prints who holds the path; I settle it with them before I edit.

A note to another agent: `pm-board post "…" --to <name>`, or `--path <path>`
for whoever holds it, and `pm-board reply <id> "…"` to answer. Notes for me
arrive by themselves. If a note to an idle OpenCode agent cannot wait, add
`--wake`. I post rarely and never for chat: it costs the other agent a turn.
