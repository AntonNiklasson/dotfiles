return {
	"mfussenegger/nvim-lint",
	opts = {
		linters_by_ft = {
			markdown = {},
			css = { "stylelint" },
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		},
		linters = {
			eslint_d = {
				-- cwd = function(ctx)
				-- 	return vim.fn.getcwd(ctx.buf)
				-- end,
			},
		},
	},
}
