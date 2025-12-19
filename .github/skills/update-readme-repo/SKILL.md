---
name: update-readme-repo
description: Guide for updating the repository reference in README.md badge when using the migration framework as a template. Use this skill to fix the status badge that displays migration workflow status.
---

# Update README Repository Reference

## Overview

This skill provides instructions for updating the repository reference in the README.md file when using the migration framework as a template. The README includes a workflow status badge that uses a placeholder for the repository name, which must be updated to display the correct workflow status.

## When to Use This Skill

Use this skill when:
- Setting up the migration framework from the template
- The workflow status badge shows "unknown" or doesn't update
- You want the README to display accurate workflow status
- Completing initial repository setup after using as template

## Why This Is Needed

The README.md file includes a GitHub Actions workflow badge that shows the status of the migration workflow. This badge uses a dynamic reference `${{ github.repository }}` that works in GitHub Actions contexts but needs to be replaced with the actual repository name to display correctly in the README.

**Current Badge:**
```markdown
[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml)
```

The `${{ github.repository }}` placeholder is a GitHub Actions context variable that:
- Works in workflow files (`.github/workflows/*.yml`)
- Does **not** work in Markdown files like README.md
- Needs to be replaced with the actual `{owner}/{repo}` format

## File That Requires Update

### `README.md`

**Location:** Line 3 (in the badge)
- **Current:** 
  ```markdown
  [![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml)
  ```
- **Update to:** Replace both occurrences of `${{ github.repository }}` with your actual repository path
- **Format:** `{organization}/{repository-name}`
- **Example:** `YourOrg/repo-migration`

## Step-by-Step Update Process

### Step 1: Identify Your Repository Information

Determine your repository's full name:

**Option A: From GitHub UI**
1. Navigate to your repository on GitHub
2. The repository name is shown at the top: `{organization}/{repository-name}`
3. Example: `acme-corp/migration-framework`

**Option B: From Git Command**
```bash
# Get the remote URL
git remote get-url origin

# Example output: https://github.com/acme-corp/migration-framework.git
# Repository is: acme-corp/migration-framework
```

**Option C: From PowerShell**
```powershell
# Get repository from git remote
$remote = git remote get-url origin
if($remote -match 'github\.com[:/](?<repo>.+?)(\.git)?$'){
    $repo = $Matches['repo']
    Write-Host "Repository: $repo"
}

# Example output: Repository: acme-corp/migration-framework
```

### Step 2: Update the README Badge

**Manual Update:**

1. Open `README.md` in your editor
2. Find line 3 with the workflow badge
3. Replace `${{ github.repository }}` with your repository path (appears twice)

**Before:**
```markdown
[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/${{ github.repository }}/actions/workflows/migrate.yml)
```

**After (Example):**
```markdown
[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/acme-corp/migration-framework/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/acme-corp/migration-framework/actions/workflows/migrate.yml)
```

### Step 3: Automated Update with PowerShell

Use this script to update automatically:

```powershell
# Get repository from git remote
$remote = git remote get-url origin
if($remote -match 'github\.com[:/](?<repo>.+?)(\.git)?$'){
    $repo = $Matches['repo']
    Write-Host "Detected repository: $repo"
    
    # Read README.md
    $readmePath = "README.md"
    $content = Get-Content $readmePath -Raw
    
    # Replace the placeholder
    $pattern = '\$\{\{ github\.repository \}\}'
    if($content -match $pattern){
        $newContent = $content -replace $pattern, $repo
        Set-Content -Path $readmePath -Value $newContent -NoNewline
        Write-Host "✅ Updated README.md with repository: $repo"
    } else {
        Write-Host "ℹ️ No placeholder found - may already be updated"
    }
} else {
    Write-Host "❌ Could not detect repository from git remote"
}
```

### Step 4: Verify the Badge

After updating, verify the badge displays correctly:

1. **Commit and push your changes:**
   ```bash
   git add README.md
   git commit -m "Update README workflow badge with repository name"
   git push
   ```

2. **View README on GitHub:**
   - Navigate to your repository
   - The badge should now display the workflow status
   - Click the badge to verify it links to the correct workflow

3. **Check Badge URL:**
   - Right-click the badge → "Copy link address"
   - Verify URL contains your organization and repository name
   - Example: `https://github.com/acme-corp/migration-framework/actions/workflows/migrate.yml`

## Understanding the Badge

### Badge Components

The workflow badge has three parts:

1. **Badge Image URL:**
   ```
   https://github.com/{org}/{repo}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch
   ```
   - Shows the workflow status (passing, failing, unknown)
   - `?event=workflow_dispatch` filters to manually triggered runs

2. **Link URL:**
   ```
   https://github.com/{org}/{repo}/actions/workflows/migrate.yml
   ```
   - Links to the workflow runs page
   - Users can click to see workflow history

3. **Badge Text:**
   ```
   🏃‍♂️ Repo Create / Import / Migrate
   ```
   - Alt text shown when hovering
   - Used by screen readers for accessibility

### Badge Status Indicators

The badge will display different statuses:

- **🟢 Passing**: Latest workflow run succeeded
- **🔴 Failing**: Latest workflow run failed
- **🟡 In Progress**: Workflow currently running
- **⚪ Unknown**: No workflow runs yet or URL incorrect

## Advanced Customization

### Custom Badge Filtering

Filter the badge by different criteria:

**Show only successful runs:**
```markdown
![Badge](https://github.com/{org}/{repo}/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch&status=success)
```

**Show specific branch:**
```markdown
![Badge](https://github.com/{org}/{repo}/actions/workflows/migrate.yml/badge.svg?branch=main)
```

**Show all events (not just manual triggers):**
```markdown
![Badge](https://github.com/{org}/{repo}/actions/workflows/migrate.yml/badge.svg)
```

### Multiple Badges

Add badges for different workflows:

```markdown
# Repository Migration Framework

[![Migration](https://github.com/{org}/{repo}/actions/workflows/migrate.yml/badge.svg)](https://github.com/{org}/{repo}/actions/workflows/migrate.yml)
[![Tests](https://github.com/{org}/{repo}/actions/workflows/test.yml/badge.svg)](https://github.com/{org}/{repo}/actions/workflows/test.yml)
[![Release](https://github.com/{org}/{repo}/actions/workflows/release.yml/badge.svg)](https://github.com/{org}/{repo}/actions/workflows/release.yml)
```

### Custom Styling

GitHub supports custom badge styling through shields.io:

**Using shields.io:**
```markdown
[![Migration Status](https://img.shields.io/github/actions/workflow/status/{org}/{repo}/migrate.yml?style=flat-square&label=Migration)](https://github.com/{org}/{repo}/actions/workflows/migrate.yml)
```

**Style options:**
- `flat` - Default flat style
- `flat-square` - Flat with squared corners
- `plastic` - Plastic look with shadows
- `for-the-badge` - Large badges
- `social` - Social media style

## Troubleshooting

### Issue: Badge Shows "unknown" Status

**Causes and Solutions:**

1. **Placeholder not updated:**
   - Verify `${{ github.repository }}` is replaced with actual repository name
   - Check both occurrences in the badge markdown

2. **No workflow runs yet:**
   - Trigger the workflow at least once
   - Go to Actions tab → Run workflow
   - Badge updates after first run completes

3. **Incorrect repository path:**
   - Verify organization/repository spelling
   - Check for typos in the URL
   - Ensure case matches exactly (GitHub URLs are case-insensitive but recommended to match)

4. **Workflow file not found:**
   - Verify `migrate.yml` exists in `.github/workflows/`
   - Check the workflow file name matches exactly

### Issue: Badge Not Displaying

**Causes and Solutions:**

1. **Markdown syntax error:**
   - Verify bracket placement: `[![alt](image-url)](link-url)`
   - Check for spaces in URLs (use URL encoding if needed)

2. **URL formatting:**
   - Ensure no line breaks in the badge markdown
   - Verify URLs don't have extra characters

3. **Private repository:**
   - Badge may not display in private repos without authentication
   - Consider using repository insights instead

### Issue: Badge Links to Wrong Workflow

**Cause:** Repository name in link URL doesn't match badge URL

**Solution:**
- Ensure both URLs in the badge markdown have the same repository path
- Verify workflow filename matches exactly

### Issue: Badge Shows Wrong Status

**Causes and Solutions:**

1. **Caching:**
   - GitHub caches badge status for a few minutes
   - Wait a few minutes and refresh
   - Hard refresh browser (Ctrl+F5 or Cmd+Shift+R)

2. **Event filter:**
   - Badge may filter to specific event types
   - Remove `?event=workflow_dispatch` to show all runs
   - Or change to show your desired event type

3. **Branch filter:**
   - Badge may be showing status from wrong branch
   - Add `?branch=main` to show specific branch status

## Validation Checklist

- [ ] Identified correct repository path ({org}/{repo})
- [ ] Updated first occurrence of `${{ github.repository }}` (badge image URL)
- [ ] Updated second occurrence of `${{ github.repository }}` (link URL)
- [ ] Committed and pushed changes to GitHub
- [ ] Verified badge displays on GitHub README
- [ ] Clicked badge to confirm it links to workflow page
- [ ] Triggered workflow at least once to show status
- [ ] Badge shows correct status (not "unknown")

## Best Practices

1. **Update Early**: Update the badge immediately after creating repository from template
2. **Verify Links**: Always click the badge to verify it links correctly
3. **Test Workflow**: Run the workflow once to ensure badge updates
4. **Document Custom Badges**: If adding custom badges, document in README
5. **Consistent Formatting**: Keep badge markdown on a single line for readability
6. **Use Descriptive Alt Text**: Ensure badge alt text describes its purpose

## Alternative: Remove the Badge

If you don't need the workflow status badge, you can remove it:

**Option 1: Remove Entirely**
```markdown
# Repository Migration Framework

Automate repository migrations from Azure DevOps, BitBucket, SVN, or GitHub into your organization.
```

**Option 2: Replace with Simple Link**
```markdown
# Repository Migration Framework

[View Workflows](../../actions/workflows/migrate.yml)

Automate repository migrations from Azure DevOps, BitBucket, SVN, or GitHub into your organization.
```

**Option 3: Use Generic Description Badge**
```markdown
# Repository Migration Framework

![Status: Active](https://img.shields.io/badge/status-active-success)

Automate repository migrations from Azure DevOps, BitBucket, SVN, or GitHub into your organization.
```

## Related Files

- `README.md` - Main documentation file with badge
- `.github/workflows/migrate.yml` - Workflow that badge references
- Other skills for related setup:
  - `update-app-name` - Update GitHub App references
  - `update-default-org` - Update organization references

## Additional Resources

- [GitHub Actions Badge Documentation](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/adding-a-workflow-status-badge)
- [Shields.io Badge Service](https://shields.io/)
- [GitHub Context Variables](https://docs.github.com/en/actions/learn-github-actions/contexts#github-context)
- [Markdown Link Syntax](https://www.markdownguide.org/basic-syntax/#links)

## Converting from Template to Production Repository

Once you've completed all setup steps (app configuration, secrets, organization updates), you should update the README to reflect that this is now a production repository, not a template.

### What to Update

After completing setup, the README should transition from:
- **Template setup instructions** → **Daily usage documentation**
- **"How to configure"** → **"How to use"**
- **Setup prerequisites** → **Quick start guide**

### Step 1: Assessment

Verify all setup is complete before converting:

**Completed Setup Checklist:**
- [ ] GitHub App created and installed
- [ ] App name and ID updated throughout repository (using `update-app-name` skill)
- [ ] Organization references updated (using `update-default-org` skill)
- [ ] All required secrets configured (`GH_APP_PRIVATE_KEY`, `GH_APP_ID`)
- [ ] Optional source system secrets configured (ADO_PAT, BB_PAT, etc.)
- [ ] Workflow badge updated with actual repository name
- [ ] Test migration run successfully completed
- [ ] Teams created and permissions verified

**If any items are incomplete**, finish setup before proceeding.

### Step 2: Simplified Production README

Replace the setup-heavy README with usage-focused content:

```markdown
# Repository Migration Framework

[![🏃‍♂️ Repo Create / Import / Migrate](https://github.com/your-org/your-repo/actions/workflows/migrate.yml/badge.svg?event=workflow_dispatch)](https://github.com/your-org/your-repo/actions/workflows/migrate.yml)

Automated repository migration framework for migrating from Azure DevOps, BitBucket, SVN, or GitHub into our organization.

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
| **GitHub (Internal)** | `https://github.com/your-org/{repo}` | No extra auth needed |

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
- 💬 **Contact:** Your organization's platform team
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
```

### Step 3: Move Setup Documentation

Create `SETUP.md` for administrative documentation:

```markdown
# Migration Framework Setup and Administration

This document contains setup and administrative information for the migration framework. **End users do not need this documentation** - they should use the issue template to request migrations.

---

## Architecture

[Move architecture content from README here]

## Initial Setup

[Move all Step 1-5 setup instructions here]

## Configuration

[Move secrets tables and configuration details here]

## Customization

[Move Copilot skills information here]

### Available Skills

- **[update-readme-repo](.github/skills/update-readme-repo/SKILL.md)** - Fix workflow status badge
- **[update-app-name](.github/skills/update-app-name/SKILL.md)** - Update GitHub App references
- **[update-default-org](.github/skills/update-default-org/SKILL.md)** - Update organization references  
- **[add-custom-properties](.github/skills/add-custom-properties/SKILL.md)** - Add repository metadata
- **[add-import-source](.github/skills/add-import-source/SKILL.md)** - Support new source systems

## Maintenance

[Add sections on:]
- Rotating GitHub App credentials
- Updating source system authentication
- Monitoring migration success rates
- Troubleshooting common issues

## Security

[Add sections on:]
- Secret management best practices
- Audit logging
- Access control
```

### Step 4: Update Repository Settings

Once documentation is finalized:

1. **Disable Template Features** (if enabled):
   - Repository Settings → General
   - Uncheck "Template repository"

2. **Update Repository Description**:
   ```
   Automated repository migration framework for [Your Org]
   ```

3. **Set Topics** (for discoverability):
   - `migration`
   - `github-actions`
   - `automation`
   - `repository-management`

4. **Update About Section**:
   - Add link to issue template
   - Add link to documentation

### Step 5: Archive Template Instructions

Create an archive of setup instructions for reference:

```bash
# Create docs directory if it doesn't exist
mkdir -p docs/archive

# Move original README for reference
cp README.md docs/archive/TEMPLATE_SETUP.md

# Add note to archived file
echo "# Original Template Setup Instructions\n\n**Note:** This is an archived version of the original template setup instructions. This repository is now configured and in production. For current documentation, see README.md\n\n---\n\n" | cat - docs/archive/TEMPLATE_SETUP.md > temp && mv temp docs/archive/TEMPLATE_SETUP.md
```

### Step 6: Commit Production README

```bash
# Stage all documentation changes
git add README.md SETUP.md docs/

# Commit with clear message
git commit -m "docs: Convert README from template to production documentation

- Simplified README for end user focus
- Moved setup instructions to SETUP.md for admins
- Archived original template instructions
- Updated repository description and topics"

# Push changes
git push
```

### Step 7: Announce to Your Organization

Communicate the new migration framework to your organization:

**Example Announcement:**

```markdown
## 🎉 New: Automated Repository Migration Framework

We've launched an automated migration framework to simplify moving repositories into GitHub!

**What it does:**
✅ Migrates repos from ADO, BitBucket, SVN, or GitHub
✅ Creates teams and sets up permissions automatically  
✅ Preserves complete git history
✅ Configures branch protection and integrations

**How to use:**
1. Go to: [repo-migration issues]
2. Click "New Issue" → "Repository Creation/Migration"
3. Fill out the form
4. Submit and watch it work!

**Questions?** See the [README] or contact the platform team.
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
3. Update organization references
...
```

### Simplify Technical Details

**Good (Simple):**
```markdown
The framework migrates your code, history, and branches automatically.
```

**Avoid (Too technical):**
```markdown
The framework uses the GitHub App authentication pattern with JWT token generation to create a scoped token that bypasses branch protection temporarily while using git commands to clone the source repository and push to the target with preserved refspecs...
```

### Link to Admin Docs

**Good:**
```markdown
## Administration

For setup and configuration, see [SETUP.md](SETUP.md).
```

**Avoid:**
Include all setup steps in the main README.

### Emphasize Self-Service

**Good:**
```markdown
## Quick Start

Request a migration in 2 minutes using our issue template.
```

**Avoid:**
```markdown
Contact the platform team to request a migration.
```

## Validation Checklist

Before considering the conversion complete:

- [ ] All setup steps completed successfully
- [ ] Test migration run confirmed working
- [ ] README focuses on usage, not setup
- [ ] Setup documentation moved to SETUP.md
- [ ] Template instructions archived
- [ ] Repository description updated
- [ ] Topics added for discoverability
- [ ] Template repository setting disabled (if applicable)
- [ ] Workflow badge shows correct status
- [ ] Team announcement prepared
- [ ] Admin documentation complete
- [ ] No placeholder values remaining ({{APP_NAME}}, {{DEFAULT ORG}}, etc.)

## Maintenance Mode

After conversion to production, maintain the framework:

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

## Rollback Plan

If issues arise after conversion, you can rollback:

```bash
# Restore original template README
git checkout HEAD~1 README.md

# Or restore from archive
cp docs/archive/TEMPLATE_SETUP.md README.md

# Commit and push
git commit -m "Revert to template README for troubleshooting"
git push
```

## Related Skills

After updating the README badge, consider using these skills:

1. **update-app-name**: Update GitHub App references throughout the repository
2. **update-default-org**: Update organization references in workflows and scripts
3. **add-custom-properties**: Add organization-specific repository metadata

Execute in sequence:
```
@workspace Use update-readme-repo skill to fix the workflow badge
@workspace Use update-app-name skill with App Name: my-app and App ID: 123456789
@workspace Use update-default-org skill with Organization: my-org
```
