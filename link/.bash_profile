# SETTINGS
export HISTCONTROL=ignoredups
export PS1="\n\n\e[1;35m\W\e[m $ "


alias sphp="/Applications/MAMP/bin/php/php5.4.4/bin/php"
alias mysql="/Applications/MAMP/Library/bin/mysql"

# ALIASES
alias ll='ls -FHhl'
alias la='ll -a'
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
