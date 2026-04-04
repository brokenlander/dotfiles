# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Overview

Personal dotfiles for a terminal development environment. Manages ZSH, Git, Neovim, Tmux, Kitty, and Kate configs across Linux (Ubuntu/Debian). Supports both headless servers and Kubuntu desktop via automatic display detection.

## Installation

Two-step process, run in order:

```bash
./scripts/install-dependencies.sh   # system packages, tools, runtimes
./scripts/install.sh                 # symlinks configs, installs plugins
```

Desktop-only packages (Kitty, Kate, KDE settings, OnlyOffice, Vesktop, fonts) are auto-skipped on headless servers via `HAS_DISPLAY` detection.

## Structure

```
dotfiles/
├── nvim/           # Neovim config (Lazy.nvim, 30+ plugins, LSP, Mason)
├── zsh/            # Shell aliases, keybindings, tool integrations
├── tmux/           # Tmux config (Tokyo Night, TPM plugins)
├── git/            # .gitconfig + .gitignore_global
├── kitty/          # Kitty terminal config (desktop only)
├── kate/           # Kate Tokyo Night theme (desktop only)
├── starship/       # Starship prompt config
├── scripts/        # install, uninstall, test-colors
```

## Key Design Decisions

- **Symlink-based**: repo is single source of truth, changes take effect immediately
- **Non-destructive**: backs up existing configs to `~/.dotfiles_backup/`
- **Display-aware**: `HAS_DISPLAY` flag auto-detects GUI vs headless
- **No Oh-My-ZSH**: uses Starship prompt + manual ZSH plugins for faster shell startup
- **fnm over NVM**: ~200x faster shell init
- **uv + micromamba**: uv for pip/venv, micromamba for conda packages

## Tool Stack

**Shell**: ZSH + Starship prompt + zsh-autosuggestions + zsh-syntax-highlighting + fast-syntax-highlighting + zsh-completions

**CLI replacements**: bat (cat), eza (ls), fd (find), ripgrep (grep), zoxide (cd), delta (diff), dust (du), btop (top), tldr (man), duf (df), difftastic (structural diff)

**Dev tools**: Neovim (LSP, Mason, Treesitter), lazygit, lazydocker, fzf, direnv, gh CLI

**Runtimes**: fnm (Node.js), uv (Python/pip), micromamba (conda), pipx (global Python tools)

**Desktop** (auto-detected): Kitty (Tokyo Night), Kate (Tokyo Night), KDE Breeze Dark, JetBrains Mono Nerd Font

## Neovim

- **Leader**: Space
- **Plugin manager**: Lazy.nvim (auto-bootstrap)
- **LSP servers** (via Mason): basedpyright, lua_ls, ts_ls, html, cssls, tailwindcss, svelte, graphql, emmet_ls, prismals
- **Formatters**: prettier, stylua, isort, black
- **Key bindings**: gd (definition), gR (references), `<leader>ca` (code action), `<leader>rn` (rename), Tab/Shift+Tab (buffers)

## ZSH Config

Modular files sourced from `~/.zshrc`:
- `zsh/aliases.zsh` — modern CLI aliases (cat→bat, ls→eza, etc.)
- `zsh/key-bindings.zsh` — navigation + Italian keyboard tilde
- `zsh/integrations.zsh` — fnm, fzf, direnv, micromamba, Starship init

**Important**: standard commands are aliased to modern replacements. When debugging, check aliases first.

## Git Config

- Auth via GitHub CLI (`gh auth git-credential`)
- Delta pager (side-by-side, line numbers)
- 20+ aliases including GitHub CLI shortcuts (git pr, git browse, git issues)
