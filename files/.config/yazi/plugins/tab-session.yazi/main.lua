-- Opt-in tab persistence on top of autosave.yazi. Only instances started with
-- YAZI_SESSION=1 restore and save, so one-off yazis (`ee <path>`, nvim's
-- <leader>ee) don't overwrite the saved tabs with their single tab.
return {
	setup = function()
		if os.getenv("YAZI_SESSION") ~= "1" then
			return
		end
		require("autosave"):setup()
		-- Save on every cd and hover instead of on quit: yazi.nvim quits via the
		-- chooser file, which skips any `q` keymap. Hover also fires when tabs
		-- are switched or closed.
		local save = function() ya.emit("plugin", { "autosave" }) end
		ps.sub("cd", save)
		ps.sub("hover", save)
	end,
}
