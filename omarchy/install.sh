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

# -------- Shell --------
mkdir -p "$HOME/forge"
if ! grep -q 'dotfiles/shell/aliases.sh' "$HOME/.bashrc"; then
  printf '\n# Shared aliases from dotfiles\n[ -f ~/dotfiles/shell/aliases.sh ] && . ~/dotfiles/shell/aliases.sh\n' >> "$HOME/.bashrc"
  echo -e "${GREEN}Added${NC} aliases to ~/.bashrc"
fi

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

# -------- Editor --------
link nvim/lua/plugins/dashboard.lua "$HOME/.config/nvim/lua/plugins/dashboard.lua"

# -------- Hyprland --------
link omarchy/hypr/looknfeel.lua "$HOME/.config/hypr/looknfeel.lua"

# -------- Idle: screen off after 5 min, never auto-lock --------
python3 -I - <<'PYJ'
import json, pathlib
p = pathlib.Path.home()/".config/omarchy/shell.json"
d = json.loads(p.read_text()) if p.exists() else {}
d["idle"] = {"screensaver": 0, "lock": 0}
p.write_text(json.dumps(d, indent=2) + "\n")
PYJ
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

echo -e "${GREEN}Done.${NC} Manual steps: README > Omarchy."
