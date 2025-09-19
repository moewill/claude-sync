# Task Master AI Troubleshooting Guide

Common issues and solutions when using Task Master AI with Claude Code integration.

## Installation Issues

### Task Master AI Installation Fails

**Problem**: `npm install -g task-master-ai` fails

**Solutions**:
```bash
# Clear npm cache
npm cache clean --force

# Use latest Node.js LTS version
nvm install --lts
nvm use --lts

# Install with verbose logging
npm install -g task-master-ai --verbose

# Alternative: use npx without global install
npx -y --package=task-master-ai task-master-ai --version
```

### Permission Errors During Installation

**Problem**: Permission denied during global npm install

**Solutions**:
```bash
# Configure npm to use different directory
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Or use sudo (not recommended for production)
sudo npm install -g task-master-ai
```

## Configuration Issues

### API Key Problems

**Problem**: Task Master reports missing API keys

**Symptoms**:
```
[ERROR] No API keys found for any provider
[ERROR] Cannot generate tasks without configured AI models
```

**Solutions**:

1. **Check current configuration**:
   ```bash
   task-master models
   ```

2. **For AWS Bedrock users**:
   ```bash
   # Verify AWS credentials
   aws sts get-caller-identity

   # Configure Task Master for Bedrock
   task-master models --set-main us.anthropic.claude-sonnet-4-20250514-v1:0
   ```

3. **For direct API access**:
   ```bash
   # Set environment variables
   export ANTHROPIC_API_KEY="sk-ant-..."
   export OPENAI_API_KEY="sk-..."

   # Configure models
   task-master models --set-main claude-sonnet-4-20250514
   ```

4. **For MCP integration**:
   ```bash
   task-master models --set-main mcp-sampling
   ```

### MCP Connection Issues

**Problem**: MCP server not connecting to Claude Code

**Symptoms**:
- Claude Code doesn't show Task Master tools
- MCP tools return "server not available" errors

**Solutions**:

1. **Check .mcp.json syntax**:
   ```bash
   # Validate JSON syntax
   cat .mcp.json | jq .
   ```

2. **Test MCP server manually**:
   ```bash
   npx -y --package=task-master-ai task-master-ai
   ```

3. **Start Claude Code with debug mode**:
   ```bash
   claude --mcp-debug
   ```

4. **Check Node.js compatibility**:
   ```bash
   node --version  # Should be v16 or higher
   ```

5. **Verify task-master-ai package**:
   ```bash
   npm list -g task-master-ai
   ```

## Task Generation Issues

### PRD Parsing Fails

**Problem**: `task-master parse-prd` returns errors

**Symptoms**:
```
[ERROR] Failed to parse PRD file
[ERROR] AI service call failed
```

**Solutions**:

1. **Check PRD file format**:
   ```bash
   # Ensure file exists and is readable
   ls -la tasks/prd-your-feature.md

   # Check file encoding
   file tasks/prd-your-feature.md
   ```

2. **Validate PRD content**:
   - Ensure PRD is in valid markdown format
   - Include clear sections: Overview, Features, Requirements
   - Avoid special characters that might confuse parsing

3. **Test with simple PRD**:
   ```bash
   echo "# Test Feature

   ## Overview
   Simple test feature

   ## Features
   1. Basic functionality" > test-prd.md

   task-master parse-prd test-prd.md
   ```

4. **Check AI model availability**:
   ```bash
   task-master models
   # Ensure at least one model shows ✅ status
   ```

### Empty Task Generation

**Problem**: PRD parsing succeeds but generates no tasks

**Solutions**:

1. **Make PRD more specific**:
   - Add detailed feature descriptions
   - Include technical requirements
   - Specify implementation details

2. **Use research mode**:
   ```bash
   task-master parse-prd your-prd.md --research
   ```

3. **Manually add tasks**:
   ```bash
   task-master add-task --prompt="Implement feature X based on PRD requirements"
   ```

## Runtime Issues

### Tasks.json Corruption

**Problem**: Tasks file becomes corrupted or unreadable

**Symptoms**:
```
[ERROR] Failed to read tasks.json
[ERROR] Invalid JSON format in tasks file
```

**Solutions**:

1. **Backup and restore**:
   ```bash
   # Check for backups
   ls .taskmaster/tasks/*.backup

   # Restore from backup
   cp .taskmaster/tasks/tasks.json.backup .taskmaster/tasks/tasks.json
   ```

2. **Regenerate task files**:
   ```bash
   task-master generate
   ```

3. **Validate JSON manually**:
   ```bash
   cat .taskmaster/tasks/tasks.json | jq .
   ```

4. **Start fresh if necessary**:
   ```bash
   # Backup current state
   cp -r .taskmaster .taskmaster.backup

   # Reinitialize
   task-master init
   ```

### Dependency Conflicts

**Problem**: Circular dependencies or invalid dependency chains

**Symptoms**:
```
[ERROR] Circular dependency detected
[WARN] Task X depends on Y but Y depends on X
```

**Solutions**:

1. **Validate dependencies**:
   ```bash
   task-master validate-dependencies
   ```

2. **Fix circular dependencies**:
   ```bash
   task-master fix-dependencies
   ```

3. **Remove problematic dependencies**:
   ```bash
   task-master remove-dependency --id=X --depends-on=Y
   ```

4. **Visualize dependency graph**:
   ```bash
   task-master dependency-graph --output=deps.dot
   # Use graphviz to visualize: dot -Tpng deps.dot -o deps.png
   ```

## Performance Issues

### Slow AI Responses

**Problem**: Task generation or updates take very long

**Solutions**:

1. **Check AI provider status**:
   - Verify API keys are valid and have quota
   - Check provider service status pages

2. **Switch to faster model**:
   ```bash
   task-master models --set-main gpt-4o-mini  # Faster but lower quality
   task-master models --set-fallback gpt-4o-mini
   ```

3. **Use local models**:
   ```bash
   # If Ollama is installed
   task-master models --set-main gpt-oss:latest
   ```

4. **Reduce complexity**:
   - Break large PRDs into smaller files
   - Limit task expansion depth

### AWS Bedrock Token Limit Errors

**Problem**: Task expansion or complexity analysis fails with token limit errors

**Symptoms**:
```
Error: The maximum tokens you requested exceeds the model limit of 65536
Error: The maximum tokens you requested exceeds the model limit of 8192
```

**Root Cause**: Task Master requests 100,000 tokens but Bedrock models have much lower limits:
- Claude Sonnet 4: 65,536 tokens
- Claude Haiku: 8,192 tokens

**Solutions**:

1. **Use OpenAI instead of Bedrock** (if you have API keys):
   ```bash
   task-master models --set-main gpt-4o
   task-master models --set-research gpt-4o
   task-master models --set-fallback gpt-4o-mini
   ```

2. **Manual task breakdown** (workaround):
   ```bash
   # Instead of task-master expand --id=1
   # Manually add subtasks:
   task-master add-task --prompt="Create Priority enum for task model"
   task-master add-task --prompt="Implement Task SQLModel with all fields"
   task-master add-task --prompt="Set up Alembic migrations for Task table"
   task-master add-task --prompt="Add database indexes for optimization"
   task-master add-task --prompt="Write unit tests for Task model"

   # Then add dependencies manually:
   task-master add-dependency --id=14 --depends-on=13
   task-master add-dependency --id=15 --depends-on=14
   ```

3. **Skip complexity analysis** (use basic functionality):
   ```bash
   # Skip: task-master analyze-complexity
   # Skip: task-master expand --id=X
   # Use: task-master list, task-master next, task-master show
   ```

4. **Use alternative providers** (if available):
   ```bash
   # Gemini (if you have Google API key)
   task-master models --set-main gemini-2.5-pro

   # Ollama (if running locally)
   task-master models --set-main gpt-oss:latest
   ```

**Note**: This is a known limitation of Task Master v0.26.0 with Bedrock. Future versions may address token limit configuration.

### Memory Issues

**Problem**: Task Master runs out of memory with large projects

**Solutions**:

1. **Increase Node.js memory**:
   ```bash
   export NODE_OPTIONS="--max-old-space-size=4096"
   task-master list
   ```

2. **Clean up old tasks**:
   ```bash
   task-master archive --completed --older-than=30d
   ```

3. **Use task tags for organization**:
   ```bash
   task-master list --tag=current-sprint
   ```

## Integration Issues

### Claude Code Agent Conflicts

**Problem**: Task Master and Claude Code agents conflict

**Solutions**:

1. **Use proper agent sequencing**:
   ```bash
   # Always use Task Master for planning first
   task-master next
   task-master show 1

   # Then use Claude Code agents for implementation
   # Finally update Task Master with results
   task-master set-status --id=1 --status=done
   ```

2. **Configure agent priorities**:
   - Use Task Master for task management
   - Use Claude Code agents for code implementation
   - Avoid overlapping responsibilities

### Git Integration Issues

**Problem**: Task references not linking properly with commits

**Solutions**:

1. **Use consistent task referencing**:
   ```bash
   git commit -m "feat: implement auth (task 1.1)

   Complete task 1.1: JWT authentication
   - Add JWT token generation
   - Implement token validation
   - Add middleware for protected routes

   Task-Master-ID: 1.1"
   ```

2. **Configure git hooks**:
   ```bash
   # .git/hooks/commit-msg
   #!/bin/sh
   # Validate task references in commit messages
   grep -q "task [0-9]" "$1" || echo "Warning: No task reference found"
   ```

## Environment-Specific Issues

### WSL/Linux Issues

**Problem**: Task Master doesn't work properly in WSL

**Solutions**:

1. **Use WSL2 instead of WSL1**
2. **Install Node.js inside WSL**:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **Fix file permissions**:
   ```bash
   chmod +x ~/.npm-global/bin/task-master
   ```

### macOS Issues

**Problem**: Task Master installation fails on macOS

**Solutions**:

1. **Install Xcode command line tools**:
   ```bash
   xcode-select --install
   ```

2. **Use Homebrew Node.js**:
   ```bash
   brew install node
   npm install -g task-master-ai
   ```

### Windows Issues

**Problem**: Task Master doesn't work on Windows

**Solutions**:

1. **Use PowerShell or Windows Terminal**
2. **Install Node.js from official website**
3. **Use WSL2 for better compatibility**

## Debug Commands

### Comprehensive System Check

```bash
# Check all system components
echo "=== System Information ==="
node --version
npm --version
claude --version

echo "=== Task Master Status ==="
task-master --version
task-master models

echo "=== Project Configuration ==="
ls -la .taskmaster/
cat .mcp.json | jq . 2>/dev/null || echo "Invalid .mcp.json or jq not installed"

echo "=== Environment Variables ==="
env | grep -E "(API_KEY|AWS_)" | sed 's/=.*/=***/'

echo "=== Recent Task Master Logs ==="
# Check system logs for task-master errors
journalctl -u task-master --lines=10 2>/dev/null || echo "No systemd logs found"
```

### Enable Debug Logging

```bash
# Enable verbose logging
export DEBUG=task-master:*
task-master list

# Enable AI provider debugging
export ANTHROPIC_DEBUG=true
export OPENAI_DEBUG=true
task-master parse-prd your-prd.md
```

## Getting Help

### Support Channels

1. **Task Master AI GitHub Issues**: Report bugs and feature requests
2. **Claude Code Documentation**: For Claude Code integration issues
3. **Community Forums**: For general usage questions

### When Reporting Issues

Include this information:

```bash
# System information
echo "OS: $(uname -a)"
echo "Node: $(node --version)"
echo "NPM: $(npm --version)"
echo "Task Master: $(task-master --version)"

# Configuration (sanitized)
echo "Models: $(task-master models | grep -E "Main|Research|Fallback")"
echo "MCP Config: $(cat .mcp.json | jq '.mcpServers | keys' 2>/dev/null)"

# Error reproduction steps
echo "Steps to reproduce:"
echo "1. ..."
echo "2. ..."
echo "3. ..."

# Error output
echo "Error output:"
# Include exact error messages
```

This information helps maintainers diagnose issues quickly.