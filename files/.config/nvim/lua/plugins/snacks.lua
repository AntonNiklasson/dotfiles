return {
	"folke/snacks.nvim",
	keys = {
		{ "<leader>.", false }, -- LazyVim: toggle scratch buffer, never used
		{ "<leader>S", false }, -- LazyVim: select scratch buffer, never used
	},
	opts = {
		gitbrowse = {
			url_patterns = {
				-- GitHub Enterprise uses the same paths as github.com
				["ghe%.megaleo%.com"] = {
					branch = "/tree/{branch}",
					file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
					permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
					commit = "/commit/{commit}",
				},
			},
		},
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
