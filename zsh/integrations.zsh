# Shell Integrations for Enhanced Tools
# ======================================

# Terminal Color Support - Enable truecolor (24-bit) support
# This tells applications like Neovim that the terminal supports 24-bit colors
export COLORTERM=truecolor

# NVM - Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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
# This initializes the shell to properly use 'micromamba activate' commands
if [ -f "$HOME/.local/bin/micromamba" ]; then
    export MAMBA_ROOT_PREFIX="$HOME/micromamba"
    export MAMBA_EXE="$HOME/.local/bin/micromamba"
    eval "$("$MAMBA_EXE" shell hook --shell zsh)"
fi

# Disable git branch in prompt (keep git plugin for aliases)
git_prompt_info() { }
