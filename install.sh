#! /bin/bash

printf "\n\n"

printf "> Initialising..."
source ./install-steps/init.sh

printf "> Setting up Homebrew..."
source ./install-steps/brew.sh

printf "> Configuring macOS..."
source ./install-steps/macos.sh

printf "> Configuring vim and tmux..."
source ./install-steps/vim-tmux.sh

printf "> Configuring node and npm..."
source ./install-steps/node-npm.sh

printf "> Installing from the App Store..."
source ./install-steps/appstore.sh

# Refresh things to read new config
printf "\n\nAll done. Reloading environment."
killall Dock
source ~/.zshrc
