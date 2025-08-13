-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Dracula'
config.default_prog = { "fish" }
config.window_decorations = "TITLE | RESIZE"
config.font_size = 13
config.hide_tab_bar_if_only_one_tab = true

config.keys = {
    -- Copying and pasting
    {
        key = 'c',
        mods = 'CTRL',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(wezterm.action.CopyTo 'ClipboardAndPrimarySelection', pane)

                window:perform_action(wezterm.action.ClearSelection, pane)
            else
                window:perform_action(wezterm.action.SendKey { key = 'c', mods = 'CTRL' }, pane)
            end
        end),
    },
    {
        key = "v",
        mods = "CTRL",
        action = wezterm.action.PasteFrom "Clipboard",
    },
}

-- and finally, return the configuration to wezterm
return config
