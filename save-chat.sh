#!/bin/bash

# Save latest Claude Code chat session with timestamp

# Get current directory name for project identification
PROJECT_DIR=$(basename "$(pwd)")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CLAUDE_PROJECT_DIR="/home/bowei/.claude/projects/$(pwd | sed 's|/|-|g')"

# Find the most recent chat session file
LATEST_CHAT=$(ls -t "$CLAUDE_PROJECT_DIR"/*.jsonl 2>/dev/null | head -1)

if [ -z "$LATEST_CHAT" ]; then
    echo "No chat session found for current project"
    exit 1
fi

# Create chat history directory if it doesn't exist
mkdir -p "chat-history"

# Copy the latest chat session with timestamp
CHAT_FILENAME="chat_${TIMESTAMP}.jsonl"
cp "$LATEST_CHAT" "chat-history/$CHAT_FILENAME"

echo "Copied chat session to: chat-history/$CHAT_FILENAME"

# Commit the chat history
#git add "chat-history/$CHAT_FILENAME"
#git commit -m "Add chat session from $TIMESTAMP
#
#🤖 Generated with [Claude Code](https://claude.ai/code)
#
#Co-Authored-By: Claude <noreply@anthropic.com>"
#
#echo "Committed chat session to git"
