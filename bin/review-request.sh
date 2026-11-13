#!/bin/zsh -l

# @raycast.schemaVersion 1
# @raycast.title Review Request
# @raycast.mode compact
# @raycast.packageName GitHub
# @raycast.description Copy a formatted PR review request to the clipboard
# @raycast.argument1 { "type": "text", "placeholder": "PR URL", "optional": false }

if [[ -z "$1" ]]; then
  print -u2 'A PR URL is required.'
  exit 1
fi

set -euo pipefail

# Raycast starts a non-interactive shell, so load mise without relying on .zshrc.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
eval "$(mise env --shell zsh)"

data=$(gh pr view "$1" --json title,additions,deletions,changedFiles,commits)
message=$(printf '%s' "$data" | jq -r --arg url "$1" '
  (.commits | length) as $count |
  "[\(.title)](\($url))\n`+\(.additions)/-\(.deletions)` · \($count) \(if $count == 1 then "commit" else "commits" end) · \(.changedFiles) \(if .changedFiles == 1 then "file" else "files" end) changed"
')
printf '%s' "$message" | pbcopy
printf '✓ copied\n%s\n' "$message"
