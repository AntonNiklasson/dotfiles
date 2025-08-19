return {
	{
		"ibhagwan/fzf-lua",
		enabled = false,
	},
	{
		"nvim-telescope/telescope.nvim",
		opts = {
			defaults = {
				path_display = {
					"filename_first",
					"truncate",
				},
				layout_config = {
					preview_cutoff = 50,
					prompt_position = "top",
					horizontal = {
						width = 0.8,
						height = 0.8,
					},
				},
				sorting_strategy = "ascending", -- works well with prompt_position=top
			},
			pickers = {
				buffers = {
					initial_mode = "normal",
					mappings = {
						n = {
							["<C-x>"] = require("telescope.actions").delete_buffer,
						},
					},
				},
				lsp_references = {
					initial_mode = "normal",
				},
				lsp_definitions = {
					initial_mode = "normal",
				},
			},
		},
	},
}
