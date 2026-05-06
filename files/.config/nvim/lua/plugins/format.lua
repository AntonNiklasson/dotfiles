local prettier_config_files = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.yaml",
	".prettierrc.yml",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	".prettierrc.toml",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
}

local function js_fmt(bufnr)
	if vim.fs.root(bufnr, prettier_config_files) then
		return { "prettier" }
	end
	return { "oxfmt", "prettier", stop_after_first = true }
end

return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			["markdown.mdx"] = { "prettier" },
			astro = { "prettier" },
			javascript = js_fmt,
			javascriptreact = js_fmt,
			typescript = js_fmt,
			typescriptreact = js_fmt,
		},
	},
}
