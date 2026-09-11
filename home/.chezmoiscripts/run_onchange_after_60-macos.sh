#!/bin/sh
# Changed macOS defaults only. Find a key: `defaults read > before`, change it by hand,
# `defaults read > after`, diff, add the `defaults write` line here.
set -eu
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.config/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
