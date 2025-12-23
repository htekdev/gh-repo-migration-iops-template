#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validate that required setup steps are complete.

.DESCRIPTION
    Checks for the presence of required GitHub App variables and secrets,
    validates workflow configuration, and reports any missing components.
    Does not access secret values, only verifies they exist.

.PARAMETER Organization
    GitHub organization name (optional, will attempt to detect from git remote)

.PARAMETER Repository
    GitHub repository name (optional, will attempt to detect from git remote)

.EXAMPLE
    ./Test-SetupCompleteness.ps1

.EXAMPLE
    ./Test-SetupCompleteness.ps1 -Organization "myorg" -Repository "repo-migration"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Organization = "",
    
    [Parameter(Mandatory = $false)]
    [string]$Repository = ""
)

# Function to get repository info from git remote
function Get-RepoInfo {
    try {
        $remote = git config --get remote.origin.url
        if ($remote -match 'github\.com[:/]([^/]+)/([^/\.]+)') {
            return @{
                Organization = $Matches[1]
                Repository = $Matches[2]
            }
        }
    }
    catch {
        return $null
    }
    return $null
}

# Auto-detect org and repo if not provided
if ([string]::IsNullOrEmpty($Organization) -or [string]::IsNullOrEmpty($Repository)) {
    $repoInfo = Get-RepoInfo
    if ($repoInfo) {
        if ([string]::IsNullOrEmpty($Organization)) { $Organization = $repoInfo.Organization }
        if ([string]::IsNullOrEmpty($Repository)) { $Repository = $repoInfo.Repository }
        Write-Host "📍 Detected repository: $Organization/$Repository"
    }
}

Write-Host "🔍 Checking setup completeness..." -ForegroundColor Cyan
Write-Host ""

$issues = @()
$warnings = @()

# Check 1: GitHub CLI installed
Write-Host "Checking GitHub CLI..." -NoNewline
try {
    $ghCommand = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghCommand) {
        $ghVersion = gh --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
        }
        else {
            Write-Host " ❌" -ForegroundColor Red
            $issues += "GitHub CLI (gh) is installed but not functioning correctly"
        }
    }
    else {
        Write-Host " ❌" -ForegroundColor Red
        $issues += "GitHub CLI (gh) is not installed or not in PATH"
    }
}
catch {
    Write-Host " ❌" -ForegroundColor Red
    $issues += "GitHub CLI (gh) is not installed or not accessible"
}

# Check 2: Repository variables (if org/repo provided)
if (![string]::IsNullOrEmpty($Organization) -and ![string]::IsNullOrEmpty($Repository)) {
    Write-Host "Checking repository variables..." -NoNewline
    
    $requiredVars = @('GH_APP_NAME', 'GH_APP_ID', 'GH_APP_USER_ID')
    $missingVars = @()
    
    try {
        $vars = gh api "repos/$Organization/$Repository/actions/variables" --jq '.variables[].name' 2>&1
        if ($LASTEXITCODE -eq 0) {
            foreach ($varName in $requiredVars) {
                if ($vars -notcontains $varName) {
                    $missingVars += $varName
                }
            }
            
            if ($missingVars.Count -eq 0) {
                Write-Host " ✅" -ForegroundColor Green
            }
            else {
                Write-Host " ❌" -ForegroundColor Red
                $issues += "Missing repository variables: $($missingVars -join ', ')"
            }
        }
        else {
            Write-Host " ⚠️" -ForegroundColor Yellow
            $warnings += "Could not check repository variables (may need authentication)"
        }
    }
    catch {
        Write-Host " ⚠️" -ForegroundColor Yellow
        $warnings += "Could not check repository variables (may need authentication)"
    }
    
    # Check 3: Repository secrets (only check if they exist, not values)
    Write-Host "Checking repository secrets..." -NoNewline
    
    $requiredSecrets = @('GH_APP_PRIVATE_KEY')
    $missingSecrets = @()
    
    try {
        $secrets = gh api "repos/$Organization/$Repository/actions/secrets" --jq '.secrets[].name' 2>&1
        if ($LASTEXITCODE -eq 0) {
            foreach ($secretName in $requiredSecrets) {
                if ($secrets -notcontains $secretName) {
                    $missingSecrets += $secretName
                }
            }
            
            if ($missingSecrets.Count -eq 0) {
                Write-Host " ✅" -ForegroundColor Green
            }
            else {
                Write-Host " ❌" -ForegroundColor Red
                $issues += "Missing repository secrets: $($missingSecrets -join ', ')"
            }
        }
        else {
            Write-Host " ⚠️" -ForegroundColor Yellow
            $warnings += "Could not check repository secrets (may need authentication)"
        }
    }
    catch {
        Write-Host " ⚠️" -ForegroundColor Yellow
        $warnings += "Could not check repository secrets (may need authentication)"
    }
}
else {
    Write-Host "⚠️  Skipping variable/secret checks (organization/repository not specified)" -ForegroundColor Yellow
}

# Check 4: Workflow file exists
Write-Host "Checking workflow file..." -NoNewline
$workflowPath = ".github/workflows/migrate.yml"
if (Test-Path $workflowPath) {
    Write-Host " ✅" -ForegroundColor Green
}
else {
    Write-Host " ❌" -ForegroundColor Red
    $issues += "Workflow file not found at $workflowPath"
}

# Check 5: Scripts directory
Write-Host "Checking scripts directory..." -NoNewline
$scriptsPath = "scripts"
if (Test-Path $scriptsPath) {
    $requiredScripts = @(
        'modules.ps1',
        'New-GitHubRepo.ps1',
        'New-GitHubRepoMigration.ps1',
        'New-ImportRepoDetails.ps1'
    )
    
    $missingScripts = @()
    foreach ($script in $requiredScripts) {
        if (-not (Test-Path "$scriptsPath/$script")) {
            $missingScripts += $script
        }
    }
    
    if ($missingScripts.Count -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    }
    else {
        Write-Host " ⚠️" -ForegroundColor Yellow
        $warnings += "Missing scripts: $($missingScripts -join ', ')"
    }
}
else {
    Write-Host " ❌" -ForegroundColor Red
    $issues += "Scripts directory not found"
}

# Check 6: Issue template
Write-Host "Checking issue template..." -NoNewline
$issueTemplatePath = ".github/ISSUE_TEMPLATE/migration-request.yml"
if (Test-Path $issueTemplatePath) {
    Write-Host " ✅" -ForegroundColor Green
}
else {
    Write-Host " ❌" -ForegroundColor Red
    $issues += "Issue template not found at $issueTemplatePath"
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Setup Completeness Report" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "🎉 All checks passed! Your setup appears complete." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Run a test migration to verify everything works"
    Write-Host "  2. Review the test results"
    Write-Host "  3. Finalize for production when ready"
    exit 0
}

if ($issues.Count -gt 0) {
    Write-Host "❌ Issues Found ($($issues.Count)):" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "   • $issue" -ForegroundColor Red
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠️  Warnings ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   • $warning" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($issues.Count -gt 0) {
    Write-Host "Please address the issues above before proceeding." -ForegroundColor Yellow
    exit 1
}
else {
    Write-Host "Setup appears mostly complete, but verify warnings if any." -ForegroundColor Yellow
    exit 0
}
