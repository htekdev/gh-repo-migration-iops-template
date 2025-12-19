Param(
  [string] $Folder,
  [string] $GithubRepoUrl
)

. "$($PSScriptRoot)/modules.ps1"

if(-not $(Test-Path $Folder)){
  throw "Folder $Folder does not exist"
}

$currentFolder = $(Get-Location).Path
Invoke-WebRequest -Uri https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -OutFile $currentFolder/bfg.jar

Push-Location $Folder


git config push.followTags true

git config user.email $env:GIT_EMAIL
git config user.name $env:GIT_NAME

if($env:IMPORT_SOURCE -eq "svn"){
  git remote add origin $GithubRepoUrl
}

if($env:IMPORT_SOURCE -eq "subversion"){
  git remote add origin $GithubRepoUrl
}

git branch -r | % { $_.Trim() } |  Where-Object { $_ -notmatch '\->' } | ForEach-Object { 
  $remote = $_; 
  $branch = ($remote -replace 'origin/', '')
  if($branch -match '^[A-Za-z][A-Za-z0-9\.\-_\/]+$'){
    git branch --track $branch $remote 
    git checkout $branch
  }
  else{

    git branch --track $branch $remote 
    git checkout $branch

     

    $branch = $branch -replace '[^A-Za-z0-9\.\-_\/]','-'
    $branch = "format-invalid/$branch"
    $remote = $remote -replace '[^A-Za-z0-9\.\-_\/]','-'
    $remote = ($remote -replace 'origin/', 'origin/format-invalid/')
    git branch -m $branch $remote
    
    Write-Output "| **Renaming Branch $($branch) to $($remote)** | 🔶  | Not in correct format |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
    
  }
}

git checkout $(git remote show origin | ? { $_ -match "HEAD branch" } | % { $_ -replace "^.* branch: ",""})
git gc

Pop-Location

java -jar $currentFolder/bfg.jar --strip-blobs-bigger-than 100M --no-blob-protection $Folder

Push-Location $Folder



try{

  # Parse components from github repo url using regex
  $githubRepoUrlRegex = [regex]::new('https://github.com/(?<organization>.+)/(?<repo>.+)(?:.git)?')
  $githubRepoUrlMatch = $githubRepoUrlRegex.Match($githubRepoUrl)
  if(-not $githubRepoUrlMatch.Success){
    throw "Failed to parse github repo url: $githubRepoUrl"
  }

  $githubOrg = $githubRepoUrlMatch.Groups['organization'].Value
  $githubRepo = $githubRepoUrlMatch.Groups['repo'].Value

  $env:GIT_TRACE_PACKET=1
  $env:GIT_TRACE=1
  $env:GIT_CURL_VERBOSE=1

  

  
  git reflog expire --expire=now --all && git gc --prune=now --aggressive
  git config http.postBuffer 157286400
  git config pack.window 1
  git config http.version HTTP/1.1
  gh auth setup-git

  
  git remote set-url origin $GithubRepoUrl
  
  

  $loc = $(Get-Location).Path
  $files = @(@($(Get-ChildItem -Force -Recurse -File | Where-Object { ($($_.Length)/1MB) -gt 100 } | ForEach-Object {$_.FullName.Substring($loc.Length + 1)}))  | % { "`"$($_)`"" })

  # Remove files in the .git folder
  $files = $files | Where-Object { $_ -notlike "`".git/*" }

  $files = $files -join " "

  Write-Host "Files Found: $($files)"

  git status
  if($files -ne ""){
    "git lfs track $files" | Invoke-Expression

    $email = $env:GIT_EMAIL
    $name = $env:GIT_NAME
    if([String]::IsNullOrEmpty($email) -or [String]::IsNullOrEmpty($name)){
      throw "Environment variables GIT_EMAIL and GIT_NAME must be set"
    }

    git config user.email $email
    git config user.name $name

    git add -A
    git commit -m "Adding All Files"

    Write-Output "| **Add Large Files to LFS** | ✅  | ``$($files.Count)`` Files Found|" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
  }

  git status

  if(-not [String]::IsNullOrEmpty($env:INCLUDE_ONLY_PATH)){
    $path = $env:INCLUDE_ONLY_PATH

    # Check if path is comma separated
    if($path -match ","){
      $paths = $path -split ","

      Write-Host "Only including multiple paths: `n  - $($paths -join "`n  - ")"
      
      git filter-branch -f --index-filter "git rm --cached -qr --ignore-unmatch -- . && git reset -q `$GIT_COMMIT -- '$($path)'" --prune-empty -- --all
      Write-Output "| **Clean history to exclude other folders** | ✅  | Only ``$($path)`` will be included |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
  
    }
    else{
      git filter-branch -f --subdirectory-filter $path -- --all
    }
    
    

    Write-Output "| **Moving Folder to Root** | ✅  | Folder ``$($path)`` |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append

    
  }

  Write-Host "Pushing to $GithubRepoUrl"
  Update-GitHubToken -Organization $githubOrg


  # Capture the output of the push command in powershell
  git push
  git push --all

  # remote: error: GH013: Repository rule violations found for refs/heads/main.        
  # remote: Review all repository rules at http://github.com/{{DEFAULT ORG}}/tis-devops-de-framework-non-critical-doodle/rules?ref=refs%2Fheads%2Fmain        
  # remote: 
  # remote: - GITHUB PUSH PROTECTION        
  # remote:   ——————————————————————————————————————————————————————        
  # remote:    Resolve the following secrets before pushing again.        
  # remote:           
  # remote:    (?) Learn how to resolve a blocked push        
  # remote:    https://docs.github.com/code-security/secret-scanning/pushing-a-branch-blocked-by-push-protection        
  # remote:           
  # remote:           
  # remote:   —— Azure DevOps Personal Access Token ————————————————        
  # remote:    locations:        
  # remote:      - commit: 5fce35060881578d6eb7c82e6b6f07d290155591        
  # remote:        path: extensions/azure-devops/adding/change-control/evaluate-change-tags/task/src/Invoke-Task.local.ps1:17        
  # remote:           
  # remote:    (?) To push, remove secret from commit(s) or follow this URL to allow the secret.        
  # remote:    https://github.com/{{DEFAULT ORG}}/tis-devops-de-framework-non-critical-doodle/security/secret-scanning/unblock-secret/2XeCXZH64naXi0A33GHeymb60ei        
  # remote: 
  # To https://github.com/{{DEFAULT ORG}}/tis-devops-de-framework-non-critical-doodle.git
  # ! [remote rejected] main -> main (push declined due to repository rule violations)
  # error: failed to push some refs to 'https://github.com/{{DEFAULT ORG}}/tis-devops-de-framework-non-critical-doodle.git'

  # Find the paths that are causing the push to failq
  $regex = [regex]::new('path: (?<path>.+):')
  $finds = $regex.Matches($results)
  $paths = @($finds | % { $_.Groups['path'].Value}) -join " "
  Write-Host "Resuilts: `n$($results)"
  Write-Host "Paths: $($paths)"

  # Remove the paths using BFG
  if($paths -ne ""){
    Write-Host "Found files that are causing the push to fail. Removing them using BFG"
    pip3 install git-filter-repo
    git filter-repo --invert-paths --path $paths
    git reflog expire --expire=now --all && git gc --prune=now --aggressive

    git status
    git remote add origin $GithubRepoUrl
    git push --all
  }
}
catch{
  throw $_.Exception
}
finally{
  Remove-Item -Path $currentFolder/bfg.jar
  Pop-Location
}
