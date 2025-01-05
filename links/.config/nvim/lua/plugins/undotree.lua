return {
	"mbbill/undotree",
	enabled = false,
	config = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
	end,
}
