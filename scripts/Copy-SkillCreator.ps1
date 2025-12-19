#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Downloads the skill-creator skill from Anthropics skills repository

.DESCRIPTION
    This script downloads all files from the skill-creator skill in the Anthropics skills repository
    and copies them to the .github/skills/skill-creator directory in the current repository.

.EXAMPLE
    ./scripts/Copy-SkillCreator.ps1
#>

param(
    [string]$OutputPath = ".github/skills/skill-creator"
)

# Import modules
. "$($PSScriptRoot)/modules.ps1"

function Copy-SkillCreator {
    param(
        [string]$OutputPath
    )

    Write-Output "[INFO] Downloading skill-creator from Anthropics skills repository..."

    # GitHub API base URL for the skill-creator directory
    $baseUrl = "https://api.github.com/repos/anthropics/skills/contents/skills/skill-creator"

    # Create output directory
    $fullOutputPath = Join-Path (Get-Location) $OutputPath
    if (Test-Path $fullOutputPath) {
        Write-Output "[INFO] Removing existing skill-creator directory..."
        Remove-Item -Path $fullOutputPath -Recurse -Force
    }

    New-Item -Path $fullOutputPath -ItemType Directory -Force | Out-Null
    Write-Output "[INFO] Created directory: $fullOutputPath"

    try {
        # Get the directory contents from GitHub API
        $response = Invoke-RestMethod -Uri $baseUrl -Headers @{
            'User-Agent' = 'PowerShell-Script'
            'Accept' = 'application/vnd.github.v3+json'
        }

        foreach ($item in $response) {
            if ($item.type -eq "file") {
                # Download file
                Write-Output "[INFO] Downloading: $($item.name)"
                $fileContent = Invoke-RestMethod -Uri $item.download_url
                $filePath = Join-Path $fullOutputPath $item.name
                Set-Content -Path $filePath -Value $fileContent -Encoding UTF8
            }
            elseif ($item.type -eq "dir") {
                # Create subdirectory and download its contents
                $subDirPath = Join-Path $fullOutputPath $item.name
                New-Item -Path $subDirPath -ItemType Directory -Force | Out-Null
                Write-Output "[INFO] Created subdirectory: $($item.name)"

                # Get subdirectory contents
                $subResponse = Invoke-RestMethod -Uri $item.url -Headers @{
                    'User-Agent' = 'PowerShell-Script'
                    'Accept' = 'application/vnd.github.v3+json'
                }

                foreach ($subItem in $subResponse) {
                    if ($subItem.type -eq "file") {
                        Write-Output "[INFO] Downloading: $($item.name)/$($subItem.name)"
                        $fileContent = Invoke-RestMethod -Uri $subItem.download_url
                        $filePath = Join-Path $subDirPath $subItem.name
                        Set-Content -Path $filePath -Value $fileContent -Encoding UTF8

                        # Make Python scripts executable if on Unix-like system
                        if ($subItem.name.EndsWith(".py") -and ($IsLinux -or $IsMacOS)) {
                            chmod +x $filePath
                        }
                    }
                }
            }
        }

        Write-Output "[SUCCESS] Successfully downloaded skill-creator to $OutputPath"
        Write-Output ""
        Write-Output "[INFO] Downloaded files:"
        Get-ChildItem -Path $fullOutputPath -Recurse | ForEach-Object {
            $relativePath = $_.FullName.Substring($fullOutputPath.Length + 1)
            Write-Output "   $relativePath"
        }

        Write-Output ""
        Write-Output "[INFO] Next steps:"
        Write-Output "1. Review the skill-creator documentation in $OutputPath/SKILL.md"
        Write-Output "2. Use the scripts to create new skills:"
        Write-Output "   python $OutputPath/scripts/init_skill.py <skill-name> --path .github/skills"
        Write-Output "   python $OutputPath/scripts/package_skill.py .github/skills/<skill-name>"

        return $true
    }
    catch {
        Write-Error "[ERROR] Failed to download skill-creator: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
if (Copy-SkillCreator -OutputPath $OutputPath) {
    Write-Output "| **Download skill-creator** | SUCCESS | Successfully downloaded to $OutputPath |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
    exit 0
} else {
    Write-Output "| **Download skill-creator** | ERROR | Failed to download skill-creator |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
    exit 1
}
