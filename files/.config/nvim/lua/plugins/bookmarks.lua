return {
	"LintaoAmons/bookmarks.nvim",
	dependencies = {
		{ "kkharji/sqlite.lua" },
		{ "nvim-telescope/telescope.nvim" },
		{ "stevearc/dressing.nvim" },
	},
	config = function()
		require("bookmarks").setup({})
	end,
	keys = {
		{
			"<leader>mm",
			"<cmd>BookmarksMark<CR>",
			desc = "Bookmark the current line",
		},
		{
			"<leader>fm",
			"<cmd>BookmarksGoto<CR>",
			desc = "Goto bookmark in the current list",
		},
	},
}
