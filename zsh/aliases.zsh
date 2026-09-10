# Aliases are for humans at a prompt. A non-interactive shell — a script, cron,
# a coding agent's tool call — must get plain coreutils: `du -sh`, `cat -A` and
# `ls -la` there mean the POSIX flags, not dust/bat/eza's, and the mismatch
# fails in confusing ways (dust printing its own help for `du -sh`, say).
# Interactive shells are untouched by this.
[[ -o interactive ]] || return

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
alias cldc='claude --dangerously-skip-permissions --continue'
alias cldd='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official'
alias clddc='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official --continue'
