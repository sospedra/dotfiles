function __dotfiles_check --description 'Daily nags: logins, undecided brews, drift'
    gh auth token >/dev/null 2>&1; or echo "gh: not logged in. run: logins"
    grep -q '//registry.npmjs.org/:_authToken' ~/.npmrc 2>/dev/null; or echo "npm: not logged in. run: logins"

    set -l undecided (__brews_candidates)
    if test (count $undecided) -gt 0
        echo "brew: "(count $undecided)" undecided. run: brews"
    end

    set -l drift (chezmoi status 2>/dev/null | string replace -r '^.. ' '')
    if test (count $drift) -gt 3
        echo "drift: "(count $drift)" files. see: chezmoi status. keep all: dots"
    else
        for rel in $drift
            set -l path ~/$rel
            echo "drift: $path"
            echo "  keep local change:  chezmoi re-add $path"
            echo "  restore tracked:    chezmoi apply $path"
            echo "  stop tracking:      chezmoi forget $path"
            echo "  see:                chezmoi diff $path"
        end
    end
end
