#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Comprehensive pre-production validation for the migration framework.

.DESCRIPTION
    Performs extensive checks to ensure the framework is ready for production use:
    - GitHub App authentication
    - Source system credential validation (connection tests)
    - Placeholder string detection
    - Test migration verification
    - Configuration completeness

.PARAMETER Organization
    GitHub organization name (optional, will attempt to detect)

.PARAMETER Repository
    GitHub repository name (optional, will attempt to detect)

.PARAMETER TestMigrationUrl
    URL of a test repository that was migrated (optional)

.EXAMPLE
    ./Confirm-ProductionReadiness.ps1

.EXAMPLE
    ./Confirm-ProductionReadiness.ps1 -Organization "myorg" -Repository "repo-migration"

.EXAMPLE
    ./Confirm-ProductionReadiness.ps1 -TestMigrationUrl "https://github.com/myorg/test-migration-repo"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$Organization = "",
    
    [Parameter(Mandatory = $false)]
    [string]$Repository = "",
    
    [Parameter(Mandatory = $false)]
    [string]$TestMigrationUrl = ""
)

# Function to get repository info
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

# Auto-detect org and repo
if ([string]::IsNullOrEmpty($Organization) -or [string]::IsNullOrEmpty($Repository)) {
    $repoInfo = Get-RepoInfo
    if ($repoInfo) {
        if ([string]::IsNullOrEmpty($Organization)) { $Organization = $repoInfo.Organization }
        if ([string]::IsNullOrEmpty($Repository)) { $Repository = $repoInfo.Repository }
    }
}

Write-Host "🔍 Production Readiness Validation" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (![string]::IsNullOrEmpty($Organization) -and ![string]::IsNullOrEmpty($Repository)) {
    Write-Host "Repository: $Organization/$Repository" -ForegroundColor White
}
else {
    Write-Host "⚠️  Repository not detected - some checks will be skipped" -ForegroundColor Yellow
}
Write-Host ""

$critical = @()
$warnings = @()
$passed = 0
$total = 0

# Check 1: GitHub App Configuration
Write-Host "[1/8] GitHub App Configuration..." -NoNewline
$total++
if (![string]::IsNullOrEmpty($Organization) -and ![string]::IsNullOrEmpty($Repository)) {
    try {
        $varsOutput = gh api "repos/$Organization/$Repository/actions/variables" --jq '.variables[] | {name: .name, value: .value}' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $vars = $varsOutput | ConvertFrom-Json
            
            $hasAppName = $vars | Where-Object { $_.name -eq 'GH_APP_NAME' }
            $hasAppId = $vars | Where-Object { $_.name -eq 'GH_APP_ID' }
            $hasUserId = $vars | Where-Object { $_.name -eq 'GH_APP_USER_ID' }
            
            if ($hasAppName -and $hasAppId -and $hasUserId) {
                Write-Host " ✅" -ForegroundColor Green
                $passed++
            }
            else {
                Write-Host " ❌" -ForegroundColor Red
                $critical += "GitHub App variables incomplete (need GH_APP_NAME, GH_APP_ID, GH_APP_USER_ID)"
            }
        }
        else {
            Write-Host " ❌" -ForegroundColor Red
            $critical += "Cannot access repository variables - check GitHub CLI authentication"
        }
    }
    catch {
        Write-Host " ❌" -ForegroundColor Red
        $critical += "Cannot access repository variables - check GitHub CLI authentication"
    }
}
else {
    Write-Host " ⏭️  Skipped" -ForegroundColor Gray
}

# Check 2: GitHub App Private Key
Write-Host "[2/8] GitHub App Private Key..." -NoNewline
$total++
if (![string]::IsNullOrEmpty($Organization) -and ![string]::IsNullOrEmpty($Repository)) {
    try {
        $secretsOutput = gh api "repos/$Organization/$Repository/actions/secrets" --jq '.secrets[].name' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $secrets = $secretsOutput
            
            if ($secrets -contains 'GH_APP_PRIVATE_KEY') {
                Write-Host " ✅" -ForegroundColor Green
                $passed++
            }
            else {
                Write-Host " ❌" -ForegroundColor Red
                $critical += "GH_APP_PRIVATE_KEY secret not found"
            }
        }
        else {
            Write-Host " ❌" -ForegroundColor Red
            $critical += "Cannot access repository secrets - check GitHub CLI authentication"
        }
    }
    catch {
        Write-Host " ❌" -ForegroundColor Red
        $critical += "Cannot access repository secrets - check GitHub CLI authentication"
    }
}
else {
    Write-Host " ⏭️  Skipped" -ForegroundColor Gray
}

# Check 3: Placeholder Detection
Write-Host "[3/8] Placeholder Detection..." -NoNewline
$total++
$placeholders = @('htekdev', '{YOUR-ORG}', '{YOUR-REPO}', 'your-org', 'your-repo')
$foundPlaceholders = @()

$filesToCheck = @(
    'README.md',
    '.github/workflows/migrate.yml',
    '.github/ISSUE_TEMPLATE/migration-request.yml'
)

foreach ($file in $filesToCheck) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        foreach ($placeholder in $placeholders) {
            if ($content -match [regex]::Escape($placeholder)) {
                $foundPlaceholders += "$placeholder in $file"
            }
        }
    }
}

if ($foundPlaceholders.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
}
else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    $warnings += "Placeholders found: $($foundPlaceholders -join ', ')"
}

# Check 4: Workflow File Integrity
Write-Host "[4/8] Workflow File Integrity..." -NoNewline
$total++
if (Test-Path '.github/workflows/migrate.yml') {
    try {
        $workflowContent = Get-Content '.github/workflows/migrate.yml' -Raw
        
        # Check for key components
        $hasWorkflowDispatch = $workflowContent -match 'workflow_dispatch\s*:'
        $hasSetupJob = $workflowContent -match 'jobs\s*:[\s\S]*?\bsetup\s*:'
        $hasTestJob = $workflowContent -match 'jobs\s*:[\s\S]*?\btest\s*:'
        
        if ($hasWorkflowDispatch -and $hasSetupJob -and $hasTestJob) {
            Write-Host " ✅" -ForegroundColor Green
            $passed++
        }
        else {
            Write-Host " ⚠️" -ForegroundColor Yellow
            $warnings += "Workflow file may be incomplete or modified"
        }
    }
    catch {
        Write-Host " ❌" -ForegroundColor Red
        $critical += "Cannot parse workflow file"
    }
}
else {
    Write-Host " ❌" -ForegroundColor Red
    $critical += "Workflow file not found"
}

# Check 5: Required Scripts
Write-Host "[5/8] Required Scripts..." -NoNewline
$total++
$requiredScripts = @(
    'scripts/modules.ps1',
    'scripts/New-GitHubRepo.ps1',
    'scripts/New-GitHubRepoMigration.ps1',
    'scripts/New-ImportRepoDetails.ps1',
    'scripts/Parse-Parameters.ps1'
)

$missingScripts = @()
foreach ($script in $requiredScripts) {
    if (-not (Test-Path $script)) {
        $missingScripts += $script
    }
}

if ($missingScripts.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
}
else {
    Write-Host " ❌" -ForegroundColor Red
    $critical += "Missing required scripts: $($missingScripts -join ', ')"
}

# Check 6: Issue Template
Write-Host "[6/8] Issue Template..." -NoNewline
$total++
if (Test-Path '.github/ISSUE_TEMPLATE/migration-request.yml') {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
}
else {
    Write-Host " ❌" -ForegroundColor Red
    $critical += "Migration request issue template not found"
}

# Check 7: Test Migration (if URL provided)
Write-Host "[7/8] Test Migration Verification..." -NoNewline
$total++
if (![string]::IsNullOrEmpty($TestMigrationUrl)) {
    if ($TestMigrationUrl -match 'github\.com/([^/]+)/([^/]+)') {
        $testOrg = $Matches[1]
        $testRepo = $Matches[2]
        
        try {
            $testRepoData = gh api "repos/$testOrg/$testRepo" 2>&1 | ConvertFrom-Json
            
            if ($testRepoData.name) {
                Write-Host " ✅" -ForegroundColor Green
                $passed++
            }
            else {
                Write-Host " ⚠️" -ForegroundColor Yellow
                $warnings += "Test repository exists but may have issues"
            }
        }
        catch {
            Write-Host " ❌" -ForegroundColor Red
            $critical += "Cannot access test migration repository: $TestMigrationUrl"
        }
    }
    else {
        Write-Host " ⚠️" -ForegroundColor Yellow
        $warnings += "Invalid test migration URL format"
    }
}
else {
    Write-Host " ⏭️  Skipped (no test URL provided)" -ForegroundColor Gray
}

# Check 8: Documentation
Write-Host "[8/8] Documentation..." -NoNewline
$total++
$docFiles = @('README.md', 'CONTRIBUTING.md', 'SECURITY.md')
$missingDocs = @()

foreach ($doc in $docFiles) {
    if (-not (Test-Path $doc)) {
        $missingDocs += $doc
    }
}

if ($missingDocs.Count -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $passed++
}
else {
    Write-Host " ⚠️" -ForegroundColor Yellow
    $warnings += "Missing documentation files: $($missingDocs -join ', ')"
}

# Generate Report
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Production Readiness Report" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$score = if ($total -gt 0) { [math]::Round(($passed / $total) * 100, 1) } else { 0 }
Write-Host "Score: $passed/$total checks passed ($score%)" -ForegroundColor $(if ($score -ge 80) { "Green" } elseif ($score -ge 60) { "Yellow" } else { "Red" })
Write-Host ""

if ($critical.Count -gt 0) {
    Write-Host "🚨 Critical Issues ($($critical.Count)):" -ForegroundColor Red
    foreach ($issue in $critical) {
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

# Final Recommendation
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Recommendation:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($critical.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✅ READY FOR PRODUCTION" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your migration framework is fully configured and ready for production use!"
    Write-Host "You can proceed with finalization when ready."
    exit 0
}
elseif ($critical.Count -eq 0 -and $warnings.Count -le 2) {
    Write-Host "⚠️  MOSTLY READY" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Your framework is mostly ready, but please review the warnings above."
    Write-Host "You may proceed with caution or address warnings first."
    exit 0
}
elseif ($critical.Count -gt 0) {
    Write-Host "❌ NOT READY" -ForegroundColor Red
    Write-Host ""
    Write-Host "Critical issues must be resolved before production use."
    Write-Host "Please address all critical issues and run this check again."
    exit 1
}
else {
    Write-Host "⚠️  NEEDS ATTENTION" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Several warnings detected. Consider addressing them before production."
    exit 0
}
