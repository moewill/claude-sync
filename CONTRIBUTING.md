# Contributing to Claude Sync

Thank you for your interest in contributing to Claude Sync! This document provides guidelines and information for contributors.

## 🎯 Ways to Contribute

### 🐛 Bug Reports
- Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
- Include OS, shell version, and exact commands run
- Provide error output and expected vs actual behavior

### ✨ Feature Requests
- Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)
- Describe the use case and expected behavior
- Consider implementation complexity and scope

### 🔧 Code Contributions
- Bug fixes
- New sync modes or features
- Performance improvements
- Cross-platform compatibility
- Documentation improvements

### 📚 Agent Contributions
- New Claude agents for specialized tasks
- Improvements to existing agents
- Agent testing and validation
- Usage examples and documentation

## 🛠️ Development Setup

### Prerequisites
- Bash 4.0+ (for associative arrays)
- Git 2.0+
- Basic Unix tools: `find`, `rsync`, `cp`

### Setting Up Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-sync.git
   cd claude-sync
   ```

2. **Create Development Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Test Your Setup**
   ```bash
   chmod +x sync.sh
   ./sync.sh --help
   ```

## 📋 Development Guidelines

### Code Style

**Shell Script Standards:**
- Use `#!/bin/bash` shebang
- Enable strict mode: `set -e`
- Use `local` for function variables
- Quote variables to prevent word splitting: `"$variable"`
- Use meaningful function and variable names
- Add comments for complex logic

**Example:**
```bash
#!/bin/bash
set -e

# Function to sync files bidirectionally
sync_file_bidirectional() {
    local local_file="$1"
    local repo_file="$2"
    local file_type="$3"

    # Check if both files exist and compare timestamps
    if [[ -f "$local_file" && -f "$repo_file" ]]; then
        # Your logic here
    fi
}
```

### Agent Development Standards

**File Naming:**
- Task agents: `[domain]-coding-agent.md`
- Critique agents: `anti[domain]-code-critique.md`
- Example: `react-coding-agent.md`, `antireact-code-critique.md`

**Agent Structure:**
```markdown
# [Agent Name]

## Purpose
Brief description of what this agent does.

## When to Use
- Specific scenario 1
- Specific scenario 2

## Tools Available
- List of tools this agent can use

## Examples
Practical examples of agent usage.
```

### Testing

**Manual Testing Checklist:**
- [ ] Test all sync modes (`--repo-to-local`, `--local-to-repo`, `--bidirectional`)
- [ ] Test with empty directories
- [ ] Test with missing files in one location
- [ ] Test with newer files in both directions
- [ ] Test preview matches actual sync behavior
- [ ] Test error handling (permission issues, missing git repo)

**Test Commands:**
```bash
# Test basic functionality
./sync.sh --help
./sync.sh --repo-to-local
echo "n" | ./sync.sh  # Test preview with cancel

# Test different scenarios
mkdir -p /tmp/test/{local,repo}/agents
echo "test" > /tmp/test/local/agents/test.md
# ... create test scenarios
```

## 🚀 Submission Process

### Before Submitting

1. **Test Thoroughly**
   ```bash
   # Test all modes
   ./sync.sh --repo-to-local
   ./sync.sh --local-to-repo
   ./sync.sh --bidirectional

   # Test edge cases
   # ... your testing steps
   ```

2. **Update Documentation**
   - Update README.md if adding new features
   - Add examples for new functionality
   - Update help text in sync.sh if needed

3. **Commit Standards**
   ```bash
   # Use conventional commits
   git commit -m "feat: add Windows PowerShell support"
   git commit -m "fix: handle spaces in file paths correctly"
   git commit -m "docs: add troubleshooting section"
   ```

### Pull Request Process

1. **Create Descriptive PR**
   - Use the [PR template](.github/pull_request_template.md)
   - Explain what changes were made and why
   - Reference any related issues: `Fixes #123`

2. **PR Checklist**
   - [ ] Changes tested on Linux/macOS
   - [ ] Documentation updated if needed
   - [ ] No breaking changes (or clearly documented)
   - [ ] Code follows project style guidelines
   - [ ] All tests pass manually

3. **Review Process**
   - Maintainers will review within 1-2 weeks
   - Address feedback promptly
   - Squash commits if requested
   - Rebase on main if needed

## 📦 Release Process

### Version Scheme
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Agent Versioning
Agents are versioned with the repository but can be updated independently.

## 🌐 Cross-Platform Support

### Current Support
- ✅ Linux (bash 4.0+)
- ✅ macOS (bash 3.2+ with limitations)
- ⏳ Windows (WSL/Git Bash)
- ⏳ Windows (PowerShell - planned)

### Platform-Specific Guidelines

**Linux/macOS:**
- Use standard bash features
- Test on both platforms when possible
- Handle path differences gracefully

**Windows (Future):**
- PowerShell version planned
- Consider Windows path conventions
- Handle line endings (CRLF vs LF)

## 🤝 Community Guidelines

### Communication
- Be respectful and constructive
- Use clear, descriptive language
- Help others learn and improve
- Share knowledge and best practices

### Issue Handling
- Check for existing issues before creating new ones
- Provide clear reproduction steps
- Be patient with response times
- Help others when you can

## 📚 Resources

### Learning Resources
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Git Workflow](https://guides.github.com/introduction/git-handbook/)

### Claude Code Resources
- [Claude Code Documentation](https://docs.claude.ai/code)
- [Agent Development Best Practices](https://docs.claude.ai/agents)

## ❓ Questions?

- 💬 [Discussions](https://github.com/moewill/claude-sync/discussions) - General questions
- 🐛 [Issues](https://github.com/moewill/claude-sync/issues) - Bug reports and feature requests
- 📧 Email: maintainers@claude-sync.dev (if available)

---

Thank you for contributing to Claude Sync! 🎉