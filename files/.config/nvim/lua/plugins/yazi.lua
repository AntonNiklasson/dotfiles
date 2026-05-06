return {
	"mikavilpas/yazi.nvim",
	version = "13.1.4",
	event = "VeryLazy",
	dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
	keys = {
		{
			"<leader>ee",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Explore filesystem",
		},
	},
	opts = {
		open_for_directories = true,
		keymaps = {
			show_help = "?",
		},
	},
}
