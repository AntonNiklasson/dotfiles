# Aliases
alias ll='ls -Hhl'
alias la='ll -a'
alias ..='cd ..'
alias ...='..;..'
alias cl='clear'
alias mkdir='mkdir -p'
alias pwd='pwd -P'

alias code='cd ~/code'
alias dotfiles='cd ~/.dotfiles/link && la'
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
alias gm='g merge'
alias gs='g status'
alias gf='g fetch'
alias push='g push'
alias pull='g pull'

# Laravel Specific 
alias art='php artisan'
alias pu='echo "Running PHPUnit..." && phpunit'

alias homestead='cd ~/code/Homestead'
alias vm='ssh vagrant@127.0.0.1 -p 2222'

alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.dotfiles/link/.bashrc'
alias gitconfig='vim ~/.gitconfig'
alias hosts='sudo vim /etc/hosts'

if [[ $OSTYPE == darwin* ]]; then
		alias sites='sudo vim /Applications/XAMPP/xamppfiles/etc/extra/httpd-vhosts.conf'
else
		alias sites='cd /etc/apache2/sites-available && ll'
fi

# Extraction
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

MkdirAndCd() {
	mkdir $1 && cd $1
}
alias md=MkdirAndCd;

function o {
	nohup xdg-open "$1" > /dev/null 2>&1 &
}
export -f o
