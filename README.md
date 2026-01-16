# Terminal Development Environment

A comprehensive, modern terminal development environment with carefully curated tools, configurations, and workflows. This setup transforms your terminal into a powerful development workspace with vim-style navigation, fuzzy finding, git integration, and intelligent code editing.

## Table of Contents

- [Quick Start](#quick-start)
- [What's Included](#whats-included)
- [Installation](#installation)
- [Tools and Usage](#tools-and-usage)
  - [Modern CLI Tools](#modern-cli-tools)
  - [FZF - Fuzzy Finder](#fzf---fuzzy-finder)
  - [Lazygit](#lazygit)
  - [Lazydocker](#lazydocker)
  - [Direnv](#direnv)
  - [Zoxide](#zoxide)
  - [Git with Delta](#git-with-delta)
  - [Micromamba](#micromamba)
  - [Docker](#docker)
- [Neovim Configuration](#neovim-configuration)
  - [Keybindings Reference](#neovim-keybindings-reference)
  - [LSP Features](#lsp-features)
  - [Plugin Shortcuts](#plugin-shortcuts)
- [Tmux Configuration](#tmux-configuration)
  - [Tmux Keybindings Reference](#tmux-keybindings-reference)
  - [Session Management](#session-management)
- [Claude Code Integration](#claude-code-integration)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/brokenlander/dotfiles.git
cd dotfiles

# Install dependencies (requires sudo)
./scripts/install-dependencies.sh

# Start a new ZSH shell (important!)
zsh

# Install configurations
./scripts/install.sh

# Restart your shell
exec zsh
```

After installation, you'll have a modern terminal with:
- 🔍 **FZF** fuzzy finding with Ctrl+R, Ctrl+T, Alt+C
- 🎨 **Lazygit** TUI for visual git operations (`lg` command)
- 🐳 **Lazydocker** TUI for Docker management (`lazydocker` command)
- 📁 **Direnv** for project-specific environment variables
- 🚀 **Modern CLI tools** replacing traditional commands
- ✨ **Neovim** with LSP, fuzzy finding, and 30+ plugins
- 🖥️ **Tmux** with vim-style navigation and session persistence

---

## What's Included

### Core Components
- **ZSH** with Oh-My-ZSH framework and custom plugins
- **Neovim** - Modern Vim with LSP, Treesitter, and 30+ plugins
- **Tmux** - Terminal multiplexer with vim-style navigation
- **Git** - Enhanced with Delta pager and GitHub CLI integration
- **Claude Code** - AI assistant CLI for terminal workflows

### Development Tools
- **LSP Servers**: Python (basedpyright), TypeScript, Lua, HTML, CSS, and more
- **Formatters**: Prettier, Stylua, Black, isort
- **Linters**: ESLint, Pylint
- **Micromamba**: Lightweight conda-compatible package manager
- **NVM**: Node Version Manager with latest LTS
- **Docker & Docker Compose**: Containerization platform

### Modern CLI Tools
All traditional Unix tools are replaced with modern, faster alternatives:
- `bat` (cat), `eza` (ls), `fd` (find), `ripgrep` (grep)
- `zoxide` (cd), `delta` (diff), `dust` (du), `bottom` (top)
- `tldr` (man), `duf` (df)

---

## Installation

### Prerequisites
- Ubuntu/Debian-based Linux distribution
- Sudo access
- Internet connection

### Step 1: Install Dependencies

The dependency installer performs a complete system setup:

```bash
./scripts/install-dependencies.sh
```

This installs:
- **Shell**: ZSH, Oh-My-ZSH, plugins (autosuggestions, syntax highlighting)
- **Tools**: FZF, Git, GitHub CLI, Direnv, Lazygit, Lazydocker
- **Modern CLI**: bat, eza, fd, ripgrep, zoxide, delta, tldr, dust, bottom, duf
- **Editors**: Neovim (unstable/latest), Claude Code CLI
- **Dev Tools**: Python (via pipx), Node.js (via NVM), Micromamba
- **Containers**: Docker, Docker Compose
- **Tmux**: Terminal multiplexer with TPM (plugin manager)

**⚠️ Important**: After this step, start a new ZSH shell before continuing:
```bash
zsh
```

### Step 2: Install Configurations

```bash
./scripts/install.sh
```

This script:
- Creates symlinks to configuration files (changes persist across updates)
- Backs up existing configs to `~/.dotfiles_backup/`
- Sources custom ZSH configurations
- Installs Neovim plugins via Lazy.nvim
- Installs LSP servers via Mason
- Sets up Tmux plugins via TPM

### Step 3: Finalize Setup

```bash
# Restart shell to load all integrations
exec zsh

# In tmux, install plugins (optional, for tmux users)
tmux
# Press: Ctrl+b then Shift+I (capital I)
```

---

## Tools and Usage

### Modern CLI Tools

Traditional Unix commands are aliased to modern alternatives:

| Old Command | New Tool | Alias | Description |
|-------------|----------|-------|-------------|
| `cat` | bat | `cat`, `bat` | Syntax highlighting, Git integration, line numbers |
| `ls` | eza | `ls`, `ll`, `la`, `lt` | Icons, Git status, tree view |
| `find` | fd | `find`, `fd` | Simpler syntax, respects .gitignore, faster |
| `grep` | ripgrep | `grep` | Respects .gitignore, blazing fast, colored output |
| `cd` | zoxide | `cd`, `z` | Learns your habits, jump to frequent directories |
| `diff` | delta | `diff` | Syntax highlighting, side-by-side view |
| `du` | dust | `du` | Intuitive tree view of disk usage |
| `top` | bottom | `top` | Interactive process viewer with graphs |
| `man` | tldr | `man` | Simplified examples instead of full manuals |
| `df` | duf | `df` | Pretty disk usage visualization |

**Examples:**

```bash
# File listing with icons and git status
ll

# Tree view of current directory
lt

# Find files by name (respects .gitignore)
find "*.js"

# Search for text in files
grep "function"

# Smart cd - jump to frequently used directory
z dotfiles  # Jumps to ~/path/to/dotfiles

# View file with syntax highlighting
cat config.json

# Disk usage as visual tree
dust

# Interactive process monitor
btm
```

---

### FZF - Fuzzy Finder

**FZF** provides interactive fuzzy finding for files, directories, and command history.

**Keybindings:**

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl+R` | History search | Fuzzy search through command history |
| `Ctrl+T` | File search | Find files in current directory recursively |
| `Alt+C` | Directory jump | Find and cd into directories |

**Usage Examples:**

```bash
# Press Ctrl+R, type partial command
# Example: Ctrl+R, type "docker" to find docker commands

# Press Ctrl+T to find files
# Opens interactive selector with preview

# Press Alt+C to navigate directories
# Jump to any subdirectory quickly
```

**Within FZF interface:**
- `Ctrl+J/K` or `↑/↓` - Navigate results
- `Enter` - Select
- `Ctrl+C` or `Esc` - Cancel
- Start typing to filter results

**Configuration:** Custom FZF options use `fd` for searches and exclude `.git` directories automatically.

---

### Lazygit

**Lazygit** is a terminal UI for git commands with vim-style keybindings.

**Launch:**
```bash
lg              # Short alias
lazygit         # Full command
```

**Key Features:**
- Visual staging/unstaging
- Interactive rebasing
- Stash management
- Branch operations
- Commit amending
- Diff viewing
- Cherry-picking

**Navigation (within lazygit):**
- `h/j/k/l` - Vim-style navigation
- `1/2/3/4/5` - Switch panels (Status/Files/Branches/Commits/Stash)
- `Space` - Stage/unstage files
- `c` - Commit
- `P` - Push
- `p` - Pull
- `n` - New branch
- `d` - Delete/drop
- `e` - Edit file
- `Enter` - View details
- `?` - Show keybindings help
- `q` - Quit

**Why use it:** Much faster than typing git commands, visual feedback makes complex operations safer.

---

### Lazydocker

**Lazydocker** is a terminal UI for Docker commands with keyboard-focused navigation.

**Launch:**
```bash
lazydocker      # Full command
```

**Key Features:**
- View and manage containers (start/stop/restart/remove)
- View logs in real-time
- Monitor container stats (CPU, memory, network)
- View and manage images
- Execute commands in running containers
- Prune unused resources
- View Docker Compose services

**Navigation (within lazydocker):**
- `h/j/k/l` - Vim-style navigation
- `1/2/3/4/5` - Switch panels (Containers/Images/Volumes/Networks/Services)
- `d` - Remove container/image
- `s` - Stop container
- `r` - Restart container
- `a` - Attach to container
- `e` - Execute shell in container
- `l` - View logs
- `m` - View stats
- `Enter` - View details
- `?` - Show keybindings help
- `q` - Quit

**Why use it:** Visual interface makes Docker management much easier than remembering complex CLI commands, real-time stats and logs in one view.

---

### Direnv

**Direnv** automatically loads and unloads environment variables based on directory.

**Setup for a project:**

```bash
# Navigate to project
cd ~/projects/myapp

# Create .envrc file
echo 'export DATABASE_URL="postgres://localhost/mydb"' > .envrc
echo 'export API_KEY="your-key-here"' >> .envrc

# Authorize the file (required once per directory)
direnv allow

# Variables are now loaded
echo $DATABASE_URL  # Shows the value

# When you leave the directory, variables unload automatically
cd ~
echo $DATABASE_URL  # Empty
```

**Common use cases:**
- Project-specific API keys
- Database connection strings
- PATH modifications
- Activating virtual environments
- Loading AWS/GCP credentials per project

**Integration with Micromamba:**
```bash
# .envrc in project root
layout python python3.11
```

**Security:** Files must be explicitly allowed with `direnv allow` before loading.

---

### Zoxide

**Zoxide** is a smarter cd command that learns your habits.

**Usage:**

```bash
# Traditional cd still works
cd ~/projects/dotfiles

# After visiting a directory once, jump to it from anywhere
z dotfiles       # Jumps to ~/projects/dotfiles
z dot            # Partial matches work too

# Interactive selection when multiple matches
z proj           # Shows menu if multiple matches

# View database of directories
zoxide query -l
```

**How it learns:** Tracks directory frequency and recency (frecency algorithm).

**Alias:** `cd` is aliased to `z`, so just use `cd` naturally.

---

### Git with Delta

Git is enhanced with **Delta**, a syntax-highlighting pager, and numerous aliases.

**Git Aliases (from .gitconfig):**

| Alias | Command | Description |
|-------|---------|-------------|
| `git st` | status | Show working tree status |
| `git ci` | commit | Create a commit |
| `git co` | checkout | Switch branches or restore files |
| `git br` | branch | List/create/delete branches |
| `git lg` | log --graph | Pretty graphical log |
| `git ll` | log with stats | Log showing file changes |
| `git unstage` | reset HEAD | Remove from staging |
| `git last` | log -1 HEAD | Show last commit |
| `git amend` | commit --amend | Modify last commit |
| `git findmsg <term>` | grep commits | Search commit messages |
| `git findcode <code>` | pickaxe search | Find commits with code changes |
| `git whoami` | show identity | Display current git user |
| `git browse` | gh repo view | Open repo in browser |
| `git pr` | gh pr create | Create pull request |
| `git prs` | gh pr list | List pull requests |

**Delta Features:**
- Syntax highlighting in diffs
- Side-by-side view (default)
- Line numbers
- Git hunk navigation with `n` and `N`

**Example workflow:**
```bash
git st                    # Check status
git add .                 # Stage changes
git ci -m "feat: ..."     # Commit
git lg                    # View history graph
git push                  # Push to remote
git pr                    # Create PR via GitHub CLI
```

---

### Micromamba

**Micromamba** is a fast, lightweight conda alternative for environment management.

**Alias:** `mm`

**Common Commands:**

```bash
# Create environment
mm create -n myenv python=3.11 pandas numpy

# Activate environment
mm activate myenv

# Deactivate
mm deactivate

# List environments
mm env list

# Install packages
mm install -n myenv requests

# Remove environment
mm env remove -n myenv

# Export environment
mm env export -n myenv > environment.yml

# Create from file
mm env create -f environment.yml
```

**Installation location:** `~/micromamba/`

**Why use it:** 10x faster than conda, smaller footprint, drop-in replacement.

---

### Docker

Docker and Docker Compose are installed and configured for the current user.

**Verify installation:**
```bash
docker --version
docker compose version
```

**Common commands:**
```bash
# Run container
docker run -it ubuntu bash

# List containers
docker ps

# Stop container
docker stop <container_id>

# View logs
docker logs <container_id>

# Build from Dockerfile
docker build -t myapp .

# Docker Compose
docker compose up
docker compose down
```

**Note:** User is added to `docker` group during installation. If you get permission errors, log out and back in.

---

## Neovim Configuration

Neovim is configured with 30+ plugins, LSP support, and custom keybindings.

**Leader Key:** `Space`

### Neovim Keybindings Reference

#### General Navigation

| Keybinding | Mode | Action |
|------------|------|--------|
| `Space` | Normal | Leader key (prefix for most shortcuts) |
| `Tab` | Normal | Next buffer |
| `Shift+Tab` | Normal | Previous buffer |
| `Ctrl+A` | Normal/Visual | Select all and copy to clipboard |

#### Buffer Management

| Keybinding | Action |
|------------|--------|
| `<leader>rd` | Open file explorer (Ex) |
| `<leader>rt` | Delete buffer but keep window |
| `<leader>re` | Force delete buffer |
| `<leader>q` | Quit all windows |

#### Tab Management

| Keybinding | Action |
|------------|--------|
| `<leader>1` | Go to tab 1 |
| `<leader>2` | Go to tab 2 |
| `<leader>3` | Go to tab 3 |
| `<leader>tn` | New tab |
| `<leader>tc` | Close tab |
| `<leader>to` | Close all other tabs |
| `<leader>tb` | Open buffer in new tab |

#### File Explorer (nvim-tree)

| Keybinding | Action |
|------------|--------|
| `<leader>ee` | Toggle file explorer |
| `<leader>er` | Focus file explorer |
| `<leader>ef` | Find current file in explorer |

**Within nvim-tree:**
| Keybinding | Action |
|------------|--------|
| `l` | Open file/directory |
| `h` | Close directory |
| `H` | Collapse all |
| `a` | Create new file |
| `d` | Delete file |
| `r` | Rename file |
| `x` | Cut file |
| `c` | Copy file |
| `p` | Paste file |
| `?` | Show help |

#### Fuzzy Finding (Telescope)

| Keybinding | Action |
|------------|--------|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>\\` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fg` | Git files |
| `<leader>fc` | Find string under cursor |
| `<leader>ft` | Find TODO comments |

**Within Telescope:**
| Keybinding | Action |
|------------|--------|
| `Ctrl+J/K` | Navigate results |
| `Ctrl+Q` | Send to quickfix list |
| `Ctrl+H` | Show which-key help |
| `Enter` | Select |
| `Esc` | Close |

#### LSP (Language Server Protocol)

| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gR` | Show references |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `gK` | Show hover documentation |
| `gS` | Restart LSP |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>d` | Show line diagnostics |
| `<leader>D` | Show buffer diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

#### Editing Utilities

| Keybinding | Action |
|------------|--------|
| `<leader>ut` | Toggle undo tree |
| `<leader>vd` | Delete all file contents (void delete) |
| `<leader>vr` | Replace file with clipboard |

#### Copy/Paste

| Keybinding | Mode | Action |
|------------|------|--------|
| `Ctrl+A` | Normal | Select all and copy |
| `Right Click` | Insert | Paste from clipboard |
| `Right Click` | Normal | Paste from clipboard |

**Note:** Neovim is configured to use system clipboard by default. Yank operations (`y`) automatically copy to clipboard.

#### Important Behavior Changes

- **Macro recording disabled:** `qq` does nothing (prevents accidental recording)
- **Auto-reload:** Buffers automatically reload when files change on disk
- **Mouse support:** Enabled in all modes

---

### LSP Features

Neovim is configured with LSP servers for intelligent code editing.

**Installed LSP Servers:**
- **Python:** basedpyright
- **JavaScript/TypeScript:** ts_ls
- **HTML/CSS:** html, cssls, tailwindcss
- **Lua:** lua_ls (vim-aware)
- **Web Frameworks:** svelte, emmet_ls
- **GraphQL:** graphql
- **Databases:** prismals

**Features:**
- ✅ Auto-completion
- ✅ Go to definition/references
- ✅ Hover documentation
- ✅ Signature help
- ✅ Diagnostics (errors/warnings)
- ✅ Code actions (quick fixes)
- ✅ Symbol renaming
- ✅ Format on save

**Managing LSP:**
```vim
:Mason              " Open Mason UI to install/update servers
:LspInfo            " Show attached LSP servers
:LspRestart         " Restart LSP (also gS)
```

**Formatters & Linters (via Mason):**
- Prettier, Stylua, Black, isort, Pylint, ESLint

---

### Plugin Shortcuts

**Auto-completion (nvim-cmp):**
- Triggered automatically while typing
- `Ctrl+Space` - Manual trigger
- `Enter` - Confirm selection
- `Ctrl+N/P` - Navigate suggestions
- `Ctrl+E` - Close completion menu

**Treesitter:**
- Provides advanced syntax highlighting
- No keybindings needed (automatic)
- Languages: Python, Lua, JavaScript, TypeScript, JSON, HTML, CSS, YAML, Bash, Markdown

**Gitsigns:**
- Shows git changes in sign column
- `[c` - Previous hunk
- `]c` - Next hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk

**Which-key:**
- Shows available keybindings automatically
- Triggered after pressing leader key and waiting
- Press `Space` and wait 300ms to see options

**Todo-comments:**
- Highlights TODO, FIXME, NOTE, HACK, WARNING in comments
- `<leader>ft` - Search all todos with Telescope

---

## Tmux Configuration

Tmux is configured with vim-style navigation, session persistence, and the **Tokyo Night** color theme.

**Prefix Key:** `Ctrl+B` (default)

**Theme:** Tokyo Night (night variant) with status widgets:
- Date and time (24H format, Day/Month/Year)
- Local git branch and status
- Hostname display
- Custom status bar length

### Tmux Keybindings Reference

#### Pane Splitting

| Keybinding | Action |
|------------|--------|
| `Prefix + \|` | Split vertically |
| `Prefix + -` | Split horizontally |

#### Pane Navigation (Vim-style)

**Without prefix (instant):**
| Keybinding | Action |
|------------|--------|
| `Alt+H` | Move to left pane |
| `Alt+J` | Move to bottom pane |
| `Alt+K` | Move to top pane |
| `Alt+L` | Move to right pane |

**With prefix:**
| Keybinding | Action |
|------------|--------|
| `Prefix + h` | Move to left pane |
| `Prefix + j` | Move to bottom pane |
| `Prefix + k` | Move to top pane |
| `Prefix + l` | Move to right pane |

#### Pane Resizing

| Keybinding | Action |
|------------|--------|
| `Prefix + H` | Resize left (repeatable) |
| `Prefix + J` | Resize down (repeatable) |
| `Prefix + K` | Resize up (repeatable) |
| `Prefix + L` | Resize right (repeatable) |

#### Window Navigation

| Keybinding | Action |
|------------|--------|
| `Prefix + n` | Next window |
| `Prefix + p` | Previous window |
| `Prefix + 0-9` | Go to window number |
| `Prefix + c` | Create new window |
| `Prefix + ,` | Rename window |
| `Prefix + &` | Kill window |

#### Copy Mode (Vim-style)

| Keybinding | Action |
|------------|--------|
| `Prefix + [` | Enter copy mode |
| `v` | Begin selection (in copy mode) |
| `y` | Copy selection and exit |
| `Ctrl+V` | Rectangle selection toggle |
| `q` | Exit copy mode |

**Within copy mode:**
- `h/j/k/l` - Navigate
- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

#### Session Management

| Keybinding | Action |
|------------|--------|
| `Prefix + d` | Detach from session |
| `Prefix + $` | Rename session |
| `Prefix + s` | List sessions |
| `Prefix + (` | Previous session |
| `Prefix + )` | Next session |

**Session persistence (via plugins):**
| Keybinding | Action |
|------------|--------|
| `Prefix + Ctrl+S` | Save session |
| `Prefix + Ctrl+R` | Restore session |

**Command line:**
```bash
# List sessions
tmux ls

# Attach to session
tmux attach -t session_name

# Create named session
tmux new -s project_name

# Kill session
tmux kill-session -t session_name
```

#### Other Keybindings

| Keybinding | Action |
|------------|--------|
| `Prefix + r` | Reload tmux config |
| `Prefix + ?` | Show all keybindings |
| `Prefix + :` | Enter command mode |
| `Prefix + z` | Zoom pane (fullscreen toggle) |
| `Prefix + x` | Kill pane |

### Session Management

**Tmux plugins:**
- **tmux-resurrect:** Manual save/restore
- **tmux-continuum:** Auto-save every 15 minutes, auto-restore on startup
- **tmux-yank:** Copy to system clipboard

**Automatic features:**
- Sessions auto-save every 15 minutes
- Last session auto-restores when starting tmux
- Pane contents preserved
- Neovim sessions restored

---

## Claude Code Integration

**Claude Code** runs alongside Neovim in a separate tmux pane for a powerful AI-assisted development workflow.

**Setup:**
1. Claude Code CLI is installed via `install-dependencies.sh`
2. Neovim is configured with auto-reload for external file changes
3. Run in tmux split panes side-by-side

**Usage:**

```bash
# Open tmux and split with 35/65 ratio (left smaller, right larger)
tmux
tmux split-window -h -l 65%

# Left pane (35%): Start Neovim
nvim

# Right pane (65%): Start Claude Code
claude

# Switch between panes with Alt+H (left) and Alt+L (right)
```

**Workflow:**
1. Edit code in Neovim, save changes (`:w`)
2. Ask Claude to make changes or add features
3. Claude writes files directly to disk
4. Neovim **auto-reloads** the changes and shows notification
5. Review changes, continue editing

**Benefits:**
- **Session persistence** - Claude sessions survive disconnects (critical for SSH)
- **Auto-reload** - Neovim detects external changes and reloads buffers automatically
- **Full visibility** - See both Claude's work and your code side-by-side
- **Multiple panes** - Add more panes for logs, tests, or terminal commands
- **No plugin overhead** - Simple, file-based collaboration

---

## Customization

All configurations use **symlinks**, so changes to files in this repo take effect immediately.

### Add Aliases

```bash
# Edit aliases file
nvim ~/dotfiles/zsh/aliases.zsh
source ~/.zshrc  # Reload
```

**ZSH Configuration Structure:**
- `zsh/aliases.zsh` - Command aliases and modern CLI tool replacements
- `zsh/key-bindings.zsh` - Custom keyboard shortcuts
- `zsh/integrations.zsh` - Shell integrations (NVM, FZF, Direnv, COLORTERM)

### Modify Neovim

```bash
# Add/remove plugins
nvim ~/dotfiles/nvim/lua/config/plugins/

# Modify keybindings
nvim ~/dotfiles/nvim/lua/config/remap.lua

# Apply changes
:source %          # In Neovim
:Lazy sync         # Update plugins
```

### Customize Tmux

```bash
nvim ~/dotfiles/tmux/.tmux.conf
# In tmux: Prefix + r (reload config)
```

### Git Configuration

```bash
nvim ~/dotfiles/git/.gitconfig
# Changes apply immediately (symlinked)
```

---

## Troubleshooting

### FZF keybindings not working

```bash
# Check if FZF files exist
ls /usr/share/doc/fzf/examples/

# Re-source integrations
source ~/.dotfiles/zsh/integrations.zsh
```

### Lazygit command not found

```bash
# Reinstall lazygit
./scripts/install-dependencies.sh

# Or manually
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit.tar.gz lazygit
```

### Neovim LSP not working

```vim
:checkhealth        " Run health check
:Mason              " Verify LSP servers installed
:LspInfo            " Check attached servers
```

### Tmux plugins not installing

```bash
# In tmux, press: Prefix + I (capital i)
# Or manually:
~/.tmux/plugins/tpm/bin/install_plugins
```

### Docker permission denied

```bash
# Verify user in docker group
groups

# If not, re-run install script or add manually:
sudo usermod -aG docker $USER

# Log out and back in for changes to take effect
```

### Neovim buffers not auto-reloading

```vim
" Check settings
:set autoread?
:set updatetime?

" Manually reload
:checktime
:e  " Or just :e to reload current buffer
```

### Colors not working properly in tmux/SSH

```bash
# Check COLORTERM variable
echo $COLORTERM  # Should show "truecolor"

# If not set, check integrations file
cat ~/.dotfiles/zsh/integrations.zsh | grep COLORTERM

# Test colors
~/dotfiles/scripts/test-colors.sh

# For SSH sessions, ensure COLORTERM is forwarded
# Add to ~/.ssh/config on local machine:
# Host *
#   SendEnv COLORTERM
```

**Note:** The `zsh/integrations.zsh` file sets `COLORTERM=truecolor` and is sourced automatically. Tmux is configured with aggressive terminal-overrides for RGB support.

---

## Uninstallation

To completely remove this configuration:

```bash
./scripts/uninstall.sh
```

This will:
- Remove all symlinks
- Restore original configs from backups
- Remove Oh-My-ZSH
- Remove Micromamba
- Clean up ~/.dotfiles directory

**Note:** Installed tools (Neovim, Git, Docker, etc.) are **not** uninstalled, only configurations.

---

## Credits and Resources

- [Lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git
- [Lazydocker](https://github.com/jesseduffield/lazydocker) - Terminal UI for Docker
- [Oh-My-ZSH](https://ohmyz.sh/) - ZSH framework
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based editor
- [Tmux](https://github.com/tmux/tmux) - Terminal multiplexer
- [Claude Code](https://claude.ai/code) - AI coding assistant
- [FZF](https://github.com/junegunn/fzf) - Fuzzy finder
- [Direnv](https://direnv.net/) - Environment switcher

---

## Contributing

Found a bug or have a suggestion? Open an issue on GitHub!

## License

MIT License - Feel free to use and modify for your own dotfiles.
