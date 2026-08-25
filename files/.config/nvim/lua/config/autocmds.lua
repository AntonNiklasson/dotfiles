-- auto-reloading files when they change
-- broader than LazyVim's own checktime autocmd, which only covers FocusGained/TermClose/TermLeave
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = vim.api.nvim_create_augroup("FileChangeDetect", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})
