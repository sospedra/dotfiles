#!/bin/sh
# Bootstrap a fresh Mac:
#   sh -c "$(curl -fsLS https://raw.githubusercontent.com/sospedra/dotfiles/main/install.sh)"
set -eu

sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null & )

open -a "App Store"
printf 'Sign in to the App Store, then press Enter. '
read -r _

if [ ! -x /opt/homebrew/bin/brew ]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

brew list chezmoi >/dev/null 2>&1 || brew install chezmoi
chezmoi init --apply sospedra
