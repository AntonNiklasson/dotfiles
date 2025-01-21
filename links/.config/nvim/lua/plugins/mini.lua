return {
	{
		"echasnovski/mini.nvim",
		version = false,
		recommended = true,
		dependencies = {
			"mini.icons",
		},
		config = function()
			require("mini.surround").setup()
			require("mini.files").setup()

			local files_toggle = function()
				if not MiniFiles.close() then
					local buffer = vim.api.nvim_buf_get_name(0)
					MiniFiles.open(buffer)
				end
			end

			vim.keymap.set("n", "<leader>eo", files_toggle)
		end,
	},
}
