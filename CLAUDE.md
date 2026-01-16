# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for a terminal development environment. It uses a symlink-based installation system to manage ZSH, Git, and Neovim configurations across a Linux system (Ubuntu/Debian-based). The configuration emphasizes modern CLI tools and a highly customized Neovim setup.

## Installation Architecture

The installation is a **two-step process** that must be executed in order:

1. **Dependencies** (`./scripts/install-dependencies.sh`): Installs system packages, tools, and package managers
2. **Configuration** (`./scripts/install.sh`): Creates symlinks from this repo to `~/.config/nvim`, `~/.gitconfig`, etc.

### Key Design Pattern: Symlinks

The installation script creates symlinks rather than copying files. This means:
- Changes to files in this repo immediately affect the active configuration
- The repo remains the single source of truth
- Backups are created in `~/.dotfiles_backup/` before overwriting existing configs

## Common Development Commands

### Installation
```bash
# Full fresh installation (requires restart between steps)
./scripts/install-dependencies.sh
# Start new ZSH shell
zsh
./scripts/install.sh
```

### Neovim Plugin Management
```bash
# Update Neovim plugins (Lazy.nvim package manager)
nvim --headless "+Lazy! sync" +qa

# Install LSP servers via Mason
nvim --headless "+MasonInstall basedpyright lua_ls" +qa

# Install Treesitter parsers
nvim --headless "+lua require('nvim-treesitter').install({'python','lua','markdown','markdown_inline','javascript','typescript','json','html','css','yaml','bash'}):wait(120000)" +qa
```

### Testing Changes
```bash
# Reload ZSH configuration
source ~/.zshrc

# Test Neovim configuration without affecting current session
nvim --noplugin -u /home/infra/dotfiles/nvim/init.lua
```

### Git Operations
The Git configuration includes extensive aliases (see `git/.gitconfig`):
```bash
git lg        # Graphical log view
git whoami    # Show current identity
git pr        # Create pull request via GitHub CLI
git browse    # Open repo in browser
```

## Architecture and Structure

### ZSH Configuration

**Modular Design**: ZSH config is split into separate concern files that are sourced from `~/.zshrc`:
- `zsh/aliases.zsh`: CLI tool replacements (bat→cat, eza→ls, etc.)
- `zsh/key-bindings.zsh`: Custom keyboard shortcuts
- `zsh/integrations.zsh`: Shell integrations for tools (NVM, FZF, direnv, micromamba)

The install script **appends** source statements to existing `~/.zshrc` rather than replacing it, preserving user customizations.

### Neovim Configuration

**Plugin Manager**: Uses Lazy.nvim with auto-bootstrapping (nvim/lua/config/lazy.lua:1-16)

**Structure**:
- `nvim/init.lua`: Entry point that loads remap, options, and lazy
- `nvim/lua/config/remap.lua`: Custom keybindings (Space as leader)
- `nvim/lua/config/options.lua`: Editor settings
- `nvim/lua/config/plugins/*.lua`: Individual plugin configurations
- `nvim/lua/config/plugins/lsp/*.lua`: LSP-specific configurations

**LSP Architecture** (lspconfig.lua:122-157):
- Auto-discovers LSP servers from runtime files
- Applies capabilities from cmp-nvim-lsp to all servers
- Supports per-server custom configurations via `server_configs` table
- Has a `disabled_servers` list for servers that shouldn't auto-load

**Key LSP Keybindings** (with Space leader):
- `gd`: Go to definition
- `gR`: Show references
- `<leader>ca`: Code actions
- `<leader>rn`: Rename symbol
- `gK`: Show hover documentation

### Git Configuration

**Authentication**: Uses GitHub CLI (`gh auth git-credential`) for credential management rather than storing tokens

**Delta Integration**: Enhanced diff viewing with side-by-side layout and line numbers

**Multi-account Support**: Designed to support multiple GitHub identities (see comments in .gitconfig)

### Modern CLI Tools

The configuration **aliases traditional commands to modern replacements**:
- All aliases are in `zsh/aliases.zsh`
- Commands like `cat`, `ls`, `find`, `cd` are aliased system-wide
- This means scripts using bare `ls` will actually call `eza`

**Important**: When debugging issues with "standard" command behavior, check if it's actually an alias to a modern tool.

## Installed LSP Servers and Tools

The following are auto-installed via Mason (nvim/lua/config/plugins/lsp/mason.lua):

**LSP Servers**:
- `basedpyright`: Python
- `lua_ls`: Lua (with vim global configured)
- `ts_ls`: TypeScript/JavaScript
- `html`, `cssls`, `tailwindcss`: Web
- `svelte`, `graphql`, `emmet_ls`, `prismals`: Framework-specific

**Formatters/Linters**:
- prettier, stylua, isort, black, pylint, eslint_d

## Environment Management

**Micromamba** (aliased as `mm`): Lightweight conda replacement installed in `~/micromamba`
- Used for Python environment management
- Configured to use conda-forge by default
- Shell initialization handled by `zsh/integrations.zsh` (not by micromamba's built-in shell init)

**NVM**: Manages Node.js versions, installed in `~/.nvm`
- Shell initialization also handled by `zsh/integrations.zsh`

**Default Directory**: The ZSH config sets `~/forge` as the default directory when opening new shells

## Important Behaviors

### Neovim
- Space is the leader key
- `qq` is disabled to prevent accidental macro recording (remap.lua:37-45)
- Buffer navigation uses Tab/Shift+Tab
- Tab navigation uses `<leader>1`, `<leader>2`, `<leader>3`
- Ctrl+A selects all and copies to system clipboard

### Installation Script Behaviors
- Creates timestamped backups before overwriting configs
- Skips reinstalling if tools already exist (Oh-My-ZSH, NVM, Micromamba)
- Docker installation adds user to docker group (requires re-login to take effect)
- ZSH is set as default shell but requires session restart

### Uninstallation
`./scripts/uninstall.sh` removes symlinks, restores backups, and removes installed components (Micromamba, Oh-My-ZSH, etc.)
