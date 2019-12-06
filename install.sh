#! /bin/bash

# Install Homebrew.
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Add taps
brew tap caskroom/cask
brew tap homebrew/cask-fonts
brew tap homebrew/cask-drivers
brew tap domt4/autoupdate

# Install CLI tools
brew install \
	coreutils \
	diff-so-fancy \
	docker \
	docker-compose \
	git-extras \
	httpie \
	hub \
	mas \
	node \
	postgresql \
	tmux \
	tree \
	vim \
	yarn \
	zsh \
	zsh-completions \
	the_silver_searcher \
	terminal-notifier

# Install GUI applications
brew cask install --force \
	font-source-code-pro \
	alfred \
	appcleaner \
	dropbox \
	fantastical \
	firefox \
	flux \
	hyper \
	iterm2 \
	logitech-options \
	notion \
	postico \
	skim \
	slack \
	spectacle \
	spotify \
	telegram \
	visual-studio-code \
	brave-browser \
	macmediakeyforwarder \
	nordvpn \
	kap \
	runjs \
	inter-power-gadget \
	sequel-pro \
	p4v


# Install software from the Mac App Store
mas lucky Todoist
mas lucky Spark


# Install packages from npm
yarn global add \
	alfred-fkill \
	alfred-npms \
	alfred-loremipsum \
	alfred-ip \
	gatsby-cli


# Install vim-plug
# curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


# Setup zsh
echo "/usr/local/bin/zsh" >> /etc/shells
chsh -s /usr/local/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


# Clone the repo
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles


# Link files.
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig
ln -is ~/.dotfiles/links/tmux.conf ~/.tmux.conf


# macOS Preferences
# Speed up dock animation
defaults write com.apple.dock autohide-time-modifier -int 0

# Don't store screenshots on the desktop
defaults write com.apple.screencapture location ~/Dropbox/Screenshots


# Refresh things to read new config
killall Dock
source ~/.zshrc
