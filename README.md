# Claude Sync

Sync updates to processes for createprd, generate subtasks, and process task lists.

## Commands

The `commands/` directory contains:
- `create-prd.md` - Process for creating PRDs
- `generate-tasks.md` - Task generation workflows  
- `process-task-list.md` - Task list processing procedures

## Setup

### Full Clone
```bash
git clone https://github.com/moewill/claude-sync.git
```

### Sparse Checkout (Commands Only)
```bash
# Clone without checking out files
git clone --no-checkout https://github.com/moewill/claude-sync.git
cd claude-sync

# Enable sparse checkout
git sparse-checkout init --cone
git sparse-checkout set commands

# Checkout only the commands directory
git checkout
```

### Sync Script for Linux Hosts

Use the provided `sync.sh` script to automatically update your local Claude commands:

```bash
# Make executable
chmod +x sync.sh

# Run to sync commands to ~/.claude/commands
./sync.sh
```

The script will:
1. Create `~/.claude/commands` if it doesn't exist
2. Pull latest changes from the repository
3. Copy command files to your local Claude directory
4. Show what was updated