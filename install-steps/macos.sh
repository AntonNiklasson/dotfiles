#! /bin/bash

# Create folders 
# todo: dropbox setup conflicts with this folder
mkdir -pv ~/code ~/Dropbox

# Speed up dock animation
defaults write com.apple.dock autohide-time-modifier -int 0

# Don't store screenshots on the desktop
defaults write com.apple.screencapture location ~/Dropbox/Screenshots

# Don't rearrange spaces automatically in Mission Control
defaults write com.apple.dock mru-spaces -int 0

# Store screenshots in ~/Dropbox/Screenshots
defaults write com.apple.screencapture location ~/Dropbox/Screenshots

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Trackpad: enable three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Turn on key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
