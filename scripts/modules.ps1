
# Check if powershell-yaml module is installed
if(!(Get-Module -ListAvailable -Name powershell-yaml)) {
  Write-Host "powershell-yaml module is not installed. Installing now..."
  Install-Module -Name powershell-yaml -Scope CurrentUser -Force -Repository 'PSGallery'
}

# Check if jwtPS module is installed
if(!(Get-Module -ListAvailable -Name jwtPS)) {
  Write-Host "jwtPS module is not installed. Installing now..."
  Install-Module -Name jwtPS -Scope CurrentUser -Force -Repository 'PSGallery'
}

# Install jwtPS module using PSGallery repo
Import-Module jwtPS

# Import powershell-yaml module
Import-Module powershell-yaml


Function Convert-ToNormalPath {
  Param(
    # Allo pipe
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $Path,

    [string] $From = $PSScriptRoot
  )

  Process{
    $From = $From -replace "[\/\\]", '/'
    

    $Path = $Path -replace "[\/\\]", '/'
    $Path = $Path -replace "$From/", ''
    return $Path
  }
}

Function Get-RootFolder {
  Param(
    [string] $Folder = $PSScriptRoot
  )

  # Get git root folder
  $rootFolder = $Folder
  while (!(Test-Path -Path "$rootFolder/.git")){
      $rootFolder = Split-Path -Path $rootFolder -Parent
  }

  return $rootFolder
}

Function Get-MarkdownNoWrap {
  Param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $Content
  )

  $Content = $Content.Trim()
  $Content = $Content -replace "-", "&#x2011;"
  $Content = $Content -replace " ", "&#x00A0;"
  
  return $Content
}
Function Get-CommentParameters {
  Param(
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string] $Content
  )

  try{
    # Pull out all the parameters in the form of #[<Parameter Name>]\n<Parameter Value>
    $regex = [regex]("# *\[(?<ParameterName>.*)\][\n\r]+#(?<ParameterValue>.*)[\n\r]*")
    $_matches = $regex.Matches($Content)
    Write-Host "$($_matches.Count) parameters found in comment"
    $Parameters = @($_matches | ForEach-Object {
        @{
            Name = $_.Groups["ParameterName"].Value
            Value = ($_.Groups["ParameterValue"].Value -replace "[\n\r]+", '').Trim()
        }
    })
    return @(@($Parameters) | Sort-Object -Property Name)
  }
  catch{
    Write-Host "$($_.Exception.Message)"
    Write-Error "No repository found with name ``$Repository``"
  }






}


Function Get-RepoDetails {
  Param(
    [string] $Folder
  )

  $rootFolder = Get-RootFolder -Folder $Folder

  try{
    Push-Location $rootFolder

    Write-Host "Getting repository details for folder ``$Folder``..."

    $repo = $(gh repo view --json name,owner,id,nameWithOwner,description,url ) | ConvertFrom-Json

    return $repo
  }
  catch{
    throw "Command failed with exit code ``$code``"
  }
  finally{
    Pop-Location
  }
}




Function Invoke-GitHubApiRouteUsingAppJWT {
  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body
  )

  $jwt = New-GitHubJWT

  return Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $jwt
}

Function New-GitHubJWT {
  Param(
    [string] $Certificate = $($env:GH_APP_CERTIFICATE),
    [string] $AppId = $($env:GH_APP_ID)
  )

  $encryption = [jwtTypes+encryption]::SHA256
  $algorithm = [jwtTypes+algorithm]::RSA
  $alg = [jwtTypes+cryptographyType]::new($algorithm, $encryption)

  # 
  $payload = @{
    iss = $AppId
    exp = ([System.DateTimeOffset]::Now.AddMinutes(9)).ToUnixTimeSeconds()
    iat = ([System.DateTimeOffset]::Now).ToUnixTimeSeconds()
  }

  #  
  $keyContent  = $Certificate
  return New-JWT -Payload $payload -Algorithm $alg -Secret $keyContent
}
Function Update-GitHubToken {
  Param(
    [string] $Certificate = $($env:GH_APP_CERTIFICATE),
    [string] $AppId = $($env:GH_APP_ID),
    [string] $Organization,
    [string] $Repository
  )

  if([String]::IsNullOrEmpty($Certificate) -and -not [String]::IsNullOrEmpty($env:GH_APP_CERTIFICATE_FILE_PATH)){
    $Certificate = Get-Content -Path $env:GH_APP_CERTIFICATE_FILE_PATH
  }

  $jwt = New-GitHubJWT -Certificate $Certificate -AppId $AppId
  $headers = @{}
  $headers.Add("Accept", "application/vnd.github+json")
  $headers.Add("Authorization", "Bearer $jwt")

  if(-not [String]::IsNullOrEmpty($Repository)){
    $path = "repos/$($Repository)/installation"
  }
  elseif(-not [String]::IsNullOrEmpty($Organization)){
    $path = "orgs/$($Organization)/installation"
  }
  else{
    # get first installation
    $path = "app/installations"
  }

  $response = @(Invoke-PaginatedGitHubApiRoute -Path $path -Method GET -Headers $headers -Token $jwt)
  $access_tokens_url = @($response.access_tokens_url)[0]
  $response = Invoke-RateLimitedEndpoint -Uri $access_tokens_url -Method POST  -Headers $headers -Token $jwt

  $token = $response.token

  $env:GH_TOKEN = $token

}

Function Invoke-PaginatedGitHubApiRoute {
  Param(
    [string] $Path,
    [hashtable] $Query = [hashtable]::new(),
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)",
    [int] $PageSize = 50,
    [string] $ArrayProperty
  )

  # if no page is specified, start at 1
  if(-not $Page) {
    $Page = 1
  }

  
  $items = @()
  do{
    # Add page and page size to query
    $Query["page"] = $Page
    $Query["per_page"] = $PageSize

    # Invoke the API
    $data = Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token

    if($ArrayProperty){
      $data = $data.$ArrayProperty
    }
    else{
      $data = @($data)
    }

    # Add the data to the items array
    $items += $data

    # Return if no data
    if($data.Count -lt $PageSize) {
      return $items
    }

    # Increment the page
    $Page = $Page + 1


  }while($true)
}

Function Invoke-GitHubApiRouteNullOn404 {
  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)"
  )
  $_statusCode = $null
  $data = Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token -StatusCode ([ref]$_statusCode) -SkipHttpErrorCheck

  # Retry if 202
  if($_statusCode -eq 404) {
    return $null
  }

  return $data
}

Function Invoke-GitHubApiRouteRetryOn202 {
  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)"
  )
  $_statusCode = $null
  $data = Invoke-GitHubApiRoute -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token -StatusCode ([ref]$_statusCode)

  # Retry if 202
  if($_statusCode -eq 202) {
    Write-Host "Waiting for 202 to complete..."
    Start-Sleep -Seconds 5
    return Invoke-GitHubApiRouteRetryOn202 -Path $Path -Query $Query -Method $Method -Body $Body -Token $Token
  }

  # If 204, return empty data
  if($_statusCode -eq 204) {
    return $null
  }

  return $data
}

Function Invoke-GitHubApiRoute {
  Param(
    [string] $Path,
    [hashtable] $Query = @{},
    [string] $Method = "GET",
    [string] $Body,
    [string] $Token = "$(gh auth token)",
    [ref] $ResponseHeaders,
    [ref] $StatusCode,

    [switch] $SkipHttpErrorCheck
  )

  # Setup Headers
  $Headers = @{
    Authorization = "Bearer $($Token)"
  }

  # Set Content-Type if not in header
  if(-not $Headers["Content-Type"]){
    $Headers["Content-Type"] = "application/json"
  }

  $RetryCount = 0
  do{
    try{
      # Build URI
      $uri = "https://api.github.com/$Path"
      if($Query) {
        $uri += "?"
        $uri += @(@($Query.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" })) -join "&"
      }

      Write-Host "$($Method) $uri"

      $parameters = [hashtable]::new()

      if(-not $ResponseHeaders){
        $ResponseHeaders = ([ref]([hashtable]::new()))
      }
      if(-not $StatusCode){
        
        $StatusCode = ([ref]([int]::new()))
      }
      

      # Invoke the API
      $data = Invoke-RateLimitedEndpoint -Method $Method -Uri $uri -Headers $Headers -Body $Body -ResponseHeaders $ResponseHeaders -StatusCode $StatusCode -SkipHttpErrorCheck:$SkipHttpErrorCheck


      # Return the data
      return $data
    }
    catch{
      Write-Host "Error: $($_.Exception.Message)"

      # Retry if rate limited (Skipping since its handled in Invoke-RateLimitedEndpoint)
      if($_.Exception.Message -match "403") {
        throw
      }
      
      # Retry if 500 error
      if($_.Exception.Message -match "500") {
        $RetryCount++
        if($RetryCount -gt 5) {
          throw
        }
        Write-Host "Retrying after 5 seconds..."
        Start-Sleep -Seconds 5
        continue
      }

      # Throw if any other error
      throw
    }
  }while($true)
}
Function Invoke-RateLimitedEndpoint {
  Param(
    [string] $Uri,
    [string] $Method,
    [string] $Body,
    [hashtable] $Headers,
    [ref] $ResponseHeaders,
    [ref] $StatusCode,

    [switch] $SkipHttpErrorCheck
  )

  $_responseHeaders = [hashtable]::new()
  $_statusCode = [int]::new()
  $data = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body $Body -ResponseHeadersVariable _responseHeaders -StatusCodeVariable _statusCode -SkipHttpErrorCheck:$SkipHttpErrorCheck

  
  if($_responseHeaders["Retry-After"]){
    $wait = [int]::Parse($_responseHeaders["Retry-After"])
    Write-Host "Waiting $($wait) seconds for retry"
    Start-Sleep -Seconds $wait.TotalSeconds
    return Invoke-RateLimitedEndpoint -Uri $Uri -Method $Method -Headers $Headers -Body $Body
  }

  if($_responseHeaders["X-RateLimit-Limit"]){
    $rateLimitRemaining = [int]::Parse($_responseHeaders["X-RateLimit-Remaining"])
    $rateLimitReset = [int]::Parse($_responseHeaders["X-RateLimit-Reset"])
    $rateLimitResetAt = [datetime]::new(1970, 1, 1, 0, 0, 0, 0, [DateTimeKind]::Utc).AddSeconds($rateLimitReset)
    # Write-Host "Rate Limit: $rateLimitRemaining of $rateLimit remaining"
    # Write-Host "Rate Limit Reset: $rateLimitResetAt"
    # Write-Host "Rate Limit Cost: $rateLimitCost"
    # Write-Host "Rate Limit Reset: $rateLimitResetAt"
  
    # Wait for the rate limit to reset
    if($rateLimitRemaining -eq 0){
      $wait = $rateLimitResetAt - [datetime]::UtcNow
      Write-Host "Waiting $($wait.TotalSeconds) seconds for rate limit to reset"
      Start-Sleep -Seconds $wait.TotalSeconds
      Start-Sleep -Seconds 20
      if(-not $ResponseHeaders){
        $ResponseHeaders = ([ref]([hashtable]::new()))
      }
      if(-not $StatusCode){
        $StatusCode = ([ref]([int]::new()))
      }
  
      # Retry the request
      $data = Invoke-RateLimitedEndpoint -Uri $Uri -Method $Method -Body $Body -Headers $Headers -ResponseHeaders $ResponseHeaders -StatusCode $StatusCode
    }
  }

  

  if($ResponseHeaders) {
    $ResponseHeaders.Value = $_responseHeaders
  }
  if($StatusCode) {
    $StatusCode.Value = $_statusCode
  }


  return $data
}



Function Get-GitHubOrganizations {
  # Get all organizations
  Write-Host "Getting organizations..."
  $installations = @(Invoke-GitHubApiRouteUsingAppJWT -Path "app/installations" -Method Get)
  Write-Host "Found $($installations.count) installations"

  $installations = @($installations | Where-Object { $_.target_type -eq "Organization" })
  $organizations = @($installations | Select-Object -ExpandProperty account)
  Write-Host "Found $($organizations.count) organizations"

  return @($organizations)
}
Function Get-GitHubRepositories {
  Param(
    [string] $login
  )
  Update-GitHubToken -Organization $login

  Write-Host "Getting repositories for $($login)..."
  $repos = @(Invoke-PaginatedGitHubApiRoute -Path "orgs/$($login)/repos" )
  Write-Host "Found $($repos.count) repositories for $($login)"

  # Adding Index / Count to each repository
  $_ = $repos | ForEach-Object -Begin { $i = 0 } -Process { 
    $_ | Add-Member -MemberType NoteProperty -Name Index -Value $i -PassThru 
    $_ | Add-Member -MemberType NoteProperty -Name Total -Value $($repos.Count) -PassThru 
    $i++
  } -End { $i++ }

  return $repos
}

Function New-TemporaryDirectory {
  Param(
  )

  $Path = [System.IO.Path]::GetTempPath()

  $tempFolder = Join-Path -Path $Path -ChildPath ([System.Guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Path $tempFolder | Out-Null
  return $tempFolder
}

Function Get-Env {
  Param(
    [string] $Name
  )

  $value = [Environment]::GetEnvironmentVariable($Name, [EnvironmentVariableTarget]::Process)
  if([String]::IsNullOrEmpty($value)){
    throw "Environment variable ``$Name`` is not set"
  }

  return $value
}


Function Get-GitHubCloneUrlParts {
  Param(
    [string] $Url
  )

  # Parse components from github repo url using regex
  $githubRepoUrlRegex = [regex]::new('https://github.com/(?<organization>.+)/(?<repo>.+)(?:.git)?')
  $githubRepoUrlMatch = $githubRepoUrlRegex.Match($Url)
  if(-not $githubRepoUrlMatch.Success){
    throw "Failed to parse github repo url: $Url"
  }

  $githubOrg = $githubRepoUrlMatch.Groups['organization'].Value
  $githubRepo = $githubRepoUrlMatch.Groups['repo'].Value

  return @{
    Organization = $githubOrg
    Repository = $githubRepo
  }
}


Function Get-AdoCloneUrlParts {
  Param(
    [string] $Url
  )

  # Parse components from ado repo url using regex
  $adoRepoUrlRegex = [regex]::new('https://(?:.*@)?dev.azure.com/(?<organization>.+)/(?<project>.+)?/_git/(?<repo>.+)')
  $adoRepoUrlMatch = $adoRepoUrlRegex.Match($Url)
  if(-not $adoRepoUrlMatch.Success){
    throw "Failed to parse ado repo url: $Url"
  }

  $adoOrg = $adoRepoUrlMatch.Groups['organization'].Value
  $adoProject = $adoRepoUrlMatch.Groups['project'].Value
  $adoRepo = $adoRepoUrlMatch.Groups['repo'].Value


  return @{
    Organization = $adoOrg
    Project = $adoProject
    Repository = $adoRepo
  }
}

Function Get-BitBucketCloneUrlParts {
  Param(
    [string] $Url
  )

  # Parse components from ado repo url using regex
  $bbUrlRegex = [regex]::new('https://.*?/scm/$(?project>.+?)/(?<repo>.+).git')
  $bbRepoUrlMatch = $bbUrlRegex.Match($Url)
  if(-not $bbRepoUrlMatch.Success){
    throw "Failed to parse ado repo url: $Url"
  }

  $repo = $adoRepoUrlMatch.Groups['repo'].Value
  $project = $adoRepoUrlMatch.Groups['project'].Value

  return @{
    Project = $project
    Slug = $repo
  }
}

Function Test-TeamExists {
  Param(
    [string] $Org,
    [string] $TeamSlug
  )

  try {
    Write-Host "Checking if team '$TeamSlug' exists in organization '$Org'"
    
    # Call GitHub API to check if team exists
    $team = Invoke-GitHubApiRouteNullOn404 -Path "orgs/$Org/teams/$TeamSlug"
    
    if ($team) {
      Write-Host "Team '$TeamSlug' exists in organization '$Org'"
      return $true
    }
    else {
      Write-Host "Team '$TeamSlug' does not exist in organization '$Org'"
      return $false
    }
  }
  catch {
    Write-Host "Error checking team existence: $($_.Exception.Message)"
    return $false
  }
}

Function Test-UserTeamMembership {
  Param(
    [string] $Org,
    [string] $TeamSlug,
    [string] $Username
  )

  try {
    Write-Host "Checking if user '$Username' is a member of team '$TeamSlug' in organization '$Org'"
    
    # First check if the team exists
    $teamExists = Test-TeamExists -Org $Org -TeamSlug $TeamSlug
    
    if (-not $teamExists) {
      Write-Host "Team '$TeamSlug' does not exist yet. Migration will proceed and create the team as part of the process."
      return $true
    }
    
    # Team exists, so check membership
    $membership = Invoke-GitHubApiRouteNullOn404 -Path "orgs/$Org/teams/$TeamSlug/memberships/$Username"
    
    if ($membership -and $membership.state -eq "active") {
      Write-Host "User '$Username' is an active member of team '$TeamSlug'"
      return $true
    }
    elseif ($membership -and $membership.state -eq "pending") {
      Write-Host "User '$Username' has a pending invitation to team '$TeamSlug'"
      return $false
    }
    else {
      Write-Host "User '$Username' is not a member of team '$TeamSlug'"
      return $false
    }
  }
  catch {
    Write-Host "Error checking team membership: $($_.Exception.Message)"
    # If we can't check membership due to an unexpected error, return false for security
    return $false
  }
}
