# Repository Migration Framework

[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml)

> **Template Repository**: Use this as a template to create your own repository migration framework in your GitHub organization.

## Overview

This repository is an automated framework for migrating application repositories into GitHub. It provides GitHub Actions workflows that automate the entire migration process from various source control systems including:
- ✅ Azure DevOps (ADO) - Git and TFVC
- ✅ BitBucket
- ✅ Subversion (SVN)
- ✅ GitHub (internal and external)

The framework handles repository creation, team setup, code migration, permissions, and optional integrations—eliminating manual work and reducing complexity.

## Getting Started (New Users)

If you're using this repository as a template for your organization, follow these steps to set it up:

### Prerequisites

- GitHub Organization admin access
- Ability to create GitHub Apps in your organization
- Access to source control systems you want to migrate from (ADO, BitBucket, SVN)

### Step 1: Use This Template

1. Click "Use this template" → "Create a new repository"
2. Select your organization
3. Name your repository (e.g., `repo-migration-framework`)
4. Set visibility to Private or Internal
5. Click "Create repository"
6. Clone your new repository locally
Advanced Configuration

### GitHub Copilot Skills

This repository includes specialized **Copilot skills** to help you customize and maintain the migration framework:

#### Setup Skills (One-Time Configuration)

- **@workspace update-app-name**: Updates all GitHub App name and ID references
- **@workspace update-default-org**: Updates all organization references
- **@workspace update-import-source**: Add support for new source control systems

#### Customization Skills

- **@workspace add-custom-properties**: Add custom repository properties for governance
  ```
  @workspace Use add-custom-properties skill to add app_id property for ServiceNow CMDB tracking
  ```

**Available Skills:** See [`.github/skills/`](.github/skills/) directory for all skills and detailed guides
   - **Administration**: Read and write

5. Click "Create GitHub App"

**After Creation:**

1. Note your **App ID** (shown in the General tab)
2. Generate a **Private Key**:
   - Scroll down to "Private keys" section
   - Click "Generate a private key"
   - Download and save the `.pem` file securely
3. Install the app:
   - Go to "Install App" in the left sidebar
   - Click "Install" next to your organization
   - Select "All repositories" or specific repositories

### Step 3: Get App User ID

You need the full numeric user ID of your GitHub App for commit attribution.

**Option A: Using GitHub CLI**

```bash
gh api /users/{YOUR_APP_NAME}[bot] --jq '.id'
# Example: gh api /users/repo-migrate[bot] --jq '.id'
# Returns: 123456789
```

**Option B: Using PowerShell**

```powershell
$appName = "repo-migrate"  # Your app name
$response = Invoke-RestMethod -Uri "https://api.github.com/users/$appName[bot]"
Write-Host "App User ID: $($response.id)"
```

**Save this ID** - you'll need it in the next step.

### Step 4: Update App Configuration with Copilot

Use GitHub Copilot to update all app references in the repository:

**Open GitHub Copilot Chat** and run:

```
@workspace Use the update-app-name skill to update all references with:
- App Name: YOUR_APP_NAME (e.g., repo-migrate)
- App ID: YOUR_APP_USER_ID (e.g., 123456789)
```

This will update all references in:
- Workflow files
- PowerShell scripts  
- Documentation
- Configuration files

### Step 5: Update Organization References

Update all organization references to match your organization:

**Open GitHub Copilot Chat** and run:

```
@workspace Use the update-default-org skill to update all references with:
- Organization: YOUR_ORGANIZATION_NAME
```

This will update:
- Default organization values
- Documentation examples
- Issue template options
- Script defaults

### Step 6: Configure Secrets

The framework needs credentials to access source control systems.

**Navigate to your repository**: Settings → Secrets and variables → Actions

#### Required for All Migrations

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `GH_APP_PRIVATE_KEY` | GitHub App private key | Contents of the `.pem` file from Step 2 |

**Variable (not secret):**

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `GH_APP_ID` | Your App ID | Numeric App ID from Step 2 |

#### Optional: Azure DevOps Migrations

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `ADO_PAT` | Azure DevOps Personal Access Token | [Create PAT](https://learn.microsoft.com/azure-devops/organizations/accounts/use-personal-access-tokens-to-authenticate) with Code (Read) scope |

#### Optional: BitBucket Migrations

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `BB_USERNAME` | BitBucket service account username | Your BitBucket username |
| `BB_PAT` | BitBucket App Password or PAT | [Create App Password](https://support.atlassian.com/bitbucket-cloud/docs/app-passwords/) with Repository Read |

**Variable (not secret):**

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `BITBUCKET_BASE_URL` | Your BitBucket domain | Example: `bitbucket.yourcompany.com` |

#### Optional: Subversion (SVN) Migrations

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `SUBVERSION_SERVICE_PASSWORD` | SVN service account password | Your SVN credentials |

**Variable (not secret):**

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `SUBVERSION_SERVICE_USERNAME` | SVN service account username | Your SVN username |
| `SVN_BASE_URL` | Your SVN server domain | Example: `svn.yourcompany.com` |

#### Optional: External GitHub Migrations

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `GH_PAT` | GitHub Personal Access Token | [Create PAT](https://github.com/settings/tokens) with repo scope |

### Step 7: Test Your Setup

1. Go to the **Issues** tab in your repository
2. Click "New Issue"
3. Select "🏃‍♂️ Repository Creation/Migration"
4. Fill in the form with test values
5. Submit and watch the workflow run
6. Verify a repository is created successfully

**If issues occur**, check:
- GitHub App is installed on your organization
- All required secrets are configured correctly
- App has correct permissions
- Organization name matches exactly

## Using the Framework (Daily Usage)

Once setup is complete, repository migrations are simple:

### Quick Start: Issue-Based Migration

The easiest way to request a repository migration is through the **Issue Template**:

1. Go to the "Issues" tab
2. Click "New Issue"
3. Select "🏃‍♂️ Repository Creation/Migration"
4. Fill in the required fields:
   - **GitHub Organization**: Target organization
   - **Team Name**: Your team identifier (e.g., `platform-engineering`)
   - **Repository Name**: New repository name (e.g., `user-api`)
5. Optionally provide:
   - **Source Repository URL**: For migrations from ADO, BitBucket, SVN, or GitHub
   - **Specific Folder**: For partial migrations
   - **Criticality**: Security level (critical = private, non-critical = internal)
6. Submit and track progress

The framework handles the rest: repository creation, team setup, code migration, and permissions.

## How It Works

The migration workflow automates the entire process:

1. **Input Validation**
   - Validates team name and repository name format
   - Checks user authorization and team membership
   - Parses source repository URL

2. **Repository Creation**
   - Creates new GitHub repository with standardized naming
   - Sets visibility based on criticality (private/internal)

3. **Code Migration** (if source provided)
   - Clones from source control system (ADO, BitBucket, SVN, GitHub)
   Workflow Reference

### Core Inputs

| Input | Required | Description | Examples |
| --- | --- | --- | --- |
| `org` | Yes | Target GitHub Organization | `your-org-name` |
| `team-name` | Yes | Team identifier | `platform-engineering`, `data-team` |
| `repo-name` | Yes | Repository name | `user-api`, `payment-service` |
| `criticality` | Yes | Security level | `critical` (private), `non-critical` (internal) |
| `clone-url` | No | Source repository URL | See supported formats below |
| `only-folder` | No | Specific folder to migrate | `backend`, `src/api` |

### Supported Source Systems

The framework supports migration from multiple source control systems:

**Azure DevOps:**
- Git repositories: `https://dev.azure.com/{org}/{project}/_git/{repo}`
- TFVC repositories: `https://dev.azure.com/{org}/{project}/_versionControl`

**BitBucket:**
- `https://{bitbucket-domain}/scm/{project}/{slug}.git`

**Subversion (SVN):**
- `https://{svn-domain}/{repo}`
- Automatically converts `trunk/branches/tags` to Git branches

**GitHub:**
- Internal (same org): `https://github.com/{your-org}/{repo}`
- External: `https://github.com/{other-org}/{repo}`

### Team Structure

The framework creates a simple two-level team hierarchy:

**Default Structure:**
- `{team-name}` - Maintain permissions on repository
- `{team-name}-admins` - Admin permissions (nested under main team)

**Permissions:**
- **Non-critical repositories**: Internal visibility, standard team access
- **Critical repositories**: Private visibility, restricted access

### Team Membership Validation

The workflow validates authorization before creating repositories:

1. **Team doesn't exist**: Migration proceeds, team created with you as maintainer
2. **Team exists**: Validates you're an active member before proceeding
3. **Validation fails**: Clear error message, no resources created

This ensures proper access control and prevents unauthorized repository creation.
1. Navigate to **Issues** → **New Issue**
2. Select **"🏃‍♂️ Repository Creation/Migration"** template
3. Fill in the required fields:
   - **GitHub Organization**: Target organization
   - **Team Name**: Your team identifier (e.g., `platform-engineering`)
   - **Repository Name**: New repository name (e.g., `user-api`)
4. Optional fields:
   - **Criticality**: Security level (default: non-critical)
   - **Source Repository URL**: For migrations
   - **Only Include Specific Folder**: For partial migrations
5. Submit the issue

The workflow automatically starts and provides status updates as comments. When complete, you'll receive a link to your new repository and the issue closes automatically.

**Benefits:**
- ✅ User-friendly interface
- 📝 Searchable migration history
- 🔔 Automatic notifications
- 📊 Tracking and auditing

## Manual Workflow Trigger (Advanced)

For advanced users or automation, you can manually trigger the workflow from the **Actions** tab with full control over all parameters including parent teams and custom admin team names.

## Workflow Inputs Reference
Complete list of workflow inputs for manual triggers or automation:

| Input | Required | Description | Examples |
| --- | --- | --- | --- |
| `org` | Yes | GitHub Organization | `{{DEFAULT ORG}}` |
| `team-name` | Yes | Team identifier | `platform-engineering` |
| `repo-name` | Yes | Repository name | `user-api` |
| `criticality` | Yes | Security level | `critical`, `non-critical` |
| `parent-team-name` | No | Parent team for hierarchy | `platform` |
| `admin-team-name` | No | Override admin team name | `custom-admins` |
| `only-folder` | No | Specific folder to migrate | `src`, `backend` |
| `clone-url` | No | Source repository URL | See formats below |

The `clone-url` input is used to specify the location of the repository to be migrated. This URL can be from Azure DevOps (ADO), Azure DevOps Wiki, BitBucket, SVN, or another GitHub repo. 

Here are the expected formats for each:

- **Azure DevOps (ADO)**: `https://dev.azure.com/{organization}/{project}/_git/{repo}`
- **Azure DevOps Wiki**: `https://dev.azure.com/{organization}/{project}/_git/{project}.wiki`
Supported source repository formats:

- **Azure DevOps**: `https://dev.azure.com/{organization}/{project}/_git/{repo}`
- **Azure DevOps Wiki**: `https://dev.azure.com/{organization}/{project}/_git/{project}.wiki`
- **BitBucket**: `https://bitbucket.example.com/scm/{project}/{slug}.git`
- **GitHub**: `https://github.com/{organization}/{repo}`
- **SVN**: `https://svn.example.com/svn/{repo}`

> [!NOTE]
> SVN repositories with standard `trunk/branches/tags` structure are automatically converted to proper Git branches.

## Team Structure

The migration creates a simplified team structure:

**Default Structure:**
- `{team-name}` - Maintain permissions
- `{team-name}-admins` - Admin permissions (created as child of `{team-name}`)

**With Parent Team:**
- `{parent-team-name}` - Parent team (if specified)
  - `{team-name}` - Your team (nested under parent)
    - `{team-name}-admins` - Admin team

**Permissions:**
- Non-critical repos: Internal visibility, standard team permissions
- Critical repos: Private visibility, restricted permissions

## Customization with Copilot Agents the existing GitHub repository according to the naming convention derived from the provided inputs.

- **Team Creation**: The workflow will create and configure the appropriate GitHub teams for the repository, just like it does during a migration. The teams created will be based on the provided inputs such as `deliverable-provider` and `deliverable-owner`.

- **Permission Setup**: It will set up the correct permissions for these teams according to the repository's criticality level.
The migration framework includes specialized GitHub Copilot agents for customization:

### @cusrun this workflow on an existing GitHub repository to standardize its setup:

**What Happens:**
- Repository is renamed to match your specified `repo-name`
- Teams are created and configured with proper permissions
- Access controls are set based on criticality

**Use Case:** Standardizing repositories that were created outside the migration framework.

### Migrating Azure DevOps Wiki
4. ✅ Add validation rules
5. 🧪 Suggest testing steps

**Common Properties:**
To migrate an Azure DevOps Wiki:

1. Navigate to your ADO project → Wiki
2. Click the three dots (⋮) beside your wiki name
3. Select "Clone wiki"
4. Copy the clone URL
5. Use this URL in the `clone-url` field

![Wiki Clone](wiki.png)

The workflow will migrate the wiki as a GitHub repository with full history.

### Partial Repository Migration

Migrate only a specific folder from a large repository:

1. Set `clone-url` to the source repository
2. Set `only-folder` to the folder path (e.g., `backend/api`)
3. The workflow extracts only that folder with its git history

**Use Case:** Splitting monorepos into separate repositories.    with:
      values: |
        app_id=APM0004686
        category=app
        bu=gtm
        team=cloudops
        name=my-app
        owner=John Doe
        criticality=non-critical
```



## Workflow Summary

Upon completion of the migration, the workflow generates a summary page. This page contains information about the steps executed during the migration and their outcomes. It can help you quickly understand what happened during the migration and identify any issues that might have occurred.

Here's a brief overview of what you can expect to see in the summary:

- **Steps and Status**: For each step in the migration process, the summary will indicate whether the step was successful (✅) or failed (❌). This allows you to quickly see which parts of the migration completed successfully and where any errors might have occurred.

- **Notes**: Alongside the status, the summary provides notes that give additional context about what was done in each step and any significant outcomes.

For example, if the workflow created a new GitHub repo, the summary would include a line item like:

```markdown
| **Create GitHub Repo** | ✅ | Repository `my-repo` created in organization `my-org` |
```

If a step failed, the summary would provide details about the error, for example:

```markdown
| **Import Repo** | ❌ | Unknown import source: `my-source` |
```

The summary is designed to provide a comprehensive overview of the migration, making it easier to track the progress and troubleshoot any issues.Ex

Every migration generates a detailed summary with:

- *Troubleshooting

### Common Setup Issues

**"Bad credentials" or 401 Errors**
- Verify `GH_APP_ID` variable is set correctly
- Check `GH_APP_PRIVATE_KEY` secret contains the complete private key
- Ensure private key format includes `-----BEGIN RSA PRIVATE KEY-----` header
- Confirm GitHub App is installed in your organization

**"Resource not accessible by integration"**
- Review GitHub App permissions (Contents: write, Administration: write)
- Reinstall the app after changing permissions
- Verify app is installed on target repositories

**Team Membership Validation Fails**
- Ensure you're a member of existing teams
- For new teams, workflow creates them automatically
- Check team name format matches your organization's conventions

**Migration Fails with Unknown Import Source**
- Verify source URL format matches expected patterns
- Check required secrets are configured (ADO_PAT, BB_PAT, etc.)
- Ensure base URLs are set for BitBucket/SVN if using custom domains

### Workflow Summary

Every migration generates a detailed summary with:

- **Step Status**: ✅ Success or ❌ Failure for each operation
- **Details**: What was executed and outcomes
- **Errors**: Specific error messages for troubleshooting
- **Links**: Direct links to created repositories and teams

**Example Summaryreation and permission setup
5. Optional custom properties (if enabled)
6. ADO integration (for ADO sources)
7. Summary generation### Key Components

```
.
├── .github/
│   ├── workflows/
│   │   └── migrate.yml              # Main orchestration workflow
│   ├── ISSUE_TEMPLATE/
│   │   └── migration-request.yml    # User-friendly issue form
│   └── skills/                      # Copilot skills for customization
│       ├── update-app-name/
│       ├── update-default-org/
│       ├── add-import-source/
│       └── add-custom-properties/
├── scripts/                         # PowerShell automation scripts
│   ├── modules.ps1                  # Common utilities
│   ├── New-GitHubRepo.ps1          # Repository creation
│   ├── New-GitHubRepoMigration.ps1 # Migration logic
│   ├── Parse-Parameters.ps1         # Input validation
│   └── ...
└── README.md
```

### Workflow Execution Flow

```
Issue Submitted / Workflow Triggered
          ↓
   Input Validation
   (team, repo name, format)
          ↓
   Team Authorization Check
          ↓
   Repository Creation
          ↓
   Source Code Migration ←─────┐
   (if source URL provided)    │
          ↓                     │
   Team Setup                  │ Supports:
   (create hierarchy)          │ • Azure DevOps
          ↓                     │ • BitBucket
   Permission Assignment       │ • Subversion
          ↓                     │ • GitHub
   Post-Migration Tasks ───────┘
   (ADO rewiring, etc.)
          ↓
   Generate Summary Report
```

### Security & Best Practices

- **Least Privilege**: GitHub App only gets required permissions
- **Audit Trail**: All operations logged in workflow summaries and issues
- **Validation**: Multi-layer validation prevents misconfigurations
- **Secrets Management**: Credentials stored in GitHub Secrets
- **Team-Based Access**: Automatic authorization via team membership

## Contributing

This is a template repository. To contribute improvements:

1. Fork the original template repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request with detailed description

**Areas for contribution:**
- Additional source control system support
- Enhanced validation rules
- Documentation improvements
- Bug fixes and optimizations

## Support & Resources

- **Skills Documentation**: [`.github/skills/`](.github/skills/)
- **GitHub Apps**: [GitHub Apps Documentation](https://docs.github.com/en/apps)
- **GitHub Actions**: [Actions Documentation](https://docs.github.com/en/actions)
- **Copilot Chat**: Use `@workspace` to invoke skills and get help

## License

[Specify your license here]

---

**Questions?** Open an issue or contact your organization's repository administrators.