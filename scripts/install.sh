#!/bin/bash

# Terminal Configuration Installation Script
# ----------------------------------------

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Detect desktop environment
HAS_DISPLAY=false
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ] || [ -n "$XDG_CURRENT_DESKTOP" ]; then
    HAS_DISPLAY=true
fi

# Print paths for debugging
echo "Script directory: $SCRIPT_DIR"
echo "Dotfiles directory: $DOTFILES"
echo "Desktop detected: $HAS_DISPLAY"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to backup existing files
backup_file() {
    local file=$1
    if [ -e "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
        echo -e "${YELLOW}Backed up${NC} $file to $BACKUP_DIR/$(basename "$file")"
    fi
}

# Function to create symlinks
create_symlink() {
    local source=$1
    local target=$2

    echo "Creating symlink: $source -> $target"

    # Backup existing file
    if [ -e "$target" ]; then
        backup_file "$target"
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    # Create the symlink
    ln -sf "$source" "$target"
    echo -e "${GREEN}Linked${NC} $source to $target"
}

echo "Installing terminal configuration..."

# Create ~/.dotfiles directory
mkdir -p "$HOME/.dotfiles/zsh"

# -------- ZSH Configuration (Non-destructive) --------
echo "Setting up ZSH configuration..."

# Create symlinks for ZSH module files
create_symlink "$DOTFILES/zsh/aliases.zsh" "$HOME/.dotfiles/zsh/aliases.zsh"
create_symlink "$DOTFILES/zsh/key-bindings.zsh" "$HOME/.dotfiles/zsh/key-bindings.zsh"
create_symlink "$DOTFILES/zsh/integrations.zsh" "$HOME/.dotfiles/zsh/integrations.zsh"

# Backup the existing .zshrc
backup_file "$HOME/.zshrc"

# Add ZSH plugin sourcing and dotfiles to .zshrc if not already present
if ! grep -q "source \$HOME/.dotfiles/zsh/aliases.zsh" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOL'

# ZSH plugins (autosuggestions, syntax highlighting, completions)
ZSH_PLUGINS="$HOME/.zsh/plugins"
[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ] && source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
[ -d "$ZSH_PLUGINS/zsh-completions/src" ] && fpath=("$ZSH_PLUGINS/zsh-completions/src" $fpath)

# Initialize completions
autoload -Uz compinit && compinit

# Added by dotfiles installer
source $HOME/.dotfiles/zsh/aliases.zsh
source $HOME/.dotfiles/zsh/key-bindings.zsh
source $HOME/.dotfiles/zsh/integrations.zsh
EOL
    echo -e "${GREEN}Added${NC} plugin sourcing and dotfiles to ~/.zshrc"
else
    echo -e "${YELLOW}Source lines already exist${NC} in ~/.zshrc"
fi

# -------- Starship Configuration --------
echo "Setting up Starship configuration..."

if [ -f "$DOTFILES/starship/starship.toml" ]; then
    create_symlink "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
else
    echo -e "${RED}Error:${NC} starship.toml not found!"
fi

# -------- Git Configuration --------
echo "Setting up Git configuration..."

if [ -f "$DOTFILES/git/.gitconfig" ]; then
    create_symlink "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
else
    echo -e "${RED}Error:${NC} $DOTFILES/git/.gitconfig not found!"
fi

if [ -f "$DOTFILES/git/.gitignore_global" ]; then
    create_symlink "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"
else
    echo -e "${RED}Error:${NC} $DOTFILES/git/.gitignore_global not found!"
fi

# -------- Tmux Configuration --------
echo "Setting up Tmux configuration..."

if [ -f "$DOTFILES/tmux/.tmux.conf" ]; then
    create_symlink "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

    # Install tmux plugins via TPM
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing tmux plugins..."
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
        echo -e "${GREEN}Tmux plugins installed${NC}"
    else
        echo -e "${YELLOW}Warning:${NC} TPM not found. Run install-dependencies.sh first."
    fi
else
    echo -e "${RED}Error:${NC} $DOTFILES/tmux/.tmux.conf not found!"
fi

# -------- Neovim Configuration --------
echo "Setting up Neovim configuration..."

if [ -d "$DOTFILES/nvim" ]; then
    create_symlink "$DOTFILES/nvim" "$HOME/.config/nvim"
else
    echo -e "${RED}Error:${NC} $DOTFILES/nvim directory not found!"
fi

# -------- Desktop-only: Kitty & Kate --------
if [ "$HAS_DISPLAY" = true ]; then
    echo "Setting up desktop configurations..."

    # Kitty
    if [ -f "$DOTFILES/kitty/kitty.conf" ]; then
        create_symlink "$DOTFILES/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
    fi

    # Kate Tokyo Night theme
    if [ -f "$DOTFILES/kate/tokyo-night.theme" ]; then
        mkdir -p "$HOME/.local/share/org.kde.syntax-highlighting/themes"
        create_symlink "$DOTFILES/kate/tokyo-night.theme" "$HOME/.local/share/org.kde.syntax-highlighting/themes/tokyo-night.theme"
    fi
fi

# Fastfetch config (shared — useful on servers too)
if [ -f "$DOTFILES/fastfetch/config.jsonc" ]; then
    create_symlink "$DOTFILES/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
fi

if [ "$HAS_DISPLAY" != true ]; then
    echo "Skipping desktop configs (no display detected)"
fi

# -------- Install Neovim plugins --------
echo "Installing Neovim plugins..."
if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
    echo -e "${GREEN}Neovim plugins installed${NC}"
else
    echo -e "${RED}WARNING: Neovim plugin install failed. Run 'nvim' manually to complete setup.${NC}"
fi

echo "Installing LSP servers..."
if nvim --headless "+MasonInstall basedpyright lua_ls" +qa 2>/dev/null; then
    echo -e "${GREEN}LSP servers installed${NC}"
else
    echo -e "${RED}WARNING: LSP install failed. Open Neovim and run :MasonInstall manually.${NC}"
fi

echo "Installing Treesitter parsers..."
if nvim --headless "+lua require('nvim-treesitter').install({'python','lua','markdown','markdown_inline','javascript','typescript','json','html','css','yaml','bash'}):wait(120000)" +qa 2>/dev/null; then
    echo -e "${GREEN}Treesitter parsers installed${NC}"
else
    echo -e "${RED}WARNING: Treesitter install failed. Open Neovim to complete setup.${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo "Desktop configs installed: $HAS_DISPLAY"
echo "Restart your terminal or run 'source ~/.zshrc' to apply changes."
