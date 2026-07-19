#!/bin/bash
# ceres — machine-specific setup for the AMD desktop
# Hardware: AMD Ryzen 5 5600, Radeon RX 5700 XT (Navi 10, amdgpu), Gigabyte X470
# KDE Plasma on Wayland. This is the AMD counterpart to workstation.sh (NVIDIA rig).
# Only run this on `ceres` — not on servers or the NVIDIA workstation.

set +e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$(id -u)" -eq 0 ]; then echo "Don't run this as root — user configs/systemd units will break."; exit 1; fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USER_NAME="$(id -un)"

echo "=== ceres (AMD desktop) setup ==="
echo ""

# ========== Gaming (Steam, MangoHud, Gamemode, ProtonUp-Qt) ==========
echo "=== Gaming packages ==="
# Steam + many games need 32-bit (i386) Vulkan/Mesa libs.
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y \
    steam-installer mangohud gamemode \
    mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
    libvulkan1 libvulkan1:i386 vulkan-tools \
    libgl1-mesa-dri:i386

if [ ! -f /usr/local/bin/protonup-qt ]; then
    echo "=== Installing ProtonUp-Qt ==="
    PROTONUP_URL=$(curl -s https://api.github.com/repos/DavidoTek/ProtonUp-Qt/releases/latest | command grep -o 'https://.*AppImage"' | tr -d '"')
    if [ -n "$PROTONUP_URL" ]; then
        wget -O /tmp/protonup-qt.AppImage "$PROTONUP_URL"
        sudo mv /tmp/protonup-qt.AppImage /usr/local/bin/protonup-qt
        sudo chmod +x /usr/local/bin/protonup-qt
    else
        echo -e "${YELLOW}Could not resolve ProtonUp-Qt release URL; skipping.${NC}"
    fi
fi

# MangoHud config (shared asset from the repo)
if [ -f "$DOTFILES/mangohud/MangoHud.conf" ]; then
    mkdir -p "$HOME/.config/MangoHud"
    ln -sf "$DOTFILES/mangohud/MangoHud.conf" "$HOME/.config/MangoHud/MangoHud.conf"
    echo -e "${GREEN}MangoHud config linked.${NC}"
fi

# Steam web-helper GPU fix (Navi 10 / RX 5700 XT)
# steamwebhelper's GPU-accelerated CEF UI hangs the amdgpu gfx ring
# ("ring gfx_0.0.0 timeout" -> "device wedged"), which looks like the screen
# briefly sleeping. Launch Steam with -cef-disable-gpu. Games are unaffected.
echo "=== Steam CEF GPU fix ==="
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
cat > "$HOME/.local/bin/steam" << 'EOF'
#!/bin/bash
# Navi 10 fix: disable GPU in Steam's CEF web helper to stop gfx-ring hangs.
exec /usr/games/steam -cef-disable-gpu "$@"
EOF
chmod +x "$HOME/.local/bin/steam"
cat > "$HOME/.local/share/applications/steam.desktop" << EOF
[Desktop Entry]
Version=1.0
Categories=Game;Network;
Exec=$HOME/.local/bin/steam %U
Icon=steam
MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
Name=Steam
Terminal=false
Type=Application
Keywords=games;valve;
EOF
update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null
echo -e "${GREEN}Steam set to launch with -cef-disable-gpu.${NC}"

# ========== AMD GPU control (CoreCtrl) ==========
# CoreCtrl = fan curves, power limits, clocks — the AMD answer to OpenLinkHub/iCUE.
echo "=== CoreCtrl ==="
if dpkg -l corectrl 2>/dev/null | command grep -q "^ii"; then
    echo "CoreCtrl already installed, skipping install..."
else
    sudo apt-get install -y corectrl
fi

# Polkit rule so CoreCtrl doesn't prompt for a password every launch.
POLKIT_RULE="/etc/polkit-1/rules.d/90-corectrl.rules"
if [ ! -f "$POLKIT_RULE" ]; then
    sudo tee "$POLKIT_RULE" > /dev/null << RULE
polkit.addRule(function(action, subject) {
    if ((action.id == "org.corectrl.helper.init" ||
         action.id == "org.corectrl.helperkiller.init") &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("$USER_NAME")) {
            return polkit.Result.YES;
    }
});
RULE
    echo -e "${GREEN}CoreCtrl polkit rule installed.${NC}"
fi

# Optional: amdgpu.ppfeaturemask unlocks CoreCtrl's MANUAL fan/clock/voltage/power
# control. OFF by default — on Navi 10 (RX 5700 XT) it can worsen GPU stability, and
# automatic fan control is fine (CoreCtrl still monitors without it). Enable only if
# you want custom fan curves:  CERES_ENABLE_PPFEATUREMASK=1 ./scripts/ceres.sh
if [ "${CERES_ENABLE_PPFEATUREMASK:-0}" = "1" ]; then
    if ! grep -q 'amdgpu.ppfeaturemask' /etc/default/grub; then
        echo "=== Enabling amdgpu.ppfeaturemask (GRUB) ==="
        sudo cp /etc/default/grub /etc/default/grub.bak.ceres
        # 26.04 defaults to single quotes on this line; older releases use double. Handle both.
        if grep -q 'GRUB_CMDLINE_LINUX_DEFAULT="' /etc/default/grub; then
            sudo sed -i 's/\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 amdgpu.ppfeaturemask=0xffffffff"/' /etc/default/grub
        else
            sudo sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT='[^']*\)'/\1 amdgpu.ppfeaturemask=0xffffffff'/" /etc/default/grub
        fi
        grep -q 'amdgpu.ppfeaturemask' /etc/default/grub && sudo update-grub
        echo -e "${YELLOW}amdgpu.ppfeaturemask enabled — reboot required.${NC}"
    else
        echo "amdgpu.ppfeaturemask already set, skipping."
    fi
else
    echo "Skipping amdgpu.ppfeaturemask (default; safer on Navi 10). Set CERES_ENABLE_PPFEATUREMASK=1 to unlock CoreCtrl manual fan/clock control."
fi

# Autostart CoreCtrl minimized to tray so fan/power profiles apply on login.
CORECTRL_AUTOSTART="$HOME/.config/autostart/org.corectrl.corectrl.desktop"
if [ ! -f "$CORECTRL_AUTOSTART" ] && [ -f /usr/share/applications/org.corectrl.corectrl.desktop ]; then
    mkdir -p "$HOME/.config/autostart"
    cp /usr/share/applications/org.corectrl.corectrl.desktop "$CORECTRL_AUTOSTART"
    echo "Exec=corectrl --minimize-systray" >> "$CORECTRL_AUTOSTART"
    echo -e "${GREEN}CoreCtrl set to autostart minimized.${NC}"
fi

# ========== Disable sleep/suspend (always-on desktop) ==========
echo "=== Disabling sleep/suspend ==="
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# ========== Disable screen autolock + idle blanking ==========
# Only manual lock (Meta+L). Config-only; re-applies on next Plasma login.
echo "=== Disabling screen autolock ==="
mkdir -p "$HOME/.config"
KSL="$HOME/.config/kscreenlockerrc"
kwriteconfig6 --file "$KSL" --group Daemon --key Autolock false
kwriteconfig6 --file "$KSL" --group Daemon --key LockOnResume false
PDV="$HOME/.config/powerdevilrc"
for action in DimDisplay DPMSControl SuspendSession TurnOffDisplay; do
    kwriteconfig6 --file "$PDV" --group AC --group "$action" --key idleTime ""
    kwriteconfig6 --file "$PDV" --group AC --group "$action" --key UseProfileDefaults false
done
qdbus6 org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.reloadConfig 2>/dev/null || true
qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement refreshStatus 2>/dev/null || true
echo -e "${GREEN}Screen autolock disabled.${NC}"

# ========== Wallpaper ==========
# plasma-apply-wallpaperimage needs a running Plasma session — no-op from a tty.
echo "=== Wallpaper ==="
if [ -f "$DOTFILES/wallpaper/wallpaper.png" ]; then
    if command -v plasma-apply-wallpaperimage &>/dev/null && \
       plasma-apply-wallpaperimage "$DOTFILES/wallpaper/wallpaper.png" 2>/dev/null; then
        echo -e "${GREEN}Wallpaper applied.${NC}"
    else
        echo -e "${YELLOW}Not in a Plasma session — re-run this from the desktop, or:${NC}"
        echo "  plasma-apply-wallpaperimage $DOTFILES/wallpaper/wallpaper.png"
    fi
fi

echo ""
echo -e "${GREEN}=== ceres setup complete! ===${NC}"
echo ""
echo "Manual steps remaining:"
echo "  - Reboot (for amdgpu.ppfeaturemask → CoreCtrl fan/clock control)"
echo "  - Log out/in once so mangohud & i386 libs are picked up"
echo "  - In Steam: enable Steam Play (Proton) for all titles; pick a Proton-GE build via protonup-qt"
