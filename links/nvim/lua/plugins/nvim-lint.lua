return {
	"mfussenegger/nvim-lint",
	optional = true,
	opts = {
		linters_by_ft = {
			markdown = {},
			css = { "stylelint" },
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		},
	},
}
