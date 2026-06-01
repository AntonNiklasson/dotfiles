local function walk_for(bufnr, packages)
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		return nil
	end
	for parent in vim.fs.parents(file) do
		for _, pkg in ipairs(packages) do
			if vim.uv.fs_stat(parent .. "/node_modules/" .. pkg) then
				return pkg
			end
		end
	end
	return nil
end

local function js_fmt(bufnr)
	local pkg = walk_for(bufnr, { "oxfmt", "prettier" })
	return pkg and { pkg } or {}
end

local function md_fmt(bufnr)
	local pkg = walk_for(bufnr, { "prettier" })
	return pkg and { pkg } or {}
end

return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			["markdown.mdx"] = md_fmt,
			astro = js_fmt,
			javascript = js_fmt,
			javascriptreact = js_fmt,
			typescript = js_fmt,
			typescriptreact = js_fmt,
		},
	},
}
