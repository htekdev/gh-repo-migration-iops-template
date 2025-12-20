Param(
)

. "$($PSScriptRoot)/modules.ps1"


# Define ADO_ORG, ADO_PROJECT, ADO_REPO
if([String]::IsNullOrEmpty($env:IMPORT_URL)){
    $results = @{
        "source" = "none"
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=none" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

    return
}

# Check if import url is a valid ado url
if($env:IMPORT_URL -match 'https://(?:.*@)?dev.azure.com/(?<organization>.+)/(?<project>.+)?/_git/(?<repo>.+)'){
    $results = @{
        "source" = "ado"
        "organization" = $Matches['organization']
        "project" = $Matches['project']
        "repo" = $Matches['repo']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=ado" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_ORGANIZATION=$($Matches['organization'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_PROJECT=$($Matches['project'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_REPO=$($Matches['repo'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}

# https://dev.azure.com/org/project/_versionControl?version=T&path=%24/devops/test
# or
# https://dev.azure.com/org/project/_versionControl?version=T
# https://dev.azure.com/org/project/_versionControl
if($env:IMPORT_URL -match 'https://(?:.*@)?dev.azure.com/(?<organization>.+)/(?<project>.+)?/_versionControl'){

    # Parse out the path from the url using uri
    $uri = New-Object System.Uri($env:IMPORT_URL)
    $path = $uri.Query -split '&'
    $path = $path | Where-Object { $_ -match 'path=(.+)'}
    $path = [System.Web.HttpUtility]::UrlDecode($Matches[1])

    # Seperate the $/project from the path
    $path -match '^(\$\/[^\/]+)(?:\/(.*))$'
    $repo = $Matches[1]
    $folder = $Matches[2]

    if(-not [String]::IsNullOrEmpty($folder)){
        $repo = "$($repo)$($folder)"
    }

    $results = @{
        "source" = "ado-tfs"
        "organization" = $Matches['organization']
        "project" = $Matches['project']
        "repo" = $repo
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=ado-tfs" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_ORGANIZATION=$($Matches['organization'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_PROJECT=$($Matches['project'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_TFS_REPO=$($repo)" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}
if($env:IMPORT_URL -match 'https://(?<organization>.+).visualstudio.com/(?<project>.+)?/_versionControl'){

    # Parse out the path from the url using uri
    $uri = New-Object System.Uri($env:IMPORT_URL)
    $path = $uri.Query -split '&'
    $path = $path | Where-Object { $_ -match 'path=(.+)'}
    $path = [System.Web.HttpUtility]::UrlDecode($Matches[1])

    # Seperate the $/project from the path
    $path -match '^(\$\/[^\/]+)(?:\/(.*))$'
    $repo = $Matches[1]
    $folder = $Matches[2]

    if(-not [String]::IsNullOrEmpty($folder)){
        $repo = "$($repo)$($folder)"
    }

    $results = @{
        "source" = "ado-tfs"
        "organization" = $Matches['organization']
        "project" = $Matches['project']
        "repo" = $repo
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=ado-tfs" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_ORGANIZATION=$($Matches['organization'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_PROJECT=$($Matches['project'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_ADO_TFS_REPO=$($repo)" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}


# Check if import url is a valid bitbucket url
$bbBaseUrl = if($env:BITBUCKET_BASE_URL) { $env:BITBUCKET_BASE_URL } else { 'bitbucket.example.com' }
if($env:IMPORT_URL -match "https://$bbBaseUrl/scm/(?<project>.+)/(?<slug>.+).git"){
    $results = @{
        "source" = "bitbucket"
        "project" = $Matches['project']
        "slug" = $Matches['slug']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=bitbucket" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_BITBUCKET_PROJECT=$($Matches['project'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_BITBUCKET_SLUG=$($Matches['slug'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

    return
}

$currentOrg = $env:GITHUB_REPOSITORY_OWNER

# Check if import url is a valid github url
if($env:IMPORT_URL -match "https://github.com/(?<organization>$currentOrg)/(?<repo>.+?)(?:\.git)?$"){
    $results = @{
        "source" = "github"
        "organization" = $Matches['organization']
        "repo" = $Matches['repo']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=github" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITHUB_ORGANIZATION=$($Matches['organization'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITHUB_REPO=$($Matches['repo'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

    return
}

# Check if import url is a valid github url
if($env:IMPORT_URL -match 'https://github.com/(?<organization>.+)/(?<repo>.+?)(?:\.git)?$'){
    $results = @{
        "source" = "github-external"
        "organization" = $Matches['organization']
        "repo" = $Matches['repo']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=github-external" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITHUB_ORGANIZATION=$($Matches['organization'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_GITHUB_REPO=$($Matches['repo'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

    return
}

# Check if import url is a valid svn url
$svnBaseUrl = if($env:SVN_BASE_URL) { $env:SVN_BASE_URL } else { 'svn.example.com' }
if($env:IMPORT_URL -match "https://$svnBaseUrl/(?<repo>.+)"){
    $results = @{
        "source" = "subversion"
        "domain" = $svnBaseUrl
        "path" = "$($Matches['repo'])"
        "repo" = $Matches['repo']
    } | ConvertTo-Json -Compress
    Write-Output "results=$results" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
    Write-Output "IMPORT_SOURCE=subversion" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_SVN_REPO=$($Matches['repo'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_SVN_DOMAIN=$svnBaseUrl" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    Write-Output "IMPORT_SVN_PATH=$($Matches['repo'])" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
    return
}

Write-Output "| **Import Repo** | ❌ | Unknown import url: ``$($env:IMPORT_URL)`` <b>Expected format:</b> ``https://dev.azure.com/{organization}/{project}/_git/{repo}``, ``https://bitbucket.example.com/scm/{project}/{slug}.git``, ``https://svn.example.com/{repo}``, or ``None`` |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
# Unknown import url
throw "Unknown import url: $env:IMPORT_URL`nExpected format: `n  1. https://dev.azure.com/{organization}/{project}/_git/{repo}`n  2. https://bitbucket.example.com/scm/{project}/{slug}.git`n  3. https://svn.example.com/{repo}`n  4. None"





