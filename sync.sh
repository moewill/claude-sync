#!/bin/bash

# Claude Sync - Update local commands, agents, and CLAUDE.md from repository
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
CLAUDE_MD_FILE="$HOME/.claude/CLAUDE.md"

echo "🔄 Syncing Claude configuration..."

# Create .claude directories if they don't exist
if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
    echo "📁 Creating ~/.claude/commands directory"
    mkdir -p "$CLAUDE_COMMANDS_DIR"
fi

if [ ! -d "$CLAUDE_AGENTS_DIR" ]; then
    echo "📁 Creating ~/.claude/agents directory"
    mkdir -p "$CLAUDE_AGENTS_DIR"
fi

# Pull latest changes
echo "📥 Pulling latest changes from repository"
cd "$REPO_DIR"
git pull origin main

# Copy commands to local directory
if [ -d "commands" ]; then
    echo "📋 Copying commands to ~/.claude/commands"
    rsync -aP commands/ "$CLAUDE_COMMANDS_DIR/"
fi

# Copy agents to local directory
if [ -d "agents" ]; then
    echo "🤖 Copying agents to ~/.claude/agents"
    rsync -aP agents/ "$CLAUDE_AGENTS_DIR/"
fi

# Copy claude.md to CLAUDE.md in ~/.claude/
if [ -f "claude.md" ]; then
    echo "⚙️  Copying claude.md to ~/.claude/CLAUDE.md"
    cp claude.md "$CLAUDE_MD_FILE"
fi

echo "✅ Sync complete! Configuration updated in ~/.claude/"
echo ""
echo "📂 Available commands:"
if [ -d "$CLAUDE_COMMANDS_DIR" ] && ls -1 "$CLAUDE_COMMANDS_DIR"/*.md &>/dev/null; then
    ls -1 "$CLAUDE_COMMANDS_DIR"/*.md | xargs -n 1 basename
else
    echo "  No commands found"
fi

echo ""
echo "🤖 Available agents:"
if [ -d "$CLAUDE_AGENTS_DIR" ] && ls -1 "$CLAUDE_AGENTS_DIR"/*.md &>/dev/null; then
    ls -1 "$CLAUDE_AGENTS_DIR"/*.md | xargs -n 1 basename
else
    echo "  No agents found"
fi

echo ""
echo "⚙️  Global configuration:"
if [ -f "$CLAUDE_MD_FILE" ]; then
    echo "  CLAUDE.md updated"
else
    echo "  No CLAUDE.md found"
fi
