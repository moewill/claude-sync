# Claude Sync

> Intelligent synchronization tool for Claude Code commands, agents, and configuration files

Claude Sync is a comprehensive tool that helps you manage and synchronize your Claude Code configuration across different machines and repositories. It provides bidirectional sync capabilities, allowing you to keep your commands, agents, and global configuration in perfect harmony.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/shell-bash-green.svg)](https://www.gnu.org/software/bash/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

## 🚀 Features

- **Bidirectional Sync**: Intelligently sync based on file modification times
- **Multi-mode Support**: Choose from repo-to-local, local-to-repo, or bidirectional sync
- **Preview Changes**: See exactly what will be synced before making changes
- **Agent Management**: Sync specialized Claude agents for different development tasks
- **Configuration Sync**: Keep your global Claude configuration (CLAUDE.md) synchronized
- **Command Workflows**: Access structured development workflows and commands

## 📦 What Gets Synced

### Commands (`~/.claude/commands/`)
- **create-prd.md** - Process for creating Product Requirements Documents
- **generate-tasks.md** - Task generation workflows
- **process-task-list.md** - Task list processing procedures
- **Architecture documentation** - React/Vite/TypeScript patterns

### Agents (`~/.claude/agents/`)
- **React Development**: `reactcoding-agent.md`, `antireact-code-critique.md`
- **JavaScript/Node.js**: `javascript-coding-agent.md`, `anti-javascript-critique.md`
- **Infrastructure**: `pulumi-coding-agent.md`, `antipulumi-code-critique.md`
- **API Development**: `fastapi-coding-agent.md`, `antifastapi-code-critique.md`
- **Build Tools**: `vite-coding-agent.md`, `antivite-code-critique.md`

### Configuration (`~/.claude/CLAUDE.md`)
- Global Claude Code settings and preferences
- Agent usage rules and workflow guidelines
- Project-specific configuration patterns

## 🛠️ Installation

### Quick Install (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/moewill/claude-sync/main/install.sh | bash
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/moewill/claude-sync.git
cd claude-sync

# Make the sync script executable
chmod +x sync.sh

# Optional: Add to PATH for global access
sudo ln -s $(pwd)/sync.sh /usr/local/bin/claude-sync
```

### Sparse Checkout (Commands Only)

If you only need the commands and don't want the full repository:

```bash
# Clone without checking out files
git clone --no-checkout https://github.com/moewill/claude-sync.git
cd claude-sync

# Enable sparse checkout for commands only
git sparse-checkout init --cone
git sparse-checkout set commands
git checkout
```

## 📖 Usage

### Basic Usage

```bash
# Default bidirectional sync with preview
./sync.sh

# Sync from repository to local
./sync.sh --repo-to-local

# Sync from local to repository
./sync.sh --local-to-repo

# Show help
./sync.sh --help
```

### Sync Modes Explained

| Mode | Description | Use Case |
|------|-------------|----------|
| `--bidirectional` | Two-way sync based on file timestamps (default) | Keep everything in sync automatically |
| `--repo-to-local` | Updates local files with repository versions | Fresh setup or reset to repo state |
| `--local-to-repo` | Updates repository with local file versions | Backup local changes to repository |

### Example Workflow

```bash
# 1. Preview what would be synced
./sync.sh
# Review the preview and confirm with 'y'

# 2. Make changes to local agents
vim ~/.claude/agents/my-custom-agent.md

# 3. Sync changes back to repo
./sync.sh --local-to-repo

# 4. Later, sync latest repo changes
./sync.sh --repo-to-local
```

## 🔧 Configuration

The sync script uses these default paths:
- **Commands**: `~/.claude/commands/`
- **Agents**: `~/.claude/agents/`
- **Global Config**: `~/.claude/CLAUDE.md`

These directories are created automatically if they don't exist.

## 🏗️ Repository Structure

```
claude-sync/
├── agents/                 # Claude agents for specialized tasks
│   ├── reactcoding-agent.md
│   ├── javascript-coding-agent.md
│   └── ...
├── commands/               # Development workflow commands
│   ├── create-prd.md
│   ├── generate-tasks.md
│   └── arch-docs/
├── taskmaster-integration/ # Taskmaster MCP integration
├── claude.md              # Global Claude configuration
├── sync.sh                # Main sync script
└── README.md
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test with different sync modes
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Adding New Agents

When adding new Claude agents:

1. Create the agent file in `agents/` directory
2. Follow the naming convention: `[task-type]-agent.md` or `anti[task-type]-code-critique.md`
3. Include comprehensive documentation and examples
4. Test the agent in real scenarios

## 🐛 Troubleshooting

### Common Issues

**Sync fails with permission error:**
```bash
chmod +x sync.sh
```

**Git pull fails:**
```bash
cd /path/to/claude-sync
git status
git stash  # if you have uncommitted changes
git pull origin main
```

**Files not syncing:**
- Check file permissions in `~/.claude/` directories
- Verify the script has read/write access to both locations
- Use `--help` to verify correct flag usage

### Getting Help

- Check existing [Issues](https://github.com/moewill/claude-sync/issues)
- Create a new issue with:
  - Your operating system
  - Command you ran
  - Error output
  - Expected vs actual behavior

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for the Claude Code ecosystem
- Inspired by the need for better development workflow management
- Community-driven agent and command development

## 📊 Project Status

- ✅ Core sync functionality
- ✅ Bidirectional sync with preview
- ✅ Agent and command management
- ✅ Cross-platform bash support
- 🔄 CI/CD pipeline (in progress)
- 🔄 Windows PowerShell version (planned)

---

**Made with ❤️ for the Claude Code community**