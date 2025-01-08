vim.g.root_spec = { "cwd" }
vim.opt.conceallevel = 0
vim.opt.cursorline = true
vim.opt.spell = false
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true

vim.filetype.add({
	extension = {
		mdx = "markdown.mdx",
	},
})
