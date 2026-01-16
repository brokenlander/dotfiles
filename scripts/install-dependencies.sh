#!/bin/bash
set -e

echo "=== Starting dependency installation ==="

# Clean up old Docker config first (prevents apt errors from stale repos)
echo "=== Cleaning up old package configs ==="
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.asc
sudo rm -f /etc/apt/keyrings/docker.gpg
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; do 
    sudo apt-get purge -y $pkg 2>/dev/null || true
done
sudo apt-get autoremove -y 2>/dev/null || true

# Update system
echo "=== Updating system ==="
sudo apt update
sudo apt install -y build-essential
sudo apt upgrade -y

# General tools
echo "=== Installing general tools ==="
sudo apt install -y curl fzf python3 pipx xclip xsel unzip rclone tmux jq

# pipx packages
export PATH="$HOME/.local/bin:$PATH"
pipx ensurepath
pipx install pylint
pipx install black
pipx install isort

# Python neovim provider
pip install pynvim --break-system-packages

# ZSH
echo "=== Installing ZSH ==="
sudo apt install -y zsh
sudo usermod -s $(which zsh) "$USER"
touch /home/$USER/.zshrc

# Modern CLI replacements
echo "=== Installing modern CLI tools ==="
sudo apt install -y bat eza fd-find ripgrep zoxide git-delta tldr duf

# Bottom (remove conflicting btm package first)
echo "=== Installing bottom ==="
sudo apt remove -y btm 2>/dev/null || true
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb
sudo dpkg -i bottom_0.10.2-1_amd64.deb
rm bottom_0.10.2-1_amd64.deb

# Dust
echo "=== Installing dust ==="
wget https://github.com/bootandy/dust/releases/download/v1.1.1/dust-v1.1.1-x86_64-unknown-linux-gnu.tar.gz
tar -xvf dust-v1.1.1-x86_64-unknown-linux-gnu.tar.gz
sudo mv dust-v1.1.1-x86_64-unknown-linux-gnu/dust /usr/local/bin/
sudo chmod +x /usr/local/bin/dust
rm dust-v1.1.1-x86_64-unknown-linux-gnu.tar.gz
rm -rf dust-v1.1.1-x86_64-unknown-linux-gnu

# Neovim (timeout on PPA to avoid Launchpad hangs)
echo "=== Installing Neovim ==="
timeout 30 sudo add-apt-repository -y ppa:neovim-ppa/unstable || echo "PPA add timed out, trying anyway..."
sudo apt update
sudo apt install -y neovim

# Git
echo "=== Installing Git ==="
timeout 30 sudo add-apt-repository -y ppa:git-core/ppa || echo "PPA add timed out, trying anyway..."
sudo apt update
sudo apt install -y git

# Docker
echo "=== Installing Docker ==="
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
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

# Oh-My-ZSH
echo "=== Installing Oh-My-ZSH ==="
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "Oh-My-ZSH already installed, skipping..."
else
    rm -rf "$HOME/.oh-my-zsh" 2>/dev/null || true
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    sleep 2
fi

# Micromamba
echo "=== Installing Micromamba ==="
if [ -f "$HOME/.local/bin/micromamba" ]; then
    echo "Micromamba already installed, skipping..."
else
    INIT_YES="yes" CONDA_FORGE_YES="yes" bash <(curl -L micro.mamba.pm/install.sh) < /dev/null
    export PATH="$HOME/.local/bin:$PATH"
    "$HOME/.local/bin/micromamba" shell init --shell zsh --root-prefix ~/micromamba
fi

# NVM
echo "=== Installing NVM ==="
if [ -d "$HOME/.nvm" ]; then
    echo "NVM already installed, skipping..."
else
    # Install NVM without modifying any profile files
    # We manage NVM initialization in dotfiles/zsh/integrations.zsh instead
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Node.js
echo "=== Installing Node.js ==="
nvm install --lts
nvm use --lts
npm install --global yarn
npm install --global tree-sitter-cli
npm install --global neovim

# Claude Code CLI
echo "=== Installing Claude Code CLI ==="
if command -v claude &> /dev/null; then
    echo "Claude Code CLI already installed, skipping..."
else
    curl -fsSL claude.ai/install.sh | bash
    # Add to PATH if not already present
    if ! grep -q "claude/bin" ~/.zshrc; then
        echo 'export PATH="$HOME/.claude/bin:$PATH"' >> ~/.zshrc
    fi
fi

# TPM (Tmux Plugin Manager)
echo "=== Installing TPM (Tmux Plugin Manager) ==="
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "TPM already installed, skipping..."
else
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed. Plugins will be installed after tmux config is linked."
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
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm lazygit.tar.gz lazygit
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
echo "Please restart your terminal or run: exec zsh"
