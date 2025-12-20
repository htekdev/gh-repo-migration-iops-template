---
name: template-to-production
description: Convert the migration framework from a template repository to a production-ready operational repository. Use this skill after completing initial setup to finalize documentation, replace placeholder organization references, and transition from setup mode to daily usage mode.
---

# Template to Production Conversion

## Overview

This skill guides you through converting the migration framework from a template repository with setup instructions to a production-ready operational repository focused on daily usage. After completing initial setup (GitHub App creation, secrets configuration, organization updates), this skill helps you:

- Refactor README from setup-focused to usage-focused
- Move detailed setup instructions to SETUP.md for administrators
- Replace all placeholder organization references with actual values
- Confirm all setup steps are complete
- Archive original template documentation

## When to Use This Skill

Use this skill when:
- You've completed all initial setup steps (GitHub App, secrets, org configuration)
- You've run at least one successful test migration
- You're ready to transition from "setting up" to "using" the framework
- You want to simplify documentation for end users
- You need to finalize organization-specific customizations

## Prerequisites Checklist

Before using this skill, confirm these setup steps are complete:

- [ ] GitHub App created with correct permissions
- [ ] App name, ID, and user ID configured as repository variables
- [ ] GitHub App private key added as secret
- [ ] Organization placeholders replaced with actual values
- [ ] Source system secrets configured (ADO_PAT, BB_PAT, etc.) if needed
- [ ] Workflow badge updated with actual repository name
- [ ] At least one test migration completed successfully
- [ ] Teams created and permissions verified

**If any items are incomplete**, finish setup before proceeding with this conversion.

## Conversion Steps

### Step 1: Get Repository Information

First, identify your repository's organization and name:

```powershell
# Run the script to get repository info
./.github/skills/template-to-production/scripts/Get-RepositoryInfo.ps1
```

Save these values for reference:
- **Organization**: `______________________`
- **Repository**: `______________________`
- **Full name**: `______________________`

### Step 2: Create SETUP.md for Administrators

Move all setup documentation from README.md to a new SETUP.md file for administrators.

**Create `SETUP.md` with this structure:**

```markdown
# Migration Framework Setup and Administration

This document contains setup and administrative information for the migration framework. **End users do not need this documentation** - they should use the issue template to request migrations.

---

## Architecture Overview

[Move the "Architecture Overview" section from README here]

## Initial Setup

[Move all "Setup Instructions" (Steps 1-5) from README here]

### Step 1: Create Your Repository from This Template
[Content from README]

### Step 2: Create a GitHub App
[Content from README]

### Step 3: Get Your App User ID
[Content from README]

### Step 4: Update Configuration with GitHub Copilot
[Content from README]

### Step 5: Configure Secrets
[Content from README]

## Prerequisites

[Move "Prerequisites" section from README here]

## Additional Configuration

[Move "Additional Configuration" section from README here]

## Available Skills

- **[add-custom-properties](.github/skills/add-custom-properties/SKILL.md)** - Add repository metadata
- **[add-import-source](.github/skills/add-import-source/SKILL.md)** - Support new source systems
- **[template-to-production](.github/skills/template-to-production/SKILL.md)** - Convert template to production

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

## Security

[Move security content from README here]

## Troubleshooting

[Move "Troubleshooting" section from README here]
```

### Step 3: Create Production-Focused README

Replace the setup-heavy README with usage-focused content.

**Update `README.md` to this structure:**

```markdown
# Repository Migration Framework

[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/{YOUR-ORG}/{YOUR-REPO}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/{YOUR-ORG}/{YOUR-REPO}/actions/workflows/migrate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![GitHub CLI](https://img.shields.io/badge/GitHub%20CLI-Required-green.svg)](https://cli.github.com/)

Automated repository migration framework for {YOUR-ORG}. Migrate repositories from Azure DevOps, BitBucket, SVN, or GitHub with complete automation.

---

## Quick Start

### Request a Repository Migration

1. Go to **[Issues](../../issues)** → **[New Issue](../../issues/new/choose)**
2. Select **"🏃‍♂️ Repository Creation/Migration"**
3. Fill in the form:
   - **Organization:** Select from dropdown
   - **Team Name:** Your team identifier (e.g., `platform-team`)
   - **Repository Name:** New repository name
   - **Source URL:** (Optional) Repository to migrate from
   - **Criticality:** `critical` (private) or `non-critical` (internal)
4. Submit and track progress

The migration runs automatically and completes in minutes.

---

## Supported Source Systems

| Source | URL Format | Authentication |
|--------|------------|----------------|
| **Azure DevOps** | `https://dev.azure.com/{org}/{project}/_git/{repo}` | PAT configured |
| **BitBucket** | `https://bitbucket.company.com/scm/{project}/{repo}.git` | Username/PAT configured |
| **Subversion** | `https://svn.company.com/{repo}` | Credentials configured |
| **GitHub (External)** | `https://github.com/{org}/{repo}` | PAT configured |
| **GitHub (Internal)** | `https://github.com/{YOUR-ORG}/{repo}` | No extra auth needed |

---

## What Gets Created

Every migration automatically:

✅ Creates new GitHub repository with standardized naming  
✅ Migrates complete git history (when source provided)  
✅ Creates team hierarchy with proper permissions  
✅ Configures repository visibility based on criticality  
✅ Sets up branch protection rules  
✅ Integrates with Azure DevOps boards (for ADO sources)

---

## Migration Options

### Full Repository Migration
Migrate an entire repository with complete history:
- Leave "Only Include Specific Folder" blank
- All branches and tags are migrated

### Partial Migration (Folder Only)
Extract a single folder from a larger repository:
- Set "Only Include Specific Folder" to folder path (e.g., `backend/api`)
- Only that folder's history is preserved
- Useful for monorepo splitting

### New Repository Only
Create an empty repository without migration:
- Leave "Source Repository URL" blank
- Repository created with README.md only

---

## Team Structure

Each repository gets a two-tier team structure:

```
{team-name}                    → Maintain permissions
└── {team-name}-admins        → Admin permissions
```

**Permissions by Criticality:**
- **Critical repos:** Private, restricted team access
- **Non-critical repos:** Internal, standard team access

---

## Troubleshooting

### Migration Fails

**Check workflow run:**
1. Go to [Actions](../../actions/workflows/migrate.yml)
2. Click the failed run
3. Review job summary for specific error

**Common issues:**
- Source URL format incorrect
- Authentication not configured for source system
- Team name doesn't follow naming conventions
- Repository name already exists

### Need Help?

- 📖 **View workflow runs:** [Actions page](../../actions)
- 🐛 **Report issues:** [Create issue](../../issues/new)
- 💬 **Contact:** {YOUR-ORG} platform team
- 📚 **Setup documentation:** [SETUP.md](SETUP.md) (for admins)

---

## Administration

Repository administrators can find setup and configuration documentation in [SETUP.md](SETUP.md).

**Admin tasks:**
- Adding new source systems
- Updating secrets and credentials  
- Modifying team naming conventions
- Customizing repository properties
- Troubleshooting authentication

---

## Support

**For migration requests:** Use the issue template  
**For technical issues:** Contact platform team  
**For setup changes:** See [SETUP.md](SETUP.md)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Security

See [SECURITY.md](SECURITY.md) for security policies and reporting vulnerabilities.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
```

### Step 4: Replace Organization Placeholders

Use the provided script to replace all placeholders with your actual organization:

```powershell
# Navigate to repository root
cd c:\Users\floreshector\enbridge-enb-migrate

# Run the update script (auto-detects org from git remote)
./.github/skills/template-to-production/scripts/Update-OrganizationPlaceholders.ps1

# Or specify explicitly:
# ./.github/skills/template-to-production/scripts/Update-OrganizationPlaceholders.ps1 -Organization myorg -Repository myrepo
```

This script will:
- Find ALL files recursively (*.md, *.yml, *.yaml, *.ps1)
- Replace `htekdev` with your organization
- Replace `${{ github.repository }}` with your org/repo
- Replace `{YOUR-ORG}` and `{YOUR-REPO}` placeholders
- Report all changes made

### Step 5: Archive Original Template Documentation

Keep a reference of the original template setup for historical purposes:

```powershell
# Run the backup script
./.github/skills/template-to-production/scripts/Backup-TemplateDocumentation.ps1
```

This creates a timestamped backup in `docs/archive/` and lists all existing archives.

### Step 6: Update Repository Settings

1. **Update Repository Description**:
   - Go to Repository Settings → General
   - Set description: `Automated repository migration framework for {YOUR-ORG}`

2. **Add Repository Topics** (for discoverability):
   ```
   migration
   github-actions
   automation
   repository-management
   devops
   ```

3. **Disable Template Repository** (if enabled):
   - Repository Settings → General
   - Uncheck "Template repository"

4. **Update About Section**:
   - Add link to issue template
   - Add link to documentation

### Step 7: Verify All Changes

Run comprehensive verification:

```powershell
# Check for remaining placeholders
./.github/skills/template-to-production/scripts/Test-PlaceholderRemoval.ps1
```

This script checks for:
- Any remaining `htekdev` references
- Placeholder variables like `${{ github.repository }}`
- Template placeholders like `{YOUR-ORG}`
- Required files (README.md, SETUP.md, docs/archive)

### Step 8: Commit and Push Changes

```powershell
# Stage all changes
git add README.md SETUP.md docs/ .github/

# Commit with descriptive message
git commit -m "docs: Convert from template to production repository

- Refactored README for end-user focus
- Moved setup instructions to SETUP.md for administrators
- Replaced all organization placeholders with actual values
- Archived original template documentation
- Updated repository description and topics

This repository is now production-ready for daily use."

# Push changes
git push origin main
```

### Step 9: Announce to Organization

Prepare an announcement to your organization:

**Example Announcement:**

```markdown
## 🎉 New: Automated Repository Migration Framework

We've launched an automated migration framework for {YOUR-ORG}!

**What it does:**
✅ Migrates repos from ADO, BitBucket, SVN, or GitHub
✅ Creates teams and sets up permissions automatically  
✅ Preserves complete git history
✅ Configures branch protection and integrations

**How to use:**
1. Go to: [Migration Framework Issues](https://github.com/{YOUR-ORG}/{YOUR-REPO}/issues)
2. Click "New Issue" → "Repository Creation/Migration"
3. Fill out the form
4. Submit and watch it work!

**Documentation:** [README](https://github.com/{YOUR-ORG}/{YOUR-REPO})

**Questions?** Contact the platform team.
```

## Production README Best Practices

### Focus on User Actions

**Good (Action-oriented):**
```markdown
## Request a Migration

1. Open a new issue
2. Select the migration template
3. Fill in the form
4. Submit
```

**Avoid (Setup-oriented):**
```markdown
## Setup

Before using this framework, you need to:
1. Create a GitHub App
2. Configure secrets
...
```

### Simplify Technical Details

**Good (Simple):**
```markdown
The framework migrates your code, history, and branches automatically.
```

**Avoid (Too technical):**
```markdown
The framework uses GitHub App authentication with JWT tokens to create scoped tokens that bypass branch protection...
```

### Emphasize Self-Service

**Good:**
```markdown
Request a migration in 2 minutes using our issue template.
```

**Avoid:**
```markdown
Contact the platform team to request a migration.
```

## Post-Conversion Checklist

Confirm all conversion steps are complete:

- [ ] SETUP.md created with all setup documentation
- [ ] README.md updated to focus on usage, not setup
- [ ] All `htekdev` references replaced with actual organization
- [ ] All `{YOUR-ORG}` placeholders replaced
- [ ] All `{YOUR-REPO}` placeholders replaced
- [ ] Workflow badge updated with actual repository path
- [ ] Original template README archived
- [ ] Repository description updated
- [ ] Repository topics added
- [ ] Template repository setting disabled (if applicable)
- [ ] All changes committed and pushed
- [ ] Organization announcement prepared
- [ ] At least one test migration confirmed working
- [ ] Admin team aware of SETUP.md location

## Rollback Plan

If issues arise after conversion, you can rollback:

```powershell
# Restore from archive
$latestArchive = Get-ChildItem "docs/archive/TEMPLATE_README_*.md" | 
                 Sort-Object LastWriteTime -Descending | 
                 Select-Object -First 1

if ($latestArchive) {
    Copy-Item $latestArchive.FullName "README.md" -Force
    Write-Host "✅ Restored README from: $($latestArchive.Name)"
    
    # Commit rollback
    git add README.md
    git commit -m "Revert README to template version for troubleshooting"
    git push
} else {
    Write-Host "❌ No archive found"
}
```

## Maintenance After Production

After conversion, maintain the framework:

### Regular Updates

**Monthly:**
- Review migration success rates
- Update documentation based on user feedback
- Check for GitHub Actions updates

**Quarterly:**
- Rotate credentials
- Review security settings
- Audit team permissions

**As Needed:**
- Add new source systems
- Update workflows
- Respond to feature requests

### Monitoring

Track these metrics:
- Migration success rate
- Workflow execution time
- Common error patterns
- Usage statistics

## Related Skills

After production conversion, you may need:

1. **add-custom-properties**: Add organization-specific repository metadata
2. **add-import-source**: Support additional source control systems

## Validation

Run the comprehensive validation script to ensure production readiness:

```powershell
./.github/skills/template-to-production/scripts/Test-ProductionReadiness.ps1
```

This validates:
- README no longer contains template setup instructions
- SETUP.md exists with admin documentation
- No placeholders remain in main files
- Archive directory created with backups
- Workflow files updated correctly

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Organizations Best Practices](https://docs.github.com/en/organizations)
- [Repository Documentation Best Practices](https://docs.github.com/en/repositories)
- [Template Repositories Guide](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)

## Summary

This skill converts your migration framework from a template focused on setup to a production repository focused on daily usage. The key changes are:

1. **README**: Usage-focused documentation for end users
2. **SETUP.md**: Administrative documentation for setup and maintenance
3. **Placeholders**: All org references replaced with actual values
4. **Archive**: Original template documentation preserved for reference
5. **Repository Settings**: Updated for production use

After completing this conversion, your migration framework is ready for your organization to use!
