#!/bin/bash
# Remove every Omarchy web app except WhatsApp (no native Linux app).
# Other sites open in Zen. Run at the end of omarchy/install.sh, and again by
# hand after any Omarchy installer that adds a web app back (Tailscale does).
set -u
APPS="$HOME/.local/share/applications"
KEEP="WhatsApp"
for f in "$APPS"/*.desktop; do
  [ -e "$f" ] || continue
  grep -q 'omarchy-launch-webapp\|omarchy-webapp-handler' "$f" || continue
  name=$(basename "$f" .desktop)
  [ "$name" = "$KEEP" ] && continue
  omarchy webapp remove "$name" >/dev/null 2>&1 && echo "removed web app: $name"
done
