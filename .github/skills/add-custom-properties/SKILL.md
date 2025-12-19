---
name: add-custom-properties
description: Guide for adding custom repository properties to migrated GitHub repositories. Use this skill when asked to enable custom property functionality, add new custom properties, or update the migration workflow to support custom repository metadata.
---

# Add Custom Properties

## Overview

This skill guides you through enabling and configuring custom repository properties in the migration workflow. Custom properties allow storing repository metadata (like app_id, category, business unit, team name, owner, and criticality) as structured data in GitHub.

## When to Use This Skill

Use this skill when:
- Asked to enable custom properties support in the migration workflow
- Need to add new custom properties to the migration process
- Required to modify existing custom property configurations
- Troubleshooting custom property issues in migrated repositories

## Current Implementation

The migration framework has a **disabled** custom properties step in the workflow. The implementation exists in:

- **Script**: `scripts/Add-CustomProperties.ps1`
- **Workflow**: `.github/workflows/migrate.yml` (commented out section)

### Current Script Features

The `Add-CustomProperties.ps1` script accepts:
- `githubRepoUrl`: The target repository URL
- `value`: Multi-line string of property assignments in format `property_name=value`

Example value format:
```
app_id=my-app-123
category=application
business_unit=technology
team=platform-engineering
owner=john-doe
criticality=high
```

## Enabling Custom Properties

### Step 1: Identify Required Properties

First, determine which custom properties are needed. Common properties include:
- `app_id` - Application identifier
- `category` - Repository category (app, library, infrastructure, etc.)
- `business_unit` - Organizational business unit
- `team` - Responsible team name
- `owner` - Primary owner/contact
- `criticality` - Criticality level (critical, high, medium, low)

### Step 2: Update Workflow Inputs

Add workflow inputs in `.github/workflows/migrate.yml` under the `workflow_dispatch.inputs` section:

```yaml
app-id:
  description: 'Application ID for custom properties'
  required: false
  type: string
  default: ''

category:
  description: 'Repository category (app, library, infrastructure, etc.)'
  required: false
  type: string
  default: 'app'

# Add other properties as needed
```

For issue-triggered migrations, update the issue template at `.github/ISSUE_TEMPLATE/migration-request.yml`.

### Step 3: Pass Parameters Through Setup Job

In the `setup` job's outputs, add your custom property fields:

```yaml
outputs:
  # existing outputs...
  app-id: ${{ steps.set-values-dispatch.outputs.app-id || steps.extract-values.outputs.app-id }}
  category: ${{ steps.set-values-dispatch.outputs.category || steps.extract-values.outputs.category }}
  # Add other properties...
```

Update both `set-values-dispatch` and `extract-values` steps to handle these parameters.

### Step 4: Uncomment and Configure the Workflow Step

In `.github/workflows/migrate.yml`, locate the commented custom properties step (around line 620-640):

```yaml
# - name: ✏️ Add Custom Properties
#   continue-on-error: true
#   env:
#     # ... existing env vars ...
#     VALUE: |
#       # Add your custom properties here in the format:
#       # property_name=value
```

Uncomment this section and configure the `VALUE` environment variable:

```yaml
- name: ✏️ Add Custom Properties
  continue-on-error: true
  env:
    GH_APP_CERTIFICATE: ${{ secrets.GH_APP_PRIVATE_KEY }}
    GH_APP_ID: ${{ vars.GH_APP_ID }}
    REPO: https://github.com/${{ env.GH_ORG }}/${{ env.GH_REPO }}
    GIT_NAME: {{APP_NAME}}[bot]
    GIT_EMAIL: {{APP_ID}}+{{APP_NAME}}[bot]@users.noreply.github.com
    VALUE: |
      app_id=${{ needs.setup.outputs.app-id }}
      category=${{ needs.setup.outputs.category }}
      business_unit=${{ needs.setup.outputs.business-unit }}
      team=${{ needs.setup.outputs.team-name }}
      owner=${{ needs.setup.outputs.deliverable-owner }}
      criticality=${{ needs.setup.outputs.criticality }}
  run: |
    & "${{github.workspace}}/scripts/Add-CustomProperties.ps1" -githubRepoUrl $($env:REPO) -value $($env:VALUE)
```

### Step 5: Configure GitHub Organization Custom Properties

Before custom properties work, they must be defined at the organization level:

1. Go to GitHub Organization Settings → Custom Properties
2. Create each property with appropriate configuration:
   - Property name (matches your script)
   - Description
   - Default value (if applicable)
   - Required/Optional setting
   - Allowed repositories (all or specific)

### Step 6: Test the Implementation

1. Run a test migration with the custom properties enabled
2. Verify properties are set correctly by:
   - Checking repository settings → Custom Properties
   - Using GitHub API: `gh api repos/{org}/{repo}/properties/values`
3. Review the job summary for success/failure indicators

## Modifying the Add-CustomProperties Script

If you need to enhance the script functionality:

### Adding Validation

Add validation logic before setting properties:

```powershell
# Validate required properties
$requiredProperties = @('app_id', 'category', 'team')
$valuesMatch = $valuesRegex.Matches($values)
$providedProperties = $valuesMatch | % { $_.Groups['property_name'].Value }

$missing = $requiredProperties | ? { $_ -notin $providedProperties }
if($missing.Count -gt 0){
  throw "Missing required properties: $($missing -join ', ')"
}
```

### Supporting Different Property Types

GitHub supports different property types (string, single_select, multi_select, true_false). Modify the payload structure:

```powershell
$payload = @{
  properties = @($items | % {
    $parts = $_.Split("=")
    $name = $parts[0].Trim()
    $value = $parts[1].Trim()
    
    # Handle different types
    if($value -eq "true" -or $value -eq "false"){
      @{ property_name = $name; value = [bool]::Parse($value) }
    }
    elseif($value -match '^\[.*\]$'){
      @{ property_name = $name; value = ($value -replace '[\[\]]','').Split(',') }
    }
    else{
      @{ property_name = $name; value = $value }
    }
  })
}
```

### Adding Conditional Logic

Apply properties based on repository characteristics:

```powershell
# Set criticality based on repo visibility
$repo = Invoke-GitHubApiRoute -Path "repos/$($githubOrg)/$($githubRepo)" -Method Get
if($repo.visibility -eq "private"){
  $properties += @{ property_name = "data_classification"; value = "confidential" }
}
```

## Troubleshooting

### Common Issues

**Properties not showing in repository settings**
- Verify properties are defined at the organization level
- Check that the repository is included in the property's allowed repositories
- Ensure GitHub App has `administration:write` permission

**Script fails with 404 error**
- Confirm the property names match exactly (case-sensitive)
- Verify the organization has custom properties feature enabled
- Check API endpoint is correct: `repos/{org}/{repo}/properties/values`

**Values not updating**
- Use PATCH method (script currently does this)
- Verify the value format matches the property type
- Check for special characters that need escaping

**Permission errors**
- Ensure GitHub App token has proper scopes
- Verify the service account has organization member access
- Check branch protection is bypassed during migration

## Best Practices

1. **Keep properties minimal**: Only add properties that provide genuine value for repository management
2. **Use consistent naming**: Follow kebab-case or snake_case throughout
3. **Document property meanings**: Maintain documentation of what each property represents
4. **Validate inputs**: Always validate property values before setting them
5. **Handle errors gracefully**: Use `continue-on-error: true` to prevent blocking migrations
6. **Test in non-production**: Always test custom property changes in a dev/test environment first
7. **Version control**: Track property schema changes in documentation

## Integration with Other Systems

Custom properties can be queried and used by:
- GitHub Actions workflows (access via API)
- GitHub CLI: `gh api repos/{org}/{repo}/properties/values`
- Third-party tools via GitHub REST API
- Organization-wide reporting and analytics

## Example: Complete Implementation

Here's a complete example of enabling custom properties with full validation:

1. Add to workflow inputs
2. Update setup job to pass parameters
3. Uncomment workflow step with proper configuration
4. Add validation to the PowerShell script
5. Configure organization-level properties
6. Test thoroughly
7. Document the properties and their purposes

## Related Files

- `scripts/Add-CustomProperties.ps1` - Main script
- `.github/workflows/migrate.yml` - Workflow configuration
- `.github/ISSUE_TEMPLATE/migration-request.yml` - Issue template for custom properties
- `scripts/modules.ps1` - GitHub API helper functions

## Security Considerations

- Never expose sensitive data in custom properties
- Avoid storing credentials or API keys
- Be cautious with PII (Personally Identifiable Information)
- Use GitHub's built-in encryption for sensitive repositories
- Consider data retention policies when adding metadata
