# autosave.yazi

A Yazi plugin that saves and restores tab session state. Restores automatically on startup, automatic saves can be configured to any action within yazi.

## Installation

**Via ya pkg:**
```bash
ya pkg add pakhromov/autosave
```

**Manual:**
```bash
git clone https://github.com/pakhromov/autosave.yazi ~/.config/yazi/plugins/autosave.yazi
```

## Configuration

Add to `~/.config/yazi/init.lua` to enable auto-restore on startup:
```lua
require("autosave"):setup()
```

Add to `~/.config/yazi/keymap.toml` to configure when to save. Since `plugin autosave` is just a command, it can be chained into any keybind. This is useful if you tend to close Yazi via a WM/DE shortcut (e.g. `Super+Q`) rather than Yazi's own quit - in that case the quit keybind never fires, so saving on quit is not used. Instead, save on actions that happen during normal use:

### Quit

```toml
# Save on normal quit
[[mgr.prepend_keymap]]
on = "q"
run = ["plugin autosave", "quit"]
desc = "Save session and quit"

# Save on force quit (closes all tabs)
[[mgr.prepend_keymap]]
on = "Q"
run = ["plugin autosave", "quit --no-cwd-file"]
desc = "Save session and force quit"
```

### Navigation

```toml
# Enter directory
[[mgr.prepend_keymap]]
on = "l"
run = ["enter", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "<Right>"
run = ["enter", "plugin autosave"]

# Leave to parent directory
[[mgr.prepend_keymap]]
on = "h"
run = ["leave", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "<Left>"
run = ["leave", "plugin autosave"]
```

### Tabs

```toml
# New tab
[[mgr.prepend_keymap]]
on = "t"
run = ["tab_create --current", "plugin autosave"]

# Close tab
[[mgr.prepend_keymap]]
on = "<C-c>"
run = ["tab_close", "plugin autosave"]

# Switch tabs by index
[[mgr.prepend_keymap]]
on = "1"
run = ["tab_switch 0", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "2"
run = ["tab_switch 1", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "3"
run = ["tab_switch 2", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "4"
run = ["tab_switch 3", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "5"
run = ["tab_switch 4", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "6"
run = ["tab_switch 5", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "7"
run = ["tab_switch 6", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "8"
run = ["tab_switch 7", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "9"
run = ["tab_switch 8", "plugin autosave"]

# Switch to previous/next tab
[[mgr.prepend_keymap]]
on = "["
run = ["tab_switch -1 --relative", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "]"
run = ["tab_switch 1 --relative", "plugin autosave"]

# Swap tab positions
[[mgr.prepend_keymap]]
on = "{"
run = ["tab_swap -1", "plugin autosave"]

[[mgr.prepend_keymap]]
on = "}"
run = ["tab_swap 1", "plugin autosave"]
```

## Usage

Startup restore happens automatically.
