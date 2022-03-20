#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.3.1" }

param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')),

	[Parameter()]
	[String] $ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..', 'Modules', 'GitWorktreeProjects')),

	[Parameter()]
	[String] $TestPath = (Resolve-Path (Join-Path $RootPath 'GitWorktreeProjects.Tests')),

	[Parameter()]
	[String] $TestOutput = (Join-Path $RootPath TestResults TestResults.Pester.xml),

	[Parameter()]
	[String] $CoverageOutput = (Join-Path $RootPath TestResults Coverage.Pester.xml),

	[Parameter()]
	[String] $CoverageOutputFormat,

	[Parameter()]
	[String] $OutputVerbosity = 'Detailed'
)

$testDataFileName = 'testdata.json'
if(Test-Path $testDataFileName)
{
	$testData = get-content $testDataFileName -Raw | ConvertFrom-Json
}
else
{
	$testData = @{
		RunIntegrationTests = $false
	}
}

$RunIntegrationTests = $testData.RunIntegrationTests ?? $false

$testOutputFolder = ([System.IO.Fileinfo]$TestOutput).DirectoryName

$testConfigData = @{
	ModuleFolder = $moduleFolder
}

$testConfigDataIntegratoinTests = @{
	ModuleFolder        = $moduleFolder
}

$configuration = New-PesterConfiguration

$containers = New-PesterContainer -Path (Join-Path $testPath '*' '*.Tests.ps1') -Data $testConfigData
$containers += New-PesterContainer -Path (Join-Path $testPath '*.Tests.ps1') -Data $testConfigData
if ($RunIntegrationTests)
{
	$containers += New-PesterContainer -Path (Join-Path $testPath '*' '*.IntegrationTests.ps1') -Data $testConfigDataIntegratoinTests
	$containers += New-PesterContainer -Path (Join-Path $testPath '*.IntegrationTests.ps1') -Data $testConfigDataIntegratoinTests
}

$configuration.Run.Container = $containers

$configuration.TestResult.Enabled = $true
$configuration.TestResult.OutputPath = $TestOutput
$configuration.Output.Verbosity = $OutputVerbosity
$configuration.CodeCoverage.Enabled = $true
$configuration.CodeCoverage.Path = "${moduleFolder}/*.psm1", "${moduleFolder}/*-*.ps1", "${moduleFolder}/*/*.ps1"
$configuration.CodeCoverage.OutputPath = $CoverageOutput
$configuration.CodeCoverage.UseBreakpoints = $false
$configuration.TestDrive.Enabled = $false
$configuration.TestRegistry.Enabled = $false
if ($CoverageOutputFormat)
{
	$configuration.CodeCoverage.OutputFormat = $CoverageOutputFormat
}

$null = New-Item -ItemType directory -Path $testOutputFolder -Force

Invoke-Pester -Configuration $configuration
