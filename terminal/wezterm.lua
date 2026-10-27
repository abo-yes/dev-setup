local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font 'JetBrains Mono'
config.font_size = 12.0
config.color_scheme = 'Builtin Solarized Dark'
config.window_padding = {
  left = 10,
  right = 10,
  top = 8,
  bottom = 6,
}
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'

return config
