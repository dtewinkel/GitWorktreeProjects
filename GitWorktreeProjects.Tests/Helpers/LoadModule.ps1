$modulePath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules")).Path
if(-not ($env:PSModulePath.Contains($modulePath)))
{
	$env:PSModulePath = $modulePath + ";" + $env:PSModulePath
}

Remove-Module GitWorktreeProjects -Force -ErrorAction SilentlyContinue

Import-Module GitWorktreeProjects -Force
