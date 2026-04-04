# dotfiles

Personal terminal configuration for Linux (Ubuntu/Debian). Works on both headless servers and Kubuntu desktop — desktop-only configs are auto-skipped on servers.

## Quick Start

```bash
git clone https://github.com/brokenlander/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/install-dependencies.sh
# restart shell
./scripts/install.sh
```

## What's Included

### Shared (server + desktop)

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

### Desktop only (auto-detected)

| Tool | Purpose |
|------|---------|
| Kitty | GPU-accelerated terminal (Tokyo Night) |
| Kate | Text editor (Tokyo Night theme) |
| KDE | Breeze Dark, 150% scaling, panel tweaks |
| JetBrains Mono Nerd Font | Terminal/editor font |
| OnlyOffice | Office suite |
| Vesktop | Discord client (Vencord) |
| Haruna | Video player |
| KeePassXC | Password manager |
| Steam | Gaming |

## Structure

```
dotfiles/
├── nvim/           # Neovim (Lazy.nvim, LSP, plugins)
├── zsh/            # Shell aliases, keybindings, integrations
├── tmux/           # Tmux config + Tokyo Night theme
├── git/            # .gitconfig + .gitignore_global
├── kitty/          # Kitty terminal config
├── kate/           # Kate editor theme
├── starship/       # Starship prompt config
└── scripts/
    ├── install-dependencies.sh
    ├── install.sh
    └── uninstall.sh
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
