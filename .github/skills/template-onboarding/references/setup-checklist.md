# Setup Checklist

This document provides a detailed checklist for validating each setup step with verification commands.

## Phase 1: GitHub App Setup

### 1.1 App Creation

- [ ] GitHub App created in organization
- [ ] App name recorded: `________________`
- [ ] App ID recorded: `________________`
- [ ] Homepage URL configured

**Verify:**
```bash
# Check if app exists
gh api "/orgs/{ORG}/installations" --jq '.[] | select(.app_slug == "{app-name}")'
```

### 1.2 Permissions

- [ ] Repository permissions:
  - [ ] Contents: Read and write
  - [ ] Administration: Read and write
  - [ ] Metadata: Read-only
- [ ] Organization permissions:
  - [ ] Members: Read and write
  - [ ] Administration: Read and write

**Verify:**
Navigate to: `https://github.com/organizations/{ORG}/settings/apps/{APP-NAME}`

### 1.3 Installation

- [ ] App installed to organization
- [ ] Access level: All repositories OR specific repos

**Verify:**
```bash
gh api "/orgs/{ORG}/installations" --jq '.[] | {app_name: .app_slug, access: .repository_selection}'
```

## Phase 2: Credentials Collection

### 2.1 App ID

- [ ] App ID obtained: `________________`

**Verify:**
```bash
# View app details
gh api "/orgs/{ORG}/installations" --jq '.[] | select(.app_slug == "{app-name}") | .app_id'
```

### 2.2 App User ID

- [ ] App User ID obtained: `________________`

**Verify:**
```bash
gh api "/users/{APP-NAME}[bot]" --jq '.id'
```

### 2.3 Private Key

- [ ] Private key generated
- [ ] `.pem` file downloaded
- [ ] File contents accessible

**Verify:**
```bash
# Check file exists and has correct format
cat your-app-name.pem | head -1
# Should show: -----BEGIN RSA PRIVATE KEY-----
```

## Phase 3: Repository Configuration

### 3.1 Repository Variables

- [ ] `GH_APP_NAME` = `________________`
- [ ] `GH_APP_ID` = `________________`
- [ ] `GH_APP_USER_ID` = `________________`

**Verify:**
```bash
gh api "repos/{ORG}/{REPO}/actions/variables" --jq '.variables[] | {name: .name, value: .value}'
```

**Expected output:**
```json
[
  {"name": "GH_APP_NAME", "value": "your-app-name"},
  {"name": "GH_APP_ID", "value": "123456"},
  {"name": "GH_APP_USER_ID", "value": "123456789"}
]
```

### 3.2 Repository Secrets

- [ ] `GH_APP_PRIVATE_KEY` added

**Verify:**
```bash
gh api "repos/{ORG}/{REPO}/actions/secrets" --jq '.secrets[].name'
```

**Expected output:**
```
GH_APP_PRIVATE_KEY
```

## Phase 4: Source System Configuration

### 4.1 Azure DevOps (Optional)

- [ ] ADO PAT generated with scopes:
  - [ ] Code: Read & Write
  - [ ] Build: Read & Execute
  - [ ] Project and Team: Read, Write, & Manage
- [ ] `ADO_PAT` secret added

**Verify:**
```bash
gh api "repos/{ORG}/{REPO}/actions/secrets" --jq '.secrets[] | select(.name == "ADO_PAT")'
```

### 4.2 BitBucket (Optional)

- [ ] BitBucket app password generated
- [ ] `BB_USERNAME` secret added
- [ ] `BB_PAT` secret added

**Verify:**
```bash
gh api "repos/{ORG}/{REPO}/actions/secrets" --jq '.secrets[] | select(.name == "BB_USERNAME" or .name == "BB_PAT")'
```

### 4.3 Subversion (Optional)

- [ ] SVN service account credentials obtained
- [ ] `SUBVERSION_SERVICE_USERNAME` secret added
- [ ] `SUBVERSION_SERVICE_PASSWORD` secret added

**Verify:**
```bash
gh api "repos/{ORG}/{REPO}/actions/secrets" --jq '.secrets[] | select(.name == "SUBVERSION_SERVICE_USERNAME" or .name == "SUBVERSION_SERVICE_PASSWORD")'
```

### 4.4 GitHub External (Optional)

- [ ] GitHub PAT generated with `repo` scope
- [ ] `GH_PAT` secret added

**Verify:**
```bash
gh api "repos/{ORG}/{REPO}/actions/secrets" --jq '.secrets[] | select(.name == "GH_PAT")'
```

## Phase 5: Custom Properties (Optional)

### 5.1 Organization-Level Configuration

For each custom property:
- [ ] Property `________________` created at org level
- [ ] Type configured: `________________`
- [ ] Description added: `________________`
- [ ] Default value (if any): `________________`

**Verify:**
```bash
gh api "orgs/{ORG}/properties/schema" --jq '.[] | {name: .property_name, type: .value_type}'
```

### 5.2 Workflow Configuration

- [ ] Workflow inputs added for custom properties
- [ ] Setup job outputs configured
- [ ] Custom properties step uncommented in workflow
- [ ] `VALUE` environment variable configured

**Verify:**
Check `.github/workflows/migrate.yml` for:
- Input definitions under `workflow_dispatch.inputs`
- Output definitions in setup job
- Uncommented custom properties step

## Phase 6: Test Migration

### 6.1 Test Repository Selection

- [ ] Test repository identified: `________________`
- [ ] Small size (< 100 MB)
- [ ] Non-critical content

### 6.2 Workflow Execution

- [ ] Workflow triggered manually
- [ ] Parameters filled correctly
- [ ] Workflow started successfully

**Verify:**
```bash
# List recent workflow runs
gh run list --workflow=migrate.yml --limit 5
```

### 6.3 Workflow Completion

- [ ] All jobs completed successfully
- [ ] No errors in logs
- [ ] Repository created in GitHub
- [ ] Teams created with correct naming
- [ ] Content migrated (if applicable)

**Verify:**
```bash
# Check workflow run status
gh run view {RUN_ID}

# Check repository exists
gh repo view {ORG}/{NEW-REPO}

# Check teams created
gh api "orgs/{ORG}/teams" --jq '.[] | select(.name | startswith("tis-{provider}")) | .name'
```

### 6.4 Repository Validation

- [ ] Repository visibility correct (private/internal)
- [ ] Branch protection configured
- [ ] Team permissions correct
- [ ] Git history preserved (if migrated)

**Verify:**
```bash
# Check repository details
gh repo view {ORG}/{NEW-REPO} --json visibility,defaultBranchRef,isPrivate

# Check branch protection
gh api "repos/{ORG}/{NEW-REPO}/branches/{default-branch}/protection"

# Check team permissions
gh api "repos/{ORG}/{NEW-REPO}/teams"
```

## Phase 7: Production Readiness

### 7.1 Configuration Review

- [ ] All required secrets configured
- [ ] All required variables configured
- [ ] Source systems tested and working
- [ ] Test migration successful
- [ ] No placeholder strings remain

**Verify:**
```bash
# Run completeness check
./.github/skills/template-onboarding/scripts/Test-SetupCompleteness.ps1

# Run readiness check
./.github/skills/template-onboarding/scripts/Confirm-ProductionReadiness.ps1
```

### 7.2 Documentation Review

- [ ] README reviewed and understood
- [ ] SETUP.md reviewed (if exists)
- [ ] Issue template reviewed
- [ ] Workflow understood

### 7.3 Team Readiness

- [ ] Administrators identified
- [ ] Users aware of migration process
- [ ] Support plan established
- [ ] Communication plan ready

## Phase 8: Production Finalization

### 8.1 Pre-Finalization

- [ ] All previous phases complete
- [ ] No outstanding issues
- [ ] User explicitly confirmed readiness

### 8.2 Finalization Steps

- [ ] SETUP.md created for administrators
- [ ] README restructured for end-users
- [ ] Organization placeholders replaced
- [ ] Template documentation archived
- [ ] Repository settings updated

**Verify:**
```bash
# Check for SETUP.md
test -f SETUP.md && echo "✅ SETUP.md exists"

# Check for placeholders
grep -r "htekdev\|{YOUR-ORG}\|{YOUR-REPO}" README.md .github/ || echo "✅ No placeholders found"

# Check archive
test -d docs/archive && echo "✅ Archive directory exists"
```

### 8.3 Post-Finalization

- [ ] README focused on end-user tasks
- [ ] Setup documentation moved to SETUP.md
- [ ] Repository description updated
- [ ] Repository topics added
- [ ] Announcement prepared

## Continuous Validation

### Monthly Checks

- [ ] Review migration success rate
- [ ] Check workflow execution times
- [ ] Review error logs
- [ ] Update documentation based on feedback

### Quarterly Checks

- [ ] Rotate GitHub App credentials
- [ ] Rotate source system credentials
- [ ] Review team permissions
- [ ] Audit security settings
- [ ] Update dependencies

### As-Needed Checks

- [ ] Add new source systems when required
- [ ] Update workflows for GitHub Actions changes
- [ ] Address feature requests
- [ ] Troubleshoot issues

## Troubleshooting Reference

### Common Issues

**Issue:** GitHub CLI authentication fails
```bash
# Re-authenticate
gh auth login

# Check authentication
gh auth status
```

**Issue:** Cannot access secrets/variables
```bash
# Ensure you have admin access to the repository
gh api "repos/{ORG}/{REPO}" --jq '.permissions'
```

**Issue:** Workflow fails with "Resource not accessible"
- Check GitHub App installation
- Verify app permissions
- Ensure app is installed to correct repositories

**Issue:** Test migration fails
- Check workflow logs for specific error
- Verify source system credentials
- Confirm source URL format
- Check GitHub App token generation

## Summary

Use this checklist to ensure complete and correct setup of the migration framework. Each phase builds on the previous one, so complete them in order. Run the verification commands to confirm each step is properly configured.

For detailed troubleshooting, see `troubleshooting.md`.
