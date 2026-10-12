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
			function()
				-- tab-session.yazi restores the saved tabs only when this is set;
				-- jobstart inherits it synchronously, so unset right after.
				vim.env.YAZI_SESSION = "1"
				require("yazi").toggle()
				vim.env.YAZI_SESSION = nil
			end,
			desc = "Resume saved yazi tabs",
		},
	},
	init = function()
		-- Inherited when nvim is opened from a session yazi; keep other
		-- launches from overwriting the saved tabs.
		vim.env.YAZI_SESSION = nil
	end,
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
