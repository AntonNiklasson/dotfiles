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

		lualine.setup({
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ LazyVim.lualine.pretty_path() },
					"filetype",
				},
				lualine_c = { "branch", "searchcount" },

				lualine_x = {},
				lualine_y = {
					"diagnostics",
				},
				lualine_z = {
					"macro_recording",
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#c77b00" },
					},
				},
			},
			extensions = { "neo-tree", "lazy" },
		})
	end,
}
