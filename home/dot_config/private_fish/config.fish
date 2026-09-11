# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# Asdf env

# Android env
set --export ANDROID_HOME $HOME/Library/Android/sdk
set -gx PATH $ANDROID_HOME/emulator $PATH;
set -gx PATH $ANDROID_HOME/tools $PATH;
set -gx PATH $ANDROID_HOME/tools/bin $PATH;
set -gx PATH $ANDROID_HOME/platform-tools $PATH;

# React Native env
set -x REACT_EDITOR zed

# Abbrs
abbr --add gm git checkout
abbr --add gf git pull
abbr --add gs git status
abbr --add gc git commit -m
abbr --add ga git add
abbr --add gp git push -u origin HEAD
abbr --add ns pnpm start
abbr --add nr pnpm run
abbr --add nrr pnpm run test:unit

# Composio CLI
set --export COMPOSIO_INSTALL_DIR "$HOME/.composio"
set --export PATH $COMPOSIO_INSTALL_DIR $PATH

# pnpm
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q -- "$PNPM_HOME/bin" $PATH
  set -gx PATH "$PNPM_HOME/bin" $PATH
end
# pnpm end


# Added by Antigravity CLI installer
set -gx PATH "$HOME/.local/bin" $PATH

# Go
set -gx PATH $HOME/go/bin $PATH;
set -gx PATH $HOME/.bb $PATH

fish_add_path $HOME/.groundcover/bin
