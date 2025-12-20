#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Archive original template documentation

.DESCRIPTION
    Creates a timestamped backup of the current README.md before
    converting to production documentation.

.EXAMPLE
    .\Backup-TemplateDocumentation.ps1
#>

# Create docs/archive directory
$archiveDir = "docs/archive"
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

# Archive current README before replacing
$timestamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'
$archivePath = "$archiveDir/TEMPLATE_README_$timestamp.md"

if (Test-Path "README.md") {
    Copy-Item "README.md" $archivePath
    Write-Host "✅ Archived original README to: $archivePath" -ForegroundColor Green
} else {
    Write-Warning "README.md not found - nothing to archive"
}

# List all archives
Write-Host ""
Write-Host "Existing archives:" -ForegroundColor Cyan
Get-ChildItem "$archiveDir/TEMPLATE_README_*.md" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    ForEach-Object {
        Write-Host "  - $($_.Name) ($(Get-Date $_.LastWriteTime -Format 'yyyy-MM-dd HH:mm'))" -ForegroundColor DarkGray
    }
