#!/usr/bin/env bash
# Builds herd-bundle.tgz. In a workspace: tar xzf herd-bundle.tgz -C ~ && ~/.herd/install.sh
set -eu
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIDEBAR="${SIDEBAR:-$HOME/forge/agent-sidebar}"
FZF=0.56.3
OUT="${1:-$PWD/herd-bundle.tgz}"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
mkdir -p "$T/dotfiles/bin" "$T/forge/agent-sidebar" "$T/.herd"
for f in pm-board pm-board-hook pm-roster pm-agent-defs pm-lastsaid; do cp "$HERE/../bin/$f" "$T/dotfiles/bin/"; done
cp -r "$SIDEBAR/agent-sidebar" "$SIDEBAR/sidebar.tmux" "$SIDEBAR/scripts" "$SIDEBAR/producers" "$T/forge/agent-sidebar/"
cp "$HERE/herd" "$HERE/install.sh" "$HERE/tmux.conf" "$HERE/briefing.md" "$T/.herd/"
curl -fsSL "https://github.com/junegunn/fzf/releases/download/v$FZF/fzf-$FZF-linux_amd64.tar.gz" | tar xz -C "$T/.herd"
tar czf "$OUT" -C "$T" dotfiles forge .herd
echo "$OUT"
