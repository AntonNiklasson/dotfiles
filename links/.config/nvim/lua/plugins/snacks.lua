return {
	"folke/snacks.nvim",
	opts = {
		dim = {
			enabled = true,
		},
		scroll = {
			enabled = false,
		},
		dashboard = {
			width = 60,
			sections = {
				{ section = "keys", gap = 0, padding = 2 },
				{
					pane = 2,
					icon = " ",
					title = "Status",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git status -s",
					padding = 1,
					ttl = 5 * 60,
				},
				{ section = "startup" },
			},
		},
	},
}
