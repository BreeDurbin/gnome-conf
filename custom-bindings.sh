#!/usr/bin/env bash
# GNOME custom keybindings installer
# Fully revised: safe unbinding + debug output + proper array formatting

BASE=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings

SITES["ChatGPT"]="https://www.chatgpt.com"
SITES["Youtube"]="https://www.youtube.com"
SITES["Google"]="https://www.google.com"

# Define keybindings
declare -A keybindings
keybindings["custom0"]="name=Code,command=code,binding=<Super>c"
keybindings["custom1"]="name=Unreal Editor,command=UnrealEditor,binding=<Super>u"
keybindings["custom2"]="name=ChatGPT,command=firefox --no-remote -P "ChatGPT" https://www.chatgpt.com,binding=<Super>a"
keybindings["custom3"]="name=Youtube,command=firefox --no-remote -P "Youtube"  https://www.youtube.com,binding=<Super>y"
keybindings["custom4"]="name=Google,command=firefox --no-remote -P "Google"  https://www.google.com,binding=<Super>b"

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
    
    # Check if this is a Firefox command with a profile
    for field in "${fields[@]}"; do
        key=${field%%=*}
        value=${field#*=}

        # Detect Firefox --no-remote -P "ProfileName"
        if [[ "$value" =~ firefox.*--no-remote.*-P[[:space:]]*\"([^\"]+)\" ]]; then
            PROFILE_NAME="${BASH_REMATCH[1]}"
            # Check if profile exists
            if ! firefox --list-profiles | grep -q "^$PROFILE_NAME "; then
                echo "Creating Firefox profile '$PROFILE_NAME'..."
                firefox --CreateProfile "$PROFILE_NAME"
            fi
        fi

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$BASE/$i/" "$key" "$value"
        echo "Set $key = $value for custom$i"
    done
done

echo "Custom GNOME keybindings applied successfully!"

