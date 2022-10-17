[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "GetGlobalConfig" {

	BeforeAll {

		. $PSScriptRoot/../TestHelpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should throw if GetConfigFile throws" {

		Mock GetConfigFile { throw "Oops!" }
		{ GetGlobalConfig } | Should -Throw "Oops!"
	}

	It "returns default config if config file does not exist" {

		Mock GetConfigFile { $null } -ParameterFilter { $FileName -eq 'configuration.json' } -Verifiable
		Mock Write-Warning {} -ParameterFilter { $Message -like "Global configuration file 'configuration.json' not found! Using default configuration." } -Verifiable
		Mock Get-Item { @{ Value = '/' } } -ParameterFilter { $Path -eq 'Env:USERPROFILE' } -Verifiable

		$globalConfig = GetGlobalConfig

		Should -InvokeVerifiable
		$globalConfig | Should -Not -BeNullOrEmpty
		$globalConfig.DefaultRootPath | Should -Be '/'
		$globalConfig.DefaultSourceBranch | Should -Be 'main'
	}

	It "returns config if config file exists" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'

		$fileContents = @{
			SchemaVersion       = 1
			DefaultRootPath     = $defaultRootPath
			DefaultSourceBranch = $defaultSourceBranch
		}
		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq 'configuration.json' } -Verifiable

		$globalConfig = GetGlobalConfig

		Should -InvokeVerifiable
		$globalConfig | Should -Not -BeNullOrEmpty
		$globalConfig.DefaultRootPath | Should -Be $defaultRootPath
		$globalConfig.DefaultSourceBranch | Should -Be $defaultSourceBranch
	}
}
