return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		reveal = true,
		filesystem = {
			filtered_items = {
				hide_dotfiles = false,
			},
			window = {
				preview_width = 0.5,
				preview_height = 0.5,
			},
		},
		window = {
			position = "right",
			mappings = {
				["P"] = {
					"toggle_preview",
					config = {
						use_float = true,
						enabled = true,
						position = "right",
						reveal = true,
						width = 100,
						height = 100,
					},
				},
			},
		},
		bind_to_cwd = false,
	},
	keys = {
		-- unbind default keymaps
		{ "<leader>e" },
		{ "<leader>E" },
		{ "<leader>be" },
		{ "<leader>fe" },
		{ "<leader>fE" },

		-- custom binds
		{
			"<leader>ee",
			function()
				require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
			end,
			desc = "Explorer NeoTree (Root Dir)",
		},
	},
}
