-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Web-app shortcuts for sites I don't use as web apps (only WhatsApp is kept,
-- Super+Shift+Alt+G). The sites still open normally in Zen.
for _, key in ipairs({
  "SUPER + SHIFT + A",        -- ChatGPT
  "SUPER + SHIFT + ALT + A",  -- Grok
  "SUPER + SHIFT + C",        -- HEY Calendar
  "SUPER + SHIFT + E",        -- HEY Email
  "SUPER + SHIFT + ALT + E",  -- HEY New email
  "SUPER + SHIFT + Y",        -- YouTube
  "SUPER + SHIFT + CTRL + G", -- Google Messages
  "SUPER + SHIFT + P",        -- Google Photos
  "SUPER + SHIFT + S",        -- Google Maps
  "SUPER + SHIFT + X",        -- X
  "SUPER + SHIFT + ALT + X",  -- X Post
}) do
  hl.unbind(key)
end

-- Apps removed in the package unbloat (or never wanted): drop their keys.
hl.unbind("SUPER + SHIFT + G")        -- Signal
hl.unbind("SUPER + SHIFT + ALT + M")  -- cliamp (Music TUI)
hl.unbind("SUPER + SHIFT + W")        -- Omawrite
hl.unbind("SUPER + CTRL + RETURN")     -- herdr (removed; tmux + agent-sidebar instead)
hl.unbind("SUPER + CTRL + K")          -- herdr keybindings

-- Passwords: Bitwarden instead of 1Password (same key as Omarchy's default).
o.rebind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden" })

-- Alt+\ (key left of 1 on the Italian keyboard) types ~ in every app.
-- The Italian layout has no easy tilde (only AltGr+ì). Send exactly AltGr+ì
-- (MOD5 + key code 21) to the focused window, so the held Alt never leaks into
-- it (with wtype, apps saw Alt+~ and bash listed usernames). Same down/up
-- pattern as Omarchy's default/hypr/bindings/jis.lua.
local function send_altgr(code)
  hl.dispatch(hl.dsp.send_key_state({ mods = "MOD5", key = code, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = "MOD5", key = code, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

o.bind("ALT + backslash", "Type tilde", function() send_altgr("code:21") end)

-- Alt+' types ` (backtick), which the Italian layout only has on AltGr+'
-- (key code 20). The zsh versions of both live in zsh/key-bindings.zsh for Ubuntu.
o.bind("ALT + apostrophe", "Type backtick", function() send_altgr("code:20") end)
