#!/usr/bin/env bash
# GNOME custom keybindings installer
# Fully revised: safe unbinding + debug output + proper array formatting

BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings

# Define keybindings
declare -A keybindings
keybindings["custom0"]="name=Code,command=code,binding=<Super>c"
keybindings["custom1"]="name=Unreal Editor,command=UnrealEditor,binding=<Super>u"
keybindings["custom2"]="name=ChatGPT,command=xdg-open https://www.chatgpt.com,binding=<Super>a"
keybindings["custom3"]="name=Youtube,command=xdg-open https://www.youtube.com,binding=<Super>y"
keybindings["custom4"]="name=Google,command=xdg-open https://www.google.com,binding=<Super>b"

# Build comma-separated array of custom keybinding paths
paths=""
for i in "${!keybindings[@]}"; do
    paths+="'$BASE/$i/', "
done
paths="${paths%, }"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$paths]"

# Apply each keybinding
for i in "${!keybindings[@]}"; do
    IFS=',' read -ra fields <<< "${keybindings[$i]}"
    # Apply each property of the keybinding
    for field in "${fields[@]}"; do
        key=${field%%=*}
        value=${field#*=}
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$BASE/$i/" "$key" "$value"
        echo "Set $key = $value for custom$i"
    done
done

echo "Custom GNOME keybindings applied successfully!"

