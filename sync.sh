#!/bin/bash

# Claude Sync - Update local commands from repository
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"

echo "🔄 Syncing Claude commands..."

# Create .claude/commands directory if it doesn't exist
if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
    echo "📁 Creating ~/.claude/commands directory"
    mkdir -p "$CLAUDE_COMMANDS_DIR"
fi

# Pull latest changes
echo "📥 Pulling latest changes from repository"
cd "$REPO_DIR"
git pull origin main

# Copy commands to local directory
echo "📋 Copying commands to ~/.claude/commands"
cp -v commands/*.md "$CLAUDE_COMMANDS_DIR/"

echo "✅ Sync complete! Commands updated in ~/.claude/commands"
echo ""
echo "📂 Available commands:"
ls -1 "$CLAUDE_COMMANDS_DIR"/*.md | xargs -n 1 basename