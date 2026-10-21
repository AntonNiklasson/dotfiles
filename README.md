# dotfiles

## install

```bash
git clone https://github.com/AntonNiklasson/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## update brewfile

```bash
brew bundle dump --file=~/.dotfiles/Brewfile --force
```

## tools

- CLI tools + runtimes: mise, `files/.config/mise/config.toml`. add with `mise use -g <tool>`, upgrade with `mise up`
- casks, mas apps, rest: Brewfile
