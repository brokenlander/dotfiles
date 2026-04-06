# Modern CLI Tool Replacements
# ----------------------------------------

# bat (modern cat replacement)
alias bat='batcat --paging=never'
alias cat='batcat --paging=never -pp'

# eza (modern ls replacement)
alias ls='eza'
alias ll='eza -la'
alias la='eza -a'
alias lt='eza -T'  # Tree view

# fd (modern find replacement — don't alias find, it breaks system scripts)
alias fd='fdfind'

# ripgrep (modern grep replacement)
alias grep='rg'

# dust (modern du replacement)
alias du='dust'

# btop (modern top replacement)
alias top='btop'

# zoxide (modern cd replacement)
alias cd='z'

# delta (modern diff replacement)
alias diff='delta'

# tldr (simplified man pages — use 'help' instead of overriding man)
alias help='tldr'

# duf
alias df='duf'

# cd to forge
alias cdf='cd forge'

# micromamba
alias mm='micromamba'

# neovim
alias vim='nvim'

# lazygit
alias lg='lazygit'

# claude code
alias cld='claude --dangerously-skip-permissions'
alias cldd='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official'

# obsbot camera tracking
alias trackon='t4l tracking normal'
alias trackoff='t4l tracking static'
