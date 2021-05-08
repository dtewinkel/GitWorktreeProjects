[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string] $Scope,

	[Parameter(Mandatory)]
	[string] $Setup
)

$sourcePath = Join-Path $PSScriptRoot .. TestFiles, $Setup
if (-not (Test-Path $sourcePath))
{
	throw "Setup '${Setup}' not found."
}
$sourcePath = Resolve-Path $sourcePath

switch ($Scope)
{
	"Default"
	{
		if ($env:GitWorktreeConfigPath)
		{
			$null = Remove-Item env:GitWorktreeConfigPath
		}
		$configRoot = Join-Path $HOME '.gitworktree'
		$configFile = Join-Path $configRoot configuration.json
	}

	"Custom"
	{
		$configRoot = Join-Path $TestDrive .gitworktree
		$configFile = Join-Path $configRoot configuration.json
		$env:GitWorktreeConfigPath = $configRoot
	}

	default
	{
		throw "Scope '${Scope}' not supported"
	}
}

$configSourceFile = Join-Path $sourcePath configuration.json
$exists = Test-Path $configSourceFile
Mock Test-Path { $exists } -ParameterFilter { $Path -eq $configFile } -ModuleName GitWorktreeProjects

if ($exists)
{
	$mockedContent = Get-Content $configSourceFile -Raw
	try
	{
		$globalConfig = $mockedContent | ConvertFrom-Json -NoEnumerate
	}
	catch
	{
		$globalConfig = $null
	}
	Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $configFile } -ModuleName GitWorktreeProjects
}

$projectFiles = Get-ChildItem (Join-Path $sourcePath '*.project') | Sort-Object Name
$projects = @()
foreach($sourceItem in $projectFiles)
{
	$name = $sourceItem.BaseName
	$projectFile = Join-Path $configRoot $sourceItem.Name
	$mockedContent = Get-Content $sourceItem -Raw
	try
	{
		$projectConfig = $mockedContent | ConvertFrom-Json -NoEnumerate -Depth 5
	}
	catch
	{
		$projectConfig = $null
	}
	$project = @{
		Name              = $name
		Project           = $projectConfig
		ProjectRaw        = $mockedContent
		ProjectConfigFile = $projectFile
		FileInfo          = [System.IO.FileInfo]$projectFile
	}
	$projects += $project
	$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq '${projectFile}'")
	Mock Test-Path { $true } -ParameterFilter $parameterFilterScriptBlock -ModuleName GitWorktreeProjects
	$resultScriptBlock = [Scriptblock]::Create("'${mockedContent}'")
	Mock Get-Content $resultScriptBlock -ParameterFilter $parameterFilterScriptBlock -ModuleName GitWorktreeProjects
	$rootPath = $projectConfig.RootPath
	$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq '${rootPath}'")
	$resultScriptBlock = [Scriptblock]::Create("@{ FullName = '$($projectConfig.RootPath)' }")
	Mock Get-Item $resultScriptBlock -ParameterFilter $parameterFilterScriptBlock -ModuleName GitWorktreeProjects
	foreach($worktreeItem in $projectConfig.Worktrees)
	{
		$worktreePath = Join-Path $rootPath $worktreeItem.RelativePath
		$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq '${worktreePath}'")
		Mock Test-Path { $true } -ParameterFilter $parameterFilterScriptBlock -ModuleName GitWorktreeProjects
		$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq '${worktreePath}'")
		Mock Set-Location {  } -ParameterFilter $parameterFilterScriptBlock -ModuleName GitWorktreeProjects
	}
}

[PSCustomObject]@{
	Scope            = $Scope
	Setup            = $Setup
	ConfigRoot       = $configRoot
	GlobalConfigFile = $configFile
	GlobalConfig     = $globalConfig
	Projects         = $projects | ForEach-Object { @{ $_.Name = $_ } }
}

Mock Get-ChildItem { $projects.FileInfo } -ParameterFilter { $Path -eq (Join-Path $configRoot '*.project') } -ModuleName GitWorktreeProjects
