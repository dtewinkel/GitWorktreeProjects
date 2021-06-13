[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules", "GitWorktreeProjects")).Path
)

$modulePath = (Resolve-Path (Join-Path $ModuleFolder '..')).Path
if(-not ($env:PSModulePath.Contains($modulePath)))
{
	$env:PSModulePath = $modulePath + ";" + $env:PSModulePath
}

Remove-Module GitWorktreeProjects -Force -ErrorAction SilentlyContinue
Import-Module GitWorktreeProjects -Force
