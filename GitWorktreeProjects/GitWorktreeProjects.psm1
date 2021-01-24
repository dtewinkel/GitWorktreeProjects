Get-ChildItem (Join-Path $PSScriptRoot Types *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module
Get-ChildItem (Join-Path $PSScriptRoot ArgumentCompleters *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module
Get-ChildItem (Join-Path $PSScriptRoot *.ps1) | ForEach-Object FullName | Resolve-Path | Import-Module

$moduleData = Import-PowerShellDataFile (Join-Path $PSScriptRoot GitWorktreeProjects.psd1)

$moduleData.FunctionsToExport | ForEach-Object { Export-ModuleMember -Function $PSItem }
$moduleData.AliasesToExport | ForEach-Object { Export-ModuleMember -Alias $PSItem }
