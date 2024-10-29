# zinit (plugin manager)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"


# plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light jeffreytse/zsh-vi-mode


# .config
export XDG_CONFIG_HOME="$HOME/.config"


# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=true
export HOMEBREW_NO_ENV_HINTS=true 
brew tap domt4/autoupdate


# setup PATH
export PATH=$PATH:~/.dotfiles/bin


# prompt with ohmyposh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/ohmyposh.toml)"
fi


# editor configurations
export VISUAL='vim'
export EDITOR=$VISUAL
export REACT_EDITOR=''
export LAUNCH_EDITOR=launch-editor.sh



# fast node manager
eval "$(fnm env --use-on-cd)"


# google cloud sdk
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"


# fzf
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'
export FZF_BASE=/opt/homebrew/bin/fzf


# Use `bat` instead of `cat`
alias cat='bat'
export BAT_THEME='TwoDark'


# zoxide jumper
eval "$(zoxide init zsh)"


# integrate direnv
eval "$(direnv hook zsh)"


# pnpm completions
source ~/completion-for-pnpm.zsh


# aliases
alias ..='cd ..'
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gca='git commit --amend'
alias gcb='git create-branch'
alias gcm='git commit -m'
alias gco="git checkout"
alias gcof="git checkout \"\$(git for-each-ref --sort='-authordate:iso8601' --format='%(refname:short)' refs/heads | fzf | tr -d '[:space:]')\""
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch'
alias gl='git log --pretty=format:"%Cred%h%Creset %Cgreen%cd%Creset %Cblue%ae%Creset%n%s%n" --date=short'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias gs='git status'
alias gst='git stash'
alias l='eza --oneline --group-directories-first'
alias ll='eza --oneline --group-directories-first --no-permissions --no-user --icons=always --all'
alias lg='lazygit'
alias my-prs='gh pr list -A="@me"'
alias nr='npm run'
alias pn='pnpm'
alias pnr='pnpm run'
alias t='tmux'
alias ta='t attach'
alias whatisrunningonport='lsof -i'
alias zshrc='vim ~/.zshrc'
alias zshrcs='source ~/.zshrc'
alias vim='nvim'
alias finder='yazi'

sierra-containers() {
    local dir
    dir=$(pwd)

    cd ~/code/sana/sierra-platform
    ./docker-compose-wrapper.sh down
    ./docker-compose-wrapper.sh up
    ./migrate-alloydb.sh docker

    cd "$dir"
}

rebase-feature() {
  base=${1:-"main"}
  git fetch -a
  git rebase origin/$base
}

copy-command() {
  fc -ln -1 | pbcopy
  echo "Copied last command to clipboard!"
}
