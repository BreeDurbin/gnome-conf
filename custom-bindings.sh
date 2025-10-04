#!/usr/bin/env bash
# GNOME custom keybindings installer
# Updated: unbind conflicting shortcuts and echo actions

BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings

# Define keybindings
declare -A keybindings
keybindings["custom0"]="name='Code',command='code',binding='<Super>c'"
keybindings["custom1"]="name='Unreal Editor',command='UnrealEditor',binding='<Super>u'"
keybindings["custom2"]="name='ChatGPT',command='xdg-open https://www.chatgpt.com',binding='<Super>a'"
keybindings["custom3"]="name='Youtube',command='xdg-open https://www.youtube.com',binding='<Super>y'"
keybindings["custom4"]="name='Google',command='xdg-open https://www.google.com',binding='<Super>b'"

# Function to unbind existing keybindings with the same key
unbind_existing() {
    local binding="$1"
    local schemas=(
        "org.gnome.settings-daemon.plugins.media-keys"
        "org.gnome.shell.keybindings"
        "org.gnome.mutter"
    )

    echo "Checking for conflicts with '$binding'..."

    for schema in "${schemas[@]}"; do
        keys=$(gsettings list-keys "$schema")
        for key in $keys; do
            # Only process array-typed keys
            type=$(gsettings range "$schema" "$key" 2>/dev/null)
            if [[ $type == *"array"* ]]; then
                current=$(gsettings get "$schema" "$key")
                # Remove leading/trailing brackets
                arr="${current#[}"
                arr="${arr%]}"
                # Split by comma
                IFS=',' read -ra vals <<< "$arr"
                new_vals=()
                changed=false
                for val in "${vals[@]}"; do
                    val_trimmed=$(echo "$val" | xargs)  # remove whitespace
                    val_trimmed=${val_trimmed//\'/}      # remove single quotes
                    if [[ "$val_trimmed" == "$binding" ]]; then
                        echo "Unbinding '$binding' from $schema:$key (was $current)"
                        changed=true
                        continue
                    fi
                    new_vals+=("'$val_trimmed'")
                done
                if $changed; then
                    new_value="[${new_vals[*]}]"
                    gsettings set "$schema" "$key" "$new_value"
                fi
            fi
        done
    done
}



# Register paths
# Build comma-separated array of paths for gsettings
paths=""
for i in "${!keybindings[@]}"; do
    paths+="'$BASE/$i/', "
done
# Remove trailing comma+space
paths="${paths%, }"

# Set the custom-keybindings array
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$paths]"


# Apply each binding
for i in "${!keybindings[@]}"; do
    IFS=',' read -ra fields <<< "${keybindings[$i]}"
    # Extract binding first to unbind
    for field in "${fields[@]}"; do
        key=${field%%=*}
        value=${field#*=}
        if [[ "$key" == "binding" ]]; then
            echo "Processing new binding: $value"
            unbind_existing "$value"
        fi
    done

    # Apply each property
    for field in "${fields[@]}"; do
        key=${field%%=*}
        value=${field#*=}
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$BASE/$i/" "$key" "$value"
        echo "Set $key = $value for custom$i"
    done
done

echo "Custom GNOME keybindings applied successfully!"
