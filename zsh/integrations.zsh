# Shell Integrations for Enhanced Tools
# ======================================

# Terminal Color Support - Enable truecolor (24-bit) support
export COLORTERM=truecolor

# fnm - Fast Node Manager
export PATH="$HOME/.local/share/fnm:$PATH"
if command -v fnm &> /dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# FZF - Fuzzy Finder Keybindings
# Ctrl+R: Search command history
# Ctrl+T: Search files in current directory
# Alt+C: Change directory
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# FZF - Completion
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# FZF - Custom options
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'

# Direnv - Automatically load/unload environment variables
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Micromamba - Lightweight conda package manager
if [ -f "$HOME/.local/bin/micromamba" ]; then
    export MAMBA_ROOT_PREFIX="$HOME/micromamba"
    export MAMBA_EXE="$HOME/.local/bin/micromamba"
    eval "$("$MAMBA_EXE" shell hook --shell zsh)"
fi

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi
