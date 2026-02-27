#!/bin/bash
set -e

BREWFILE="$HOME/.dotfiles/Brewfile"

install_mas_if_needed() {
  if ! command -v mas &>/dev/null; then
    echo "Installing mas (prerequisite)..."
    brew install mas
  fi
}

install_stow_if_needed() {
  if ! command -v stow &>/dev/null; then
    echo "Installing stow (prerequisite)..."
    brew install stow
  fi
}

get_extras() {
  local installed_formulae installed_casks installed_mas expected

  while IFS= read -r line; do
    installed_formulae+=("$line")
  done < <(brew leaves 2>/dev/null || true)

  while IFS= read -r line; do
    installed_casks+=("$line")
  done < <(brew list --cask 2>/dev/null || true)

  while IFS= read -r line; do
    installed_mas+=("$line")
  done < <(mas list 2>/dev/null | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//' | sed 's/ ([0-9.]*)$//' || true)

  local all_installed=("${installed_formulae[@]}" "${installed_casks[@]}")

  if command -v mas &>/dev/null; then
    local mas_installed=("${installed_mas[@]}")
    all_installed+=("${mas_installed[@]}")
  fi

  if [[ ! -f "$BREWFILE" ]]; then
    echo "No Brewfile found. All installed packages will be considered extras."
    printf '%s\n' "${all_installed[@]}" | sort -u
    return
  fi

  local expected_formulae expected_casks expected_mas
  while IFS= read -r line; do
    expected_formulae+=("$line")
  done < <(grep -E '^brew "' "$BREWFILE" | sed 's/brew "\(.*\)"/\1/' | sed 's/",.*//' || true)

  while IFS= read -r line; do
    expected_casks+=("$line")
  done < <(grep -E '^cask "' "$BREWFILE" | sed 's/cask "\(.*\)"/\1/' | sed 's/",.*//' || true)

  while IFS= read -r line; do
    expected_mas+=("$line")
  done < <(grep -E '^mas "' "$BREWFILE" | sed 's/mas "\(.*\)"/\1/' | grep -v 'id:' | sed 's/",.*//' || true)

  local expected_all=("${expected_formulae[@]}" "${expected_casks[@]}" "${expected_mas[@]}")

  local extras=()
  for item in "${all_installed[@]}"; do
    local item_lower=$(echo "$item" | tr '[:upper:]' '[:lower:]')
    local found=0
    for exp in "${expected_all[@]}"; do
      local exp_lower=$(echo "$exp" | tr '[:upper:]' '[:lower:]')
      if [[ "$item_lower" == "$exp_lower" ]]; then
        found=1
        break
      fi
    done
    if [[ $found -eq 0 && -n "$item" ]]; then
      extras+=("$item")
    fi
  done

  printf '%s\n' "${extras[@]}" | sort -u
}

check_brew_extras() {
  echo "Checking for untracked Homebrew packages..."

  local extras
  while IFS= read -r line; do
    extras+=("$line")
  done < <(get_extras)

  if [[ ${#extras[@]} -eq 0 || -z "${extras[0]}" ]]; then
    echo "All Homebrew packages are tracked in Brewfile. ✓"
    return
  fi

  echo ""
  echo "Found ${#extras[@]} packages not in Brewfile:"
  for pkg in "${extras[@]}"; do
    echo "  - $pkg"
  done
  echo ""

  local valid=0
  while [[ $valid -eq 0 ]]; do
    read -p "Options: [u] Uninstall, [a] Add to Brewfile, [i] Ignore: " -n 1 -r
    echo
    case $REPLY in
      u|U)
        valid=1
        echo "Uninstalling extras..."
        for pkg in "${extras[@]}"; do
          if brew list "$pkg" &>/dev/null; then
            brew uninstall "$pkg" || echo "  Failed to uninstall $pkg"
          elif brew list --cask "$pkg" &>/dev/null; then
            brew uninstall --cask "$pkg" || echo "  Failed to uninstall $pkg"
          elif mas list 2>/dev/null | grep -q "^$pkg "; then
            mas uninstall "$pkg" || echo "  Failed to uninstall $pkg"
          fi
        done
        ;;
      a|A)
        valid=1
        echo "Updating Brewfile with current packages..."
        brew bundle dump --force --file="$BREWFILE"
        ;;
      i|I)
        valid=1
        echo "Ignoring extras, continuing..."
        ;;
      *)
        echo "Invalid option. Please choose u, a, or i."
        ;;
    esac
  done
}

# 1. homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 1.5. install prerequisites
install_mas_if_needed
install_stow_if_needed

# 1.6. check for extras before continuing
check_brew_extras

# 2. link dotfiles to $HOME
for item in "$HOME/.dotfiles/links"/.*; do
  name=$(basename "$item")
  [[ "$name" == "." || "$name" == ".." ]] && continue
  target="$HOME/$name"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.backup"
    echo "moved $name to $name.backup"
  fi
done
stow --target="$HOME" --dir="$HOME/.dotfiles/links" .

# 3. oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. brew packages
brew bundle --file="$BREWFILE"

# 5. tmux plugin manager
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# 6. macos defaults
read -p "apply macos defaults? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  defaults write com.apple.dock autohide-time-modifier -int 0
  defaults write com.apple.dock mru-spaces -int 0
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write com.apple.LaunchServices LSQuarantine -bool false
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write -g ApplePressAndHoldEnabled -bool false
  killall Dock
fi

echo "done! restart terminal"
