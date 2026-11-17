#!/usr/bin/env bash
set -euo pipefail

pattern='polymarket|polyarchy|notion[.]so'

hits=$(
  git diff --cached -U0 --no-color -- . \
    ':!.pre-commit-config.yaml' ':!hooks/no-work-content.sh' ':!home/.chezmoiignore' |
    awk -v re="$pattern" '
      /^\+\+\+ / { file = substr($0, 7); next }
      /^\+/ && tolower($0) ~ re { print file ": " substr($0, 2) }
    '
)

if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  echo "Blocked: these added lines hold work content and the repo is public."
  echo "Fix: edit the lines, or run 'chezmoi forget <file>' and add the file to .chezmoiignore."
  exit 1
fi
