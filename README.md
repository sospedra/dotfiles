# dotfiles

## Install

One command on a fresh Mac:

    sh -c "$(curl -fsLS https://raw.githubusercontent.com/sospedra/dotfiles/main/install.sh)"

It asks three things in the first minute: your password, the App Store sign-in (press Enter
after), your git email (Enter keeps the default). Then wait 15 to 30 minutes.

## After install

1. Open a new terminal. Run what it says: `logins`, then `secrets`.
2. Safari > Settings > Extensions: enable Ghostery, Consent-O-Matic, Qwant, Hush.
3. Coming from another Mac: Raycast > Import Settings and Data, pick the file in iCloud Drive.

## Daily use

| Situation | Command |
|---|---|
| I edited a tracked file in place | `dots` |
| Edit a tracked file | `chezmoi edit <path>` (saves and applies on exit) |
| Track a new file | `chezmoi add <path>` |
| Stop tracking, keep the file | `chezmoi forget <path>` |
| The shell says drift | run the printed command |
| I installed a tool for a project | nothing. Tomorrow the shell says undecided |
| The shell says undecided | `brews`. `k` every Mac, `s` never again, Enter later |
| Add a tool to every Mac | `chezmoi edit ~/.Brewfile` |
| Add a runtime or bump a version | `chezmoi edit ~/.tool-versions` |
| Change the dock or a macOS default | `chezmoi cd`, edit the script in `home/.chezmoiscripts/`, `dots` |
| New secret | add `name:VAR` to the map in `conf.d/secrets.fish`, `dots`, `secrets` |
| What would change | `chezmoi diff` |
| Health | `chezmoi doctor` |

## Leaving a Mac

    moveout

Fix what it prints, rerun until it says `ok`. Then do the manual list it prints.

## Uninstall

    chezmoi purge --binary

Removes chezmoi, its state and the source repo. Files in `~` stay as they are.

## Inventory

- Base: Xcode Command Line Tools, Homebrew, chezmoi.
- Brews (33): age, asdf, autoconf, chezmoi, cliclick, cocoapods, dockutil, exiftool, ffmpeg, fish,
  fonttools, gh, git-filter-repo, gitleaks, gmp, gnupg, grpcurl, htop, libyaml, mas, mkcert,
  openssl@3, oxipng, pinentry-mac, pngquant, poppler, pre-commit, protobuf, readline, shellcheck,
  tectonic, watchman, xz.
- Casks (15): affinity, android-commandlinetools, claude, codex, docker-desktop, google-chrome,
  hush, iterm2, monitorcontrol, protonvpn, raycast, slack, telegram, yaak, zed.
- App Store (5): Ghostery, Consent-O-Matic, Qwant for Safari, Amphetamine, Klack.
- asdf: what `~/.tool-versions` lists.
- fisher: fisher, z.
- Zed extensions: astro, catppuccin-icons, dockerfile, git-firefly, glsl, html, proto,
  rose-pine-theme, terraform, toml.
- pa (password store) into `~/.local/bin`.

## Never tracked

`fish_variables`, fisher files, `.npmrc`, ssh keys, `~/.local/share/pa`, `gh/hosts.yml`,
`~/.config/sops`, `~/.claude.json`, Claude and Codex state, `~/.config/zed/{conversations,prompts}`,
app data under `~/Library` except the iTerm2 plist.
