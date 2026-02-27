# setup the plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
unalias zi

# plugins
zinit ice depth=1
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# environment
export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$PATH:/opt/homebrew/opt/ruby/bin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:~/.dotfiles/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.local/share/bob/nvim-bin
export VISUAL='nvim'
export EDITOR=$VISUAL
export REACT_EDITOR=''
export LAUNCH_EDITOR=launch-editor.sh
export TERM='xterm-256color'

# vi mode
bindkey -v
export KEYTIMEOUT=1
bindkey -M viins '^?' backward-delete-char

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # block cursor
  else
    echo -ne '\e[6 q'  # beam cursor
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  zle -K viins
  echo -ne '\e[6 q'  # beam cursor
}
zle -N zle-line-init

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^e' edit-command-line

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=true
export HOMEBREW_NO_ENV_HINTS=true 
brew tap domt4/autoupdate


# prompt
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/ohmyposh.toml)"
fi


# fast node manager
eval "$(fnm env --use-on-cd --shell zsh)"


# history
setopt EXTENDED_HISTORY       # save timestamp with each command
setopt HIST_IGNORE_ALL_DUPS   # no duplicates
HISTSIZE=10000
SAVEHIST=10000

# fzf
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND='ag --nocolor --ignore node_modules -g ""'
export FZF_BASE=/opt/homebrew/bin/fzf
export FZF_CTRL_R_OPTS="--with-nth=2.."  # hide line numbers
function fzf-history-clean {
  zle kill-whole-line
  zle fzf-history-widget
}
zle -N fzf-history-clean
bindkey -M vicmd '/' fzf-history-clean


# Use `bat` instead of `cat`
alias cat='bat'
export BAT_THEME='tokyonight'


# zoxide jumper
eval "$(zoxide init zsh)"


# integrate direnv
eval "$(direnv hook zsh)"


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
alias show-commit='git show --no-patch --no-notes --pretty=format:"%h - %s"'
export EZA_CONFIG_DIR="$HOME/.config/eza"
alias ls='eza --long --group-directories-first --icons=always --all --no-user --no-permissions --no-time'
alias lg='lazygit'
alias ld='lazydocker'
alias p='pnpm'
alias pr='pnpm run'
alias pi='pnpm install'
alias t='tmux'
alias ta='t attach'
alias rc='vim ~/.zshrc'
alias rcs='source ~/.zshrc'
alias vim='nvim'
alias k='HTTPS_PROXY=socks5://localhost:8888 kubectl'
alias oc='opencode --agent plan'

function r() {
  local runner=npm
  if [[ -f pnpm-lock.yaml ]]; then runner=pnpm
  elif [[ -f yarn.lock ]]; then runner=yarn
  elif [[ -f bun.lockb || -f bun.lock ]]; then runner=bun
  fi
  NTL_RUNNER=$runner ntl -A "$@"
}
alias c='clear'

function tree() {
  # add depth as an optional argument
  command tree -I 'node_modules|dist' -C --filesfirst -L 2 | less -RFS
}

finder() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"

	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi

	rm -f -- "$tmp"
}

copy-command() {
  fc -ln -1 | pbcopy
  echo "Copied last command to clipboard!"
}

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Turso
export PATH="$PATH:$HOME/.turso"
export PATH=$PATH:$HOME/.maestro/bin



[[ -f ~/.workday-setup ]] && source ~/.workday-setup
