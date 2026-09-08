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

-- pasting over a visual selection with `p` clobbers the unnamed register with the
-- replaced text, so pasting the same yank over a second word pastes the text it just
-- replaced. `P` does the same replace but leaves the register alone.
vim.keymap.set("x", "p", "P", { desc = "Paste without clobbering the register" })

-- ctrl+hjkl moves between splits, falling through to herdr panes at the edge.
-- herdr grabs ctrl+hjkl globally and forwards it here via bin/pane-nav when the
-- pane runs nvim, so this is the other half of that handshake.
-- Replaces christoomey/vim-tmux-navigator.
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	vim.keymap.set("n", "<C-" .. key .. ">", function()
		local from = vim.api.nvim_get_current_win()
		vim.cmd.wincmd(key)
		if from == vim.api.nvim_get_current_win() and vim.env.HERDR_ENV then
			vim.system({ "herdr", "pane", "focus", "--direction", direction })
		end
	end, { desc = "Go to " .. direction .. " window or herdr pane" })
end
