#!/bin/bash
# fresh-mac setup: just enough to run `mise bootstrap` (config in files/.config/mise).
# usage: ./install.sh [--dry-run]
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BOOTSTRAP_ARGS=(--force-dotfiles)
[[ "${1:-}" == --dry-run ]] && BOOTSTRAP_ARGS=(--dry-run)

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  read -r -p "press enter once the command line tools have installed "
fi

[[ -d "$DOTFILES" ]] || git clone https://github.com/AntonNiklasson/dotfiles.git "$DOTFILES"

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# gh from brew, not mise: installing it via mise already needs the github API,
# and unauthenticated calls share zscaler's 60 req/h
TEMP_GH=false
if ! command -v gh &>/dev/null; then
  brew install gh
  TEMP_GH=true
fi
gh auth status &>/dev/null || gh auth login
GITHUB_TOKEN="$(gh auth token)"
export GITHUB_TOKEN

command -v mise &>/dev/null || brew install mise

if [[ -e ~/.config/mise && ! -L ~/.config/mise ]]; then
  mv ~/.config/mise ~/.config/mise.bak."$(date +%Y%m%d%H%M%S)"
fi
mkdir -p ~/.config
ln -sfn "$DOTFILES/files/.config/mise" ~/.config/mise

mise bootstrap "${BOOTSTRAP_ARGS[@]}"

# mise's gh takes over once bootstrap has installed tools
[[ "$TEMP_GH" == true && "${BOOTSTRAP_ARGS[0]}" != --dry-run ]] && brew uninstall gh

echo "done! restart terminal (and killall Dock Finder SystemUIServer for defaults)"
