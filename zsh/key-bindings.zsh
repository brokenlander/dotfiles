# Key bindings for the zsh prompt (both machines).

# Home / End / Delete
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char

# Italian keyboard: Alt+\ types ~ and Alt+' types `.
# On Omarchy these are desktop-wide Hyprland shortcuts (every app), so they
# are only bound here where Hyprland is not running (the Ubuntu workstation).
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  bindkey -s '\e\\' '~'
  bindkey -s "\e'" '`'
fi
