# new machine setup (for agents)

You're a coding agent on a fresh Mac or Debian/Ubuntu box. Goal: this repo at `~/.dotfiles`, `./install.sh` run, everything working.

You can't answer interactive prompts (sudo password, GUI dialogs, `gh auth login`). For those, give the human the exact command to run in their own terminal and wait for them.

1. **git**: on linux, `sudo apt-get install -y git` (human runs it). On macos, if `xcode-select -p` fails, run `xcode-select --install`, ask the human to click through the dialog, wait until `xcode-select -p` succeeds.
2. **clone**: `git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles`, or `git -C ~/.dotfiles pull` if it exists.
3. **read** `README.md` and `files/.config/mise/` to see what gets installed.
4. **machine role**: ask the human whether this is a private or work machine. Private: `echo 'env = ["private"]' > ~/.dotfiles/files/.config/mise/miserc.local.toml`. Work: create it empty (`: > …`). `install.sh` skips its own question once the file exists.
5. **preview**: ask the human to run `~/.dotfiles/install.sh --dry-run`. Look over the output with them.
6. **install**: ask the human to run `~/.dotfiles/install.sh`. It's safe to re-run after fixing something.
7. **pi login**: pi keeps its config in `~/.config/pi/agent` once the dotfiles are linked, so copy `~/.pi/agent/auth.json` there if it's missing.
8. **verify** in a fresh zsh: `zsh -ic 'mise doctor; mise bootstrap status --missing; node -v; gh auth status'`. Fix what you can. Usual suspects: GitHub rate limits (`GITHUB_TOKEN=$(gh auth token)`), source-only formulae that fail to build, corporate proxy/Artifactory blocking downloads.
9. **report** what's left for the human: app sign-ins (1Password, Slack, Raycast, …), `~/.zshrc.local`, SSH keys, logging out once on macos for keyboard + defaults.

Don't commit or push in this repo without asking.
