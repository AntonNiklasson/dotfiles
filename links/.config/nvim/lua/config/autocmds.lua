-- autoreload Kitty with ~/.config/kitty/kitty.conf
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { "kitty.conf" },
	callback = function()
		vim.cmd("silent !kill -SIGUSR1 $(pgrep -a kitty)")
	end,
})

-- format the file on every keystroke in markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.formatoptions:append("t")
	end,
})
