#Requires -Module @{ ModuleName="Pester"; ModuleVersion="5.1.0" }, PSScriptAnalyzer

$root = Resolve-Path (Join-Path $PSScriptRoot '..' '..', '..')

$toolsFolder = Join-Path $root tools
$moduleFolder = Join-Path $root Modules GitWorktreeProjects
$testFolder = Join-Path $root GitWorktreeProjects.Tests
$testOutputFolder = Join-Path $root TestResults
$testOutput = Join-Path $testOutputFolder TestResults.Pester.xml
$coverageOutput = Join-Path $testOutputFolder Coverage.Pester.xml
$reportGenerator = Join-Path $toolsFolder reportgenerator.exe

Invoke-ScriptAnalyzer (Join-Path -Path $moduleFolder -ChildPath *.ps1) -ExcludeRule PSReviewUnusedParameter, PSShouldProcess, PSUseShouldProcessForStateChangingFunctions
Invoke-ScriptAnalyzer $testFolder -Severity Error

if(-not (Test-Path $reportGenerator))
{
	dotnet tool install dotnet-reportgenerator-globaltool --tool-path $toolsFolder
}

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
			Path = "${moduleFolder}\*.psm1", "${moduleFolder}\*-*.ps1"
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

& $reportGenerator "-targetdir:${testOutputFolder}" "-reports:${coverageOutput}" "-sourcedirs:${moduleFolder}" -verbosity:warning
Write-Host "Coverage report written to ${testOutputFolder}\index.htm"
