function dots --description 'Save local edits to the repo, apply, commit hand edits, push'
    chezmoi re-add
    chezmoi apply
    if test -n "$(chezmoi git -- status --porcelain)"
        chezmoi git -- add -A
        chezmoi git -- commit -m "update"
        chezmoi git -- push
    end
    chezmoi status
end
