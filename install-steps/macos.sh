#! /bin/bash

# Speed up dock animation
defaults write com.apple.dock autohide-time-modifier -int 0

# Don't store screenshots on the desktop
defaults write com.apple.screencapture location ~/Dropbox/Screenshots

# Don't rearrange spaces automatically in Mission Control
defaults write com.apple.dock mru-spaces -int 0

# Don't store screenshots in ~/Desktop
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
