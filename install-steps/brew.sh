#! /bin/bash

# Install Homebrew if needed
if ! command -v brew &> /dev/null
then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add taps
brew tap homebrew/cask-fonts
brew tap homebrew/cask-drivers
brew tap domt4/autoupdate
brew tap phrase/brewed

# Install CLI tools
brew install -f \
	bat \
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
	postgresql \
	rename \
	terminal-notifier \
	the_silver_searcher \
	tmux \
	tree \
	vim \
	yarn \
	zsh \
	zsh-completions \
	svn \
	phrase \
;

# Install GUI applications
brew install --cask \
	appcleaner \
	discord \
	dropbox \
	fantastical \
	figma \
	firefox \
	font-source-code-pro \
	google-chrome \
	google-cloud-sdk \
	hiddenbar \
	iterm2 \
	kap \
	logitech-options \
	nordvpn \
	notion \
	numi \
	postico \
	runjs \
	sequel-pro \
	slack \
	sonos \
	spotify \
	raycast \
	telegram \
	tuple \
	visual-studio-code \
	vlc \
	1password \
	obsidian \
	intellij-idea-ce \
;
