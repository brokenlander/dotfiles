#!/bin/bash
# Terminal Configuration Uninstallation Script
# ----------------------------------------

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Find the most recent backup
BACKUP_DIR=$(find "$HOME/.dotfiles_backup" -type d -name "20*" 2>/dev/null | sort -r | head -n 1)

if [ -z "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}No backup directory found.${NC} Symlinks will be removed but original configs cannot be restored."
    echo "Continue? (y/N)"
    read -r response
    [ "$response" != "y" ] && echo "Aborted." && exit 0
fi

echo "Uninstalling terminal configuration..."
[ -n "$BACKUP_DIR" ] && echo "Using backup from: $BACKUP_DIR"

# Function to restore from backup
restore_file() {
    local file=$1

    # Remove symlink
    if [ -L "$file" ]; then
        rm "$file"
        echo -e "${YELLOW}Removed symlink${NC} $file"
    fi

    # Restore from backup if available
    if [ -n "$BACKUP_DIR" ]; then
        local backup="$BACKUP_DIR/$(basename "$file")"
        if [ -e "$backup" ]; then
            cp "$backup" "$file"
            echo -e "${GREEN}Restored${NC} $file from backup"
        fi
    fi
}

# Restore Git configuration
restore_file "$HOME/.gitconfig"
restore_file "$HOME/.gitignore_global"

# Remove Tmux configuration
restore_file "$HOME/.tmux.conf"

# Remove Starship configuration
if [ -L "$HOME/.config/starship.toml" ]; then
    rm "$HOME/.config/starship.toml"
    echo -e "${YELLOW}Removed${NC} Starship config symlink"
fi

# Remove Neovim configuration symlink
if [ -L "$HOME/.config/nvim" ]; then
    rm "$HOME/.config/nvim"
    echo -e "${YELLOW}Removed Neovim symlink${NC} $HOME/.config/nvim"

    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR/nvim" ]; then
        mkdir -p "$HOME/.config"
        cp -r "$BACKUP_DIR/nvim" "$HOME/.config/"
        echo -e "${GREEN}Restored${NC} Neovim configuration from backup"
    fi
fi

# Remove Kitty configuration symlink
if [ -L "$HOME/.config/kitty/kitty.conf" ]; then
    rm "$HOME/.config/kitty/kitty.conf"
    echo -e "${YELLOW}Removed${NC} Kitty config symlink"
fi

# Remove Kate theme symlink
if [ -L "$HOME/.local/share/org.kde.syntax-highlighting/themes/tokyo-night.theme" ]; then
    rm "$HOME/.local/share/org.kde.syntax-highlighting/themes/tokyo-night.theme"
    echo -e "${YELLOW}Removed${NC} Kate Tokyo Night theme symlink"
fi

# Restore .zshrc from backup if it exists, otherwise strip dotfiles lines
if [ -n "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/.zshrc" ]; then
    cp "$BACKUP_DIR/.zshrc" "$HOME/.zshrc"
    echo -e "${GREEN}Restored${NC} original .zshrc from backup"
elif [ -f "$HOME/.zshrc" ]; then
    echo "No .zshrc backup found, stripping dotfiles-specific lines..."
    TEMP_FILE=$(mktemp)
    sed '/# Added by dotfiles installer/d;
         /source \$HOME\/.dotfiles\/zsh\/aliases.zsh/d;
         /source \$HOME\/.dotfiles\/zsh\/key-bindings.zsh/d;
         /source \$HOME\/.dotfiles\/zsh\/integrations.zsh/d;
         /# ZSH plugins (autosuggestions/d;
         /ZSH_PLUGINS="\$HOME\/.zsh\/plugins"/d;
         /zsh-autosuggestions\.zsh/d;
         /fast-syntax-highlighting\.plugin\.zsh/d;
         /zsh-completions\/src/d;
         /autoload -Uz compinit/d;
         /# Initialize completions/d;
         /# >>> mamba initialize >>>/,/# <<< mamba initialize <<</d' "$HOME/.zshrc" > "$TEMP_FILE"
    cp "$TEMP_FILE" "$HOME/.zshrc"
    rm "$TEMP_FILE"
    echo -e "${GREEN}Removed${NC} dotfiles-specific lines from .zshrc"
fi

# Remove ZSH configuration symlinks
rm -f "$HOME/.dotfiles/zsh/aliases.zsh"
rm -f "$HOME/.dotfiles/zsh/key-bindings.zsh"
rm -f "$HOME/.dotfiles/zsh/integrations.zsh"

# Remove modular configuration directory
if [ -d "$HOME/.dotfiles" ]; then
    rm -rf "$HOME/.dotfiles"
    echo -e "${YELLOW}Removed${NC} $HOME/.dotfiles directory"
fi

# Remove ZSH plugins
if [ -d "$HOME/.zsh/plugins" ]; then
    rm -rf "$HOME/.zsh/plugins"
    echo -e "${YELLOW}Removed${NC} ZSH plugins"
fi

# Remove micromamba
if [ -d "$HOME/micromamba" ]; then
    rm -rf "$HOME/micromamba"
    echo -e "${YELLOW}Removed${NC} micromamba"
fi
if [ -f "$HOME/.local/bin/micromamba" ]; then
    rm "$HOME/.local/bin/micromamba"
    echo -e "${YELLOW}Removed${NC} micromamba binary"
fi

echo -e "\n${GREEN}Uninstallation complete!${NC}"
echo "Your original configuration has been restored where possible."
echo "You may need to restart your terminal for changes to take effect."
