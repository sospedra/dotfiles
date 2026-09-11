#!/bin/sh
# Barebones dock. Linear and Notion are not installed by the bootstrap, so they are not here.
set -eu
eval "$(/opt/homebrew/bin/brew shellenv)"
dockutil --remove all --no-restart
for app in \
  "/System/Applications/Mail.app" \
  "/System/Applications/Calendar.app" \
  "/System/Applications/Music.app" \
  "/Applications/Telegram.app" \
  "/Applications/Zed.app" \
  "/Applications/Safari.app" \
  "/Applications/Claude.app" \
  "/Applications/iTerm.app" \
  "/Applications/Slack.app" \
  "/System/Applications/System Settings.app"; do
  if [ -d "$app" ]; then dockutil --add "$app" --no-restart; fi
done
dockutil --add "$HOME/Downloads" --view fan --display folder --no-restart
killall Dock
