vim.opt.termguicolors = true

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

-- root dir should always be cwd
vim.g.root_spec = { "cwd" }

-- save undo history to disk
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true
