return {
	"folke/tokyonight.nvim",
	opts = {
		style = "night",
		dim_inactive = false,
		-- night's split border is almost the same color as the background
		on_highlights = function(hl, c)
			hl.WinSeparator = { fg = c.dark3, bold = true }
		end,
	},
}
