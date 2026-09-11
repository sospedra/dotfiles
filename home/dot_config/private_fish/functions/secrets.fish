function secrets --description 'Store missing pa entries, from universal vars or one paste'
    set -l pa_dir ~/.local/share/pa
    pa list >/dev/null 2>&1
    for entry in $__secrets_map
        set -l parts (string split : $entry)
        set -l name $parts[1]
        set -l var $parts[2]
        if pa show $name >/dev/null 2>&1
            continue
        end
        set -l value
        if set -qU $var
            set value $$var
            echo "$name: moving universal var $var into pa"
        else
            read -s -l -P "$name: paste the token, then Enter: " value
        end
        if test -z "$value"
            echo "$name: empty, skipped"
            continue
        end
        if printf '%s\n' $value | age --encrypt -R $pa_dir/recipients -o $pa_dir/passwords/$name.age
            set -eU $var
            set -gx $var (pa show $name)
            echo "$name: stored"
        else
            echo "$name: age failed"
        end
    end
end
