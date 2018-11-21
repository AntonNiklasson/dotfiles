#! /bin/bash

git clone git@github.com:AntonNiklasson/dotfiles.git .dotfiles

# Install Homebrew.
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install things from Homebrew
brew install node tree coreutils diff-so-fancy hub mas zsh docker git-extras httpie sequel-pro
brew tap caskroom/cask
brew tap caskroom/fonts
brew cask install font-inconsolata font-source-code-pro telegram google-chrome firefox slack spotify skim alfred spectacle dropbox flux seil skype vlc iterm2 atom appcleaner macvim visual-studio-code notion virtualbox

# Install things from NPM
npm i -g yarn spaceship-prompt

# Setup zsh
echo "/usr/local/bin/zsh" >> /etc/shells
chsh -s /usr/local/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Link up files.
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig

# macOS Preferences
defaults write com.apple.dock autohide-time-modifier -int 0
killall Dock

source ~/.zshrc
