#! /bin/bash

# Install some apps.
printf "\n\n"
read -p "Install Homebrew and all the apps? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
	Install Homebrew.
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	# Install things from brew.
	brew install node npm tree composer

	# Install Homebrew Cask.
	brew tap caskroom/cask

	# Install all GUI applications.
	brew cask install google-chrome firefox lastpass sequel-pro slack spotify skim alfred divvy dropbox flux omnidisksweeper seil skype transmission vlc iterm2 atom fantastical hipchat appcleaner divvy macvim
	
	# Install some fonts.
	brew tap caskroom/fonts
	brew cask install font-inconsolata font-source-code-pro
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
