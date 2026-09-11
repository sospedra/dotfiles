# Project tokens live in pa. Export each on shell start. Nag if one is missing.
# conf.d runs before config.fish, so PATH is set here too.
set -g __secrets_map figma:FIGMA_TOKEN groundcover:GC_API_KEY

if status is-interactive
    fish_add_path -g /opt/homebrew/bin ~/.local/bin
    set -l missing
    for entry in $__secrets_map
        set -l parts (string split : $entry)
        set -l value (pa show $parts[1] 2>/dev/null)
        if test $status -eq 0 -a -n "$value"
            set -gx $parts[2] $value
        else
            set -a missing $parts[1]
        end
    end
    if test (count $missing) -gt 0
        echo "missing secrets: $missing. run: secrets"
    end
end
