#!/bin/sh
# Guard only. install.sh installs Homebrew before chezmoi runs.
set -eu
[ -x /opt/homebrew/bin/brew ] && exit 0
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
