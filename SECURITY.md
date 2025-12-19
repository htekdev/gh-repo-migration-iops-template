# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of the Repository Migration Framework seriously. If you discover a security vulnerability, please follow these guidelines:

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please email us directly at:
- **Email**: [hector.flores@htek.dev](mailto:hector.flores@htek.dev)
- **Subject**: `[SECURITY] Repository Migration Framework Vulnerability`

### What to Include

Please include as much of the following information as possible:

1. **Description**: A clear description of the vulnerability
2. **Impact**: What an attacker could achieve by exploiting this vulnerability
3. **Steps to Reproduce**: Detailed steps to reproduce the vulnerability
4. **Affected Versions**: Which versions of the framework are affected
5. **Suggested Fix**: If you have suggestions for how to fix the issue
6. **Contact Info**: How we can reach you for follow-up questions

### What to Expect

After you email us, here's what you can expect:

1. **Acknowledgment**: We'll acknowledge receipt of your report within **48 hours**
2. **Initial Assessment**: We'll provide an initial assessment within **5 business days**
3. **Regular Updates**: We'll keep you informed of our progress at least every **7 days**
4. **Resolution**: We'll work to resolve critical vulnerabilities within **30 days**

### Responsible Disclosure

We follow responsible disclosure practices:

- We'll work with you to understand the vulnerability
- We'll develop and test a fix
- We'll coordinate the release of the fix
- We'll publicly acknowledge your contribution (unless you prefer to remain anonymous)

## Security Features

The Repository Migration Framework implements several security measures:

### Authentication & Authorization
- Uses GitHub Apps for secure authentication with minimal required permissions
- Supports enterprise-grade authentication methods (ADO PAT, BitBucket app passwords)
- Validates team membership before granting repository access

### Data Protection
- Does not log or expose sensitive information (passwords, tokens, private keys)
- Implements secure credential handling patterns
- Uses temporary directories for isolation during migrations

### Input Validation
- Validates repository names, URLs, and user inputs against strict patterns
- Sanitizes file paths and prevents directory traversal
- Checks for SQL injection and command injection patterns

### Access Controls
- Implements hierarchical team structures with appropriate permissions
- Supports both critical (private) and non-critical (internal) repository configurations
- Automatically configures branch protection rules

## Security Best Practices for Users

### GitHub App Configuration
- Grant only the minimum required permissions to the GitHub App
- Regularly rotate private keys and access tokens
- Monitor app installations and remove unused ones

### Source System Integration
- Use service accounts with minimal permissions for source systems
- Rotate credentials regularly
- Enable audit logging where available

### Repository Security
- Review migrated repositories for accidentally committed secrets
- Enable secret scanning and push protection
- Configure branch protection rules appropriate for your criticality level

### Monitoring
- Monitor GitHub audit logs for unusual activity
- Set up alerts for failed authentications
- Review repository access regularly

## Known Security Considerations

### Migration Process
- **Temporary exposure**: During migration, repositories may have relaxed security settings
- **History preservation**: Git history is preserved, including potentially sensitive commits
- **Network transit**: Data travels between systems during migration

### Mitigation Strategies
- Migrations disable secret scanning temporarily, then re-enable after completion
- BFG tool support for cleaning sensitive data from git history
- Encrypted HTTPS connections for all data transfer

## Security Contact

For security-related questions or concerns:
- **Primary**: [hector.flores@htek.dev](mailto:hector.flores@htek.dev)
- **Project**: [Repository Issues](../../issues) (for non-sensitive security questions only)

## Updates to This Policy

This security policy may be updated from time to time. Check back regularly or watch this repository for notifications of changes.

---

**Last Updated**: December 19, 2025