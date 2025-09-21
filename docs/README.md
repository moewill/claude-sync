# Documentation

This directory contains comprehensive documentation for Claude Sync.

## 📚 Documentation Index

### Core Documentation
- **[Architecture](ARCHITECTURE.md)** - System design and technical architecture
- **[API Documentation](API.md)** - Command-line interface and functions (planned)

### Development Guidelines
- **[Claude Sonnet Anti-patterns](claude-sonnet-anti-patterns.md)** - Best practices and patterns to avoid
- **[JIRA Story Creation Guidelines](jira-story-creation-guidelines.md)** - Project management guidelines

### Project Information
- **[Security Policy](../SECURITY.md)** - Security reporting and best practices
- **[Contributing Guidelines](../CONTRIBUTING.md)** - How to contribute to the project
- **[Changelog](../CHANGELOG.md)** - Version history and release notes

## 🔗 External Resources

### Claude Code Documentation
- [Claude Code Official Docs](https://docs.claude.ai/code)
- [Agent Development Guide](https://docs.claude.ai/agents)
- [Best Practices](https://docs.claude.ai/best-practices)

### Development Resources
- [Bash Scripting Guide](https://tldp.org/LDP/Bash-Beginners-Guide/html/)
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Git Workflow Best Practices](https://guides.github.com/introduction/git-handbook/)

## 📖 Quick Reference

### Common Tasks
```bash
# Get help
./sync.sh --help

# Default sync with preview
./sync.sh

# One-way sync modes
./sync.sh --repo-to-local
./sync.sh --local-to-repo
```

### Directory Structure
```
~/.claude/
├── commands/          # Development workflows
├── agents/           # Specialized Claude agents
└── CLAUDE.md        # Global configuration
```

### File Conventions
- **Agents**: `[domain]-coding-agent.md`, `anti[domain]-code-critique.md`
- **Commands**: `[action]-[object].md`
- **Documentation**: Standard markdown with clear headers

## 🤝 Contributing Documentation

When contributing documentation:

1. **Follow Conventions**: Use consistent formatting and structure
2. **Include Examples**: Provide practical usage examples
3. **Update Index**: Add new documents to relevant index files
4. **Cross-reference**: Link to related documentation
5. **Keep Updated**: Maintain accuracy with code changes

## 📧 Documentation Feedback

Found an issue with the documentation?
- Open a [GitHub Issue](https://github.com/moewill/claude-sync/issues)
- Submit a [Pull Request](https://github.com/moewill/claude-sync/pulls) with fixes
- Start a [Discussion](https://github.com/moewill/claude-sync/discussions) for questions

---

**Happy documenting! 📝**