# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Open source documentation and community files
- LICENSE file (MIT)
- CONTRIBUTING.md with development guidelines
- SECURITY.md with vulnerability reporting process
- Pull request template
- Comprehensive .gitignore file

### Changed
- README.md updated with open source standards

## [1.0.0] - 2025-12-19

### Added
- Initial release of Repository Migration Framework
- Support for migrating from Azure DevOps (ADO), BitBucket, SVN, and GitHub
- Automated repository creation with standardized naming conventions
- Team management with hierarchical permission structures
- GitHub App authentication system
- PowerShell-based automation scripts
- GitHub Actions workflows for migration orchestration
- Issue-based migration request system
- Custom repository properties support
- Azure DevOps integration for pipeline rewiring and board integration
- Branch protection and security configuration
- Comprehensive logging and error handling

### Migration Sources
- **Azure DevOps**: Git repositories and TFVC with folder-specific migration
- **BitBucket**: Git repositories with authentication
- **Subversion**: SVN repositories with history conversion
- **GitHub**: Repository-to-repository migrations (internal and external)

### Features
- **Repository Management**: Automated creation, naming validation, visibility control
- **Team Structure**: Parent teams, owner teams, admin teams with proper permissions
- **Security**: Branch protection, secret scanning integration, criticality-based access
- **Extensibility**: Modular PowerShell architecture, GitHub CLI extensions
- **Documentation**: Comprehensive setup guides, troubleshooting, and skill-based assistance

### Documentation
- Complete setup instructions with GitHub App creation
- Step-by-step configuration guides
- Source system integration documentation
- Troubleshooting guides and FAQ
- GitHub Copilot Coding Agent skills integration

---

## Release Notes Template

### [Version Number] - YYYY-MM-DD

#### Added
- New features and capabilities

#### Changed  
- Changes in existing functionality

#### Deprecated
- Soon-to-be removed features

#### Removed
- Removed features

#### Fixed
- Bug fixes

#### Security
- Security improvements and fixes

---

**Links:**
- [Unreleased]: ../../compare/v1.0.0...HEAD
- [1.0.0]: ../../releases/tag/v1.0.0