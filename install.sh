#! /bin/sh

for f in ~/.dotfiles/link/.*; do
	if test -f "$f"
	then
		ln -fs "$f" "$(basename $f)"
	fi
done

# .bashrc to .bash_profile on OSX.
if [[ $OSTYPE == darwin* ]]; then
	ln -fs ~/.bashrc ~/.bash_profile
	. ~/.bash_profile
else
	. ~/.bashrc
fi

git config --global user.name "Anton Niklasson"
git config --global user.email "niklasson.anton@gmail.com"
git config --global core.excludesfile '~/.gitignore'
git config --global core.editor 'vim'


echo "Dotfiles installed."
