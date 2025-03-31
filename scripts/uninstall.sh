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

# Clean up added source lines from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "Cleaning up .zshrc..."
    
    # Create a temporary file
    TEMP_FILE=$(mktemp)
    
    # Filter out lines added by the installer
    grep -v "# Added by dotfiles installer" "$HOME/.zshrc" | \
    grep -v "source \$HOME/.dotfiles/zsh/aliases.zsh" | \
    grep -v "source \$HOME/.dotfiles/zsh/key-binding.zsh" > "$TEMP_FILE"
    
    # Replace original file
    cp "$TEMP_FILE" "$HOME/.zshrc"
    rm "$TEMP_FILE"
    
    echo -e "${GREEN}Removed${NC} dotfiles-specific lines from .zshrc"
fi

# Remove modular configuration directory
if [ -d "$HOME/.dotfiles" ]; then
    rm -rf "$HOME/.dotfiles"
    echo -e "${YELLOW}Removed${NC} $HOME/.dotfiles directory"
fi

echo -e "\n${GREEN}Uninstallation complete!${NC}"
echo "Your original configuration has been restored where possible."
echo "You may need to restart your terminal for changes to take effect."
