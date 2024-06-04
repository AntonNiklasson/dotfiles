-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- setup colors
vim.o.termguicolors = true
vim.opt.background = "dark"

-- set filetype for .mdx to 'markdown-mdx'
vim.filetype.add({
	extension = {
		mdx = "markdown.mdx",
	},
})

-- set conceal to "none" by default
vim.opt.conceallevel = 0

-- disable swapfiles
vim.opt.swapfile = false

-- set tabsize to 4
vim.opt.tabstop = 4

-- disable a highglight for the current line
vim.opt.cursorline = false

-- stop auto changing directory
vim.opt.autochdir = false

-- set colors for line numbers
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#ff0000", bold = true })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#00ff00", bold = true })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#0000ff", bold = true })
