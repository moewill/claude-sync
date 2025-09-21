#!/bin/bash

# Claude Sync - Basic Usage Examples
# This script demonstrates common usage patterns for Claude Sync

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if sync.sh exists
if [ ! -f "./sync.sh" ]; then
    echo_error "sync.sh not found. Please run this from the claude-sync directory."
    exit 1
fi

echo_info "Claude Sync - Basic Usage Examples"
echo ""

# Example 1: First-time setup
echo_info "Example 1: First-time setup"
echo "# When setting up Claude Sync for the first time:"
echo "./sync.sh --repo-to-local"
echo ""
echo "This will:"
echo "- Create ~/.claude/commands, ~/.claude/agents, ~/.claude/ directories"
echo "- Copy all repository files to your local Claude directories"
echo "- Pull latest changes from the repository"
echo ""

# Example 2: Regular bidirectional sync
echo_info "Example 2: Regular bidirectional sync (default)"
echo "# For regular usage with preview:"
echo "./sync.sh"
echo ""
echo "This will:"
echo "- Show a preview of what files would be synced in each direction"
echo "- Ask for confirmation before making changes"
echo "- Sync newer files in both directions"
echo "- Create missing files where needed"
echo ""

# Example 3: Backup local changes
echo_info "Example 3: Backup your local changes to repository"
echo "# When you've modified agents or config locally:"
echo "./sync.sh --local-to-repo"
echo ""
echo "This will:"
echo "- Copy all local files to the repository"
echo "- Overwrite repository files with local versions"
echo "- Still sync commands from repo to local"
echo ""

# Example 4: Check what would be synced
echo_info "Example 4: Preview changes without confirmation prompts"
echo "# To see what would be synced (bidirectional mode):"
echo "echo 'n' | ./sync.sh"
echo ""
echo "This will:"
echo "- Show the preview of changes"
echo "- Automatically cancel when prompted"
echo "- No files will be modified"
echo ""

# Example 5: Common workflow
echo_info "Example 5: Common development workflow"
echo ""
echo "# 1. Start with fresh repository state"
echo "./sync.sh --repo-to-local"
echo ""
echo "# 2. Work on your project, modify agents as needed"
echo "vim ~/.claude/agents/my-custom-agent.md"
echo ""
echo "# 3. Backup your changes"
echo "./sync.sh --local-to-repo"
echo ""
echo "# 4. Later, get updates from repository"
echo "./sync.sh --bidirectional"
echo "# (Review and confirm changes)"
echo ""

# Interactive demo option
echo_warning "Demo Mode Available"
echo "Would you like to run an interactive demo? (y/N)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo_info "Running Interactive Demo..."

    echo ""
    echo_info "Step 1: Checking help output"
    ./sync.sh --help

    echo ""
    echo_info "Step 2: Showing current status (preview mode)"
    echo "Running: echo 'n' | ./sync.sh"
    echo ""
    echo "n" | ./sync.sh || true

    echo ""
    echo_success "Demo completed!"
    echo_info "Try running different sync modes to see how they work:"
    echo "  ./sync.sh --repo-to-local"
    echo "  ./sync.sh --local-to-repo"
    echo "  ./sync.sh --bidirectional"

else
    echo ""
    echo_info "Demo skipped. You can run this script anytime to see examples:"
    echo "  ./examples/basic_usage.sh"
fi

echo ""
echo_success "For more information, see README.md and docs/ARCHITECTURE.md"