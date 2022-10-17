[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "SetProjectConfig" {

	BeforeAll {

		. $PSScriptRoot/../TestHelpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder

		$configFileDirectory = "DoesNotExist"
		$configFilePath = "DoesNotExist/${projectName}.project"
		$projectName = "MyProject"
		$projectConfig = @{
			Name = $projectName
		}
		$convertedJson = "{ }"
		Mock New-Item {}
		Mock Out-File {} -RemoveParameterType "Encoding"
	}

	It "Should create path if config path does not exist." {

		Mock GetConfigFilePath { $configFileDirectory } -ParameterFilter { -not $ChildPath } -Verifiable
		Mock GetConfigFilePath { $configFilePath } -ParameterFilter { $ChildPath -eq "${projectName}.project" } -Verifiable
		Mock Test-Path { $false } -ParameterFilter { $Path -eq $configFileDirectory } -Verifiable
		Mock ConvertTo-Json { $convertedJson } -ParameterFilter { $InputObject.Name -eq $projectName } -Verifiable

		SetProjectConfig -Project $projectName -ProjectConfig $projectConfig

		Should -InvokeVerifiable
		Should -Invoke New-Item -ParameterFilter { $ItemType -eq "Directory" -and $Path -eq $configFileDirectory } -Times 1
		Should -Invoke Out-File -ParameterFilter { $Encoding -eq "utf8BOM" -and $FilePath -eq $configFilePath -and $InputObject -eq $convertedJson } -Times 1
	}


	It "Should not create path if config path does exist and store the file" {

		Mock GetConfigFilePath { $configFileDirectory } -ParameterFilter { -not $ChildPath } -Verifiable
		Mock GetConfigFilePath { $configFilePath } -ParameterFilter { $ChildPath -eq "${projectName}.project" } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configFileDirectory } -Verifiable
		Mock ConvertTo-Json { $convertedJson } -ParameterFilter { $InputObject.Name -eq $projectName } -Verifiable

		SetProjectConfig -Project $projectName -ProjectConfig $projectConfig

		Should -InvokeVerifiable
		Should -Not -Invoke New-Item
		Should -Invoke Out-File -ParameterFilter { $Encoding -eq "utf8BOM" -and $FilePath -eq $configFilePath -and $InputObject -eq $convertedJson } -Times 1
	}
}
