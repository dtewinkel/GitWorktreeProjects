#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.1.0" }

param(
	[Parameter()]
	[String] $RootPath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..'))
)

$modulesFolder = Join-Path $RootPath Modules
$moduleFolder = Join-Path $modulesFolder GitWorktreeProjects
$testFolder = Join-Path $RootPath GitWorktreeProjects.Tests
$testOutputFolder = Join-Path $RootPath TestResults
$testOutput = Join-Path $testOutputFolder TestResults.Pester.xml
$coverageOutput = Join-Path $testOutputFolder Coverage.Pester.xml

Import-Module Pester

$configuration = [PesterConfiguration]@{
		TestResult = @{
				Enabled = $true
				OutputPath = $testOutput
		}
		Output = @{
				Verbosity = 'Detailed'
		}
		CodeCoverage = @{
			Enabled = $true
			Path = "${moduleFolder}/*.psm1", "${moduleFolder}/*-*.ps1", "${moduleFolder}/*/*.ps1"
			OutputPath = $coverageOutput
		}
}

$null = mkdir $testOutputFolder -Force

Push-Location $testFolder

try
{
	Invoke-Pester -Configuration $configuration
}
finally
{
	Pop-Location
}
