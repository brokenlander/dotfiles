#!/bin/bash
# zsh plugins, no framework (both machines). Safe to run again: updates existing clones.
set -euo pipefail
ZSH_PLUGINS="$HOME/.zsh/plugins"
mkdir -p "$ZSH_PLUGINS"
for repo in zsh-users/zsh-autosuggestions zdharma-continuum/fast-syntax-highlighting zsh-users/zsh-completions; do
  dir="$ZSH_PLUGINS/${repo#*/}"
  if [ -d "$dir/.git" ]; then
    git -C "$dir" pull -q --ff-only || echo "could not update $dir"
  else
    git clone -q --depth 1 "https://github.com/$repo.git" "$dir"
  fi
done
echo "zsh plugins ready in $ZSH_PLUGINS"
