# Omarchy's aliases and env for machines WITHOUT Omarchy (the Ubuntu workstation),
# so the prompt behaves the same everywhere. On Omarchy, zshrc loads the real
# files from $OMARCHY_PATH/default/bash instead, and this file is not used.
# Mirrors: /usr/share/omarchy/default/bash/{aliases,envs} (Omarchy 4.5).
case $- in *i*) ;; *) return ;; esac

# Ubuntu package names for bat and fd
command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd='fdfind'
_bat=$(command -v bat || command -v batcat || echo cat)

# Env
export EDITOR="${EDITOR:-nvim}"
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | $_bat -l man -p'"

# File system
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi
alias ff="fzf --preview '$_bat --style=numbers --color=always {}'"
alias eff='$EDITOR "$(ff)"'
if command -v zoxide >/dev/null 2>&1; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ || return
    elif [ -d "$1" ]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi
      printf "\U000F17A9 "
      pwd
    fi
  }
fi
open() ( xdg-open "$@" >/dev/null 2>&1 & )
unset _bat

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode auto'
alias d='docker'
alias t='tmux attach || tmux new -s Work'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { if [ "$#" -eq 0 ]; then command nvim . ; else command nvim "$@"; fi; }

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
