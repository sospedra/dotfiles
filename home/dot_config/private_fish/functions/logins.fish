function logins --description 'GitHub, read:packages scope, ssh key, GitHub Packages for npm, npm login'
    gh auth status >/dev/null 2>&1; or gh auth login
    gh auth status 2>&1 | grep -q 'read:packages'; or gh auth refresh -h github.com -s read:packages
    gh auth setup-git
    if not test -f ~/.ssh/id_ed25519
        ssh-keygen -t ed25519 -C (hostname) -f ~/.ssh/id_ed25519
    end
    gh ssh-key list 2>/dev/null | grep -q (hostname); or gh ssh-key add ~/.ssh/id_ed25519.pub --title (hostname)
    npm config set '//npm.pkg.github.com/:_authToken' '${GH_PACKAGES_AUTH_TOKEN}'
    set -gx GH_PACKAGES_AUTH_TOKEN (gh auth token)
    npm whoami >/dev/null 2>&1; or npm login
    echo "logins: done"
end
