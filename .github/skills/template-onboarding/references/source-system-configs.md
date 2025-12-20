# Source System Configurations

This document provides detailed configuration patterns for all supported source systems and guidance for adding new ones.

## Supported Source Systems

### 1. Azure DevOps (ADO)

**URL Pattern:**
```
https://dev.azure.com/{organization}/{project}/_git/{repository}
```

**Authentication:**
- Personal Access Token (PAT)
- Required scopes:
  - Code: Read & Write
  - Build: Read & Execute
  - Project and Team: Read, Write, & Manage

**Setup Steps:**

1. **Generate PAT:**
   - Navigate to: Azure DevOps → User Settings → Personal Access Tokens
   - Click "New Token"
   - Name: `GitHub Migration`
   - Organization: Select your organization
   - Expiration: Choose appropriate timeframe
   - Scopes: Select required scopes listed above
   - Click "Create" and copy the token

2. **Add to GitHub Secrets:**
   ```bash
   gh secret set ADO_PAT --repo {ORG}/{REPO}
   # Paste your PAT when prompted
   ```

3. **Test Connection:**
   ```bash
   # Clone a test repository using the PAT
   git clone https://{PAT}@dev.azure.com/{org}/{project}/_git/{repo}
   ```

**Common Issues:**
- **401 Unauthorized:** PAT expired or invalid
- **403 Forbidden:** Insufficient PAT scopes
- **404 Not Found:** Incorrect URL or repository doesn't exist

**Workflow Integration:**
Already integrated. The workflow automatically detects ADO URLs and uses the `ADO_PAT` secret.

---

### 2. BitBucket (Server/Data Center)

**URL Pattern:**
```
https://{bitbucket-domain}/scm/{project}/{repository}.git
```

**Authentication:**
- Username + App Password or PAT
- Required permissions:
  - Repository: Read

**Setup Steps:**

1. **Generate App Password:**
   - Navigate to: BitBucket → Personal Settings → App passwords
   - Click "Create app password"
   - Label: `GitHub Migration`
   - Permissions: Repository - Read
   - Click "Create" and copy the password

2. **Add to GitHub Secrets:**
   ```bash
   gh secret set BB_USERNAME --repo {ORG}/{REPO}
   # Enter your BitBucket username
   
   gh secret set BB_PAT --repo {ORG}/{REPO}
   # Paste your app password
   ```

3. **Test Connection:**
   ```bash
   git clone https://{USERNAME}:{APP-PASSWORD}@{bitbucket-domain}/scm/{project}/{repo}.git
   ```

**Common Issues:**
- **401 Unauthorized:** Invalid credentials
- **SSL Certificate Issues:** Self-signed certificates in on-premises instances
- **Rate Limiting:** Too many concurrent requests

**Workflow Integration:**
Already integrated. The workflow detects BitBucket URLs and uses `BB_USERNAME` and `BB_PAT` secrets.

---

### 3. Subversion (SVN)

**URL Pattern:**
```
https://{svn-domain}/{repository}
# or
svn://{svn-domain}/{repository}
```

**Authentication:**
- Service account username and password
- Required permissions:
  - Read access to repository

**Setup Steps:**

1. **Obtain Service Account Credentials:**
   - Contact your SVN administrator
   - Request read-only service account

2. **Add to GitHub Secrets:**
   ```bash
   gh secret set SUBVERSION_SERVICE_USERNAME --repo {ORG}/{REPO}
   # Enter SVN username
   
   gh secret set SUBVERSION_SERVICE_PASSWORD --repo {ORG}/{REPO}
   # Enter SVN password
   ```

3. **Test Connection:**
   ```bash
   svn list https://{svn-domain}/{repo} --username {USERNAME} --password {PASSWORD}
   ```

**Special Considerations:**
- SVN repositories are converted to Git during migration
- History is preserved through `git svn clone`
- Large repositories may take significant time
- Branches and tags are mapped to Git equivalents

**Common Issues:**
- **E170001:** Authentication failed
- **E175002:** Connection timeout
- **Large Repository:** May exceed workflow timeout (consider partial migration)

**Workflow Integration:**
Already integrated. The workflow detects SVN URLs and uses the service account credentials.

---

### 4. GitHub (External Organizations)

**URL Pattern:**
```
https://github.com/{organization}/{repository}
```

**Authentication:**
- Personal Access Token (PAT)
- Required scopes:
  - `repo` (all repository permissions)

**Setup Steps:**

1. **Generate PAT:**
   - Navigate to: GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Note: `GitHub Migration`
   - Scopes: Select `repo`
   - Click "Generate token" and copy

2. **Add to GitHub Secrets:**
   ```bash
   gh secret set GH_PAT --repo {ORG}/{REPO}
   # Paste your GitHub PAT
   ```

3. **Test Connection:**
   ```bash
   git clone https://{PAT}@github.com/{org}/{repo}.git
   ```

**Common Issues:**
- **404 Not Found:** Repository doesn't exist or PAT lacks access
- **403 Forbidden:** Rate limiting or insufficient permissions
- **SAML SSO:** Token may need SAML authorization

**Workflow Integration:**
Already integrated for external GitHub organizations. Internal organization migrations don't need this secret.

---

## Adding New Source Systems

### Pattern for Adding New Sources

Follow these steps to add support for a new source control system:

#### Step 1: Define Source Specifications

Document:
- Source system name
- URL pattern(s)
- Authentication method
- Required scopes/permissions
- Command-line tools needed
- Special handling requirements

#### Step 2: Update URL Parsing

Modify `scripts/New-ImportRepoDetails.ps1`:

```powershell
# Add after existing source checks
if($env:IMPORT_URL -match 'https://your-source.com/(?<org>.+)/(?<repo>.+?)(?:\.git)?$'){
    $results = @{
        "source" = "your-source"
        "org" = $Matches['org']
        "repo" = $Matches['repo']
    } | ConvertTo-Json -Compress
    
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=your-source" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_YOUR_SOURCE_ORG=$($Matches['org'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_YOUR_SOURCE_REPO=$($Matches['repo'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}
```

#### Step 3: Update Migration Script

Modify `scripts/New-GitHubRepoMigration.ps1`:

```powershell
# Add authentication and cloning logic
elseif($env:IMPORT_SOURCE -eq "your-source"){
    if([String]::IsNullOrEmpty($env:YOUR_SOURCE_PAT)){
      throw "Environment variable YOUR_SOURCE_PAT is not set"
    }
    
    $org = $env:IMPORT_YOUR_SOURCE_ORG
    $repo = $env:IMPORT_YOUR_SOURCE_REPO
    
    # Construct clone URL with authentication
    $cloneUrl = "https://oauth2:$($env:YOUR_SOURCE_PAT)@your-source.com/$org/$repo.git"
    
    # Add any special handling
    # Example: LFS, specific branch handling, etc.
}
```

#### Step 4: Update Workflow

Modify `.github/workflows/migrate.yml`:

```yaml
- name: 🏃 Migrate Repo to GitHub
  env:
    # ... existing env vars ...
    YOUR_SOURCE_PAT: ${{ secrets.YOUR_SOURCE_PAT }}
  run: |
    & "${{github.workspace}}/scripts/New-GitHubRepoMigration.ps1"
```

#### Step 5: Document Configuration

Add documentation:

1. **In this file:** Add a new section following the pattern above
2. **In README.md:** Add to supported sources table
3. **In issue template:** Update source URL field description

#### Step 6: Test Thoroughly

Test with:
- Valid credentials
- Invalid credentials
- Various repository sizes
- Edge cases (empty repos, large files, special characters)

---

## Example: Adding GitLab Support

Here's a complete example of adding GitLab:

### GitLab Specifications

- **Name:** GitLab
- **URL:** `https://gitlab.com/{group}/{project}`
- **Auth:** Personal Access Token with `read_repository` scope
- **Tools:** Standard git

### Implementation

**1. URL Parsing (`scripts/New-ImportRepoDetails.ps1`):**

```powershell
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

**2. Migration Script (`scripts/New-GitHubRepoMigration.ps1`):**

```powershell
elseif($env:IMPORT_SOURCE -eq "gitlab"){
    if([String]::IsNullOrEmpty($env:GITLAB_PAT)){
      throw "Environment variable GITLAB_PAT is not set"
    }
    
    $gitlabGroup = $env:IMPORT_GITLAB_GROUP
    $gitlabProject = $env:IMPORT_GITLAB_PROJECT
    
    $cloneUrl = "https://oauth2:$($env:GITLAB_PAT)@gitlab.com/$gitlabGroup/$gitlabProject.git"
}
```

**3. Workflow (`.github/workflows/migrate.yml`):**

```yaml
env:
  GITLAB_PAT: ${{ secrets.GITLAB_PAT }}
```

**4. Setup Instructions:**

```markdown
### GitLab Configuration

1. Generate GitLab Personal Access Token:
   - Go to GitLab Settings → Access Tokens
   - Create token with `read_repository` scope
   - Copy the token

2. Add to GitHub Secrets:
   ```bash
   gh secret set GITLAB_PAT --repo {ORG}/{REPO}
   ```

3. Test migration with GitLab URL:
   ```
   https://gitlab.com/mygroup/myproject
   ```
```

---

## Special Authentication Patterns

### OAuth 2.0

For sources using OAuth:

```powershell
if($env:IMPORT_SOURCE -eq "oauth-source"){
    # Exchange credentials for OAuth token
    $tokenUrl = "https://oauth-source.com/oauth/token"
    $body = @{
        client_id = $env:OAUTH_CLIENT_ID
        client_secret = $env:OAUTH_CLIENT_SECRET
        grant_type = "client_credentials"
    }
    
    $response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body
    $token = $response.access_token
    
    $cloneUrl = "https://oauth2:$token@oauth-source.com/$org/$repo.git"
}
```

### SSH Key Authentication

For sources requiring SSH:

```powershell
if($env:IMPORT_SOURCE -eq "ssh-source"){
    # Setup SSH key
    $sshDir = "$HOME/.ssh"
    New-Item -ItemType Directory -Force -Path $sshDir | Out-Null
    
    $sshKeyPath = "$sshDir/id_rsa"
    Set-Content -Path $sshKeyPath -Value $env:SSH_PRIVATE_KEY
    
    # Set correct permissions (Unix-like systems)
    if($IsLinux -or $IsMacOS){
        chmod 600 $sshKeyPath
    }
    
    # Add to known hosts
    ssh-keyscan ssh-source.com >> "$sshDir/known_hosts"
    
    $cloneUrl = "git@ssh-source.com:$org/$repo.git"
}
```

### API-Based Migration

For sources without direct git access:

```powershell
if($env:IMPORT_SOURCE -eq "api-source"){
    # Download via API
    $apiUrl = "https://api-source.com/repos/$org/$repo/export"
    $headers = @{
        "Authorization" = "Bearer $($env:API_SOURCE_TOKEN)"
    }
    
    $exportFile = "$folder/export.zip"
    Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -OutFile $exportFile
    
    # Extract and convert to git
    Expand-Archive -Path $exportFile -DestinationPath "$folder/ado"
    
    # Initialize git if needed
    Push-Location "$folder/ado"
    git init
    git add .
    git commit -m "Initial import from API source"
    Pop-Location
}
```

---

## Security Considerations

### Credential Management

1. **Use Secrets, Not Variables:**
   - Always use repository/organization secrets for credentials
   - Never use repository variables for sensitive data
   - Variables are visible to anyone with read access

2. **Minimum Required Scopes:**
   - Request only the permissions needed
   - Prefer read-only access when possible
   - Document required scopes clearly

3. **Token Rotation:**
   - Rotate credentials quarterly
   - Use short-lived tokens when available
   - Monitor for token compromise

4. **Service Accounts:**
   - Prefer service accounts over personal tokens
   - Use dedicated accounts for automation
   - Implement proper audit logging

### Network Security

1. **HTTPS Only:**
   - Always use HTTPS for git operations
   - Validate SSL certificates
   - Avoid disabling certificate verification

2. **Rate Limiting:**
   - Implement backoff strategies
   - Monitor API usage
   - Use pagination for large datasets

3. **Data Protection:**
   - Never log credentials or tokens
   - Mask sensitive data in outputs
   - Clean up temporary files containing credentials

---

## Troubleshooting Guide

### Authentication Issues

**Symptom:** 401 Unauthorized
- Verify token/credentials are correct
- Check token hasn't expired
- Ensure token has required scopes

**Symptom:** 403 Forbidden
- Check rate limiting
- Verify permissions on repository
- Confirm SAML/SSO authorization (GitHub)

### Connection Issues

**Symptom:** Connection timeout
- Check network connectivity
- Verify firewall rules
- Try different network

**Symptom:** SSL certificate errors
- Update git to latest version
- Check certificate validity
- For self-signed certs, configure trust (not recommended for production)

### Migration Issues

**Symptom:** Missing branches
- Check default branch configuration
- Verify branch permissions
- Use `--mirror` flag for full clone

**Symptom:** Large file errors
- Check for LFS usage
- Consider partial migration
- Increase workflow timeout

**Symptom:** Character encoding issues
- Set git config for encoding
- Convert files before migration
- Document encoding requirements

---

## Best Practices

1. **Test First:**
   - Always test with small repositories first
   - Verify configuration before bulk migrations
   - Keep test credentials separate from production

2. **Document Everything:**
   - Record configuration decisions
   - Document special cases
   - Maintain runbooks for common issues

3. **Monitor and Iterate:**
   - Track migration success rates
   - Collect feedback from users
   - Continuously improve based on experience

4. **Plan for Failures:**
   - Implement retry logic
   - Provide clear error messages
   - Have rollback procedures ready

---

## Summary

This document provides configuration patterns for all supported source systems and a framework for adding new ones. Follow the established patterns, prioritize security, and maintain comprehensive documentation for successful migrations.

For step-by-step onboarding guidance, see the main SKILL.md file.
For validation commands, see setup-checklist.md.
