#!/bin/bash
# Pre-install: run once on a fresh machine (Ubuntu or Omarchy), before anything else.
# Asks for the sudo password one last time.
set -euo pipefail

# Passwordless sudo for this user (validated with visudo before it is kept).
rule="$USER ALL=(ALL) NOPASSWD: ALL"
tmp=$(mktemp)
echo "$rule" > "$tmp"
sudo visudo -cf "$tmp" >/dev/null
sudo install -m 440 -o root -g root "$tmp" "/etc/sudoers.d/$USER"
rm -f "$tmp"
echo "Passwordless sudo enabled for $USER"

# Personal workspace folder (cdf alias)
mkdir -p "$HOME/forge"
