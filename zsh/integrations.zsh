# Tool integrations for zsh (both machines). Every tool is optional.

export COLORTERM=truecolor
export _ZO_DOCTOR=0   # zoxide nags in subshells otherwise

# mise: language versions (node, python, ...) and per-folder env; replaces fnm + direnv
command -v mise >/dev/null && eval "$(mise activate zsh)"

# micromamba: conda packages, workstation only (CUDA / ML)
if [ -x "$HOME/.local/bin/micromamba" ]; then
  export MAMBA_ROOT_PREFIX="$HOME/micromamba"
  export MAMBA_EXE="$HOME/.local/bin/micromamba"
  eval "$("$MAMBA_EXE" shell hook --shell zsh)"
fi

# MangoHud overlay for games, where installed (workstation)
if command -v mangohud >/dev/null && [ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]; then
  export MANGOHUD=1
fi

# fzf: Ctrl+R history, Ctrl+T files, Alt+C directories
if fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# try (Omarchy's experiment folders), loaded on first use like Omarchy's bash does
if command -v try >/dev/null; then
  try() {
    unfunction try
    eval "$(SHELL=zsh command try init ~/Work/tries)"
    try "$@"
  }
fi

# Prompt
command -v starship >/dev/null && eval "$(starship init zsh)"
