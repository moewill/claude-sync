# Security Policy

## Supported Versions

We actively support the following versions of Claude Sync:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in Claude Sync, please report it responsibly.

### How to Report

**For security issues, please DO NOT open a public GitHub issue.**

Instead, please email security concerns to:
- **Email**: [Create a private security advisory](https://github.com/moewill/claude-sync/security/advisories/new)
- **Alternative**: Create a private GitHub security advisory

### What to Include

When reporting a security issue, please include:

1. **Description**: Clear description of the vulnerability
2. **Steps to Reproduce**: Detailed steps to reproduce the issue
3. **Impact**: What the vulnerability could allow an attacker to do
4. **Environment**: OS, shell version, and Claude Sync version
5. **Proof of Concept**: If possible, include a minimal reproduction

### Response Timeline

- **Initial Response**: Within 48 hours
- **Assessment**: Within 1 week
- **Fix Timeline**: Depends on severity
  - Critical: Within 1-3 days
  - High: Within 1-2 weeks
  - Medium/Low: Next scheduled release

## Security Best Practices

### For Users

**File System Security:**
- Ensure your `~/.claude/` directory has appropriate permissions (700)
- Don't run Claude Sync with unnecessary elevated privileges
- Regularly review synced files for unexpected changes

**Repository Security:**
- Use HTTPS URLs for git operations
- Keep your git repository up to date
- Don't commit sensitive information to your Claude Sync repository

**System Security:**
- Keep your system and shell updated
- Use strong authentication for your git repositories
- Monitor file system changes in sensitive directories

### For Contributors

**Code Security:**
- Never commit secrets, tokens, or sensitive information
- Validate all user inputs and file paths
- Use secure coding practices for shell scripts
- Avoid command injection vulnerabilities

**Development Security:**
- Test security-related changes thoroughly
- Follow the principle of least privilege
- Document security implications of changes

## Known Security Considerations

### File System Access

Claude Sync operates on file system paths and has these security characteristics:

**Mitigations:**
- Only operates within expected directories (`~/.claude/`, repository path)
- Uses relative paths within known directory structures
- Validates file extensions and types

**Limitations:**
- Relies on file system permissions for access control
- Bash script execution inherits user privileges
- Git operations use user's git configuration and credentials

### Git Repository Access

**Security Features:**
- Uses read-only git operations by default
- Respects existing git configuration
- No automatic credential handling

**User Responsibilities:**
- Secure your git credentials appropriately
- Use HTTPS or SSH for repository access
- Regularly audit repository access permissions

## Vulnerability Categories

### In Scope

- Command injection vulnerabilities
- Path traversal attacks
- File permission issues
- Git repository manipulation
- Information disclosure
- Denial of service through resource exhaustion

### Out of Scope

- Issues requiring physical access to the machine
- Social engineering attacks
- Issues in dependencies (git, bash, OS utilities)
- Git repository content security (user responsibility)
- Network security between user and git remote

## Security Updates

Security updates will be:
- Released as soon as possible after verification
- Documented in release notes with CVE information (if applicable)
- Announced through GitHub security advisories
- Backported to supported versions when necessary

## Contact

For security-related questions or concerns:
- Security issues: [GitHub Security Advisories](https://github.com/moewill/claude-sync/security/advisories)
- General security questions: Open a regular GitHub issue with the "security" label

---

Thank you for helping keep Claude Sync secure! 🔒