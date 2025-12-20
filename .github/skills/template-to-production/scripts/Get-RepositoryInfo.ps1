#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Get repository organization and name from git remote

.DESCRIPTION
    Extracts the organization and repository name from the git remote URL.
    Returns an object with Organization, Repository, and FullName properties.

.EXAMPLE
    .\Get-RepositoryInfo.ps1

    Organization: myorg
    Repository: myrepo
    Full name: myorg/myrepo
#>

# Get the remote URL
$remote = git remote get-url origin

if($remote -match 'github\.com[:/](?<org>[^/]+)/(?<repo>.+?)(\.git)?$'){
    $org = $Matches['org']
    $repo = $Matches['repo']

    Write-Host "Organization: $org" -ForegroundColor Cyan
    Write-Host "Repository: $repo" -ForegroundColor Cyan
    Write-Host "Full name: $org/$repo" -ForegroundColor Cyan

    # Return object for script usage
    return [PSCustomObject]@{
        Organization = $org
        Repository = $repo
        FullName = "$org/$repo"
    }
} else {
    Write-Error "Could not parse GitHub repository from remote URL: $remote"
    exit 1
}
