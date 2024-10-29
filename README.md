# Anton's dotfiles

## Install

```
curl https://raw.githubusercontent.com/AntonNiklasson/dotfiles/master/install.sh | sh
```

### Link files

```
stow --target="$HOME" --dir="$HOME/.dotfiles/links" . --verbose --simulate
```
