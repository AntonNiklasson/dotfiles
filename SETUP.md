# new machine setup (for agents)

You're a coding agent on a fresh Mac or Debian/Ubuntu box. Goal: this repo at `~/.dotfiles`, `./install.sh` run, everything working.

You can't answer interactive prompts (sudo password, GUI dialogs, `gh auth login`). For those, give the human the exact command to run in their own terminal and wait for them.

1. **git**: on linux, `sudo apt-get install -y git` (human runs it). On macos, if `xcode-select -p` fails, run `xcode-select --install`, ask the human to click through the dialog, wait until `xcode-select -p` succeeds.
2. **clone**: `git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles`, or `git -C ~/.dotfiles pull` if it exists.
3. **read** `README.md` and `files/.config/mise/` to see what gets installed.
4. **machine role**: ask the human whether this is a private or work machine. Private: `echo 'env = ["private"]' > ~/.dotfiles/files/.config/mise/miserc.local.toml`. Work: create it empty (`: > …`). `install.sh` skips its own question once the file exists.
5. **preview**: run `~/.dotfiles/install.sh --plan`. This prints the installer steps without applying them, plus a package preview when mise and the checkout are available. Look over the output with the human.
6. **install**: ask the human to run `~/.dotfiles/install.sh`. Safe to re-run after fixing something. Until `~/.zshrc` links to the repo, re-runs still use `--force-dotfiles` to finish interrupted first setups. After that, re-runs won't overwrite real files at link targets: if bootstrap stops on one, check it with the human, then `mise bootstrap --force-dotfiles`.
7. **verify** in a fresh zsh: `zsh -ic 'mise doctor; mise bootstrap status --missing; node -v; gh auth status'`. Fix what you can. Usual suspects: GitHub rate limits (`GITHUB_TOKEN=$(gh auth token)`), source-only formulae that fail to build, corporate proxy/Artifactory blocking downloads.
8. **report** what's left for the human: app sign-ins (1Password, Slack, Raycast, …), logging in to your coding agent again if its config moved to the dotfiles, `~/.zshrc.local`, SSH keys, logging out once on macos for keyboard + defaults.

9. **friction log**: keep a running list of confusing, broken, or surprising behavior outside the repo (for example `~/dotfiles-improvements.md`). Record commands, errors, and workarounds without credentials. Include unresolved items in the final report.

If you fix repository bugs during setup, follow `AGENTS.md`: pull first, work on main, and commit each focused change without asking. Ask before pushing. Machine-specific configuration belongs in gitignored local overrides.
