alias ll='ls -lh --color --group-directories-first'
alias la='ll -a'
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias pwd='pwd -P'

alias code='cd ~/code'
alias dotfiles='cd ~/.dotfiles/link && la'
alias t48='cd ~/code/TNM048'

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
alias pushdeploy='git push origin master && envoy run deploy'

alias pyserv='python -m http.server'

alias vm='ssh vagrant@127.0.0.1 -p 2222'
alias digitalocean='ssh root@5.101.107.248'
alias pi='ssh pi@192.168.1.123'

alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.dotfiles/link/.bashrc'
alias aliases='vim ~/.bash_aliases && source ~/.bashrc'
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
