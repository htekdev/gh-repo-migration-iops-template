Param(
)

. "$($PSScriptRoot)/modules.ps1"

$folder = New-TemporaryDirectory
Push-Location $folder

Write-Output "| *Import Repo* |  |  |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
Function Disable-Secret-Scanning-Push-Protection{
  param(
    [string]$org,
    [string]$repo
  )
  Invoke-GitHubApiRoute -Path repos/$($org)/$($repo) -Method Patch -Body $(@{
    security_and_analysis = @{
      secret_scanning_push_protection = @{
        status = "disabled"
      }
    }
  } | ConvertTo-Json -Depth 100) -SkipHttpErrorCheck | Out-Null
}

Function Enable-Secret-Scanning-Push-Protection{
  param(
    [string]$org,
    [string]$repo
  )
  Invoke-GitHubApiRoute -Path repos/$($org)/$($repo) -Method Patch -Body $(@{
    security_and_analysis = @{
      secret_scanning_push_protection = @{
        status = "enabled"
      }
    }
  } | ConvertTo-Json -Depth 100) -SkipHttpErrorCheck | Out-Null
}

Function Get-Secret-Scanning-Push-Protection{
  param(
    [string]$org,
    [string]$repo
  )
  $response = Invoke-GitHubApiRoute -Path repos/$($org)/$($repo) -Method Get -SkipHttpErrorCheck
  $response.security_and_analysis.secret_scanning_push_protection.status
}


try{


  if($env:IMPORT_SOURCE -eq "ado"){
    if([String]::IsNullOrEmpty($env:ADO_PAT)){
      throw "Environment variable ADO_PAT is not set"
    }
    
    $adoOrg = $env:IMPORT_ADO_ORGANIZATION
    $adoProject = $env:IMPORT_ADO_PROJECT
    $adoRepo = $env:IMPORT_ADO_REPO
    
    $cloneUrl = "https://$($adoOrg):$($env:ADO_PAT)@dev.azure.com/$adoOrg/$adoProject/_git/$adoRepo"
  } 
  elseif($env:IMPORT_SOURCE -eq "ado-tfs"){
    if([String]::IsNullOrEmpty($env:ADO_PAT)){
      throw "Environment variable ADO_PAT is not set"
    }
    
    $adoOrg = $env:IMPORT_ADO_ORGANIZATION
    $adoProject = $env:IMPORT_ADO_PROJECT
    $adoRepo = $env:IMPORT_ADO_TFS_REPO
    $adoFolder = $env:IMPORT_ADO_TFS_FOLDER
    
    $cloneUrl = "https://$($adoOrg):$($env:ADO_PAT)@dev.azure.com/$adoOrg/$adoProject/_versionControl"
  } 
  elseif($env:IMPORT_SOURCE -eq "github" -or $env:IMPORT_SOURCE -eq "github-external"){
    
    
    $githubOrg = $env:IMPORT_GITHUB_ORGANIZATION
    $githubRepo = $env:IMPORT_GITHUB_REPO

    if($env:IMPORT_SOURCE -eq "github"){
      Update-GitHubToken -Repository "$($githubOrg)/$($githubRepo)"
    }

    
    $cloneUrl = "https://$($env:GIT_NAME):$($env:GH_TOKEN)@github.com/$githubOrg/$githubRepo.git"
  }
  elseif($env:IMPORT_SOURCE -eq "bitbucket"){
    if([String]::IsNullOrEmpty($env:BB_USERNAME) -or [String]::IsNullOrEmpty($env:BB_PASSWORD)){
      throw "Environment variables BB_USERNAME and BB_PASSWORD must be set"
    }

    $project = $env:IMPORT_BITBUCKET_PROJECT
    $slug = $env:IMPORT_BITBUCKET_SLUG
    $bbBaseUrl = if($env:BITBUCKET_BASE_URL) { $env:BITBUCKET_BASE_URL } else { 'bitbucket.example.com' }
    $url = "$bbBaseUrl/scm/$project/$slug.git"

    $cloneUrl = "https://$($env:BB_USERNAME):$($env:BB_PASSWORD)@$url"
  }
  elseif($env:IMPORT_SOURCE -eq "svn"){
    if([String]::IsNullOrEmpty($env:SVN_SERVICE_USERNAME) -or [String]::IsNullOrEmpty($env:SVN_SERVICE_PASSWORD)){
      throw "Environment variables SVN_SERVICE_USERNAME and SVN_SERVICE_PASSWORD must be set"
    }

    $url = $env:IMPORT_URL

    $cloneUrl = "https://$($env:IMPORT_SVN_DOMAIN)/$($env:IMPORT_SVN_PATH)"
  }
  elseif($env:IMPORT_SOURCE -eq "subversion"){
    if([String]::IsNullOrEmpty($env:SUBVERSION_SERVICE_USERNAME) -or [String]::IsNullOrEmpty($env:SUBVERSION_SERVICE_PASSWORD)){
      throw "Environment variables SUBVERSION_SERVICE_USERNAME and SUBVERSION_SERVICE_PASSWORD must be set"
    }

    $url = $env:IMPORT_URL

    $cloneUrl = "https://$($env:IMPORT_SVN_DOMAIN)/$($env:IMPORT_SVN_PATH)"
  }
  else{
    Write-Output "| **Import Repo** | ❌ | Unknown import source: ``$($env:IMPORT_SOURCE)`` <b>Expected values:</b> ``ado``, ``bitbucket`` |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
    throw "Unknown import source: $env:IMPORT_SOURCE, expected values: ado, bitbucket"
  }

  $githubOrg = $env:ORG
  $githubRepo = $env:REPO
  $githubRepoUrl = "https://github.com/$($githubOrg)/$($githubRepo)"

  # Setup
  Update-GitHubToken -Organization $githubOrg

  
  Write-Output "| Disable Push Protection | ✅  |  |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append

  
  #########################################################################
  # Disable secret scanning push protection
  #########################################################################
  $tries = 0  
  Disable-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
  $status = Get-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
  Write-Host "Secret scanning push protection status: $status"
  while($status -ne "disabled" -and $tries -lt 10){
    Write-Host "Secret scanning push protection is not disabled yet, waiting 10 seconds - Attempt $($tries + 1)"
    Start-Sleep -Seconds 5
    Disable-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
    $status = Get-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo

    $tries = $tries + 1
  }
  #########################################################################



  # Clone ADO repo

  if($env:IMPORT_SOURCE -eq "svn"){
    # $env:GIT_SSL_NO_VERIFY = "true"
    $GIT_REPO="ppa:git-core/ppa"
    add-apt-repository $GIT_REPO -y
    apt-get update
    apt-get install git=2.34.1 -y
    apt-get install git-svn
    apt-get install subversion

    # Using bash inline script run svn list to accept the certificate and then git svn clone
    $list_script = @" 
rm ~/.subversion/auth/svn.simple/* -rf
rm ~/.subversion/auth/svn.ssl.server/* -rf
(echo p | git svn clone $($cloneUrl) --username $($env:SVN_SERVICE_USERNAME) ado) & pid=$! ; sleep 5 ; kill `$pid
rm ado -rf
svn list $($cloneUrl) --username $($env:SVN_SERVICE_USERNAME) --password $($env:SVN_SERVICE_PASSWORD)
"@
    $files = $($list_script | bash)
    $files = $files | ? { $_ -notmatch "Initialized empty Git repository in"}
    
    # Check if the only files that exists is branches, tags, and trunk
    $files_not_match = $files | ? { $_ -notmatch "branches|tags|trunk" }

    $extra_parameters = ""

    # If there is only branches, tags, and trunk, then append --branches, --tags, --trunk to the git svn clone command
    if($files_not_match.Count -eq 0){
      $extra_parameters = "--branches=branches --tags=tags --trunk=trunk"
    }


    $script = @"
(echo $($env:SVN_SERVICE_PASSWORD) | git svn clone $($cloneUrl) --username $($env:SVN_SERVICE_USERNAME) ado $extra_parameters)
"@
    $script | bash


    
  }
  elseif($env:IMPORT_SOURCE -eq "subversion"){
    # $env:GIT_SSL_NO_VERIFY = "true"
    $GIT_REPO="ppa:git-core/ppa"
    add-apt-repository $GIT_REPO -y
    apt-get update
    apt-get install git=2.34.1 -y
    apt-get install git-svn
    apt-get install subversion

    # Using bash inline script run svn list to accept the certificate and then git svn clone
    $list_script = @" 
rm ~/.subversion/auth/svn.simple/* -rf
rm ~/.subversion/auth/svn.ssl.server/* -rf
(echo p | git svn clone $($cloneUrl) --username $($env:SUBVERSION_SERVICE_USERNAME) ado) & pid=$! ; sleep 5 ; kill `$pid
rm ado -rf
svn list $($cloneUrl) --username $($env:SUBVERSION_SERVICE_USERNAME) --password $($env:SUBVERSION_SERVICE_PASSWORD)
"@
    $files = $($list_script | bash)
    $files = $files | ? { $_ -notmatch "Initialized empty Git repository in"}
    
    # Check if the only files that exists is branches, tags, and trunk
    $files_not_match = $files | ? { $_ -notmatch "branches|tags|trunk" }

    $extra_parameters = ""

    # If there is only branches, tags, and trunk, then append --branches, --tags, --trunk to the git svn clone command
    if($files_not_match.Count -eq 0){
      $extra_parameters = "--branches=branches --tags=tags --trunk=trunk"
    }


    $script = @"
(echo $($env:SUBVERSION_SERVICE_PASSWORD) | git svn clone $($cloneUrl) --username $($env:SUBVERSION_SERVICE_USERNAME) ado $extra_parameters)
"@
    $script | bash
    
  }
  elseif($env:IMPORT_SOURCE -eq "ado-tfs"){
    apt-get install git=2.34.1 -y
    apt-get install git-tfs
    git tfs clone $cloneUrl --branches=all $cloneUrl $adoRepo ado
  }
  else{
    git clone $cloneUrl ado
  }
  
  
  Push-Location $folder/ado
  $defaultBranch = $(git remote show origin | ? { $_ -match "HEAD branch" } | % { $_ -replace "^.* branch: ",""})
  Pop-Location

  Start-Sleep -Seconds 10

  Update-GitHubToken -Organization $githubOrg

  Disable-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
  & "$($PSScriptRoot)/Execute-GitImport.ps1" -Folder ado -GithubRepoUrl $githubRepoUrl

  Invoke-GitHubApiRoute -Path repos/$($githubOrg)/$($githubRepo) -Method PATCH -Body $(@{
    default_branch = $defaultBranch
  } | ConvertTo-Json)| Out-Null

  
  Write-Output "| Set Default Branch | ✅  | ``$($defaultBranch)`` |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append

  #########################################################################
  # Enable secret scanning push protection
  #########################################################################
  $tries = 0  
  Enable-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
  $status = Get-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
  while($status -ne "enabled" -and $tries -lt 10){
    Write-Host "Secret scanning push protection is not enabled yet, waiting 10 seconds - Attempt $($tries + 1)"
    Start-Sleep -Seconds 10

    Enable-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo
    $status = Get-Secret-Scanning-Push-Protection -org $githubOrg -repo $githubRepo

    $tries = $tries + 1
  }
  #########################################################################
  

  Write-Output "| Enable Push Protection | ✅  |  |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
}
catch{
  throw $_
}
finally{
  Pop-Location
  Remove-Item -Path $folder -Recurse -Force

  
}


