return {
	"LintaoAmons/bookmarks.nvim",
	tag = "v2.0.0",
	dependencies = {
		{ "kkharji/sqlite.lua" },
		{ "nvim-telescope/telescope.nvim" },
		{ "stevearc/dressing.nvim" }, -- optional: better UI
	},
	opts = {
		signs = {
			mark = {
				icon = "👉",
			},
		},
	},
	keys = {
		{
			"<leader>mm",
			"<cmd>BookmarksMark<CR>",
			desc = "Bookmark the current line",
		},
		{
			"<leader>fm",
			"<cmd>BookmarksGoto<CR>",
			{
				desc = "Goto bookmark in the current list",
			},
		},
	},
}
