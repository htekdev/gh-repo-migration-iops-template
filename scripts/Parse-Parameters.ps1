Param(
  [string] $githubRepoUrl
)

. "$($PSScriptRoot)/modules.ps1"

# Get environment variables - updated to match current workflow patterns
$criticality = $env:CRITICALITY
$org = $env:ORG
$deliverableOwner = $env:DELIVERABLE_OWNER  # Team identifier
$deliverableProvider = $env:DELIVERABLE_PROVIDER  # Business unit (lp, gtm, gds, etc.)
$deliverable = $env:DELIVERABLE  # Application name
$category = $env:CATEGORY  # Type (app, back, front, etc.)
$appId = $env:APP_ID  # CMDB App ID
$owner = $env:OWNER  # Person responsible
$onlyFolder = $env:ONLY_FOLDER  # Optional folder for partial migration
$cloneUrl = $env:CLONE_URL  # Source repository URL

# Define PRIVATE based on criticality
if ($criticality -eq 'critical') {
    $PRIVATE = 'true'
} else {
    $PRIVATE = 'false'
}

# Define organization - use provided org or default
if ([String]::IsNullOrEmpty($org)) {
    $org = $env:GITHUB_REPOSITORY_OWNER
}

# Define repository name using current pattern: {deliverable-provider}-{deliverable}-{category}
$repo = "$deliverableProvider-$deliverable-$category"
$REPO_URL = "https://github.com/$org/$repo"

# Define TEAMS using current team structure
$TEAMS = @(
    @{
        "name" = "tis"
        "permission" = if ($criticality -eq 'critical') { 'none' } else { 'pull' }
        "privacy" = "closed"
    },
    @{
        "name" = "tis-$deliverableProvider"
        "parent" = "tis"
        "permission" = if ($criticality -eq 'critical') { 'none' } else { 'pull' }
        "privacy" = "closed"
    },
    @{
        "name" = "tis-$deliverableProvider-$deliverableOwner"
        "parent" = "tis-$deliverableProvider"
        "permission" = "maintain"
        "privacy" = "closed"
    },
    @{
        "name" = "tis-$deliverableProvider-$deliverableOwner-admins"
        "parent" = "tis-$deliverableProvider-$deliverableOwner"
        "permission" = "admin"
        "privacy" = "closed"
    }
) | ConvertTo-Json -Compress


# Import source detection and parsing
$importType = $null
$importFromUrl = $null

$adoOrg = $null
$adoProject = $null
$adoRepo = $null

# Parse clone URL if provided to determine import type and details
if(-not [String]::IsNullOrEmpty($cloneUrl)){

    # Check for Azure DevOps URL
    if($cloneUrl -match 'dev\.azure\.com'){
        if([String]::IsNullOrEmpty($env:ADO_PAT)){
            Write-Warning "Environment variable ADO_PAT is not set but ADO URL provided"
        }

        # Parse components from ado repo url using regex
        $adoRepoUrlRegex = [regex]::new('https://(?:.*@)?dev.azure.com/(?<organization>.+)/(?<project>.+)?/_git/(?<repo>.+)')
        $adoRepoUrlMatch = $adoRepoUrlRegex.Match($cloneUrl)
        if(-not $adoRepoUrlMatch.Success){
            throw "Failed to parse Azure DevOps repo URL: $cloneUrl"
        }

        $adoOrg = $adoRepoUrlMatch.Groups['organization'].Value
        $adoProject = $adoRepoUrlMatch.Groups['project'].Value
        $adoRepo = $adoRepoUrlMatch.Groups['repo'].Value
        $importType = "ado"
        $importFromUrl = $cloneUrl
    }

    # Check for BitBucket URL
    elseif($cloneUrl -match 'bitbucket\.org'){
        if([String]::IsNullOrEmpty($env:BB_USERNAME) -or [String]::IsNullOrEmpty($env:BB_PASSWORD)){
            Write-Warning "Environment variables BB_USERNAME and BB_PASSWORD must be set for BitBucket imports"
        }

        $importType = "bitbucket"
        $importFromUrl = $cloneUrl
    }

    # Check for GitHub URL
    elseif($cloneUrl -match 'github\.com'){
        $importType = "github"
        $importFromUrl = $cloneUrl
    }

    # Check for SVN URL
    elseif($cloneUrl -match 'svn\.'){
        $importType = "svn"
        $importFromUrl = $cloneUrl
    }

    # Unknown source type
    else {
        $importType = "unknown"
        $importFromUrl = $cloneUrl
    }
}

# Write outputs for GitHub Actions
Write-Output "PRIVATE=$PRIVATE" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "REPO_URL=$REPO_URL" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "TEAMS=$TEAMS" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "GH_ORG=$org" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "GH_REPO=$repo" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "ADO_ORG=$adoOrg" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "ADO_PROJECT=$adoProject" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "ADO_REPO=$adoRepo" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "IMPORT_TYPE=$importType" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Output "IMPORT_FROM_URL=$importFromUrl" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append

# Add validation and debugging information
Write-Output "| **Parameter Parsing** | ✅ | Successfully parsed parameters |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
Write-Output "| **Repository Name** | ✅ | $repo |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
Write-Output "| **Organization** | ✅ | $org |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
Write-Output "| **Criticality** | ✅ | $criticality (Private: $PRIVATE) |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append

if(-not [String]::IsNullOrEmpty($importFromUrl)){
    Write-Output "| **Import Source** | ✅ | $importType from $importFromUrl |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
}


