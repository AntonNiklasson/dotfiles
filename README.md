# dotfiles

## install

```bash
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## how it works

`mise bootstrap` does everything, from `files/.config/mise/config.toml`:

- `[bootstrap.packages]`: brew formulae, casks, mac app store apps
- `[dotfiles]`: symlinks into `$HOME`
- `[bootstrap.macos.defaults]`: macos settings
- `[tools]`: CLI tools + runtimes
- `[bootstrap.hooks]`: everything else

## day to day

```bash
mise bootstrap --dry-run          # preview
mise bootstrap                    # apply
mise bootstrap status --missing   # what's out of sync
mise use -g <tool>                # add a CLI tool
mise bootstrap packages use -g brew-cask:<app>   # add a package
mise up                           # upgrade tools
mise bootstrap packages upgrade   # upgrade packages
```
