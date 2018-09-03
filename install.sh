#! /bin/bash

# Install Homebrew.
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Get some stuff from Homebrew.
brew install node npm tree neovim/neovim/neovim coreutils
brew tap caskroom/cask
brew cask install google-chrome firefox slack spotify skim alfred spectacle dropbox flux seil skype vlc iterm2 atom appcleaner macvim
brew tap caskroom/fonts
brew cask install font-inconsolata font-source-code-pro

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Link up files.
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig

source ~/.zshrc
