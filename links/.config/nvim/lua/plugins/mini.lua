return {
	{
		"echasnovski/mini.nvim",
		version = false,
		recommended = true,
		config = function()
			require("mini.surround").setup()
		end,
	},
}
