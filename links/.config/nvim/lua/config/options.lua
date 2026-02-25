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
	pattern = {
		[".*"] = {
			priority = -math.huge,
			function(path, bufnr)
				local content = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
				if content:match("^#!.*zx") then
					return "typescript"
				end
			end,
		},
	},
})

vim.g.lazyvim_prettier_needs_config = true
