return {
	"nvimdev/dashboard-nvim",
	lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
	opts = function()
		local logo = [[


    ]]

		logo = string.rep("\n", 8) .. logo .. "\n\n"

		local opts = {
			theme = "doom",
			hide = {
				statusline = false,
				tabline = false,
				winbar = false,
			},
			config = {
				header = vim.split(logo, "\n"),
				center = {
					{
						action = "lua LazyVim.pick()()",
						desc = " file",
						icon = " ",
						key = "f",
					},
					{
						action = "ene | startinsert",
						desc = " new",
						icon = " ",
						key = "n",
					},
					{
						action = 'lua require("persistence").load()',
						desc = " restore",
						icon = " ",
						key = "s",
					},
					{
						action = function()
							vim.api.nvim_input("<cmd>qa<cr>")
						end,
						desc = " quit",
						icon = " ",
						key = "q",
					},
				},
				footer = {},
			},
		}

		for _, button in ipairs(opts.config.center) do
			button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
			button.key_format = "  %s"
		end

		-- close Lazy and re-open when the dashboard is ready
		if vim.o.filetype == "lazy" then
			vim.cmd.close()
			vim.api.nvim_create_autocmd("User", {
				pattern = "DashboardLoaded",
				callback = function()
					require("lazy").show()
				end,
			})
		end

		return opts
	end,
}
