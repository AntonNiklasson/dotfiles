local wk = require("which-key")

-- unmap alt + j/k to move lines
vim.keymap.del("n", "<A-j>")
vim.keymap.del("n", "<A-k>")

-- center the current line after jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Center cursor after moving down half-page" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Center cursor after moving up half-page" })
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

-- save file from insert mode with jj
vim.keymap.set({ "i" }, "jj", "<Esc>:w<cr>l", { silent = true, desc = "Save file from insert mode" })
