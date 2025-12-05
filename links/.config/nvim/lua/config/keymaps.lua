-- unmap alt + j/k to move lines
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- center the current line after jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

-- save file
vim.keymap.set("i", "jj", "<Esc>:w<CR>l", { silent = true, desc = "Save file from insert mode" })
vim.keymap.set("n", "<Leader>w", ":w<CR>l", { silent = true, desc = "Save file from normal mode" })

-- auto-reloading files when they change
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = vim.api.nvim_create_augroup("FileChangeDetect", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.fn.getcmdwintype() == "" then
			vim.cmd("checktime")
		end
	end,
})
