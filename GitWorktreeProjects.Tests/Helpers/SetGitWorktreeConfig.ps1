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
		$mockFiles = $true
		if ($env:GitWorktreeConfigPath)
		{
			$null = Remove-Item env:GitWorktreeConfigPath
		}
		$configRoot = Join-Path $HOME '.gitworktree'
		$configFile = Join-Path $configRoot configuration.json
	}

	"Custom"
	{
		$mockFiles = $false
		$configRoot = Join-Path $TestDrive .gitworktree
		$configFile = Join-Path $configRoot configuration.json
		$env:GitWorktreeConfigPath = $configRoot

		if (Test-Path $configRoot)
		{
			$null = Remove-Item $configRoot -Recurse -Force
		}
		$null = New-Item -ItemType Directory $configRoot
		$null = Copy-Item (Join-Path $sourcePath *) $configRoot -Recurse -Force
	}

	default
	{
		throw "Scope '${Scope}' not supported"
	}
}

$configSourceFile = Join-Path $sourcePath configuration.json
$exists = Test-Path $configSourceFile
if ($mockFiles)
{
	Mock Test-Path { $exists } -ParameterFilter { $Path -eq $configFile }
}
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
	if ($mockFiles)
	{
		Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $configFile }
	}
}

$projects = @()

Get-ChildItem (Join-Path $sourcePath '*.project') | ForEach-Object {

	$sourceItem = $_
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
	if ($mockFiles)
	{
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $projectFile }
		Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $projectFile }
	}
	$project = @{
		Name              = $sourceItem.BaseName
		Project           = $projectConfig
		ProjectConfigFile = $projectFile
		FileInfo          = [System.IO.FileInfo]$projectFile
	}
	$projects += $project
}

[PSCustomObject]@{
	Scope            = $Scope
	Setup            = $Setup
	ConfigRoot       = $configRoot
	GlobalConfigFile = $configFile
	GlobalConfig     = $globalConfig
	Projects         = $projects | ForEach-Object { @{ $_.Name = $_ } }
}

Mock Get-ChildItem { $projects.FileInfo } -ParameterFilter { $Path -eq (Join-Path $configRoot '*.project') }
