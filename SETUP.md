# Migration Framework Setup and Administration

This document contains setup and administrative information for the migration framework. **End users do not need this documentation** - they should use the issue template to request migrations.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Initial Setup](#initial-setup)
- [Prerequisites](#prerequisites)
- [Additional Configuration](#additional-configuration)
- [Available Skills](#available-skills)
- [Maintenance](#maintenance)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

---

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

---

## Initial Setup

### 🤖 Interactive Setup with GitHub Copilot

**Want guided, interactive setup?** Use the onboarding agent:

```
@workspace /onboarding
```

The onboarding agent will:
- Walk you through each setup step with validation
- Request screenshots to confirm completion
- Help customize for your organization
- Skip configuration for unused source systems
- Add custom properties if needed
- Finalize the repository when you're ready

**Prefer manual setup?** Continue with the steps below.

---

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

1. Go to: **Organization Settings** → **Developer settings** → **GitHub Apps** → [**New GitHub App**](https://github.com/settings/apps/new)

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

### Step 4: Configure Secrets

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
| `GH_APP_NAME` | App name (without [bot] suffix) | From Step 2 |
| `GH_APP_USER_ID` | Full numeric user ID | From Step 3 |

#### Optional (Configure for sources you'll use):

<details>
<summary><b>Azure DevOps</b></summary>

**Secrets:**
- `ADO_PAT` - [Create Personal Access Token](https://learn.microsoft.com/azure-devops/organizations/accounts/use-personal-access-tokens-to-authenticate) with **Code (Read)** scope

**Variables:**
- `ADO_SERVICE_CONNECTION_ID` - The ID of a GitHub service connection created in a central ADO project. This connection will be shared to other projects to enable pipeline rewiring to GitHub. See setup instructions below.

#### Setting up ADO Service Connection

1. **Create a central project** in Azure DevOps (if you don't already have one) for managing shared service connections
2. **Create a GitHub service connection** in this central project:
   - Go to **Project Settings** → **Service connections** → **New service connection**
   - Select **GitHub** as the connection type
   - Configure authentication (OAuth or Personal Access Token)
   - Name it appropriately (e.g., `github-migration-shared`)
3. **Get the Service Connection ID:**
   - Navigate to the service connection you just created
   - The ID is visible in the URL: `https://dev.azure.com/{org}/{project}/_settings/adminservices?resourceId={SERVICE_CONNECTION_ID}`
   - Or use Azure CLI: `az devops service-endpoint list --org https://dev.azure.com/{org} --project {project}`
4. **Add the ID as a repository variable:**
   - Go to your migration framework repository settings
   - Add `ADO_SERVICE_CONNECTION_ID` with the service connection ID as the value

**Note:** This service connection will be automatically shared to other projects during migration to enable pipeline rewiring.

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

### Step 5: Finalize Repository for Production

Now that you've completed the setup, use **GitHub Copilot Coding Agent** to convert this template repository into a production-ready framework:

**Ask Copilot:**
```
Use the template-to-production skill to finalize this repository for production use
```

**What this does:**
- ✅ Refactors README from setup instructions to usage-focused documentation
- ✅ Moves administrative documentation to SETUP.md
- ✅ Replaces all organization placeholders with your organization name
- ✅ Updates workflow badge with your actual repository path
- ✅ Archives original template documentation
- ✅ Validates all placeholders are removed

**What you've already configured:**
- ✅ GitHub App with proper permissions
- ✅ App ID, name, and user ID as repository variables
- ✅ App private key as secret
- ✅ Source system credentials (if applicable)

After Copilot completes the conversion, your repository will be ready for your organization to use!

---

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

### GitHub Copilot Agents & Skills

#### Custom Agents

- **[template-onboarding](.github/agents/onboarding-agent.md)** - Interactive onboarding guide for template setup

#### Skills

- **[add-custom-properties](.github/skills/add-custom-properties/SKILL.md)** - Add repository metadata
- **[add-import-source](.github/skills/add-import-source/SKILL.md)** - Support new source systems
- **[template-to-production](.github/skills/template-to-production/SKILL.md)** - Convert template to production

---

## Maintenance

### Regular Tasks

**Monthly:**
- Review migration success rates
- Check for failed migrations
- Update documentation based on common questions
- Review and update dependencies

**Quarterly:**
- Rotate GitHub App credentials
- Review and update source system credentials
- Audit team permissions
- Review security best practices

**As Needed:**
- Add support for new source systems
- Update workflows based on GitHub Actions changes
- Respond to feature requests
- Troubleshoot issues

### Monitoring

Set up monitoring for:
- Migration success rate
- Workflow execution time
- Common error patterns
- Usage statistics (migrations per week)

---

## Security

Security is paramount for migration frameworks. Please see our [Security Policy](SECURITY.md) for:

- Reporting security vulnerabilities
- Supported versions and security updates
- Security best practices for users
- Framework security features

**Report vulnerabilities**: [hector.flores@htek.dev](mailto:hector.flores@htek.dev)

### Best Practices

1. **Rotate Credentials Regularly**
   - GitHub App private keys: Every 6-12 months
   - Source system PATs: Based on expiration policies
   - Service account passwords: According to org policy

2. **Audit Permissions**
   - Review GitHub App permissions quarterly
   - Audit team memberships monthly
   - Check repository access regularly

3. **Monitor Activity**
   - Review workflow runs for anomalies
   - Track failed authentications
   - Monitor unusual migration patterns

4. **Secure Secrets**
   - Never commit secrets to repositories
   - Use GitHub secrets exclusively
   - Rotate compromised secrets immediately

---

## Troubleshooting

### Authentication Issues

**Problem:** Authentication fails
- Check `GH_APP_ID` variable is correct
- Verify `GH_APP_PRIVATE_KEY` includes `-----BEGIN RSA PRIVATE KEY-----` headers
- Confirm GitHub App is installed on your organization

**Problem:** Permission errors
- Review app permissions in Organization Settings → Developer settings → GitHub Apps
- Ensure app has Contents (write) and Administration (write)

### Source Migration Issues

**Problem:** Source migration fails
- Verify correct secrets are configured for your source (ADO_PAT, BB_PAT, etc.)
- Check source URL format matches examples
- Ensure base URL variables are set (BITBUCKET_BASE_URL, SVN_BASE_URL)

**Problem:** Azure DevOps migration fails
- Verify ADO_PAT has Code (Read) scope
- Check ADO organization URL is correct
- Ensure PAT hasn't expired

**Problem:** BitBucket migration fails
- Verify BB_PAT is an app password, not user password
- Check BITBUCKET_BASE_URL doesn't include protocol (https://)
- Ensure app password has Repository Read permission

### Workflow Issues

**Problem:** Workflow doesn't trigger
- Check issue has correct label (`migration-request`)
- Verify workflow file syntax is valid
- Ensure repository has Actions enabled

**Problem:** Team creation fails
- Verify GitHub App has Organization Members (write) permission
- Check team naming follows conventions
- Ensure parent teams exist

### Common Error Messages

**"Failed to create repository"**
- Repository name already exists
- Check naming convention compliance
- Verify GitHub App has Repository Administration (write)

**"Failed to migrate source"**
- Invalid source URL format
- Missing or incorrect credentials
- Source repository doesn't exist or isn't accessible

**"Team validation failed"**
- Team member doesn't exist in organization
- User has pending invitation
- Check team membership requirements

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

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and version history.

---

## Support

- 🤖 **Interactive Setup:** Use `@workspace /onboarding` with GitHub Copilot for guided setup
- 📖 **Skills Documentation:** [`.github/skills/`](.github/skills/)
- 📋 **Custom Agents:** [`.github/agents/`](.github/agents/)
- 💬 **GitHub Copilot Coding Agent:** Ask Copilot to help with configuration and customization
- 🐛 **Issues:** [Report issues](../../issues/new)

---

**Questions?** Contact your organization's administrators or open an issue.
