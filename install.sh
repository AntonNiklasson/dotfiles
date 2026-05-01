#!/bin/bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BREWFILE="$DOTFILES/Brewfile"

# 0. prompt for sudo once, then keep it alive for the rest of the script.
# mas (Mac App Store installs), defaults to /Library, etc. may want sudo later.
echo "Note: password prompt is for Mac App Store apps via mas and any sudo-gated steps."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# 1. homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 1.5. prerequisites needed before brew bundle + dotfile linking
for pkg in mas dotbot; do
  command -v "$pkg" &>/dev/null || brew install "$pkg"
done

# 1.6. show anything installed but not declared in Brewfile
"$DOTFILES/bin/brew-dotfiles" extras

# 2. link dotfiles to $HOME
dotbot -d "$DOTFILES" -c "$DOTFILES/links.yml"

# 3. brew packages (sudo already primed at top of script)
"$DOTFILES/bin/brew-dotfiles" install

# 4. tmux plugin manager
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# 5. macos defaults
read -p "apply macos defaults? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  defaults write com.apple.dock autohide-time-modifier -int 0
  defaults write com.apple.dock mru-spaces -int 0
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write -g ApplePressAndHoldEnabled -bool false
  killall Dock
fi

echo "done! restart terminal"
