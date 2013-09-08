# SETTINGS
export HISTCONTROL=ignoredups


# ALIASES
# some basics
alias ll='ls -l'
alias ..='cd ..'
alias ...='..;..'
alias cl='clear'
alias rm='rm -i'
alias mkdir='mkdir -p'

# git related
alias g='git'
alias gb='g branch'
alias gs='g status'
alias gc='g commit'
alias gcm='gc -m'
alias gco='g checkout'
alias ga='g add'
alias gd='g diff'
alias gdc='gd --cached'
alias deploy='g ftp push' # Set config in the git config

# apps etc
alias subl='subl&'
alias fz='filezilla'

# laravel related
alias arti='php artisan'


# PROMPT
export PS1="\[\033[36m\][\t] \[\033[1;33m\]\u\[\033[0m\]@\h:\[\033[36m\][\w]:\[\033[0m\]\n $ "
