#!/bin/bash

# Setup script for meta.md reminder hook in Claude Code

set -e

HOOK_SCRIPT="$(pwd)/meta-reminder-hook.py"
SETTINGS_FILE="$HOME/.claude/settings.local.json"

echo "Setting up meta.md reminder hook for Claude Code..."

# Create .claude directory if it doesn't exist
mkdir -p "$HOME/.claude"

# Check if hook script exists
if [[ ! -f "$HOOK_SCRIPT" ]]; then
    echo "Error: Hook script not found at $HOOK_SCRIPT"
    exit 1
fi

# Make hook script executable
chmod +x "$HOOK_SCRIPT"

# Create or update settings file
if [[ -f "$SETTINGS_FILE" ]]; then
    echo "Updating existing settings file: $SETTINGS_FILE"
    
    # Backup existing settings
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backup created: $SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Use jq to merge the hook configuration
    if command -v jq >/dev/null 2>&1; then
        TEMP_FILE=$(mktemp)
        jq --arg hook_path "$HOOK_SCRIPT" '
            .hooks.UserPromptSubmit = [
                {
                    "hooks": [
                        {
                            "type": "command",
                            "command": $hook_path
                        }
                    ]
                }
            ]
        ' "$SETTINGS_FILE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$SETTINGS_FILE"
    else
        echo "Warning: jq not found. You'll need to manually add the hook configuration."
        echo "Please add this to your $SETTINGS_FILE:"
        cat << EOF

{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_SCRIPT"
          }
        ]
      }
    ]
  }
}
EOF
        exit 1
    fi
else
    echo "Creating new settings file: $SETTINGS_FILE"
    cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_SCRIPT"
          }
        ]
      }
    ]
  }
}
EOF
fi

echo "✅ Hook configuration complete!"
echo "Hook script: $HOOK_SCRIPT"
echo "Settings file: $SETTINGS_FILE"
echo ""
echo "The hook will now remind you to consult meta.md when editing markdown files."
echo "Restart Claude Code for changes to take effect."