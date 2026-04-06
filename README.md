# dotfiles

Personal configuration for Linux (Ubuntu/Debian). Three tiers: server (any box), desktop (Kubuntu), and workstation (this specific machine).

## Fresh Install

### 1. Pre-install (manual)

Do a **minimal install** of Kubuntu, then enable passwordless sudo:

```bash
sudo bash -c 'echo "brokenlander ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/brokenlander && chmod 440 /etc/sudoers.d/brokenlander'
```

### 2. Server + Desktop

```bash
git clone https://github.com/brokenlander/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install-dependencies.sh
# restart shell
./scripts/install.sh
```

This installs and configures everything portable: CLI tools, ZSH, Neovim, Tmux, Docker, Git, Starship, Kitty, Kate, KDE settings, fonts, Zen Browser, Vesktop, OnlyOffice, Spotify, Steam, Krohnkite, and more. Desktop packages are auto-skipped on headless servers.

### 3. Workstation (this machine only)

```bash
./scripts/workstation.sh
```

Hardware-specific setup for the primary rig:
- NVIDIA driver 590 (RTX 5090) + Secure Boot MOK enrollment
- Display: 1440p @ 120Hz, 1.5x scale
- Disable sleep/suspend (always-on)
- OpenLinkHub (Corsair iCUE alternative)
- Keymapp + udev rules (ZSA Voyager keyboard)
- Elgato Wave 3 WirePlumber fix (mic silence bug)
- OBSBOT Tiny 2 + Tiny4Linux CLI (AI tracking control)
- CUDA toolkit 13.1

Voice services (ASR/TTS) are managed separately — see `~/forge/voice/README.md`.

### 4. Post-install (manual)

```bash
# GitHub CLI
gh auth login

# OneDrive
onedrive
nano ~/.config/onedrive/sync_list    # add folders to sync
onedrive --sync --resync

# Zen settings from Windows partition
udisksctl mount -b /dev/nvme0n1p3
~/dotfiles/scripts/sync-zen-settings.sh

# Timeshift — first snapshot
sudo timeshift-gtk
```

### 5. UI tweaks (can't be scripted)

- **Panel height** — right-click panel > Edit Mode > drag top edge to ~36px
- **Krohnkite** — System Settings > Window Management > KWin Scripts > Krohnkite gear icon (gaps, float rules, layouts). Reboot after.
- **OBS Studio** — first launch wizard: optimize for recording, 2560x1440 base, 1920x1080 output, Lanczos, 30fps, NVENC, Screen Capture (PipeWire)

---

## What's Included

### Server (any Linux box)

| Category | Tools |
|----------|-------|
| Shell | ZSH + Starship prompt |
| Editor | Neovim (30+ plugins, LSP, Mason, Treesitter) |
| Multiplexer | Tmux (Tokyo Night, session persistence) |
| Git | Delta pager, GitHub CLI integration, aliases |
| CLI tools | bat, eza, fd, ripgrep, zoxide, delta, dust, btop, tldr, duf, difftastic |
| Dev tools | lazygit, lazydocker, fzf, direnv, gh CLI |
| Runtimes | fnm (Node.js), uv (Python), micromamba (conda), pipx |
| Containers | Docker, Docker Compose |

### Desktop (Kubuntu)

| Tool | Purpose |
|------|---------|
| Kitty | GPU-accelerated terminal (Tokyo Night) |
| Kate | Text editor (Tokyo Night theme) |
| KDE | Breeze Dark, Papirus-Dark icons, Bibata-Modern-Ice cursor |
| Krohnkite | Dynamic tiling for KWin |
| JetBrains Mono Nerd Font | Terminal/editor font |
| OnlyOffice | Office suite |
| Vesktop | Discord client (Vencord) |
| Haruna | Video player |
| KeePassXC | Password manager |
| Spotify | Music |

### Workstation (this machine)

| Component | What |
|-----------|------|
| GPU | NVIDIA RTX 5090 (driver 590-open, CUDA 13.1) |
| Mic | Elgato Wave 3 (WirePlumber always-process fix) |
| Camera | OBSBOT Tiny 2 (Tiny4Linux CLI for tracking) |
| Keyboard | ZSA Voyager (Keymapp + udev rules) |
| Cooling | Corsair (OpenLinkHub) |
| Gaming | Steam, MangoHud, Gamemode, ProtonUp-Qt |

## Structure

```
dotfiles/
├── nvim/           # Neovim (Lazy.nvim, LSP, plugins)
├── zsh/            # Shell aliases, keybindings, integrations
├── tmux/           # Tmux config + Tokyo Night theme
├── git/            # .gitconfig + .gitignore_global
├── git-hooks/      # Global git hooks (block AI references in commits)
├── kitty/          # Kitty terminal config
├── kate/           # Kate editor theme
├── starship/       # Starship prompt config
├── btop/           # System monitor config + theme
├── cava/           # Audio visualizer config
├── fastfetch/      # System info display config
├── mangohud/       # Game overlay config
└── scripts/
    ├── install-dependencies.sh  # Server + Desktop packages
    ├── install.sh               # Symlinks + configs
    ├── workstation.sh           # Hardware-specific setup
    ├── sync-zen-settings.sh     # Zen Browser Windows sync
    └── uninstall.sh             # Restore original configs
```

## Key Bindings

### Neovim
- **Leader**: Space
- `gd` definition, `gR` references, `<leader>ca` code action, `<leader>rn` rename
- `Tab`/`Shift+Tab` switch buffers
- `<leader>ee` file explorer, `<leader>ff` find files

### Tmux
- **Prefix**: Ctrl+B
- `|` / `-` split panes
- `Alt+h/j/k/l` switch panes (no prefix)
- `Prefix+Ctrl+s` save session, `Prefix+Ctrl+r` restore

### ZSH
- `Ctrl+R` fuzzy history (fzf)
- `Ctrl+T` fuzzy file search
- `Alt+C` fuzzy cd

## Uninstall

```bash
./scripts/uninstall.sh
```

Restores original configs from backup.
