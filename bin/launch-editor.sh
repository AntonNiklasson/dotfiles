#!/usr/bin/env bash
set -euo pipefail

# launch-editor — open a file in the Neovim instance running in the herdr
# tab for the worktree that contains the file.
#
# Usage: launch-editor.sh <file> [<line> [<column>]]
#
# Invoked by the `launch-editor` npm package when $LAUNCH_EDITOR points at
# this script: it falls through to the unknown-editor branch in get-args.js
# and spawns us with three separate args. The target pane is the one running
# nvim whose cwd is inside the file's git worktree.

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

# Candidate panes: cwd at or under the worktree. herdr's pane list has no
# process name, so each candidate is checked with `pane process-info` —
# argv0 rather than name, because some agents exec version-named binaries.
TARGET=""
for pane in $(herdr pane list |
    jq -r --arg wt "$WORKTREE" \
      '.result.panes[] | select(.cwd == $wt or (.cwd | startswith($wt + "/"))) | .pane_id'); do
  if herdr pane process-info --pane "$pane" |
      jq -e '.result.process_info.foreground_processes[]
             | select(.argv0 | test("^n?vim$|^neovim$"))' >/dev/null 2>&1; then
    TARGET=$pane
    break
  fi
done

if [ -z "$TARGET" ]; then
  echo "launch-editor: no nvim pane found for worktree $WORKTREE" >&2
  exit 1
fi

if [ -n "${COLUMN:-}" ]; then
  OPEN=":e +$LINE $FILE | normal! ${COLUMN}|"
else
  OPEN=":e +$LINE $FILE"
fi

TAB=$(herdr pane get "$TARGET" | jq -r '.result.pane.tab_id')

log "target: pane=$TARGET tab=$TAB worktree=$WORKTREE"
log "send: $OPEN"

herdr tab focus "$TAB" >/dev/null 2>&1 || true
herdr pane send-keys "$TARGET" esc >/dev/null
herdr pane send-text "$TARGET" "$OPEN" >/dev/null
herdr pane send-keys "$TARGET" Enter >/dev/null
osascript -e 'tell application "Ghostty" to activate' 2>/dev/null || true
