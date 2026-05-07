#!/usr/bin/env bash
set -euo pipefail

# launch-editor — open a file in the Neovim instance running in the tmux
# window for the worktree that contains the file.
#
# Usage: launch-editor.sh <file> [<line> [<column>]]
#
# Invoked by the `launch-editor` npm package when $LAUNCH_EDITOR points at
# this script: it falls through to the unknown-editor branch in get-args.js
# and spawns us with three separate args. The target tmux window is the one
# whose nvim pane is rooted in the file's git worktree (typically created
# by `wt new`).

LOG="$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")/launch-editor.log"
log() {
  local line
  line="[$(date '+%H:%M:%S')] $*"
  printf '%s\n' "$line"
  printf '%s\n' "$line" >>"$LOG"
}

FILE=${1:-}
LINE=${2:-1}
COLUMN=${3:-}
log "input: file=$FILE line=$LINE column=$COLUMN"
[ -z "$FILE" ] && { echo "Usage: launch-editor.sh <file> [<line> [<column>]]" >&2; exit 1; }

if [[ "$FILE" != /* ]]; then
  FILE="$PWD/$FILE"
fi

WORKTREE=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null) || {
  echo "launch-editor: $FILE is not inside a git worktree" >&2
  exit 1
}

TARGET=$(tmux list-panes -a \
  -F '#{session_name}:#{window_index}.#{pane_index}|#{pane_current_path}|#{pane_current_command}' 2>/dev/null \
  | awk -F'|' -v wt="$WORKTREE" '
      ($2 == wt || index($2, wt"/") == 1) && $3 ~ /^(n?vim|neovim)$/ { print $1; exit }')

if [ -z "$TARGET" ]; then
  echo "launch-editor: no nvim pane found for worktree $WORKTREE" >&2
  exit 1
fi

WINDOW=${TARGET%.*}

if [ -n "${COLUMN:-}" ]; then
  OPEN=":e +$LINE $FILE | normal! ${COLUMN}|"
else
  OPEN=":e +$LINE $FILE"
fi

log "target: pane=$TARGET worktree=$WORKTREE"
log "send: $OPEN"

tmux switch-client -t "$WINDOW" 2>/dev/null || true
tmux send-keys -t "$TARGET" Escape "$OPEN" Enter
tmux select-pane -t "$TARGET"
osascript -e 'tell application "Ghostty" to activate' 2>/dev/null || true
