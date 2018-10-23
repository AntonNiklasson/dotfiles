# Keyboard Setup

## 1. Input Sources

![Input Sources](assets/input-sources.png)

## 2. Key Repeat

In order to have that quick and responsive key repeat you need to disable the built in "accent character popup" that appear as you hold a few of the letter keys.

```
defaults write -g ApplePressAndHoldEnabled -bool false
```

You need to either logout or restart the computer for this to take effect in the whole system.

On top of that, make sure to increase the frequency and initial delay for the repeating:

![Key Repeat](assets/key-repeat.png)
