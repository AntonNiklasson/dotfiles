# SETTINGS
export HISTCONTROL=ignoredups
export PS1="\n\n\e[1;35m\W\e[m $ "
export PATH="/Applications/XAMPP/xamppfiles/bin:$PATH"
export PATH=/usr/local/bin:$PATH


# PROMPT
export PS1="[\u] \[\033[36m\]\w \[\033[0m\]\n $ "


# ALIASES
alias ll='ls -Hhl'
alias la='ll -a'
alias ..='cd ..'
alias ...='..;..'
alias cl='clear'
alias mkdir='mkdir -p'

alias code='cd ~/code'
alias dotfiles='cd ~/.dotfiles/link && la'

alias v='vim'
alias vi='vim'

alias g='git'
alias ga='g add'
alias gb='g branch'
alias gba='gb -a'
alias gc='g commit'
alias gcm='gc -m'
alias gco='g checkout'
alias gd='g diff'
alias gdc='gd --cached'
alias gl='g log'
alias gs='g status'

# Dotfile helpers
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.dotfiles/link/.bash_profile'
alias gitconfig='vim ~/.gitconfig'

# Laravel specific
alias art='php artisan'


# Extract files with ease
extract () {
	if [ -f $1 ] ; then
		case $1 in
				*.tar.bz2) tar xvjf $1 		&& cd $(basename "$1" .tar.bz2) ;;
				*.tar.gz) tar xvzf $1 		&& cd $(basename "$1" .tar.gz) ;;
				*.tar.xz) tar Jxvf $1 		&& cd $(basename "$1" .tar.xz) ;;
				*.bz2) bunzip2 $1 				&& cd $(basename "$1" /bz2) ;;
				*.rar) unrar x $1 				&& cd $(basename "$1" .rar) ;;
				*.gz) gunzip $1 					&& cd $(basename "$1" .gz) ;;
				*.tar) tar xvf $1 				&& cd $(basename "$1" .tar) ;;
				*.tbz2) tar xvjf $1 			&& cd $(basename "$1" .tbz2) ;;
				*.tgz) tar xvzf $1				&& cd $(basename "$1" .tgz) ;;
				*.zip) unzip $1 					&& cd $(basename "$1" .zip) ;;
				*.Z) uncompress $1 				&& cd $(basename "$1" .Z) ;;
				*.7z) 7z x $1 						&& cd $(basename "$1" .7z) ;;
				*) echo "don't know how to extract '$1'..." ;;
esac
else
	echo "'$1' is not a valid file!"
fi
}
