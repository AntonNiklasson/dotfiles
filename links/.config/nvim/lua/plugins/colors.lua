return {
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
			dim_inactive = true,
		},
	},
	{
		"f-person/auto-dark-mode.nvim",
		opts = {
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
			end,
			update_interval = 1000,
			fallback = "dark",
		},
	},
}
