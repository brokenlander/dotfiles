#!/bin/bash
# No set -e — too many tools have non-zero exits that aren't real errors

# Detect desktop environment
HAS_DISPLAY=false
if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ] || [ -n "$XDG_CURRENT_DESKTOP" ]; then
    HAS_DISPLAY=true
fi

echo "=== Starting dependency installation ==="
echo "Desktop detected: $HAS_DISPLAY"

# Clean up old Docker config (only if Docker is missing or not from official repo)
if dpkg -l docker-ce 2>/dev/null | grep -q "^ii"; then
    echo "=== Docker already installed from official repo, skipping cleanup ==="
else
    echo "=== Cleaning up old package configs ==="
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/keyrings/docker.asc
    sudo rm -f /etc/apt/keyrings/docker.gpg
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get purge -y $pkg 2>/dev/null || true
    done
    sudo apt-get autoremove -y 2>/dev/null || true
fi

# Update system
echo "=== Updating system ==="
sudo apt-get update
sudo apt-get install -y build-essential
sudo apt-get full-upgrade -y

# General tools (shared)
echo "=== Installing general tools ==="
sudo apt-get install -y curl fzf python3 pipx xclip xsel unzip rclone tmux jq glow libudev-dev openssh-server autossh fastfetch

# Desktop-only packages
if [ "$HAS_DISPLAY" = true ]; then
    echo "=== Installing desktop packages ==="
    sudo apt-get install -y kitty keepassxc haruna steam-installer ubuntu-restricted-extras timeshift solaar papirus-icon-theme

    # Zen Browser
    echo "=== Installing Zen Browser ==="
    if command -v zen-browser &> /dev/null || [ -d "$HOME/.tarball-installations/zen" ]; then
        echo "Zen Browser already installed, skipping..."
    else
        curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | bash
    fi
fi

# Enable SSH
sudo systemctl enable ssh

# ZSH
echo "=== Installing ZSH ==="
sudo apt install -y zsh
sudo usermod -s $(which zsh) "$USER"
touch "$HOME/.zshrc"

# Modern CLI replacements
echo "=== Installing modern CLI tools ==="
sudo apt install -y bat eza fd-find ripgrep zoxide git-delta tealdeer duf btop difftastic

# Dust
echo "=== Installing dust ==="
if command -v dust &> /dev/null; then
    echo "Dust already installed, skipping..."
else
    DUST_VERSION=$(curl -s "https://api.github.com/repos/bootandy/dust/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    if [ -z "$DUST_VERSION" ]; then
        echo "WARNING: Failed to fetch dust version (GitHub API rate limit?). Skipping."
    else
        wget -P /tmp "https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
        tar -xf "/tmp/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz" -C /tmp
        sudo mv "/tmp/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu/dust" /usr/local/bin/
        sudo chmod +x /usr/local/bin/dust
        rm "/tmp/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
        rm -rf "/tmp/dust-v${DUST_VERSION}-x86_64-unknown-linux-gnu"
    fi
fi

# Starship prompt
echo "=== Installing Starship ==="
if command -v starship &> /dev/null; then
    echo "Starship already installed, skipping..."
else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Add PPAs for Neovim and Git
echo "=== Adding PPAs ==="
timeout 30 sudo add-apt-repository -y ppa:neovim-ppa/stable 2>/dev/null || echo "WARNING: Neovim PPA failed, will use Ubuntu repo version."
timeout 30 sudo add-apt-repository -y ppa:git-core/ppa 2>/dev/null || echo "WARNING: Git PPA failed, will use Ubuntu repo version."
sudo apt update
sudo apt install -y neovim git

# Docker
echo "=== Installing Docker ==="
if dpkg -l docker-ce 2>/dev/null | grep -q "^ii"; then
    echo "Docker already installed from official repo, skipping..."
else
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo usermod -aG docker "$USER"

# Lazydocker
echo "=== Installing Lazydocker ==="
if command -v lazydocker &> /dev/null; then
    echo "Lazydocker already installed, skipping..."
else
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

# GitHub CLI
echo "=== Installing GitHub CLI ==="
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# ZSH plugins (no Oh-My-ZSH, manual install)
echo "=== Installing ZSH plugins ==="
ZSH_PLUGINS="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGINS"

if [ ! -d "$ZSH_PLUGINS/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_PLUGINS/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_PLUGINS/fast-syntax-highlighting" ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_PLUGINS/fast-syntax-highlighting"
fi

if [ ! -d "$ZSH_PLUGINS/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions.git "$ZSH_PLUGINS/zsh-completions"
fi

# Micromamba
echo "=== Installing Micromamba ==="
if [ -f "$HOME/.local/bin/micromamba" ]; then
    echo "Micromamba already installed, skipping..."
else
    INIT_YES="yes" CONDA_FORGE_YES="yes" bash <(curl -L micro.mamba.pm/install.sh) < /dev/null
    export PATH="$HOME/.local/bin:$PATH"
fi

# uv (Python package manager)
echo "=== Installing uv ==="
if command -v uv &> /dev/null; then
    echo "uv already installed, skipping..."
else
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# pipx packages (using uv if available, pipx as fallback)
export PATH="$HOME/.local/bin:$PATH"
pipx ensurepath
pipx install pylint
pipx install black
pipx install isort


# fnm (Fast Node Manager)
echo "=== Installing fnm ==="
if command -v fnm &> /dev/null; then
    echo "fnm already installed, skipping..."
else
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

# Node.js
echo "=== Installing Node.js ==="
fnm install --lts
fnm use --lts
npm install --global yarn
npm install --global tree-sitter-cli
npm install --global neovim

# Claude Code CLI
echo "=== Installing Claude Code CLI ==="
if command -v claude &> /dev/null; then
    echo "Claude Code CLI already installed, skipping..."
else
    curl -fsSL https://cli.claude.ai/install.sh | sh
    if ! grep -q "claude/bin" ~/.zshrc; then
        echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.zshrc
    fi
fi

# Agency Agents (Claude Code agent personalities)
echo "=== Installing Agency Agents ==="
if [ -d "$HOME/.claude/agents" ] && [ "$(ls -A $HOME/.claude/agents 2>/dev/null)" ]; then
    echo "Agency agents already installed, skipping..."
else
    AGENCY_TMP=$(mktemp -d)
    git clone https://github.com/msitarzewski/agency-agents.git "$AGENCY_TMP"
    mkdir -p "$HOME/.claude/agents"
    cp -r "$AGENCY_TMP"/agents/* "$HOME/.claude/agents/" 2>/dev/null || cp -r "$AGENCY_TMP"/*.md "$HOME/.claude/agents/" 2>/dev/null || true
    rm -rf "$AGENCY_TMP"
fi

# TPM (Tmux Plugin Manager)
echo "=== Installing TPM ==="
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "TPM already installed, skipping..."
else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# FZF Shell Integration
echo "=== Configuring FZF Shell Integration ==="
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    echo "FZF keybindings available"
else
    echo "Warning: FZF keybindings not found at expected location"
fi

# Direnv
echo "=== Installing Direnv ==="
if command -v direnv &> /dev/null; then
    echo "Direnv already installed, skipping..."
else
    sudo apt install -y direnv
fi

# Lazygit
echo "=== Installing Lazygit ==="
if command -v lazygit &> /dev/null; then
    echo "Lazygit already installed, skipping..."
else
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    if [ -z "$LAZYGIT_VERSION" ]; then
        echo "WARNING: Failed to fetch lazygit version. Skipping."
    else
        curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit -D -t /usr/local/bin/
        rm /tmp/lazygit.tar.gz /tmp/lazygit
    fi
fi

# Desktop-only: OnlyOffice, Vesktop, Fonts, KDE settings
if [ "$HAS_DISPLAY" = true ]; then
    echo "=== Installing OnlyOffice ==="
    mkdir -p -m 700 ~/.gnupg
    TMPKEYRING=$(mktemp /tmp/onlyoffice-keyring.XXXXXX.gpg)
    gpg --no-default-keyring --keyring "gnupg-ring:$TMPKEYRING" --keyserver hkps://keyserver.ubuntu.com --recv-keys E09CA29F6E178040EF22B4098320CA65CB2DE8E5
    chmod 644 "$TMPKEYRING"
    sudo chown root:root "$TMPKEYRING"
    sudo mv "$TMPKEYRING" /usr/share/keyrings/onlyoffice.gpg
    echo 'deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main' | sudo tee /etc/apt/sources.list.d/onlyoffice.list
    sudo apt-get update
    sudo apt-get install -y onlyoffice-desktopeditors

    echo "=== Installing Vesktop ==="
    VESKTOP_VERSION=$(curl -s "https://api.github.com/repos/Vencord/Vesktop/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    if [ -z "$VESKTOP_VERSION" ]; then
        echo "WARNING: Failed to fetch Vesktop version. Skipping."
    else
        wget -O /tmp/vesktop.deb "https://github.com/Vencord/Vesktop/releases/download/v${VESKTOP_VERSION}/vesktop_${VESKTOP_VERSION}_amd64.deb"
        sudo dpkg -i /tmp/vesktop.deb
        sudo apt-get install -f -y
    fi

    echo "=== Installing JetBrains Mono Nerd Font ==="
    mkdir -p ~/.local/share/fonts
    wget -qO /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
    fc-cache -f

    echo "=== Installing Keymapp (ZSA keyboard firmware) ==="
    if [ ! -f /opt/keymapp/keymapp ]; then
        wget -O /tmp/keymapp.tar.gz "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz"
        sudo mkdir -p /opt/keymapp
        sudo tar -xzf /tmp/keymapp.tar.gz -C /opt/keymapp/
        sudo ln -sf /opt/keymapp/keymapp /usr/local/bin/keymapp
    fi
    # ZSA udev rules
    if [ ! -f /etc/udev/rules.d/50-zsa.rules ]; then
        sudo bash -c 'cat > /etc/udev/rules.d/50-zsa.rules << UDEV
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="0791", GROUP="plugdev"
UDEV'
        sudo udevadm control --reload-rules
    fi
    sudo usermod -aG plugdev "$USER"

    echo "=== Applying KDE desktop settings ==="
    plasma-apply-lookandfeel --apply org.kde.breezedark.desktop || echo "WARNING: Plasma not running, apply dark mode manually after login."
    kscreen-doctor output.1.scale.1.5 || echo "WARNING: Could not set display scale, set manually in System Settings > Display."
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark 2>/dev/null || true
    sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
fi

# Zoxide init
echo "=== Configuring Zoxide ==="
if ! grep -q "zoxide init zsh" ~/.zshrc; then
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
fi

# Forge directory
echo "=== Setting up forge directory ==="
mkdir -p ~/forge
if ! grep -q "Set forge as default directory" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOL'
# Set forge as default directory
if [[ "$PWD" == "$HOME" && -z "$NVIM_SESSION" ]]; then
  cd ~/forge
fi
EOL
fi

echo "=== Installation complete! ==="
echo "Desktop packages installed: $HAS_DISPLAY"
echo "Please restart your terminal or run: exec zsh"
