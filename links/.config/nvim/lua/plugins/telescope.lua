return {
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
					width = 0.9,
					height = 0.5,
				},
			},
			sorting_strategy = "ascending", -- works well with prompt_position=top
		},
		pickers = {
			buffers = {
				initial_mode = "normal",
			},
			lsp_references = {
				initial_mode = "normal",
			},
		},
	},
}
