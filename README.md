# dotfiles

## install

```bash
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## how it works

`mise bootstrap` does everything, from `files/.config/mise/` (linked to `~/.config/mise`):

- `config.toml`: settings
- `conf.d/tools.toml`: CLI tools + runtimes
- `conf.d/packages.toml`: brew formulae + casks
- `conf.d/dotfiles.toml`: symlinks into `$HOME`
- `conf.d/macos.toml`: macos defaults
- `conf.d/hooks.toml`: extra steps (bin/ deps, herdr)
- `conf.d/tasks.toml`: `mise run cleanup`

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
