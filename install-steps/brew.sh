#! /bin/bash

# Install Homebrew if needed
if ! command -v brew &>/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add taps
brew tap homebrew/cask-fonts
brew tap domt4/autoupdate
brew tap phrase/brewed

# Install CLI tools
brew install -f \
	coreutils \
	diff-so-fancy \
	docker-compose \
	fzf \
	gh \
	git-extras \
	httpie \
	jq \
	mas \
	node \
	phrase \
	postgresql \
	rename \
	terminal-notifier \
	tmux \
	tree \
	vim \
	zsh \
	zsh-completions \
	;

# Install GUI applications
brew install --cask \
	1password \
	appcleaner \
	discord \
	dropbox \
	figma \
	firefox \
	google-chrome \
	google-cloud-sdk \
	hiddenbar \
	intellij-idea-ce \
	iterm2 \
	kap \
	logitech-options \
	messenger \
	numi \
	obsidian \
	postico \
	raycast \
	slack \
	sonos \
	spotify \
	tuple \
	visual-studio-code \
	;
