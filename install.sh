#!/bin/bash
# fresh-mac setup: just enough to run `mise bootstrap`. packages, links, macos
# defaults, tools and hooks all live in files/.config/mise/config.toml.
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

# 0. prompt for sudo once, then keep it alive (homebrew, cask installers).
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# 1. xcode command line tools (git, compilers for source-only formulae)
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  read -r -p "press enter once the command line tools have installed "
fi

# 2. repo
[[ -d "$DOTFILES" ]] || git clone https://github.com/AntonNiklasson/dotfiles.git "$DOTFILES"

# 3. homebrew. mise installs formulae/casks into its prefix itself, but the
# brew CLI is still handy and .zshrc runs `brew shellenv`.
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. mise
command -v mise &>/dev/null || brew install mise

# 5. link the mise config so bootstrap reads it (bootstrap relinks it too)
if [[ -e ~/.config/mise && ! -L ~/.config/mise ]]; then
  mv ~/.config/mise ~/.config/mise.bak."$(date +%Y%m%d%H%M%S)"
fi
mkdir -p ~/.config
ln -sfn "$DOTFILES/files/.config/mise" ~/.config/mise

# 6. github login. mise resolves versions and taps via the github API, and the
# unauthenticated 60 req/h limit is shared with everyone behind zscaler.
mise install gh
mise exec -- gh auth status &>/dev/null || mise exec -- gh auth login
GITHUB_TOKEN="$(mise exec -- gh auth token)"
export GITHUB_TOKEN

# 7. everything else. --force-dotfiles replaces real files at link targets.
mise bootstrap --force-dotfiles

echo "done! restart terminal (and killall Dock Finder SystemUIServer for defaults)"
