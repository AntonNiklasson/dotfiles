#! /bin/bash

printf "\n\n"

printf "> Initialising...\n\n"
source ./install-steps/init.sh

printf "> Setting up Homebrew...\n\n"
source ./install-steps/brew.sh

printf "> Configuring macOS...\n\n"
source ./install-steps/macos.sh

printf "> Configuring vim and tmux...\n\n"
source ./install-steps/vim-tmux.sh

printf "> Configuring node and npm...\n\n"
source ./install-steps/node-npm.sh

printf "> Installing from the App Store...\n\n"
source ./install-steps/appstore.sh

# Refresh things to read new config
printf "\n\nAll done. Reloading environment.\n\n"
killall Dock
source ~/.zshrc
