#!/bin/bash
# Terminal Configuration Uninstallation Script
# ----------------------------------------

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Find the most recent backup
BACKUP_DIR=$(find "$HOME/.dotfiles_backup" -type d -name "20*" | sort -r | head -n 1)

echo "Uninstalling terminal configuration..."

# Function to restore from backup
restore_file() {
    local file=$1
    local backup="$BACKUP_DIR/$(basename "$file")"
    
    # Remove symlink
    if [ -L "$file" ]; then
        rm "$file"
        echo -e "${YELLOW}Removed symlink${NC} $file"
    fi
    
    # Restore from backup if available
    if [ -e "$backup" ]; then
        cp "$backup" "$file"
        echo -e "${GREEN}Restored${NC} $file from backup"
    fi
}

# Restore Git configuration
restore_file "$HOME/.gitconfig"
restore_file "$HOME/.gitignore_global"

# Remove Neovim configuration symlink
if [ -L "$HOME/.config/nvim" ]; then
    rm "$HOME/.config/nvim"
    echo -e "${YELLOW}Removed Neovim symlink${NC} $HOME/.config/nvim"
    
    # Restore from backup if available
    if [ -d "$BACKUP_DIR/nvim" ]; then
        mkdir -p "$HOME/.config"
        cp -r "$BACKUP_DIR/nvim" "$HOME/.config/"
        echo -e "${GREEN}Restored${NC} Neovim configuration from backup"
    fi
fi

# Clean up added source lines and configurations from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "Cleaning up .zshrc..."
    
    # Create a temporary file
    TEMP_FILE=$(mktemp)
    
    # Filter out lines added by various installers
    sed '/# Added by dotfiles installer/d; 
         /source \$HOME\/.dotfiles\/zsh\/aliases.zsh/d; 
         /source \$HOME\/.dotfiles\/zsh\/key-bindings.zsh/d; 
         /source \$ZSH\/oh-my-zsh.sh/d;
         /# >>> mamba initialize >>>/,/# <<< mamba initialize <<</d' "$HOME/.zshrc" > "$TEMP_FILE"
    
    # Replace original file
    cp "$TEMP_FILE" "$HOME/.zshrc"
    rm "$TEMP_FILE"
    
    echo -e "${GREEN}Removed${NC} dotfiles-specific lines and configurations from .zshrc"
fi

# Remove ZSH configuration symlinks
if [ -L "$HOME/.dotfiles/zsh/aliases.zsh" ]; then
    rm "$HOME/.dotfiles/zsh/aliases.zsh"
    echo -e "${YELLOW}Removed symlink${NC} $HOME/.dotfiles/zsh/aliases.zsh"
fi

if [ -L "$HOME/.dotfiles/zsh/key-bindings.zsh" ]; then
    rm "$HOME/.dotfiles/zsh/key-bindings.zsh"
    echo -e "${YELLOW}Removed symlink${NC} $HOME/.dotfiles/zsh/key-bindings.zsh"
fi

# Remove modular configuration directory
if [ -d "$HOME/.dotfiles" ]; then
    rm -rf "$HOME/.dotfiles"
    echo -e "${YELLOW}Removed${NC} $HOME/.dotfiles directory"
fi

# Restore .zshrc from backup if it exists
if [ -f "$BACKUP_DIR/.zshrc" ]; then
    cp "$BACKUP_DIR/.zshrc" "$HOME/.zshrc"
    echo -e "${GREEN}Restored${NC} original .zshrc from backup"
fi

# Remove micromamba from /opt
if [ -d "/opt/micromamba" ]; then
    echo "Removing micromamba installation..."
    sudo rm -rf /opt/micromamba
    echo -e "${YELLOW}Removed${NC} micromamba installation from /opt/micromamba"
fi

# Remove Oh-My-Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    echo -e "${YELLOW}Removed${NC} Oh-My-Zsh from $HOME/.oh-my-zsh"
fi

echo -e "\n${GREEN}Uninstallation complete!${NC}"
echo "Your original configuration has been restored where possible."
echo "You may need to restart your terminal for changes to take effect."
