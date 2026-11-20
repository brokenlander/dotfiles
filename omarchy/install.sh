#!/bin/bash
# Omarchy install: the laptop counterpart to scripts/install.sh (Ubuntu).
# Run after scripts/pre-install.sh. Safe to run again.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

# link <repo-path> <target>: back up a real file, then symlink it to the repo.
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP_DIR"; cp -a "$dst" "$BACKUP_DIR/"
    echo -e "${YELLOW}Backed up${NC} $dst"
  fi
  ln -sfn "$src" "$dst"
  echo -e "${GREEN}Linked${NC} $dst"
}

# -------- Theme --------
[ "$(omarchy theme current)" = "Ristretto" ] || omarchy theme set ristretto

# -------- Packages --------
pacman -Q zen-browser-bin >/dev/null 2>&1 || omarchy install browser zen
omarchy default browser zen
pacman -Q onedrive-abraunegg >/dev/null 2>&1 || omarchy pkg aur add onedrive-abraunegg
pacman -Q solaar >/dev/null 2>&1 || omarchy pkg add solaar   # Logitech MX Keys / MX Master

# Apps added (see README > Omarchy apps: what stays and what goes)
omarchy pkg add discord spotify bitwarden obs-studio
pacman -Q onlyoffice-bin >/dev/null 2>&1 || omarchy pkg aur add onlyoffice-bin

# Omarchy apps removed. OWE plays the login intro video, so the intro goes off first.
omarchy theme bg intro disable >/dev/null 2>&1 || true
omarchy pkg drop libreoffice-fresh aether cliamp hype monologue omacut omawrite ttfx owe \
  fcitx5-chewing fcitx5-chinese-addons fcitx5-hangul fcitx5-mozc fcitx5-table-extra asdcontrol herdr
rm -rf "$HOME/.config/herdr"   # herdr: replaced by tmux + agent-sidebar

# Tailscale (asks you to log in through a link the first time)
pacman -Q tailscale >/dev/null 2>&1 || omarchy install service tailscale

# -------- Shell --------
mkdir -p "$HOME/forge"
if ! grep -q 'dotfiles/shell/aliases.sh' "$HOME/.bashrc"; then
  printf '\n# Shared aliases from dotfiles\n[ -f ~/dotfiles/shell/aliases.sh ] && . ~/dotfiles/shell/aliases.sh\n' >> "$HOME/.bashrc"
  echo -e "${GREEN}Added${NC} aliases to ~/.bashrc"
fi
if ! grep -q 'dotfiles/shell/env.sh' "$HOME/.bashrc"; then
  printf '[ -f ~/dotfiles/shell/env.sh ] && . ~/dotfiles/shell/env.sh\n' >> "$HOME/.bashrc"
  echo -e "${GREEN}Added${NC} shell env to ~/.bashrc"
fi

# zsh in terminals (bash stays the login shell; Omarchy's session expects it)
pacman -Q zsh >/dev/null 2>&1 || omarchy pkg add zsh
"$DOTFILES/shell/install-zsh-plugins.sh"
link zsh/zshrc "$HOME/.zshrc"

# -------- Terminal + prompt --------
link foot/foot.ini "$HOME/.config/foot/foot.ini"
ln -sfn "$HOME/.local/state/omarchy/current/theme/foot.ini" "$HOME/.config/foot/theme.ini"
link starship/starship.toml "$HOME/.config/starship.toml"

# -------- Git --------
for f in config ignore work.gitconfig; do link "git/$f" "$HOME/.config/git/$f"; done
if [ ! -f "$HOME/.gitconfig.local" ]; then
  printf '[credential "https://github.com"]\n\thelper =\n\thelper = !gh auth git-credential\n[credential "https://gist.github.com"]\n\thelper =\n\thelper = !gh auth git-credential\n' > "$HOME/.gitconfig.local"
  echo -e "${GREEN}Created${NC} ~/.gitconfig.local (gh credential helper)"
fi

# Global commit guards (core.hooksPath = ~/.git-hooks/)
for hook in "$DOTFILES"/git-hooks/*; do link "git-hooks/$(basename "$hook")" "$HOME/.git-hooks/$(basename "$hook")"; done

# -------- tmux + agent workflow (agent-sidebar, pm-* tools, agent keys) --------
pacman -Q tmux >/dev/null 2>&1 || omarchy pkg add tmux
pacman -Q sesh >/dev/null 2>&1 || omarchy pkg aur add sesh   # prefix+y session picker
link tmux/.tmux.conf "$HOME/.tmux.conf"
link tmux/.tmux.conf "$HOME/.config/tmux/tmux.conf"   # Omarchy's own tmux config is replaced
for u in tmux-resurrect-save.service tmux-resurrect-save.timer; do
  link "systemd/user/$u" "$HOME/.config/systemd/user/$u"
done
systemctl --user daemon-reload
systemctl --user enable --now tmux-resurrect-save.timer
"$DOTFILES/scripts/agents-setup.sh"

# -------- Editor --------
link nvim/lua/plugins/dashboard.lua "$HOME/.config/nvim/lua/plugins/dashboard.lua"

# -------- Hyprland --------
link omarchy/hypr/looknfeel.lua "$HOME/.config/hypr/looknfeel.lua"
link omarchy/hypr/input.lua "$HOME/.config/hypr/input.lua"   # natural touchpad scrolling
link omarchy/hypr/bindings.lua "$HOME/.config/hypr/bindings.lua"   # Alt+\ types ~

# -------- Bar, dock, idle (shell.json) --------
# Bar: no keyboard-layout widget; mic, media and Tailscale added; world clocks.
# Dock: Zen instead of Chromium. Idle: no screensaver, no auto-lock.
python3 -I "$DOTFILES/omarchy/shell-settings.py"

# -------- Idle: screen off after 5 min, never auto-lock --------
pacman -Q hypridle >/dev/null 2>&1 || omarchy pkg add hypridle
link omarchy/hypr/hypridle.conf "$HOME/.config/hypr/hypridle.conf"
systemctl --user enable --now hypridle.service
systemctl --user mask --now omarchy-sleep-lock.service   # no lock before suspend

# -------- Wallpapers (not in the repo; see omarchy/wallpapers.txt) --------
WP="$HOME/.config/omarchy/backgrounds/ristretto"; mkdir -p "$WP"
grep -v '^#' "$DOTFILES/omarchy/wallpapers.txt" | while read -r url; do
  [ -n "$url" ] && [ ! -s "$WP/$(basename "$url")" ] && curl -sfL -o "$WP/$(basename "$url")" "$url" || true
done

# -------- OneDrive --------
link onedrive/config "$HOME/.config/onedrive/config"

# -------- Web apps (LAST: installers above, e.g. Tailscale, add their own) --------
"$DOTFILES/omarchy/remove-webapps.sh"

echo -e "${GREEN}Done.${NC} Manual steps: README > Omarchy."
