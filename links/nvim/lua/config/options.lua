-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

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

-- disable the tab line
-- vim.opt.showtabline = 0

-- set tabsize to 4
vim.opt.tabstop = 2

-- highlight the current line
vim.opt.cursorline = true
