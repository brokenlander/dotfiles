# dotfiles

Personal configuration for Linux (Ubuntu/Debian). Three tiers: server (any box), desktop (Kubuntu), and workstation (this specific machine).

## Fresh Install

### 1. Pre-install

Do a **minimal install** of Kubuntu (or a fresh Omarchy), then clone and run the pre-install (passwordless sudo, `~/forge`):

```bash
git clone https://github.com/brokenlander/dotfiles.git ~/dotfiles
~/dotfiles/scripts/pre-install.sh   # passwordless sudo + ~/forge
```

### 2. Server + Desktop

```bash
cd ~/dotfiles
./scripts/install-dependencies.sh
# restart shell
./scripts/install.sh
```

This installs and configures everything portable: CLI tools, ZSH, Neovim, Tmux, Docker, Git, Starship, foot, Kate, KDE settings, fonts, Zen Browser, Discord, Bitwarden, Obsidian, LocalSend, OnlyOffice, Spotify, Steam, Krohnkite, and more. Desktop packages are auto-skipped on headless servers.

### 3. Workstation (this machine only)

```bash
./scripts/workstation.sh
```

Hardware-specific setup for the primary rig:
- NVIDIA open driver, latest branch (RTX 5090) + Secure Boot MOK enrollment
- Display: 1440p @ 120Hz, 1.5x scale
- Disable sleep/suspend (always-on)
- OpenLinkHub (Corsair iCUE alternative)
- Keymapp + udev rules (ZSA Voyager keyboard)
- Elgato Wave 3 WirePlumber fix (mic silence bug)
- CUDA toolkit 13.1

Voice services (ASR/TTS) are managed separately — see `~/forge/voice/README.md`.

### 4. Post-install (manual)

> **Tokens expired later?** If `git push` hangs or OneDrive throws
> `AADSTS70000`, it's a dead OAuth token, not a broken config. Run
> `./scripts/reauth.sh` — it refreshes gh and/or OneDrive and pushes any
> waiting dotfiles commits. Note: KDE Wallet is disabled on this box, so gh
> can't keep its token in the keyring — git uses the `store` helper
> (`~/.git-credentials`, chmod 600) instead.

```bash
# GitHub CLI
gh auth login

# OneDrive — interactive login (browser), then configure + first sync (see notes below)
onedrive                             # authorise in browser, paste redirect URI back
onedrive --sync --resync

# Timeshift — first snapshot
sudo timeshift-gtk
```

#### OneDrive on a large account

The `abraunegg` client crawls the **entire** remote tree before downloading, so a
huge folder you *don't* want (e.g. a multi-hundred-GB photo archive) makes the
first sync appear to hang. Two lessons:

- **`skip_dir` beats `sync_list` for excluding big folders.** `sync_list` still
  crawls everything and filters; `skip_dir` never even looks inside. In
  `~/.config/onedrive/config` (config is per-machine, never committed — it holds
  personal paths, and `refresh_token` next to it is a secret):

  ```
  sync_dir = "~/OneDrive"
  skip_dir = "BigArchive|SomeFolder/BigSubdir"   # example names
  ```
  Changing `skip_dir`/`sync_list` requires `onedrive --sync --resync`.

- **Grab one folder fast** without crawling siblings:
  `onedrive --single-directory 'Folder/Subfolder' --sync`

- **Automatic background sync** — enable the bundled user service (and linger so
  it runs while logged out):

  ```bash
  systemctl --user enable --now onedrive
  sudo loginctl enable-linger "$USER"
  ```

### 5. UI tweaks (can't be scripted)

- **Panel height** — right-click panel > Edit Mode > drag top edge to ~36px
- **Krohnkite** — System Settings > Window Management > KWin Scripts > Krohnkite gear icon (gaps, float rules, layouts). Reboot after.
- **OBS Studio** — first launch wizard: optimize for recording, 2560x1440 base, 1920x1080 output, Lanczos, 30fps, NVENC, Screen Capture (PipeWire)

---

## Omarchy (laptop)

Same repo, same shared configs; `omarchy/install.sh` replaces steps 2–3.

```bash
git clone https://github.com/brokenlander/dotfiles.git ~/dotfiles
~/dotfiles/scripts/pre-install.sh   # passwordless sudo + ~/forge
~/dotfiles/omarchy/install.sh       # theme, packages, symlinks (safe to re-run)
```

It sets the Ristretto theme, installs Zen (default browser) and the OneDrive
client, and links: foot, starship, git (`~/.config/git/`), shared aliases
(sourced from `~/.bashrc`), the nvim start page, Hyprland look'n'feel, and the
OneDrive config. Terminals run zsh with the same shared config as Ubuntu
(`zsh/zshrc`); bash stays the login shell because Omarchy's session expects it.

Manual afterwards:
- `gh auth login` (git uses `gh` via `~/.gitconfig.local`)
- Zen: sign into the Mozilla account
- Lid: closing it only turns the screen off; still closed after 5 min the laptop suspends
  (opening the lid wakes it, no lock); after 2 h suspended it hibernates (fully off:
  press power, then the disk password). With an external monitor it never sleeps.
  Don't put it in a bag closed for under 5 min. Nothing ever locks automatically.
- Battery: charges to 80% and only restarts below 50% (longer battery life). For a long
  day unplugged: `echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold`
  (back to 80 at the next boot).
- Steam (UI only, once): Settings → Compatibility → turn on **"Enable Steam Play for all
  other titles"** and pick the latest Proton, so Windows-only games run. Per game, for the
  overlay and performance mode: Properties → Launch options `gamemoderun mangohud %command%`.
- Web apps: only WhatsApp is kept. Some Omarchy installers add one back
  (Tailscale adds its admin page); run `~/dotfiles/omarchy/remove-webapps.sh` afterwards.
- OneDrive: `onedrive` (log in). The config skips only the top-level `Foto`
  folder (~534 GB), but a full sync still has to LIST every item in the drive
  first (photos included), which takes hours. So get the working folder first:
  ```bash
  onedrive --sync --single-directory 'Struttura' --resync --resync-auth   # minutes
  onedrive --sync --resync --resync-auth                                  # full, leave overnight
  ```

### Omarchy apps: what stays and what goes

Decided one by one on the laptop (Nov 2026). `omarchy/install.sh` applies it.

**Kept**
- **Obsidian**: Markdown notes; vault in `~/OneDrive/Documents/Notes` (also on Ubuntu)
- **Pinta**: simple image editor, handy now and then (also on Ubuntu)
- **LocalSend**: AirDrop-style file sharing with the phone (also on Ubuntu)
- **Evince**: PDF viewer
- **Signed**: sign and fill in PDFs
- **Disks** (gnome-disk-utility): format USB sticks, check drives
- **Sushi**: Space-bar file preview in Files
- **Moonlight**: game / desktop streaming client; Sunshine is the host on the workstation
- **Disk Tree**: disk usage map
- **Gliff**: Hyprland-to-Hyprland remote desktop over SSH (for an Omarchy workstation)
- **Omasnap**: screenshots + annotation (the Print key)
- **Omacalc**: calculator
- **Docker** (+ compose, buildx, ufw-docker): containers, as on Ubuntu
- **MariaDB / PostgreSQL client libraries, python-poetry-core**: small build dependencies; removing them only causes confusing build errors later
- **amd-ucode**: does nothing on this Intel laptop, kept so the setup works on AMD machines too
- **tzupdate**: set the timezone from location when travelling
- **vi**: tiny fallback editor for system tools and recovery (`vi`/`vim` open nvim anyway)
- **OCR + QR tools** (tesseract, zbar, qrencode): copy text from the screen, scan/show QR codes
- **WhatsApp** web app: the only web app kept (no native Linux app)

**Removed**
- **LibreOffice**: replaced by OnlyOffice (better with Office files, looks better; same as Ubuntu)
- **Aether**: theme maker; settled on Ristretto
- **cliamp**: terminal music player; mpv plays music and shows in the bar's media widget
- **Hype**: Markdown slide presentations; not needed
- **Monologue**: webcam recorder; calls and the screen recorder cover it
- **Omacut**: video trimmer; an agent can trim with ffmpeg
- **Omawrite**: Markdown writing app; Obsidian covers it
- **ttfx**: screensaver text effects; the screensaver is off
- **OWE**: video wallpaper engine; no video wallpapers, login intro turned off
- **Asian input methods** (Chinese, Japanese, Korean fcitx5 engines): not needed; fcitx5 itself stays
- **asdcontrol**: brightness for Apple displays; none here
- **herdr**: Omarchy's agent workspace manager; replaced by our own tmux + agent-sidebar stack (shortcuts, `h` alias and `hd*` functions dropped too)
- **All other web apps** (X, YouTube, Basecamp, HEY, Zoom, Discord, Google Maps/Contacts/Messages/Photos) and their shortcuts, plus the Signal, cliamp and Omawrite keys

**Added**
- **OnlyOffice**, **Discord** (official app, replaces Vesktop on Ubuntu), **Spotify**, **Bitwarden** (replaces KeePassXC and Zen's saved passwords; `Super+Shift+/`), **OBS Studio**, **Steam** (Omarchy's gaming installer, with 32-bit GPU libraries), **Xbox controller driver** (xpadneo, pair with `Super+Ctrl+B`), **MangoHud + Gamemode** (per game in Steam: launch options `gamemoderun mangohud %command%`), **lazydocker** (`Super+Shift+D`), CLI tools **dust, duf, glow, rclone, gping** (as on Ubuntu)

## What's Included

### Server (any Linux box)

| Category | Tools |
|----------|-------|
| Shell | ZSH + Starship prompt |
| Editor | Neovim (stock LazyVim) |
| Multiplexer | Tmux (theme colours, session persistence, agent-sidebar + agent keys) |
| Git | Identity per remote (personal / work), rebase pulls, aliases, commit guards |
| CLI tools | bat, eza, fd, ripgrep, zoxide, delta, dust, btop, tldr, duf, difftastic |
| Dev tools | lazygit, lazydocker, fzf, gh CLI, kubectl, k9s |
| Runtimes | mise (Node.js and other versions, per-folder env), uv (Python), micromamba (conda, workstation), pipx |
| Containers | Docker, Docker Compose |

### Desktop (Kubuntu)

| Tool | Purpose |
|------|---------|
| foot | Fast Wayland terminal (Ristretto; right-click paste, copy on select) |
| Kate | Text editor (Tokyo Night theme) |
| KDE | Breeze Dark, Papirus-Dark icons, Bibata-Modern-Ice cursor |
| Krohnkite | Dynamic tiling for KWin |
| JetBrains Mono Nerd Font | Terminal/editor font |
| OnlyOffice | Office suite |
| Discord | Chat (official app) |
| Obsidian | Notes (vault in OneDrive) |
| LocalSend | File sharing with the phone |
| Pinta | Simple image editor |
| Haruna | Video player |
| Bitwarden | Password manager |
| Spotify | Music |
| FreeRDP 3.33 (SDL3 client) | RDP, built from source with H.264 into `/opt/freerdp` by `scripts/build-freerdp.sh`. Ubuntu's FreeRDP has no H.264 and its X11/Wayland clients are legacy/deprecated; don't install Ubuntu's `freerdp-*` client packages. Bump `FREERDP_VERSION` to upgrade. |

### Workstation (this machine)

| Component | What |
|-----------|------|
| GPU | NVIDIA RTX 5090 (driver open, latest — currently 620, CUDA 13.1) |
| Mic | Elgato Wave 3 (WirePlumber always-process fix) |
| Camera | Logitech UVC webcam (cameractrls GUI for settings) |
| Keyboard | ZSA Voyager (Keymapp + udev rules) |
| Cooling | Corsair (OpenLinkHub) |
| Gaming | Steam, MangoHud, Gamemode, ProtonUp-Qt |

## Zen

Everything syncs through **Firefox Sync** (sign into the Mozilla account): bookmarks,
passwords, history, tabs, workspaces and essentials. `zen/user.js` opts Zen's own
appearance and behaviour prefs into Firefox Sync too (theme/accent, compact mode,
sidebar, tab behaviour), and sets two local fixes: no default-browser prompt, and no
password saving (Bitwarden). The installers copy it into the profile with
`scripts/zen-userjs.sh`. Custom shortcuts and mods are not synced.

## Structure

```
dotfiles/
├── nvim/           # Neovim (Lazy.nvim, LSP, plugins)
├── zsh/            # Shared zshrc, key bindings, integrations
├── shell/          # Aliases + env shared by zsh/bash, Omarchy compat for Ubuntu
├── tmux/           # Tmux base config + agent layer (agents.conf)
├── git/            # config, ignore, work.gitconfig (linked into ~/.config/git/)
├── git-hooks/      # Global git hooks (block AI references in commits)
├── foot/           # foot terminal config (shared) + Ubuntu theme
├── kate/           # Kate editor theme
├── starship/       # Starship prompt config
├── btop/           # System monitor config + theme
├── cava/           # Audio visualizer config
├── fastfetch/      # System info display config
├── mangohud/       # Game overlay config
└── scripts/
    ├── install-dependencies.sh  # Server + Desktop packages
    ├── build-freerdp.sh         # FreeRDP 3 from source with H.264, SDL3 client (desktop; called by install-dependencies)
    ├── install.sh               # Symlinks + configs
    ├── workstation.sh           # Hardware-specific setup
    ├── zen-userjs.sh            # Zen: install zen/user.js into the profile
    └── uninstall.sh             # Restore original configs
```

## Key Bindings

### Neovim
- **Leader**: Space
- `gd` definition, `gR` references, `<leader>ca` code action, `<leader>rn` rename
- `Tab`/`Shift+Tab` switch buffers
- `<leader>ee` file explorer, `<leader>ff` find files

### Tmux
- **Prefix**: Ctrl+B
- `|` / `-` split panes
- `Alt+h/j/k/l` switch panes (no prefix)
- `Prefix+Ctrl+s` save session, `Prefix+Ctrl+r` restore
- `Prefix+y` session picker (sesh), `Prefix+d` scratch popup, `Prefix+R` reload config
- Agents (tmux/agents.conf): `Prefix+e` sidebar, `Prefix+u` agent picker, `Prefix+a` new agent,
  `Prefix+q` end, `Prefix+r` reset, `Prefix+o` reopen, `Prefix+B` branch, `Prefix+b` board
- Copy goes to the system clipboard (OSC 52); right-click pastes it (wl-paste)

Base config (`tmux/.tmux.conf`) works anywhere; the agent layer loads only when
`~/forge/agent-sidebar` and `~/dotfiles/bin/pm-agent` exist. `scripts/agents-setup.sh`
installs agent-sidebar, tmux-resurrect (no TPM) and the Claude Code hooks on both machines.

### ZSH
- `Ctrl+R` fuzzy history (fzf)
- `Ctrl+T` fuzzy file search
- `Alt+C` fuzzy cd
- `→` accept the grey autosuggestion
- `Alt+\` types `~`, `Alt+'` types `` ` `` (Italian keyboard). On Omarchy these
  work in every app (Hyprland); on Ubuntu, at the zsh prompt.

Machine-only zsh lines go in `~/.zshrc.local` (sourced by the shared `~/.zshrc`).

## Uninstall

```bash
./scripts/uninstall.sh
```

Restores original configs from backup.
