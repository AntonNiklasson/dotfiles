return {
	"nvim-telescope/telescope.nvim",
	opts = {
		defaults = vim.tbl_extend("force", require("telescope.themes").get_ivy(), {
			layout_config = {
				prompt_position = "top",
			},
			sorting_strategy = "ascending",
		}),
	},
}
