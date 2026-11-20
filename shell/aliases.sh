# Shared aliases (bash on Omarchy, zsh on Ubuntu). Interactive shells only.
case $- in *i*) ;; *) return ;; esac

alias vim='nvim'
alias vi='nvim'
alias lg='lazygit'
alias cdf='cd ~/forge'

# Claude Code
alias cld='claude --dangerously-skip-permissions'
alias cldc='claude --dangerously-skip-permissions --continue'
alias cldd='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official'
alias clddc='claude --dangerously-skip-permissions --channels plugin:discord@claude-plugins-official --continue'

# micromamba only where it exists (workstation)
command -v micromamba >/dev/null 2>&1 && alias mm='micromamba'

# Alt+\ (key left of 1 on the Italian keyboard) types ~ at the prompt.
if [ -n "${BASH_VERSION:-}" ]; then
  bind '"\e\\": "~"'
elif [ -n "${ZSH_VERSION:-}" ]; then
  bindkey -s '\e\\' '~'
fi
