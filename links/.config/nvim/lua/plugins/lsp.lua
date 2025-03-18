return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = {
				enabled = false,
			},
			servers = {
				vtsls = {
					settings = {
						typescript = {
							tsserver = {
								maxTsServerMemory = 8192,
							},
							preferences = {
								importModuleSpecifier = "non-relative",
							},
						},
					},
				},
			},
		},
	},
}
