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

## how it works

`mise bootstrap` does everything, from `files/.config/mise/` (linked to `~/.config/mise`):

- `config.toml`: settings
- `miserc.toml`: turns on `*.macos.toml` / `*.linux.toml` loading only on that OS
- `conf.d/tools.toml`: CLI tools + runtimes
- `conf.d/packages.macos.toml`: brew formulae + casks
- `conf.d/packages.linux.toml`: apt packages
- `conf.d/defaults.macos.toml`: macos defaults, login items, caps lock agent
- `conf.d/user.linux.toml`: zsh as login shell
- `conf.d/dotfiles.toml`: symlinks into `$HOME`
- `conf.d/hooks.toml`: extra steps (bin/ deps, herdr)
- `conf.d/tasks.toml`: `mise run cleanup` (macos)

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
