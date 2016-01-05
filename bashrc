source ~/.dotfiles/variables
source ~/.dotfiles/paths
source ~/.dotfiles/aliases

if [[ $OSTYPE == darwin* ]]; then
	. ~/.dotfiles/osx
else
	. ~/.dotfiles/linux
fi

# Prevent Ctrl-S
stty -ixon
