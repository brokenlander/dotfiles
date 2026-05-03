# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Overview

Personal dotfiles for a terminal development environment. Manages ZSH, Git, Neovim, Tmux, Kitty, Kate, and hardware-specific configs across Linux (Ubuntu/Debian). Three tiers:

- **Server** — any Linux box (CLI tools, runtimes, Docker, Neovim, Tmux)
- **Desktop** — Kubuntu with GUI (Kitty, Kate, KDE theming, apps) — auto-detected via `HAS_DISPLAY`
- **Workstation** — this specific machine (NVIDIA RTX 5090, peripherals, CUDA, gaming)

## Installation

Three scripts, run in order:

```bash
./scripts/install-dependencies.sh   # system packages, tools, runtimes
./scripts/install.sh                 # symlinks configs, installs plugins
./scripts/workstation.sh             # hardware-specific (workstation only)
```

Post-install manual steps: `gh auth login`, OneDrive sync, Timeshift snapshot, KDE panel/Krohnkite tweaks.

## Structure

```
dotfiles/
├── nvim/           # Neovim config (Lazy.nvim, 30+ plugins, LSP, Mason)
├── zsh/            # Shell aliases, keybindings, tool integrations
├── tmux/           # Tmux config (Tokyo Night, TPM plugins)
├── git/            # .gitconfig + .gitignore_global
├── git-hooks/      # Global hooks (block AI references in commits)
├── kitty/          # Kitty terminal config (desktop only)
├── kate/           # Kate Tokyo Night theme (desktop only)
├── starship/       # Starship prompt config
├── btop/           # System monitor config + Tokyo Night theme
├── cava/           # Audio visualizer config (desktop only)
├── fastfetch/      # System info display config
├── mangohud/       # Game overlay config (workstation)
├── wallpaper/      # Desktop wallpaper
└── scripts/
    ├── install-dependencies.sh  # Server + Desktop packages
    ├── install.sh               # Symlinks + plugin installs
    ├── workstation.sh           # Hardware-specific setup
    ├── patch-discord-plugin.sh  # Fix DM recipientId bug (re-run after plugin updates)
    ├── sync-zen-settings.sh     # Zen Browser Windows sync
    └── uninstall.sh             # Restore original configs
```

## Key Design Decisions

- **Symlink-based**: repo is single source of truth, changes take effect immediately
- **Non-destructive**: backs up existing configs to `~/.dotfiles_backup/`
- **Three-tier display-aware**: `HAS_DISPLAY` and `IS_KDE` flags auto-detect environment
- **No Oh-My-ZSH**: Starship prompt + manual ZSH plugins for faster shell startup
- **fnm over NVM**: ~200x faster shell init
- **uv + micromamba**: uv for pip/venv, micromamba for conda packages
- **Idempotent scripts**: all installers check before installing, safe to re-run

## Git Hooks

Global hooks live in `git-hooks/` and are symlinked to `~/.git-hooks/` (referenced by `.gitconfig` hooksPath):

- **pre-commit**: blocks CLAUDE.md from being committed; rejects staged diffs containing `claude` or `anthropic`
- **commit-msg**: rejects commit messages containing `claude` or `anthropic`

**Important for Claude Code**: these hooks will block any commit that references Claude/Anthropic. The Co-Authored-By trailer and any AI references must be stripped before committing.

## Tool Stack

**Shell**: ZSH + Starship prompt + zsh-autosuggestions + fast-syntax-highlighting + zsh-completions

**CLI replacements**: bat (cat), eza (ls), fd (find), ripgrep (grep), zoxide (cd), delta (diff), dust (du), btop (top), tldr (man), duf (df), difftastic (structural diff), gping (ping)

**Dev tools**: Neovim (LSP, Mason, Treesitter), lazygit, lazydocker, fzf, direnv, gh CLI, glow (markdown)

**Runtimes**: fnm (Node.js), uv (Python/pip), micromamba (conda), pipx (global Python tools)

**System info**: fastfetch (auto-runs on shell start), nvtop (GPU monitor), cava (audio visualizer), cmatrix, cbonsai

**Desktop** (auto-detected): Kitty (Tokyo Night), Kate (Tokyo Night), KDE Breeze Dark + Papirus-Dark icons + Bibata-Modern-Ice cursor, JetBrains Mono Nerd Font, Krohnkite (tiling), Zen Browser, Vesktop, OnlyOffice, Spotify, Haruna, KeePassXC, Solaar, OBS Studio, Timeshift, OneDrive

**Workstation**: NVIDIA driver 590-open, CUDA 13.1, OpenLinkHub (Corsair cooling), Keymapp (ZSA Voyager), Elgato Wave 3 WirePlumber fix, Logitech UVC webcam (`cameractrls` GUI in `~/.local/bin`), Steam, MangoHud (auto-enabled via `MANGOHUD=1`), Gamemode, ProtonUp-Qt

## Neovim

- **Leader**: Space
- **Plugin manager**: Lazy.nvim (auto-bootstrap)
- **LSP servers** (via Mason): basedpyright, lua_ls, ts_ls, html, cssls, tailwindcss, svelte, graphql, emmet_ls, prismals
- **Formatters**: prettier, stylua, isort, black
- **Key bindings**: gd (definition), gR (references), `<leader>ca` (code action), `<leader>rn` (rename), Tab/Shift+Tab (buffers), `<leader>ee` (explorer), `<leader>ff` (find files)

## ZSH Config

Modular files sourced from `~/.zshrc`:
- `zsh/aliases.zsh` — modern CLI aliases (cat->bat, ls->eza, etc.)
- `zsh/key-bindings.zsh` — navigation + Italian keyboard tilde
- `zsh/integrations.zsh` — fnm, fzf, direnv, micromamba, Starship, MangoHud env, fastfetch on start

Shell starts in `~/forge` by default (unless inside Neovim). Zoxide init is last in `.zshrc`.

**Important**: standard commands are aliased to modern replacements. When debugging, check aliases first.

## Git Config

- Auth via GitHub CLI (`gh auth git-credential`)
- Delta pager (side-by-side, line numbers)
- Global hooks path: `~/.git-hooks/`
- 20+ aliases including GitHub CLI shortcuts (git pr, git browse, git issues)
- Auto-setup remote on first push (`push.autoSetupRemote = true`)

## Discord Plugin Patch

The Claude Code Discord plugin (`~/.claude/plugins/.../discord/server.ts`) has a bug where `discord.js` sometimes returns `undefined` for `ch.recipientId` on fetched DM channels, causing outbound replies to fail with "not allowlisted." Plugin updates overwrite the fix.

Re-apply after any plugin update:

```bash
./scripts/patch-discord-plugin.sh
```

The patch adds a persistent `channelId -> userId` cache that populates on every inbound DM and falls back to it when `recipientId` is missing. May become unnecessary if the upstream plugin fixes this.
