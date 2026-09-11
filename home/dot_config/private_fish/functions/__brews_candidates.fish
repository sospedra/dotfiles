function __brews_candidates --description 'Installed brew, cask and mas names not in ~/.Brewfile or ~/.Brewfile.skip'
    set -l declared (grep -oE '^(brew|cask|mas) "[^"]+"' ~/.Brewfile 2>/dev/null | string replace -r '^\S+ "(.+)"$' '$1')
    set -l skipped
    test -f ~/.Brewfile.skip; and set skipped (string trim < ~/.Brewfile.skip | string match -v '')
    for name in (brew leaves -r 2>/dev/null) (brew list --cask 2>/dev/null)
        contains -- $name $declared $skipped; or echo $name
    end
    if command -q mas
        for line in (mas list 2>/dev/null)
            set -l name (string replace -r '^\s*(\d+)\s+(.+?)\s+\(.*\)$' '$2' -- $line)
            contains -- $name $declared $skipped; or echo $name
        end
    end
end
