# Once a day, run the local checks. Every nag ends with the command to run.
if status is-interactive
    fish_add_path -g /opt/homebrew/bin ~/.local/bin
    set -l stamp ~/.cache/dotfiles/last-check
    set -l now (date +%s)
    set -l last 0
    test -f $stamp; and set last (cat $stamp)
    if test (math $now - $last) -gt 86400
        mkdir -p (dirname $stamp)
        echo $now > $stamp
        __dotfiles_check
    end
end
