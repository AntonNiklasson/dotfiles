#! /bin/bash

# Speed up dock animation
defaults write com.apple.dock autohide-time-modifier -int 0

# Don't store screenshots on the desktop
defaults write com.apple.screencapture location ~/Dropbox/Screenshots

# Don't rearrange spaces automatically in Mission Control
defaults write com.apple.dock mru-spaces -int 0

# Don't store screenshots in ~/Desktop
defaults write com.apple.screencapture location ~/Dropbox/Screenshots
