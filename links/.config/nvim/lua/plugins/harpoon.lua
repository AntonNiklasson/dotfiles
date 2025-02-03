return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("harpoon"):setup()
	end,
	keys = function()
		local harpoon = require("harpoon")
		return {
			{
				"<leader>H",
				function()
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Toggle Harpoon menu",
			},
			{
				"<leader>h",
				function()
					harpoon:list():add()
				end,
				desc = "Harpoon current file",
			},

			{
				"<leader>1",
				function()
					harpoon:list():select(1)
				end,
				desc = "Jump to harpoon #1",
			},
			{
				"<leader>2",
				function()
					harpoon:list():select(2)
				end,
				desc = "Jump to harpoon #2",
			},
			{
				"<leader>3",
				function()
					harpoon:list():select(3)
				end,
				desc = "Jump to harpoon #3",
			},
		}
	end,
}
