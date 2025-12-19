# Repository Migration Framework

[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![GitHub CLI](https://img.shields.io/badge/GitHub%20CLI-Required-green.svg)](https://cli.github.com/)

A comprehensive automation framework that simplifies and standardizes repository migrations into GitHub from various source control systems including Azure DevOps, BitBucket, SVN, and other GitHub repositories.

## What is This?

The Repository Migration Framework automates the complex process of moving repositories between different source control systems while preserving git history, setting up proper team structures, and configuring security controls. It eliminates manual migration steps and ensures consistent, repeatable results.

**Key Benefits:**
- 🚀 **Automated End-to-End Migration** - Complete repository setup with one workflow
- 🔒 **Security-First Design** - Proper permissions, branch protection, and team management
- 🎯 **Multiple Source Support** - ADO, BitBucket, SVN, and GitHub migrations
- 📋 **Standardized Process** - Consistent naming, structure, and configuration
- 🛠️ **Enterprise Ready** - GitHub Apps, audit logging, and compliance features


---

## Setup Instructions

### Step 1: Create Your Repository from This Template

**Click here to create:** [Use this template](../../generate)

Or manually:
1. Click the green **"Use this template"** button at the top of this page
2. Choose your organization
3. Name your repository (e.g., `repo-migration`)
4. Set visibility to **Private** or **Internal**
5. Click **"Create repository"**
6. Clone your new repository locally

---

### Step 2: Create a GitHub App

Your organization needs a GitHub App for authentication and permissions.

**Create the App:**

1. Go to: **Organization Settings** → **Developer settings** → **GitHub Apps** → [**New GitHub App**](../../settings/apps/new)

2. **Basic Information:**
   - **GitHub App name:** Choose a name (e.g., `repo-migrate`, `migration-bot`)
     - ⚠️ **SAVE THIS NAME** - you'll need it later
   - **Homepage URL:** Your organization URL
   - **Webhook:** Uncheck "Active" (not needed)

3. **Repository Permissions** (Required):
   ```
   Contents:        Read and write
   Administration:  Read and write
   Metadata:        Read-only (automatic)
   ```

4. **Organization Permissions** (Required):
   ```
   Members:         Read and write
   Administration:  Read and write
   ```

5. Click **"Create GitHub App"**

**After Creation:**

1. **Note your App ID** (shown at top of General tab)
2. **Generate Private Key:**
   - Scroll to "Private keys" section
   - Click **"Generate a private key"**
   - Save the downloaded `.pem` file securely
3. **Install the App:**
   - Click **"Install App"** in left sidebar
   - Click **"Install"** next to your organization
   - Select **"All repositories"** (recommended)

---

### Step 3: Get Your App User ID

You need the full numeric user ID for git commit attribution.

**Using GitHub CLI:**
```bash
gh api /users/YOUR-APP-NAME[bot] --jq '.id'
```
Example: `gh api /users/repo-migrate[bot] --jq '.id'` returns `123456789`

**Using PowerShell:**
```powershell
$appName = "YOUR-APP-NAME"  # Use the name you saved in Step 2
$response = Invoke-RestMethod "https://api.github.com/users/$appName[bot]"
$response.id  # This is your App User ID
```

**Save both:**
- App Name: `YOUR-APP-NAME`
- App User ID: `123456789` (example)

---

### Step 4: Update Configuration with GitHub Copilot

Open your repository in VS Code and use **GitHub Copilot Coding Agent** to configure everything in one step.

**Ask Copilot:**
```
Use the update-app-name skill to update all references with:

App Name: YOUR-APP-NAME
App ID: YOUR-APP-USER-ID

Use the update-default-org skill to update all references with:

Organization: YOUR-ORG-NAME

Finalize the README to be production ready using your skills
```

Replace `YOUR-APP-NAME`, `YOUR-APP-USER-ID`, and `YOUR-ORG-NAME` with your actual values. Copilot will update all workflow files, scripts, and documentation automatically in a single pull request.

---

### Step 5: Configure Secrets

Go to: **Repository Settings** → **Secrets and variables** → **Actions**

#### Required (All Migrations):

**Secrets:**
| Name | Value | Where to get it |
|------|-------|-----------------|
| `GH_APP_PRIVATE_KEY` | Full contents of `.pem` file | From Step 2 |

**Variables:**
| Name | Value | Where to get it |
|------|-------|-----------------|
| `GH_APP_ID` | App ID number | From Step 2 |

#### Optional (Configure for sources you'll use):

<details>
<summary><b>Azure DevOps</b></summary>

**Secrets:**
- `ADO_PAT` - [Create Personal Access Token](https://learn.microsoft.com/azure-devops/organizations/accounts/use-personal-access-tokens-to-authenticate) with **Code (Read)** scope

</details>

<details>
<summary><b>BitBucket</b></summary>

**Secrets:**
- `BB_USERNAME` - Your BitBucket username
- `BB_PAT` - [Create App Password](https://support.atlassian.com/bitbucket-cloud/docs/app-passwords/) with **Repository Read**

**Variables:**
- `BITBUCKET_BASE_URL` - Your BitBucket domain (e.g., `bitbucket.company.com`)

</details>

<details>
<summary><b>Subversion (SVN)</b></summary>

**Secrets:**
- `SUBVERSION_SERVICE_PASSWORD` - Your SVN password

**Variables:**
- `SUBVERSION_SERVICE_USERNAME` - Your SVN username
- `SVN_BASE_URL` - Your SVN domain (e.g., `svn.company.com`)

</details>

<details>
<summary><b>External GitHub</b></summary>

**Secrets:**
- `GH_PAT` - [Create Personal Access Token](https://github.com/settings/tokens) with **repo** scope

</details>

---

## ✅ You're Done! Start Migrating

### Create a Migration Request:

1. Go to **[Issues](../../issues)** → **[New Issue](../../issues/new/choose)**
2. Select **"🏃‍♂️ Repository Creation/Migration"**
3. Fill in:
   - **Organization:** Your org name
   - **Team Name:** Your team (e.g., `platform-team`)
   - **Repository Name:** New repo name (e.g., `user-api`)
   - **Source URL:** (Optional) Repository to migrate from
   - **Criticality:** `critical` (private) or `non-critical` (internal)
4. **Submit** and watch it work!

The workflow creates the repository, migrates code, sets up teams, and configures permissions automatically.

## Architecture Overview

### How It Works

```mermaid
graph TD
    A[Migration Request] --> B[Input Validation]
    B --> C[GitHub App Authentication]
    C --> D[Repository Creation]
    D --> E[Team Setup]
    E --> F[Source Migration]
    F --> G[Security Configuration]
    G --> H[Post-Migration Setup]
    
    F --> F1[Azure DevOps]
    F --> F2[BitBucket]
    F --> F3[Subversion]
    F --> F4[GitHub]
    
    H --> H1[Branch Protection]
    H --> H2[Mandatory Files]
    H --> H3[ADO Integration]
```

### Core Components

1. **GitHub Actions Workflows** - Orchestration and automation engine
2. **PowerShell Scripts** - Migration logic and API interactions  
3. **GitHub App** - Secure authentication and enhanced permissions
4. **Team Management** - Hierarchical permission structures
5. **Source Integrations** - Support for multiple source control systems

### Supported Migration Sources

| Source | Description | Authentication | Features |
|--------|-------------|----------------|----------|
| **Azure DevOps** | Git repos, TFVC with folders | Personal Access Token | Pipeline rewiring, board integration |
| **BitBucket** | Git repositories | Username/App Password | Full history preservation |
| **Subversion** | SVN repositories | Username/Password | History conversion to Git |
| **GitHub** | Internal/external repos | GitHub Token/App | Repository cloning and setup |

## Prerequisites

Before setting up the migration framework, ensure you have:

### Required Tools
- **PowerShell 7.0+** - [Installation guide](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- **GitHub CLI** - [Installation guide](https://cli.github.com/)
- **Git** - [Installation guide](https://git-scm.com/downloads)

### Required Permissions
- **Organization Owner** access in target GitHub organization
- **GitHub App creation** permissions
- **Source system access** (ADO, BitBucket, etc.) with appropriate permissions

### PowerShell Modules
The framework automatically installs required modules:
- `powershell-yaml` - YAML processing
- `jwtPS` - JWT token generation

---

## Additional Configuration

### Custom Properties

Add custom repository properties (like app IDs, cost centers, etc.) using GitHub Copilot Coding Agent:

```
Use the add-custom-properties skill to add app_id property
```

See [Custom Properties Guide](.github/skills/add-custom-properties/SKILL.md)

### Add New Source Systems

Support additional source control systems using GitHub Copilot Coding Agent:

```
Use the add-import-source skill to add GitLab support
```

See [Add Import Source Guide](.github/skills/add-import-source/SKILL.md)

### All Available Skills:

- **[update-readme-repo](.github/skills/update-readme-repo/SKILL.md)** - Fix workflow status badge
- **[update-app-name](.github/skills/update-app-name/SKILL.md)** - Update GitHub App references
- **[update-default-org](.github/skills/update-default-org/SKILL.md)** - Update organization references  
- **[add-custom-properties](.github/skills/add-custom-properties/SKILL.md)** - Add repository metadata
- **[add-import-source](.github/skills/add-import-source/SKILL.md)** - Support new source systems

---

## Troubleshooting

**Authentication fails:**
- Check `GH_APP_ID` variable is correct
- Verify `GH_APP_PRIVATE_KEY` includes `-----BEGIN RSA PRIVATE KEY-----` headers
- Confirm GitHub App is installed on your organization

**Permission errors:**
- Review app permissions in Organization Settings → Developer settings → GitHub Apps
- Ensure app has Contents (write) and Administration (write)

**Source migration fails:**
- Verify correct secrets are configured for your source (ADO_PAT, BB_PAT, etc.)
- Check source URL format matches examples
- Ensure base URL variables are set (BITBUCKET_BASE_URL, SVN_BASE_URL)

---

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- How to submit bug reports and feature requests
- Development setup and coding standards
- Pull request process and requirements
- PowerShell coding conventions

### Quick Start for Contributors

1. **Fork the repository** and clone your fork
2. **Install prerequisites** (PowerShell 7.0+, GitHub CLI, Git)
3. **Create a feature branch** for your changes
4. **Test your changes** with a test organization
5. **Submit a pull request** following our template

## Security

Security is paramount for migration frameworks. Please see our [Security Policy](SECURITY.md) for:

- Reporting security vulnerabilities
- Supported versions and security updates
- Security best practices for users
- Framework security features

**Report vulnerabilities**: [hector.flores@htek.dev](mailto:hector.flores@htek.dev)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and version history.

---

## Support

- 📖 **Skills Documentation:** [`.github/skills/`](.github/skills/)
- 💬 **GitHub Copilot Coding Agent:** Ask Copilot to help with configuration and customization
- 🐛 **Issues:** [Report issues](../../issues/new)

---

**Questions?** Contact your organization's administrators or open an issue.
