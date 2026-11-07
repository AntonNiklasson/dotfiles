# dotfiles

## install

If you're an agent, follow [SETUP.md](SETUP.md).

```bash
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --plan      # preview installer steps and available package plan
./install.sh
```

## day to day

```bash
mise bootstrap --dry-run          # preview
mise bootstrap                    # apply
mise bootstrap status --missing   # what's out of sync
mise use -g <tool>                # add a CLI tool
mise bootstrap packages use -g brew-cask:<app>   # add a package
mise up                           # upgrade tools
mise bootstrap packages upgrade   # upgrade packages
mise run cleanup                  # preview removal of anything undeclared (--apply to remove)
```

Installer logs are saved per run to `~/.local/state/dotfiles/install-*.log`; the path is printed at startup and exit. `--plan` does not create a log.
