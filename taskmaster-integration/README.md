# Task Master AI Integration with Claude Code

This directory contains instructions and configurations for integrating Task Master AI with Claude Code agents using AWS Bedrock credentials.

## Overview

Task Master AI is a powerful CLI tool for structured project management that can be integrated with Claude Code to provide automated task generation, tracking, and execution through specialized agents.

## Files in this Directory

- `README.md` - This overview and quick start guide
- `setup-instructions.md` - Detailed setup instructions for new systems
- `mcp-configuration.md` - MCP server configuration details
- `workflow-examples.md` - Common workflows and usage patterns
- `troubleshooting.md` - Common issues and solutions

## Quick Start

1. **Install Task Master AI**:
   ```bash
   npm install -g task-master-ai
   ```

2. **Initialize in your project**:
   ```bash
   task-master init
   ```

3. **Configure models to use MCP**:
   ```bash
   task-master models --set-main mcp-sampling
   task-master models --set-research mcp-sampling
   task-master models --set-fallback mcp-sampling
   ```

4. **Parse a PRD to generate tasks**:
   ```bash
   task-master parse-prd path/to/your-prd.md
   ```

5. **Start working**:
   ```bash
   task-master next  # See next available task
   task-master show <id>  # View task details
   task-master set-status --id=<id> --status=in-progress  # Start work
   ```

## Benefits of Integration

- **Structured Workflow**: Task Master provides organized task management
- **Agent Automation**: Claude Code agents handle implementation details
- **AWS Bedrock**: Uses your existing AWS credentials (no separate API keys needed)
- **Dependency Management**: Automatic task ordering and dependency resolution
- **Progress Tracking**: Visual progress indicators and status management

## Prerequisites

- Node.js installed
- Claude Code CLI installed and configured
- AWS credentials configured for Bedrock access
- MCP server configuration in your project's `.mcp.json`

See the detailed setup instructions for complete configuration steps.