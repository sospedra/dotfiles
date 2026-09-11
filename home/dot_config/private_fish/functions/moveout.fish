function moveout --description 'Readiness check before leaving this Mac'
    set -l fail 0
    if test -n "$(chezmoi status 2>/dev/null)"
        echo "drift: run dots"
        set fail 1
    end
    if test -n "$(chezmoi git -- status --porcelain)"; or test -n "$(chezmoi git -- log '@{u}..HEAD' --oneline 2>/dev/null)"
        echo "unpushed: run dots"
        set fail 1
    end
    test $fail -eq 0; and echo "ok. before you wipe:"
    echo "  iTerm2: Settings > General > Settings > Save Now, then dots"
    echo "  Raycast: Export Settings and Data to iCloud Drive. Remember the passphrase."
    echo "  Copy: ~/labs ~/Downloads ~/Desktop ~/Documents"
    return $fail
end
