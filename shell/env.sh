# Shared interactive shell setup (bash on Omarchy, zsh on Ubuntu).
case $- in *i*) ;; *) return ;; esac

# Personal tools, the agent tools (agent-sidebar repo), Go-installed tools (sesh, ...)
for d in "$HOME/dotfiles/bin" "$HOME/forge/agent-sidebar/bin" "$HOME/go/bin"; do
  case ":$PATH:" in *":$d:"*) ;; *) [ -d "$d" ] && PATH="$d:$PATH" ;; esac
done
export PATH

# fzf: fd for file/dir search (Ubuntu calls it fdfind), reverse layout with a border
_fd=$(command -v fd || command -v fdfind || true)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
if [ -n "$_fd" ]; then
  export FZF_DEFAULT_COMMAND="$_fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$_fd --type d --hidden --follow --exclude .git"
fi
unset _fd

# New terminals opened in ~ start in ~/forge (not inside nvim's terminal)
if [ "$PWD" = "$HOME" ] && [ -z "${NVIM:-}" ] && [ -d "$HOME/forge" ]; then
  builtin cd "$HOME/forge"
fi
