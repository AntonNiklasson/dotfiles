vim.opt.termguicolors = true

vim.filetype.add({
	extension = {
		mdx = "markdown.mdx",
	},
})

vim.opt.conceallevel = 0

vim.opt.swapfile = false

vim.opt.tabstop = 4

vim.opt.cursorline = true

vim.g.root_spec = { "cwd" }

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true
