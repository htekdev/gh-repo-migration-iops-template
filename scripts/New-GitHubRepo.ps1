Param(
  [string] $githubRepoUrl
)

. "$($PSScriptRoot)/modules.ps1"

$folder = New-TemporaryDirectory
Push-Location $folder
try{

  # Parse components from github repo url using regex
  $githubRepoUrlRegex = [regex]::new('https://github.com/(?<organization>.+)/(?<repo>.+)(?:.git)?')
  $githubRepoUrlMatch = $githubRepoUrlRegex.Match($githubRepoUrl)
  if(-not $githubRepoUrlMatch.Success){
    throw "Failed to parse github repo url: $githubRepoUrl"
  }

  $githubOrg = $githubRepoUrlMatch.Groups['organization'].Value
  $githubRepo = $githubRepoUrlMatch.Groups['repo'].Value

  # Setup
  Update-GitHubToken -Organization $githubOrg

  # Check if repo already exists
  $exisitingRepo = Invoke-GitHubApiRouteNullOn404 -Path "repos/$($githubOrg)/$($githubRepo)"
  if($exisitingRepo){
    throw "Repo $githubRepo already exists in organization $githubOrg"
  }

  # Create repo
  Write-Host "Creating repo $githubRepo in organization $githubOrg"
  $repo = $(Invoke-GitHubApiRoute -Path "orgs/$($githubOrg)/repos" -Method Post -Body $(@{
    name = $githubRepo
    private = $true
  } | ConvertTo-Json))

  $repoWebUrl = $repo.html_url
  $repoNameWithOwner = $repo.full_name

  Write-Output "| **Create Repo** | ✅ | [$repoNameWithOwner]($($repoWebUrl)) |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
}
catch{
  Write-Output "| **Create Repo** | ❌ | $($_.Exception.Message) |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
  throw $_
}
finally{
  Pop-Location
  Remove-Item -Path $folder -Recurse -Force
}


