-- Enter opens every selected file, not just the hovered one.
require("smart-enter"):setup({ open_multi = true })
require("git"):setup({ order = 1500 })
-- Inside nvim (yazi.nvim), skip session restore so the path it passes is honored.
-- Saving on quit still works; only the restore subscription is suppressed.
if os.getenv("NVIM") then
	local sub_remote = ps.sub_remote
	ps.sub_remote = function() end
	require("autosession"):setup()
	ps.sub_remote = sub_remote
else
	require("autosession"):setup()
end
require("yamb"):setup({})
require("no-status"):setup()
