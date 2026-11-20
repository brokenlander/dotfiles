#!/usr/bin/env python3
"""Apply personal settings to ~/.config/omarchy/shell.json (Omarchy's bar, idle).

Edits only the keys below and keeps everything else Omarchy or its commands
wrote there. Safe to run again.
"""
import json
import pathlib

path = pathlib.Path.home() / ".config/omarchy/shell.json"
cfg = json.loads(path.read_text()) if path.exists() else {}

# Idle: no screensaver, no automatic lock (hypridle turns the screen off).
cfg["idle"] = {"screensaver": 0, "lock": 0}

layout = cfg.setdefault("bar", {}).setdefault("layout", {})


def section(name):
    return layout.setdefault(name, [])


def find(widget_id):
    for name, items in layout.items():
        for i, item in enumerate(items):
            if item.get("id") == widget_id:
                return name, i, item
    return None, None, None


def remove(widget_id):
    name, i, _ = find(widget_id)
    if name is not None:
        del layout[name][i]


def ensure(widget_id, name, before=None, after=None, **settings):
    """Place widget_id in section name (once), next to before/after if present."""
    _, _, item = find(widget_id)
    if item is None:
        item = {"id": widget_id}
        items = section(name)
        anchor = before or after
        idx = next((i for i, it in enumerate(items) if it.get("id") == anchor), None)
        if idx is None:
            items.append(item)
        else:
            items.insert(idx if before else idx + 1, item)
    item.update(settings)


# Only one keyboard layout (Italian), so its widget never changes.
remove("omarchy.keyboard-layout")

# Mic state next to audio (handy with Superwhisper dictation).
ensure("omarchy.microphone", "right", before="omarchy.audio")

# Now playing, with controls, beside the status indicators.
ensure("omarchy.media", "centerBegin", after="omarchy.indicators")

# Tailscale next to the network widget.
ensure("omarchy.tailscale", "right", before="omarchy.network")

# World clocks.
ensure(
    "omarchy.elsewhen",
    "centerEnd",
    units="C",  # Celsius, like the weather widget
    cities=[
        {"name": "Geneva", "zone": "Europe/Zurich"},
        {"name": "Arona", "zone": "Europe/Rome"},
        {"name": "Belfast", "zone": "Europe/London"},
        {"name": "New York", "zone": "America/New_York"},
        {"name": "San Francisco", "zone": "America/Los_Angeles"},
    ],
)

# Tray: hide Solaar's icon (it keeps running for the Logitech devices).
ensure("omarchy.tray", "right")
_, _, tray = find("omarchy.tray")
hidden = tray.setdefault("hidden", [])
if "indicator-solaar" not in hidden:
    hidden.append("indicator-solaar")
# Pinned tray icons sit in the bar instead of the fold-out drawer.
pinned_tray = tray.setdefault("pinned", [])
if "superwhisper" not in pinned_tray:
    pinned_tray.append("superwhisper")

# Widgets in the "tray" section live inside the fold-out drawer (behind the
# arrow). Move them onto the bar itself, right of the tray, so nothing is
# folded away.
for item in list(layout.get("tray", [])):
    layout["tray"].remove(item)
    right = section("right")
    if not any(it.get("id") == item.get("id") for it in right):
        idx = next((i for i, it in enumerate(right) if it.get("id") == "omarchy.tray"), -1)
        right.insert(idx + 1, item)

# Weather in °C and km/h (the en_US locale would otherwise pick °F).
ensure("omarchy.weather", "centerEnd", unit="metric")

# Dock: Zen is the browser (Chromium stays only as the web-app engine).
pinned = cfg.setdefault("dock", {}).setdefault("pinned", [])
cfg["dock"]["pinned"] = ["zen" if p == "chromium" else p for p in pinned]
# Web apps removed (only WhatsApp kept), so their pins go too.
cfg["dock"]["pinned"] = [p for p in cfg["dock"]["pinned"] if p not in ("X", "YouTube")]
if "zen" not in cfg["dock"]["pinned"]:
    cfg["dock"]["pinned"].insert(1, "zen")

path.write_text(json.dumps(cfg, indent=2) + "\n")
print("shell.json updated")
