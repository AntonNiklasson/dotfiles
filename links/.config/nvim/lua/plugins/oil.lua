return {
	"stevearc/oil.nvim",
	opts = {
		view_options = {
			show_hidden = true,
		},
		columns = {
			"icons",
		},
		float = {
			max_width = 100,
			max_height = 20,
			border = "rounded",
			preview_split = "right",
		},
		use_default_keymaps = true,
		keymaps = {
			["<C-v>"] = { "actions.select", opts = { vertical = true } },
		},
	},
	keys = {
		{
			"<leader>eo",
			function()
				require("oil").open_float()
			end,
			desc = "Open Oil floating",
		},
	},
}
