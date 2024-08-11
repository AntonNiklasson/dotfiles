return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"yavorski/lualine-macro-recording.nvim",
	},
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")
		local icons = LazyVim.config.icons

		lualine.setup({
			sections = {
				lualine_a = {},
				lualine_b = {
					{ LazyVim.lualine.pretty_path() },
				},
				lualine_c = {},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{
						"diagnostics",
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
					},
				},
				lualine_y = {},
				lualine_z = {
					"macro_recording",
					"mode",
				},
			},
			extensions = { "neo-tree", "lazy" },
		})
	end,
}
