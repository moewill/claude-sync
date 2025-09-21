# Claude Sync Architecture

This document describes the architecture and design decisions of Claude Sync.

## 🏗️ System Overview

Claude Sync is a bash-based synchronization tool that manages Claude Code configuration files across different locations. It operates on three main categories of files:

1. **Commands** - Development workflow templates
2. **Agents** - Specialized Claude agents for different tasks
3. **Configuration** - Global Claude settings (CLAUDE.md)

## 📁 Directory Structure

```
claude-sync/
├── .github/                    # GitHub templates and workflows
│   ├── ISSUE_TEMPLATE/        # Issue templates
│   ├── workflows/             # CI/CD workflows
│   └── pull_request_template.md
├── agents/                    # Claude agent definitions
│   ├── *-coding-agent.md      # Task-specific coding agents
│   └── anti*-code-critique.md # Code critique agents
├── commands/                  # Development workflow commands
│   ├── arch-docs/            # Architecture documentation
│   ├── create-prd.md         # PRD creation process
│   ├── generate-tasks.md     # Task generation workflow
│   └── process-task-list.md  # Task processing workflow
├── docs/                     # Documentation
│   ├── ARCHITECTURE.md       # This file
│   └── API.md               # API documentation
├── examples/                 # Usage examples
├── taskmaster-integration/   # Taskmaster MCP integration
├── tests/                   # Test scripts and fixtures
├── claude.md               # Global Claude configuration
├── sync.sh                 # Main synchronization script
├── install.sh              # Installation script
└── README.md               # Main documentation
```

## 🔄 Sync Algorithm

### Bidirectional Sync Logic

The core synchronization algorithm follows these steps:

1. **Discovery Phase**
   - Scan both local (`~/.claude/`) and repository locations
   - Build unified list of all unique files
   - Handle missing directories gracefully

2. **Analysis Phase**
   - For each file, determine sync action:
     - Both exist: Compare modification times using bash `-nt` operator
     - Local only: Mark for creation in repository
     - Repository only: Mark for creation locally

3. **Preview Phase** (bidirectional mode only)
   - Display all planned operations with visual indicators
   - Wait for user confirmation

4. **Execution Phase**
   - Execute file operations based on analysis
   - Provide real-time feedback
   - Handle errors gracefully

### Sync Modes

| Mode | Direction | Use Case |
|------|-----------|----------|
| `--repo-to-local` | Repo → Local | Fresh setup, reset local state |
| `--local-to-repo` | Local → Repo | Backup local changes |
| `--bidirectional` | Both directions | Intelligent sync with preview |

## 🛠️ Implementation Details

### Core Functions

**`sync_file_bidirectional()`**
- Compares two file locations
- Uses bash file test operators (`-f`, `-nt`)
- Handles missing files and timestamp comparison

**`sync_agents_bidirectional()`**
- Orchestrates agent file synchronization
- Builds unified file list from both locations
- Calls `sync_file_bidirectional()` for each agent

**`preview_sync_changes()`**
- Duplicates sync logic without file operations
- Provides user-friendly preview of changes
- Uses same logic as actual sync for consistency

### File Operations

**Timestamp Comparison:**
```bash
if [[ "$local_file" -nt "$repo_file" ]]; then
    # Local file is newer
elif [[ "$repo_file" -nt "$local_file" ]]; then
    # Repository file is newer
else
    # Files have same timestamp
fi
```

**Safe File Operations:**
- Use `cp` for file copying (preserves content, updates timestamp)
- Use `rsync` for directory synchronization
- Create parent directories as needed with `mkdir -p`

### Error Handling

**Graceful Degradation:**
- Missing directories are created automatically
- Permission errors are reported clearly
- Git operations are wrapped with error checking

**User Safety:**
- Preview mode prevents accidental overwrites
- Confirmation prompts for destructive operations
- Clear feedback about what operations will be performed

## 🔌 Extension Points

### Adding New Sync Modes

To add a new sync mode:

1. Add command-line flag parsing
2. Implement sync function following naming pattern: `sync_agents_[mode]()`
3. Add case in main sync switch statement
4. Update help text and documentation

### Adding New File Types

To sync additional file types:

1. Add directory variable (e.g., `CLAUDE_TEMPLATES_DIR`)
2. Implement sync function following existing patterns
3. Add to each sync mode's case statement
4. Update preview function if needed

### Platform Support

**Current Support:**
- Linux: Full support with bash 4.0+
- macOS: Limited support (bash 3.2 limitations)
- Windows: WSL/Git Bash support

**Extension Approach:**
- PowerShell version for native Windows support
- Feature detection for bash version capabilities
- Platform-specific path handling

## 🚀 Performance Considerations

### File Discovery

**Optimization Strategies:**
- Use `find` with null termination for safe file handling
- Limit search to specific file extensions (*.md)
- Process files in batches to avoid memory issues with large repositories

### Network Operations

**Git Operations:**
- Single `git pull` operation per sync
- Avoid unnecessary network calls
- Handle offline scenarios gracefully

## 🔒 Security Considerations

### File Safety

**Validation:**
- Ensure target directories are within expected paths
- Prevent directory traversal attacks
- Validate file extensions and content types

**Permission Handling:**
- Respect existing file permissions
- Don't escalate privileges unnecessarily
- Provide clear error messages for permission issues

### Git Repository Safety

**Repository Integrity:**
- Don't modify git configuration
- Avoid force operations
- Respect existing branching strategy

## 🧪 Testing Strategy

### Manual Testing

**Test Matrix:**
- 3 sync modes × 4 file scenarios × 2+ platforms
- Edge cases: empty directories, permission issues, corrupted files
- Integration testing with real Claude Code environments

### Automated Testing (Future)

**Test Categories:**
- Unit tests for individual functions
- Integration tests for complete workflows
- Performance tests for large file sets
- Cross-platform compatibility tests

## 📈 Future Architecture

### Planned Enhancements

**Configuration System:**
- User-configurable sync paths
- Exclude/include patterns for selective sync
- Custom sync rules and transformations

**Advanced Sync Features:**
- Conflict resolution strategies
- Merge capabilities for text files
- Backup and rollback functionality

**Multi-Repository Support:**
- Sync from multiple upstream repositories
- Repository prioritization and merging
- Distributed configuration management

## 🤝 Contributing to Architecture

When contributing architectural changes:

1. **Maintain Compatibility:** Preserve existing interfaces
2. **Follow Patterns:** Use established naming and structure conventions
3. **Document Decisions:** Update this document with rationale
4. **Consider Scale:** Design for growth in users and file counts

---

For implementation details, see the source code in `sync.sh`.
For usage patterns, see `README.md` and `examples/`.