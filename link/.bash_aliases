alias ll='ls -Hhl'
alias la='ll -a'
alias ..='cd ..'
alias ...='..;..'
alias mkdir='mkdir -p'
alias pwd='pwd -P'

alias code='cd ~/code'
alias dotfiles='cd ~/.dotfiles/link && la'
alias homestead='cd ~/code/Homestead'

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
alias push='g push'
alias pull='g pull'

alias vm='ssh vagrant@127.0.0.1 -p 2222'
alias digitalocean='ssh root@5.101.107.248'

alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.dotfiles/link/.bash_profile'
alias gitconfig='vim ~/.gitconfig'
alias hosts='sudo vim /etc/hosts'


if [[ $OSTYPE == darwin* ]]; then
		alias sites='sudo vim /Applications/XAMPP/xamppfiles/etc/extra/httpd-vhosts.conf'
else
		alias sites='cd /etc/apache2/sites-available && ll'
fi


MkdirAndCd() {
	mkdir $1 && cd $1
}
alias md=MkdirAndCd;


function o {
	nohup xdg-open "$1" > /dev/null 2>&1 &
}
export -f o
