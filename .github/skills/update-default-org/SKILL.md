---
name: update-default-org
description: Guide for updating all default organization references when using the migration framework as a template repository. Use this skill when setting up the migration framework in a new organization or troubleshooting organization-specific configuration issues.
---

# Update Default Organization

## Overview

This skill provides step-by-step instructions for updating all references to the default organization ({{DEFAULT ORG}}) throughout the migration framework when using it as a template repository. This is essential when deploying the framework to a different GitHub organization.

## When to Use This Skill

Use this skill when:
- Setting up the migration framework in a new organization
- Converting the repository from a template to an active framework
- Troubleshooting organization-specific configuration issues
- Migrating the framework from one organization to another
- Customizing the framework for organization-specific requirements

## Why This Is Needed

The migration framework contains numerous references to the default organization in:
- Workflow files (default values, action references)
- PowerShell scripts (URL patterns, default parameters)
- Documentation (examples, URLs)
- Issue templates (organization options)
- Configuration files (validation patterns)

When using this repository as a template, these references must be updated to match your target organization to ensure proper functionality.

## Files That Require Updates

The following files contain organization references that need to be updated:

### 1. GitHub Actions Workflows

#### `.github/workflows/migrate.yml`

**Location 1: Default Organization Variable**
- **Line**: ~223
- **Current**: `if [ -z "$ORG" ]; then ORG="{{DEFAULT ORG}}"; fi`
- **Update to**: Your organization name
- **Purpose**: Sets default organization when not specified in inputs

**Location 2: Branch Protection Bypass Action**
- **Line**: ~539
- **Current**: `uses: {{DEFAULT ORG}}/es-dop-framework/actions/branch-protection-bypass@main`
- **Update to**: Your organization's framework repository
- **Purpose**: References organization-specific GitHub Actions
- **Note**: Only update if you have a similar action in your organization, otherwise remove or replace with alternative

### 2. PowerShell Scripts

#### `scripts/Parse-Parameters.ps1`

**Default Organization Setting**
- **Line**: ~28
- **Current**: `$org = '{{DEFAULT ORG}}'`
- **Update to**: Your organization name
- **Purpose**: Fallback when organization parameter is empty

#### `scripts/New-ImportRepoDetails.ps1`

**GitHub Internal URL Pattern**
- **Line**: ~117
- **Current**: `if($env:IMPORT_URL -match 'https://github.com/(?<organization>{{DEFAULT ORG}})/(?<repo>.+?)(?:\.git)?$')`
- **Update to**: Your organization name in the regex pattern
- **Purpose**: Detects internal GitHub repository migrations
- **Note**: This pattern identifies repositories within your organization for internal migrations

### 3. Documentation Files

#### `README.md`

**Location 1: Workflow Inputs Table (Core Workflow Inputs)**
- **Line**: ~66
- **Current**: `| \`org\` | Yes | GitHub Organization | \`{{DEFAULT ORG}}\` |`
- **Update to**: Your organization name in the example
- **Purpose**: Documentation example for users

**Location 2: Workflow Inputs Table (Reference Section)**
- **Line**: ~170
- **Current**: `| \`org\` | Yes | GitHub Organization | \`{{DEFAULT ORG}}\` |`
- **Update to**: Your organization name in the example
- **Purpose**: Documentation example for users

#### `.github/skills/add-import-source/SKILL.md`

**GitHub Internal Repository Pattern**
- **Line**: ~45
- **Current**: `- URL pattern: \`https://github.com/{{DEFAULT ORG}}/{repo}\``
- **Update to**: Your organization name
- **Purpose**: Documentation for internal GitHub migrations

#### `.github/copilot-instructions.md`

**Add-MandatedRepoFile Script**
- **Line**: ~90
- **Current**: Script creates meta workflow files with repository metadata
- **Update to**: Review if this functionality is needed for your organization
- **Purpose**: Copilot agent instructions
- **Note**: The meta workflow integration is optional and may not be needed

### 4. Issue Templates

#### `.github/ISSUE_TEMPLATE/migration-request.yml`

**Organization Options**
- **Line**: ~27-28
- **Current**: 
  ```yaml
  options:
    - {{DEFAULT ORG}}
  ```
- **Update to**: 
  ```yaml
  options:
    - YourOrganization
    - YourArchiveOrganization  # Optional: if you have multiple orgs
  ```
- **Purpose**: Dropdown options for users requesting migrations
- **Note**: Add all organizations where users might create repositories

### 5. Comment Examples in Scripts

#### `scripts/Execute-GitImport.ps1`

**Example URLs in Comments**
- **Lines**: ~161, 177, 179, 181
- **Current**: Contains example URLs with `{{DEFAULT ORG}}`
- **Update to**: Your organization name
- **Purpose**: Example output in comments for reference
- **Note**: These are comments documenting example error messages; update for clarity

## Step-by-Step Update Process

### Step 1: Use as Template or Clone

**Option A: GitHub Template (Recommended)**
1. Navigate to the repository
2. Click "Use this template" → "Create a new repository"
3. Choose your organization and repository name
4. Clone your new repository locally

**Option B: Manual Clone**
1. Clone the original repository
2. Remove existing git history: `Remove-Item -Recurse -Force .git`
3. Initialize new repository: `git init`
4. Create new remote in your organization

### Step 2: Identify Your Organization Names

Document your organization information:

```powershell
# Primary organization for active repositories
$PrimaryOrg = "YourOrgName"

# Optional: Archive organization for legacy repositories
$ArchiveOrg = "YourArchiveOrg"

# Optional: Organization hosting shared workflows/actions
$FrameworkOrg = "YourFrameworkOrg"
```

### Step 3: Perform Global Search and Replace

Use a PowerShell script to update all files:

```powershell
# Navigate to repository root
cd c:\path\to\your\repo

# Define organization names
$defaultOrg = "YourOrgName"

# Find all files with {{DEFAULT ORG}} placeholder
$files = Get-ChildItem -Recurse -File | Where-Object { 
    $_.Extension -in @('.yml', '.yaml', '.md', '.ps1') 
}

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match '\{\{DEFAULT ORG\}\}') {
        $newContent = $content -replace '\{\{DEFAULT ORG\}\}', $defaultOrg
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}
```

### Step 4: Update Organization-Specific Actions

Review and update action references:

#### Branch Protection Bypass Action

**Current:**
```yaml
uses: {{DEFAULT ORG}}/es-dop-framework/actions/branch-protection-bypass@main
```

**Options:**

1. **If you have a similar action in your organization:**
   ```yaml
   uses: YourOrg/your-framework/actions/branch-protection-bypass@main
   ```

2. **If you don't have this action:**
   - **Option A**: Create the action in your organization
   - **Option B**: Remove the step and handle branch protection manually
   - **Option C**: Use a third-party action or GitHub's native API

### Step 6: Update Issue Template Organization Options

Edit `.github/ISSUE_TEMPLATE/migration-request.yml`:

**Single Organization:**
```yaml
- type: dropdown
  id: org
  attributes:
    label: GitHub Organization
    description: Select the target GitHub organization
    options:
      - YourOrgName
    default: 0
  validations:
    required: true
```

**Multiple Organizations:**
```yaml
- type: dropdown
  id: org
  attributes:
    label: GitHub Organization
    description: Select the target GitHub organization
    options:
      - YourPrimaryOrg
      - YourArchiveOrg
      - YourSandboxOrg
    default: 0
  validations:
    required: true
```

### Step 7: Update Import Source Detection

In `scripts/New-ImportRepoDetails.ps1`, update the regex pattern:

**Before:**
```powershell
if($env:IMPORT_URL -match 'https://github.com/(?<organization>{{DEFAULT ORG}})/(?<repo>.+?)(?:\.git)?$'){
```

**After:**
```powershell
if($env:IMPORT_URL -match 'https://github.com/(?<organization>YourOrgName)/(?<repo>.+?)(?:\.git)?$'){
```

**Important**: This pattern identifies repositories within your organization as "internal" migrations, which:
- Use the existing GitHub App authentication
- Skip external PAT authentication
- May have different handling for teams and permissions

### Step 8: Update Documentation Examples

Update all documentation to reference your organization:

```powershell
# Find and list all documentation files
Get-ChildItem -Recurse -Include *.md | ForEach-Object {
    Write-Host $_.FullName
}

# Review each file and update examples to match your organization
```

Common documentation updates:
- Repository URLs in examples
- Organization names in screenshots (consider retaking screenshots)
- Team name examples that might include organization-specific prefixes
- Workflow run examples

### Step 9: Verify Updates

Run comprehensive verification:

```powershell
# Search for any remaining {{DEFAULT ORG}} placeholders
Get-ChildItem -Recurse -File | Select-String -Pattern '\{\{DEFAULT ORG\}\}' | Format-Table Path, LineNumber, Line -AutoSize

# Search for old organization references (if migrating from existing org)
Get-ChildItem -Recurse -File | Select-String -Pattern 'OldOrgName' | Format-Table Path, LineNumber, Line -AutoSize

# Verify workflow syntax
# Use GitHub Actions validator or commit to see workflow validation
```

### Step 10: Test the Framework

Perform end-to-end testing:

1. **Test Issue Template:**
   - Create a new issue using the migration template
   - Verify organization dropdown shows correct options
   - Check that all fields render correctly

2. **Test Workflow Trigger:**
   - Trigger the workflow manually with test inputs
   - Monitor workflow execution in Actions tab
   - Verify organization parameter is correctly processed

3. **Test Internal Repository Migration:**
   - Create a test repository in your organization
   - Trigger migration with internal repository URL
   - Verify it's detected as internal source

4. **Test External Source Migration:**
   - Test with an ADO, BitBucket, or external GitHub URL
   - Verify authentication and cloning work correctly
   - Check team creation and permissions

5. **Verify Created Resources:**
   - Check that teams are created with correct names
   - Verify repository permissions are set properly
   - Confirm repository visibility matches criticality

## Organization-Specific Customizations

Beyond updating the default organization, consider these customizations:

### Team Name Conventions

If your organization uses different team naming conventions:

**Default Pattern:**
```
{team-name}
{team-name}-admins
```

**Custom Pattern Example:**
```
{department}-{team-name}
{department}-{team-name}-admins
```

Update in:
- `scripts/Parse-Parameters.ps1` - Team name construction logic
- `.github/workflows/migrate.yml` - Team creation steps
- Documentation and examples

### Repository Naming Conventions

If your organization has specific repository naming requirements:

**Update validation in `.github/workflows/migrate.yml`:**
```yaml
# Current pattern: lowercase-with-hyphens
# Update regex to match your convention
```

**Update in:**
- Workflow input validation
- PowerShell script validation
- Documentation examples

### Custom Properties

If your organization tracks different metadata:

Use the `@custom-properties` Copilot agent to add organization-specific properties:
```
@custom-properties add cost_center property for finance tracking
@custom-properties add department property for organizational structure
@custom-properties add compliance_level property for regulatory requirements
```

### Criticality Levels

If your organization uses different criticality classifications:

**Current Options:**
- `critical` - Private repository
- `non-critical` - Internal repository

**Custom Options Example:**
- `high` - Private, strict access controls
- `medium` - Internal, standard controls
- `low` - Internal, relaxed controls
- `public` - Public repository

Update in:
- Issue template dropdown options
- Workflow input validation
- Permission assignment logic in scripts

## Advanced: Organization Detection

For organizations managing multiple tenants, implement automatic organization detection:

### Option 1: Repository-Based Detection

```powershell
# In scripts/Parse-Parameters.ps1
# Detect organization from repository location
$repoFullName = $env:GITHUB_REPOSITORY
$detectedOrg = $repoFullName.Split('/')[0]

if([String]::IsNullOrEmpty($env:ORG)){
    $org = $detectedOrg
    Write-Output "Organization auto-detected: $org"
}
```

### Option 2: Team-Based Detection

```powershell
# Infer organization from team name prefix
if($teamName -match '^(?<org>[a-z]+)-'){
    $org = $Matches['org']
    Write-Output "Organization inferred from team name: $org"
}
```

### Option 3: Configuration File

Create a configuration file:

```json
// .github/config.json
{
  "defaultOrganization": "YourOrgName",
  "archiveOrganization": "YourArchiveOrg",
  "frameworkOrganization": "YourFrameworkOrg",
  "organizationMapping": {
    "prod": "YourOrgName",
    "archive": "YourArchiveOrg"
  }
}
```

Load in scripts:
```powershell
$config = Get-Content .github/config.json | ConvertFrom-Json
$org = $config.defaultOrganization
```

## Troubleshooting

### Issue: Workflow Fails with "Organization Not Found"

**Cause**: Organization name mismatch or typo

**Solutions**:
1. Verify organization name spelling (case-sensitive)
2. Check GitHub App installation in correct organization
3. Verify secrets are configured at correct organization level
4. Review workflow logs for exact organization being used

### Issue: Teams Created in Wrong Organization

**Cause**: Default organization not updated in scripts

**Solutions**:
1. Verify `Parse-Parameters.ps1` has correct default organization
2. Check workflow environment variable `GH_ORG` is set correctly
3. Review team API calls in scripts for hardcoded organization

### Issue: Internal Repository Migration Not Detected

**Cause**: Import source regex pattern not updated

**Solutions**:
1. Update regex in `New-ImportRepoDetails.ps1`
2. Verify organization name in URL matches exactly
3. Test regex pattern: `"https://github.com/YourOrg/repo" -match 'pattern'`
4. Check for URL encoding issues in organization name

### Issue: Action Reference Not Found

**Cause**: Referenced action doesn't exist in your organization

**Solutions**:
1. Create the action in your organization
2. Replace with equivalent public action
3. Remove the step if not needed
4. Fork the action repository to your organization

### Issue: Custom Workflow Integration Not Found

**Cause**: Custom workflow repository doesn't exist in your organization

**Solutions**:
1. Create custom workflow repository if needed for your organization
2. Use custom properties as alternative (see `@custom-properties` agent)
3. Use GitHub Topics for categorization
4. Implement simplified metadata tracking with repository variables

## Validation Checklist

Use this checklist to ensure all updates are complete:

- [ ] All `{{DEFAULT ORG}}` placeholders replaced
- [ ] Workflow files updated with correct organization
- [ ] PowerShell scripts updated with correct default organization
- [ ] Issue template organization options updated
- [ ] Documentation examples updated
- [ ] Import source regex patterns updated
- [ ] Action references updated or removed
- [ ] No hardcoded references to previous organization
- [ ] Issue template renders correctly
- [ ] Workflow syntax validates successfully
- [ ] Test migration completes successfully
- [ ] Teams created with correct names
- [ ] Repository permissions set correctly
- [ ] Repository created in correct organization
- [ ] Documentation updated with correct examples

## Best Practices

1. **Use Version Control**: Commit changes incrementally to track updates
2. **Test Thoroughly**: Run end-to-end tests before deploying to production
3. **Document Custom Changes**: Maintain a CUSTOMIZATIONS.md file documenting organization-specific modifications
4. **Use Configuration Files**: Centralize organization-specific values in configuration files
5. **Automate Validation**: Create scripts to validate organization references
6. **Keep Template Updated**: Periodically sync with upstream template for improvements
7. **Review Before Merging**: Have another team member review organization-specific changes
8. **Tag Releases**: Use git tags to mark stable versions after updates

## Related Files

- `.github/workflows/migrate.yml` - Main workflow orchestration
- `scripts/Parse-Parameters.ps1` - Parameter parsing and defaults
- `scripts/New-ImportRepoDetails.ps1` - Import source detection
- `.github/ISSUE_TEMPLATE/migration-request.yml` - User issue template
- `README.md` - Main documentation
- `.github/copilot-instructions.md` - Copilot agent instructions
- `.github/skills/add-import-source/SKILL.md` - Import source skill

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Organizations Documentation](https://docs.github.com/en/organizations)
- [GitHub Apps Documentation](https://docs.github.com/en/apps)
- [GitHub Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Template Repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository)
