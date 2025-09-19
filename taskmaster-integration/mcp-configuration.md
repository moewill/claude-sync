# MCP Configuration for Task Master Integration

This document explains how to configure the Model Context Protocol (MCP) server for Task Master AI integration with Claude Code.

## What is MCP?

MCP (Model Context Protocol) allows Claude Code to communicate with external tools like Task Master AI, enabling seamless integration between task management and code implementation.

## MCP Server Configuration

### Basic .mcp.json Setup

Create `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "--package=task-master-ai",
        "task-master-ai"
      ],
      "env": {
        "ANTHROPIC_API_KEY": "YOUR_ANTHROPIC_API_KEY_HERE",
        "PERPLEXITY_API_KEY": "YOUR_PERPLEXITY_API_KEY_HERE",
        "OPENAI_API_KEY": "YOUR_OPENAI_KEY_HERE",
        "GOOGLE_API_KEY": "YOUR_GOOGLE_KEY_HERE",
        "XAI_API_KEY": "YOUR_XAI_KEY_HERE",
        "OPENROUTER_API_KEY": "YOUR_OPENROUTER_KEY_HERE",
        "MISTRAL_API_KEY": "YOUR_MISTRAL_KEY_HERE",
        "AZURE_OPENAI_API_KEY": "YOUR_AZURE_KEY_HERE",
        "OLLAMA_API_KEY": "YOUR_OLLAMA_API_KEY_HERE"
      }
    }
  }
}
```

### Using AWS Bedrock (Recommended)

If you're using AWS Bedrock credentials, add these to the env section:

```json
{
  "mcpServers": {
    "task-master-ai": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "--package=task-master-ai",
        "task-master-ai"
      ],
      "env": {
        "AWS_ACCESS_KEY_ID": "your-aws-access-key",
        "AWS_SECRET_ACCESS_KEY": "your-aws-secret-key",
        "AWS_DEFAULT_REGION": "us-east-1",
        "ANTHROPIC_API_KEY": "dummy-key-for-mcp"
      }
    }
  }
}
```

## Available MCP Tools

When the MCP server is configured, you'll have access to these tools in Claude Code:

### Core Task Management
- `help` - Show available taskmaster commands
- `initialize_project` - Initialize Task Master in current project
- `parse_prd` - Generate tasks from PRD document
- `get_tasks` - List all tasks with status
- `next_task` - Get next available task to work on
- `get_task` - View detailed task information
- `set_task_status` - Mark task as complete/in-progress/etc

### Task Operations
- `add_task` - Add new task with AI assistance
- `expand_task` - Break task into subtasks
- `update_task` - Update specific task
- `update_subtask` - Add implementation notes to subtask
- `update` - Update multiple tasks from ID onwards

### Analysis & Planning
- `analyze_project_complexity` - Analyze task complexity
- `complexity_report` - View complexity analysis

## Task Master Model Configuration

Configure Task Master to use the MCP provider:

```bash
# Set all models to use MCP (routes through Claude Code)
task-master models --set-main mcp-sampling
task-master models --set-research mcp-sampling
task-master models --set-fallback mcp-sampling
```

## Claude Code Integration

### Custom Slash Commands

Create `.claude/commands/taskmaster-next.md`:

```markdown
Find the next available Task Master task and show its details.

Steps:
1. Run `task-master next` to get the next task
2. If a task is available, run `task-master show <id>` for full details
3. Provide a summary of what needs to be implemented
4. Suggest the first implementation step
```

Create `.claude/commands/taskmaster-complete.md`:

```markdown
Complete a Task Master task: $ARGUMENTS

Steps:
1. Review the current task with `task-master show $ARGUMENTS`
2. Verify all implementation is complete
3. Run any tests related to this task
4. Mark as complete: `task-master set-status --id=$ARGUMENTS --status=done`
5. Show the next available task with `task-master next`
```

### Tool Allowlist

Add to `.claude/settings.json`:

```json
{
  "allowedTools": [
    "Edit",
    "Bash(task-master *)",
    "Bash(git commit:*)",
    "Bash(git add:*)",
    "Bash(npm run *)",
    "mcp__task_master_ai__*"
  ]
}
```

## Workflow Integration

### Standard Development Loop

1. **Start Claude Code** with MCP configured
2. **Use MCP tools** directly in Claude Code:
   ```
   Use the get_tasks tool to see all available tasks
   Use the next_task tool to get the next task to work on
   Use the get_task tool with id 1 to see task details
   ```

3. **Implement with agents** following your agent workflow
4. **Update progress** using MCP tools:
   ```
   Use the set_task_status tool with id 1 and status "done"
   ```

### Task Generation Workflow

1. **Create PRD** in `tasks/prd-feature-name.md`
2. **Parse with MCP**:
   ```
   Use the parse_prd tool with file path "tasks/prd-feature-name.md"
   ```
3. **Analyze complexity**:
   ```
   Use the analyze_project_complexity tool
   ```
4. **Expand tasks**:
   ```
   Use the expand_task tool with id 1 to break it down
   ```

## Debugging MCP Connection

### Check MCP Server Status

Start Claude Code with debug mode:
```bash
claude --mcp-debug
```

### Verify Task Master Installation

```bash
npx -y --package=task-master-ai task-master-ai --version
```

### Test MCP Tools

In Claude Code, try:
```
Use the help tool to see available taskmaster commands
```

### Common Issues

1. **MCP server not starting**:
   - Check Node.js is installed
   - Verify task-master-ai package can be installed
   - Check .mcp.json syntax

2. **API key issues**:
   - Ensure at least one API key is configured
   - For AWS Bedrock, verify AWS credentials are working

3. **Permission errors**:
   - Check file permissions on .mcp.json
   - Verify Claude Code can execute npx commands

## Environment Isolation

For team projects, consider:

1. **Project-specific MCP config**: Keep .mcp.json in project repo
2. **Shared environment variables**: Use .env files for API keys
3. **Documentation**: Keep MCP setup in project README

## Security Considerations

1. **API Keys**: Never commit real API keys to version control
2. **Environment Variables**: Use secure environment variable management
3. **MCP Access**: Limit MCP server access to necessary tools only
4. **Network Security**: MCP runs locally, but be aware of network implications

## Alternative Configurations

### Local Ollama Setup

```json
{
  "mcpServers": {
    "task-master-ai": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "OLLAMA_API_KEY": "ollama-local",
        "OLLAMA_BASE_URL": "http://localhost:11434"
      }
    }
  }
}
```

### Multiple Provider Setup

```json
{
  "mcpServers": {
    "task-master-ai": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "--package=task-master-ai", "task-master-ai"],
      "env": {
        "ANTHROPIC_API_KEY": "sk-ant-...",
        "OPENAI_API_KEY": "sk-...",
        "PERPLEXITY_API_KEY": "pplx-..."
      }
    }
  }
}
```

This allows Task Master to fallback between providers as needed.