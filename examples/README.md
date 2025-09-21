# Examples

This directory contains practical examples and usage patterns for Claude Sync.

## 📋 Available Examples

### Basic Usage
- **[basic_usage.sh](basic_usage.sh)** - Interactive examples of common sync operations

### Advanced Scenarios (Planned)
- **team_workflow.md** - Collaborative development patterns
- **ci_integration.md** - Continuous integration setup
- **custom_agents.md** - Creating and managing custom agents

## 🚀 Running Examples

### Interactive Basic Usage
```bash
# Run the interactive example script
./examples/basic_usage.sh

# Or run with demo mode
cd claude-sync
./examples/basic_usage.sh
# Select 'y' when prompted for demo
```

### Manual Examples

**First-time Setup:**
```bash
# Clone and setup
git clone https://github.com/moewill/claude-sync.git
cd claude-sync

# Install globally (optional)
./install.sh

# Initial sync
./sync.sh --repo-to-local
```

**Daily Workflow:**
```bash
# Check what would be synced
echo "n" | ./sync.sh

# Sync with confirmation
./sync.sh

# Make local changes
vim ~/.claude/agents/my-custom-agent.md

# Backup changes to repository
./sync.sh --local-to-repo
```

**Team Collaboration:**
```bash
# Get latest team updates
./sync.sh --repo-to-local

# Work on your changes
# ... edit files ...

# Share your improvements
git add agents/new-agent.md
git commit -m "feat: add new deployment agent"
git push

# Sync your local environment
./sync.sh --bidirectional
```

## 📝 Example File Structure

After running the examples, your directory structure should look like:

```
~/.claude/
├── commands/
│   ├── create-prd.md
│   ├── generate-tasks.md
│   ├── process-task-list.md
│   └── arch-docs/
│       └── ReactViteTypescript.md
├── agents/
│   ├── reactcoding-agent.md
│   ├── antireact-code-critique.md
│   ├── javascript-coding-agent.md
│   ├── anti-javascript-critique.md
│   ├── fastapi-coding-agent.md
│   ├── antifastapi-code-critique.md
│   ├── pulumi-coding-agent.md
│   ├── antipulumi-code-critique.md
│   ├── vite-coding-agent.md
│   └── antivite-code-critique.md
└── CLAUDE.md
```

## 🔧 Customization Examples

### Custom Agent Example
```markdown
# My Custom Agent

## Purpose
This agent helps with custom development tasks specific to my workflow.

## When to Use
- When implementing custom business logic
- During code review processes
- For project-specific patterns

## Tools Available
- Read, Write, Edit
- Bash, Grep, Glob
- Context7 integration

## Examples
[Provide specific examples of usage]
```

### Configuration Customization
```bash
# Create custom sync paths (future feature)
export CLAUDE_SYNC_AGENTS_DIR="$HOME/my-custom-agents"
export CLAUDE_SYNC_COMMANDS_DIR="$HOME/my-workflows"

# Run with custom configuration
./sync.sh --config my-config.json
```

## 🧪 Testing Examples

### Manual Testing Scenarios
```bash
# Test different timestamp scenarios
echo "old content" > ~/.claude/agents/test.md
sleep 2
echo "new content" > agents/test.md

# Test bidirectional sync
./sync.sh --bidirectional

# Verify newer content wins
cat ~/.claude/agents/test.md  # Should show "new content"
```

### Error Handling Examples
```bash
# Test with invalid flags
./sync.sh --invalid-flag  # Should show error and help

# Test with missing directories
rm -rf ~/.claude
./sync.sh  # Should recreate directories

# Test with permission issues
chmod 000 ~/.claude
./sync.sh  # Should show permission error
chmod 755 ~/.claude  # Fix permissions
```

## 📊 Performance Examples

### Large Repository Testing
```bash
# Create many test files
for i in {1..100}; do
    echo "Agent $i content" > agents/test-agent-$i.md
done

# Test sync performance
time ./sync.sh --repo-to-local
```

### Network Scenarios
```bash
# Test offline mode (should gracefully handle git failures)
# Disconnect network, then:
./sync.sh --local-to-repo  # Should work without git pull

# Test with slow network
# Use network throttling tools to simulate slow connections
```

## 🤝 Contributing Examples

To contribute examples:

1. **Create New Example Files**: Follow naming convention `example_name.md` or `example_name.sh`
2. **Include Clear Documentation**: Explain what the example demonstrates
3. **Test Thoroughly**: Ensure examples work on different platforms
4. **Update This README**: Add your example to the index

### Example Template
```bash
#!/bin/bash
# Example: [Brief Description]
# This example demonstrates [specific feature or scenario]

set -e

echo "🔍 Example: [Name]"
echo "Description: [What this example shows]"
echo ""

# Example code here
# ... with clear comments explaining each step
```

## 🔗 Related Resources

- **[Basic Usage Documentation](../README.md#usage)** - Main usage guide
- **[Contributing Guidelines](../CONTRIBUTING.md)** - How to contribute
- **[Architecture Documentation](../docs/ARCHITECTURE.md)** - Technical details

---

**Need help with examples? Open an [issue](https://github.com/moewill/claude-sync/issues) or start a [discussion](https://github.com/moewill/claude-sync/discussions)!**