Param(
  [string] $githubRepoUrl,
  [string] $values # Multi-line string
)

. "$($PSScriptRoot)/modules.ps1"

Write-Output "| *Adding Mandated Repo Files* |  |  |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append

$tempFolder = New-TemporaryDirectory
Push-Location $tempFolder

try{
  
  # Parse components from github repo url using regex
  $githubRepoUrlRegex = [regex]::new('https://github.com/(?<organization>.+)/(?<repo>.+?)(?:\.git)?$')
  $githubRepoUrlMatch = $githubRepoUrlRegex.Match($githubRepoUrl)
  if(-not $githubRepoUrlMatch.Success){
    throw "Failed to parse github repo url: $githubRepoUrl"
  }

  $githubOrg = $githubRepoUrlMatch.Groups['organization'].Value
  $githubRepo = $githubRepoUrlMatch.Groups['repo'].Value

  # Setup
  Update-GitHubToken -Organization $githubOrg

  if($env:IMPORT_SOURCE -eq "none"){
    mkdir $githubRepo
    # Get Default Branch
    Push-Location $githubRepo
    Write-Output "# $($githubRepo)" >> README.md
    git init
    git add README.md
    git commit -m "first commit"
    git branch -M main
    git remote add origin "https://github.com/$($githubOrg)/$($githubRepo).git"
    git push -u origin main
  }
  else{
    # Checkout repo
    gh repo clone $githubOrg/$githubRepo
    # Get Default Branch
    Push-Location $githubRepo
  }
  

  $defaultBranch = $(git remote show origin | ? { $_ -match "HEAD branch" } | % { $_ -replace "^.* branch: ",""})
  

  # Add mandated repo files
  $repoPath = "$($tempFolder)/$($githubRepo)"

  $metaFileContent = @"
name: 📋 Platform | Define Metadata Requirements

on: 
  repository_dispatch:
    types: [meta]
  workflow_dispatch:
  push:
    branches:
      - $defaultBranch
    paths: 
      - '.github/workflows/meta.yml'
  
jobs:  
  #########################################################################
  set: 
    uses: $($env:META_WORKFLOW_REPO)/.github/workflows/set.yml@main
    with:
      values: |
        $($values.Replace("`n","`n        "))
"@

  # Remove any empty lines with only whitespace
  $metaFileContent = $metaFileContent -replace "(?m)^\s*$[\r\n]*", ""


  $metaFilePath = "$($repoPath)/.github/workflows/meta.yml"
  New-Item -Path $metaFilePath -ItemType File -Force | Out-Null

  $metaFileContent | Out-File -FilePath $metaFilePath -Encoding utf8

  $email = $env:GIT_EMAIL
  $name = $env:GIT_NAME
  if([String]::IsNullOrEmpty($email) -or [String]::IsNullOrEmpty($name)){
    throw "Environment variables GIT_EMAIL and GIT_NAME must be set"
  }

  git config user.email $email
  git config user.name $name

  git add $metaFilePath

  # Commit if there are changes
  if($(git status --porcelain | Measure-Object).Count -gt 0){
    git commit -m "Add mandated repo files"
    git push origin $defaultBranch | Out-Null
  }

  Write-Output "| Add mandated repo files | ✅  |  |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
  Pop-Location
  
}
catch{
  throw $_
}
finally{
  Pop-Location
  Remove-Item -Path $tempFolder -Recurse -Force
}


