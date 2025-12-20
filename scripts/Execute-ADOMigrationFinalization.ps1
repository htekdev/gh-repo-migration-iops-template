Param(
  [string] $githubRepoUrl
)

. "$($PSScriptRoot)/modules.ps1"

$adoServiceConnectionId = if($env:ADO_SERVICE_CONNECTION_ID) { $env:ADO_SERVICE_CONNECTION_ID } else { throw "ADO_SERVICE_CONNECTION_ID environment variable not set" }

gh extension install github/gh-gei
gh extension install github/gh-ado2gh

$folder = New-TemporaryDirectory
Push-Location $folder
try{

  if([String]::IsNullOrEmpty($env:ADO_PAT)){
    throw "Environment variable ADO_PAT is not set"
  }

  $adoOrg = $env:IMPORT_ADO_ORGANIZATION
  $adoProject = $env:IMPORT_ADO_PROJECT
  $adoRepo = $env:IMPORT_ADO_REPO

  # Parse components from github repo url using regex
  $githubRepoUrlRegex = [regex]::new('https://github.com/(?<organization>.+)/(?<repo>.+)(?:.git)?')
  $githubRepoUrlMatch = $githubRepoUrlRegex.Match($githubRepoUrl)
  if(-not $githubRepoUrlMatch.Success){
    throw "Failed to parse github repo url: $githubRepoUrl"
  }

  $githubOrg = $githubRepoUrlMatch.Groups['organization'].Value
  $githubRepo = $githubRepoUrlMatch.Groups['repo'].Value

  # $env:ADO_PAT | az devops login --org "https://dev.azure.com/$($adoOrg)"  --verbose


  $adoRepo = [System.Web.HttpUtility]::UrlDecode($adoRepo)
  $adoRepoId = $(az repos show --org "https://dev.azure.com/$($adoOrg)" --project $adoProject --repository $adoRepo --query id -o tsv)

  ###########################################################################
  ## Workaround (Delete the service connection that was incorrectly added)
  ###########################################################################
  # $env:ADO_PAT | az devops login --org "https://dev.azure.com/$($adoOrg)"  --verbose
  $targetServiceConnectionId = "2bcd4c53-84bd-4dea-a46c-ed1862ae9ea3"
  $sc = @(az devops service-endpoint list --org "https://dev.azure.com/$($adoOrg)" --project $adoProject --query "[?id=='$targetServiceConnectionId']" -o tsv)
  if ($sc.Count -ne 0) {
      az devops service-endpoint delete --org "https://dev.azure.com/$($adoOrg)" --project $adoProject --id $targetServiceConnectionId --yes
  }
  ###########################################################################

  gh ado2gh share-service-connection `
    --ado-org $adoOrg `
    --ado-team-project $adoProject `
    --service-connection-id $adoServiceConnectionId --verbose

  # Setup
  Update-GitHubToken -Organization $githubOrg

  gh ado2gh integrate-boards  `
        --ado-org $adoOrg `
        --ado-team-project $adoProject `
        --github-org "$githubOrg" `
        --github-repo "$githubRepo" --verbose

  gh ado2gh configure-autolink  `
        --ado-org $adoOrg `
        --ado-team-project $adoProject `
        --github-org "$githubOrg" `
        --github-repo "$githubRepo" --verbose

  $pipelines = az pipelines list --org "https://dev.azure.com/$($adoOrg)" --project $adoProject --repository $adoRepoId | ConvertFrom-Json
  Write-Host "Re-wiring $($pipelines.count) pipelines"

  foreach($pipeline in $pipelines){
    Write-Host "Re-wiring pipeline $pipelineName"
    gh ado2gh rewire-pipeline `
            --ado-org "$adoOrg" `
            --ado-team-project "$adoProject" `
            --ado-pipeline "$($pipeline.name)" `
            --github-org "$githubOrg" `
            --github-repo "$githubRepo" `
            --service-connection-id "$adoServiceConnectionId" --verbose
  }
}
catch{
  throw $_
}
finally{
  Pop-Location
  Remove-Item -Path $folder -Recurse -Force
}


