# Terminal Configuration

A comprehensive collection of terminal configuration files and settings for a productive development environment.

## What's Included

- **ZSH Configuration**: Custom settings, aliases, key bindings, and plugins
- **Git Configuration**: Enhanced settings, aliases, and multi-account support
- **Modern CLI Tools**: Setup for replacements like bat, eza, fd, ripgrep, etc.

## Installation

The installation is a two-step process:

### 1. Install Dependencies

First, install all required software and tools:

```bash
# Make the script executable
chmod +x scripts/install-dependencies.sh

# Run the dependencies installer
./scripts/install-dependencies.sh
```

This script installs:
- ZSH shell
- Modern CLI replacements (bat, exa, fd-find, ripgrep, etc.)
- Neovim
- Git (latest version)
- GitHub CLI
- Oh-My-ZSH and plugins

### 2. Install Configuration

After the dependencies are installed, set up your configuration files:

```bash
# Make the script executable
chmod +x scripts/install.sh

# Run the installation script
./scripts/install.sh
```

The installation script:
- Preserves your existing ZSH configuration while adding our custom settings
- Sets up Git configuration with useful aliases and settings
- Configures plugins for Oh-My-ZSH

## Modern CLI Tools

This configuration uses several modern replacements for traditional command line tools:

| Traditional | Modern Replacement | Description |
|-------------|-------------------|-------------|
| `cat` | `bat` | Syntax highlighting and Git integration |
| `ls` | `eza` | More features and better defaults |
| `find` | `fd` | Simpler syntax, respects .gitignore |
| `grep` | `ripgrep` | Faster, respects .gitignore |
| `du` | `dust` | More intuitive disk usage analyzer |
| `top` | `bottom`/`btop` | More interactive process viewer |
| `cd` | `zoxide` | Smarter directory navigation |
| `diff` | `delta` | Better diff with syntax highlighting |
| `man` | `tldr` | Simplified command examples |

## Components

### ZSH

- Modular configuration with:
  - `aliases.zsh`: Custom command aliases for modern CLI tools
  - `key-binding.zsh`: Keyboard shortcuts and custom key bindings

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

## Custom Key Bindings

- Italian keyboard tilde (`~`) access: `Alt+\`
- Home key: Go to beginning of line
- End key: Go to end of line
- Delete key: Delete character under cursor

## Environment Management

This configuration does not include environment manager setup scripts (like Conda/Mamba or NVM). These tools should be installed separately using their official installers, which will automatically add the necessary initialization code to your shell configuration.

Benefits of this approach:
- More portable across different machines
- Avoids hardcoding system-specific paths
- Allows proper installers to handle their own setup and updates
- Prevents conflicts when environment tools are updated

## Customization

Feel free to modify any of these files to suit your preferences. The modular approach makes it easy to:
- Add new aliases or key bindings
- Update Git configuration
- Add new tools to your setup

## Uninstallation

If you need to remove this configuration:

```bash
# Run the uninstall script
./scripts/uninstall.sh
```

This will:
- Remove the custom configuration lines from your .zshrc
- Restore your original Git configuration from backup
- Clean up the ~/.dotfiles directory
