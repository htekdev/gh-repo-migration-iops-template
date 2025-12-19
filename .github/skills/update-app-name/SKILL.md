---
name: update-app-name
description: Guide for updating GitHub App name and ID references when using the migration framework as a template repository. Use this skill when setting up the framework with a custom GitHub App or troubleshooting app-related configuration issues.
---

# Update App Name and ID

## Overview

This skill provides step-by-step instructions for updating all references to the GitHub App name and ID throughout the migration framework when using it as a template repository. The framework uses a GitHub App for authentication and authorization, and these references must be updated to match your organization's GitHub App.

## When to Use This Skill

Use this skill when:
- Setting up the migration framework with a new GitHub App
- Converting the repository from a template to an active framework
- Troubleshooting GitHub App authentication issues
- Migrating the framework from one organization to another
- Updating to a different GitHub App for enhanced permissions

## Why This Is Needed

The migration framework relies on a GitHub App for:
- **Authentication**: Accessing GitHub API with elevated permissions
- **Authorization**: Creating repositories, managing teams, and setting permissions
- **Commit Attribution**: Attributing automated commits to a service account
- **Branch Protection Bypass**: Temporarily bypassing branch protection during migration

The framework contains references to the GitHub App in:
- Git commit configurations (name and email)
- GitHub Actions workflow parameters (app-slug)
- Documentation and examples

## Understanding GitHub App Configuration

### GitHub App Components

1. **App Name** (e.g., `migrate`)
   - The unique identifier/slug for your GitHub App
   - Used in API calls and workflow configurations
   - Should be lowercase with hyphens

2. **App ID** (e.g., `149748790`)
   - Numeric identifier assigned by GitHub when creating the app
   - Used in bot email addresses for commit attribution
   - Found in GitHub App settings

3. **Bot Email Format**
   - Pattern: `{APP_ID}+{APP_NAME}[bot]@users.noreply.github.com`
   - Example: `149748790+migrate[bot]@users.noreply.github.com`
   - Used for git commit author attribution

## Files That Require Updates

The following files contain app name/ID references that need to be updated:

### 1. GitHub Actions Workflows

#### `.github/workflows/migrate.yml`

**Location 1: Add Mandated Repository Files Step**
- **Lines**: ~464-465
- **Current**: 
  ```yaml
  GIT_NAME: {{APP_NAME}}[bot]
  GIT_EMAIL: {{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com
  ```
- **Update to**: Your app name and ID
- **Purpose**: Git commit attribution for adding mandatory files

**Location 2: Import/Clone Repository Step**
- **Lines**: ~509-510
- **Current**: 
  ```yaml
  GIT_NAME: {{APP_NAME}}[bot]
  GIT_EMAIL: {{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com
  ```
- **Update to**: Your app name and ID
- **Purpose**: Git commit attribution during repository migration

**Location 3: Branch Protection Bypass Step**
- **Line**: ~542
- **Current**: 
  ```yaml
  app-slug: {{APP_NAME}}
  ```
- **Update to**: Your GitHub App slug
- **Purpose**: Identifies the app when bypassing branch protection
- **Note**: Only update if you're using the branch protection bypass action

**Location 4: Add Custom Properties Step (Commented)**
- **Lines**: ~555-556
- **Current**: 
  ```yaml
  #     GIT_NAME: {{APP_NAME}}[bot]
  #     GIT_EMAIL: {{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com
  ```
- **Update to**: Your app name and ID
- **Purpose**: Git commit attribution if custom properties are enabled

### 2. Documentation Files

#### `.github/copilot-instructions.md`

**Git Operations Standards Section**
- **Line**: ~227
- **Current**: 
  ```markdown
  - Use service account: `{{APP_NAME}}[bot]` with email `{{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com`
  ```
- **Update to**: Your app name and ID
- **Purpose**: Documents standard commit attribution pattern

#### `.github/skills/add-custom-properties/SKILL.md`

**Custom Properties Workflow Example**
- **Lines**: ~114-115
- **Current**: 
  ```yaml
  GIT_NAME: {{APP_NAME}}[bot]
  GIT_EMAIL: {{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com
  ```
- **Update to**: Your app name and ID
- **Purpose**: Example configuration for custom properties feature

## Step-by-Step Update Process

### Step 1: Create or Identify Your GitHub App

If you don't have a GitHub App yet, create one:

1. **Navigate to GitHub App Settings**:
   - Organization Settings → Developer settings → GitHub Apps → New GitHub App
   - Or use: `https://github.com/organizations/{YOUR_ORG}/settings/apps/new`

2. **Configure Basic Information**:
   - **GitHub App name**: Choose a descriptive name (e.g., `my-org-migrate`, `repo-migration-bot`)
   - **Homepage URL**: Your organization URL or repository URL
   - **Webhook**: Disable if not needed for your use case

3. **Set Permissions**:
   - **Repository permissions**:
     - Administration: Read & write
     - Contents: Read & write
     - Metadata: Read-only
     - Pull requests: Read & write
   - **Organization permissions**:
     - Members: Read & write
     - Administration: Read & write

4. **Install the App**:
   - After creation, install the app to your organization
   - Select which repositories it can access (all or specific)

5. **Record App Details**:
   - **App ID**: Found in app settings (General tab)
   - **App slug**: The URL-friendly name you chose
   - **Private Key**: Generate and download (needed for authentication)

### Step 2: Document Your App Information

Create a reference document with your app details:

```powershell
# Your GitHub App Information
$AppName = "my-org-migrate"  # Replace with your app slug
$AppID = "123456789"         # Replace with your app ID
$AppEmail = "$AppID+$AppName[bot]@users.noreply.github.com"
```

### Step 3: Perform Global Search and Replace

Use PowerShell to update all files:

```powershell
# Navigate to repository root
cd c:\path\to\your\repo

# Define your GitHub App details
$appName = "my-org-migrate"
$appId = "123456789"

# Find all files with {{APP_NAME}} placeholder
$files = Get-ChildItem -Recurse -File | Where-Object { 
    $_.Extension -in @('.yml', '.yaml', '.md') 
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $updated = $false
    
    if ($content -match '\{\{APP_NAME\}\}') {
        $content = $content -replace '\{\{APP_NAME\}\}', $appName
        $updated = $true
    }
    
    if ($content -match '\{\{APP_ID\}\}') {
        $content = $content -replace '\{\{APP_ID\}\}', $appId
        $updated = $true
    }
    
    if ($updated) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}
```

### Step 4: Configure GitHub Secrets and Variables

The framework requires GitHub App credentials to be configured:

#### Organization Variables

1. **Navigate to Organization Settings** → Secrets and Variables → Actions → Variables
2. **Create `GH_APP_ID` variable**:
   - Name: `GH_APP_ID`
   - Value: Your GitHub App ID (e.g., `123456789`)

#### Organization Secrets

1. **Navigate to Organization Settings** → Secrets and Variables → Actions → Secrets
2. **Create `GH_APP_PRIVATE_KEY` secret**:
   - Name: `GH_APP_PRIVATE_KEY`
   - Value: Your GitHub App private key (entire PEM file contents)

**Important**: The private key should include the header and footer:
```
-----BEGIN RSA PRIVATE KEY-----
[key content]
-----END RSA PRIVATE KEY-----
```

### Step 5: Update Branch Protection Bypass Configuration

If you're using the branch protection bypass action:

**Option 1: Use Your Own Branch Protection Bypass Action**

If your organization has a similar action:
```yaml
- name: 🔓 Add Branch Protection Exceptions
  uses: YourOrg/your-framework/actions/branch-protection-bypass@main
  id: clear-branch-protection
  with:
    app-slug: my-org-migrate  # Your app name
    repository: ${{ env.GH_ORG }}/${{ env.GH_REPO }}
    token: ${{ steps.app-token.outputs.token }}
```

**Option 2: Remove Branch Protection Bypass**

If you don't have this action:
- Remove or comment out the branch protection bypass step
- Handle branch protection manually or use GitHub's native API
- Alternative: Use `gh api` to temporarily disable protection

**Option 3: Implement Custom Bypass Logic**

Create your own bypass logic:
```yaml
- name: 🔓 Disable Branch Protection Temporarily
  run: |
    gh api -X PUT "/repos/${{ env.GH_ORG }}/${{ env.GH_REPO }}/branches/main/protection" \
      -f required_status_checks='null' \
      -f enforce_admins=false \
      -f required_pull_request_reviews='null'
```

### Step 6: Verify Git Commit Attribution

Test that commits are properly attributed to your GitHub App:

1. **Run a test migration**
2. **Check commit history** in the migrated repository
3. **Verify commits show**:
   - Author: `your-app-name[bot]`
   - Email: `{APP_ID}+your-app-name[bot]@users.noreply.github.com`

If commits aren't attributed correctly:
- Verify `GIT_NAME` and `GIT_EMAIL` are set correctly
- Ensure the email format matches GitHub's bot email pattern
- Check that git config is applied before commits

### Step 7: Test Authentication

Validate that the GitHub App authentication works:

```powershell
# Test GitHub App token generation
$env:GH_APP_ID = "123456789"
$env:GH_APP_CERTIFICATE = Get-Content "path/to/private-key.pem" -Raw

# Run a simple test script
& "$PSScriptRoot/scripts/modules.ps1"
Update-GitHubToken -Organization "YourOrg"

if($env:GH_TOKEN) {
    Write-Host "✅ GitHub App authentication successful"
    
    # Test API access
    gh api user
} else {
    Write-Host "❌ GitHub App authentication failed"
}
```

### Step 8: Update Documentation

Update any organization-specific documentation:

- **README.md**: Update examples to reference your app name
- **Internal docs**: Document your GitHub App setup
- **Team wiki**: Add troubleshooting guide for app authentication

## Advanced Configuration

### Multiple GitHub Apps

If you need different apps for different purposes:

**Scenario**: Separate apps for production and testing

```yaml
# Use different app based on environment
- name: 🔑 Generate GitHub App Token
  id: app-token
  env:
    GH_APP_ID: ${{ vars.GH_APP_ID_PROD || vars.GH_APP_ID_TEST }}
    GH_APP_CERTIFICATE: ${{ secrets.GH_APP_PRIVATE_KEY_PROD || secrets.GH_APP_PRIVATE_KEY_TEST }}
```

### App Permissions Validation

Verify your app has required permissions:

```powershell
# Check app permissions
$appId = "123456789"
gh api "/app" --jq '.permissions'

# Expected permissions:
# - administration: write
# - contents: write
# - members: write
# - metadata: read
```

### Rotating GitHub App Credentials

When rotating credentials:

1. **Generate new private key** in GitHub App settings
2. **Update `GH_APP_PRIVATE_KEY` secret** with new key
3. **Test authentication** before deleting old key
4. **Revoke old key** after confirming new key works
5. **Document rotation** in change log

## Troubleshooting

### Issue: "Bad credentials" or 401 Errors

**Cause**: GitHub App authentication failing

**Solutions**:
1. Verify `GH_APP_ID` variable is set correctly
2. Check `GH_APP_PRIVATE_KEY` secret contains complete key
3. Ensure private key format includes headers/footers
4. Confirm GitHub App is installed in the target organization
5. Verify app hasn't been suspended or deleted

### Issue: "Resource not accessible by integration"

**Cause**: GitHub App lacks required permissions

**Solutions**:
1. Review GitHub App permissions in settings
2. Grant required permissions:
   - Repository: Administration (write), Contents (write)
   - Organization: Members (write), Administration (write)
3. Reinstall the app if permissions were changed
4. Verify app is installed on target repositories

### Issue: Commits Show Wrong Author

**Cause**: Git config not properly set

**Solutions**:
1. Verify `GIT_NAME` and `GIT_EMAIL` environment variables
2. Check email format: `{APP_ID}+{APP_NAME}[bot]@users.noreply.github.com`
3. Ensure git config commands run before commits
4. Verify no global git config is overriding settings

### Issue: Branch Protection Bypass Fails

**Cause**: Action not available or misconfigured

**Solutions**:
1. Verify the action repository exists and is accessible
2. Check `app-slug` matches your GitHub App name exactly
3. Ensure GitHub App has bypass permissions
4. Consider alternative: Disable protection temporarily via API
5. Remove step if bypass isn't needed for your use case

### Issue: Token Expires During Long Migrations

**Cause**: GitHub App tokens have 1-hour expiration

**Solutions**:
1. Regenerate token periodically during long operations
2. Implement token refresh logic in scripts
3. Use `Update-GitHubToken` function before each major operation
4. Consider breaking large migrations into smaller chunks

## Validation Checklist

Use this checklist to ensure all updates are complete:

- [ ] Created or identified GitHub App in your organization
- [ ] Recorded GitHub App ID and slug
- [ ] Generated and downloaded private key
- [ ] Updated all `{{APP_NAME}}` placeholders
- [ ] Updated all `{{APP_ID}}` placeholders
- [ ] Configured `GH_APP_ID` organization variable
- [ ] Configured `GH_APP_PRIVATE_KEY` organization secret
- [ ] Updated branch protection bypass (or removed if not needed)
- [ ] Verified app permissions are sufficient
- [ ] Tested authentication with test script
- [ ] Performed test migration
- [ ] Verified commit attribution
- [ ] Updated documentation with app details
- [ ] Documented credential rotation procedure

## Best Practices

1. **Use Descriptive Names**: Choose GitHub App names that clearly indicate purpose
2. **Minimum Permissions**: Grant only permissions required for migration operations
3. **Secure Private Keys**: Store private keys securely, never commit to repository
4. **Regular Rotation**: Rotate private keys periodically (quarterly recommended)
5. **Separate Environments**: Use different apps for production and testing
6. **Document Everything**: Maintain documentation of app setup and configuration
7. **Monitor Usage**: Regularly review GitHub App activity logs
8. **Backup Keys**: Securely backup private keys before rotation

## Security Considerations

1. **Private Key Storage**:
   - Never commit private keys to repository
   - Use GitHub Secrets for storage
   - Restrict access to secrets to necessary personnel

2. **Permission Scoping**:
   - Grant minimum required permissions
   - Review permissions quarterly
   - Remove unused permissions

3. **Access Control**:
   - Limit app installation to specific repositories when possible
   - Use organization-level installation only when necessary
   - Regularly audit app installations

4. **Token Management**:
   - Tokens expire after 1 hour (security feature)
   - Never log or expose tokens
   - Use tokens only within secure workflows

5. **Audit Trail**:
   - Monitor GitHub App activity in audit logs
   - Review commit history for proper attribution
   - Track permission changes

## GitHub App vs Personal Access Token (PAT)

### Why Use GitHub App?

**Advantages**:
- More granular permissions
- Higher rate limits
- Better attribution (bot account)
- Organization-level management
- Automatic token expiration (security)
- Audit trail in organization logs

**Disadvantages**:
- More complex setup
- Requires organization admin access
- Additional configuration

### When to Use PAT Instead

Consider using PAT if:
- You don't have organization admin access
- Temporary or one-time migrations
- Testing in personal repositories
- GitHub App creation is blocked by policy

**Note**: The framework supports both authentication methods; GitHub App is recommended for production use.

## Related Files

- `.github/workflows/migrate.yml` - Main workflow with app references
- `.github/copilot-instructions.md` - Coding standards documentation
- `.github/skills/add-custom-properties/SKILL.md` - Custom properties skill
- `scripts/modules.ps1` - Contains `Update-GitHubToken` function for app authentication

## Additional Resources

- [GitHub Apps Documentation](https://docs.github.com/en/apps)
- [Authenticating as a GitHub App](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/authenticating-as-a-github-app)
- [GitHub App Permissions](https://docs.github.com/en/apps/creating-github-apps/setting-permissions-for-github-apps/choosing-permissions-for-a-github-app)
- [Managing GitHub App Installation](https://docs.github.com/en/apps/using-github-apps/installing-your-own-github-app)
- [Rate Limits for GitHub Apps](https://docs.github.com/en/apps/creating-github-apps/setting-up-a-github-app/rate-limits-for-github-apps)
