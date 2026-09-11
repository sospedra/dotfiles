#!/bin/sh
set -eu
fish=/opt/homebrew/bin/fish
grep -qx "$fish" /etc/shells || echo "$fish" | sudo tee -a /etc/shells >/dev/null
current=$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')
[ "$current" = "$fish" ] || sudo chsh -s "$fish" "$USER"
# fisher is not tracked. Install it, then install the plugins listed in fish_plugins.
"$fish" -c 'if not test -f ~/.config/fish/functions/fisher.fish
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
end
fisher update'
