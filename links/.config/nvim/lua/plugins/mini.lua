return {
	{ "echasnovski/mini.cursorword", version = "*" },
	{ "echasnovski/mini.surround", version = "*", opts = {} },
	{
		"echasnovski/mini.files",
		version = "*",
		dependencies = { "mini.icons" },
		config = function()
			require("mini.files").setup()

			-- Toggle between mini.files open and closed
			local files_open_close = function()
				if not MiniFiles.close() then
					local buffer = vim.api.nvim_buf_get_name(0)
					MiniFiles.open(buffer)
				end
			end
			vim.keymap.set("n", "<leader>ee", files_open_close)

			-- Toggle preview mode in mini.files with `gp`
			local files_toggle_preview = function()
				MiniFiles.config.windows.preview = not MiniFiles.config.windows.preview
				MiniFiles.refresh({})
			end
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					vim.keymap.set("n", "gp", files_toggle_preview, { buffer = args.data.buf_id })
				end,
			})
		end,
	},
}
