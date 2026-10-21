#!/bin/bash
# fresh-machine setup (macos, debian/ubuntu): just enough to run `mise bootstrap`.
# usage: ./install.sh [--dry-run]
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BOOTSTRAP_ARGS=(--force-dotfiles)
[[ "${1:-}" == --dry-run ]] && BOOTSTRAP_ARGS=(--dry-run)

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# gh comes from the system package manager, not mise: installing it via mise
# already needs the github API, and unauthenticated calls share zscaler's 60 req/h
TEMP_GH=false
case "$(uname -s)" in
  Darwin)
    if ! xcode-select -p &>/dev/null; then
      xcode-select --install
      read -r -p "press enter once the command line tools have installed "
    fi
    if [[ ! -x /opt/homebrew/bin/brew ]]; then
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if ! command -v gh &>/dev/null; then
      brew install gh
      TEMP_GH=true
    fi
    command -v mise &>/dev/null || brew install mise
    ;;
  Linux)
    sudo apt-get update
    sudo apt-get install -y git curl ca-certificates gh
    export PATH="$HOME/.local/bin:$PATH"
    command -v mise &>/dev/null || curl -fsSL https://mise.run | sh
    ;;
  *)
    echo "unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

[[ -d "$DOTFILES" ]] || git clone https://github.com/AntonNiklasson/dotfiles.git "$DOTFILES"

# per-machine role, gitignored; "private" loads conf.d/*.private.toml
MISERC_LOCAL="$DOTFILES/files/.config/mise/miserc.local.toml"
if [[ ! -f "$MISERC_LOCAL" ]]; then
  read -r -p "private machine? (y/n) " reply
  if [[ "$reply" == y ]]; then echo 'env = ["private"]' > "$MISERC_LOCAL"; else : > "$MISERC_LOCAL"; fi
fi

gh auth status &>/dev/null || gh auth login
GITHUB_TOKEN="$(gh auth token)"
export GITHUB_TOKEN

# linux gh keeps its token in hosts.yml (no keyring); keep it once ~/.config/gh becomes a link (gitignored)
if [[ -f ~/.config/gh/hosts.yml && ! -L ~/.config/gh ]]; then
  mv -n ~/.config/gh/hosts.yml "$DOTFILES/files/.config/gh/hosts.yml"
fi

if [[ -e ~/.config/mise && ! -L ~/.config/mise ]]; then
  mv ~/.config/mise ~/.config/mise.bak."$(date +%Y%m%d%H%M%S)"
fi
mkdir -p ~/.config
ln -sfn "$DOTFILES/files/.config/mise" ~/.config/mise

mise bootstrap "${BOOTSTRAP_ARGS[@]}"

# mise's gh takes over once bootstrap has installed tools
if [[ "$TEMP_GH" == true && "${BOOTSTRAP_ARGS[0]}" != --dry-run ]]; then
  brew uninstall gh
fi

echo "done! restart terminal (macos: log out once for keyboard and defaults)"
