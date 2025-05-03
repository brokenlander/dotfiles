#!/bin/bash

# Terminal Configuration Installation Script
# ----------------------------------------

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Print paths for debugging
echo "Script directory: $SCRIPT_DIR"
echo "Dotfiles directory: $DOTFILES"

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

# Backup the existing .zshrc
backup_file "$HOME/.zshrc"

# Add the source lines to .zshrc if they don't exist
if ! grep -q "source \$HOME/.dotfiles/zsh/aliases.zsh" "$HOME/.zshrc" 2>/dev/null; then
    echo "" >> "$HOME/.zshrc"
    echo "# Added by dotfiles installer" >> "$HOME/.zshrc"
    echo "source \$HOME/.dotfiles/zsh/aliases.zsh" >> "$HOME/.zshrc"
    echo "source \$HOME/.dotfiles/zsh/key-bindings.zsh" >> "$HOME/.zshrc"
    echo -e "${GREEN}Added${NC} source lines to ~/.zshrc"
else
    echo -e "${YELLOW}Source lines already exist${NC} in ~/.zshrc"
fi

# -------- Git Configuration (Replace) --------
echo "Setting up Git configuration..."

# Check if Git files exist
if [ -f "$DOTFILES/git/.gitconfig" ]; then
    echo "Found .gitconfig at $DOTFILES/git/.gitconfig"
    # Direct symlink creation - avoid using function for critical path
    create_symlink "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
    echo -e "${GREEN}Linked${NC} $DOTFILES/git/.gitconfig to $HOME/.gitconfig"
else
    echo -e "${RED}Error:${NC} $DOTFILES/git/.gitconfig not found!"
fi

if [ -f "$DOTFILES/git/.gitignore_global" ]; then
    echo "Found .gitignore_global at $DOTFILES/git/.gitignore_global"
    create_symlink "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"
    echo -e "${GREEN}Linked${NC} $DOTFILES/git/.gitignore_global to $HOME/.gitignore_global"
else
    echo -e "${RED}Error:${NC} $DOTFILES/git/.gitignore_global not found!"
fi

# -------- Oh-My-ZSH Setup --------
# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My ZSH..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Update Oh-My-ZSH configuration
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Install plugins if not present
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]; then
    echo "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
fi

# Update plugins in .zshrc
if grep -q "^plugins=" "$HOME/.zshrc"; then
    echo "Updating Oh-My-ZSH plugins..."
    # Create a backup of .zshrc before we modify it
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
    # Use sed to replace the plugins line
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting kubectl docker python npm)/' "$HOME/.zshrc"
fi

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. We recommend installing it for better GitHub integration."
    echo "You can install it with: mamba install gh --channel conda-forge"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo "Restart your terminal or run 'source ~/.zshrc' to apply changes."

# -------- Neovim Configuration --------
echo "Setting up Neovim configuration..."

if [ -d "$DOTFILES/nvim" ]; then
    echo "Found Neovim configuration at $DOTFILES/nvim"
    
    # Create symlink for the entire nvim directory
    create_symlink "$DOTFILES/nvim" "$HOME/.config/nvim"
    
    echo -e "${GREEN}Linked${NC} Neovim configuration from $DOTFILES/nvim to $HOME/.config/nvim"
else
    echo -e "${RED}Error:${NC} $DOTFILES/nvim directory not found!"
fi
