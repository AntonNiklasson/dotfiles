#! /bin/bash

# Clone the repo to ~/.dotfiles
if [ ! -d ~/.dotfiles ]; then
	echo "Cloning the dotfiles repo..."
	git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
fi

echo "✅ dotfiles installed"

# Install oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
	echo "Installing oh-my-zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "✅ ohmyzsh installed"

# Link files.
printf "\nLinking files...\n"
ln -is ~/.dotfiles/links/.zshrc ~/.zshrc
ln -is ~/.dotfiles/links/.gitignore ~/.gitignore
ln -is ~/.dotfiles/links/.gitconfig ~/.gitconfig
ln -is ~/.dotfiles/links/tmux.conf ~/.tmux.conf
ln -is ~/.dotfiles/links/nvim ~/.config/nvim

source ~/.zshrc

# Install zsh-autoupdate
git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins $ZSH_CUSTOM/plugins/autoupdate
