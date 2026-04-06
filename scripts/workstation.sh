#!/bin/bash
# Workstation-specific setup
# Hardware: RTX 5090, Elgato Wave 3, OBSBOT Tiny 2, ZSA Voyager,
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

# ========== OBSBOT Tiny 2 (Tiny4Linux CLI) ==========
echo "=== OBSBOT Tiny 2 ==="
if command -v t4l &>/dev/null; then
    echo "Tiny4Linux already installed, skipping..."
else
    # Install Rust if needed
    if ! command -v cargo &>/dev/null; then
        echo "Installing Rust (needed for Tiny4Linux)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    sudo apt-get install -y libudev-dev pkg-config
    sudo git clone https://github.com/OpenFoxes/Tiny4Linux.git /tmp/Tiny4Linux
    cd /tmp/Tiny4Linux
    cargo build --release --bin tiny4linux-cli --features="cli"
    sudo cp target/release/tiny4linux-cli /usr/local/bin/
    sudo ln -sf /usr/local/bin/tiny4linux-cli /usr/local/bin/t4l
    sudo rm -rf /tmp/Tiny4Linux
    echo -e "${GREEN}Tiny4Linux installed.${NC} Usage: t4l tracking normal/static, t4l info"
fi

# ========== OBSBOT Control GUI ==========
echo "=== OBSBOT Control GUI ==="
if [ -f "$HOME/.local/bin/obsbot-gui" ]; then
    echo "OBSBOT Control GUI already installed, skipping..."
else
    sudo apt-get install -y qt6-base-dev qt6-multimedia-dev libgl1-mesa-dev
    if [ ! -d "/opt/obsbot-camera-control" ]; then
        sudo git clone https://github.com/aaronsb/obsbot-camera-control.git /opt/obsbot-camera-control
    fi
    cd /opt/obsbot-camera-control
    ./build.sh build --confirm
    ./build.sh install --confirm
    sudo cp sdk/v1.0.2/lib/libdev.so.1.0.2 /usr/lib/
    sudo ln -sf /usr/lib/libdev.so.1.0.2 /usr/lib/libdev.so.1
    sudo ln -sf /usr/lib/libdev.so.1.0.2 /usr/lib/libdev.so
    sudo ldconfig

    # Desktop icon — KDE needs absolute PNG path + matching StartupWMClass
    mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
    rsvg-convert -w 256 -h 256 /opt/obsbot-camera-control/resources/icons/camera.svg \
        > "$HOME/.local/share/icons/hicolor/256x256/apps/obsbot-gui.png"
    cat > "$HOME/.local/share/applications/obsbot-gui.desktop" << DESKTOP
[Desktop Entry]
Name=OBSBOT Control
Comment=Control OBSBOT camera settings
Exec=env QT_MEDIA_BACKEND=ffmpeg $HOME/.local/bin/obsbot-gui
Icon=$HOME/.local/share/icons/hicolor/256x256/apps/obsbot-gui.png
Terminal=false
Type=Application
Categories=Video;AudioVideo;Utility;
Keywords=camera;obsbot;webcam;
StartupWMClass=obsbot-gui
DESKTOP
    update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
    echo -e "${GREEN}OBSBOT Control GUI installed.${NC}"
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
