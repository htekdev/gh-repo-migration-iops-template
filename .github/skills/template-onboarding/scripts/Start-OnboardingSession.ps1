#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Initialize an onboarding session for the migration framework setup.

.DESCRIPTION
    Creates a session tracking file to record the onboarding progress, configuration choices,
    and key milestones. This helps maintain state across the onboarding process.

.PARAMETER OutputPath
    Path where the session file should be created. Defaults to ./.onboarding/session.json

.EXAMPLE
    ./Start-OnboardingSession.ps1

.EXAMPLE
    ./Start-OnboardingSession.ps1 -OutputPath "./my-session.json"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "./.onboarding/session.json"
)

# Ensure the directory exists
$directory = Split-Path -Parent $OutputPath
if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Write-Host "✅ Created onboarding directory: $directory"
}

# Generate session ID
$sessionId = [Guid]::NewGuid().ToString()

# Create session object
$session = @{
    sessionId = $sessionId
    startTime = (Get-Date).ToString("o")
    phase = "introduction"
    configurationChoices = @{
        sourceSystems = @()
        customPropertiesEnabled = $false
        additionalSources = @()
    }
    completedSteps = @()
    screenshots = @()
    githubApp = @{
        appName = ""
        appId = ""
        appUserId = ""
        configured = $false
    }
    secrets = @{
        ghAppPrivateKey = $false
        adoPat = $false
        bbCredentials = $false
        svnCredentials = $false
        ghPat = $false
    }
    testMigration = @{
        attempted = $false
        successful = $false
        repositoryUrl = ""
        workflowRunUrl = ""
    }
    productionReady = $false
    finalized = $false
}

# Save session file
$session | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputPath -Encoding utf8

Write-Host "🚀 Onboarding session started!"
Write-Host "   Session ID: $sessionId"
Write-Host "   Started at: $($session.startTime)"
Write-Host "   Session file: $OutputPath"
Write-Host ""
Write-Host "Use this session file to track your onboarding progress."
Write-Host "You can resume at any time by referencing this session ID."

# Return session ID for reference
return $sessionId
