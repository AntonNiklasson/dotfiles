-- unmap alt + j/k to move lines
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- save file
vim.keymap.set("i", "jj", "<Esc>:w<CR>l", { silent = true, desc = "Save file from insert mode" })
vim.keymap.set("n", "<Leader>w", ":w<CR>l", { silent = true, desc = "Save file from normal mode" })

-- copy relative file path to clipboard
vim.keymap.set("n", "<Leader>yp", function()
	local path = vim.fn.expand("%:.")
	vim.fn.setreg("+", path)
	vim.notify(path, vim.log.levels.INFO, { title = "Copied path" })
end, { desc = "Copy relative file path" })
