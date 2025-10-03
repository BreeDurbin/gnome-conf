#!/bin/bash

# Check if a file path was provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <keybindings-file>"
    exit 1
fi

KEYBINDINGS_FILE="$1"

# Check if file exists
if [[ ! -f "$KEYBINDINGS_FILE" ]]; then
    echo "File $KEYBINDINGS_FILE not found!"
    exit 1
fi

# Read each line
while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Extract schema, key, and value
    schema=$(echo "$line" | awk '{print $1}')
    key=$(echo "$line" | awk '{print $2}')
    value=$(echo "$line" | awk '{$1=""; $2=""; print $0}' | sed 's/^ //')

    # Apply the keybinding
    gsettings set "$schema" "$key" "$value"
    echo "Set $schema $key to $value"
done < "$KEYBINDINGS_FILE"

echo "All keybindings applied!"
