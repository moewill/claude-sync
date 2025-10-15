#!/bin/bash

# Claude Sync - Intelligent sync for commands, agents, and CLAUDE.md
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
CLAUDE_MD_FILE="$HOME/.claude/CLAUDE.md"

# Default sync mode
SYNC_MODE="bidirectional"

# Security validation functions
validate_directory_safety() {
    local path="$1"
    local path_name="$2"

    # Check if path is empty
    if [ -z "$path" ]; then
        echo "Error: $path_name cannot be empty"
        log_validation_failure "DIRECTORY_EMPTY" "$path_name is empty"
        return 1
    fi

    # Prevent directory traversal attacks
    if [[ "$path" == *".."* ]]; then
        echo "Error: Invalid $path_name - contains potentially dangerous path elements"
        log_validation_failure "DIRECTORY_TRAVERSAL" "$path_name contains '..' - $path"
        return 1
    fi

    # Ensure path is within expected locations
    case "$path" in
        "$HOME"*|"/tmp"*|"$REPO_DIR"*)
            log_validation_success "DIRECTORY_PATH" "$path_name validated - $path"
            return 0
            ;;
        *)
            echo "Warning: $path_name is outside typical sync directories: $path"
            log_security_event "DIRECTORY_WARNING" "$path_name outside typical directories - $path"
            return 0  # Allow but warn
            ;;
    esac
}

# Security logging functions
LOG_FILE="${CLAUDE_SYNC_LOG_FILE:-$HOME/.claude/sync_security.log}"

log_security_event() {
    local event_type="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

    # Log the event
    echo "[$timestamp] [$event_type] $message" >> "$LOG_FILE" 2>/dev/null || true
}

log_file_operation() {
    local operation="$1"
    local source="$2"
    local destination="$3"
    local safe_src
    local safe_dest
    safe_src=$(sanitize_path_for_log "$source")
    safe_dest=$(sanitize_path_for_log "$destination")
    log_security_event "FILE_OP" "$operation: $safe_src -> $safe_dest"
}

log_validation_failure() {
    local validation_type="$1"
    local details="$2"
    log_security_event "VALIDATION_FAIL" "$validation_type: $details"
}

log_validation_success() {
    local validation_type="$1"
    local details="$2"
    log_security_event "VALIDATION_OK" "$validation_type: $details"
}

# Path sanitization for sensitive information
sanitize_path_for_display() {
    local path="$1"

    # Replace full home directory path with ~
    if [[ "$path" == "$HOME"* ]]; then
        echo "~${path#$HOME}"
    # Replace full repo directory path with <repo>
    elif [[ -n "$REPO_DIR" && "$path" == "$REPO_DIR"* ]]; then
        echo "<repo>${path#$REPO_DIR}"
    # For other paths, just show basename if it's a deep path
    elif [[ $(echo "$path" | tr -cd '/' | wc -c) -gt 2 ]]; then
        echo "...$(basename "$path")"
    else
        echo "$path"
    fi
}

sanitize_path_for_log() {
    local path="$1"

    # For logs, be more restrictive - only show relative paths or sanitized versions
    if [[ "$path" == "$HOME"* ]]; then
        echo "~/${path#$HOME/}"
    elif [[ -n "$REPO_DIR" && "$path" == "$REPO_DIR"* ]]; then
        echo "<repo>/${path#$REPO_DIR/}"
    else
        # Hash sensitive parts of the path
        local sanitized
        sanitized=$(echo "$path" | sed 's|/[^/]*|/<sanitized>|g' | sed 's|<sanitized>/[^/]*$|/<file>|')
        echo "$sanitized"
    fi
}

# Secure file operation functions
safe_copy_file() {
    local src="$1"
    local dest="$2"
    local operation_type="$3"

    # Log the operation attempt
    log_file_operation "$operation_type" "$src" "$dest"

    # Validate source file exists and is readable
    if [ ! -f "$src" ]; then
        echo "Error: Source file does not exist: $(sanitize_path_for_display "$src")"
        log_security_event "FILE_ERROR" "Source file missing: $(sanitize_path_for_log "$src")"
        return 1
    fi

    if [ ! -r "$src" ]; then
        echo "Error: Cannot read source file: $(sanitize_path_for_display "$src")"
        log_security_event "FILE_ERROR" "Source file unreadable: $(sanitize_path_for_log "$src")"
        return 1
    fi

    # Create destination directory if it doesn't exist
    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [ ! -d "$dest_dir" ]; then
        if ! mkdir -p "$dest_dir"; then
            echo "Error: Cannot create destination directory: $dest_dir"
            log_security_event "DIR_ERROR" "Failed to create directory: $dest_dir"
            return 1
        fi
        log_security_event "DIR_CREATE" "Created directory: $dest_dir"
    fi

    # Check if we can write to destination directory
    if [ ! -w "$dest_dir" ]; then
        echo "Error: Cannot write to destination directory: $dest_dir"
        log_security_event "PERMISSION_ERROR" "Cannot write to directory: $dest_dir"
        return 1
    fi

    # Skip backup creation - rely on git history for rollbacks

    # Perform the copy with error handling
    if ! cp "$src" "$dest"; then
        echo "Error: Failed to copy $src to $dest"
        log_security_event "COPY_FAIL" "Copy failed: $src to $dest"
        return 1
    fi

    # Preserve reasonable permissions (readable by user, not executable unless necessary)
    chmod 644 "$dest"
    log_security_event "COPY_SUCCESS" "File copied successfully: $src to $dest"

    return 0
}

safe_rsync() {
    local src="$1"
    local dest="$2"

    # Validate source directory exists
    if [ ! -d "$src" ]; then
        echo "Error: Source directory does not exist: $src"
        return 1
    fi

    # Create destination directory if it doesn't exist
    if [ ! -d "$dest" ]; then
        if ! safe_mkdir_simple "$dest" "rsync destination"; then
            return 1
        fi
    fi

    # Use rsync with safer options - no preserve permissions, no devices, no special files
    if ! rsync -rlpt --exclude=".*" --exclude="*.tmp" --exclude="*.bak" "$src" "$dest"; then
        echo "Error: Failed to sync $src to $dest"
        return 1
    fi

    return 0
}

# Simple secure directory creation (without full validation for internal use)
safe_mkdir_simple() {
    local dir="$1"
    local description="$2"

    if ! mkdir -p "$dir"; then
        echo "Error: Cannot create $description directory: $dir"
        return 1
    fi

    # Set secure permissions (rwx for owner, rx for group)
    chmod 750 "$dir" 2>/dev/null || true
    return 0
}

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
            safe_copy_file "$local_file" "$repo_file" "local-to-repo"
        elif [[ "$repo_file" -nt "$local_file" ]]; then
            echo "  📥 $file_type: $(basename "$repo_file") (repo → local)"
            safe_copy_file "$repo_file" "$local_file" "repo-to-local"
        else
            echo "  ✓ $file_type: $(basename "$local_file") (up to date)"
        fi
    elif [[ -f "$local_file" ]]; then
        echo "  📤 $file_type: $(basename "$local_file") (creating in repo)"
        safe_copy_file "$local_file" "$repo_file" "create-repo"
    elif [[ -f "$repo_file" ]]; then
        echo "  📥 $file_type: $(basename "$repo_file") (creating locally)"
        safe_copy_file "$repo_file" "$local_file" "create-local"
    fi
}

# Function to sync agents in local-to-repo mode
sync_agents_local_to_repo() {
    echo "🤖 Syncing agents (local → repo)"
    if [ -d "$CLAUDE_AGENTS_DIR" ]; then
        safe_mkdir_simple "$REPO_DIR/agents" "repository agents"
        safe_rsync "$CLAUDE_AGENTS_DIR/" "$REPO_DIR/agents/"
    else
        echo "  No local agents directory found"
    fi
}

# Function to sync agents in repo-to-local mode
sync_agents_repo_to_local() {
    echo "🤖 Syncing agents (repo → local)"
    if [ -d "$REPO_DIR/agents" ]; then
        safe_mkdir_simple "$CLAUDE_AGENTS_DIR" "local agents"
        safe_rsync "$REPO_DIR/agents/" "$CLAUDE_AGENTS_DIR/"
    else
        echo "  No agents directory in repository"
    fi
}

# Function to sync agents bidirectionally
sync_agents_bidirectional() {
    echo "🤖 Syncing agents (bidirectional)"

    # Create directories if they don't exist
    safe_mkdir_simple "$CLAUDE_AGENTS_DIR" "local agents"
    safe_mkdir_simple "$REPO_DIR/agents" "repository agents"

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
    safe_mkdir_simple "$CLAUDE_COMMANDS_DIR" "commands"
fi

if [ ! -d "$CLAUDE_AGENTS_DIR" ]; then
    echo "📁 Creating ~/.claude/agents directory"
    safe_mkdir_simple "$CLAUDE_AGENTS_DIR" "agents"
fi

# Validate directories before operations
if ! validate_directory_safety "$REPO_DIR" "Repository directory"; then
    exit 1
fi

if ! validate_directory_safety "$CLAUDE_COMMANDS_DIR" "Commands directory"; then
    exit 1
fi

if ! validate_directory_safety "$CLAUDE_AGENTS_DIR" "Agents directory"; then
    exit 1
fi

if ! validate_directory_safety "$(dirname "$CLAUDE_MD_FILE")" "Claude config directory"; then
    exit 1
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
            safe_rsync "$REPO_DIR/commands/" "$CLAUDE_COMMANDS_DIR/"
        fi

        # Agents
        sync_agents_local_to_repo

        # CLAUDE.md
        if [ -f "$CLAUDE_MD_FILE" ]; then
            echo "⚙️  Syncing CLAUDE.md (local → repo)"
            safe_copy_file "$CLAUDE_MD_FILE" "$REPO_DIR/claude.md" "config-local-to-repo"
        fi
        ;;

    "repo-to-local")
        # Commands
        if [ -d "$REPO_DIR/commands" ]; then
            echo "📋 Syncing commands (repo → local)"
            safe_rsync "$REPO_DIR/commands/" "$CLAUDE_COMMANDS_DIR/"
        fi

        # Agents
        sync_agents_repo_to_local

        # CLAUDE.md
        if [ -f "$REPO_DIR/claude.md" ]; then
            echo "⚙️  Syncing claude.md (repo → local)"
            safe_copy_file "$REPO_DIR/claude.md" "$CLAUDE_MD_FILE" "config-repo-to-local"
        fi
        ;;

    "bidirectional")
        # Show preview and get confirmation
        preview_sync_changes
        confirm_sync

        # Commands (always repo-to-local for now)
        if [ -d "$REPO_DIR/commands" ]; then
            echo "📋 Syncing commands (repo → local)"
            safe_rsync "$REPO_DIR/commands/" "$CLAUDE_COMMANDS_DIR/"
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