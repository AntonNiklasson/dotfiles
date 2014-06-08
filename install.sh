#! /bin/sh


# Link all files in /link to ~/<filename>
echo "Linking files..."
for f in ~/.dotfiles/link/.*; do
	if test -f "$f"
	then
		echo "Creating link from $f to $(basename $f)"
		ln -fs "$f" "$(basename $f)"
	fi
done

# .bashrc to .bash_profile on OSX
if [[ $OSTYPE == darwin* ]]; then
	ln -fs ~/.bashrc ~/.bash_profile
	source ~/.bash_profile
else
	source ~/.bashrc
fi

# Set global .gitignore
git config --global core.excludesfile '~/.gitignore'


echo "Dotfiles installed successfully!"
