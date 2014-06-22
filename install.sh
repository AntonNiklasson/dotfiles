#! /bin/sh

echo "Creating .files..."

for f in ~/.dotfiles/link/.*; do
	if test -f "$f"
	then
		echo "Creating ~/$(basename $f)"
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

# Set global .gitignore
git config --global core.excludesfile '~/.gitignore'


echo "Dotfiles installed successfully!"
