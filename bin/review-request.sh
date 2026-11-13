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

exec "$HOME/.dotfiles/bin/review-request" "$1"
