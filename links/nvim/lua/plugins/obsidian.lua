return {
	"epwalsh/obsidian.nvim",
	version = "*",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		workspaces = {
			{
				name = "notes",
				path = "~/notes",
			},
		},
		daily_notes = {
			folder = "calendar/days/",
			date_format = "%Y-%m-%d",
			template = "templates/daily.md",
		},
	},
}
