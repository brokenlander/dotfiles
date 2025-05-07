# Terminal Configuration

A comprehensive collection of terminal configuration files and settings for a productive development environment.

```bash
# Installation
git clone https://github.com/brokenlander/dotfiles.git
cd dotfiles
./scripts/install-dependencies.sh
# Start a new ZSH shell
zsh
./scripts/install.sh
# Optional: Remove backups if everything works properly
rm ~/.dotfiles_backup -dr
```

## What's Included

- **ZSH Configuration**: Custom settings, aliases, and plugins
- **Git Configuration**: Enhanced settings, aliases, and multi-account support
- **Neovim Configuration**: Custom setup for the modern text editor
- **Modern CLI Tools**: Setup for replacements like bat, eza, fd, ripgrep, dust, etc.
- **Micromamba Integration**: Lightweight conda-compatible package manager
- **Docker Configuration**: Docker and Docker Compose setup
- **Python Development Tools**: pylint, black, and isort via pipx
- **Node.js Environment**: NVM for Node.js version management

## Installation

The installation is a two-step process:

### 1. Install Dependencies

First, install all required software and tools:

```bash
# Run the dependencies installer
./scripts/install-dependencies.sh
```

This script installs:

- ZSH shell and sets it as the default shell
- System utilities and common packages (curl, fzf, python3, pipx, yarn, unzip, rclone, tmux, jq)
- Python development tools via pipx (pylint, black, isort)
- Modern CLI replacements (bat, eza, fd-find, ripgrep, zoxide, delta, tldr, dust, bottom, duf)
- Neovim (unstable/latest version)
- Git (latest version)
- Docker and Docker Compose
- GitHub CLI
- Oh-My-ZSH and plugins
- Micromamba in the user's home directory
- NVM with the latest LTS Node.js version

It also performs a full system update/upgrade

### 2. Install Configuration

After the dependencies are installed, set up your configuration files:

```bash
# Run the installation script
./scripts/install.sh
```

The installation script:

- Creates symlinks to configuration files in your dotfiles repository
- Preserves your existing ZSH configuration while adding our custom settings
- Sets up Git configuration with useful aliases and settings
- Configures Neovim with your custom setup
- Configures plugins for Oh-My-ZSH
- Updates Neovim plugins using Lazy and Mason package managers

## Modern CLI Tools

This configuration replaces traditional command line tools with modern alternatives for improved productivity:

| Traditional | Modern Replacement | Description                             |
| ----------- | ------------------ | --------------------------------------- |
| `cat`       | `bat`              | Syntax highlighting and Git integration |
| `ls`        | `eza`              | More features and better defaults       |
| `find`      | `fd`               | Simpler syntax, respects .gitignore     |
| `grep`      | `ripgrep`          | Faster, respects .gitignore             |
| `du`        | `dust`             | More intuitive disk usage analyzer      |
| `top`       | `bottom`/`btm`     | More interactive process viewer         |
| `cd`        | `zoxide`           | Smarter directory navigation            |
| `diff`      | `delta`            | Better diff with syntax highlighting    |
| `man`       | `tldr`             | Simplified command examples             |
| `df`        | `duf`              | Better disk usage visualization         |

## Components

### ZSH

- Modular configuration with:
  - `aliases.zsh`: Custom command aliases for modern CLI tools
  - `key-bindings.zsh`: Keyboard shortcuts and custom key bindings

### Oh-My-ZSH

This configuration uses Oh-My-ZSH with the following plugins:

- git
- zsh-autosuggestions
- zsh-syntax-highlighting
- fast-syntax-highlighting
- kubectl
- docker
- python
- npm

### Git

- Enhanced configuration with useful aliases
- Support for multiple GitHub accounts
- Integration with GitHub CLI
- Better diff viewing with Delta

### Neovim

- Custom configuration for the modern Vim-based text editor
- Symlinked directly from your dotfiles repository to `~/.config/nvim`
- Includes a curated set of plugins:
  - **Telescope**: Fuzzy finder for files, buffers, and more
  - **Mason**: LSP, DAP, and linter manager
  - **Treesitter**: Advanced syntax highlighting and code navigation
  - **LSP**: Language Server Protocol support for code intelligence
  - **Alpha**: Dashboard startup screen
  - **Avante**: Editor theme and styling
  - **Which-key**: Keybinding helper
  - **Monokai-Pro**: Modern color scheme
  - **Nvim-tree**: File explorer
  - **Auto-session**: Automatic session management

### Micromamba

- Lightweight conda-compatible package manager
- Installed in the user's home directory (`~/micromamba`)
- Configured to use conda-forge by default
- Alias: `mm` for quick access

### Docker

- Docker and Docker Compose installation
- Configured for current user access

### Node.js

- NVM (Node Version Manager) for managing Node.js versions
- Latest LTS version of Node.js installed by default

### Python Development

- pipx for isolated Python application installation
- Development tools:
  - pylint for linting
  - black for code formatting
  - isort for import sorting

## Custom Aliases

The configuration includes aliases for all modern CLI tools:

```bash
# Modern CLI Tool Aliases
alias bat='batcat'
alias cat='batcat'
alias ls='eza'
alias ll='eza -la'
alias la='eza -a'
alias lt='eza -T'  # Tree view
alias find='fd'
alias fd='fdfind'
alias grep='rg'
alias du='dust'
alias top='btm'
alias cd='z'
alias diff='delta'
alias man='tldr'
alias df='duf'
alias mm='micromamba'  # Micromamba shortcut
alias vim='nvim'  # Use neovim by default
```



## Environment Management

This configuration includes Micromamba for lightweight package and environment management. It's installed in your home directory with the `mm` alias for quick access.

To create and activate environments:

```bash
# Create a new environment with Python 3.12
mm create -n py312 python=3.12 -c conda-forge

# Activate the environment
mm activate py312
```

## Customization

Feel free to modify any of these files to suit your preferences. The modular approach and use of symlinks makes it easy to:

- Add new aliases or key bindings
- Update Git configuration
- Customize your Neovim setup
- Add new tools to your environment

Changes made to files in your dotfiles repository will be immediately reflected in your active configuration due to the use of symlinks.

## Uninstallation

If you need to remove this configuration:

```bash
# Run the uninstall script
./scripts/uninstall.sh
```

This will:

- Remove all symlinks created during installation
- Remove the custom configuration lines from your .zshrc
- Remove Micromamba from your home directory
- Remove Oh-My-ZSH completely
- Restore your original configuration files from backup when available
- Clean up the ~/.dotfiles directory
