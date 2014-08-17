# Ignore duplicates in history
export HISTCONTROL=ignoredups

# Show git branch in PS1
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="[\u] \[\033[36m\]\w\[\033[0m\]\[\033[32m\]\$(parse_git_branch)\[\033[00m\] \n $ "

# Install aliases
. ~/.bash_aliases

alias mapniktest='ssh -i ~/.ssh/mapniktest.pem ubuntu@mapniktest.2xper.se'

# Setup $PATH
. ~/.paths
