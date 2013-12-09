# SETTINGS
export HISTCONTROL=ignoredups


# PROMPT
if [ -n "$SSH_CLIENT" ]; then
	text="[ssh]"
fi

export PS1="$text\[\033[36m\][\t] \[\033[1;33m\]\u\[\033[0m\]@\h:\[\033[36m\][\w]:\[\033[0m\]\n $ "


alias php="/Applications/MAMP/bin/php/php5.4.4/bin/php"

# ALIASES
alias apt='apt-get'

alias ll='ls -FHhl'
alias lla='ll -a'
alias ..='cd ..'
alias ...='..;..'
alias cl='clear'
alias rm='rm -i'
alias mkdir='mkdir -p'

alias g='git'
alias gb='g branch'
alias gba='gb -a'
alias gs='g status'
alias gc='g commit'
alias gcm='gc -m'
alias gco='g checkout'
alias ga='g add'
alias gd='g diff'
alias gdc='gd --cached'
alias deploy='g ftp push' # Set config in the git config

alias artisan='php artisan'


extract () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2) tar xvjf $1 && cd $(basename "$1" .tar.bz2) ;;
		*.tar.gz) tar xvzf $1 && cd $(basename "$1" .tar.gz) ;;
	*.tar.xz) tar Jxvf $1 && cd $(basename "$1" .tar.xz) ;;
*.bz2) bunzip2 $1 && cd $(basename "$1" /bz2) ;;
*.rar) unrar x $1 && cd $(basename "$1" .rar) ;;
*.gz) gunzip $1 && cd $(basename "$1" .gz) ;;
*.tar) tar xvf $1 && cd $(basename "$1" .tar) ;;
*.tbz2) tar xvjf $1 && cd $(basename "$1" .tbz2) ;;
*.tgz) tar xvzf $1 && cd $(basename "$1" .tgz) ;;
*.zip) unzip $1 && cd $(basename "$1" .zip) ;;
*.Z) uncompress $1 && cd $(basename "$1" .Z) ;;
*.7z) 7z x $1 && cd $(basename "$1" .7z) ;;
*) echo "don't know how to extract '$1'..." ;;
esac
else
	echo "'$1' is not a valid file!"
fi
}
