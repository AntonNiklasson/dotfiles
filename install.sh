#! /bin/bash

# Install some apps.
printf "\n\n"
read -p "Install Homebrew and all the apps? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	Install Homebrew.
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	# Install Homebrew Cask.
	brew tap caskroom/cask
	brew tap caskroom/font

	# Install all the applications.
	brew cask install google-chrome firefox lastpass sequel-pro slack spotify
	brew cask install sublime-text skim alfred divvy dropbox flux
	brew cask install omnidisksweeper seil skype transmission vlc
	brew cask install iterm2 atom fantastical hipchat
fi

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Link up files.
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig

# Configure Vim with Vundle.
rm -rf ~/.vim ~/.dotfiles/vim/bundle
ln -is ~/.dotfiles/vim ~/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c PluginInstall -c quitall

source ~/.zshrc
