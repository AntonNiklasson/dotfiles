#! /bin/bash

# Clone the repo to ~/.dotfiles
if [ ! -d ~/.dotfiles ] 
then
    git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
fi

# Link files.
echo "Linking files..."
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig
ln -is ~/.dotfiles/links/tmux.conf ~/.tmux.conf
