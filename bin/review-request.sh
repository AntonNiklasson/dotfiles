#!/bin/zsh -l

# @raycast.schemaVersion 1
# @raycast.title Review Request
# @raycast.mode compact
# @raycast.packageName GitHub
# @raycast.description Copy a formatted PR review request to the clipboard
# @raycast.argument1 { "type": "text", "placeholder": "PR URL", "optional": true }

set -euo pipefail
setopt extendedglob

pr_url="${1:-$(pbpaste)}"
pr_url="${pr_url##[[:space:]]#}"
pr_url="${pr_url%%[[:space:]]#}"
if [[ ! "$pr_url" =~ '^https://github\.com/[^/[:space:]]+/[^/[:space:]]+/pull/[0-9]+/?$' ]]; then
  print -u2 'Provide a GitHub PR URL or copy one to the clipboard first.'
  exit 1
fi

# Raycast starts a non-interactive shell, so load mise without relying on .zshrc.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
eval "$(mise env --shell zsh)"

data=$(gh pr view "$pr_url" --json title,additions,deletions,changedFiles,commits)
message=$(printf '%s' "$data" | jq -r --arg url "$pr_url" '
  (.commits | length) as $count |
  "[\(.title)](\($url))\n`+\(.additions)/-\(.deletions)` · \($count) \(if $count == 1 then "commit" else "commits" end) · \(.changedFiles) \(if .changedFiles == 1 then "file" else "files" end) changed"
')
printf '%s' "$message" | pbcopy
printf '✓ copied\n%s\n' "$message"
