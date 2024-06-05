# Setup the spaceship theme
source /opt/homebrew/opt/spaceship/spaceship.zsh
ZSH_THEME="spaceship"

# Editors
export VISUAL='nvim'
export EDITOR=$VISUAL
export REACT_EDITOR='codium'

# Add folders to PATH
export PATH=~/.dotfiles/bin:$PATH
export PATH=/usr/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/lib:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=/opt/homebrew/sbin:$PATH
export PATH=./node_modules/.bin:$PATH

# Aliases & Functions
alias copy-branch='git rev-parse --abbrev-ref HEAD | pbcopy'
alias docker-remove-all-containers='docker rm $(docker ps -a -q) || true'
alias docker-remove-all-images='docker rmi $(docker images -q) || true'
alias docker-stop-all-containers='docker stop $(docker ps -q) || true'
alias dotfiles='vim ~/.dotfiles'
alias ga='git add'
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit'
alias gca='git commit --amend'
alias gcb='git create-branch'
alias gcm='git commit -m'
alias gco="git checkout"
alias gcof="git checkout \"\$(git for-each-ref --sort='-authordate:iso8601' --format='%(refname:short)' refs/heads | fzf | tr -d '[:space:]')\""
alias gcp='git cherry-pick'
alias gd='git diff'
alias gdc='git diff --cached'
alias gf='git fetch'
alias gl='git log --pretty=format:"%Cred%h%Creset %Cgreen%cd%Creset %Cblue%ae%Creset%n%s%n" --date=short'
alias gm='git merge'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gpnv='git push --no-verify'
alias gpsu='git push --set-upstream origin'
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gri='git rebase -i'
alias gs='git status'
alias gst='git stash'
alias iclouddrive='cd "/Users/anton/Library/Mobile Documents"'
alias ls='eza'
alias ll='eza --long --group-directories-first --no-permissions --no-user --icons=always'
alias lla='ll --all'
alias lg='lazygit'
alias my-prs='gh pr list -A="@me"'
alias nr='npm run'
alias pn='pnpm'
alias pnr='pnpm run'
alias pr='open-github-pull-request'
alias t='tmux'
alias ta='t attach'
alias tl='tmux ls'
alias tn='tmux new-session -t'
alias whatisrunningonport='lsof -i'
alias zshrc='vim ~/.zshrc'
alias zshrcs='source ~/.zshrc'
alias vim='nvim'

rebase-feature() {
  base=${1:-"main"}
  git fetch -a
  git rebase origin/$base
}

copy-last-command-to-cliboard() {
  fc -ln -1 | pbcopy
  echo "Copied last command to clipboard!"
}

# Fast Node Manager
eval "$(fnm env --use-on-cd)"

# Google Cloud SDK
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi

# z jumper
source ~/.config/z.sh

# fzf fuzzy finder
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'
export FZF_BASE=/opt/homebrew/bin/fzf

# Use `bat` instead of `cat`
alias cat='bat'
export BAT_THEME='TwoDark'
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# zsh autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^ ' autosuggest-accept
