[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "SetGlobalConfig" {

	BeforeAll {

		$globalConfig = @{
			DefaultRootPath     = '/root'
			DefaultSourceBranch = 'origin'
			DefaultTools        = @( '1', 'a')
		}

		$configFilePath = '/config/path'
		$configFile = '/config/file'

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder

		Mock Out-File {} -RemoveParameterType "Encoding"
		Mock New-Item { @{} }
		Mock GetConfigFilePath { $configFilePath } -ParameterFilter { -not $ChildPath } -Verifiable
		Mock GetConfigFilePath { $configFile } -ParameterFilter { $ChildPath -eq 'configuration.json' } -Verifiable
	}

	It "should have the right parameters" {
		$command = Get-Command SetGlobalConfig
		$command | Should -HaveParameter GlobalConfig -Mandatory
	}

	It "Should create the global config directory if it does not exist" {

		Mock Test-Path { $false } -ParameterFilter { $Path -eq $configFilePath } -Verifiable

		SetGlobalConfig -GlobalConfig $globalConfig

		Should -InvokeVerifiable
		Should -Invoke New-Item -ParameterFilter { $ItemType -eq 'Directory' -and $Path -eq $configFilePath }
	}

	It "Should not create the global config directory if it does exist" {

		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configFilePath } -Verifiable

		SetGlobalConfig -GlobalConfig $globalConfig

		Should -InvokeVerifiable
		Should -Not -Invoke New-Item -ParameterFilter { $ItemType -eq 'Directory' -and $Path -eq $configFilePath }
	}

	It "Should serialize the global config and write it to file" {

		$stringContent = '{ ... JSON ... }'
		$expectedConfig = @{
			SchemaVersion       = 1
			DefaultRootPath     = '/root'
			DefaultSourceBranch = 'origin'
			DefaultTools        = @( '1', 'a')
		}
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configFilePath } -Verifiable
		Mock ConvertTo-Json { $stringContent } -Verifiable -ParameterFilter { & $PSScriptRoot/../Helpers/CompareObject.ps1 $InputObject $expectedConfig GlobalConfigFile -AsBoolean }

		SetGlobalConfig -GlobalConfig $globalConfig

		Should -InvokeVerifiable
		Should -Invoke Out-File -ParameterFilter { $InputObject -eq $stringContent -and $Path -eq $configFile -and $Encoding -eq 'utf8BOM' } -Times 1
	}
}
