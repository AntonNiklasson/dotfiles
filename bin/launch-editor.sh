#! /bin/bash

# Launch Editor Script
# 
# Opens a file in Neovim within a specific tmux session at a given line/column
#
# Usage:
#   launch-editor.sh <file-path>:<line>:<column>
#   launch-editor.sh <file-path>:<line>
#   launch-editor.sh <file-path>
#
# Examples:
#   launch-editor.sh src/app.tsx:25:10    # Opens app.tsx at line 25, column 10
#   launch-editor.sh src/app.tsx:25       # Opens app.tsx at line 25
#   launch-editor.sh src/app.tsx          # Opens app.tsx at line 1
#
# Required tmux setup:
#   - Session named "sana-code" must exist (create with: tmux new-session -s sana-code)
#   - Window named "main" in that session
#   - Neovim should be running in one of the panes (automatically detected)
#
# The script will:
#   1. Parse the file path and optional line/column from the input
#   2. Send vim commands to the tmux pane to open the file
#   3. Activate the Ghostty terminal application
#
# This is typically used by external tools (e.g., error reporters, test runners)
# to jump directly to specific code locations.

# Parse argument in format: file-path.tsx:12:34
ARG=$1

# Split by colon to get file path and line/column
FILE=$(echo "$ARG" | cut -d':' -f1)
LINE=$(echo "$ARG" | cut -d':' -f2)
COLUMN=$(echo "$ARG" | cut -d':' -f3)

# If no line provided, default to 1
if [ -z "$LINE" ]; then
  LINE=1
fi

# If column is provided, use it; otherwise just use line
if [ -n "$COLUMN" ]; then
  OPEN_COMMAND=":e $FILE | :$LINE | normal! ${COLUMN}|"
else
  OPEN_COMMAND=":e $FILE | :$LINE"
fi

TERMINAL="Ghostty"
SESSION="sana-code"
WINDOW="main"

tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
  echo "Session $SESSION does not exist."
else
  # Find the first pane running nvim/neovim
  PANE=$(tmux list-panes -t "$SESSION:$WINDOW" -F '#{pane_index} #{pane_current_command}' | grep -E 'nvim|neovim' | head -1 | cut -d' ' -f1)
  
  if [ -z "$PANE" ]; then
    echo "No Neovim instance found in $SESSION:$WINDOW"
    exit 1
  fi
  
  # Switch the client to the sana-code session and main window
  tmux switch-client -t "$SESSION:$WINDOW" 2>/dev/null
  # Send the vim command to open the file (escape to ensure normal mode)
  tmux send-keys -t "$SESSION:$WINDOW.$PANE" Escape "$OPEN_COMMAND" Enter
  # Focus the Neovim pane
  tmux select-pane -t "$SESSION:$WINDOW.$PANE"
  # Activate the terminal
  osascript -e 'tell application "'$TERMINAL'" to activate' 2>/dev/null
fi
