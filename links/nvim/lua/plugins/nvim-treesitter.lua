return {
	-- add more treesitter parsers
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"bash",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"regex",
				"tsx",
				"typescript",
				"yaml",
				"astro",
				"css",
				"vue",
				"php",
			},
		},
	},
}
