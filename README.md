# dotfiles

## install

With an agent:

```bash
curl -fsSL https://pi.dev/install.sh | sh
pi   # /login, then:
# set up this mac: follow https://raw.githubusercontent.com/AntonNiklasson/dotfiles/main/SETUP.md
```

Without:

```bash
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --dry-run   # preview
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
