# Shared aliases (bash on Omarchy, zsh on Ubuntu). Interactive shells only.
case $- in *i*) ;; *) return ;; esac

alias vim='nvim'
alias vi='nvim'
alias lg='lazygit'
alias cdf='cd ~/forge'
alias top='btop'
alias help='tldr'
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -la'
  alias la='eza -a'
fi

# Claude Code
alias cld='claude --dangerously-skip-permissions'
alias cldc='claude --dangerously-skip-permissions --continue'
alias cldd='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official'
alias clddc='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official --continue'

# micromamba only where it exists (workstation)
command -v micromamba >/dev/null 2>&1 && alias mm='micromamba'
