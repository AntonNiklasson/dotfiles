return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = {
				enabled = false,
			},
			servers = {
				eslint = {
					settings = {
						-- monorepo: resolve config + deps from the nearest package, not the repo root
						workingDirectories = { mode = "auto" },
						-- diagnostics only; formatting is handled by conform (oxfmt/prettier)
						format = false,
					},
				},
				-- disabled for now: pulled in by the lang.typescript directory import (oxc.lua).
				-- using eslint for diagnostics instead.
				oxlint = false,
			},
		},
	},
}
