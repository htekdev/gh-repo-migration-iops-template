#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verify all placeholders have been removed

.DESCRIPTION
    Searches for common placeholders that should be replaced before
    production deployment. Reports any remaining placeholders found.

.EXAMPLE
    .\Test-PlaceholderRemoval.ps1
#>

Write-Host "=== Checking for Remaining Placeholders ===" -ForegroundColor Cyan
Write-Host ""

$placeholders = @(
    'htekdev',
    '\{\{DEFAULT ORG\}\}',
    '\$\{\{ github\.repository \}\}',
    '\{YOUR-ORG\}',
    '\{YOUR-REPO\}'
)

$foundIssues = $false

foreach ($pattern in $placeholders) {
    Write-Host "Checking for: $pattern" -ForegroundColor Yellow

    $isRegex = $pattern -match '\\'
    $results = Get-ChildItem -Recurse -Include *.md,*.yml,*.yaml,*.ps1 -ErrorAction SilentlyContinue |
               Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|docs\\archive|\.github\\skills)\\' } |
               Select-String -Pattern $pattern -SimpleMatch:(-not $isRegex)

    if ($results) {
        Write-Host "  ⚠️  Found in:" -ForegroundColor Red
        $results | ForEach-Object {
            Write-Host "     $($_.Path):$($_.LineNumber)" -ForegroundColor Red
        }
        $foundIssues = $true
    } else {
        Write-Host "  ✅ Not found" -ForegroundColor Green
    }
    Write-Host ""
}

# Verify key files exist
Write-Host "=== Checking Required Files ===" -ForegroundColor Cyan
$requiredFiles = @('README.md', 'SETUP.md', 'docs/archive')
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
        $foundIssues = $true
    }
}

Write-Host ""
if (-not $foundIssues) {
    Write-Host "✅ All checks passed! No placeholders found." -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️  Issues found - please review and fix before proceeding" -ForegroundColor Yellow
    exit 1
}
