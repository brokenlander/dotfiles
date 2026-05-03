#!/bin/bash
# Workstation-specific setup
# Hardware: RTX 5090, Elgato Wave 3, Logitech webcam, ZSA Voyager,
#           Corsair cooling (OpenLinkHub), 1440p 120Hz monitor
# Only run this on the primary workstation — not on laptops or servers.

set +e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$(id -u)" -eq 0 ]; then echo "Don't run this as root — systemd units will break."; exit 1; fi
if ! command -v uv &>/dev/null; then echo "ERROR: Run install-dependencies.sh first."; exit 1; fi

echo "=== Workstation Setup ==="
echo "This script installs hardware-specific drivers and tools."
echo ""

# ========== NVIDIA Driver ==========
echo "=== NVIDIA Driver ==="
if dpkg -l nvidia-driver-590-open 2>/dev/null | command grep -q "^ii"; then
    echo "NVIDIA driver 590 already installed, skipping..."
else
    sudo apt-get update
    sudo apt-get install -y nvidia-driver-590-open
    echo -e "${YELLOW}NVIDIA driver installed. Reboot required.${NC}"

    # Secure Boot: enroll MOK key
    if mokutil --sb-state 2>/dev/null | command grep -q "SecureBoot enabled"; then
        sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
        echo -e "${YELLOW}MOK key enrolled. After reboot:${NC}"
        echo "  Blue MOK screen > Enroll MOK > Continue > Yes > enter password > Reboot"
    fi
fi

# ========== Display Settings ==========
echo "=== Display Settings ==="
kscreen-doctor output.1.scale.1.5 || echo "WARNING: Could not set 1.5x scale."
kscreen-doctor output.1.mode.10 || echo "WARNING: Could not set 120Hz."

# ========== Disable Sleep/Suspend ==========
echo "=== Disabling sleep/suspend (always-on workstation) ==="
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# ========== OpenLinkHub (Corsair cooling) ==========
echo "=== OpenLinkHub ==="
if command -v OpenLinkHub &>/dev/null || dpkg -l openlinkhub 2>/dev/null | command grep -q "^ii"; then
    echo "OpenLinkHub already installed, skipping..."
else
    OLH_VERSION="0.8.1"
    wget -O /tmp/OpenLinkHub.deb "https://github.com/jurkovic-nikola/OpenLinkHub/releases/download/${OLH_VERSION}/OpenLinkHub_${OLH_VERSION}_amd64.deb"
    sudo dpkg -i /tmp/OpenLinkHub.deb
    sudo apt-get install -f -y
    echo -e "${GREEN}OpenLinkHub installed.${NC} Web UI: http://127.0.0.1:27003/"
fi

# ========== Keymapp (ZSA keyboard firmware) ==========
echo "=== Keymapp ==="
if [ -f /opt/keymapp/keymapp ]; then
    echo "Keymapp already installed, skipping..."
else
    wget -O /tmp/keymapp.tar.gz "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz"
    sudo mkdir -p /opt/keymapp
    sudo tar -xzf /tmp/keymapp.tar.gz -C /opt/keymapp/
    sudo ln -sf /opt/keymapp/keymapp /usr/local/bin/keymapp
fi
# ZSA udev rules
if [ ! -f /etc/udev/rules.d/50-zsa.rules ]; then
    sudo bash -c 'cat > /etc/udev/rules.d/50-zsa.rules << UDEV
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="0791", GROUP="plugdev"
UDEV'
    sudo udevadm control --reload-rules
fi
sudo usermod -aG plugdev "$USER"

# ========== Elgato Wave 3 (WirePlumber fix) ==========
echo "=== Elgato Wave 3 mic fix ==="
WAVE3_CONF="$HOME/.config/wireplumber/wireplumber.conf.d/51-wave3.conf"
if [ -f "$WAVE3_CONF" ]; then
    echo "Wave 3 WirePlumber config already exists, skipping..."
else
    mkdir -p "$(dirname "$WAVE3_CONF")"
    cat > "$WAVE3_CONF" << 'EOF'
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "~alsa_input.usb-Elgato_Systems_Elgato_Wave_3_*"
      }
    ]
    actions = {
      update-props = {
        node.always-process = true
      }
    }
  }
]
EOF
    systemctl restart --user wireplumber 2>/dev/null || true
    echo -e "${GREEN}Wave 3 WirePlumber fix applied.${NC}"
fi

# ========== Block Chromium/Electron WebRTC mic auto-gain ==========
# Vesktop/Discord/Slack/Teams' Chromium WebRTC AGC reaches into the
# ALSA hardware mixer and ducks the mic, ignoring the in-app toggle
# (Vesktop bug Vencord/Vesktop#161). The pipewire-pulse `block-source-volume`
# quirk drops volume-change requests only — capture still works.
echo "=== Block Chromium mic auto-gain ==="
PULSE_QUIRK_CONF="$HOME/.config/pipewire/pipewire-pulse.conf.d/10-block-mic-volume.conf"
if [ -f "$PULSE_QUIRK_CONF" ]; then
    echo "Mic auto-adjust quirk already configured, skipping..."
else
    mkdir -p "$(dirname "$PULSE_QUIRK_CONF")"
    cat > "$PULSE_QUIRK_CONF" << 'EOF'
pulse.rules = [
    {
        matches = [ { application.name = "~Chromium.*" } ]
        actions = { quirks = [ block-source-volume ] }
    }
    {
        matches = [
            { application.process.binary = "vesktop" }
            { application.process.binary = "Discord" }
            { application.process.binary = "discord" }
            { application.process.binary = "slack" }
            { application.process.binary = "teams-for-linux" }
        ]
        actions = { quirks = [ block-source-volume ] }
    }
]
EOF
    systemctl --user restart pipewire-pulse 2>/dev/null || true
    echo -e "${GREEN}Mic auto-adjust quirk applied.${NC}"
fi

# ========== Logitech webcam (cameractrls — Linux camera GUI) ==========
echo "=== cameractrls ==="
if [ -L "$HOME/.local/bin/cameractrls" ]; then
    echo "cameractrls already installed, skipping..."
else
    sudo apt-get install -y v4l-utils python3-gi gir1.2-gtk-4.0 || \
        sudo apt-get install -y v4l-utils python3-gi gir1.2-gtk-3.0
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share" \
             "$HOME/.local/share/applications" \
             "$HOME/.local/share/icons/hicolor/scalable/apps"
    git clone --depth 1 https://github.com/soyersoyer/cameractrls.git \
        "$HOME/.local/share/cameractrls"
    ln -sf "$HOME/.local/share/cameractrls/cameractrls.py" "$HOME/.local/bin/cameractrls"
    # Prefer GTK4 frontend, fall back to GTK3 if gir1.2-gtk-4.0 isn't available
    if dpkg -s gir1.2-gtk-4.0 &>/dev/null; then
        ln -sf "$HOME/.local/share/cameractrls/cameractrlsgtk4.py" "$HOME/.local/bin/cameractrls-gtk"
    else
        ln -sf "$HOME/.local/share/cameractrls/cameractrlsgtk.py" "$HOME/.local/bin/cameractrls-gtk"
    fi
    cp "$HOME/.local/share/cameractrls/pkg/hu.irl.cameractrls.svg" \
       "$HOME/.local/share/icons/hicolor/scalable/apps/cameractrls.svg"
    cat > "$HOME/.local/share/applications/cameractrls.desktop" << DESKTOP
[Desktop Entry]
Name=Cameractrls
Comment=Camera controls for UVC webcams
Exec=$HOME/.local/bin/cameractrls-gtk
Icon=cameractrls
Terminal=false
Type=Application
Categories=Video;AudioVideo;Utility;
Keywords=camera;webcam;v4l2;uvc;
StartupWMClass=cameractrlsgtk
DESKTOP
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
    echo -e "${GREEN}cameractrls installed.${NC}"
fi

# ========== Apply optimal V4L2 settings to Logitech UVC webcam ==========
# Idempotent: re-running just re-asserts the same controls. Logitech
# UVC cams persist these in firmware across reboots.
#   - power_line_frequency=60_hz   anti-flicker for 60Hz mains (Canada/US)
#   - exposure_dynamic_framerate=0 lock 30fps (no slow-shutter drops)
#   - sharpness=100                less haloing than the 128 default
echo "=== Logitech webcam settings ==="
LOGI_CAM=$(v4l2-ctl --list-devices 2>/dev/null \
    | awk '/HD Pro Webcam|BRIO|C922|C925|StreamCam|MX BRIO/{getline; print $1; exit}')
if [ -n "$LOGI_CAM" ] && [ -L "$HOME/.local/bin/cameractrls" ]; then
    PYTHONWARNINGS=ignore "$HOME/.local/bin/cameractrls" -d "$LOGI_CAM" \
        -c power_line_frequency=60_hz,exposure_dynamic_framerate=0,sharpness=100 \
        >/dev/null 2>&1 \
        && echo -e "${GREEN}Camera settings applied to $LOGI_CAM.${NC}" \
        || echo -e "${YELLOW}Camera busy or not ready; rerun later.${NC}"
else
    echo "No Logitech webcam detected; skipping camera settings."
fi

# ========== Gaming (Steam, MangoHud, Gamemode, ProtonUp-Qt) ==========
echo "=== Gaming packages ==="
sudo apt-get install -y steam-installer mangohud gamemode

if [ ! -f /usr/local/bin/protonup-qt ]; then
    echo "=== Installing ProtonUp-Qt ==="
    PROTONUP_URL=$(curl -s https://api.github.com/repos/DavidoTek/ProtonUp-Qt/releases/latest | command grep -o 'https://.*AppImage"' | tr -d '"')
    if [ -n "$PROTONUP_URL" ]; then
        wget -O /tmp/protonup-qt.AppImage "$PROTONUP_URL"
        sudo mv /tmp/protonup-qt.AppImage /usr/local/bin/protonup-qt
        sudo chmod +x /usr/local/bin/protonup-qt
    fi
fi

# ========== MangoHud config ==========
echo "=== MangoHud config ==="
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$DOTFILES/mangohud/MangoHud.conf" ]; then
    mkdir -p "$HOME/.config/MangoHud"
    ln -sf "$DOTFILES/mangohud/MangoHud.conf" "$HOME/.config/MangoHud/MangoHud.conf"
    echo -e "${GREEN}MangoHud config linked.${NC}"
fi

# ========== CUDA Toolkit 13.1 ==========
echo "=== CUDA Toolkit ==="
if dpkg -l cuda-toolkit-13-1 2>/dev/null | command grep -q "^ii"; then
    echo "CUDA toolkit 13.1 already installed, skipping..."
else
    wget -O /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i /tmp/cuda-keyring.deb
    sudo apt-get update
    sudo apt-get install -y cuda-toolkit-13-1
    echo -e "${GREEN}CUDA toolkit 13.1 installed.${NC}"
fi

echo ""
echo -e "${GREEN}=== Workstation setup complete! ===${NC}"
echo ""
echo "Services:"
echo "  OpenLinkHub: localhost:27003"
echo ""
echo "Manual steps remaining:"
echo "  - Reboot (if NVIDIA driver was installed)"
echo "  - MOK enrollment at blue screen (if Secure Boot)"
echo "  - Voice services: see ~/forge/voice/README.md"
echo "  - Sync Zen settings: udisksctl mount -b /dev/nvme0n1p3 && ~/dotfiles/scripts/sync-zen-settings.sh"
