# Terminal Configuration

A comprehensive collection of terminal configuration files and settings for a productive development environment.

```bash
# Installation
git clone https://github.com/brokenlander/dotfiles.git
dotfiles/scripts/install-dependencies.sh
zsh
../dotfiles/scripts/install.sh
rm ~/.dotfiles_backup -dr # Remove backups
```

## What's Included

- **ZSH Configuration**: Custom settings, aliases, key bindings, and plugins
- **Git Configuration**: Enhanced settings, aliases, and multi-account support
- **Neovim Configuration**: Custom setup for the modern text editor
- **Modern CLI Tools**: Setup for replacements like bat, eza, fd, ripgrep, etc.
- **Micromamba Integration**: Lightweight conda-compatible package manager

## Installation

The installation is a two-step process:

### 1. Install Dependencies

First, install all required software and tools:

```bash
# Run the dependencies installer
./scripts/install-dependencies.sh
```

This script installs:

- ZSH shell
- System utilities and common packages
- Modern CLI replacements (bat, exa, fd-find, ripgrep, etc.)
- Neovim
- Git (latest version)
- GitHub CLI
- Oh-My-ZSH and plugins
- Micromamba in `/opt/micromamba` with read/write access for all users
- Nvm

It also does a full update/upgrade

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

## Modern CLI Tools

This configuration uses several modern replacements for traditional command line tools:

| Traditional | Modern Replacement | Description                             |
| ----------- | ------------------ | --------------------------------------- |
| `cat`       | `bat`              | Syntax highlighting and Git integration |
| `ls`        | `eza`              | More features and better defaults       |
| `find`      | `fd`               | Simpler syntax, respects .gitignore     |
| `grep`      | `ripgrep`          | Faster, respects .gitignore             |
| `du`        | `dust`             | More intuitive disk usage analyzer      |
| `top`       | `bottom`/`btop`    | More interactive process viewer         |
| `cd`        | `zoxide`           | Smarter directory navigation            |
| `diff`      | `delta`            | Better diff with syntax highlighting    |
| `man`       | `tldr`             | Simplified command examples             |

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
- Installed in `/opt/micromamba` with permissions for all users
- Configured to use conda-forge by default

## Custom Key Bindings

- Italian keyboard tilde (`~`) access: `Alt+\`
- Home key: Go to beginning of line
- End key: Go to end of line
- Delete key: Delete character under cursor

## Environment Management

This configuration includes Micromamba for lightweight package and environment management. It's installed in `/opt/micromamba` with permissions set for all users to have read/write access.

To create and activate environments:

```bash
# Create a new environment with Python 3.12
micromamba create -n py312 python=3.12 -c conda-forge

# Activate the environment
micromamba activate py312
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
- Remove Micromamba from `/opt/micromamba`
- Remove Oh-My-ZSH completely
- Restore your original configuration files from backup when available
- Clean up the ~/.dotfiles directory
