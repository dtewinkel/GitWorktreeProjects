#Requires -Module PSScriptAnalyzer

[cmdletbinding()]
param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..'))
)

$modulesFolder = Join-Path $RootPath Modules
$moduleFolder = Join-Path $modulesFolder GitWorktreeProjects
$testFolder = Join-Path $RootPath GitWorktreeProjects.Tests

Invoke-ScriptAnalyzer (Join-Path -Path $moduleFolder -ChildPath *.ps1) -ExcludeRule PSUseShouldProcessForStateChangingFunctions
Invoke-ScriptAnalyzer $testFolder -Severity Error