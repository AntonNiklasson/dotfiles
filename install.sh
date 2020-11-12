#! /bin/bash

# Install Homebrew.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Add taps
brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew tap homebrew/cask-drivers
brew tap domt4/autoupdate

# Install CLI tools
brew install \
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
brew cask install --force \
alfred \
appcleaner \
basecamp \
brave-browser \
displaylink \
docker \
dropbox \
fantastical \
firefox \
firefox-developer-edition \
firefox-nightly \
flux \
font-source-code-pro \
google-chrome \
google-chrome-canary \
google-chrome-dev \
hiddenbar \
hyper \
iterm2 \
kap \
logitech-options \
macmediakeyforwarder \
nordvpn \
notion \
p4v \
postico \
rectangle \
runjs \
safari-technology-preview \
sequel-pro \
slack \
sonos \
spotify \
telegram \
tuple \
visual-studio-code


# Install software from the Mac App Store
mas lucky Todoist
mas lucky Spark
mas lucky Vimari


# Install packages from npm
yarn global add \
	yo \
	alfred-fkill \
	alfred-npms \
	alfred-loremipsum \
	alfred-ip \
	gatsby-cli \
	@bitwarden/cli


# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.0/install.sh | bash
nvm install 12


# Setup zsh
echo "/usr/local/bin/zsh" >> /etc/shells
chsh -s /usr/local/bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"


# Clone the repo
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles


# Install Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


# Link files.
ln -is ~/.dotfiles/links/zshrc ~/.zshrc
ln -is ~/.dotfiles/links/vimrc ~/.vimrc
ln -is ~/.dotfiles/links/gitignore ~/.gitignore
ln -is ~/.dotfiles/links/gitconfig ~/.gitconfig
ln -is ~/.dotfiles/links/tmux.conf ~/.tmux.conf


# macOS Preferences
# Speed up dock animation
defaults write com.apple.dock autohide-time-modifier -int 0

# Don't store screenshots on the desktop
defaults write com.apple.screencapture location ~/Dropbox/Screenshots


# Refresh things to read new config
killall Dock
source ~/.zshrc
