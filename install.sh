#!/bin/bash
set -e

# get sudo upfront
sudo -v

# 1. homebrew
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. stow for linking
brew install stow

# 3. link dotfiles to $HOME
for item in "$HOME/.dotfiles/links"/.*; do
    name=$(basename "$item")
    [[ "$name" == "." || "$name" == ".." ]] && continue
    target="$HOME/$name"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mv "$target" "$target.backup"
        echo "moved $name to $name.backup"
    fi
done
stow --target="$HOME" --dir="$HOME/.dotfiles/links" .

# 4. oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 5. brew packages
brew bundle --file="$HOME/.dotfiles/Brewfile"

# 6. tmux plugin manager
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# 7. macos defaults
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
