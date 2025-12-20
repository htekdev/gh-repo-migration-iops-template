#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validate repository is production-ready

.DESCRIPTION
    Comprehensive validation to ensure the template has been fully
    converted to a production repository. Checks for:
    - Template content removed from README
    - SETUP.md exists
    - No placeholders remain
    - Archive created

.EXAMPLE
    .\Test-ProductionReadiness.ps1
#>

Write-Host "=== Production Readiness Validation ===" -ForegroundColor Cyan
Write-Host ""

# Check for template content
$issues = @()

# 1. Check README focuses on usage
if (Test-Path "README.md") {
    $readme = Get-Content "README.md" -Raw
    if ($readme -match "Step 1: Create Your Repository from This Template") {
        $issues += "README still contains template setup instructions"
    }
    if ($readme -match "## Setup Instructions") {
        $issues += "README contains 'Setup Instructions' section"
    }
    Write-Host "✅ README.md checked" -ForegroundColor Green
} else {
    $issues += "README.md does not exist"
    Write-Host "❌ README.md not found" -ForegroundColor Red
}

# 2. Check SETUP.md exists
if (Test-Path "SETUP.md") {
    $setup = Get-Content "SETUP.md" -Raw
    if ($setup -match "## Initial Setup") {
        Write-Host "✅ SETUP.md exists with setup content" -ForegroundColor Green
    } else {
        $issues += "SETUP.md exists but may be missing setup content"
    }
} else {
    $issues += "SETUP.md does not exist"
    Write-Host "❌ SETUP.md not found" -ForegroundColor Red
}

# 3. Check for placeholders
Write-Host ""
Write-Host "Checking for placeholders..." -ForegroundColor Yellow
$placeholders = @('htekdev', '\{YOUR-ORG\}', '\{YOUR-REPO\}', '\$\{\{ github\.repository \}\}')
$placeholderFound = $false

foreach ($pattern in $placeholders) {
    $isRegex = $pattern -match '\\'
    $results = Get-ChildItem -Recurse -Include *.md -ErrorAction SilentlyContinue |
               Where-Object { $_.FullName -notmatch '\\(\.git|docs\\archive|\.github\\skills)\\' } |
               Select-String -Pattern $pattern -SimpleMatch:(-not $isRegex)

    if ($results) {
        $issues += "Found placeholder '$pattern' in: $($results[0].Path)"
        Write-Host "  ⚠️  Found '$pattern'" -ForegroundColor Red
        $placeholderFound = $true
    }
}

if (-not $placeholderFound) {
    Write-Host "  ✅ No placeholders found in main files" -ForegroundColor Green
}

# 4. Check archive exists
if (Test-Path "docs/archive") {
    $archives = Get-ChildItem "docs/archive/TEMPLATE_README_*.md" -ErrorAction SilentlyContinue
    if ($archives.Count -gt 0) {
        Write-Host "✅ Archive directory exists with $($archives.Count) backup(s)" -ForegroundColor Green
    } else {
        $issues += "Archive directory exists but no backups found"
    }
} else {
    $issues += "Archive directory does not exist"
    Write-Host "❌ docs/archive not found" -ForegroundColor Red
}

# 5. Check .github/workflows files
Write-Host ""
Write-Host "Checking workflow files..." -ForegroundColor Yellow
$workflowFiles = Get-ChildItem ".github/workflows/*.yml" -ErrorAction SilentlyContinue
if ($workflowFiles) {
    $workflowIssues = $false
    foreach ($workflow in $workflowFiles) {
        $content = Get-Content $workflow.FullName -Raw
        if ($content -match 'htekdev') {
            $issues += "Workflow $($workflow.Name) contains 'htekdev'"
            $workflowIssues = $true
        }
    }
    if (-not $workflowIssues) {
        Write-Host "  ✅ Workflow files checked" -ForegroundColor Green
    }
}

# Report results
Write-Host ""
Write-Host "=== Validation Results ===" -ForegroundColor Cyan
Write-Host ""

if ($issues.Count -eq 0) {
    Write-Host "✅ All validation checks passed!" -ForegroundColor Green
    Write-Host "Repository is production-ready." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Update repository description in GitHub settings"
    Write-Host "  2. Add repository topics (migration, github-actions, automation)"
    Write-Host "  3. Disable template repository setting (if enabled)"
    Write-Host "  4. Announce to your organization"
    exit 0
} else {
    Write-Host "❌ Issues found:" -ForegroundColor Red
    $issues | ForEach-Object { Write-Host "   - $_" -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "Please resolve these issues before using in production." -ForegroundColor Yellow
    exit 1
}
