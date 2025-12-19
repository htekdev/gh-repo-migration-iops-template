Param(
  [string] $Folder
)
# Download BFG Tool
Invoke-WebRequest -Uri https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -OutFile $Folder/bfg.jar