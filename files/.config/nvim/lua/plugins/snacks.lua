return {
	"folke/snacks.nvim",
	opts = {
		picker = {
			formatters = {
				file = {
					filename_first = true,
				},
			},
			layout = {
				layout = {
					box = "horizontal",
					width = 0.8,
					min_width = 120,
					height = 0.8,
					{
						box = "vertical",
						border = true,
						title = "{title} {live} {flags}",
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
					},
					{ win = "preview", title = "{preview}", border = true, width = 0.35 },
				},
			},
			sources = {
				buffers = { format = "file" },
				files = { hidden = true },
				smart = { hidden = true },
				grep = { hidden = true },
				grep_word = { hidden = true },
			},
		},
	},
}
