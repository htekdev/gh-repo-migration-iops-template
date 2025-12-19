---
name: add-import-source
description: Comprehensive guide for adding new source control systems to the migration framework. Use this skill when asked to add support for importing from a new source system (like GitLab, Perforce, Mercurial, etc.), or when troubleshooting import source issues. Includes workflow modifications, script updates, and credential configuration guidance.
---

# Add Import Source

## Overview

This skill provides step-by-step instructions for adding support for a new source control system to the migration framework. The framework currently supports Azure DevOps (ADO), BitBucket, Subversion (SVN), and GitHub as import sources.

## When to Use This Skill

Use this skill when:
- Adding support for a new source control system (GitLab, Perforce, Mercurial, etc.)
- Extending existing source system support with new authentication methods
- Troubleshooting import source detection or cloning issues
- Updating import source URL patterns or parsing logic

## Current Supported Sources

The framework currently supports these import sources:

1. **Azure DevOps (ADO)** - Git repositories
   - URL pattern: `https://dev.azure.com/{org}/{project}/_git/{repo}`
   - Auth: Personal Access Token (PAT)
   - Environment variable: `ADO_PAT`

2. **Azure DevOps TFS** - Team Foundation Server repositories
   - URL pattern: `https://dev.azure.com/{org}/{project}/_versionControl`
   - Auth: Personal Access Token (PAT)
   - Environment variable: `ADO_PAT`

3. **BitBucket** - Git repositories
   - URL pattern: `https://{bitbucket-domain}/scm/{project}/{slug}.git`
   - Auth: Username + Password/PAT
   - Environment variables: `BB_USERNAME`, `BB_PAT`

4. **Subversion (SVN)** - SVN repositories
   - URL pattern: `https://{svn-domain}/{repo}`
   - Auth: Service account credentials
   - Environment variables: `SUBVERSION_SERVICE_USERNAME`, `SUBVERSION_SERVICE_PASSWORD`

5. **GitHub** (internal) - Same organization
   - URL pattern: `https://github.com/{{DEFAULT ORG}}/{repo}`
   - Auth: GitHub App token
   - Environment variable: Handled by `modules.ps1`

6. **GitHub External** - Different organization
   - URL pattern: `https://github.com/{org}/{repo}`
   - Auth: Personal Access Token
   - Environment variable: `GH_PAT`

## Adding a New Import Source

### Step 1: Identify Source System Requirements

Before adding a new source, gather these details:

1. **Source system name** (e.g., GitLab, Perforce, Mercurial)
2. **URL pattern** - How repositories are identified
3. **Authentication method** - PAT, OAuth, SSH keys, username/password
4. **Command-line tools** - Required CLI tools or libraries
5. **Special considerations** - Folder structures, branch handling, history preservation

Example for GitLab:
- Name: `gitlab`
- URL: `https://gitlab.com/{group}/{project}.git`
- Auth: Personal Access Token
- Tool: `git clone` (native git)
- Special: Supports groups/subgroups

### Step 2: Update URL Parsing Script

Modify `scripts/New-ImportRepoDetails.ps1` to detect and parse the new source URL.

Add URL pattern matching logic:

```powershell
# Add after existing source checks, before the final error

# Check if import url is a valid GitLab url
if($env:IMPORT_URL -match 'https://gitlab.com/(?<group>.+)/(?<project>.+?)(?:\.git)?$'){
    $results = @{
        "source" = "gitlab"
        "group" = $Matches['group']
        "project" = $Matches['project']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=gitlab" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITLAB_GROUP=$($Matches['group'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITLAB_PROJECT=$($Matches['project'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}
```

**Important**: Place new source checks in logical order (most specific patterns first).

### Step 3: Update Migration Script

Modify `scripts/New-GitHubRepoMigration.ps1` to handle the new source type.

Add authentication and cloning logic:

```powershell
# Add in the try block, before the existing if/elseif chain

if($env:IMPORT_SOURCE -eq "gitlab"){
    if([String]::IsNullOrEmpty($env:GITLAB_PAT)){
      throw "Environment variable GITLAB_PAT is not set"
    }
    
    $gitlabGroup = $env:IMPORT_GITLAB_GROUP
    $gitlabProject = $env:IMPORT_GITLAB_PROJECT
    
    $cloneUrl = "https://oauth2:$($env:GITLAB_PAT)@gitlab.com/$gitlabGroup/$gitlabProject.git"
}
```

Add any special handling after the main cloning logic:

```powershell
# After: git clone $cloneUrl ado
# Add special processing if needed

if($env:IMPORT_SOURCE -eq "gitlab"){
  # GitLab-specific post-clone operations
  Push-Location $folder/ado
  # Handle GitLab-specific branch naming, tags, etc.
  Pop-Location
}
```

### Step 4: Update Error Messages

Update error messages to include the new source:

In `New-GitHubRepoMigration.ps1`:

```powershell
else{
    Write-Output "| **Import Repo** | ❌ | Unknown import source: ``$($env:IMPORT_SOURCE)`` <b>Expected values:</b> ``ado``, ``bitbucket``, ``gitlab``, ``svn`` |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
    throw "Unknown import source: $env:IMPORT_SOURCE, expected values: ado, bitbucket, gitlab, svn, etc."
}
```

In `New-ImportRepoDetails.ps1` (final error):

```powershell
throw "Unknown import url: $env:IMPORT_URL`nExpected format: `n  1. https://dev.azure.com/{organization}/{project}/_git/{repo}`n  2. https://bitbucket.example.com/scm/{project}/{slug}.git`n  3. https://gitlab.com/{group}/{project}.git`n  4. https://svn.example.com/{repo}`n  5. None"
```

### Step 5: Configure Required Secrets

**CRITICAL**: Users must add the necessary credentials to their repository secrets.

#### GitHub Organization Secrets (Recommended)

For organization-wide use, add secrets at the organization level:

1. Navigate to Organization Settings → Secrets and Variables → Actions
2. Click "New organization secret"
3. Add the credential (e.g., `GITLAB_PAT`)
4. Set repository access (all repositories or specific ones)

#### Repository Secrets (Alternative)

For repository-specific credentials:

1. Navigate to Repository Settings → Secrets and Variables → Actions
2. Click "New repository secret"
3. Add the credential

#### Secret Naming Conventions

Follow the existing pattern:
- `{SOURCE}_PAT` - Personal Access Token
- `{SOURCE}_USERNAME` - Username (if needed)
- `{SOURCE}_PASSWORD` - Password (if separate from PAT)
- `{SOURCE}_SERVICE_USERNAME` - Service account username
- `{SOURCE}_SERVICE_PASSWORD` - Service account password

Example for GitLab:
- `GITLAB_PAT` - GitLab Personal Access Token
- `GITLAB_USERNAME` - (Optional) If using username/password auth

### Step 6: Update Workflow to Pass Secrets

Modify `.github/workflows/migrate.yml` to pass the new secret to the migration job.

In the `test` job, add environment variables:

```yaml
- name: 🏃 Migrate ADO Repo to GitHub Repo
  id: import
  if: ${{ fromJson(steps.url.outputs.results).source != 'none' }}
  env:
    GH_APP_CERTIFICATE: ${{ secrets.GH_APP_PRIVATE_KEY }}
    GH_APP_ID: ${{ vars.GH_APP_ID }}
    ADO_PAT: ${{ secrets.ADO_PAT }}
    BB_USERNAME: ${{ secrets.BB_USERNAME }}
    BB_PASSWORD: ${{ secrets.BB_PAT }}
    GITLAB_PAT: ${{ secrets.GITLAB_PAT }}  # Add this line
    ORG: ${{ env.GH_ORG }}
    REPO: ${{ env.GH_REPO }}
    # ... rest of env vars
```

### Step 7: Install Required Tools (if needed)

If the new source requires special command-line tools, add installation steps in the workflow.

Add before the migration step:

```yaml
- name: 📦 Install GitLab Tools
  if: ${{ fromJson(steps.url.outputs.results).source == 'gitlab' }}
  run: |
    # Install any required tools
    # Example: pip install gitlab-cli
    # Or: apt-get install gitlab-tools
```

For tools that need compilation or complex setup, create a dedicated script in `scripts/` directory:

```powershell
# scripts/Install-GitLabTools.ps1
# Tool installation logic
```

### Step 8: Handle Source-Specific Features

Some sources may have unique features requiring special handling:

#### Large File Storage (LFS)

```powershell
if($env:IMPORT_SOURCE -eq "gitlab"){
  Push-Location $folder/ado
  # Check for LFS
  if(Test-Path ".gitattributes"){
    git lfs fetch --all
    git lfs checkout
  }
  Pop-Location
}
```

#### Branch Protection

```powershell
if($env:IMPORT_SOURCE -eq "gitlab"){
  # GitLab protected branches need special handling
  Push-Location $folder/ado
  # Identify and migrate branch protection rules
  Pop-Location
}
```

#### Webhooks and Integrations

```powershell
# Document webhooks for manual migration
Write-Output "| **GitLab Webhooks** | ⚠️ | Manual migration required. See documentation. |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
```

### Step 9: Add Post-Migration Finalization (Optional)

If the source has ADO-style finalization requirements (pipeline rewiring, integration setup), create a finalization script:

```powershell
# scripts/Execute-GitLabMigrationFinalization.ps1
# Similar to Execute-ADOMigrationFinalization.ps1
```

Add to workflow:

```yaml
- name: 🏃 GitLab Integration Setup
  continue-on-error: true
  if: ${{ fromJson(steps.url.outputs.results).source == 'gitlab' }}
  env:
    GITLAB_PAT: ${{ secrets.GITLAB_PAT }}
    # ... other env vars
  run: |
    & "${{github.workspace}}/scripts/Execute-GitLabMigrationFinalization.ps1" -githubRepoUrl $($env:GITHUB_REPO_URL)
```

### Step 10: Document Credential Setup for Users

Create clear documentation for users on how to set up credentials. Add to your repository's documentation:

#### For GitLab Import Source

**Prerequisites:**
1. GitLab Personal Access Token with `read_repository` scope

**Setup Steps:**

1. **Generate GitLab Personal Access Token**:
   - Go to GitLab Settings → Access Tokens
   - Create token with scopes: `read_repository`, `read_api`
   - Copy the token (shown only once)

2. **Add Token to GitHub Secrets**:
   - Go to GitHub Organization/Repository Settings
   - Navigate to Secrets and Variables → Actions
   - Click "New organization secret" (or "New repository secret")
   - Name: `GITLAB_PAT`
   - Value: Paste your GitLab token
   - Click "Add secret"

3. **Verify Configuration**:
   - Run a test migration with a GitLab repository URL
   - Check workflow logs for authentication success
   - Verify repository content was cloned correctly

**Troubleshooting:**
- **401 Unauthorized**: Token expired or invalid
- **403 Forbidden**: Token lacks required scopes
- **404 Not Found**: Repository path incorrect or token lacks access

## Testing the New Source

### Unit Testing

1. Create a test repository in the new source system
2. Generate test credentials with minimal permissions
3. Run migration workflow manually with test parameters
4. Verify all stages complete successfully

### Integration Testing

1. Test with various repository sizes (small, medium, large)
2. Test with different branch structures
3. Test with edge cases (empty repos, archived repos)
4. Verify history preservation
5. Check file integrity and commit metadata

### Error Handling Testing

1. Test with invalid credentials
2. Test with malformed URLs
3. Test with inaccessible repositories
4. Verify error messages are clear and actionable

## Advanced: Custom Authentication Patterns

Some source systems use custom auth:

### OAuth 2.0 Flow

```powershell
if($env:IMPORT_SOURCE -eq "custom-source"){
  # Get OAuth token
  $response = Invoke-RestMethod -Method Post -Uri "https://custom-source.com/oauth/token" `
    -Body @{
      client_id = $env:CUSTOM_SOURCE_CLIENT_ID
      client_secret = $env:CUSTOM_SOURCE_CLIENT_SECRET
      grant_type = "client_credentials"
    }
  
  $token = $response.access_token
  $cloneUrl = "https://oauth2:$($token)@custom-source.com/$repo.git"
}
```

### SSH Key Authentication

```powershell
if($env:IMPORT_SOURCE -eq "ssh-source"){
  # Configure SSH key
  $sshKey = $env:SSH_PRIVATE_KEY
  $sshKeyPath = "$HOME/.ssh/id_rsa"
  
  New-Item -ItemType Directory -Force -Path "$HOME/.ssh"
  Set-Content -Path $sshKeyPath -Value $sshKey
  chmod 600 $sshKeyPath
  
  # Add to known hosts
  ssh-keyscan ssh-source.com >> "$HOME/.ssh/known_hosts"
  
  $cloneUrl = "git@ssh-source.com:$org/$repo.git"
}
```

### API Token with Custom Header

```powershell
if($env:IMPORT_SOURCE -eq "api-source"){
  # Configure git credential helper
  git config --global credential.helper store
  
  # Create credentials file
  $credentials = "https://api-token:$($env:API_SOURCE_TOKEN)@api-source.com"
  Set-Content -Path "$HOME/.git-credentials" -Value $credentials
  
  $cloneUrl = "https://api-source.com/$org/$repo.git"
}
```

## Common Patterns and Best Practices

### URL Parsing Best Practices

1. **Use specific regex patterns** - Avoid overly broad matches
2. **Test regex thoroughly** - Include edge cases in tests
3. **Handle optional components** - Like `.git` suffix, auth prefixes
4. **Escape special characters** - In regex patterns
5. **Document expected formats** - In error messages

### Credential Management

1. **Never log credentials** - Use Write-Host for debugging, not Write-Output
2. **Use secret masking** - GitHub Actions automatically masks registered secrets
3. **Minimum required permissions** - Request only necessary scopes
4. **Rotate credentials regularly** - Document rotation procedures
5. **Use service accounts** - Prefer service accounts over personal tokens

### Error Handling

1. **Validate early** - Check for credentials before starting migration
2. **Provide context** - Include source URL in error messages
3. **Suggest remediation** - Tell users how to fix the problem
4. **Log to job summary** - Use the job summary file for user-visible errors
5. **Fail gracefully** - Clean up partial migrations on error

### Performance Optimization

1. **Shallow clones** - Use `--depth 1` for repositories without history requirements
2. **Sparse checkout** - For folder-specific migrations
3. **Parallel processing** - For bulk migrations (future enhancement)
4. **Compression** - Enable git compression for large repositories
5. **Network optimization** - Use mirrors or proxies when available

## Example: Complete GitLab Implementation

Here's a complete example of adding GitLab support:

### 1. Update New-ImportRepoDetails.ps1

```powershell
# Add after BitBucket check
if($env:IMPORT_URL -match 'https://gitlab.com/(?<group>.+)/(?<project>.+?)(?:\.git)?$'){
    $results = @{
        "source" = "gitlab"
        "group" = $Matches['group']
        "project" = $Matches['project']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=gitlab" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITLAB_GROUP=$($Matches['group'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITLAB_PROJECT=$($Matches['project'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}
```

### 2. Update New-GitHubRepoMigration.ps1

```powershell
# Add after BitBucket handling
elseif($env:IMPORT_SOURCE -eq "gitlab"){
    if([String]::IsNullOrEmpty($env:GITLAB_PAT)){
      throw "Environment variable GITLAB_PAT is not set"
    }

    $gitlabGroup = $env:IMPORT_GITLAB_GROUP
    $gitlabProject = $env:IMPORT_GITLAB_PROJECT

    $cloneUrl = "https://oauth2:$($env:GITLAB_PAT)@gitlab.com/$gitlabGroup/$gitlabProject.git"
}
```

### 3. Update Workflow

```yaml
env:
  # ... existing env vars ...
  GITLAB_PAT: ${{ secrets.GITLAB_PAT }}
```

### 4. User Documentation

**README.md Addition:**

```markdown
### Supported Import Sources

- Azure DevOps (ADO)
- BitBucket
- GitLab
- Subversion (SVN)
- GitHub

#### GitLab Setup

1. Generate a Personal Access Token in GitLab with `read_repository` scope
2. Add `GITLAB_PAT` secret to your GitHub organization or repository
3. Use GitLab repository URL format: `https://gitlab.com/{group}/{project}`
```

## Troubleshooting Guide

### Source Not Detected

**Symptom**: "Unknown import url" error

**Solutions**:
1. Verify URL format matches the regex pattern exactly
2. Check for typos in the domain or path
3. Ensure the regex is placed in the correct order in `New-ImportRepoDetails.ps1`
4. Test regex pattern using PowerShell: `"url" -match 'pattern'`

### Authentication Failures

**Symptom**: 401 or 403 errors during clone

**Solutions**:
1. Verify secret name matches exactly (case-sensitive)
2. Check token hasn't expired
3. Confirm token has required permissions/scopes
4. Test token manually: `git clone https://token@source.com/repo.git`

### Clone Hangs or Times Out

**Symptom**: Workflow hangs during git clone

**Solutions**:
1. Check repository size (consider shallow clone for large repos)
2. Verify network connectivity to source
3. Check for rate limiting on source system
4. Increase timeout values in workflow

### Missing Branches or History

**Symptom**: Not all branches migrated

**Solutions**:
1. Use `--mirror` flag for full clone: `git clone --mirror`
2. Check default branch handling logic
3. Verify branch patterns match source system
4. Test with: `git branch -a` after clone

### Special Characters in URLs

**Symptom**: URL parsing fails with special characters

**Solutions**:
1. URL-encode special characters before parsing
2. Use `[System.Web.HttpUtility]::UrlDecode()` for decoding
3. Handle authentication credentials separately from URL
4. Test with various special character combinations

## Security Considerations

1. **Credential Storage**: Never commit credentials or expose them in logs
2. **Least Privilege**: Request minimum required permissions for migration
3. **Token Expiration**: Document token rotation procedures
4. **Audit Trail**: Log migration activities for compliance
5. **Data Exposure**: Be cautious when migrating between different security contexts
6. **Network Security**: Use HTTPS for all connections, validate certificates
7. **Secret Sprawl**: Consolidate credentials when possible

## Related Files

- `scripts/New-ImportRepoDetails.ps1` - URL parsing and source detection
- `scripts/New-GitHubRepoMigration.ps1` - Main migration logic and cloning
- `scripts/Execute-GitImport.ps1` - Git push operations
- `.github/workflows/migrate.yml` - Workflow orchestration
- `scripts/modules.ps1` - Common utility functions

## Future Enhancements

Consider these enhancements when adding new sources:

1. **Parallel migrations** - Support bulk migrations
2. **Partial history** - Allow date-range or commit-range imports
3. **Incremental sync** - Keep source and GitHub in sync
4. **Metadata preservation** - Migrate issue trackers, wikis, etc.
5. **Dry-run mode** - Validate migration before execution
6. **Rollback capability** - Undo failed migrations
7. **Source validation** - Pre-check source accessibility before migration
