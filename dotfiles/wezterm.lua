local wezterm = require("wezterm")

-- integration with zen-mode.nvim, see https://github.com/folke/zen-mode.nvim/blob/main/README.md#wezterm
wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

return {
	front_end = "WebGpu", -- https://github.com/wez/wezterm/issues/5990#issuecomment-2305416553
	hide_mouse_cursor_when_typing = false,
	hide_tab_bar_if_only_one_tab = true,
	color_scheme = "GruvboxDarkHard",
	colors = {
		background = "#1e1e1e", -- from vim's colorscheme
	},
	-- font = wezterm.font('JetBrains Mono Nerd Font'),
	default_prog = { "fish" },
	keys = {
		{
			mods = "CTRL",
			key = "'",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			mods = "CTRL",
			key = "/",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
	},
}
