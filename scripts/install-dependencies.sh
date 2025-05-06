#!/bin/bash

# Update package lists
sudo apt update
sudo apt install -y build-essential
sudo apt upgrade -y

# General tools
sudo apt install -y unzip curl fzf

# Install zsh
sudo apt install -y zsh
sudo usermod -s $(which zsh) "$USER"
touch /home/$USER/.zshrc

# Install modern CLI replacements
sudo apt install -y bat
sudo apt install -y eza
sudo apt install -y fd-find
sudo apt install -y ripgrep
sudo apt install -y zoxide
sudo apt install -y git-delta
sudo apt install -y tldr

# Bottom
curl -LO https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb
sudo dpkg -i bottom_0.10.2-1_amd64.deb
rm bottom_0.10.2-1_amd64.deb

# Dust
wget https://github.com/bootandy/dust/releases/download/v1.1.1/dust-v1.1.1-x86_64-unknown-linux-gnu.tar.gz
tar -xvf dust-v1.1.1-x86_64-unknown-linux-gnu.tar.gz
sudo mv dust-v1.1.1-x86_64-unknown-linux-gnu/dust /usr/local/bin/
sudo chmod +x /usr/local/bin/dust
rm dust-v1.1.1-x86_64-unknown-linux-gnu.tar.gz
rm -rf dust-v1.1.1-x86_64-unknown-linux-gnu

# Install neovim
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

# Install Git
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git

#Install Docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sleep 2

# Install Micromamba
INIT_YES="yes" CONDA_FORGE_YES="yes" bash <(curl -L micro.mamba.pm/install.sh) < /dev/null
export PATH="$HOME/.local/bin:$PATH"
"$HOME/.local/bin/micromamba" shell init --shell zsh --root-prefix ~/micromamba


# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=~/.zshrc bash

# Zoxide
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

# Create Forge
mkdir -p forge
cat >> ~/.zshrc << 'EOL'

# Set forge as default directory
if [[ "$PWD" == "$HOME" && -z "$NVIM_SESSION" ]]; then
  cd ~/forge
fi
EOL
