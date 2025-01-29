return {
	"epwalsh/obsidian.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"telescope.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "notes",
				path = "/Users/anton/notes",
			},
		},

		open_app_foreground = true,
		disable_frontmatter = true,
		open_notes_in = "vsplit",
		ui = {
			enable = false,
		},

		picker = {
			name = "telescope.nvim",
		},

		templates = {
			folder = "templates",
		},
		daily_notes = {
			folder = "calendar/days",
			template = "templates/daily.md",
			default_tags = {},
		},
	},
	keys = {
		{
			"<leader>ot",
			"<cmd>ObsidianToday<CR>",
			desc = "daily note",
		},
		{
			"<leader>oi",
			"<cmd>ObsidianTemplate<CR>",
			desc = "insert template",
		},
		{
			"<leader>os",
			"<cmd>ObsidianSearch<CR>",
			desc = "search notes",
		},
		{
			"<leader>of",
			"<cmd>ObsidianQuickSwitch<CR>",
			desc = "open note",
		},
	},
}
