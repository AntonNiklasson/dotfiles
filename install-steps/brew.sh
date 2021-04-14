#! /bin/bash

echo "Step 02: homebrew"

# Install Homebrew if needed
if ! command -v brew &> /dev/null
then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add taps
brew tap homebrew/cask-fonts
brew tap homebrew/cask-drivers
brew tap domt4/autoupdate

# Install CLI tools
brew install \
bat \
coreutils \
diff-so-fancy \
docker-compose \
fzf \
gh \
git-extras \
httpie \
mas \
node \
postgresql \
rename \
terminal-notifier \
the_silver_searcher \
tmux \
tree \
vim \
yarn \
zsh \
zsh-completions

# Install GUI applications
brew install --cask --force \
alfred \
appcleaner \
basecamp \
docker \
dropbox \
fantastical \
figma \
firefox \
font-source-code-pro \
google-chrome \
hiddenbar \
hyper \
iterm2 \
kap \
logitech-options \
macmediakeyforwarder \
nordvpn \
notion \
numi \
postico \
rectangle \
runjs \
sequel-pro \
slack \
sonos \
spotify \
telegram \
tuple \
visual-studio-code
