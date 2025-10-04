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
    for schema in org.gnome.settings-daemon.plugins.media-keys custom-keybinding; do
        # Check default shortcuts
        existing=$(gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys | grep "$binding")
        if [[ -n "$existing" ]]; then
            echo "Unbinding existing binding: $existing"
            # Reset it to empty (unbind)
            # This resets keys globally; be cautious
            gsettings set org.gnome.settings-daemon.plugins.media-keys "$schema" "[]"
        fi
    done
}

# Register paths
paths=$(printf "'$BASE/%s/' " "${!keybindings[@]}")
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
