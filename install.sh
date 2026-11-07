#!/bin/bash
# fresh-machine setup (macos, debian/ubuntu): just enough to run `mise bootstrap`.
# usage: ./install.sh [--plan]
set -euo pipefail

DOTFILES="$HOME/.dotfiles"
PLAN=false
for arg in "$@"; do
  case "$arg" in
    --plan) PLAN=true ;;
    *) echo "unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Preview must exit before sudo, package installation, auth, or config writes.
if [[ "$PLAN" == true ]]; then
  cat <<'PLAN'
Installer plan (no changes will be made):
1. Save installation output under ~/.local/state/dotfiles/install-*.log,
   then request sudo and keep it available during installation.
2. Prepare prerequisites:
   macOS: install Command Line Tools and Homebrew if missing; install gh if
   missing, and install or upgrade mise.
   Linux (Debian/Ubuntu): update apt and install git, curl, certificates,
   and gh; install or update mise.
3. Clone ~/.dotfiles if missing.
4. Ask whether this is a private machine if no local role config exists.
5. Check GitHub authentication; start login if needed.
6. Preserve existing gh credentials before linking dotfiles.
7. Back up an existing mise config directory and link the repo's config.
8. Run mise bootstrap to install declared packages/tools, link dotfiles,
   and apply configured settings and hooks. Incomplete first setups use
   --force-dotfiles. Bootstrap may ask for confirmation.
9. Remove a temporary Homebrew gh installation after successful bootstrap.
PLAN
  if [[ -d "$DOTFILES/files/.config/mise" ]] && command -v mise &>/dev/null; then
    MISE_CONFIG_DIR="$DOTFILES/files/.config/mise" mise bootstrap --dry-run --force-dotfiles
  else
    echo "Would install prerequisites, clone $DOTFILES, authenticate GitHub, and run mise bootstrap."
    echo "A package preview requires mise and the repository to be installed first."
  fi
  exit 0
fi

# Keep each run outside the checkout so logs survive config linking and retries.
LOG_DIR="$HOME/.local/state/dotfiles"
mkdir -p "$LOG_DIR"
LOG_FILE="$(umask 077; mktemp "$LOG_DIR/install-$(date +%Y%m%d-%H%M%S)-XXXXXX.log")"
exec > >(tee -a "$LOG_FILE") 2>&1
finish() {
  local status=$?
  trap - EXIT
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
  echo "installer exited with status $status; log: $LOG_FILE"
  exit "$status"
}
trap finish EXIT
echo "installation log: $LOG_FILE"
echo "started: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
SUDO_KEEPALIVE_PID=$!

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
    if command -v mise &>/dev/null; then brew upgrade mise; else brew install mise; fi
    ;;
  Linux)
    sudo apt-get update
    sudo apt-get install -y git curl ca-certificates gh
    export PATH="$HOME/.local/bin:$PATH"
    if command -v mise &>/dev/null; then mise self-update -y; else curl -fsSL https://mise.run | sh; fi
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

cd "$HOME"

# linux gh keeps its token in hosts.yml (no keyring); keep a copy for when ~/.config/gh becomes a link (gitignored)
if [[ -f ~/.config/gh/hosts.yml && ! -L ~/.config/gh && ! -e "$DOTFILES/files/.config/gh/hosts.yml" ]]; then
  cp ~/.config/gh/hosts.yml "$DOTFILES/files/.config/gh/hosts.yml"
fi

# only the first run overwrites real files at link targets; later runs stop and show them
BOOTSTRAP_ARGS=()
[[ "$(readlink ~/.zshrc || true)" == "$DOTFILES/files/.zshrc" ]] || BOOTSTRAP_ARGS=(--force-dotfiles)

if [[ -e ~/.config/mise && ! -L ~/.config/mise ]]; then
  mv ~/.config/mise ~/.config/mise.bak."$(date +%Y%m%d%H%M%S)"
fi
mkdir -p ~/.config
ln -sfn "$DOTFILES/files/.config/mise" ~/.config/mise

mise bootstrap ${BOOTSTRAP_ARGS[@]+"${BOOTSTRAP_ARGS[@]}"}

# mise's gh takes over once bootstrap has installed tools
if [[ "$TEMP_GH" == true ]]; then
  brew uninstall gh
fi

echo "done! restart terminal (macos: log out once for keyboard and defaults)"
