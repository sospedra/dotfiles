function brews --description 'Decide each undecided name: k keeps it in ~/.Brewfile, s skips it forever'
    set -l candidates (__brews_candidates)
    if test (count $candidates) -eq 0
        echo "nothing undecided"
        return 0
    end
    set -l casks (brew list --cask 2>/dev/null)
    set -l maslist
    command -q mas; and set maslist (mas list 2>/dev/null)
    for name in $candidates
        read -l -P "$name   keep / skip / later > " answer
        switch $answer
            case k keep
                set -l re (string escape --style=regex -- $name)
                if contains -- $name $casks
                    echo "cask \"$name\"" >> ~/.Brewfile
                else if set -l m (string match -r "^\s*(\d+)\s+$re\s+\(" -- $maslist)
                    echo "mas \"$name\", id: $m[2]" >> ~/.Brewfile
                else
                    echo "brew \"$name\"" >> ~/.Brewfile
                end
                echo "$name: kept"
            case s skip
                echo $name >> ~/.Brewfile.skip
                echo "$name: skipped"
            case '*'
                echo "$name: later"
        end
    end
    dots
end
