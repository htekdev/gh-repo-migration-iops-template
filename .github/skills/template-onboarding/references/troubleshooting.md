# Troubleshooting Guide

This document provides solutions for common issues encountered during onboarding and migration.

## Table of Contents

1. [GitHub App Setup Issues](#github-app-setup-issues)
2. [Secrets and Variables Issues](#secrets-and-variables-issues)
3. [Source System Authentication](#source-system-authentication)
4. [Workflow Execution Issues](#workflow-execution-issues)
5. [Migration Failures](#migration-failures)
6. [Team and Permission Issues](#team-and-permission-issues)
7. [Custom Properties Issues](#custom-properties-issues)
8. [Production Finalization Issues](#production-finalization-issues)

---

## GitHub App Setup Issues

### Issue: Cannot create GitHub App

**Symptoms:**
- "You don't have permission to create apps" error
- No "GitHub Apps" option in settings

**Solutions:**
1. Verify you have organization owner or admin permissions
2. Check organization security settings for app creation restrictions
3. Contact organization owner to create app or grant permissions

**Verification:**
```bash
# Check your role in the organization
gh api "orgs/{ORG}/memberships/{USERNAME}" --jq '.role'
# Should return: "admin" or "owner"
```

---

### Issue: GitHub App installation failed

**Symptoms:**
- App created but installation fails
- "Installation failed" or "App not installed" messages

**Solutions:**
1. Check app permissions are correctly configured
2. Verify organization allows app installations
3. Try uninstalling and reinstalling the app
4. Check organization app policy settings

**Verification:**
```bash
# List installed apps
gh api "orgs/{ORG}/installations"

# Check app installation
gh api "orgs/{ORG}/installations" --jq '.[] | select(.app_slug == "{APP-NAME}")'
```

---

### Issue: Cannot find App User ID

**Symptoms:**
- API returns 404 for bot user
- `gh api /users/{APP-NAME}[bot]` fails

**Solutions:**
1. Ensure app name is exactly correct (case-sensitive)
2. Verify app has been installed to organization
3. Wait a few minutes after installation for bot user creation
4. Use alternative method:
   ```bash
   # Get app installation
   gh api "orgs/{ORG}/installations" --jq '.[] | select(.app_slug == "{APP-NAME}") | .id'
   
   # Get bot user from installation
   gh api "/app/installations/{INSTALLATION-ID}" --jq '.account.id'
   ```

---

## Secrets and Variables Issues

### Issue: Cannot set repository secrets

**Symptoms:**
- "Resource not accessible by integration" error
- Secrets page not accessible

**Solutions:**
1. Verify you have admin access to repository:
   ```bash
   gh api "repos/{ORG}/{REPO}" --jq '.permissions'
   ```
2. Check organization secret policies
3. Ensure you're authenticated with correct account:
   ```bash
   gh auth status
   ```

---

### Issue: Secrets not being passed to workflow

**Symptoms:**
- Workflow fails with "Environment variable not set"
- Secrets show as empty in logs

**Solutions:**
1. Verify secret names match exactly (case-sensitive)
2. Check workflow YAML has correct secret references
3. Ensure secrets are added at correct level (repo vs org)
4. Verify the secret actually has a value set

**Example workflow secret reference:**
```yaml
env:
  ADO_PAT: ${{ secrets.ADO_PAT }}  # Correct
  ADO_PAT: ${{ vars.ADO_PAT }}     # Wrong - vars is for variables, not secrets
```

---

### Issue: Variables not appearing in workflow

**Symptoms:**
- Workflow uses empty or default values
- Variables section shows variables but workflow doesn't see them

**Solutions:**
1. Verify variable reference syntax:
   ```yaml
   env:
     GH_APP_ID: ${{ vars.GH_APP_ID }}  # Correct
     GH_APP_ID: ${{ secrets.GH_APP_ID }}  # Wrong - use vars, not secrets
   ```
2. Check variable names for typos
3. Ensure variables are created at repository level (not environment level)

---

## Source System Authentication

### Issue: ADO authentication fails

**Symptoms:**
- "fatal: Authentication failed" during clone
- "TF401019: The Git repository with name or identifier does not exist"

**Solutions:**
1. Verify PAT hasn't expired:
   - Go to ADO → User Settings → Personal Access Tokens
   - Check expiration date
   - Generate new token if expired

2. Check PAT scopes:
   - Code: Read & Write ✓
   - Build: Read & Execute ✓
   - Project and Team: Read, Write, & Manage ✓

3. Test PAT manually:
   ```bash
   git clone https://{PAT}@dev.azure.com/{org}/{project}/_git/{repo}
   ```

4. Verify repository URL format:
   ```
   Correct: https://dev.azure.com/myorg/myproject/_git/myrepo
   Wrong: https://myorg.visualstudio.com/myproject/_git/myrepo (old URL)
   ```

---

### Issue: BitBucket connection timeout

**Symptoms:**
- Git clone hangs or times out
- "Could not resolve host" errors

**Solutions:**
1. Check BitBucket server URL is accessible:
   ```bash
   curl -I https://{bitbucket-domain}
   ```

2. Verify credentials work:
   ```bash
   git ls-remote https://{USERNAME}:{PAT}@{bitbucket-domain}/scm/{project}/{repo}.git
   ```

3. Check for SSL certificate issues (self-hosted BitBucket):
   ```bash
   # Temporarily disable SSL verification for testing (not for production!)
   git -c http.sslVerify=false clone https://...
   ```

4. Check firewall/network rules allow GitHub Actions runners to access BitBucket

---

### Issue: SVN authentication fails

**Symptoms:**
- "svn: E170001: Authentication failed"
- "svn: E175009: XML parsing failed"

**Solutions:**
1. Test credentials directly:
   ```bash
   svn list {SVN-URL} --username {USERNAME} --password {PASSWORD}
   ```

2. Check service account hasn't been locked or disabled

3. Verify SVN server URL is correct

4. For HTTPS SVN, check certificate trust

---

## Workflow Execution Issues

### Issue: Workflow not triggering

**Symptoms:**
- "Run workflow" button doesn't start workflow
- Workflow appears in list but doesn't execute

**Solutions:**
1. Check workflow file syntax:
   ```bash
   # Install actionlint
   # brew install actionlint (Mac) or download from GitHub
   
   # Validate workflow
   actionlint .github/workflows/migrate.yml
   ```

2. Verify workflow has `workflow_dispatch:` trigger

3. Check branch - workflows must be on default branch to appear in UI

4. Review Actions permissions:
   - Repository Settings → Actions → General
   - Ensure actions are enabled

---

### Issue: Workflow fails immediately

**Symptoms:**
- Workflow starts but fails within seconds
- Error: "Resource not accessible by integration"

**Solutions:**
1. Check GitHub App installation:
   ```bash
   gh api "orgs/{ORG}/installations"
   ```

2. Verify app has required permissions:
   - Repository: Contents (RW), Administration (RW)
   - Organization: Members (RW), Administration (RW)

3. Check workflow permissions:
   - Repository Settings → Actions → General → Workflow permissions
   - Should be "Read and write permissions"

---

### Issue: Workflow timeout

**Symptoms:**
- Workflow runs for 6 hours then cancels
- Large repository migration incomplete

**Solutions:**
1. For large repositories, consider:
   - Shallow clone: `git clone --depth 1`
   - Partial migration: Specify folder to import
   - Split into multiple smaller migrations

2. Increase timeout for specific step (if needed):
   ```yaml
   - name: Long running step
     timeout-minutes: 360  # 6 hours
     run: ...
   ```

3. Optimize repository before migration:
   - Remove unnecessary files
   - Clean up large binaries
   - Use Git LFS for large files

---

## Migration Failures

### Issue: Repository creation succeeds but migration fails

**Symptoms:**
- New repository exists but is empty
- "Clone failed" or "Push failed" errors

**Solutions:**
1. Check job summary for specific error

2. Verify source system credentials in secrets

3. Test source repository accessibility:
   ```bash
   git ls-remote {SOURCE-URL}
   ```

4. Check for special characters in repository name/path

5. Review migration logs in workflow run

---

### Issue: Team creation fails

**Symptoms:**
- "Team already exists" error
- "Cannot create team" error

**Solutions:**
1. Check if team name conflicts with existing team:
   ```bash
   gh api "orgs/{ORG}/teams" --jq '.[] | select(.name == "{TEAM-NAME}")'
   ```

2. Verify naming convention is correct:
   ```
   Format: tis-{provider}-{owner}
   Example: tis-platform-engineering
   ```

3. Check organization team creation permissions

4. Verify GitHub App has Organization Members (RW) permission

---

### Issue: Branch protection fails to apply

**Symptoms:**
- Repository created but branch protection missing
- "Branch not found" error

**Solutions:**
1. Ensure default branch exists before applying protection

2. Check branch name matches:
   ```bash
   gh api "repos/{ORG}/{REPO}" --jq '.default_branch'
   ```

3. Verify GitHub App can bypass branch protection:
   - This is required during setup
   - App must be included in bypass list

4. Check the branch protection configuration in workflow matches GitHub's API format

---

## Team and Permission Issues

### Issue: Team members cannot access repository

**Symptoms:**
- Team exists but members don't have access
- "404 Not Found" when team members try to access repo

**Solutions:**
1. Verify team has repository access:
   ```bash
   gh api "repos/{ORG}/{REPO}/teams"
   ```

2. Check team membership:
   ```bash
   gh api "orgs/{ORG}/teams/{TEAM-SLUG}/members"
   ```

3. Verify permission level is correct:
   ```bash
   gh api "orgs/{ORG}/teams/{TEAM-SLUG}/repos/{ORG}/{REPO}" --jq '.permissions'
   ```

4. Add team to repository manually if needed:
   ```bash
   gh api -X PUT "orgs/{ORG}/teams/{TEAM-SLUG}/repos/{ORG}/{REPO}" \
     -f permission=maintain
   ```

---

## Custom Properties Issues

### Issue: Custom properties not appearing on repository

**Symptoms:**
- Properties set in workflow but don't show in repository
- "Property not found" errors

**Solutions:**
1. Verify properties exist at organization level:
   ```bash
   gh api "orgs/{ORG}/properties/schema"
   ```

2. Create missing properties:
   - Organization Settings → Custom properties
   - Add each property with correct type

3. Check property names match exactly (case-sensitive)

4. Verify repository is included in property's allowed repositories

---

### Issue: Custom property values not updating

**Symptoms:**
- Workflow succeeds but property values remain unchanged
- Default values shown instead of workflow values

**Solutions:**
1. Check workflow step is uncommented in `.github/workflows/migrate.yml`

2. Verify VALUE environment variable is correctly formatted:
   ```yaml
   VALUE: |
     property_name=value
     another_property=another_value
   ```

3. Test setting properties manually:
   ```bash
   gh api -X PATCH "repos/{ORG}/{REPO}/properties/values" \
     -f properties[][property_name]=test_property \
     -f properties[][value]=test_value
   ```

---

## Production Finalization Issues

### Issue: Placeholder replacement incomplete

**Symptoms:**
- Some placeholders remain after running replacement script
- Organization name not updated in all files

**Solutions:**
1. Run placeholder detection:
   ```bash
   grep -r "htekdev\|{YOUR-ORG}\|{YOUR-REPO}" . --exclude-dir=.git
   ```

2. Manually replace remaining placeholders:
   ```bash
   # For specific files
   sed -i 's/htekdev/your-org/g' path/to/file
   ```

3. Check hidden files:
   ```bash
   grep -r "htekdev" . --include=".*"
   ```

4. Review and update:
   - Workflow files
   - Documentation
   - Issue templates
   - Scripts

---

### Issue: Template conversion incomplete

**Symptoms:**
- SETUP.md not created
- README still contains setup instructions

**Solutions:**
1. Manually create SETUP.md with setup content from README

2. Update README to focus on usage:
   - Remove setup sections
   - Add quick start guide
   - Link to SETUP.md for administrators

3. Run production readiness check:
   ```bash
   ./.github/skills/template-onboarding/scripts/Confirm-ProductionReadiness.ps1
   ```

---

## General Troubleshooting Tips

### Enable Debug Logging

Add to workflow to see detailed logs:

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
```

### Check GitHub Status

Verify GitHub isn't experiencing issues:
- Visit: https://www.githubstatus.com

### Review Workflow Logs

Access detailed logs:
```bash
# List recent runs
gh run list --workflow=migrate.yml

# View specific run
gh run view {RUN-ID}

# Download logs
gh run download {RUN-ID}
```

### Test Individual Scripts

Run scripts locally for debugging:

```powershell
# Navigate to repository root
cd /path/to/repo

# Test script with parameters
./scripts/New-GitHubRepo.ps1 -githubOrg "myorg" -githubRepo "test-repo"
```

### Validate Configuration

Use validation scripts:

```bash
# Check setup completeness
./.github/skills/template-onboarding/scripts/Test-SetupCompleteness.ps1

# Verify production readiness
./.github/skills/template-onboarding/scripts/Confirm-ProductionReadiness.ps1
```

---

## Getting Additional Help

### Information to Collect

When seeking help, provide:

1. **Workflow run URL** or run ID
2. **Error message** (exact text)
3. **Steps taken** before error occurred
4. **Configuration** (without sensitive data):
   - Which source system
   - Repository size
   - Custom configurations

### Support Channels

1. **Check existing issues** in the framework repository
2. **Review documentation**:
   - SKILL.md for onboarding guidance
   - setup-checklist.md for validation steps
   - source-system-configs.md for source-specific help
3. **Create new issue** with collected information
4. **Contact platform team** for organization-specific help

---

## Summary

This troubleshooting guide covers common issues encountered during onboarding and migration. For issues not covered here:

1. Check workflow logs for specific error messages
2. Verify configuration using validation scripts
3. Test components individually to isolate the problem
4. Collect detailed information before seeking help

Most issues relate to authentication, permissions, or configuration. Systematic verification usually identifies the root cause.
