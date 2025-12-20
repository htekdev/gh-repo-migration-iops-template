#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Replace organization placeholders with actual values

.DESCRIPTION
    Recursively finds all markdown, YAML, and PowerShell files and replaces:
    - htekdev → actual organization
    - ${{ github.repository }} → org/repo
    - {YOUR-ORG} → actual organization
    - {YOUR-REPO} → actual repository name

.PARAMETER Organization
    The organization name to use for replacements

.PARAMETER Repository
    The repository name to use for replacements

.EXAMPLE
    .\Update-OrganizationPlaceholders.ps1 -Organization myorg -Repository myrepo
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Organization,

    [Parameter(Mandatory=$false)]
    [string]$Repository
)

# If not provided, get from git remote
if ([string]::IsNullOrEmpty($Organization) -or [string]::IsNullOrEmpty($Repository)) {
    Write-Host "Detecting repository information from git remote..." -ForegroundColor Yellow
    $remote = git remote get-url origin
    if($remote -match 'github\.com[:/](?<org>[^/]+)/(?<repo>.+?)(\.git)?$'){
        $Organization = $Matches['org']
        $Repository = $Matches['repo']
    } else {
        Write-Error "Could not detect repository from git remote. Please provide -Organization and -Repository parameters."
        exit 1
    }
}

Write-Host "Replacing placeholders with:" -ForegroundColor Cyan
Write-Host "  Organization: $Organization" -ForegroundColor Cyan
Write-Host "  Repository: $Repository" -ForegroundColor Cyan
Write-Host ""

Write-Host "Searching for files to update..."

# Find ALL relevant files recursively (markdown, yaml, PowerShell scripts)
$files = Get-ChildItem -Recurse -File -Include @('*.md', '*.yml', '*.yaml', '*.ps1') -ErrorAction SilentlyContinue |
         Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|docs\\archive)\\' }

Write-Host "Found $($files.Count) files to check" -ForegroundColor Green
Write-Host ""

$updatedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -ErrorAction Continue
    if (-not $content) { continue }

    $updated = $false
    $changes = @()

    # Replace htekdev with actual org
    if ($content -match '\bhtekdev\b') {
        $content = $content -replace '\bhtekdev\b', $Organization
        $changes += "htekdev → $Organization"
        $updated = $true
    }

    # Replace placeholder badge URLs
    if ($content -match '\$\{\{ github\.repository \}\}') {
        $content = $content -replace '\$\{\{ github\.repository \}\}', "$Organization/$Repository"
        $changes += '${{ github.repository }} → {org}/{repo}'
        $updated = $true
    }

    # Replace {YOUR-ORG} placeholders
    if ($content -match '\{YOUR-ORG\}') {
        $content = $content -replace '\{YOUR-ORG\}', $Organization
        $changes += '{YOUR-ORG} → {org}'
        $updated = $true
    }

    # Replace {YOUR-REPO} placeholders
    if ($content -match '\{YOUR-REPO\}') {
        $content = $content -replace '\{YOUR-REPO\}', $Repository
        $changes += '{YOUR-REPO} → {repo}'
        $updated = $true
    }

    if ($updated) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "✅ Updated: $($file.FullName)" -ForegroundColor Green
        foreach ($change in $changes) {
            Write-Host "   - $change" -ForegroundColor DarkGray
        }
        $updatedCount++
    }
}

Write-Host ""
Write-Host "✅ Placeholder replacement complete!" -ForegroundColor Green
Write-Host "Updated $updatedCount file(s)" -ForegroundColor Cyan
Write-Host "Organization: $Organization" -ForegroundColor Cyan
Write-Host "Repository: $Repository" -ForegroundColor Cyan
