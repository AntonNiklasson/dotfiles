return {
	"stevearc/oil.nvim",
	enabled = false,
	opts = {
		view_options = {
			show_hidden = true,
		},
		columns = {
			"icons",
		},
		float = {
			max_width = 100,
			max_height = 20,
			border = "rounded",
			preview_split = "right",
		},
		use_default_keymaps = true,
	},
	config = function(opts)
		require("oil").setup(opts)

		local last = nil

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "oil://*",
			callback = function()
				last = require("oil").get_current_dir()
			end,
		})

		vim.keymap.set("n", "<leader>eo", require("oil").open_float, { desc = "Oil the current file" })
		vim.keymap.set("n", "<leader>eO", function()
			if last then
				require("oil").open_float(last)
			else
				require("oil").open_float()
			end
		end, { desc = "Oil the previous dir" })
	end,
}
