# Ignore duplicates in the command history
export HISTCONTROL=ignoredups

# Vim that shit up.
export EDITOR='vim'

# Set the prompt. Shows current branch if in repo.
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="[\u] \[\033[36m\]\w\[\033[0m\]\[\033[32m\]\$(parse_git_branch)\[\033[00m\] \n $ "

. ~/.dotfiles/aliases
. ~/.dotfiles/paths

# Put OS specifics in these two files.
if [[ $OSTYPE == darwin* ]]; then
	. ~/.dotfiles/osx
else
	. ~/.dotfiles/linux
fi

# Prevent Ctrl-S
stty -ixon
