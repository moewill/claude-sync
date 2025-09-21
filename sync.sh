#!/bin/bash

# Claude Sync - Intelligent sync for commands, agents, and CLAUDE.md
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
CLAUDE_MD_FILE="$HOME/.claude/CLAUDE.md"

# Default sync mode
SYNC_MODE="bidirectional"

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Sync Claude configuration between repository and local directories"
    echo ""
    echo "OPTIONS:"
    echo "  --local-to-repo     Sync from local (~/.claude) to repository"
    echo "  --repo-to-local     Sync from repository to local (~/.claude)"
    echo "  --bidirectional     Two-way sync based on file modification times"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "SYNC MODES:"
    echo "  repo-to-local:   Updates local files with repository versions"
    echo "  local-to-repo:   Updates repository with local file versions"
    echo "  bidirectional:   Syncs newer files in both directions, creates missing files [default]"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --local-to-repo)
            SYNC_MODE="local-to-repo"
            shift
            ;;
        --repo-to-local)
            SYNC_MODE="repo-to-local"
            shift
            ;;
        --bidirectional)
            SYNC_MODE="bidirectional"
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to preview bidirectional sync changes
preview_sync_changes() {
    echo ""
    echo "🔍 Preview of changes for bidirectional sync:"
    echo ""

    # Preview agents
    echo "🤖 Agent files:"
    local found_agents=false

    # Get all unique agent files from both locations
    local all_agents=()
    if [ -d "$CLAUDE_AGENTS_DIR" ]; then
        while IFS= read -r -d '' file; do
            all_agents+=("$(basename "$file")")
        done < <(find "$CLAUDE_AGENTS_DIR" -name "*.md" -print0 2>/dev/null || true)
    fi

    if [ -d "$REPO_DIR/agents" ]; then
        while IFS= read -r -d '' file; do
            local basename_file="$(basename "$file")"
            if [[ ! " ${all_agents[*]} " =~ " ${basename_file} " ]]; then
                all_agents+=("$basename_file")
            fi
        done < <(find "$REPO_DIR/agents" -name "*.md" -print0 2>/dev/null || true)
    fi

    # Preview each agent file
    for agent in "${all_agents[@]}"; do
        local local_file="$CLAUDE_AGENTS_DIR/$agent"
        local repo_file="$REPO_DIR/agents/$agent"

        if [[ -f "$local_file" && -f "$repo_file" ]]; then
            if [[ "$local_file" -nt "$repo_file" ]]; then
                echo "  📤 $agent (local → repo)"
                found_agents=true
            elif [[ "$repo_file" -nt "$local_file" ]]; then
                echo "  📥 $agent (repo → local)"
                found_agents=true
            else
                echo "  ✓ $agent (up to date)"
            fi
        elif [[ -f "$local_file" ]]; then
            echo "  📤 $agent (creating in repo)"
            found_agents=true
        elif [[ -f "$repo_file" ]]; then
            echo "  📥 $agent (creating locally)"
            found_agents=true
        fi
    done

    if [ "$found_agents" = false ] && [ ${#all_agents[@]} -eq 0 ]; then
        echo "  No agent files found"
    fi

    # Preview CLAUDE.md
    echo ""
    echo "⚙️  Configuration file:"
    local local_config="$CLAUDE_MD_FILE"
    local repo_config="$REPO_DIR/claude.md"

    if [[ -f "$local_config" && -f "$repo_config" ]]; then
        if [[ "$local_config" -nt "$repo_config" ]]; then
            echo "  📤 CLAUDE.md (local → repo)"
        elif [[ "$repo_config" -nt "$local_config" ]]; then
            echo "  📥 claude.md (repo → local)"
        else
            echo "  ✓ CLAUDE.md (up to date)"
        fi
    elif [[ -f "$local_config" ]]; then
        echo "  📤 CLAUDE.md (creating in repo)"
    elif [[ -f "$repo_config" ]]; then
        echo "  📥 claude.md (creating locally)"
    else
        echo "  No configuration files found"
    fi

    echo ""
}

# Function to get user confirmation
confirm_sync() {
    echo -n "Do you want to proceed with these changes? [y/N]: "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            echo "Sync cancelled."
            exit 0
            ;;
    esac
}

# Function to compare and sync files based on modification time
sync_file_bidirectional() {
    local local_file="$1"
    local repo_file="$2"
    local file_type="$3"

    if [[ -f "$local_file" && -f "$repo_file" ]]; then
        if [[ "$local_file" -nt "$repo_file" ]]; then
            echo "  📤 $file_type: $(basename "$local_file") (local → repo)"
            cp "$local_file" "$repo_file"
        elif [[ "$repo_file" -nt "$local_file" ]]; then
            echo "  📥 $file_type: $(basename "$repo_file") (repo → local)"
            cp "$repo_file" "$local_file"
        else
            echo "  ✓ $file_type: $(basename "$local_file") (up to date)"
        fi
    elif [[ -f "$local_file" ]]; then
        echo "  📤 $file_type: $(basename "$local_file") (creating in repo)"
        cp "$local_file" "$repo_file"
    elif [[ -f "$repo_file" ]]; then
        echo "  📥 $file_type: $(basename "$repo_file") (creating locally)"
        cp "$repo_file" "$local_file"
    fi
}

# Function to sync agents in local-to-repo mode
sync_agents_local_to_repo() {
    echo "🤖 Syncing agents (local → repo)"
    if [ -d "$CLAUDE_AGENTS_DIR" ]; then
        mkdir -p "$REPO_DIR/agents"
        rsync -aP "$CLAUDE_AGENTS_DIR/" "$REPO_DIR/agents/"
    else
        echo "  No local agents directory found"
    fi
}

# Function to sync agents in repo-to-local mode
sync_agents_repo_to_local() {
    echo "🤖 Syncing agents (repo → local)"
    if [ -d "$REPO_DIR/agents" ]; then
        mkdir -p "$CLAUDE_AGENTS_DIR"
        rsync -aP "$REPO_DIR/agents/" "$CLAUDE_AGENTS_DIR/"
    else
        echo "  No agents directory in repository"
    fi
}

# Function to sync agents bidirectionally
sync_agents_bidirectional() {
    echo "🤖 Syncing agents (bidirectional)"

    # Create directories if they don't exist
    mkdir -p "$CLAUDE_AGENTS_DIR"
    mkdir -p "$REPO_DIR/agents"

    # Get all unique agent files from both locations
    local all_agents=()
    if [ -d "$CLAUDE_AGENTS_DIR" ]; then
        while IFS= read -r -d '' file; do
            all_agents+=("$(basename "$file")")
        done < <(find "$CLAUDE_AGENTS_DIR" -name "*.md" -print0 2>/dev/null || true)
    fi

    if [ -d "$REPO_DIR/agents" ]; then
        while IFS= read -r -d '' file; do
            local basename_file="$(basename "$file")"
            if [[ ! " ${all_agents[*]} " =~ " ${basename_file} " ]]; then
                all_agents+=("$basename_file")
            fi
        done < <(find "$REPO_DIR/agents" -name "*.md" -print0 2>/dev/null || true)
    fi

    # Sync each agent file
    for agent in "${all_agents[@]}"; do
        sync_file_bidirectional "$CLAUDE_AGENTS_DIR/$agent" "$REPO_DIR/agents/$agent" "Agent"
    done
}

# Create .claude directories if they don't exist
if [ ! -d "$CLAUDE_COMMANDS_DIR" ]; then
    echo "📁 Creating ~/.claude/commands directory"
    mkdir -p "$CLAUDE_COMMANDS_DIR"
fi

if [ ! -d "$CLAUDE_AGENTS_DIR" ]; then
    echo "📁 Creating ~/.claude/agents directory"
    mkdir -p "$CLAUDE_AGENTS_DIR"
fi

echo "🔄 Syncing Claude configuration ($SYNC_MODE mode)..."

# Pull latest changes for repo-to-local and bidirectional modes
if [[ "$SYNC_MODE" == "repo-to-local" || "$SYNC_MODE" == "bidirectional" ]]; then
    echo "📥 Pulling latest changes from repository"
    cd "$REPO_DIR"
    git pull origin main
fi

# Sync based on mode
case $SYNC_MODE in
    "local-to-repo")
        # Commands (always repo-to-local for now)
        if [ -d "$REPO_DIR/commands" ]; then
            echo "📋 Syncing commands (repo → local)"
            rsync -aP "$REPO_DIR/commands/" "$CLAUDE_COMMANDS_DIR/"
        fi

        # Agents
        sync_agents_local_to_repo

        # CLAUDE.md
        if [ -f "$CLAUDE_MD_FILE" ]; then
            echo "⚙️  Syncing CLAUDE.md (local → repo)"
            cp "$CLAUDE_MD_FILE" "$REPO_DIR/claude.md"
        fi
        ;;

    "repo-to-local")
        # Commands
        if [ -d "$REPO_DIR/commands" ]; then
            echo "📋 Syncing commands (repo → local)"
            rsync -aP "$REPO_DIR/commands/" "$CLAUDE_COMMANDS_DIR/"
        fi

        # Agents
        sync_agents_repo_to_local

        # CLAUDE.md
        if [ -f "$REPO_DIR/claude.md" ]; then
            echo "⚙️  Syncing claude.md (repo → local)"
            cp "$REPO_DIR/claude.md" "$CLAUDE_MD_FILE"
        fi
        ;;

    "bidirectional")
        # Show preview and get confirmation
        preview_sync_changes
        confirm_sync

        # Commands (always repo-to-local for now)
        if [ -d "$REPO_DIR/commands" ]; then
            echo "📋 Syncing commands (repo → local)"
            rsync -aP "$REPO_DIR/commands/" "$CLAUDE_COMMANDS_DIR/"
        fi

        # Agents
        sync_agents_bidirectional

        # CLAUDE.md
        echo "⚙️  Syncing CLAUDE.md (bidirectional)"
        sync_file_bidirectional "$CLAUDE_MD_FILE" "$REPO_DIR/claude.md" "Config"
        ;;
esac

echo ""
echo "✅ Sync complete! Configuration updated using $SYNC_MODE mode"
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
    echo "  CLAUDE.md present"
else
    echo "  No CLAUDE.md found"
fi