#!/bin/bash

# Claude Sync Installation Script
# This script installs Claude Sync and sets up the environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration - Allow override via environment variables
REPO_URL="${CLAUDE_SYNC_REPO_URL:-https://github.com/moewill/claude-sync.git}"
INSTALL_DIR="${CLAUDE_SYNC_INSTALL_DIR:-$HOME/.claude-sync}"
CLAUDE_DIR="${CLAUDE_SYNC_DIR:-$HOME/.claude}"

# Functions for styled output
print_header() {
    echo -e "\n${BLUE}${BOLD}🚀 Claude Sync Installer${NC}"
    echo -e "${BLUE}=========================${NC}\n"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step() {
    echo -e "\n${BOLD}📋 $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    case "$OSTYPE" in
        linux-gnu*)   echo "linux" ;;
        darwin*)      echo "macos" ;;
        msys|cygwin*) echo "windows" ;;
        *)            echo "unknown" ;;
    esac
}

# Security validation functions
validate_repository_url() {
    local url="$1"

    # Check if URL is empty
    if [ -z "$url" ]; then
        print_error "Repository URL cannot be empty"
        log_validation_failure "URL_EMPTY" "Repository URL is empty"
        return 1
    fi

    # Sanitize URL by removing any dangerous characters
    local sanitized_url
    sanitized_url=$(echo "$url" | tr -d '\r\n\t' | sed 's/[[:space:]]//g')

    # Check for URL injection attempts
    if [[ "$sanitized_url" == *";"* ]] || [[ "$sanitized_url" == *"|"* ]] || [[ "$sanitized_url" == *"&"* ]]; then
        print_error "Repository URL contains potentially malicious characters"
        log_validation_failure "URL_INJECTION" "Malicious characters in URL: $sanitized_url"
        return 1
    fi

    # Allow only HTTPS GitHub URLs for security
    if [[ ! "$sanitized_url" =~ ^https://github\.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+\.git$ ]]; then
        print_error "Invalid repository URL. Only HTTPS GitHub URLs are allowed."
        print_info "Expected format: https://github.com/username/repository.git"
        print_info "Provided: $sanitized_url"
        log_validation_failure "URL_FORMAT" "Invalid URL format: $sanitized_url"
        return 1
    fi

    # Additional security checks
    local repo_path
    repo_path=$(echo "$sanitized_url" | sed 's|https://github.com/||' | sed 's|\.git$||')
    local username
    local reponame
    username=$(echo "$repo_path" | cut -d'/' -f1)
    reponame=$(echo "$repo_path" | cut -d'/' -f2)

    # Check for suspicious patterns
    if [[ "$username" =~ ^[.-] ]] || [[ "$username" =~ [.-]$ ]] || [[ "$reponame" =~ ^[.-] ]] || [[ "$reponame" =~ [.-]$ ]]; then
        print_error "Repository username or name has suspicious formatting"
        log_validation_failure "URL_SUSPICIOUS" "Suspicious repo format: $username/$reponame"
        return 1
    fi

    # Store sanitized URL back for use
    REPO_URL="$sanitized_url"
    log_validation_success "URL_VALIDATED" "Repository URL validated: $sanitized_url"

    return 0
}

validate_directory_path() {
    local path="$1"
    local path_name="$2"

    # Check if path is empty
    if [ -z "$path" ]; then
        print_error "$path_name cannot be empty"
        return 1
    fi

    # Prevent directory traversal attacks
    if [[ "$path" == *".."* ]] || [[ "$path" == *"~"* && "$path" != "$HOME"* ]]; then
        print_error "Invalid $path_name: contains potentially dangerous path elements"
        return 1
    fi

    # Ensure path is within user's home directory or safe system paths
    case "$path" in
        "$HOME"*|"/usr/local"*|"/opt"*)
            return 0
            ;;
        *)
            print_warning "$path_name is outside typical installation directories"
            print_info "Path: $path"
            read -p "Continue anyway? (y/N): " -r
            [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
            ;;
    esac
}

# Security logging functions
LOG_FILE="${CLAUDE_SYNC_LOG_FILE:-$HOME/.claude/install_security.log}"

log_security_event() {
    local event_type="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

    # Log the event
    echo "[$timestamp] [$event_type] [INSTALL] $message" >> "$LOG_FILE" 2>/dev/null || true
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
    # For other paths, just show basename if it's a deep path
    elif [[ $(echo "$path" | tr -cd '/' | wc -c) -gt 2 ]]; then
        echo "...$(basename "$path")"
    else
        echo "$path"
    fi
}

sanitize_path_for_log() {
    local path="$1"

    # For logs, be more restrictive
    if [[ "$path" == "$HOME"* ]]; then
        echo "~/${path#$HOME/}"
    else
        # Hash sensitive parts of the path
        local sanitized
        sanitized=$(echo "$path" | sed 's|/[^/]*|/<sanitized>|g' | sed 's|<sanitized>/[^/]*$|/<file>|')
        echo "$sanitized"
    fi
}

# Secure directory creation with validation
safe_mkdir() {
    local dir="$1"
    local description="$2"

    # Validate directory path
    if ! validate_directory_path "$dir" "$description"; then
        return 1
    fi

    # Create directory with secure permissions
    if ! mkdir -p "$dir"; then
        print_error "Failed to create $description: $dir"
        return 1
    fi

    # Set secure permissions (rwx for owner only)
    chmod 700 "$dir" 2>/dev/null || true

    return 0
}

# Function to check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites"

    local missing_deps=()

    # Check for required commands
    if ! command_exists git; then
        missing_deps+=("git")
    fi

    if ! command_exists bash; then
        missing_deps+=("bash")
    fi

    # Check bash version (need 4.0+ for associative arrays)
    if command_exists bash; then
        bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
        bash_major=$(echo "$bash_version" | cut -d. -f1)
        if [ "$bash_major" -lt 4 ]; then
            print_warning "Bash version $bash_version detected. Some features may not work properly."
            print_info "Consider upgrading to Bash 4.0 or later for full functionality."
        fi
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        print_info "Please install the missing dependencies and run the installer again."

        case $(detect_os) in
            linux)
                print_info "On Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
                print_info "On CentOS/RHEL: sudo yum install ${missing_deps[*]}"
                ;;
            macos)
                print_info "On macOS: brew install ${missing_deps[*]}"
                print_info "Or install Xcode Command Line Tools: xcode-select --install"
                ;;
            windows)
                print_info "On Windows: Install Git for Windows or use Windows Subsystem for Linux (WSL)"
                ;;
        esac
        exit 1
    fi

    print_success "All prerequisites satisfied"
}

# Function to create directories
create_directories() {
    print_step "Creating directories"

    # Create Claude directories with validation
    if ! safe_mkdir "$CLAUDE_DIR" "Claude configuration directory"; then
        return 1
    fi

    if ! safe_mkdir "$CLAUDE_DIR/commands" "Claude commands directory"; then
        return 1
    fi

    if ! safe_mkdir "$CLAUDE_DIR/agents" "Claude agents directory"; then
        return 1
    fi

    print_success "Created ~/.claude directories with secure permissions"
}

# Function to clone or update repository
setup_repository() {
    print_step "Setting up repository"

    if [ -d "$INSTALL_DIR" ]; then
        print_info "Existing installation found. Updating..."
        cd "$INSTALL_DIR"
        git fetch origin
        git reset --hard origin/main
        print_success "Repository updated"
    else
        print_info "Cloning repository..."
        git clone "$REPO_URL" "$INSTALL_DIR"
        print_success "Repository cloned to $INSTALL_DIR"
    fi
}

# Function to install the sync script
install_sync_script() {
    print_step "Installing sync script"

    cd "$INSTALL_DIR"
    chmod +x sync.sh

    # Create symlink for global access if user has write access to /usr/local/bin
    if [ -w "/usr/local/bin" ] || [ -w "/usr/local" ]; then
        if [ -L "/usr/local/bin/claude-sync" ]; then
            rm "/usr/local/bin/claude-sync"
        fi
        ln -s "$INSTALL_DIR/sync.sh" "/usr/local/bin/claude-sync"
        print_success "Installed claude-sync command globally"
        print_info "You can now run 'claude-sync' from anywhere"
    else
        print_warning "Cannot create global symlink (no write access to /usr/local/bin)"
        print_info "Add $INSTALL_DIR to your PATH, or run directly: $INSTALL_DIR/sync.sh"
    fi
}

# Function to run initial sync
initial_sync() {
    print_step "Running initial sync"

    cd "$INSTALL_DIR"
    print_info "Syncing repository files to ~/.claude directories"
    ./sync.sh --repo-to-local

    print_success "Initial sync completed"
}

# Function to show installation summary
show_summary() {
    print_step "Installation Summary"

    echo -e "${GREEN}🎉 Claude Sync has been successfully installed!${NC}\n"

    echo -e "${BOLD}📁 Installation Details:${NC}"
    echo "  • Repository: $INSTALL_DIR"
    echo "  • Commands: $CLAUDE_DIR/commands"
    echo "  • Agents: $CLAUDE_DIR/agents"
    echo "  • Config: $CLAUDE_DIR/CLAUDE.md"

    echo -e "\n${BOLD}🚀 Getting Started:${NC}"

    if command_exists claude-sync; then
        echo "  • Run sync: ${GREEN}claude-sync${NC}"
        echo "  • Get help: ${GREEN}claude-sync --help${NC}"
    else
        echo "  • Run sync: ${GREEN}$INSTALL_DIR/sync.sh${NC}"
        echo "  • Get help: ${GREEN}$INSTALL_DIR/sync.sh --help${NC}"
    fi

    echo -e "\n${BOLD}📖 Sync Modes:${NC}"
    echo "  • ${BLUE}--bidirectional${NC}  Two-way sync with preview (default)"
    echo "  • ${BLUE}--repo-to-local${NC}  Update local files from repository"
    echo "  • ${BLUE}--local-to-repo${NC}  Update repository with local changes"

    echo -e "\n${BOLD}🔗 Resources:${NC}"
    echo "  • Documentation: $INSTALL_DIR/README.md"
    echo "  • Examples: $INSTALL_DIR/examples/"
    echo "  • Issues: https://github.com/moewill/claude-sync/issues"

    echo -e "\n${GREEN}Happy coding with Claude! 🤖${NC}"
}

# Function to handle cleanup on error
cleanup_on_error() {
    print_error "Installation failed. Cleaning up..."
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
    fi
    exit 1
}

# Main installation function
main() {
    # Set up error handling
    trap cleanup_on_error ERR

    print_header

    # Validate configuration before proceeding
    print_step "Validating configuration"

    if ! validate_repository_url "$REPO_URL"; then
        exit 1
    fi

    if ! validate_directory_path "$INSTALL_DIR" "Installation directory"; then
        exit 1
    fi

    if ! validate_directory_path "$CLAUDE_DIR" "Claude directory"; then
        exit 1
    fi

    print_success "Configuration validated"

    # Check if running as root
    if [ "$(id -u)" = "0" ]; then
        print_warning "Running as root. This will install Claude Sync for the root user."
        print_info "Consider running as a regular user to install in your home directory."
        echo ""
        read -p "Continue anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled."
            exit 0
        fi
    fi

    # Show what will be installed
    print_info "This installer will:"
    echo "  • Clone Claude Sync repository to $INSTALL_DIR"
    echo "  • Create ~/.claude directories"
    echo "  • Install sync script and create global command (if possible)"
    echo "  • Run initial sync to populate your Claude directories"
    echo ""

    # Ask for confirmation
    read -p "Proceed with installation? (Y/n): " -r
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Installation cancelled."
        exit 0
    fi

    # Run installation steps
    check_prerequisites
    create_directories
    setup_repository
    install_sync_script
    initial_sync
    show_summary
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Claude Sync Installation Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --uninstall    Uninstall Claude Sync"
        echo ""
        echo "This script will install Claude Sync to $INSTALL_DIR"
        echo "and set up the necessary directories and configuration."
        exit 0
        ;;
    --uninstall)
        print_header
        print_warning "This will remove Claude Sync installation"
        echo "  • Repository: $INSTALL_DIR"
        echo "  • Global command: /usr/local/bin/claude-sync"
        echo ""
        print_info "Your ~/.claude directories will NOT be removed"
        echo ""
        read -p "Proceed with uninstall? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            [ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
            [ -L "/usr/local/bin/claude-sync" ] && rm "/usr/local/bin/claude-sync"
            print_success "Claude Sync uninstalled"
        else
            print_info "Uninstall cancelled"
        fi
        exit 0
        ;;
    "")
        # No arguments, proceed with installation
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac