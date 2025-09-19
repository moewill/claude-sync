# Task Master AI Setup Instructions

Complete step-by-step instructions for setting up Task Master AI integration with Claude Code on a new system.

## Prerequisites

1. **Node.js** (v16 or higher)
2. **Claude Code CLI** installed and configured
3. **AWS credentials** configured for Bedrock access
4. **Git** for repository management

## Step 1: Install Task Master AI

```bash
npm install -g task-master-ai
```

## Step 2: Project Setup

Navigate to your project directory and initialize Task Master:

```bash
cd /path/to/your/project
task-master init
```

This creates the `.taskmaster/` directory with necessary configuration files.

## Step 3: Configure MCP Server

Create or update `.mcp.json` in your project root:

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

**Note**: If you're using AWS Bedrock (recommended), you don't need these API keys - Task Master will use your AWS credentials.

## Step 4: Configure Task Master Models

### Option A: Using AWS Bedrock (Recommended)

If you have AWS credentials configured for Bedrock:

```bash
# Set all models to use Bedrock with Claude Sonnet 4
task-master models --set-main us.anthropic.claude-sonnet-4-20250514-v1:0
task-master models --set-research us.anthropic.claude-sonnet-4-20250514-v1:0
task-master models --set-fallback us.anthropic.claude-3-5-haiku-20241022-v1:0
```

### Option B: Using MCP (For Claude Code Agent Integration)

To route through Claude Code agents:

```bash
task-master models --set-main mcp-sampling
task-master models --set-research mcp-sampling
task-master models --set-fallback mcp-sampling
```

### Option C: Using Direct API Keys

If you have API keys configured:

```bash
task-master models --set-main gpt-4o
task-master models --set-research gpt-4o
task-master models --set-fallback gpt-4o-mini
```

## Step 5: Verify Configuration

Check that everything is configured correctly:

```bash
task-master models
```

You should see your configured models listed with ✅ indicators for available API keys.

## Step 6: Create Your First PRD

Create a Product Requirements Document (PRD) in markdown format. Save it as `tasks/prd-your-feature.md`:

```markdown
# Your Feature Name

## Overview
Brief description of what you're building.

## Features
1. Feature 1 description
2. Feature 2 description
3. Feature 3 description

## Technical Requirements
- Technology stack requirements
- Database requirements
- API requirements
- Frontend requirements

## Success Criteria
- Measurable outcomes
- Performance requirements
- User experience goals
```

## Step 7: Generate Tasks from PRD

Parse your PRD to generate structured tasks:

```bash
task-master parse-prd tasks/prd-your-feature.md
```

## Step 8: Start Working

View your generated tasks:

```bash
task-master list
```

Get the next available task:

```bash
task-master next
```

View detailed task information:

```bash
task-master show <task-id>
```

Start working on a task:

```bash
task-master set-status --id=<task-id> --status=in-progress
```

Break down complex tasks into subtasks:

```bash
task-master expand --id=<task-id>
```

Complete a task:

```bash
task-master set-status --id=<task-id> --status=done
```

## File Structure After Setup

```
your-project/
├── .taskmaster/
│   ├── tasks/
│   │   ├── tasks.json      # Main task database
│   │   └── task-*.md       # Individual task files
│   ├── config.json         # AI model configuration
│   └── templates/          # Template files
├── tasks/
│   └── prd-your-feature.md # Your PRD files
├── .mcp.json              # MCP server configuration
└── CLAUDE.md              # Claude Code instructions (if using)
```

## Environment Variables

If using direct API access, ensure these environment variables are set:

```bash
# For AWS Bedrock (recommended)
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Or for direct API access
export ANTHROPIC_API_KEY="your-anthropic-key"
export OPENAI_API_KEY="your-openai-key"
export PERPLEXITY_API_KEY="your-perplexity-key"
```

## Verification Steps

1. **Test Task Master installation**:
   ```bash
   task-master --version
   ```

2. **Test model configuration**:
   ```bash
   task-master models
   ```

3. **Test task generation**:
   ```bash
   task-master add-task --prompt="Test task creation"
   ```

4. **Test MCP integration** (if using):
   Start Claude Code and verify MCP connection works.

## Next Steps

- Read `workflow-examples.md` for common usage patterns
- Check `troubleshooting.md` if you encounter issues
- Configure custom slash commands in Claude Code for streamlined workflows

## Important Notes

- Always use `task-master generate` after making manual changes to tasks.json
- Keep your PRD files in version control for team collaboration
- Use tags (`--tag`) to separate different project phases or features
- Task Master supports parallel development with dependency management