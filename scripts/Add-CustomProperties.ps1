Param(
  [string] $githubRepoUrl,
  [string] $values # Multi-line string
)

. "$($PSScriptRoot)/modules.ps1"

Write-Output "| *Adding Custom Properties* |  |  |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append


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


  # Split values per line using regex
  $valuesRegex = [regex]::new('(?<property_name>.+?)=(?<value>.+)')
  $valuesMatch = $valuesRegex.Matches($values)
  if(-not $valuesMatch.Success){
    throw "Failed to parse values: $values"
  }

  $items = $valuesMatch.Value | % { $_.Trim()}
  $payload = @{
    properties = @($items | % {
      @{
        property_name = $_.Split("=")[0].Trim()
        value = $_.Split("=")[1].Trim()
      }
    })
  }
  Write-Host $($payload | ConvertTo-Json -Depth 100)
  
  Invoke-GitHubApiRoute -Method Patch -Body $($payload | ConvertTo-Json -Depth 100) -Path "repos/$($githubOrg)/$($githubRepo)/properties/values" | Out-Null
  Write-Output "| **Updated Custom Properties** | ✅ | |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
}
catch{
  Write-Output "| **Updated Custom Properties** | ❌ | $($_.Exception.Message) |" | Out-File -FilePath $env:JOB_SUMMARY_FILE -Encoding utf8 -Append
  throw $_
}
finally{
  
}


