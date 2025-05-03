#!/bin/bash


# Update package lists
sudo apt update

# Install zsh
sudo apt install -y zsh 

# Install modern CLI replacements
sudo apt install -y bat
sudo apt install -y exa
sudo apt install -y fd-find
sudo apt install -y ripgrep
sudo apt install -y dust
sudo apt install -y bottom
sudo apt install -y zoxide
sudo apt install -y git-delta
sudo apt install -y tldr

# Install neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install -y neovim

# Install Git (latest version)
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sleep 2

# Install Micromamba
sudo mkdir /opt/micromamba
sudo chmod -R a+rw /opt/micromamba
BIN_FOLDER="/opt/micromamba/bin" PREFIX_LOCATION="/opt/micromamba" INIT_YES="yes" CONDA_FORGE_YES="yes" ${SHELL} <(curl -L micro.mamba.pm/install.sh) < /dev/null


# Install ZSH plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# Set ZSH as default shell
sudo chsh -s $(which zsh)
