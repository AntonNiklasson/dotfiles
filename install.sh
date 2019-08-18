#! /bin/bash

git clone git@github.com:AntonNiklasson/dotfiles.git .dotfiles

# Install Homebrew.
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install \
	coreutils \
	diff-so-fancy \
	docker \
	git-extras \
	httpie \
	hub \
	mas \
	node \
	postgresql \
	sequel-pro \
	tmux \
	tree \
	vim \
	zsh \
	yarn
brew tap caskroom/cask
brew tap caskroom/fonts
brew tap homebrew/cask-drivers
brew cask install --force \
	alfred \
	appcleaner \
	dropbox \
	fantastical \
	firefox \
	flux \
	font-inconsolata \
	font-source-code-pro \
	hyper \
	iterm2 \
	macvim \
	notion \
	skim \
	slack \
	spectacle \
	spotify \
	telegram \
	virtualbox \
	visual-studio-code \
	postico \
	logitech-options

# Install software from the Mac App Store
mas install \
	585829637 # Todoist

# Setup zsh
echo "/usr/local/bin/zsh" >> /etc/shells
chsh -s /usr/local/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Link up files.
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig
ln -is ~/.dotfiles/links/tmux.conf ~/.tmux.conf

# macOS Preferences
defaults write com.apple.dock autohide-time-modifier -int 0
killall Dock

source ~/.zshrc
