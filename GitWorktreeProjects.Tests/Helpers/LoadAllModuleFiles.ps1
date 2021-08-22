[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules", "GitWorktreeProjects")).Path
)

Get-ChildItem (Join-Path $ModuleFolder Types *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $ModuleFolder Config *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $ModuleFolder Git *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $ModuleFolder Tools *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $ModuleFolder ArgumentCompleters *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
