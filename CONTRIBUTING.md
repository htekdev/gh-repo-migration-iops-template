# Contributing to Repository Migration Framework

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project adheres to the Contributor Covenant [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [hector.flores@htek.dev](mailto:hector.flores@htek.dev).

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/enbridge-enb-migrate.git
   cd enbridge-enb-migrate
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to Contribute

### Types of Contributions

- **Bug Fixes**: Fix existing issues or bugs
- **New Features**: Add support for new source systems or capabilities
- **Documentation**: Improve documentation, add examples
- **Code Quality**: Refactor code, improve performance
- **Testing**: Add or improve tests

### Before You Start

- Check [existing issues](../../issues) to see if your idea is already being discussed
- For major changes, open an issue first to discuss your approach
- Ensure your contribution aligns with the project's goals

## Development Setup

### Prerequisites

- **PowerShell 7.0+** (PowerShell Core recommended)
- **Git** command-line tools
- **GitHub CLI** (`gh`) - [Installation guide](https://cli.github.com/)
- **GitHub Account** with appropriate permissions

### Required PowerShell Modules

The framework automatically installs these modules, but you can install them manually:

```powershell
Install-Module -Name powershell-yaml -Scope CurrentUser -Force
Install-Module -Name jwtPS -Scope CurrentUser -Force
```

### Testing Your Changes

1. **Set up a test organization** or use a personal GitHub account
2. **Configure GitHub App** following the README instructions
3. **Test locally** before submitting:
   ```powershell
   # Test script syntax
   pwsh -File scripts/Your-Script.ps1 -WhatIf
   ```
4. **Validate workflows** using:
   ```bash
   # Install actionlint
   brew install actionlint  # macOS
   # or download from https://github.com/rhysd/actionlint
   
   # Validate workflow files
   actionlint .github/workflows/*.yml
   ```

## Coding Standards

### PowerShell Style Guide

#### Naming Conventions

- **Functions**: Use `PascalCase` with approved PowerShell verbs
  ```powershell
  Function New-GitHubRepo { }
  Function Update-GitHubToken { }
  Function Test-TeamExists { }
  ```

- **Parameters**: Use `PascalCase`
  ```powershell
  Param(
    [string] $GitHubRepoUrl,
    [string] $DeliverableProvider
  )
  ```

- **Variables**: Use `camelCase` for local variables, `PascalCase` for parameters
  ```powershell
  $cloneUrl = "https://github.com/..."
  $adoOrg = $env:IMPORT_ADO_ORGANIZATION
  ```

- **Workflow Inputs**: Use `kebab-case`
  ```yaml
  deliverable-provider:
  deliverable-owner:
  team-name:
  ```

#### Code Structure

1. **Module Imports**: Always source `modules.ps1` at the start:
   ```powershell
   . "$($PSScriptRoot)/modules.ps1"
   ```

2. **Error Handling**: Use try-catch-finally blocks:
   ```powershell
   try {
     # Main operations
     $result = Invoke-SomeOperation
     Write-Output "| **Operation** | ✅ | Success |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
   }
   catch {
     Write-Output "| **Operation** | ❌ | $($_.Exception.Message) |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
     throw $_
   }
   finally {
     # Cleanup
     Pop-Location
     Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
   }
   ```

3. **Comments**: Use clear, descriptive comments:
   ```powershell
   # Parse components from GitHub repo URL using regex
   $githubRepoUrlRegex = [regex]::new('https://github.com/(?<organization>.+)/(?<repo>.+)')
   ```

4. **Job Summaries**: Always update GitHub Actions job summary:
   ```powershell
   Write-Output "| Name | Status | Notes |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
   Write-Output "| ---- | ------ | ----- |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
   ```

#### Security Best Practices

- **Never log secrets** or sensitive information
- **Use GitHub secrets** for credentials
- **Validate all user inputs** against regex patterns
- **Sanitize file paths** and repository names
- **Use service tokens** with minimal required permissions

#### Git Operations

- **Service Account Commits**: Use bot account for automated commits:
  ```bash
  git config user.name "app-name[bot]"
  git config user.email "app-id+app-name[bot]@users.noreply.github.com"
  ```

- **Descriptive Commit Messages**: Follow conventional commits:
  ```
  feat: add support for GitLab migrations
  fix: resolve team creation race condition
  docs: update security reporting guidelines
  ```

### YAML Workflow Standards

- Use **2-space indentation**
- Keep lines under **120 characters** when possible
- Use **descriptive step names**
- Add **comments** for complex logic
- Group related inputs/outputs together

## Pull Request Process

### Before Submitting

1. **Test your changes** thoroughly
2. **Update documentation** if you've changed functionality
3. **Add entries to CHANGELOG.md** under "Unreleased"
4. **Ensure all checks pass** (linting, validation)
5. **Keep commits clean** - squash if necessary

### Submitting a PR

1. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a pull request** from your fork to the main repository

3. **Fill out the PR template** with:
   - Clear description of changes
   - Related issue numbers
   - Testing performed
   - Screenshots/examples if applicable

4. **Address review feedback** promptly

### PR Requirements

- ✅ All CI checks must pass
- ✅ Code follows style guidelines
- ✅ Documentation is updated
- ✅ No merge conflicts
- ✅ Approved by at least one maintainer

### After Approval

- Maintainers will merge your PR
- Your contribution will be included in the next release
- You'll be added to the contributors list

## Reporting Issues

### Bug Reports

Use the bug report template and include:

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Exact steps to reproduce the issue
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Environment**: OS, PowerShell version, GitHub CLI version
- **Logs**: Relevant log output (redact sensitive information)

### Feature Requests

Use the feature request template and include:

- **Use Case**: Why this feature is needed
- **Proposed Solution**: How you envision it working
- **Alternatives**: Other solutions you've considered
- **Additional Context**: Any other relevant information

### Security Vulnerabilities

**DO NOT** open public issues for security vulnerabilities. Instead, email [hector.flores@htek.dev](mailto:hector.flores@htek.dev) directly. See [SECURITY.md](SECURITY.md) for details.

## Questions?

- **Documentation**: Check the [README](README.md) and [Skills documentation](.github/skills/)
- **GitHub Discussions**: Ask questions in [Discussions](../../discussions)
- **Issues**: Search [existing issues](../../issues) or create a new one
- **Email**: Contact [hector.flores@htek.dev](mailto:hector.flores@htek.dev)

## Recognition

Contributors will be recognized in:
- The repository's contributor list
- Release notes
- The project README

Thank you for contributing to make repository migrations easier for everyone! 🎉
