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
		{
			"<leader>ec",
			"<cmd>Yazi cwd<cr>",
			desc = "Explore cwd",
		},
		{
			"<leader>er",
			"<cmd>Yazi toggle<cr>",
			desc = "Resume last yazi session",
		},
	},
	opts = {
		open_for_directories = true,
		keymaps = {
			show_help = "?",
			-- default replacer is grug-far.nvim, which isn't installed
			replace_in_directory = false,
		},
		integrations = {
			-- default is telescope, which isn't installed
			grep_in_directory = "fzf-lua",
			grep_in_selected_files = "fzf-lua",
			picker_add_copy_relative_path_action = "snacks.picker",
		},
	},
}
