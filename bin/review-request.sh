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
if [[ ! "$pr_url" =~ '^(https://([^/[:space:]?#]+)/[^/[:space:]?#]+/[^/[:space:]?#]+/pull/[0-9]+)([/?#][^[:space:]]*)?$' ]]; then
  print -u2 'Provide a PR URL or copy one to the clipboard first.'
  exit 1
fi

pr_url="$match[1]"
pr_host="$match[2]"

# Raycast starts a non-interactive shell, so load mise without relying on .zshrc.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
eval "$(mise env --shell zsh)"

# Accept only hosts that gh has a login for. No host names in this script.
if ! gh auth status --json hosts --jq '.hosts | keys[]' | grep -qxF "$pr_host"; then
  print -u2 "gh has no login for $pr_host. Run: gh auth login --hostname $pr_host"
  exit 1
fi

data=$(gh pr view "$pr_url" --json title,additions,deletions,changedFiles,commits)
message=$(printf '%s' "$data" | jq -r --arg url "$pr_url" '
  (.commits | length) as $count |
  "[\(.title)](\($url))\n+\(.additions)/−\(.deletions) · \($count) \(if $count == 1 then "commit" else "commits" end) · \(.changedFiles) \(if .changedFiles == 1 then "file" else "files" end) changed"
')
printf '%s' "$message" | pbcopy
printf '✓ copied\n%s\n' "$message"
